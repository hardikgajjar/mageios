//
//  BillingViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 12/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "BillingViewController.h"
#import "AddressbookViewController.h"
#import "Service.h"
#import "Customer.h"
#import "Quote.h"
#import "Checkout.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"
#import "Core.h"


@interface BillingViewController ()

@end

@implementation BillingViewController {
    Service *service;
    Customer *customer;
    Checkout *checkout;
    NSArray *fields;
    NSMutableArray *cells;
    NSDictionary *selected_address;
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
        [self performSegueWithIdentifier:@"paymentFromBillingSegue" sender:self];
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
    // hide continue button if there's no default address
    if (customer.isLoggedIn && [self.data valueForKey:@"item"] != nil) {
        self.continueBtn.enabled = true;
    } else {
        self.continueBtn.enabled = false;
    }
    

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
                    if ([[self.data valueForKey:@"item"] isKindOfClass:[NSDictionary class]]) { // if only one address is there
                        selected_address = [self.data valueForKey:@"item"];
                    } else { // there are multiple addresses, we need default address
                        
                        for (NSDictionary *address in [self.data valueForKey:@"item"]) {
                            if ([[address valueForKey:@"_selected"] isEqualToString:@"1"]) {
                                selected_address = address;
                                break;
                            }
                        }
                        
                    }
                    
                    static NSString *CellIdentifier = @"addressCell";
                    
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    
                    UILabel *name = (UILabel *)[cell viewWithTag:10];
                    name.text = [NSString stringWithFormat:@"%@ %@",
                                 [selected_address valueForKeyPath:@"firstname"],
                                 [selected_address valueForKeyPath:@"lastname"]
                                 ];
                    
                    UILabel *company = (UILabel *)[cell viewWithTag:20];
                    company.text = [selected_address valueForKeyPath:@"company"];
                    
                    UILabel *street = (UILabel *)[cell viewWithTag:30];
                    street.text = [NSString stringWithFormat:@"%@ %@",
                                   [selected_address valueForKeyPath:@"street1"],
                                   [selected_address valueForKeyPath:@"street2"]
                                   ];
                    
                    UILabel *cityStateZip = (UILabel *)[cell viewWithTag:40];
                    cityStateZip.text = [NSString stringWithFormat:@"%@ %@ %@",
                                   [selected_address valueForKeyPath:@"city"],
                                   [selected_address valueForKeyPath:@"region"],
                                   [selected_address valueForKeyPath:@"postcode"]
                                   ];
                    
                    UILabel *country = (UILabel *)[cell viewWithTag:50];
                    country.text = [selected_address valueForKeyPath:@"country"];
                    
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
                    [self saveDefaultAddress:self];
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
                    [self performSegueWithIdentifier:@"addressBookSegue" sender:self];
                    break;
                }
                default:
                    break;
            }
        } else {
            switch (indexPath.section) {
                case 0: // add new address
                {
                    // go to add new address screen
                    [self performSegueWithIdentifier:@"addNewAddressSegue" sender:self];
                    break;
                }
                case 1: // select from address book
                {
                    [self performSegueWithIdentifier:@"addressBookSegue" sender:self];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addressBookSegue"]) {
        AddressbookViewController *nextController = segue.destinationViewController;
        
        if ([[self.data valueForKey:@"item"] isKindOfClass:[NSDictionary class]]) {
            nextController.data = [NSArray arrayWithObjects:[self.data valueForKey:@"item"], nil];
        } else {
            nextController.data = [self.data valueForKey:@"item"];
        }
    }
}


- (IBAction)saveDefaultAddress:(id)sender {
    // save default billing address in checkout
    customer = [Customer getInstance];
    
    if (customer) {
        // show loading
        self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.loading.labelText = @"Loading";
        
        // prepare post data
        NSMutableDictionary *post_data = [NSMutableDictionary dictionary];
        [post_data setValue:[selected_address valueForKey:@"entity_id"] forKey:@"billing_address_id"];
        [post_data setValue:@"0" forKey:@"billing[use_for_shipping]"];
        
        [customer saveBillingAddress:post_data];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
