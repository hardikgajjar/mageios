//
//  DashboardViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 27/05/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "DashboardViewController.h"
#import "Service.h"
#import "Customer.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"
#import "Core.h"


@interface DashboardViewController ()

@end

@implementation DashboardViewController {
    Service *service;
    Customer *customer;
    
    NSMutableDictionary *form;
    NSMutableArray *cells;
    NSMutableDictionary *tags;
    
    bool showChangePassword;
}

- (void) observer:(NSNotification *) notification
{
    // perform ui updates from main thread so that they updates correctly
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(observer:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    [self.loading hide:YES];
    
    if ([[notification name] isEqualToString:@"dashboardFormLoadedNotification"]) {
        form = [customer.response mutableCopy];
        [self showFields];
    } else if ([[notification name] isEqualToString:@"accountInfoSavedNotification"]) {
        // go to dashboard
        [self performSegueWithIdentifier:@"unwindToMyAccountSegue" sender:self];
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
                                                 name:@"dashboardFormLoadedNotification"
                                               object:nil];

    // account info saved observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"accountInfoSavedNotification"
                                               object:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addObservers];
    
    service = [Service getInstance];
    
    if (service.initialized) {
        
        [self updateCommonStyles];
        
        // show loading
        self.loading = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] windows] objectAtIndex:0] animated:YES];
        self.loading.labelText = @"Loading";
        
        customer = [Customer getInstance];
        [customer getAccountInformationForm];
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
    showChangePassword = false;
    int i = 0;
    int tag = 0;
    
    for (NSArray *fieldset in [form valueForKey:@"fieldset"]) {
        
        int j = 0;
        NSMutableArray *fieldsetCells = [NSMutableArray array];
        
        for (NSDictionary *field in [fieldset valueForKey:@"field"]) {
            // set tags
            NSArray *combination = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", i], [NSString stringWithFormat:@"%d", j], nil];
            [tags setObject:combination forKey:[NSString stringWithFormat:@"%d", tag]];
            
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
                input_field.tag = tag;
                input_field.delegate = self;
                input_field.text = [field valueForKey:@"_value"];
                
                [cell.contentView addSubview:input_field];
                
            } else if ([[field valueForKey:@"_type"] isEqualToString:@"password"]) {
                
                UITextField *input_field = [[UITextField alloc] initWithFrame:CGRectMake(20, 7, 280, 30)];
                input_field.placeholder = placeholder;
                input_field.tag = tag;
                input_field.delegate = self;
                
                [cell.contentView addSubview:input_field];
                
            } else if ([[field valueForKey:@"_type"] isEqualToString:@"checkbox"]) {
                UISwitch *checkbox = [[UISwitch alloc] initWithFrame:CGRectMake(251, 6, 51, 31)];
                checkbox.tag = tag;
                [checkbox addTarget:self action:@selector(flip:) forControlEvents:UIControlEventValueChanged];
                checkbox.on = NO;
                [cell.contentView addSubview:checkbox];
                
                [[cell textLabel] setText:placeholder];
                
            }
            
            [fieldsetCells addObject:cell];
            
            tag++;
            j++;
            
        }
        [cells addObject:fieldsetCells];
        
        i++;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int count = 0;
    if (showChangePassword)
        count = [cells count];
    else
        count = [cells count] - 1;
    
    if (count < 0) count = 0;

    // Return the number of sections.
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[cells objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[cells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[form valueForKey:@"fieldset"] objectAtIndex:section] valueForKey:@"_legend"];
}

# pragma mark - switch methods

- (IBAction)flip:(id)sender {
    UISwitch *checkbox = (UISwitch *) sender;
    int i = checkbox.tag;
    NSArray *tag = [tags objectForKey:[NSString stringWithFormat:@"%d", i]];
    [[[[[form valueForKey:@"fieldset"] objectAtIndex:[[tag objectAtIndex:0] intValue]] valueForKey:@"field"] objectAtIndex:[[tag objectAtIndex:1] intValue]] setValue:checkbox.on ? @"1" : @"0" forKey:@"_value"];
    
    if (checkbox.on) {
        showChangePassword = true;
        if ([self.tableView numberOfSections] == 1)
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } else {
        showChangePassword = false;
        if ([self.tableView numberOfSections] == 2)
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}


# pragma marks - textfield methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    int i = textField.tag;
    NSArray *tag = [tags objectForKey:[NSString stringWithFormat:@"%d", i]];
    [[[[[form valueForKey:@"fieldset"] objectAtIndex:[[tag objectAtIndex:0] intValue]] valueForKey:@"field"] objectAtIndex:[[tag objectAtIndex:1] intValue]] setValue:textField.text forKey:@"_value"];
    
    //    for (NSDictionary *field in fields) {
    //        NSLog(@"%@",[field valueForKey:@"_id"]);
    //        NSLog(@"%@", [field valueForKey:@"_value"]);
    //    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)save:(id)sender {
    [self.view endEditing:YES];
    
    BOOL is_valid = true;
    
    if (form != nil) {
        
        // check if all required options are having values?
        for (NSArray *fieldset in [form valueForKey:@"fieldset"]) {
            
            // do not check fields in change password fieldset if change password checkbox is not checked
            if (!showChangePassword && [[fieldset valueForKey:@"_id"] isEqualToString:@"password_edit"])
                continue;
                
            for (NSDictionary *field in [fieldset valueForKey:@"field"]) {
                    
                if ([[field valueForKey:@"_required"] isEqualToString:@"true"]) {
                    
                    if ([field valueForKey:@"_value"] == nil ||
                        [[field valueForKey:@"_value"] isEqualToString:@""]) {
                        
                            is_valid = false;
                            break;
                       
                    }
                }
            }
        }
        
    }
    
    if (is_valid) {
        
        // save data
        
        customer = [Customer getInstance];
        
        if (customer) {
            
            [self.loading show:YES];
            
            // prepare post data
            NSMutableDictionary *post_data = [NSMutableDictionary dictionary];
            
            for (NSArray *fieldset in [form valueForKey:@"fieldset"]) {
                for (NSDictionary *field in [fieldset valueForKey:@"field"]) {
                    [post_data setValue:[field valueForKey:@"_value"] forKey:[field valueForKey:@"_name"]];
                }
            }
            
            [customer saveAccountData:post_data withActionUrl:[form valueForKey:@"_action"]];
            
        }
    } else {
        // show alert
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"An Error Occured"
                              message:@"Please fill all required field(s)."
                              delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil];
        
        [alert show];
    }
}

@end
