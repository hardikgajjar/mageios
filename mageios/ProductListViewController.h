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

@interface ProductListViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property(strong, nonatomic)NSDictionary *current_category;
@property(strong, nonatomic)NSArray *products;
@property(strong, nonatomic)NSArray *orders;
@property(strong, nonatomic)NSArray *filters;
@property(strong, nonatomic)NSArray *sub_categories;
@property(strong, nonatomic)NSString *selected_sub_category;
@property (weak, nonatomic) IBOutlet MBProgressHUD *loading;
- (IBAction)changeSortDirection:(id)sender;

@end
