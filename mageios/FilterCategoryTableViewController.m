//
//  FilterCategoryTableViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 05/06/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "FilterCategoryTableViewController.h"
#import "ProductListViewController.h"

@interface FilterCategoryTableViewController ()

@end

@implementation FilterCategoryTableViewController

@synthesize categories;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fieldCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[self.categories objectAtIndex:indexPath.row] valueForKey:@"label"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"returnToProductListWithSelectedCategory" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"returnToProductListWithSelectedCategory"]) {
        // set selected category
        ProductListViewController *destinationController = segue.destinationViewController;
        destinationController.selected_sub_category = [NSString stringWithFormat:@"%d", [self.tableView indexPathForSelectedRow].row];
    }
}


@end
