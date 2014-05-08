//
//  CartViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 10/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "CartViewController.h"
#import "Service.h"
#import "Quote.h"
#import "Customer.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"
#import "Core.h"
#import "Utility.h"

#import "BillingViewController.h"
#import "RegisterViewController.h"


@interface CartViewController ()

@end

@implementation CartViewController {
    Service *service;
    Quote   *quote;
    Customer *customer;
    Utility *utility;
    NSInteger last_deleted_item_id;
    NSString *last_qty_value;
}

@synthesize checkout_btn;

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
    
    [self.loading hide:NO];
    
    if ([[notification name] isEqualToString:@"quoteDataLoadedNotification"]) {
        [self refreshCart];
    } else if ([[notification name] isEqualToString:@"productRemovedFromCartNotification"]) {

        if ([[quote.data valueForKeyPath:@"products.item"] isKindOfClass:[NSDictionary class]]) {
            quote.data = nil;
            quote.is_empty = true;
        } else {
            [[quote.data valueForKeyPath:@"products.item"] removeObjectAtIndex:last_deleted_item_id];
        }

        [self refreshCart];
    } else if ([[notification name] isEqualToString:@"productUpdatedInCartNotification"]) {
        //reload data
        [self.loading show:YES];
        [quote getData];
    }
}

- (void)refreshCart
{
    if (quote.is_empty) {
        checkout_btn.enabled = false;
    } else {
        checkout_btn.enabled = true;
    }
    [self.tableView reloadData];
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"requestCompletedNotification"
                                               object:nil];
    // Add quote load observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"quoteDataLoadedNotification"
                                               object:nil];
    
    // Add item deleted from cart observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"productRemovedFromCartNotification"
                                               object:nil];

    // Add item updated from cart observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"productUpdatedInCartNotification"
                                               object:nil];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add left menu
    //utility = [[Utility alloc] init];
    //[utility addLeftMenu:self];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // writing here to load cart all the times this view is opened
    // show loading
    self.loading = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] windows] objectAtIndex:0] animated:YES];
    self.loading.labelText = @"Loading";
    
    [self addObservers];
    
    service = [Service getInstance];
    
    if (service.initialized) {
        [self updateCommonStyles];
        
        // get customer
        customer = [Customer getInstance];
        
        // get quote
        quote = [Quote getInstance];
        [quote getData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [MBProgressHUD hideAllHUDsForView:[[[UIApplication sharedApplication] windows] objectAtIndex:0] animated:NO];
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


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"billingSegue"]) {
        BillingViewController *nextController = segue.destinationViewController;
        nextController.data = sender;
    } else if ([segue.identifier isEqualToString:@"createAccountFromCheckoutSegue"]) {
        RegisterViewController *nextController = segue.destinationViewController;
        nextController.sender = sender;
    }
}

- (IBAction)returnFromLogin:(UIStoryboardSegue *)segue {
    customer.isLoggedIn = true;
    [self checkout];
}

- (IBAction)returnFromRegister:(UIStoryboardSegue *)unwindSegue
{
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            if ([[quote.data valueForKeyPath:@"products.item"] isKindOfClass:[NSDictionary class]]) {
                return 1;
            }
            return [[quote.data valueForKeyPath:@"products.item"] count];
        case 1:
            if ([quote.data valueForKeyPath:@"totals.total"] && [[quote.data valueForKeyPath:@"products.item"] count] > 0)
                return 1;
            else
                return 0;
//        case 1:
//            if ([[quote.data valueForKeyPath:@"crosssell.item"] isKindOfClass:[NSDictionary class]]) {
//                return 1;
//            }
//            return [[quote.data valueForKeyPath:@"crosssell.item"] count];
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Product                                                    Qty";
//        case 1:
//            return @"You may also like";
        default:
            return 0;
    }
}

- (void)logTags:(UIView *)view indent:(NSInteger)indent {
    
    NSLog(@"%*sview is a %@ with tag = %d", indent, "", view.class, view.tag);
    
    for (UIView *subview in [view subviews]) {
        [self logTags:subview indent:indent+4];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            static NSString *CellIdentifier = @"productCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            NSDictionary *product;
            
            cell.contentView.tag = indexPath.row;
            
            if ([[quote.data valueForKeyPath:@"products.item"] isKindOfClass:[NSDictionary class]]) {
                product = [quote.data valueForKeyPath:@"products.item"];
            } else {
                product = [[quote.data valueForKeyPath:@"products.item"] objectAtIndex:indexPath.row];
            }
            
            
            // set icon
            UIImageView *productImageView = (UIImageView *)[cell viewWithTag:10];
            UIImage *icon_image = [UIImage imageWithData:
                                   [NSData dataWithContentsOfURL:
                                    [NSURL URLWithString:[product valueForKeyPath:@"icon.@innerText"]]]];
            [productImageView setImage:icon_image];
            
            //border to icon
            CALayer *borderLayer = [CALayer layer];
            CGRect borderFrame = CGRectMake(0, 0, (productImageView.frame.size.width), (productImageView.frame.size.height));
            [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
            [borderLayer setFrame:borderFrame];
            [borderLayer setBorderWidth:1.0];
            [borderLayer setBorderColor:[[UIColor colorWithHex:[service.config_data valueForKeyPath:@"body.backgroundColor"] alpha:1.0] CGColor]];
            [productImageView.layer addSublayer:borderLayer];
            
            // set name
            UILabel *name = (UILabel *)[cell viewWithTag:20];
            name.text = [product valueForKey:@"name"];
            
            // set unit price
            int y = 37, i=0;
            for (NSDictionary *item in [product valueForKeyPath:@"price_list.prices"]) {
                
                UILabel *label = (UILabel *)[cell viewWithTag:70+i];
                if (label == nil)
                label = [[UILabel alloc] initWithFrame:CGRectMake(88, y, 65, 21)];
                label.tag = 70+i;
                label.backgroundColor=[UIColor clearColor];
                [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:13]];
                label.text = [item valueForKeyPath:@"price._label"];
                
                UILabel *price = (UILabel *)[cell viewWithTag:150+i];
                if (price == nil)
                price = [[UILabel alloc] initWithFrame:CGRectMake(155, y, 80, 21)];
                price.tag = 150+i;
                //price.backgroundColor=[UIColor clearColor];
                [price setFont:[UIFont fontWithName:@"HelveticaNeue" size:13]];
                price.text = [item valueForKeyPath:@"price._formatted_value"];
                //price.textColor=[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0];
                
                [cell.contentView addSubview:label];
                [cell.contentView addSubview:price];
                
                y += 15;
                i++;
            }
            
            
            // set qty
            //UITextView *qty = (UITextView *)[cell viewWithTag:50];
            UILabel *qty = (UILabel *)[cell viewWithTag:60];
            qty.text = [product valueForKey:@"qty"];
            
            return cell;
        }
        case 1:
        {
            static NSString *CellIdentifier = @"totalsCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            cell.editing = false;
            
            int i = 1;
            
            if ([[quote.data valueForKeyPath:@"totals.total"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *total = [quote.data valueForKeyPath:@"totals.total"];
                
                UILabel *title = (UILabel *)[cell viewWithTag:10];
                if (title == nil)
                title = [[UILabel alloc] initWithFrame:CGRectMake(20, 20*i, 180, 20)];
                title.tag = 10;
                title.textAlignment = NSTextAlignmentRight;
                title.font=[title.font fontWithSize:13];
                title.text = [total valueForKeyPath:@"item._label"];
                
                UILabel *value = (UILabel *)[cell viewWithTag:20];
                if (value == nil)
                value = [[UILabel alloc] initWithFrame:CGRectMake(220, 20*i, 80, 20)];
                value.tag = 20;
                value.textAlignment = NSTextAlignmentRight;
                value.font=[value.font fontWithSize:13];
                value.text = [total valueForKeyPath:@"item._formatted_value"];
                
                [cell.contentView addSubview:title];
                [cell.contentView addSubview:value];
            } else {
                for (NSDictionary *total in [quote.data valueForKeyPath:@"totals.total"]) {
                    
                    UILabel *title = (UILabel *)[cell viewWithTag:10+i];
                    if (title == nil)
                    title = [[UILabel alloc] initWithFrame:CGRectMake(20, 20*i, 180, 20)];
                    title.tag = 10+i;
                    title.textAlignment = NSTextAlignmentRight;
                    title.font=[title.font fontWithSize:13];
                    title.text = [total valueForKeyPath:@"item._label"];
                    
                    UILabel *value = (UILabel *)[cell viewWithTag:50+i];
                    if (value == nil)
                    value = [[UILabel alloc] initWithFrame:CGRectMake(220, 20*i, 80, 20)];
                    value.tag = 50+i;
                    value.textAlignment = NSTextAlignmentRight;
                    value.font=[value.font fontWithSize:13];
                    value.text = [total valueForKeyPath:@"item._formatted_value"];
                    
                    [cell.contentView addSubview:title];
                    [cell.contentView addSubview:value];
                    
                    i++;
                }
            }
            
            return cell;
        }
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return true;
    }
    return false;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.edit_btn.title = @"Edit";
        [self.loading show:YES];
        
        NSDictionary *item;
        if ([[quote.data valueForKeyPath:@"products.item"] isKindOfClass:[NSDictionary class]]) {
            item = [quote.data valueForKeyPath:@"products.item"];
        } else {
            item = [[quote.data valueForKeyPath:@"products.item"] objectAtIndex:indexPath.row];
        }
        last_deleted_item_id = indexPath.row;
        
        // prepare post data
        NSMutableDictionary *post_data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[item valueForKey:@"item_id"], @"item_id", nil];
        
        [quote removeItem:post_data];
    }
}


- (void)setCustomEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];

    if (editing == false) {
        for (UITableViewCell *cell in [self.tableView visibleCells]) {
            NSIndexPath *path = [self.tableView indexPathForCell:cell];
            if (path.section == 0) {
                // hide text box for qty
                UITextView *qty_field = (UITextView *)[cell viewWithTag:50];
                [qty_field resignFirstResponder];
                qty_field.hidden = true;
                UILabel *qty = (UILabel *)[cell viewWithTag:60];
                qty.hidden = false;
                qty.text = qty_field.text;
            }
        }
    } else {
        self.edit_btn.title = @"Done";

        for (UITableViewCell *cell in [self.tableView visibleCells]) {
            NSIndexPath *path = [self.tableView indexPathForCell:cell];
            if (path.section == 0) {
                // show text box for qty
                UILabel *qty = (UILabel *)[cell viewWithTag:60];
                qty.hidden = true;
                UITextView *qty_field = (UITextView *)[cell viewWithTag:50];
                qty_field.hidden = false;
                qty_field.text = qty.text;
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        self.edit_btn.title = @"Done";
        // show text box for qty
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UILabel *qty = (UILabel *)[cell viewWithTag:60];
        qty.hidden = true;
        UITextView *qty_field = (UITextView *)[cell viewWithTag:50];
        qty_field.hidden = false;
        qty_field.text = qty.text;
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        self.edit_btn.title = @"Edit";
        // hide text box for qty
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UITextView *qty_field = (UITextView *)[cell viewWithTag:50];
        [qty_field resignFirstResponder];
        qty_field.hidden = true;
        UILabel *qty = (UILabel *)[cell viewWithTag:60];
        qty.hidden = false;
        qty.text = qty_field.text;
    }
}


- (IBAction)showCheckoutOptions:(id)sender {
    
    if (customer.isLoggedIn) {
        [self checkout];
    } else {
#warning removed @"Checkout as Guest" option for now since we are using onestepcheckout and this module allows guest checkout(with username/password fields) even if we have virtual/downloadable products
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Log into Account", @"Create Account", nil];
        actionSheet.tag = 1;
        [actionSheet showInView:self.view];
    }
}

- (IBAction)editCart:(id)sender {
    
    if ([self.edit_btn.title isEqualToString:@"Edit"]) {
        [self setCustomEditing:YES animated:YES];
        self.edit_btn.title = @"Done";
    } else {
        [self setCustomEditing:NO animated:YES];
        self.edit_btn.title = @"Edit";
    }
    
}

#pragma mark - Action sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // go to login
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
            break;
            
        case 1:
            // open register screen
            [self performSegueWithIdentifier:@"createAccountFromCheckoutSegue" sender:self];
            break;
            
#warning removed @"Checkout as Guest" option for now since we are using onestepcheckout and this module allows guest checkout(with username/password fields) even if we have virtual/downloadable products
//        case 2:
//            // checkout as guest
//            [self checkout];
//            break;
            
        default:
            break;
    }
}

- (void)checkout
{
    [self.loading show:YES];
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/checkout"];
    
    NSString *checkout_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:checkout_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    //[request setHTTPBody:[self encodeDictionary:data]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *checkout = [session dataTaskWithRequest:request
                                                completionHandler:
                                      ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                          
                                          [self.loading hide:YES];
                                          
                                          NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                          
                                          if ([[res valueForKey:@"__name"] isEqualToString:@"billing"]) {
                                                  [self saveCheckoutMethod];
                                                  
                                                  // go to /checkout again and get on which page we should
                                                  // redirect customer to, billing or shipping or anything else?
                                                  // and may be there's an error also
                                                  [self getCheckoutLandingPage];
                                          } else if ([[res valueForKey:@"__name"] isEqualToString:@"message"] &&
                                                     [[res valueForKey:@"status"] isEqualToString:@"error"] &&
                                                     [[res valueForKey:@"logged_in"] isEqualToString:@"0"]) {

                                              // show alert and on click go to login
                                              [self performSelectorOnMainThread:@selector(showAlertWithMessage:) withObject:[res valueForKey:@"text"] waitUntilDone:NO];

                                          }
                                          
                                      }];
    
    [checkout resume];
}

- (void)saveCheckoutMethod
{
    [self.loading show:YES];
    
    // save checkout method
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/checkout/savemethod"];
    NSString *save_checkout_method_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:save_checkout_method_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    NSDictionary *post_data = [[NSDictionary alloc] initWithObjectsAndKeys:@"guest", @"method", nil];

    [request setHTTPBody:[Core encodeDictionary:post_data]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *save_checkout_method = [session dataTaskWithRequest:request
                                                            completionHandler:
                                                  ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                                      
                                                      [self.loading hide:YES];
                                                      
                                                      NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                                      if (![[res valueForKey:@"status"] isEqualToString:@"success"]) {
                                                          // TODO: show error and may be redirect user on home
                                                      }
                                                  }
    ];
    [save_checkout_method resume];
}

- (void)getCheckoutLandingPage
{
    [self.loading show:YES];
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/checkout"];
    
    NSString *checkout_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:checkout_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    //[request setHTTPBody:[self encodeDictionary:data]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *checkout = [session dataTaskWithRequest:request
                                                completionHandler:
                                      ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                          
                                          [self.loading hide:YES];
                                          
                                          NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                          
                                          if ([[res valueForKey:@"__name"] isEqualToString:@"billing"]) {
                                              [self performSelectorOnMainThread:@selector(redirectToBillingwithData:) withObject:res waitUntilDone:NO];
                                              return;
                                          }
                                          
                                      }];
    
    [checkout resume];
}

- (void)redirectToBillingwithData:(NSDictionary *)data
{
    [self performSegueWithIdentifier:@"billingSegue" sender:data];
}

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"An Error Occured"
                          message:message
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    [alert show];
}

#pragma mark - alert view methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { // go to login
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    }
}

#pragma mark - textfield methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    last_qty_value = textField.text;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    // update qty if changed
    if (textField.text != last_qty_value) {
        [self.loading show:YES];
        
        NSDictionary *item;
        if ([[quote.data valueForKeyPath:@"products.item"] isKindOfClass:[NSDictionary class]]) {
            item = [quote.data valueForKeyPath:@"products.item"];
        } else {
            item = [[quote.data valueForKeyPath:@"products.item"] objectAtIndex:textField.superview.tag];
        }
        
        // prepare post data
        NSString *key = [NSString stringWithFormat:@"cart[%@][qty]", [item valueForKey:@"item_id"]];
        NSMutableDictionary *post_data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:textField.text, key, nil];
        
        [quote updateItem:post_data];
    }
    
    last_qty_value = nil;
}

@end
