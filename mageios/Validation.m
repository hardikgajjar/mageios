//
//  Validation.m
//  mageios
//
//  Created by KTPL - Mobile Development on 20/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "Validation.h"

@implementation Validation

+ (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)validatePasswordWithString:(NSString *)password
{
    if ([password length] < 6) {
        return NO;
    }
    return YES;
}

+ (BOOL)validateEmptyString:(NSString *)field
{
    if ([field length] == 0) {
        return NO;
    }
    return YES;
}

@end
