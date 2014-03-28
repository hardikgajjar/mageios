//
//  BillingViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 12/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "BillingViewController.h"
#import "Service.h"
#import "Customer.h"
#import "Quote.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"
#import "Core.h"


@interface BillingViewController ()

@end

@implementation BillingViewController {
    Service *service;
    Customer *customer;
    NSArray *fields;
    NSMutableArray *cells;
}

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
    
    service = [Service getInstance];
    
    if (service.initialized) {
        
        [self updateCommonStyles];
        
        customer = [Customer getInstance];
        
        if (customer.isLoggedIn) {
            [self showBillingOptions];
        } else {
            [self loadBillingForm];
        }
        
    }
}

// for a customer, show saved addess(if any) and other options like add new address, select from addressbook
- (void)showBillingOptions
{
    [self.tableView reloadData];
}

- (void)loadBillingForm
{
    // show loading
    self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
    
    if (customer.isLoggedIn) {
        if ([self.data valueForKey:@"item"] != nil) {
            return 3;
        } else {
            return 2;
        }
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (customer.isLoggedIn) {
        return 1;
    }
    
    return [fields count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (customer.isLoggedIn) {
        
        if ([self.data valueForKey:@"item"] != nil) {
            switch (indexPath.section) {
                case 0: // saved address
                {
                    static NSString *CellIdentifier = @"addressCell";
                    
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    
                    UILabel *name = (UILabel *)[cell viewWithTag:10];
                    name.text = [NSString stringWithFormat:@"%@ %@",
                                 [self.data valueForKeyPath:@"item.firstname"],
                                 [self.data valueForKeyPath:@"item.lastname"]
                                 ];
                    
                    UILabel *company = (UILabel *)[cell viewWithTag:20];
                    company.text = [self.data valueForKeyPath:@"item.company"];
                    
                    UILabel *street = (UILabel *)[cell viewWithTag:30];
                    street.text = [NSString stringWithFormat:@"%@ %@",
                                   [self.data valueForKeyPath:@"item.street1"],
                                   [self.data valueForKeyPath:@"item.street2"]
                                   ];
                    
                    UILabel *cityStateZip = (UILabel *)[cell viewWithTag:40];
                    cityStateZip.text = [NSString stringWithFormat:@"%@ %@ %@",
                                   [self.data valueForKeyPath:@"item.city"],
                                   [self.data valueForKeyPath:@"item.region"],
                                   [self.data valueForKeyPath:@"item.postcode"]
                                   ];
                    
                    UILabel *country = (UILabel *)[cell viewWithTag:50];
                    country.text = [self.data valueForKeyPath:@"item.country"];
                    
                    return cell;
                    break;
                }
                case 1: // add new address
                {
                    static NSString *CellIdentifier = @"fieldCell";
                    
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Add New Address";
                    
                    return cell;
                    break;
                }
                case 2: // select from address book
                {
                    static NSString *CellIdentifier = @"fieldCell";
                    
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Select from Address Book";
                    
                    return cell;
                    break;
                }
                default:
                    break;
            }
        } else {
            switch (indexPath.section) {
                case 0: // add new address
                {
                    static NSString *CellIdentifier = @"fieldCell";
                    
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Add New Address";
                    return cell;
                    break;
                }
                case 1: // select from address book
                {
                    static NSString *CellIdentifier = @"fieldCell";
                    
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    cell.textLabel.text = @"Select from Address Book";
                    return cell;
                    break;
                }
                default:
                    break;
            }
        }
    }
    
    return [cells objectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (customer.isLoggedIn) {
        
        if ([self.data valueForKey:@"item"] != nil) {
            switch (indexPath.section) {
                case 0: // saved address
                {
                    // go to payment step
                    
                    break;
                }
                case 1: // add new address
                {
                    // go to add new address screen
                    [self performSegueWithIdentifier:@"addNewAddressSegue" sender:self];
                    
                    break;
                }
                case 2: // select from address book
                {
                    // go to address book screen
                    
                    break;
                }
                default:
                    break;
            }
        } else {
            switch (indexPath.section) {
                case 0: // add new address
                {
                    break;
                }
                case 1: // select from address book
                {
                    break;
                }
                default:
                    break;
            }
        }
    } else {
        // enter billing address fiels (Guest)
        NSDictionary *field = [fields objectAtIndex:indexPath.row];
        //UITableViewController *selectFromList = [self.storyboard instantiateViewControllerWithIdentifier:@"listSelector"];
        
        //[self presentViewController:selectFromList animated:YES completion:nil];
    }

}

- (void)prepareCells
{
    cells = [NSMutableArray array];
    
    for (NSDictionary *field in fields) {
        
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        if ([[field valueForKey:@"_type"] isEqualToString:@"text"]) {
            
                UITextField *input_field = [[UITextField alloc] initWithFrame:CGRectMake(20, 7, 280, 30)];
                input_field.placeholder = [field valueForKey:@"_label"];
                
                [cell.contentView addSubview:input_field];
                
            
        } else if ([[field valueForKey:@"_type"] isEqualToString:@"select"]) {
            
                [[cell textLabel] setText:[field valueForKey:@"_label"]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if ([[field valueForKey:@"_type"] isEqualToString:@"checkbox"]) {
            
                [[cell textLabel] setText:[field valueForKey:@"_label"]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [cells addObject:cell];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (customer.isLoggedIn && [self.data valueForKey:@"item"] != nil) {
        if (indexPath.section == 0) {
            return 89;
        }
    }
    return 44;
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
