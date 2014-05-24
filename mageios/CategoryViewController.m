//
//  CategoryViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 11/02/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "CategoryViewController.h"
#import "ProductListViewController.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"
#import "Service.h"
#import "XCategory.h"
#import "Utility.h"

@interface CategoryViewController () {
    Service *service;
    XCategory *category;
    Utility *utility;
}

@end

@implementation CategoryViewController

@synthesize parent_category, loading, current_category;

- (void) observer:(NSNotification *) notification
{
    // perform ui updates from main thread so that they updates correctly
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(observer:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    [self.loading hide:YES];
    if ([[notification name] isEqualToString:@"serviceNotification"]) {
        [self updateCommonStyles];
        category = [[XCategory alloc] init];
    } else if ([[notification name] isEqualToString:@"categoryDataLoadedNotification"]) {
        [self updateCategories];
    }
}

- (void)addObservers
{
    
    // Add request completed observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"requestCompletedNotification"
                                               object:nil];
    // Add service observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"serviceNotification"
                                               object:nil];
    // Add category list observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"categoryDataLoadedNotification"
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    utility = [[Utility alloc] init];
    
    if (parent_category == nil) {
        [utility addLeftMenu:self];
    }
    
    // Do any additional setup after loading the view.
    
    // show loading
    self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loading.labelText = @"Loading";
}


- (void)updateCommonStyles
{
    // set backgroundcolor
    [self.collectionView setBackgroundColor:[UIColor colorWithHex:[service.config_data valueForKeyPath:@"body.backgroundColor"] alpha:1.0]];
    
    // set title
    if ([parent_category valueForKey:@"label"]) {
        self.navigationItem.title = [parent_category valueForKey:@"label"];
    } else {
        self.navigationItem.title = @"Shop";
    }
}

- (void)updateCategories
{
    if ([category.data valueForKeyPath:@"items.item"] != nil) {
        // reload collectionview
        [self.collectionView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self addObservers];
    
    service = [Service getInstance];
    
    if (service.initialized) {
        [self updateCommonStyles];
        if (category) {
            [self updateCategories];
            [self.loading hide:YES];
        } else {
            if (current_category == nil) {
                if (parent_category != nil) {
                    int cat_id = [[parent_category valueForKey:@"entity_id"] integerValue];
                    category = [[XCategory alloc] initWithId:cat_id];
                } else {
                    category = [[XCategory alloc] init];
                }
            }
        }
    }
    
    [self openCurrentCategoryPage];
}

- (void)openCurrentCategoryPage
{
    // fire segue for current category (if available, from home tab)
    if (self.current_category != nil) {
        [self performSegueWithIdentifier:@"productsListSegue" sender:self.current_category];
//        if ([[self.current_category valueForKeyPath:@"content_type"] isEqualToString:@"categories"]) {
//            [self performSegueWithIdentifier:@"loopbackSegue" sender:self.current_category];
//        } else if ([[self.current_category valueForKeyPath:@"content_type"] isEqualToString:@"products"]) {
//            [self performSegueWithIdentifier:@"productsListSegue" sender:self.current_category];
//        }
        self.current_category = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/* collection delegate methods */

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[category.data valueForKeyPath:@"items.item"] count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *cat = [[category.data valueForKeyPath:@"items.item"] objectAtIndex:indexPath.row];
    
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    // set icon
    UIImageView *categoryImageView = (UIImageView *)[cell viewWithTag:100];
    UIImage *icon_image = [UIImage imageWithData:
                           [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:[cat valueForKeyPath:@"icon.@innerText"]]]];
    [categoryImageView setImage:icon_image];
    
    //border to icon
    CALayer *borderLayer = [CALayer layer];
    CGRect borderFrame = CGRectMake(0, 0, (categoryImageView.frame.size.width), (categoryImageView.frame.size.height));
    [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [borderLayer setFrame:borderFrame];
    [borderLayer setBorderWidth:1.0];
    [borderLayer setBorderColor:[[UIColor colorWithHex:[service.config_data valueForKeyPath:@"body.backgroundColor"] alpha:1.0] CGColor]];
    [categoryImageView.layer addSublayer:borderLayer];
    
    // set label
    UILabel *label = (UILabel *)[cell viewWithTag:200];
    //label.backgroundColor=[UIColor clearColor];
    //label.textColor=[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0];
    label.text = [cat valueForKey:@"label"];
    
    
    //border to cell
    CALayer *cellBorderLayer = [CALayer layer];
    CGRect cellBorderFrame = CGRectMake(0, 0, (cell.frame.size.width), (cell.frame.size.height));
    [cellBorderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [cellBorderLayer setFrame:cellBorderFrame];
    [cellBorderLayer setBorderWidth:1.0];
    [cellBorderLayer setBorderColor:[[UIColor colorWithHex:@"#EEEBEB" alpha:1.0] CGColor]];
    [cell.layer addSublayer:cellBorderLayer];

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cat = [[category.data valueForKeyPath:@"items.item"] objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"productsListSegue" sender:cat];
//    if ([[cat valueForKeyPath:@"content_type"] isEqualToString:@"categories"]) {
//        [self performSegueWithIdentifier:@"loopbackSegue" sender:cat];
//    } else if ([[cat valueForKeyPath:@"content_type"] isEqualToString:@"products"]) {
//        [self performSegueWithIdentifier:@"productsListSegue" sender:cat];
//    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"loopbackSegue"]) {
        CategoryViewController *nextController = segue.destinationViewController;
        nextController.parent_category = sender;
        //nextController.title = [sender valueForKeyPath:@"name"];
    } else if ([segue.identifier isEqualToString:@"productsListSegue"]) {
        ProductListViewController *nextController = segue.destinationViewController;
        nextController.title = [sender valueForKey:@"label"];
        nextController.current_category = sender;
    }
}

@end
