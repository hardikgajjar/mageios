//
//  OrderReviewViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 07/04/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "OrderReviewViewController.h"
#import "HomeViewController.h"
#import "Service.h"
#import "Quote.h"
#import "Checkout.h"
#import "Customer.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"
#import "Core.h"

#import "PPRevealSideViewController.h"

@interface OrderReviewViewController ()

@end

@implementation OrderReviewViewController {
    Service *service;
    Checkout *checkout;
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
    
    if ([[notification name] isEqualToString:@"orderReviewDataLoadedNotification"]) {
        [self.tableView reloadData];
    } else if ([[notification name] isEqualToString:@"orderSavedNotification"]) {
        
        // go to home
        UITabBarController *root = (UITabBarController *)self.revealSideViewController.rootViewController;
        root.selectedIndex = 0;
        [[[root.viewControllers objectAtIndex:2] navigationController] popToRootViewControllerAnimated:NO];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:[checkout.response valueForKey:@"text"]
                              delegate:self
                              cancelButtonTitle:@"Continue"
                              otherButtonTitles:nil];
        
        [alert show];
        
    }
}

- (void)addObservers
{
    // Add request completed observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"requestCompletedNotification"
                                               object:nil];
    // Add order review data loaded observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"orderReviewDataLoadedNotification"
                                               object:nil];
    // save order observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"orderSavedNotification"
                                               object:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // show loading
    self.loading = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] windows] objectAtIndex:0] animated:YES];
    //self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loading.labelText = @"Loading";
    
    [self addObservers];
    
    service = [Service getInstance];
    
    if (service.initialized) {
        [self updateCommonStyles];
        
        checkout = [Checkout getInstance];
        [checkout orderReview];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            if ([[checkout.response valueForKeyPath:@"products.item"] isKindOfClass:[NSDictionary class]]) {
                return 1;
            }
            return [[checkout.response valueForKeyPath:@"products.item"] count];
        case 1:
            return 1;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Product                                                    Qty";
        default:
            return 0;
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
            
            if ([[checkout.response valueForKeyPath:@"products.item"] isKindOfClass:[NSDictionary class]]) {
                product = [checkout.response valueForKeyPath:@"products.item"];
            } else {
                product = [[checkout.response valueForKeyPath:@"products.item"] objectAtIndex:indexPath.row];
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
            //unit_price.backgroundColor=[UIColor clearColor];
            //unit_price.textColor=[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0];
            unit_price.text = [product valueForKeyPath:@"formated_price._regular"];
            
            // set subtotal
            UILabel *subtotal = (UILabel *)[cell viewWithTag:40];
            //subtotal.backgroundColor=[UIColor clearColor];
            //subtotal.textColor=[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0];
            subtotal.text = [product valueForKeyPath:@"formated_subtotal._regular"];
            
            // set qty
            UILabel *qty = (UILabel *)[cell viewWithTag:50];
            qty.text = [product valueForKey:@"qty"];
            
            return cell;
        }
        case 1:
        {
            static NSString *CellIdentifier = @"totalsCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            int i = 1;
            
            for (id key in [checkout.response valueForKey:@"totals"]) {
                
                UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 20*i, 180, 20)];
                title.textAlignment = NSTextAlignmentRight;
                title.font=[title.font fontWithSize:13];
                title.text = [[[checkout.response valueForKey:@"totals"] objectForKey:key] valueForKey:@"title"];
                
                UILabel *value = [[UILabel alloc] initWithFrame:CGRectMake(220, 20*i, 80, 20)];
                value.textAlignment = NSTextAlignmentRight;
                value.font=[value.font fontWithSize:13];
                value.text = [[[checkout.response valueForKey:@"totals"] objectForKey:key] valueForKey:@"formated_value"];
                
                [cell.contentView addSubview:title];
                [cell.contentView addSubview:value];
                
                i++;
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



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"paypalSegue"]) {
        PaypalViewController *nextController = segue.destinationViewController;
        nextController.title = @"PayPal";
        nextController.delegate = self;
    }
}

- (IBAction)placeOrder:(id)sender {
    if (checkout == nil) {
        checkout = [Checkout getInstance];
    }
    
    if ([checkout.savedPaymentMethod isEqualToString:@"free"]) {
        
        [self.loading show:YES];
        
        // prepare post data
        NSMutableDictionary *post_data = [NSMutableDictionary dictionary];
        [post_data setValue:checkout.savedPaymentMethod forKey:@"payment[method]"];
        [post_data setValue:@"1" forKey:@"agreement[1]"];
        
        [checkout saveOrder:post_data];
        
    } else {
        #warning assuming we dont have only paypalmobile
        // open paypal VC
        [self performSegueWithIdentifier:@"paypalSegue" sender:self];
    }
}

#pragma mark - paypal view delegate methods

- (void)paymentCompleteWithResponse:(PayPalPayment *)response
{
    //NSLog(@"%@", [response description]);
    
    // confirmation has id, intent,state
    if([[response.confirmation valueForKeyPath:@"response.state"] isEqualToString:@"approved"]) {
        
        // show loading
        [self.loading show:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[response.confirmation valueForKeyPath:@"response.id"] forKey:@"pay_id"];
        [defaults synchronize];
        
        // place order
        checkout = [Checkout getInstance];
        
        if (checkout) {
            
            [self.loading show:YES];
            
            // prepare post data
            NSMutableDictionary *post_data = [NSMutableDictionary dictionary];
            [post_data setValue:checkout.savedPaymentMethod forKey:@"payment[method]"];
            [post_data setValue:@"1" forKey:@"agreement[1]"];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *pay_id = [defaults valueForKey:@"pay_id"];
            
            [post_data setValue:pay_id forKey:@"payment[pay_id]"];
            
            [checkout saveOrder:post_data];
        }
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
