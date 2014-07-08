//
//  Core.m
//  mageios
//
//  Created by KTPL - Mobile Development on 11/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "Core.h"

@implementation Core

+ (NSData*)encodeDictionary:(NSDictionary*)dictionary {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if ([[dictionary objectForKey:key] isKindOfClass:[NSMutableArray class]]) {
            for (NSString *eachValue in [dictionary objectForKey:key]) {
                NSString *encodedValue = [eachValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
                [parts addObject:part];
            }
        } else {
            NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
            [parts addObject:part];
        }
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSArray *)indexLettersForStrings:(NSArray *)strings {
    NSMutableArray *letters = [NSMutableArray array];
    NSString *currentLetter = nil;
    for (NSString *string in strings) {
        if (string.length > 0) {
            NSString *letter = [string substringToIndex:1];
            if (![letter isEqualToString:currentLetter]) {
                [letters addObject:letter];
                currentLetter = letter;
            }
        }
    }
    return [NSArray arrayWithArray:letters];
}

+ (NSDictionary *)objectsByCharacters:(NSArray *)objects {
    NSMutableDictionary *objectsForCharacters = [NSMutableDictionary dictionary];
    for (NSDictionary *obj in objects) {
            NSString *letter = [[obj valueForKey:@"label"] substringToIndex:1];
            if ([objectsForCharacters valueForKey:letter] != nil) {
                [[objectsForCharacters valueForKey:letter] addObject:obj];
            } else {
                [objectsForCharacters setObject:[NSMutableArray arrayWithObjects:obj, nil] forKey:letter];
            }
    }
    return objectsForCharacters;
}

@end
