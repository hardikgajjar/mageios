//
//  NewAddressViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 22/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "NewAddressViewController.h"
#import "SelectFromListViewController.h"
#import "PaymentViewController.h"
#import "Service.h"
#import "Customer.h"
#import "Quote.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"
#import "Core.h"

@interface NewAddressViewController ()

@end

@implementation NewAddressViewController {
    Service *service;
    Customer *customer;
    NSMutableArray *fields;
    NSMutableArray *cells;
    NSMutableDictionary *tags;
    
    int regionCellTag, regionIdCellTag;
    NSArray *regions;
}

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
    
    if ([[notification name] isEqualToString:@"billingAddressSavedNotification"]) {
        // goto payment (assume that we only have virtual products so no need of shipping address)
        [self performSegueWithIdentifier:@"paymentSegue" sender:self];
    }
}

- (void)addObservers
{
    // Add request completed observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"requestCompletedNotification"
                                               object:nil];
    // Add billing address saved observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"billingAddressSavedNotification"
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addObservers];
    
    service = [Service getInstance];
    
    if (service.initialized) {
        
        [self updateCommonStyles];
        
        [self loadBillingForm];
        
    }
}

- (void)loadBillingForm
{
    // show loading
    self.loading = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] windows] objectAtIndex:0] animated:YES];
    self.loading.labelText = @"Loading";
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/checkout/newbillingaddressform"];
    
    NSString *billing_form_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:billing_form_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    //[request setHTTPBody:[self encodeDictionary:data]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *billing_form = [session dataTaskWithRequest:request
                                                    completionHandler:
                                          ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                              
                                              NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                              //NSLog(@"%@", res);
                                              fields = [res valueForKey:@"field"];
                                              
                                              // remove region_id by default
                                              /*int i = 0;
                                              for (NSDictionary *field in fields) {
                                                  if ([[field valueForKey:@"_id"] isEqualToString:@"region_id"]) {
                                                      break;
                                                  }
                                                  i++;
                                              }
                                              [fields removeObjectAtIndex:i];*/
                                              
                                              [self showFields];
                                              
                                          }];
    
    [billing_form resume];
}

- (void)showFields
{
    // perform ui updates from main thread so that they updates correctly
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(showFields) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self.loading hide:YES];
    [self prepareCells];
    [self.tableView reloadData];
    
    return;
}

- (void)prepareCells
{
    cells = [NSMutableArray array];
    tags = [NSMutableDictionary dictionary];
    int i = 0;
    for (NSDictionary *field in fields) {
        
        // set tags
        [tags setValue:[NSString stringWithFormat:@"%d", i] forKey:[field valueForKey:@"_id"]];
        
        if ([[field valueForKey:@"_id"] isEqualToString:@"region"]) {
            regionCellTag = i;
        } else if ([[field valueForKey:@"_id"] isEqualToString:@"region_id"]) {
            regionIdCellTag = i;
            
            // skip region_id by default
            i++;
            continue;
        }
        
        
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        NSString *placeholder;
        if ([[field valueForKey:@"_required"] isEqualToString:@"true"]) {
            placeholder = @"* ";
            placeholder = [placeholder stringByAppendingString:[field valueForKey:@"_label"]];
        } else {
            placeholder = [field valueForKey:@"_label"];
        }
        
        if ([[field valueForKey:@"_type"] isEqualToString:@"text"]) {
            
            UITextField *input_field = [[UITextField alloc] initWithFrame:CGRectMake(20, 7, 280, 30)];
            input_field.placeholder = placeholder;
            input_field.tag = i;
            input_field.delegate = self;
            
            [cell.contentView addSubview:input_field];
            
        } else if ([[field valueForKey:@"_type"] isEqualToString:@"select"]) {

            [[cell textLabel] setText:placeholder];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        } else if ([[field valueForKey:@"_type"] isEqualToString:@"checkbox"]) {
            UISwitch *checkbox = [[UISwitch alloc] initWithFrame:CGRectMake(251, 6, 51, 31)];
            checkbox.tag = i;
            [checkbox addTarget:self action:@selector(flip:) forControlEvents:UIControlEventValueChanged];
            checkbox.on = YES;
            [cell.contentView addSubview:checkbox];
            
            [[cell textLabel] setText:placeholder];
            
            // set default value to yes in fields array
            [[fields objectAtIndex:i] setValue:@"1" forKey:@"selected_value"];
        }
        
        [cells addObject:cell];
        
        i++;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *field = [fields objectAtIndex:indexPath.row];
    
    if ([[field valueForKey:@"_type"] isEqualToString:@"select"] ||
        [[field valueForKey:@"_id"] isEqualToString:@"region"]) {

        if ([[field valueForKey:@"_id"] isEqualToString:@"country_id"]) {

            SelectFromListViewController *selectFromList = [self.storyboard instantiateViewControllerWithIdentifier:@"listSelector"];
            selectFromList.options = [field valueForKeyPath:@"values.item"];
            selectFromList.delegate = self;
            [self presentViewController:selectFromList animated:YES completion:nil];
            
        } else {
            if (regions != nil) {
                
                SelectFromListViewController *selectFromList = [self.storyboard instantiateViewControllerWithIdentifier:@"listSelector"];
                selectFromList.options = regions;
                selectFromList.delegate = self;
                [self presentViewController:selectFromList animated:YES completion:nil];
                
            }
        }
    }
}


- (void)updateCommonStyles
{
    // set backgroundcolor
    [self.tableView setBackgroundColor:[UIColor colorWithHex:[service.config_data valueForKeyPath:@"body.backgroundColor"] alpha:1.0]];
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
    return [fields count] - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [cells objectAtIndex:indexPath.row];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"paymentSegue"]) {
        PaymentViewController *nextController = segue.destinationViewController;
        nextController.title = @"Payment Information";
    }
}


#pragma mark - SelectFromListViewDelegate methods

- (void)selectItemViewController:(SelectFromListViewController *)controller didFinishSelectingItem:(NSDictionary *)value
{
    if ([value valueForKey:@"_relation"] != nil) { // country is selected
        
        // set this value in cell label
        [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]].textLabel.text = [value valueForKey:@"label"];
        
        // update region cell based on selected country
        if ([[value valueForKey:@"_relation"] isEqualToString:@"region"]) {
            
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            UITextField *input_field = [[UITextField alloc] initWithFrame:CGRectMake(20, 7, 280, 30)];
            
            NSString *placeholder;
            if ([[[fields objectAtIndex:regionCellTag] valueForKey:@"_required"] isEqualToString:@"true"]) {
                placeholder = @"* ";
                placeholder = [placeholder stringByAppendingString:[[fields objectAtIndex:regionCellTag] valueForKey:@"_label"]];
            } else {
                placeholder = [[fields objectAtIndex:regionCellTag] valueForKey:@"_label"];
            }
            
            input_field.placeholder = placeholder;
            input_field.tag = regionCellTag;
            input_field.delegate = self;
            
            [cell.contentView addSubview:input_field];
            [cells setObject:cell atIndexedSubscript:regionCellTag];
            
            regions = nil;
        } else {
            
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            
            NSString *label;
            if ([[[fields objectAtIndex:regionIdCellTag] valueForKey:@"_required"] isEqualToString:@"true"]) {
                label = @"* ";
                label = [label stringByAppendingString:[[fields objectAtIndex:regionIdCellTag] valueForKey:@"_label"]];
            } else {
                label = [[fields objectAtIndex:regionIdCellTag] valueForKey:@"_label"];
            }
            
            [[cell textLabel] setText:label];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            [cells setObject:cell atIndexedSubscript:regionCellTag];
            
            regions = [value valueForKeyPath:@"regions.region_item"];
        }
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:regionCellTag inSection:0];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
        // set this value in fields array
        int country_id_index = [[tags valueForKey:@"country_id"] intValue];
        [[fields objectAtIndex:country_id_index] setValue:[value valueForKey:@"value"] forKey:@"selected_value"];
        
        // reset region
        [[fields objectAtIndex:regionCellTag] removeObjectForKey:@"selected_value"];
        [[fields objectAtIndex:regionIdCellTag] removeObjectForKey:@"selected_value"];
        
    } else { // region is selected
        
        // set this value in cell label
        [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]].textLabel.text = [value valueForKey:@"label"];
        
        // set this value in fields array
        [[fields objectAtIndex:regionCellTag] setValue:[value valueForKey:@"label"] forKey:@"selected_value"];
        [[fields objectAtIndex:regionIdCellTag] setValue:[value valueForKey:@"value"] forKey:@"selected_value"];
        
    }
}

# pragma marks - textfield methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    int i = textField.tag;
    [[fields objectAtIndex:i] setValue:textField.text forKey:@"selected_value"];
//    for (NSDictionary *field in fields) {
//        NSLog(@"%@",[field valueForKey:@"_id"]);
//        NSLog(@"%@", [field valueForKey:@"selected_value"]);
//    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

# pragma mark - switch methods

- (IBAction)flip:(id)sender {
    UISwitch *checkbox = (UISwitch *) sender;
    int i = checkbox.tag;
    [[fields objectAtIndex:i] setValue:checkbox.on ? @"1" : @"0" forKey:@"selected_value"];
}

- (IBAction)goNext:(id)sender {
    [self.view endEditing:YES];
    
    BOOL is_valid = true;
    
    if (fields != nil) {
        
        // check if all required options are having values?
        for (NSDictionary *field in fields) {
            
            if ([[field valueForKey:@"_required"] isEqualToString:@"true"]) {
                
                if ([field valueForKey:@"selected_value"] == nil ||
                    [[field valueForKey:@"selected_value"] isEqualToString:@""]) {
                    
                    if ([[field valueForKey:@"_id"] isEqualToString:@"region_id"]) {
                        if (regions != nil) {
                            is_valid = false;
                            break;
                        }
                    } else {
                        is_valid = false;
                        break;
                    }
                } else if ([[field valueForKey:@"_id"] isEqualToString:@"region_id"] &&
                           [[field valueForKey:@"selected_value"] isEqualToString:@"0"] &&
                           regions != nil) {
                    is_valid = false;
                    break;
                }
            }
        }
        
    }
    
    if (is_valid) {
        
        // save this address and goto payment
        
        customer = [Customer getInstance];
        
        if (customer) {
            
            [self.loading show:YES];
            
            // prepare post data
            NSMutableDictionary *post_data = [NSMutableDictionary dictionary];
            for (NSArray *field in fields) {
                
                // skip region_id if selected country has no any regions
                if ([[field valueForKey:@"_id"] isEqualToString:@"region_id"] && regions == nil) continue;
                
                [post_data setValue:[field valueForKey:@"selected_value"] forKey:[field valueForKey:@"_name"]];
            }
            
            [customer saveBillingAddress:post_data];
            
        }
    } else {
        // show alert
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"An Error Occured"
                              message:@"Please insert all required field(s)."
                              delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil];
        
        [alert show];
    }
}

@end
