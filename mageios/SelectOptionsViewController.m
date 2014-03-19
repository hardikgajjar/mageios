//
//  SelectOptionsViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 14/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "SelectOptionsViewController.h"

@interface SelectOptionsViewController ()

@end

@implementation SelectOptionsViewController {
    NSMutableArray *cells;
}

@synthesize options,delegate;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self prepareCells];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // add input values back to options array
    for (int i=0; i < [self.options count]; i++) {
        NSMutableDictionary *option = [self.options objectAtIndex:i];
        [option setObject:[(UITextView *)[self.view viewWithTag:i+1] text] forKey:@"value"];
    }

    // pass inputs back to delegate controller

    [self.delegate addItemViewController:self didFinishEnteringItem:self.options];
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
    return [self.options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [cells objectAtIndex:indexPath.row];
}


- (void)prepareCells
{
    cells = [NSMutableArray array];
    
    for (int i=0; i < [self.options count]; i++) {
        
        NSDictionary *option = [self.options objectAtIndex:i];
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        if ([[option valueForKey:@"_type"] isEqualToString:@"text"]) {
            
            UITextField *input_field = [[UITextField alloc] initWithFrame:CGRectMake(20, 7, 280, 30)];
            input_field.tag = i+1; // start with tag 1 since 0 is already allocated
            input_field.placeholder = [option valueForKey:@"_label"];
            input_field.text = [option valueForKey:@"value"];
            
            [cell.contentView addSubview:input_field];
            
        } else if ([[option valueForKey:@"_type"] isEqualToString:@"select"]) {

            [[cell textLabel] setText:[option valueForKey:@"_label"]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        } else if ([[option valueForKey:@"_type"] isEqualToString:@"checkbox"]) {
            
            [[cell textLabel] setText:[option valueForKey:@"_label"]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        [cells addObject:cell];
    }
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
