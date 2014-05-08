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
    NSDictionary *payment_methods;
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
    } else if ([[notification name] isEqualToString:@"paymentMethodsLoadedNotification"]) {
        // show loaded methods
        payment_methods = checkout.response;
        [self.tableView reloadData];
    }
}

- (void)addObservers
{
    // Add request completed observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"requestCompletedNotification"
                                               object:nil];

    // Add payment methods loaded observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"paymentMethodsLoadedNotification"
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
        
        if (checkout == nil) {
            checkout = [Checkout getInstance];
            
            // show loading
            self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.loading.labelText = @"Loading";
            
            [checkout getPaymentMethods];
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
    if (payment_methods != nil) {
        if ([[payment_methods valueForKey:@"method"] isKindOfClass:[NSDictionary class]]) {
            return 1;
        } else {
            return [[payment_methods valueForKey:@"method"] count];
        }
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fieldCell" forIndexPath:indexPath];
    
    if (payment_methods != nil) {
        if ([[payment_methods valueForKey:@"method"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *method = [payment_methods valueForKey:@"method"];
            cell.textLabel.text = [method valueForKey:@"_label"];
        } else {
            NSDictionary *method = [[payment_methods valueForKey:@"method"] objectAtIndex:indexPath.row];
            cell.textLabel.text = [method valueForKey:@"_label"];
            
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // save this payment method
    if ([[payment_methods valueForKey:@"method"] isKindOfClass:[NSDictionary class]]) {
        [self savePaymentMethod:[payment_methods valueForKeyPath:@"method._code"]];
    } else {
        [self savePaymentMethod:[[[payment_methods valueForKey:@"method"] objectAtIndex:indexPath.row] valueForKey:@"_code"]];
    }
}

- (void)savePaymentMethod:(NSString *)method
{
    checkout = [Checkout getInstance];
    
    if (checkout) {
        
        [self.loading show:YES];
        
        // prepare post data
        NSMutableDictionary *post_data = [NSMutableDictionary dictionary];
        [post_data setValue:method forKey:@"payment[method]"];
        //[post_data setValue:authId forKey:@"payment[pay_id]"];

        [checkout savePayment:post_data];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"reviewSegue"]) {
        OrderReviewViewController *nextController = segue.destinationViewController;
        nextController.title = @"Order Review";
    }
}

@end
