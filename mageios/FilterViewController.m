//
//  FilterViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 09/06/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "FilterViewController.h"
#import "ProductListViewController.h"
#import "UIColor+CreateMethods.h"

@interface FilterViewController ()

@end

@implementation FilterViewController

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
    
    [self.navigationController setToolbarHidden:NO];
    
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
    return [[self.filter_options valueForKeyPath:@"values.value"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fieldCell" forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *value = (UILabel *)[cell viewWithTag:10];
    value.text = [[[self.filter_options valueForKeyPath:@"values.value"] objectAtIndex:indexPath.row] valueForKey:@"label"];
    
    if ([[[self.filter_options valueForKeyPath:@"values.value"] objectAtIndex:indexPath.row] valueForKey:@"selected"] != nil)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (NSMutableDictionary *value in [self.filter_options valueForKeyPath:@"values.value"]) {
        if ([value valueForKey:@"selected"] != nil)
            [value removeObjectForKey:@"selected"];
    }
    NSMutableDictionary *selected_value = [[self.filter_options valueForKeyPath:@"values.value"] objectAtIndex:indexPath.row];
    [selected_value setValue:@"true" forKey:@"selected"];
    
    for (int row = 0; row < [tableView numberOfRowsInSection:0]; row++) {
        NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:0];
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:cellPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"applyFilterSegue"]) {
        ProductListViewController *destinationController = segue.destinationViewController;
        for (NSDictionary __strong *filter in destinationController.filters) {
            if ([[filter valueForKey:@"code"] isEqualToString:self.filter_code]) {
                filter = self.filter_options;
            }
        }
    }
}

- (IBAction)done:(id)sender {
    [self performSegueWithIdentifier:@"applyFilterSegue" sender:self];
}

- (IBAction)cancel:(id)sender {
    [self performSegueWithIdentifier:@"cancelFilterSegue" sender:self];
}

- (IBAction)clear:(id)sender {
    // clear all filters
    for (NSMutableDictionary __strong *filter in [self.filter_options valueForKeyPath:@"values.value"]) {
        [filter removeObjectForKey:@"selected"];
    }
    [self performSegueWithIdentifier:@"applyFilterSegue" sender:self];
}

@end
