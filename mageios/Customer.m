//
//  Customer.m
//  mageios
//
//  Created by KTPL - Mobile Development on 20/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "Customer.h"
#import "Service.h"
#import "XMLDictionary.h"
#import "Core.h"

@implementation Customer

static Customer *instance =nil;

+(Customer *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [Customer new];
        }
    }
    return instance;
}

- (id)init
{
    // check if customer is loggedIn
    
    Service *service = [Service getInstance];
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/customer/isLoggined"];
    
    NSString *login_check_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:login_check_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *check_login = [session dataTaskWithRequest:request
                                             completionHandler:
                                   ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                       
                                       NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];

                                       if ([[res valueForKey:@"__name"] isEqualToString:@"message"]) {
                                           
                                           self.isLoggedIn = [[res valueForKey:@"is_loggined"] boolValue];
                                           
                                       } else {
                                           NSLog(@"%@", res);
                                           [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:@"Unable to check customer's login state" waitUntilDone:NO];
                                       }
                                       
                                   }];
    
    [check_login resume];
    
    return self;
}

- (void)login:(NSDictionary *)data
{
    Service *service = [Service getInstance];
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/customer/login"];
    
    // login
    
    NSString *login_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:login_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[Core encodeDictionary:data]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *login = [session dataTaskWithRequest:request
                                                           completionHandler:
                                                 ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                                     
                                                     // fire request complete event
                                                     [[NSNotificationCenter defaultCenter]
                                                      postNotificationName:@"requestCompletedNotification"
                                                      object:self];
                                                     
                                                     NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                                     
                                                     if ([[res valueForKey:@"status"] isEqualToString:@"success"]) {
                                                         
                                                         self.isLoggedIn = true;
                                                         
                                                         // fire event
                                                         [[NSNotificationCenter defaultCenter]
                                                          postNotificationName:@"loggedInNotification"
                                                          object:self];
                                                         
                                                     } else if([[res valueForKey:@"status"] isEqualToString:@"error"]) {
                                                         [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:[res valueForKey:@"text"] waitUntilDone:NO];
                                                     } else {
                                                         NSLog(@"%@", res);
                                                         [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:nil waitUntilDone:NO];
                                                     }
                                                     
                                                 }];
    
    [login resume];
}

- (void)logout
{
    Service *service = [Service getInstance];
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/customer/logout"];
    
    // logout
    
    NSString *logout_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:logout_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *logout = [session dataTaskWithRequest:request
                                             completionHandler:
                                   ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                       
                                       // fire request complete event
                                       [[NSNotificationCenter defaultCenter]
                                        postNotificationName:@"requestCompletedNotification"
                                        object:self];
                                       
                                       NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                       
                                       if ([[res valueForKey:@"status"] isEqualToString:@"success"]) {
                                           self.isLoggedIn = false;
                                           
                                           // fire event
                                           [[NSNotificationCenter defaultCenter]
                                            postNotificationName:@"loggedOutNotification"
                                            object:self];
                                           
                                       } else if([[res valueForKey:@"status"] isEqualToString:@"error"]) {
                                           [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:[res valueForKey:@"text"] waitUntilDone:NO];
                                       } else {
                                           NSLog(@"%@", res);
                                           [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:nil waitUntilDone:NO];
                                       }
                                       
                                   }];
    
    [logout resume];
}

- (void)save:(NSDictionary *)data
{
    Service *service = [Service getInstance];
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/customer/save"];
    
    // save
    
    NSString *save_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:save_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[Core encodeDictionary:data]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *save_customer = [session dataTaskWithRequest:request
                                             completionHandler:
                                   ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                       
                                       // fire request complete event
                                       [[NSNotificationCenter defaultCenter]
                                        postNotificationName:@"requestCompletedNotification"
                                        object:self];
                                       
                                       NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                       
                                       if ([[res valueForKey:@"status"] isEqualToString:@"success"]) {
                                           
                                           self.isLoggedIn = true;
                                           
                                           // fire event
                                           [[NSNotificationCenter defaultCenter]
                                            postNotificationName:@"RegistrationCompleteNotification"
                                            object:self];
                                           
                                       } else if([[res valueForKey:@"status"] isEqualToString:@"error"]) {
                                           [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:[res valueForKey:@"text"] waitUntilDone:NO];
                                       } else {
                                           NSLog(@"%@", res);
                                           [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:nil waitUntilDone:NO];
                                       }
                                       
                                   }];
    
    [save_customer resume];
}


- (void)saveBillingAddress:(NSDictionary *)data
{
    Service *service = [Service getInstance];
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/checkout/savebillingaddress"];
    
    // save billing address for this customer
    
    NSString *save_billing_address_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:save_billing_address_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[Core encodeDictionary:data]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *save_billing_address = [session dataTaskWithRequest:request
                                                           completionHandler:
                                                 ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                                     
                                                     // fire request complete event
                                                     [[NSNotificationCenter defaultCenter]
                                                      postNotificationName:@"requestCompletedNotification"
                                                      object:self];
                                                     
                                                     NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                                     
                                                     if ([[res valueForKey:@"status"] isEqualToString:@"success"]) {
                                                         
                                                         // store response
                                                         self.response = res;
                                                         
                                                         // fire event
                                                         [[NSNotificationCenter defaultCenter]
                                                          postNotificationName:@"billingAddressSavedNotification"
                                                          object:self];
                                                         
                                                     } else if([[res valueForKey:@"status"] isEqualToString:@"error"]) {
                                                         [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:[res valueForKey:@"text"] waitUntilDone:NO];
                                                     } else {
                                                         NSLog(@"%@", res);
                                                         [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:nil waitUntilDone:NO];
                                                     }
                                                     
                                                 }];
    
    [save_billing_address resume];
}

- (void)getAccountInformationForm
{
    Service *service = [Service getInstance];
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/customer/form/edit/1"];
    
    NSString *account_info_form_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:account_info_form_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *account_info_form = [session dataTaskWithRequest:request
                                                    completionHandler:
                                          ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                              
                                              NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                              
                                              if ([[res valueForKey:@"__name"] isEqualToString:@"form"]) {
                                                  self.response = res;
                                                  
                                                  // fire event
                                                  [[NSNotificationCenter defaultCenter]
                                                   postNotificationName:@"dashboardFormLoadedNotification"
                                                   object:self];
                                                  
                                              } else {
                                                  NSLog(@"%@", res);
                                                  [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:nil waitUntilDone:NO];
                                              }
                                              
                                          }];
    
    [account_info_form resume];
}

- (void)saveAccountData:(NSDictionary *)data withActionUrl:(NSString *)url
{
    // save account info for this customer
    
    NSString *save_account_info_url = url;
    NSURL *URL = [NSURL URLWithString:save_account_info_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[Core encodeDictionary:data]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *save_account_info = [session dataTaskWithRequest:request
                                                            completionHandler:
                                                  ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                                      
                                                      // fire request complete event
                                                      [[NSNotificationCenter defaultCenter]
                                                       postNotificationName:@"requestCompletedNotification"
                                                       object:self];
                                                      
                                                      NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                                      NSLog(@"%@", res);
                                                      if ([[res valueForKey:@"status"] isEqualToString:@"success"]) {
                                                          
                                                          // store response
                                                          self.response = res;
                                                          
                                                          // fire event
                                                          [[NSNotificationCenter defaultCenter]
                                                           postNotificationName:@"accountInfoSavedNotification"
                                                           object:self];
                                                          
                                                      } else if([[res valueForKey:@"status"] isEqualToString:@"error"]) {
                                                          [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:[res valueForKey:@"text"] waitUntilDone:NO];
                                                      } else {
                                                          NSLog(@"%@", res);
                                                          [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:nil waitUntilDone:NO];
                                                      }
                                                      
                                                  }];
    
    [save_account_info resume];
}


- (void)showAlertWithErrorMessage:(NSString *)message
{
    if (message == nil) message = @"Unable to login.";
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"An Error Occured"
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil];
    
    [alert show];
}
@end
