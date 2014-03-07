//
//  ProductViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 06/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ASStarRatingView.h"

@interface ProductViewController : UITableViewController

@property(weak, nonatomic)NSDictionary *current_product;
@property (weak, nonatomic) IBOutlet MBProgressHUD *loading;

@property (weak, nonatomic) IBOutlet UIImageView *product_image;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *stock_status;
@property (weak, nonatomic) IBOutlet UITextView *short_desc;

@end
