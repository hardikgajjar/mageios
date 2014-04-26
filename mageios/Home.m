//
//  Home.m
//  mageios
//
//  Created by KTPL - Mobile Development on 08/02/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "Home.h"
#import "Service.h"
#import "XMLDictionary.h"

@implementation Home

@synthesize data,url;

static Home *instance =nil;

+(Home *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [Home new];
        }
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        // initialize variables
        self.url = @"index.php/xmlconnect/";
        
        // get remote data
        Service *service = [Service getInstance];
        
        NSString *url_home = [service.base_url stringByAppendingString:self.url];
        NSURL *URL = [NSURL URLWithString:url_home];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *get_home_data = [session dataTaskWithRequest:request
                                                         completionHandler:
                                               ^(NSData *remoteData, NSURLResponse *response, NSError *error) {
                                                   NSDictionary *res = [NSDictionary dictionaryWithXMLData:remoteData];
                                                   //NSLog(@"%@", res);
                                                   
                                                   if ([res valueForKeyPath:@"categories"] != NULL) {
                                                       // store data
                                                       self.data = res;
                                                       
                                                       // fire event
                                                       [[NSNotificationCenter defaultCenter]
                                                        postNotificationName:@"homeDataLoadedNotification"
                                                        object:self];
                                                   } else {
                                                       [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
                                                   }
                                                   
                                               }];
        
        [get_home_data resume];
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
