//
//  Home.h
//  mageios
//
//  Created by KTPL - Mobile Development on 08/02/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Home : NSObject {
    NSDictionary *data;
    NSString *url;
}

@property(nonatomic,retain)NSDictionary *data;
@property(nonatomic,retain)NSString *url;

+(Home *)getInstance;

@end
