//
//  Quote.h
//  mageios
//
//  Created by KTPL - Mobile Development on 08/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quote : NSObject

@property(nonatomic,retain)NSDictionary *response;
@property(nonatomic,retain)NSDictionary *data;

+ (Quote *)getInstance;
- (void)getData;
- (void)addToCart:(NSDictionary *)data;

@end