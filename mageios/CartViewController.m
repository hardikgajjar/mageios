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
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"
#import "Core.h"


@interface CartViewController ()

@end

@implementation CartViewController {
    Service *service;
    Quote   *quote;
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
    
    if ([[notification name] isEqualToString:@"quoteDataLoadedNotification"]) {
        [self.tableView reloadData];
    }
}

- (void)addObservers
{
    // Add quote load observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"quoteDataLoadedNotification"
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // show loading
    self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loading.labelText = @"Loading";
    
    [self addObservers];
    
    service = [Service getInstance];
    
    if (service.initialized) {
        [self updateCommonStyles];
        
        quote = [Quote getInstance];
        [quote getData];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

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
            return 1;
        case 1:
            if ([[quote.data valueForKeyPath:@"products.item"] isKindOfClass:[NSDictionary class]]) {
                return 1;
            }
            return [[quote.data valueForKeyPath:@"products.item"] count];
        case 2:
            if ([[quote.data valueForKeyPath:@"crosssell.item"] isKindOfClass:[NSDictionary class]]) {
                return 1;
            }
            return [[quote.data valueForKeyPath:@"crosssell.item"] count];
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return nil;
        case 1:
            return @"Product                                                    Qty";
        case 2:
            return @"You may also like";
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            static NSString *CellIdentifier = @"checkoutButtonCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            return cell;
        }
        case 1:
        {
            static NSString *CellIdentifier = @"productCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            NSDictionary *product;
            
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
            UILabel *unit_price = (UILabel *)[cell viewWithTag:30];
            unit_price.backgroundColor=[UIColor clearColor];
            unit_price.textColor=[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0];
            unit_price.text = [product valueForKeyPath:@"formated_price._regular"];
            
            // set subtotal 
            UILabel *subtotal = (UILabel *)[cell viewWithTag:40];
            subtotal.backgroundColor=[UIColor clearColor];
            subtotal.textColor=[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0];
            subtotal.text = [product valueForKeyPath:@"formated_subtotal._regular"];
            
            // set qty
            UITextView *qty = (UITextView *)[cell viewWithTag:50];
            qty.text = [product valueForKey:@"qty"];
            
            return cell;
        }
        case 2:
        {
            static NSString *CellIdentifier = @"crossellCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            return cell;
        }
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 50;
    return 110;
}


- (IBAction)showCheckoutOptions:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Log into Account", @"Create Account", @"Checkout as Guest", nil];
    
    [actionSheet showInView:self.view];
}

#pragma mark - Action sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // TODO: open login screen
            break;
        
        case 1:
            // TODO: open register screen
            break;
            
        case 2:
            // checkout as guest
            [self checkoutAsGuest];
            break;
            
        default:
            break;
    }
}

- (void)checkoutAsGuest
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
    Core *core_helper = [[Core alloc] init];
    [request setHTTPBody:[core_helper encodeDictionary:post_data]];
    
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
                                              [self performSelectorOnMainThread:@selector(redirectToBilling) withObject:nil waitUntilDone:NO];
                                              return;
                                          }
                                          
                                      }];
    
    [checkout resume];
}

- (void)redirectToBilling
{
    [self performSegueWithIdentifier:@"billingSegue" sender:self];
}

@end
