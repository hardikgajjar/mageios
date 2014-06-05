//
//  Order.h
//  mageios
//
//  Created by KTPL - Mobile Development on 28/05/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Order : NSObject

@property(nonatomic,retain)NSDictionary *response;

+ (Order *)getInstance;
- (void)getOrderList;

@end
