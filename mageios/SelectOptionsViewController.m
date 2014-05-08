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
    BOOL isShowingList;
    int selectedValueIndex;
    BOOL installationSelected;
    BOOL callAddToCart;
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
    
    
    isShowingList = NO;
    selectedValueIndex = 0;
    installationSelected = NO;
    callAddToCart = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self prepareCells];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveEnteredValues];

    // pass inputs back to delegate controller
    [self.delegate addItemViewController:self didFinishEnteringItem:self.options withAddToCart:callAddToCart];
}

- (void)saveEnteredValues
{
    // add input values back to options array
    for (int i=0; i < [self.options count]; i++) {
        NSMutableDictionary *option = [self.options objectAtIndex:i];
        
        if ([option valueForKey:@"value"] != nil) { // has childs
            
            // iterate childs and set their selected values
            NSArray *childs = [option valueForKey:@"value"];
            
            if ([childs isKindOfClass:[NSDictionary class]]) {
                
                NSMutableDictionary *child = (NSMutableDictionary *)childs;
                
                if (installationSelected) {
                    [child setObject:[child valueForKey:@"_code"] forKey:@"selected_value"];
                }
                
            } else {
                
                for (NSMutableDictionary *child in childs) {
                    
                    if (installationSelected) {
                        [child setObject:[child valueForKey:@"_code"] forKey:@"selected_value"];
                    }
                    
                }
                
            }
            
        } else {
            [option setObject:[(UITextView *)[self.view viewWithTag:i+1] text] forKey:@"selected_value"];
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
    return [cells count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (!isShowingList) {
        return 1;
    }

    int count = 1;
    
    if ([[self.options objectAtIndex:section] valueForKey:@"value"] != nil) {
        NSArray *child = [[self.options objectAtIndex:section] valueForKey:@"value"];
        
        if ([child isKindOfClass:[NSDictionary class]]) {
            count++;
        } else {
            for (int j=0; j < [child count]; j++) {
                count++;
            }
        }
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { //first row of any section will be parent
        return [[cells objectAtIndex:indexPath.section] valueForKey:@"value"];
    }
    
    // else childs
    
    if ([[cells objectAtIndex:indexPath.section] valueForKey:@"has_items"] != nil) {
        
        UITableViewCell *cell = [[[cells objectAtIndex:indexPath.section] valueForKey:@"childs"] objectAtIndex:(indexPath.row-1)];
        
        if (installationSelected) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[cells objectAtIndex:indexPath.section] valueForKey:@"has_items"] != nil) {
        
        if (isShowingList) {
            selectedValueIndex = [indexPath row];
        }
        if (isShowingList && indexPath.row != 0) {
            installationSelected = !installationSelected;
        }
        if (indexPath.row == 0) {
            isShowingList = !isShowingList;
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        
    } else {
        return;
    }
}


- (void)prepareCells
{
    cells = [NSMutableArray array];
    
    for (int i=0; i < [self.options count]; i++) {
        
        NSMutableDictionary *cellDictionary = [NSMutableDictionary dictionary];
        
        NSDictionary *option = [self.options objectAtIndex:i];
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        if ([[option valueForKey:@"_type"] isEqualToString:@"text"]) {
            
            UITextField *input_field = [[UITextField alloc] initWithFrame:CGRectMake(20, 7, 280, 30)];
            input_field.tag = i+1; // start with tag 1 since 0 is already allocated
            input_field.placeholder = [option valueForKey:@"_label"];
            input_field.text = [option valueForKey:@"value"];
            input_field.delegate = self;
            
            [cell.contentView addSubview:input_field];
            
        } else if ([[option valueForKey:@"_type"] isEqualToString:@"select"]) {

            [[cell textLabel] setText:[option valueForKey:@"_label"]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        } else if ([[option valueForKey:@"_type"] isEqualToString:@"checkbox"]) {
            //NSLog(@"%@", option);
            [[cell textLabel] setText:[option valueForKey:@"_label"]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
        [cellDictionary setValue:cell forKey:@"value"];
        
        
        if ([option valueForKey:@"value"] != nil) {
            
            [cellDictionary setValue:@"1" forKey:@"has_items"];
            
            NSArray *childs = [option valueForKey:@"value"];
            NSMutableArray *child_cells = [NSMutableArray array];
            
            if ([childs isKindOfClass:[NSDictionary class]]) {
                
                UITableViewCell *cell = [[UITableViewCell alloc] init];
                NSString *label = [childs valueForKey:@"_label"];
                if ([childs valueForKey:@"_price"] != nil) {
                    label = [label stringByAppendingString:@" +"];
                    label = [label stringByAppendingString:[childs valueForKey:@"_formated_price"]];
                }
                [[cell textLabel] setText:label];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
                [child_cells addObject:cell];
                
            } else {
                
                for (int j=0; j < [childs count]; j++) {
                    
                    UITableViewCell *cell = [[UITableViewCell alloc] init];
                    
                    [[cell textLabel] setText:[[childs objectAtIndex:j] valueForKey:@"_label"]];
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    
                    [child_cells addObject:cell];
                }
            }
            
            [cellDictionary setValue:child_cells forKey:@"childs"];
        }
        
        [cells addObject:cellDictionary];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)addToCart:(id)sender {
    callAddToCart = YES;
    [self.navigationController popViewControllerAnimated:TRUE];
    
}
@end
