//
//  Order.m
//  mageios
//
//  Created by KTPL - Mobile Development on 28/05/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "Order.h"
#import "Service.h"
#import "XMLDictionary.h"
#import "Core.h"


@implementation Order

static Order *instance =nil;

+(Order *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [Order new];
        }
    }
    return instance;
}

- (void)getOrderList
{
    Service *service = [Service getInstance];
    
    // initialize variables
    NSString *url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/customer/orderlist"];
    
    NSString *order_list_url = [service.base_url stringByAppendingString:url];
    NSURL *URL = [NSURL URLWithString:order_list_url];
    
    // prepare request with post data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *get_orders = [session dataTaskWithRequest:request
                                                           completionHandler:
                                                 ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                                     
                                                     NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                                     
                                                     if ([[res valueForKey:@"__name"] isEqualToString:@"orders"]) {
                                                         // store response
                                                         self.response = res;
                                                         
                                                         // fire event
                                                         [[NSNotificationCenter defaultCenter]
                                                          postNotificationName:@"ordersLoadedNotification"
                                                          object:self];
                                                     } else if ([[res valueForKey:@"_orders_count"] isEqualToString:@"0"]) {
                                                         [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:@"You don't have any orders yet." waitUntilDone:NO];
                                                     } else {
                                                         NSLog(@"%@", res);
                                                         [self performSelectorOnMainThread:@selector(showAlertWithErrorMessage:) withObject:@"Unable to load payment methods." waitUntilDone:NO];
                                                     }
                                                 }];
    
    [get_orders resume];
}

- (void)showAlertWithErrorMessage:(NSString *)message
{
    if (message == nil) message = @"Something went wrong.";
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@""
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil];
    
    [alert show];
}

@end
