//
//  ProductListViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 21/02/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ASStarRatingView.h"

@interface ProductListViewController : UITableViewController

@property(weak, nonatomic)NSDictionary *current_category;
@property(weak, nonatomic)NSArray *products;
@property(weak, nonatomic)NSArray *orders;
@property(weak, nonatomic)NSArray *filters;
@property (weak, nonatomic) IBOutlet MBProgressHUD *loading;
- (IBAction)changeSortDirection:(id)sender;

@end
