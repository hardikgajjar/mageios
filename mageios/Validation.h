//
//  Validation.h
//  mageios
//
//  Created by KTPL - Mobile Development on 20/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Validation : NSObject

+ (BOOL)validateEmailWithString:(NSString*)email;
+ (BOOL)validatePasswordWithString:(NSString*)password;
+ (BOOL)validateEmptyString:(NSString *)field;

@end
