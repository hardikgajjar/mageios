//
//  Category.m
//  mageios
//
//  Created by KTPL - Mobile Development on 11/02/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "XCategory.h"
#import "Service.h"
#import "XMLDictionary.h"

@implementation XCategory {
    int parent_id, offset, count;
}

@synthesize data,url,products;

- (id)init
{
    self = [super init];
    if(self)
    {
        Service *service = [Service getInstance];
        
        // initialize variables
        if (parent_id == 0) {
            self.url = @"index.php/xmlconnect/catalog/category";
        } else if (count != 0) {
            
            // get filters
            [self getFilters:service forCategoryId:parent_id];
            
            // set url for getting products
            self.url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/catalog/category/id/%d/offset/%d/count/%d", parent_id, offset, count];
        } else {
            self.url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/catalog/category/id/%d", parent_id];
        }
        
        // get category data
        
        NSString *url_home = [service.base_url stringByAppendingString:self.url];
        NSURL *URL = [NSURL URLWithString:url_home];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *get_home_data = [session dataTaskWithRequest:request
                                                         completionHandler:
                                               ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                                   NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                                   
                                                   // fire request complete event
                                                   [[NSNotificationCenter defaultCenter]
                                                    postNotificationName:@"requestCompletedNotification"
                                                    object:self];
                                                   
                                                   if ([res valueForKeyPath:@"items"] != NULL || [res valueForKeyPath:@"products"] != NULL) {
                                                       // store data
                                                       self.data = res;
                                                       self.sub_categories = [res valueForKeyPath:@"items.item"];
                                                       
                                                       self.hasMoreItems = [res valueForKeyPath:@"category_info.has_more_items"];
                                                       
                                                       if ([res valueForKeyPath:@"products"] != NULL) {
                                                            self.products = [res valueForKeyPath:@"products.item"];
                                                       }
                                                       
                                                       // fire event
                                                       [[NSNotificationCenter defaultCenter]
                                                        postNotificationName:@"categoryDataLoadedNotification"
                                                        object:self];
                                                   } else {
                                                       NSLog(@"%@", res);
                                                       [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
                                                   }
                                                   
                                               }];
        
        [get_home_data resume];
    }
    return self;
}

- (void)getFilters:(Service *)service forCategoryId:(int)cat_id
{
    NSString *filters_url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/catalog/filters/category_id/%d", parent_id];
    filters_url = [service.base_url stringByAppendingString:filters_url];
    NSURL *URL = [NSURL URLWithString:filters_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *get_filters = [session dataTaskWithRequest:request
                                                     completionHandler:
                                           ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                               NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                               
                                               if ([res valueForKeyPath:@"orders.item"] != NULL) {
                                                   // store data
                                                   self.orders = [res valueForKeyPath:@"orders.item"];
                                               }
                                               
                                               if ([res valueForKeyPath:@"filters.item"] != NULL) {
                                                   // store data
                                                   self.filters = [res valueForKeyPath:@"filters.item"];
                                               }
                                               
                                               // fire event
                                               [[NSNotificationCenter defaultCenter]
                                                postNotificationName:@"filtersLoadedNotification"
                                                object:self];
                                               
                                           }];
    
    [get_filters resume];
}

- (id)initWithId:(int)cat_id
{
    parent_id = cat_id;
    return [self init];
}

- (id)initWithId:(int)cat_id withOffset:(int)o withCount:(int)c
{
    parent_id = cat_id;
    offset = o;
    count = c;
    return [self init];
}

- (id)fetchRowsWithOffset:(int)o withCount:(int)c
{
    offset = o;
    count = c;
    Service *service = [Service getInstance];
    
    // set url for getting products
    NSString *paging_url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/catalog/category/id/%d/offset/%d/count/%d", parent_id, offset, count];
    
    // get category data
    
    paging_url = [service.base_url stringByAppendingString:paging_url];
    NSURL *URL = [NSURL URLWithString:paging_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *get_more_rows = [session dataTaskWithRequest:request
                                                     completionHandler:
                                           ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                               NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                               
                                               if ([res valueForKeyPath:@"products"] != NULL) {

                                                   [self.products addObjectsFromArray:[res valueForKeyPath:@"products.item"]];
                                                   self.hasMoreItems = [res valueForKeyPath:@"category_info.has_more_items"];
                                                   
                                                   // fire event
                                                   [[NSNotificationCenter defaultCenter]
                                                    postNotificationName:@"moreProductsLoadedNotification"
                                                    object:self];
                                               } else {
                                                   NSLog(@"%@", res);
                                                   [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
                                               }
                                               
                                           }];
    
    [get_more_rows resume];
    return self;
}

- (void)filterBy:(NSArray *)filters sortBy:(NSString *)code direction:(NSString *)direction withOffset:(int)o withCount:(int)c
{
    // sort by this code and direction
    offset = o;
    count = c;
    
    Service *service = [Service getInstance];
    
    NSString *filter_url = [[NSString alloc] initWithFormat:@"index.php/xmlconnect/catalog/category/id/%d/", parent_id];
    
    for (NSDictionary *filter in filters) {
        for (NSDictionary *value in [filter valueForKeyPath:@"values.value"]) {
            if ([value valueForKey:@"selected"] != nil) {
                NSString *chunk = [NSString stringWithFormat:@"%@/%@/", [filter valueForKey:@"code"] , [value valueForKey:@"id"]];
                filter_url = [filter_url stringByAppendingString:chunk];
            }
        }
    }
    
    NSString *chunk = [NSString stringWithFormat:@"order_%@/%@/offset/%d/count/%d", code, direction, offset, count];
    filter_url = [filter_url stringByAppendingString:chunk];
    
    filter_url = [service.base_url stringByAppendingString:filter_url];

    NSURL *URL = [NSURL URLWithString:filter_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *apply_filter = [session dataTaskWithRequest:request
                                                  completionHandler:
                                        ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                            NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];

                                            // fire request complete event
                                            [[NSNotificationCenter defaultCenter]
                                             postNotificationName:@"requestCompletedNotification"
                                             object:self];
                                            
                                            if ([res valueForKeyPath:@"items"] != NULL || [res valueForKeyPath:@"products"] != NULL) {
                                                // store data
                                                self.data = res;

                                                if ([res valueForKeyPath:@"products"] != NULL) {
                                                    self.products = [res valueForKeyPath:@"products.item"];
                                                }

                                                // fire event
                                                [[NSNotificationCenter defaultCenter]
                                                 postNotificationName:@"categoryDataLoadedNotification"
                                                 object:self];
                                                
                                            } else {
                                                NSLog(@"%@", res);
                                                [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
                                            }
                                            
                                            
                                        }];
    
    [apply_filter resume];
}



- (void)showAlert
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"An Error Occured"
                          message:@"Category is empty."
                          delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil];
    
    [alert show];
}

@end
