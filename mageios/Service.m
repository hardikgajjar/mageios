//
//  Config.m
//  mageios
//
//  Created by KTPL - Mobile Development on 06/02/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "Service.h"
#import "Customer.h"
#import "XMLDictionary.h"

@implementation Service

@synthesize base_url, url_init,initialized, config_data;
static Service *instance =nil;

+(Service *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [Service new];
        }
    }
    return instance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        // initialize variables
        //self.base_url = @"http://10.16.16.78:8888/magento-1.8/";
        //self.base_url = @"http://www.magedelight.com/beta/";
        self.base_url = @"http://www.magedelight.com/";

        self.url_init = [base_url stringByAppendingString:@"index.php/xmlconnect/configuration/index/app_code/defiph1/screen_size/320%C3%97480"];
        self.initialized = FALSE;

        // initialize magento
        NSURL *URL = [NSURL URLWithString:self.url_init];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *init = [session dataTaskWithRequest:request
                                                completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                          
                                          NSDictionary *res = [NSDictionary dictionaryWithXMLData:data];
                                          
                                          if ([res valueForKeyPath:@"cacheLifetime"] != NULL) {
                                              // store data
                                              self.initialized = TRUE;
                                              self.config_data = res;
                                              
                                              // fire event
                                              [[NSNotificationCenter defaultCenter]
                                               postNotificationName:@"serviceNotification"
                                               object:self];
                                              
                                              // init customer to find if is logged In.
                                              Customer *customer = [Customer getInstance];
                                          } else {
                                              [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
                                          }
                                      }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [init resume];
        
    }
    return self;
}

- (void)showAlert
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"An Error Occured"
                          message:@"Unable to connect with Remote Server."
                          delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Dismiss", nil];
    
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // close app
    if (buttonIndex == 0) {
        //home button press programmatically
        UIApplication *app = [UIApplication sharedApplication];
        [app performSelector:@selector(suspend)];
        
        //wait 2 seconds while app is going background
        [NSThread sleepForTimeInterval:2.0];
        
        //exit app when app is in background
        exit(0);
    }
}

@end
