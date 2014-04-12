//
//  HomeViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 05/02/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "HomeViewController.h"
#import "CategoryViewController.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"
#import "Service.h"
#import "Home.h"
#import "Utility.h"

@interface HomeViewController () {
    Service *service;
    Home *home;
    Utility *utility;
}
@end

@implementation HomeViewController

@synthesize home_banner, categories_placeholder, loading;

- (void) observer:(NSNotification *) notification
{
    // perform ui updates from main thread so that they updates correctly
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(observer:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    if ([[notification name] isEqualToString:@"serviceNotification"]) {
        [self updateCommonStyles];
        home = [[Home alloc] init];
    } else if ([[notification name] isEqualToString:@"homeDataLoadedNotification"]) {
        [self updateCategories];
        [self.loading hide:YES];
    }
}

- (void)addObservers
{
    // Add service observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"serviceNotification"
                                               object:nil];
    // Add home observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"homeDataLoadedNotification"
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    utility = [[Utility alloc] init];
    [utility addLeftMenu:self];
    
    // show loading
    self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loading.labelText = @"Loading";
    
    [self addObservers];
    
    service = [Service getInstance];
    
    if (service.initialized) {
        [self updateCommonStyles];
        home = [[Home alloc] init];
    }
}

- (void)updateCommonStyles
{
    // set backgroundcolor
    [self.view setBackgroundColor:[UIColor colorWithHex:[service.config_data valueForKeyPath:@"body.backgroundColor"] alpha:1.0]];
    
    // set background Image
    if ([service.config_data valueForKeyPath:@"body.backgroundImage"] != nil) {
        UIImage *banner = [UIImage imageWithData:
                           [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:[service.config_data valueForKeyPath:@"body.bannerImage"]]]];
        [self.home_banner setImage:banner];
    }
    
    // set title view
    //UIView *titleview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    UIImage *nav_icon = [UIImage imageWithData:
                       [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:[service.config_data valueForKeyPath:@"navigationBar.icon"]]]];
    UIImageView *nav_icon_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [nav_icon_view setImage:nav_icon];
    
    UILabel *nav_label = [[UILabel alloc] initWithFrame:CGRectMake(145, 0, 100, 30)];
    nav_label.text = self.navigationItem.title;
    nav_label.backgroundColor=[UIColor clearColor];
    nav_label.textColor=[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0];
    
    //[titleview addSubview:nav_icon_view];
    //[titleview addSubview:nav_label];
    self.navigationItem.titleView = nav_icon_view;
}

- (void)updateCategories
{
    if ([home.data valueForKeyPath:@"categories.item"] != nil) {
        int i=0;
        int total_width = 0;
        int box_w = 95;
        int box_h = 115;
        int padding_l = 7.5;
        int padding_t = 7.5;
        
        for (NSDictionary *category in [home.data valueForKeyPath:@"categories.item"]) {
            int x = 95*i;
            int x1 = x;
            if (i!=0) x1 += (i*5);
            
            //background view
            UIView *background = [[UIView alloc] initWithFrame:CGRectMake(x1, 0, box_w, box_h)];
            [background setTag:[[category valueForKey:@"entity_id"] integerValue]];
            [background setBackgroundColor:[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.backgroundColor"] alpha:1.0]];
            
            //icon
            UIImage *icon_image = [UIImage imageWithData:
                               [NSData dataWithContentsOfURL:
                                [NSURL URLWithString:[category valueForKeyPath:@"icon.@innerText"]]]];
            UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(padding_l, padding_t, 80, 80)];
            [icon setImage:icon_image];
            
            //border to icon
            CALayer *borderLayer = [CALayer layer];
            CGRect borderFrame = CGRectMake(0, 0, (icon.frame.size.width), (icon.frame.size.height));
            [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
            [borderLayer setFrame:borderFrame];
            [borderLayer setBorderWidth:1.0];
            [borderLayer setBorderColor:[[UIColor colorWithHex:[service.config_data valueForKeyPath:@"body.backgroundColor"] alpha:1.0] CGColor]];
            [icon.layer addSublayer:borderLayer];
            
            //label
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(7.5, 90, 85, 25)];
            label.backgroundColor=[UIColor clearColor];
            label.textColor=[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0];
            label.font=[label.font fontWithSize:13];
            label.text = [category valueForKey:@"label"];
            
            [background addSubview:icon];
            [background addSubview:label];

            // bind touch gesture
            UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(categoryTap:)];
            [background addGestureRecognizer:singleFingerTap];

            [self.categories_placeholder addSubview:background];
            
            total_width = x1 + box_w;
            i++;
        }
        self.categories_placeholder.contentSize = CGSizeMake(total_width, box_h);
    }
}

- (void)categoryTap:(UITapGestureRecognizer *)recognizer {
    
    // get touched category
    
    for (NSDictionary *category in [home.data valueForKeyPath:@"categories.item"]) {
        if ([[category valueForKey:@"entity_id"] integerValue] == recognizer.view.tag) {
            
            // open shop tab [tabs index is 0 based]
            
            UINavigationController *t = [self.tabBarController.viewControllers objectAtIndex:1];
            [t popToRootViewControllerAnimated:NO];
            
            CategoryViewController *cat_view = [t.childViewControllers objectAtIndex:0];
            cat_view.current_category = category;
            
            self.tabBarController.selectedIndex = 1;
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

@end
