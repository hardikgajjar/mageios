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
@property(nonatomic,retain)NSDictionary *totals;
@property(assign)BOOL is_empty;


+ (Quote *)getInstance;
- (void)getData;
- (void)getTotals;
- (void)addToCart:(NSDictionary *)data;
- (void)removeItem:(NSDictionary *)data;
- (void)updateItem:(NSDictionary *)data;

@end
