//
//  Customer.h
//  mageios
//
//  Created by KTPL - Mobile Development on 20/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Customer : NSObject

@property(assign)BOOL isLoggedIn;
@property(nonatomic,retain)NSDictionary *response;

+ (Customer *)getInstance;
- (void)login:(NSDictionary *)data;
- (void)logout;
- (void)saveBillingAddress:(NSDictionary *)data;
- (void)save:(NSDictionary *)data;
- (void)getAccountInformationForm;
- (void)saveAccountData:(NSDictionary *)data withActionUrl:(NSString *)url;

@end
