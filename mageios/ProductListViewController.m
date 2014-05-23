//
//  ProductListViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 21/02/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "ProductListViewController.h"
#import "ProductViewController.h"
#import "Service.h"
#import "XCategory.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"

@interface ProductListViewController ()

@end

@implementation ProductListViewController {
    Service *service;
    XCategory *category;
    UISegmentedControl *sorters;
    int lastSelectedDirection; //0=asc, 1=desc
    int offset;
    int count;
}

@synthesize current_category,loading,products;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) observer:(NSNotification *) notification
{
    // perform ui updates from main thread so that they updates correctly
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(observer:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    [self.loading hide:YES];
    
    if ([[notification name] isEqualToString:@"categoryDataLoadedNotification"]) {
        
        if ([[category valueForKeyPath:@"orders"] isKindOfClass:[NSDictionary class]]) {
            self.orders = [NSArray arrayWithObjects:[category valueForKeyPath:@"orders"], nil];
        } else {
            self.orders = [category valueForKeyPath:@"orders"];
        }
        
        if ([[category valueForKeyPath:@"filters"] isKindOfClass:[NSDictionary class]]) {
            self.filters = [NSArray arrayWithObjects:[category valueForKeyPath:@"filters"], nil];
        } else {
            self.filters = [category valueForKeyPath:@"filters"];
        }
        
        if ([[category valueForKeyPath:@"products"] isKindOfClass:[NSDictionary class]]) {
            self.products = [NSArray arrayWithObjects:[category valueForKeyPath:@"products"], nil];
        } else {
            self.products = [category valueForKeyPath:@"products"];
        }

        [self updateProducts];
        
    } else if ([[notification name] isEqualToString:@"moreProductsLoadedNotification"]) {
        
        if ([[category valueForKeyPath:@"products"] isKindOfClass:[NSDictionary class]]) {
            self.products = [NSArray arrayWithObjects:[category valueForKeyPath:@"products"], nil];
        } else {
            self.products = [category valueForKeyPath:@"products"];
        }
        
        [self updateProducts];
    }
}

- (void)addObservers
{
    // Add request completed observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"requestCompletedNotification"
                                               object:nil];
    
    // Add category products load observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"categoryDataLoadedNotification"
                                               object:nil];
    // Add more products load observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"moreProductsLoadedNotification"
                                               object:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    // show loading
    self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loading.labelText = @"Loading";
    
    [self addObservers];
    
    service = [Service getInstance];
    
    // intialize constants
    lastSelectedDirection = 0;
    offset = 0;
    count = 10;
    
    if (service.initialized) {
        [self updateCommonStyles];
        
        if (self.current_category != nil) {
            int cat_id = [[self.current_category valueForKey:@"entity_id"] integerValue];
            category = [[XCategory alloc] initWithId:cat_id withOffset:offset withCount:count];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateCommonStyles
{
    // set backgroundcolor
    [self.tableView setBackgroundColor:[UIColor colorWithHex:[service.config_data valueForKeyPath:@"body.backgroundColor"] alpha:1.0]];
}

- (void)updateProducts
{
    if (self.products != nil) {
        
        if (offset == 0) {
            
            [self.tableView reloadData];
            
        } else { //attach items at bottom
            
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            
            for (NSInteger index = offset; index < [self.products count]; index++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:1];
                [indexPaths addObject:indexPath];
                
            }
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths
                                  withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            
            //scroll to latest rows
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:offset inSection:1];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else {
        return [self.products count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"SortbyCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // set sorters
        if (sorters == NULL && self.orders != NULL) {
            sorters = [[UISegmentedControl alloc] initWithFrame:CGRectMake(80, 11, 100, 30)];
            sorters.tintColor = [UIColor grayColor];
            [sorters addTarget:self
                        action:@selector(sortBy:)
              forControlEvents:UIControlEventValueChanged];
            [sorters setApportionsSegmentWidthsByContent:YES]; //change width of segment dynamically as per its text
            
            for (int i=0; i < [self.orders count]; i++) {
                NSDictionary *item = [self.orders objectAtIndex:i];
                [sorters insertSegmentWithTitle:[item valueForKey:@"name"]
                                        atIndex:i
                                       animated:FALSE];
                [sorters setWidth:65.0f forSegmentAtIndex:i];
                if ([[item valueForKey:@"_isDefault"] isEqualToString:@"1"]) {
                    [sorters setSelectedSegmentIndex:i];
                }
            }
            [sorters sizeToFit];
            [cell addSubview:sorters];
        }
        return cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *product = [self.products objectAtIndex:indexPath.row];
    
    // set icon
    UIImageView *productImageView = (UIImageView *)[cell viewWithTag:10];
    UIImage *icon_image = [UIImage imageWithData:
                           [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:[product valueForKeyPath:@"icon.@innerText"]]]];
    [productImageView setImage:icon_image];
    
    //border to icon
    CALayer *borderLayer = [CALayer layer];
    CGRect borderFrame = CGRectMake(0, 0, (productImageView.frame.size.width), (productImageView.frame.size.height));
    [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [borderLayer setFrame:borderFrame];
    [borderLayer setBorderWidth:1.0];
    [borderLayer setBorderColor:[[UIColor colorWithHex:[service.config_data valueForKeyPath:@"body.backgroundColor"] alpha:1.0] CGColor]];
    [productImageView.layer addSublayer:borderLayer];
    
    // set name
    UILabel *name = (UILabel *)[cell viewWithTag:20];
    //name.backgroundColor=[UIColor clearColor];
    //name.textColor=[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0];
    name.text = [product valueForKey:@"name"];
    
    // set price
    NSDictionary *price_attributes = [product valueForKeyPath:@"price.@attributes"];
    NSString *price;
    
    if ([price_attributes valueForKey:@"regular"]) price = [price_attributes valueForKey:@"regular"];
    else if ([price_attributes valueForKey:@"starting_at"]) {
        price = @"Starting At ";
        price = [price stringByAppendingString:[price_attributes valueForKey:@"starting_at"]];
    }

    UILabel *price_label = (UILabel *)[cell viewWithTag:30];
    //price_label.backgroundColor=[UIColor clearColor];
    //price_label.textColor=[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0];
    price_label.text = price;
    
    // set ratings
    if ([[product valueForKey:@"reviews_count"] integerValue] > 0) {
        ASStarRatingView *staticStarRatingView = [[ASStarRatingView alloc] initWithFrame:CGRectMake(15, 90, 85, 15)];
        staticStarRatingView.canEdit = NO;
        staticStarRatingView.maxRating = 5;
        staticStarRatingView.rating = [[product valueForKey:@"reviews_count"] integerValue];
        
        [cell addSubview:staticStarRatingView];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 50;
    return 110;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([category.hasMoreItems isEqualToString:@"1"]) {

        float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (endScrolling >= scrollView.contentSize.height)
        {
            offset += count;
            count += count;
            [category fetchRowsWithOffset:offset withCount:count];
        }
        
    }
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    int selectedRow = [[self.tableView indexPathForSelectedRow] row];
    
    // set product information
    ProductViewController *product_controller = [segue destinationViewController];
    product_controller.title = [[self.products objectAtIndex:selectedRow] valueForKey:@"name"];
    product_controller.current_product = [self.products objectAtIndex:selectedRow];
}


#pragma mark - segment control
- (void)sortBy: (id) sender
{
    [self.loading show:YES];
    
    if (lastSelectedDirection == 0)
    {
        [category sortBy:[[self.orders objectAtIndex:[sorters selectedSegmentIndex]] valueForKey:@"code"]
               direction:@"asc"
              withOffset:offset
               withCount:count];
    }
    else
    {
        [category sortBy:[[self.orders objectAtIndex:[sorters selectedSegmentIndex]] valueForKey:@"code"]
               direction:@"desc"
              withOffset:offset
               withCount:count];
    }
}

- (IBAction)changeSortDirection:(id)sender {

    [self.loading show:YES];

    if (lastSelectedDirection == 0)
    {
        lastSelectedDirection = 1;
        [sender setImage: [UIImage imageNamed:@"button_up.png"] forState:UIControlStateNormal];
        [category sortBy:[[self.orders objectAtIndex:[sorters selectedSegmentIndex]] valueForKey:@"code"]
               direction:@"desc"
              withOffset:offset
               withCount:count];
    }
    else
    {
        lastSelectedDirection = 0;
        [sender setImage:[UIImage imageNamed:@"button_down.png"] forState:UIControlStateNormal];
        [category sortBy:[[self.orders objectAtIndex:[sorters selectedSegmentIndex]] valueForKey:@"code"]
               direction:@"asc"
              withOffset:offset
               withCount:count];
    }
}
@end
