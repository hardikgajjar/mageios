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

@implementation Quote

@synthesize response;

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
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/cart"];
    
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
    [request setHTTPBody:[self encodeDictionary:data]];
    
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

- (NSData*)encodeDictionary:(NSDictionary*)dictionary {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)showAlertWithErrorMessage:(NSString *)message
{
    if (message == nil) message = @"Unable to add product to cart.";
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"An Error Occured"
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil];
    
    [alert show];
}

@end
