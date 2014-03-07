//
//  CategoryViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 11/02/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CategoryViewController : UICollectionViewController

@property(weak, nonatomic)NSDictionary *current_category;
@property(weak, nonatomic)NSDictionary *parent_category;
@property(weak, nonatomic) IBOutlet MBProgressHUD *loading;

@end
