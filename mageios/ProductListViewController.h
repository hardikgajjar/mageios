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

@property(strong, nonatomic)NSDictionary *current_category;
@property(strong, nonatomic)NSArray *products;
@property(strong, nonatomic)NSArray *orders;
@property(strong, nonatomic)NSArray *filters;
@property (weak, nonatomic) IBOutlet MBProgressHUD *loading;
- (IBAction)changeSortDirection:(id)sender;

@end
