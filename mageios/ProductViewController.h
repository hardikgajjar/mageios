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
#import "SelectOptionsViewController.h"

@interface ProductViewController : UITableViewController <UIAlertViewDelegate, SelectOptionsViewDelegate>

@property(weak, nonatomic)NSDictionary *current_product;
@property (weak, nonatomic) IBOutlet MBProgressHUD *loading;
@property (strong, nonatomic) IBOutlet NSArray *productOptions;

@property (weak, nonatomic) IBOutlet UIImageView *product_image;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *stock_status;
@property (weak, nonatomic) IBOutlet UITextView *short_desc;
@property (weak, nonatomic) IBOutlet ASStarRatingView *ratings;
@property (weak, nonatomic) IBOutlet UILabel *reviewCount;
@property (weak, nonatomic) IBOutlet UILabel *reviewText;
@property (weak, nonatomic) IBOutlet UITextField *qty;

@property (weak, nonatomic) IBOutlet UIButton *selectOptions;
@property (weak, nonatomic) IBOutlet UIButton *addToCart;
@property (weak, nonatomic) IBOutlet UIView *front_demo_btn;
@property (weak, nonatomic) IBOutlet UITableViewCell *back_demo_btn;


- (IBAction)addToCart:(id)sender;
@end
