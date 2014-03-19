//
//  BillingViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 12/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "BillingViewController.h"
#import "Service.h"
#import "Quote.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"
#import "Core.h"


@interface BillingViewController ()

@end

@implementation BillingViewController {
    Service *service;
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
    
    // show loading
    self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loading.labelText = @"Loading";
    
    service = [Service getInstance];
    
    if (service.initialized) {
        [self updateCommonStyles];
        
        [self loadBillingForm];
    }
}

- (void)loadBillingForm
{
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [fields count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [cells objectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *field = [fields objectAtIndex:indexPath.row];
    //UITableViewController *selectFromList = [self.storyboard instantiateViewControllerWithIdentifier:@"listSelector"];
    
    //[self presentViewController:selectFromList animated:YES completion:nil];
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
