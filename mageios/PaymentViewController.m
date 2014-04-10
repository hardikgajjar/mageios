//
//  PaymentViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 28/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "PaymentViewController.h"
#import "PaypalViewController.h"
#import "OrderReviewViewController.h"
#import "Service.h"
#import "Customer.h"
#import "Quote.h"
#import "Checkout.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"
#import "Core.h"

@interface PaymentViewController ()

@end

@implementation PaymentViewController {
    Service *service;
    Quote *quote;
    Checkout *checkout;
}

- (void) observer:(NSNotification *) notification
{
    // perform ui updates from main thread so that they updates correctly
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(observer:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    [self.loading hide:YES];
    
    if ([[notification name] isEqualToString:@"paymentMethodSavedNotification"]) {
        // goto order review
        [self performSegueWithIdentifier:@"reviewSegue" sender:self];
    }
}

- (void)addObservers
{
    // Add request completed observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"requestCompletedNotification"
                                               object:nil];
    // Add quote totals loaded observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"paymentMethodSavedNotification"
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addObservers];
    
    service = [Service getInstance];
    
    if (service.initialized) {
        
        // get cart totals
        quote = [Quote getInstance];
        
        [self updateCommonStyles];
        
        //[self getPaymentMethods];
        
    }
}


- (void)getPaymentMethods
{
    // show loading
    self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loading.labelText = @"Loading";
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/checkout/paymentMethods"];
    
    NSString *payment_methods_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:payment_methods_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *get_payment_methods = [session dataTaskWithRequest:request
                                                    completionHandler:
                                          ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                              
                                              NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                              NSLog(@"%@", res);
                                              //fields = [res valueForKey:@"field"];
                                              //[self showMethods];
                                              
                                          }];
    
    [get_payment_methods resume];
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
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fieldCell" forIndexPath:indexPath];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // open paypal controller
    [self performSegueWithIdentifier:@"paypalSegue" sender:self];
}

- (void)savePaymentMethod:(NSString *)method withAuthId:(NSString *)authId
{
    checkout = [Checkout getInstance];
    
    if (checkout) {
        
        [self.loading show:YES];
        
        // prepare post data
        NSMutableDictionary *post_data = [NSMutableDictionary dictionary];
        [post_data setValue:method forKey:@"payment[method]"];
        [post_data setValue:authId forKey:@"payment[pay_id]"];

        [checkout savePayment:post_data];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"paypalSegue"]) {
        PaypalViewController *nextController = segue.destinationViewController;
        nextController.title = @"PayPal";
        nextController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"reviewSegue"]) {
        OrderReviewViewController *nextController = segue.destinationViewController;
        nextController.title = @"Order Review";
    }
}


#pragma mark - paypal view delegate methods

- (void)paymentComplete:(PaypalViewController *)controller withResponse:(PayPalPayment *)response
{
    //NSLog(@"%@", [response description]);
    
    // confirmation has id, intent,state
    if([[response.confirmation valueForKeyPath:@"response.state"] isEqualToString:@"approved"]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[response.confirmation valueForKeyPath:@"response.id"] forKey:@"pay_id"];
        [defaults synchronize];
        
        // save payment method
        #warning change once server side paypal mobile is ready
        [self savePaymentMethod:@"paypalmobile" withAuthId:[response.confirmation valueForKeyPath:@"response.id"]];
        
    } else {
        // show error
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"An Error Occured"
                              message:@"Payment can't be authorized. Please try again later."
                              delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil];
        
        [alert show];
    }
    
}

@end
