//
//  Config.h
//  mageios
//
//  Created by KTPL - Mobile Development on 06/02/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Service : NSObject {
    NSString *base_url, *url_init;
    NSDictionary *config_data;
    BOOL initialized;
}

@property(nonatomic,retain)NSString *base_url;
@property(nonatomic,retain)NSString *url_init;
@property(nonatomic,retain)NSDictionary *config_data;
@property(assign)BOOL initialized;

+(Service *)getInstance;
@end
