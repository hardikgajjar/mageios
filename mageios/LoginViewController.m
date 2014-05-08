//
//  LoginViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 19/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "LoginViewController.h"
#import "Validation.h"
#import "Customer.h"

#import "RegisterViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController {
    Customer *customer;
}

@synthesize email,password,showPassword;

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
    
    if ([[notification name] isEqualToString:@"loggedInNotification"]) {
        // go back to previous view
        [self performSegueWithIdentifier:@"returnFromLoginSegue" sender:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)addObservers
{
    // Add login observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"loggedInNotification"
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
    
    //UIImage *button_image = [[UIImage imageNamed:@"button"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    //[self.loginBtn setBackgroundImage:button_image forState:UIControlStateNormal];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"createAccountFromCheckoutSegue"]) {
        RegisterViewController *nextController = segue.destinationViewController;
        nextController.sender = sender;
    }
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

- (IBAction)login:(id)sender {
    
    if ([self validateForm]) {
        
        // trigger post to login
        customer = [Customer getInstance];
        
        if (customer) {
            self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.loading.labelText = @"Loading";
            
            // prepare post data
            NSMutableDictionary *post_data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[self.email text], @"username", [self.password text], @"password", nil];
            
            [customer login:post_data];
        }
    }
}

- (IBAction)forgotPassword:(id)sender {
}

- (IBAction)togglePassword:(id)sender {
    if (self.showPassword.on) {
        self.password.secureTextEntry = false;
    } else {
        self.password.secureTextEntry = true;
    }
}
@end
