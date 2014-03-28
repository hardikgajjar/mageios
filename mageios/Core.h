//
//  Core.h
//  mageios
//
//  Created by KTPL - Mobile Development on 11/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Core : NSObject

+ (NSData*)encodeDictionary:(NSDictionary*)dictionary;
+ (NSArray *)indexLettersForStrings:(NSArray *)strings;
+ (NSDictionary *)objectsByCharacters:(NSArray *)objects;

@end
