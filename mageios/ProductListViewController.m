//
//  ProductListViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 21/02/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "ProductListViewController.h"
#import "ProductViewController.h"
#import "FilterCategoryTableViewController.h"
#import "FilterViewController.h"
#import "Service.h"
#import "XCategory.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"

@interface ProductListViewController ()

@property (strong, nonatomic) UIPickerView *pickerView;

@end

@implementation ProductListViewController {
    Service *service;
    XCategory *category;

    int lastSelectedDirection; //0=asc, 1=desc
    int offset;
    int count;
    UIView  *pickerParentView;
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
        
        if ([[category valueForKeyPath:@"sub_categories"] isKindOfClass:[NSDictionary class]]) {
            self.sub_categories = [NSArray arrayWithObjects:[category valueForKeyPath:@"sub_categories"], nil];
        } else {
            self.sub_categories = [category valueForKeyPath:@"sub_categories"];
        }

        [self updateProducts];
        
    } else if ([[notification name] isEqualToString:@"filtersLoadedNotification"]) {
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

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } else if ([[notification name] isEqualToString:@"moreProductsLoadedNotification"]) {
        
        if ([[category valueForKeyPath:@"products"] isKindOfClass:[NSDictionary class]]) {
            self.products = [NSArray arrayWithObjects:[category valueForKeyPath:@"products"], nil];
        } else {
            self.products = [category valueForKeyPath:@"products"];
        }
        
        [self updateProducts];
        
    } else if ([[notification name] isEqualToString:@"selfViewDidAppear"]) {
        
        NSDictionary *cat = [self.sub_categories objectAtIndex:[self.selected_sub_category intValue]];
        [self performSegueWithIdentifier:@"productListLoopBackSegue" sender:cat];
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
    
    // Add filters load observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"filtersLoadedNotification"
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
    self.loading = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] windows] objectAtIndex:0] animated:YES];
    self.loading.labelText = @"Loading";
    
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
    
    // set picker for sort by
    self.pickerView = [[UIPickerView alloc] initWithFrame:(CGRect){{0, 0}, 320, 480}];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.backgroundColor = [UIColor colorWithHex:@"#CCCCCC" alpha:0.7];
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(toggleSortByPicker:)];
    barButtonCancel.tintColor=[UIColor blackColor];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(sortBy:)];
    toolBar.items = [[NSArray alloc] initWithObjects:barButtonCancel,flex,barButtonDone,nil];
    barButtonDone.tintColor=[UIColor blackColor];
    pickerParentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 260)];
    pickerParentView.hidden = YES;
    [pickerParentView addSubview:self.pickerView];
    [pickerParentView addSubview:toolBar];
    [self.view addSubview:pickerParentView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self addObservers];
    
    // fire event
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"selfViewDidAppear"
     object:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // fix the picker
    CGRect newFrame = pickerParentView.frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.tableView.contentOffset.y+(self.tableView.frame.size.height-224);;
    pickerParentView.frame = newFrame;
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
        if (self.orders != NULL) {
            
            UILabel *sortByLabel = (UILabel *)[cell viewWithTag:20];
            UILabel *currentShortBy = (UILabel *)[cell viewWithTag:30];
            
            sortByLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSortByPicker:)];
            [sortByLabel addGestureRecognizer:tapGesture];
            
            
            // show default sort by
            NSDictionary *defaultSort;
            for (int i=0; i < [self.orders count]; i++) {
                NSDictionary *item = [self.orders objectAtIndex:i];
                if ([[item valueForKey:@"_isDefault"] isEqualToString:@"1"]) {
                    defaultSort = item;
                }
            }
            
            if ([defaultSort valueForKey:@"code"] != [[self.orders objectAtIndex:[self.pickerView selectedRowInComponent:0]] valueForKey:@"code"]) {
                currentShortBy.text = [[self.orders objectAtIndex:[self.pickerView selectedRowInComponent:0]] valueForKey:@"name"];
            } else {
                currentShortBy.text = [defaultSort valueForKey:@"name"];
            }
            
            // set all sort by options in picker
            [self.pickerView reloadAllComponents];
        }
        
        // set filters
        UIView *filters_icon = (UIView *)[cell viewWithTag:110];
        UIView *filters_separator = (UIView *)[cell viewWithTag:120];
        
        if (self.filters != NULL) {
            UIScrollView *all_filters = (UIScrollView *)[cell viewWithTag:100];
            int i = 0;
            for (NSDictionary *filter in self.filters) {
                NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14]};
                CGSize size = [[filter valueForKey:@"name"] sizeWithAttributes:attributes];
                
                UILabel *filter_name = [[UILabel alloc] initWithFrame:CGRectMake(i, 8, size.width, 15)];
                filter_name.text = [filter valueForKey:@"name"];
                [filter_name setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                                         initWithTarget:self action:@selector(openFilterView:)];
                [filter_name addGestureRecognizer:tapRecognizer];
                filter_name.userInteractionEnabled = YES;
                
                [all_filters addSubview:filter_name];
                
                i += size.width + 15;
            }
            all_filters.contentSize = CGSizeMake(i - 10, all_filters.frame.size.height);
            
            filters_icon.hidden = NO;
            filters_separator.hidden = NO;
        } else {
            filters_icon.hidden = YES;
            filters_separator.hidden = YES;
        }
        
        // set sub categories
        UIView *sub_categories_separator = (UIView *)[cell viewWithTag:130];
        UIButton *subCatBtn = (UIButton *)[cell viewWithTag:40];
        
        if (self.sub_categories == NULL) {
            subCatBtn.hidden = YES;
            sub_categories_separator.hidden = YES;
        } else {
            subCatBtn.hidden = NO;
            sub_categories_separator.hidden = NO;
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


- (IBAction)openFilterView:(id)sender
{
    [self performSegueWithIdentifier:@"openFilterViewSegue" sender:sender];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"productDetailSegue"]) {
        int selectedRow = [[self.tableView indexPathForSelectedRow] row];
        
        // set product information
        ProductViewController *product_controller = [segue destinationViewController];
        product_controller.title = [[self.products objectAtIndex:selectedRow] valueForKey:@"name"];
        product_controller.current_product = [self.products objectAtIndex:selectedRow];
    } else if ([segue.identifier isEqualToString:@"listSubCategoriesSegue"]) {
        // set sub-categories
        UINavigationController *navController = segue.destinationViewController;
        FilterCategoryTableViewController *sub_categories_controller = [navController.childViewControllers objectAtIndex:0];
        sub_categories_controller.categories = self.sub_categories;
    } else if ([segue.identifier isEqualToString:@"productListLoopBackSegue"]) {
        ProductListViewController *nextController = segue.destinationViewController;
        nextController.title = [sender valueForKey:@"label"];
        nextController.current_category = sender;
    } else if ([segue.identifier isEqualToString:@"openFilterViewSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        FilterViewController *nextController = [navController.childViewControllers objectAtIndex:0];
        NSString *title = @"Filter By - ";
        UITapGestureRecognizer *s = sender;
        UILabel *l = (UILabel *)s.view;
        nextController.title = [title stringByAppendingString: l.text];
        
        for (NSDictionary *filter in self.filters) {
            if ([[filter valueForKey:@"name"] isEqualToString:l.text]) {
                nextController.filter_options = [filter mutableCopy];
                nextController.filter_code = [filter valueForKey:@"code"];
            }
        }
    }
}

- (IBAction)FilterBySubCategorySelected:(UIStoryboardSegue *)unwindSegue
{
    // goto selected sub category
    // Add view loaded observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"selfViewDidAppear"
                                               object:nil];
    
    
}



#pragma mark - segment control
- (void)sortBy: (id) sender
{
    [self.loading show:YES];

    if (lastSelectedDirection == 0)
    {
        [category filterBy:self.filters
                    sortBy:[[self.orders objectAtIndex:[self.pickerView selectedRowInComponent:0]] valueForKey:@"code"]
                 direction:@"asc"
                withOffset:offset
                 withCount:count];
    }
    else
    {
        [category filterBy:self.filters
                    sortBy:[[self.orders objectAtIndex:[self.pickerView selectedRowInComponent:0]] valueForKey:@"code"]
                 direction:@"desc"
                withOffset:offset
                 withCount:count];
    }
    
    [self toggleSortByPicker:self];
}

- (IBAction)changeSortDirection:(id)sender {

    [self.loading show:YES];
    
    if (lastSelectedDirection == 0)
    {
        lastSelectedDirection = 1;
        [sender setImage: [UIImage imageNamed:@"button_up.png"] forState:UIControlStateNormal];
        [category filterBy:self.filters
                    sortBy:[[self.orders objectAtIndex:[self.pickerView selectedRowInComponent:0]] valueForKey:@"code"]
                 direction:@"desc"
                withOffset:offset
                 withCount:count];
    }
    else
    {
        lastSelectedDirection = 0;
        [sender setImage:[UIImage imageNamed:@"button_down.png"] forState:UIControlStateNormal];
        [category filterBy:self.filters
                    sortBy:[[self.orders objectAtIndex:[self.pickerView selectedRowInComponent:0]] valueForKey:@"code"]
                 direction:@"asc"
                withOffset:offset
                 withCount:count];
    }
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (self.orders != NULL)
        return self.orders.count;
    else
        return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (self.orders != NULL)
        return [[self.orders objectAtIndex:row] valueForKey:@"name"];
    else
        return nil;
}

- (IBAction)toggleSortByPicker:(id)sender
{
    if (pickerParentView.hidden)
        pickerParentView.hidden = NO;
    else
        pickerParentView.hidden = YES;
}

# pragma mark - filter

- (IBAction)applyFilter:(UIStoryboardSegue *)unwindSegue
{
    [self.loading show:YES];

    offset = 0;
    count = 10;

    if (lastSelectedDirection == 0)
    {
        [category filterBy:self.filters
                    sortBy:[[self.orders objectAtIndex:[self.pickerView selectedRowInComponent:0]] valueForKey:@"code"]
                 direction:@"asc"
                withOffset:offset
                 withCount:count];
    }
    else
    {
        [category filterBy:self.filters
                    sortBy:[[self.orders objectAtIndex:[self.pickerView selectedRowInComponent:0]] valueForKey:@"code"]
                 direction:@"desc"
                withOffset:offset
                 withCount:count];
    }
    
}

- (IBAction)cancelFilter:(UIStoryboardSegue *)unwindSegue
{
    
}

@end
