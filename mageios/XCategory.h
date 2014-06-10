//
//  Category.h
//  mageios
//
//  Created by KTPL - Mobile Development on 11/02/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCategory : NSObject {
    NSDictionary *data;
    NSString *url;
}

@property(nonatomic,retain)NSDictionary *data;
@property(nonatomic,retain)NSMutableArray *products;
@property(nonatomic,retain)NSArray *sub_categories;
@property(nonatomic,retain)NSDictionary *orders;
@property(nonatomic,retain)NSDictionary *filters;
@property(nonatomic,retain)NSString *hasMoreItems;
@property(nonatomic,retain)NSString *url;

- (id)initWithId:(int)cat_id;
- (id)initWithId:(int)cat_id withOffset:(int)offset withCount:(int)count;

- (void)filterBy:(NSArray *)filters sortBy:(NSString *)code direction:(NSString *)direction withOffset:(int)offset withCount:(int)count;
- (id)fetchRowsWithOffset:(int)offset withCount:(int)count;
@end
