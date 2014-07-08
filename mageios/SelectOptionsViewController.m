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
    NSMutableArray *isShowingListForSection;
    NSInteger selectedValueIndex;
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
    
    selectedValueIndex = 0;
    installationSelected = NO;
    callAddToCart = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self prepareCells];
    isShowingListForSection = [NSMutableArray array];
    
    for (int i=0; i < [cells count]; i++) {
        [isShowingListForSection insertObject:[NSNumber numberWithInt:0] atIndex:i];
    }
    
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
    // add text input values back to options array
    for (int i=0; i < [self.options count]; i++) {
        NSMutableDictionary *option = [self.options objectAtIndex:i];
        
        if ([option valueForKey:@"value"] == nil) {
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
    if (![[isShowingListForSection objectAtIndex:section] intValue]) {
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
        
        BOOL valueSelected = false;
        
        NSMutableDictionary *option = [self.options objectAtIndex:indexPath.section];
        
        if ([option valueForKey:@"value"] != nil) { // has childs
            
            // if option type is checkbox, it will have selected_value key if it is selected
            // else if option type is select/radio, main option will have selected_value key
            // and its value will be the code of its selected option
            if ([[option valueForKey:@"_type"] isEqualToString:@"checkbox"]) {
                NSArray *childs = [option valueForKey:@"value"];
                if ([childs isKindOfClass:[NSDictionary class]]) {
                    if ([childs valueForKey:@"selected_value"]) valueSelected = true;
                } else {
                    NSDictionary *child = [childs objectAtIndex:indexPath.row-1];
                    if ([child valueForKey:@"selected_value"]) valueSelected = true;
                }
            } else if ([[option valueForKey:@"_type"] isEqualToString:@"select"]) {
                NSArray *childs = [option valueForKey:@"value"];
                if ([childs isKindOfClass:[NSDictionary class]]) { //single option will always be selected
                    if ([option valueForKey:@"selected_value"]) valueSelected = true;
                } else {
                    if ([option valueForKey:@"selected_value"]) {
                        NSDictionary *child = [childs objectAtIndex:indexPath.row-1];
                        if ([[child valueForKey:@"_code"] isEqualToString:[option valueForKey:@"selected_value"]]) valueSelected = true;
                    }
                }
            }
        }
        
        UITableViewCell *cell = [[[cells objectAtIndex:indexPath.section] valueForKey:@"childs"] objectAtIndex:(indexPath.row-1)];
        
        if (valueSelected) {
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
        
        if ([[isShowingListForSection objectAtIndex:indexPath.section] intValue]) {
            selectedValueIndex = [indexPath row];
        }
        if ([[isShowingListForSection objectAtIndex:indexPath.section] intValue] && indexPath.row != 0) {
            installationSelected = !installationSelected;
        }
        
        // show/hide sections
        if (indexPath.row == 0) {
            
            int isShowingList;
            
            if (![[isShowingListForSection objectAtIndex:indexPath.section] intValue])
            isShowingList = 1;
            else
                isShowingList = 0;

            [isShowingListForSection replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithInt:isShowingList]];
        }
        
        // select/unselect options
        if ([[isShowingListForSection objectAtIndex:indexPath.section] intValue] && indexPath.row != 0) {
            
            NSMutableDictionary *option = [self.options objectAtIndex:indexPath.section];

            if ([option valueForKey:@"value"] != nil) { // has childs
                
                // if option type is checkbox, just invert its value
                if ([[option valueForKey:@"_type"] isEqualToString:@"checkbox"]) {
                    NSArray *childs = [option valueForKey:@"value"];
                    NSMutableDictionary *child;
                    if ([childs isKindOfClass:[NSDictionary class]]) {
                        child = (NSMutableDictionary *)childs;
                    } else {
                        child = [childs objectAtIndex:indexPath.row - 1];
                    }
                    
                    if (![child valueForKey:@"selected_value"])
                        [child setObject:[child valueForKey:@"_code"] forKey:@"selected_value"];
                    else
                        [child removeObjectForKey:@"selected_value"];
                }
                
                // if option type is select/radio, select the selected value and unselect all other values
                if ([[option valueForKey:@"_type"] isEqualToString:@"select"]) {
                    NSArray *childs = [option valueForKey:@"value"];

                    if ([childs isKindOfClass:[NSDictionary class]]) {
                        // only one option is available, so this will be always selected
                        NSMutableDictionary *child = (NSMutableDictionary *)childs;
                        [child setObject:[child valueForKey:@"_code"] forKey:@"selected_value"];
                    } else {
                        // iterate all options, set last selected value in main option
                        for (int i=0; i<[childs count]; i++) {
                            NSMutableDictionary *child = [childs objectAtIndex:i];
                            
                            if (i == (indexPath.row-1)) { //this option is selected
                                [option setObject:[child valueForKey:@"_code"] forKey:@"selected_value"];
                            }
                        }
                    }
                }
            }
            
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
        
        NSString *placeholder;
        if ([[option valueForKey:@"_is_required"] isEqualToString:@"1"]) {
            placeholder = @"* ";
            placeholder = [placeholder stringByAppendingString:[option valueForKey:@"_label"]];
        } else {
            placeholder = [option valueForKey:@"_label"];
        }
        
        if ([[option valueForKey:@"_type"] isEqualToString:@"text"]) {
            
            UITextField *input_field = [[UITextField alloc] initWithFrame:CGRectMake(20, 7, 280, 30)];
            input_field.tag = i+1; // start with tag 1 since 0 is already allocated
            input_field.placeholder = placeholder;
            input_field.text = [option valueForKey:@"value"];
            input_field.delegate = self;
            
            [cell.contentView addSubview:input_field];
            
        } else if ([[option valueForKey:@"_type"] isEqualToString:@"select"]) {

            [[cell textLabel] setText:placeholder];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        } else if ([[option valueForKey:@"_type"] isEqualToString:@"checkbox"]) {
            //NSLog(@"%@", option);
            [[cell textLabel] setText:placeholder];
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
                    NSString *label = [[childs objectAtIndex:j] valueForKey:@"_label"];
                    if ([[childs objectAtIndex:j] valueForKey:@"_price"] != nil) {
                        label = [label stringByAppendingString:@" +"];
                        label = [label stringByAppendingString:[[childs objectAtIndex:j] valueForKey:@"_formated_price"]];
                    }
                    [[cell textLabel] setText:label];
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
