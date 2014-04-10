//
//  PaypalViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 04/04/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "PaypalViewController.h"
#import "PayPalMobile.h"
#import "Service.h"
#import "Customer.h"
#import "Quote.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"
#import "Core.h"


// Set the environment:
// - For live charges, use PayPalEnvironmentProduction (default).
// - To use the PayPal sandbox, use PayPalEnvironmentSandbox.
// - For testing, use PayPalEnvironmentNoNetwork.
#define kPayPalEnvironment PayPalEnvironmentSandbox

@interface PaypalViewController ()

@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;

@end

@implementation PaypalViewController {
    Service *service;
    Quote *quote;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    
    if ([[notification name] isEqualToString:@"quoteTotalsLoadedNotification"]) {
        [self pay];
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
                                                 name:@"quoteTotalsLoadedNotification"
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
        
        // show loading
        self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.loading.labelText = @"Loading";
        
        [quote getTotals];
        
        [self updateCommonStyles];
        
        // Set up payPalConfig
        _payPalConfiguration = [[PayPalConfiguration alloc] init];
        _payPalConfiguration.acceptCreditCards = YES;
        _payPalConfiguration.languageOrLocale = @"en";
        _payPalConfiguration.merchantName = @"Awesome Shirts, Inc.";
        _payPalConfiguration.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
        _payPalConfiguration.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
        
        // Setting the languageOrLocale property is optional.
        //
        // If you do not set languageOrLocale, then the PayPalPaymentViewController will present
        // its user interface according to the device's current language setting.
        //
        // Setting languageOrLocale to a particular language (e.g., @"es" for Spanish) or
        // locale (e.g., @"es_MX" for Mexican Spanish) forces the PayPalPaymentViewController
        // to use that language/locale.
        //
        // For full details, including a list of available languages and locales, see PayPalPaymentViewController.h.
        
        _payPalConfiguration.languageOrLocale = [NSLocale preferredLanguages][0];
        
        // use default environment, should be Production in real life
        self.environment = kPayPalEnvironment;
        
    }
}

- (void)updateCommonStyles
{
    // set backgroundcolor
    [self.view setBackgroundColor:[UIColor colorWithHex:[service.config_data valueForKeyPath:@"body.backgroundColor"] alpha:1.0]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // initialize paypal sdk
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"YOUR_CLIENT_ID_FOR_PRODUCTION",
                                                           PayPalEnvironmentSandbox : @"AT0aHRB6pFxfdhUQn5GPi7CfaYlHbeJpXFKjkt-PkvG3RCWTLDv0vF9pS9oQ"}];
    
    // Start out working with the test environment! When you are ready, switch to PayPalEnvironmentProduction.
    [PayPalMobile preconnectWithEnvironment:self.environment];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Receive Single Payment

- (IBAction)pay {
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%@", [quote.totals valueForKeyPath:@"totals.grand_total.value"]]];
    payment.currencyCode = @"USD";
    payment.intent = PayPalPaymentIntentAuthorize;
    payment.shortDescription = @"Mage Delight Order";
    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
    }
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:self.payPalConfiguration
                                                                                                     delegate:self];
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    //NSLog(@"%@", [completedPayment description]);
    
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate paymentComplete:self withResponse:completedPayment];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    // TODO: Send completedPayment.confirmation to server
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
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
