//
//  RegisterViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 10/04/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "RegisterViewController.h"
#import "Validation.h"
#import "Customer.h"

#import "CartViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController {
    Customer *customer;
}

@synthesize firstname,lastname,email,password,confirmPassword,showPassword;

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
    
    if ([[notification name] isEqualToString:@"RegistrationCompleteNotification"]) {
        if ([self.sender isKindOfClass:[CartViewController class]]) {
            // go back to cart
            [self performSegueWithIdentifier:@"returntoCartSegue" sender:self];
        } else {
            // go to my account
            [self performSegueWithIdentifier:@"myAccountSegue" sender:self];
        }
    }
}

- (void)addObservers
{
    // Add login observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"RegistrationCompleteNotification"
                                               object:nil];
    
    // Add request completed observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"requestCompletedNotification"
                                               object:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addObservers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Textfield

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)validateForm
{
    BOOL valid = true;
    
    if (![Validation validateEmailWithString:[self.email text]]) {
        valid = false;
        [self showAlertWithMessage:@"Email is not valid"];
    } else if (![Validation validatePasswordWithString:[self.password text]]) {
        valid = false;
        [self showAlertWithMessage:@"Password must be atleast 6 characters long."];
    } else if (![[self.confirmPassword text] isEqualToString:[self.password text]]) {
        valid = false;
        [self showAlertWithMessage:@"Password confirmtaion is not same as original password."];
    } else if (![Validation validateEmptyString:[self.firstname text]]) {
        valid = false;
        [self showAlertWithMessage:@"Firstname can not be empty."];
    } else if (![Validation validateEmptyString:[self.lastname text]]) {
        valid = false;
        [self showAlertWithMessage:@"Lastname can not be empty."];
    }
    return valid;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)togglePassword:(id)sender {
    if (self.showPassword.on) {
        self.password.secureTextEntry = false;
    } else {
        self.password.secureTextEntry = true;
    }
}

- (IBAction)registerCustomer:(id)sender {
    
    if ([self validateForm]) {
        
        // trigger post to create account
        customer = [Customer getInstance];
        
        if (customer) {
            self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.loading.labelText = @"Loading";
            
            // prepare post data
            NSMutableDictionary *post_data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1", @"checkout_page_registration", [self.firstname text], @"firstname", [self.lastname text], @"lastname", [self.email text], @"email", [self.password text], @"password", [self.confirmPassword text], @"confirmation", nil];
            
            [customer save:post_data];
        }
    }
}


@end
