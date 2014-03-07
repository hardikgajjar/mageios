//
//  Product.h
//  mageios
//
//  Created by KTPL - Mobile Development on 06/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property(nonatomic,retain)NSString *url;
@property(nonatomic,retain)NSDictionary *data;

- (id)initWithId:(int)product_id;

@end
