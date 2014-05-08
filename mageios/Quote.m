//
//  Quote.m
//  mageios
//
//  Created by KTPL - Mobile Development on 08/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "Quote.h"
#import "Service.h"
#import "XMLDictionary.h"
#import "Core.h"

@implementation Quote

@synthesize response, is_empty;

static Quote *instance =nil;

+(Quote *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [Quote new];
        }
    }
    return instance;
}

- (void)getData
{
    Service *service = [Service getInstance];
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/cart/shoppingCart"];
    
    // get cart data
    
    NSString *cart_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:cart_url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *get_cart_data = [session dataTaskWithRequest:request
                                                           completionHandler:
                                                 ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                                     NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                                     
                                                     if ([res valueForKey:@"products"] != nil) {
                                                         
                                                         // store cart data
                                                         self.data = res;
                                                         is_empty = false;
                                                         
                                                         // fire event
                                                         [[NSNotificationCenter defaultCenter]
                                                          postNotificationName:@"quoteDataLoadedNotification"
                                                          object:self];
                                                         
                                                     } else if([res valueForKey:@"summary"] != nil) {
                                                         
                                                         is_empty = true;
                                                         self.data = nil;
                                                         
                                                         [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:@"Cart is empty." waitUntilDone:NO];
                                                        
                                                         // fire event
                                                         [[NSNotificationCenter defaultCenter]
                                                          postNotificationName:@"quoteDataLoadedNotification"
                                                          object:self];
                                                         
                                                     } else {
                                                         NSLog(@"%@", res);
                                                         [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:nil waitUntilDone:NO];
                                                     }
                                                     
                                                 }];
    
    [get_cart_data resume];
}

- (void)getTotals
{
    Service *service = [Service getInstance];
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/cart/info"];
    
    // get cart data
    
    NSString *cart_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:cart_url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *get_cart_data = [session dataTaskWithRequest:request
                                                     completionHandler:
                                           ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                               NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                               
                                               if ([res valueForKey:@"totals"] != nil) {
                                                   
                                                   // store cart data
                                                   is_empty = false;
                                                   self.totals = res;
                                                   
                                                   // fire event
                                                   [[NSNotificationCenter defaultCenter]
                                                    postNotificationName:@"quoteTotalsLoadedNotification"
                                                    object:self];
                                                   
                                               } else if([[res valueForKey:@"summary_qty"] isEqualToString:@"0"]) {
                                                   is_empty = true;
                                                   [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:@"Cart is empty." waitUntilDone:NO];
                                                   
                                                   // fire event
                                                   [[NSNotificationCenter defaultCenter]
                                                    postNotificationName:@"quoteDataLoadedNotification"
                                                    object:self];
                                                   
                                               } else {
                                                   NSLog(@"%@", res);
                                                   [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:nil waitUntilDone:NO];
                                               }
                                               
                                           }];
    
    [get_cart_data resume];
}

- (void)addToCart:(NSDictionary *)data
{
    Service *service = [Service getInstance];
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/cart/add"];
    
    // add product to cart
    
    NSString *add_to_cart_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:add_to_cart_url];

    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[Core encodeDictionary:data]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *add_product_to_cart = [session dataTaskWithRequest:request
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
                                                       postNotificationName:@"productAddedToCartNotification"
                                                       object:self];
                                                      
                                                  } else if([[res valueForKey:@"status"] isEqualToString:@"error"]) {
                                                      [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:[res valueForKey:@"text"] waitUntilDone:NO];
                                                  } else {
                                                      NSLog(@"%@", res);
                                                      [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:nil waitUntilDone:NO];
                                                  }
                                                  
                                              }];
    
    [add_product_to_cart resume];
}


- (void)removeItem:(NSDictionary *)data
{
    Service *service = [Service getInstance];
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/cart/delete"];
    
    // delete product to cart
    
    NSString *remove_cart_item_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:remove_cart_item_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[Core encodeDictionary:data]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *delete_product_from_cart = [session dataTaskWithRequest:request
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
                                                          postNotificationName:@"productRemovedFromCartNotification"
                                                          object:self];
                                                         
                                                     } else if([[res valueForKey:@"status"] isEqualToString:@"error"]) {
                                                         [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:[res valueForKey:@"text"] waitUntilDone:NO];
                                                     } else {
                                                         NSLog(@"%@", res);
                                                         [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:nil waitUntilDone:NO];
                                                     }
                                                     
                                                 }];
    
    [delete_product_from_cart resume];
}

- (void)updateItem:(NSDictionary *)data
{
    Service *service = [Service getInstance];

    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/cart/update"];
    
    // update product in cart
    
    NSString *update_cart_item_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:update_cart_item_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[Core encodeDictionary:data]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *update_product_from_cart = [session dataTaskWithRequest:request
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
                                                               postNotificationName:@"productUpdatedInCartNotification"
                                                               object:self];
                                                              
                                                          } else if([[res valueForKey:@"status"] isEqualToString:@"error"]) {
                                                              [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:[res valueForKey:@"text"] waitUntilDone:NO];
                                                          } else {
                                                              NSLog(@"%@", res);
                                                              [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:nil waitUntilDone:NO];
                                                          }
                                                          
                                                      }];
    
    [update_product_from_cart resume];
}

- (void)showAlertWithErrorMessage:(NSString *)message
{
    if (message == nil) message = @"Something went wrong.";
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"An Error Occured"
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil];
    
    [alert show];
}

@end
