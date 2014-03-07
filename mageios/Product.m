//
//  Product.m
//  mageios
//
//  Created by KTPL - Mobile Development on 06/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "Product.h"
#import "Service.h"
#import "XMLDictionary.h"


@implementation Product

@synthesize url,data;

- (id)initWithId:(int)product_id
{
    self = [super init];
    if(self)
    {
        Service *service = [Service getInstance];
        
        // initialize variables
        self.url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/catalog/product/id/%d", product_id];
        
        // get product data
        
        NSString *detail_page_url = [service.base_url stringByAppendingString:self.url];
        NSURL *URL = [NSURL URLWithString:detail_page_url];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *get_product_data = [session dataTaskWithRequest:request
                                                         completionHandler:
                                               ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                                   NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                                   
                                                   if ([res valueForKey:@"entity_id"] != NULL) {

                                                       // store data
                                                       self.data = res;
                                                       
                                                       // fire event
                                                       [[NSNotificationCenter defaultCenter]
                                                        postNotificationName:@"productDataLoadedNotification"
                                                        object:self];
                                                   } else {
                                                       NSLog(@"%@", res);
                                                       [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
                                                   }
                                                   
                                               }];
        
        [get_product_data resume];
    }
    return self;
}

- (void)showAlert
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"An Error Occured"
                          message:@"Unable to load categories."
                          delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil];
    
    [alert show];
}

@end
