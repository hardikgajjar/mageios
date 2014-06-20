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
        home = [Home getInstance];
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
    self.loading = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] windows] objectAtIndex:0] animated:YES];
    self.loading.labelText = @"Loading";
    
    [self addObservers];
    
    service = [Service getInstance];
    
    if (service.initialized) {
        [self updateCommonStyles];
        home = [Home getInstance];
    }

    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (screenSize.height > 480.0f) { //iphone5
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.container
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:0.5
                                                                       constant:0];
        [self.view addConstraint:constraint];
    }
}

- (void)updateCommonStyles
{
    // set backgroundcolor
    [self.view setBackgroundColor:[UIColor colorWithHex:[service.config_data valueForKeyPath:@"body.primaryColor"] alpha:1.0]];
    
    // set banner image
    if ([service.config_data valueForKeyPath:@"body.bannerImage"] != nil) {
        UIImage *banner = [UIImage imageWithData:
                           [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:[service.config_data valueForKeyPath:@"body.bannerImage"]]]];
        [self.home_banner setImage:banner];
    }
    
    // set title view
    //UIView *titleview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    /*UIImage *nav_icon = [UIImage imageWithData:
                       [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:[service.config_data valueForKeyPath:@"navigationBar.icon"]]]];*/
    UIImage *nav_icon = [UIImage imageNamed:@"logo"];
    UIImageView *nav_icon_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 27)];
    [nav_icon_view setImage:nav_icon];
    
    UILabel *nav_label = [[UILabel alloc] initWithFrame:CGRectMake(145, 0, 100, 30)];
    nav_label.text = self.navigationItem.title;
    //nav_label.backgroundColor=[UIColor clearColor];
    //nav_label.textColor=[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0];
    
    //[titleview addSubview:nav_icon_view];
    //[titleview addSubview:nav_label];
    self.navigationItem.titleView = nav_icon_view;
}

- (void)updateCategories
{
    if ([home.data valueForKeyPath:@"categories.item"] != nil) {
        int i=0;
        int total_width = 0;
        float box_w = 91.5f;
        int box_h = 120;
        float padding_l = 5.75f;
        float padding_t = 5.75f;
        
        for (NSDictionary *category in [home.data valueForKeyPath:@"categories.item"]) {
            int x = box_w*i;
            int x1 = x;
            if (i!=0) x1 += (i*7.75f);
            
            //background view
            UIView *background = [[UIView alloc] initWithFrame:CGRectMake(x1, 0, box_w, box_h)];
            background.layer.cornerRadius = 5.0;
            background.layer.masksToBounds = YES;
            [background setTag:[[category valueForKey:@"entity_id"] integerValue]];
            [background setBackgroundColor:[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.backgroundColor"] alpha:1.0]];
            
            CALayer *cellBorderLayer = [CALayer layer];
            CGRect cellBorderFrame = CGRectMake(0, 0, (background.frame.size.width), (background.frame.size.height));
            [cellBorderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
            [cellBorderLayer setFrame:cellBorderFrame];
            [cellBorderLayer setBorderWidth:1.0];
            [cellBorderLayer setBorderColor:[[UIColor colorWithHex:@"#EEEBEB" alpha:1.0] CGColor]];
            [background.layer addSublayer:cellBorderLayer];
            
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
            UIView *label_background = [[UIView alloc] initWithFrame:CGRectMake(1, box_h - 23, box_w - 2, 23)];
            //[label_background setBackgroundColor:[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0]];
            
            // add half rectangle
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:label_background.bounds
                                                           byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                                 cornerRadii:CGSizeMake(1, 1)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = label_background.bounds;
            maskLayer.path = maskPath.CGPath;
            label_background.layer.mask = maskLayer;
            label_background.layer.masksToBounds = YES;
            
            // add top border
            CGSize mainViewSize = label_background.bounds.size;
            UIColor *borderColor = [UIColor colorWithHex:@"#d6d6d6" alpha:1.0];
            UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainViewSize.width, 1)];
            topView.opaque = YES;
            topView.backgroundColor = borderColor;
            
            // for bonus points, set the views' autoresizing mask so they'll stay with the edges:
            topView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
            [label_background addSubview:topView];
            
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 75, 23)];
            label.backgroundColor=[UIColor clearColor];
            label.textColor=[UIColor grayColor];
            UIFont* boldFont = [UIFont boldSystemFontOfSize:12];
            label.font=boldFont;
            label.text = [category valueForKey:@"label"];
            [label_background addSubview:label];
            
            [background addSubview:icon];
            [background addSubview:label_background];

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
