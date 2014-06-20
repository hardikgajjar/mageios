//
//  HomeViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 05/02/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface HomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *home_banner;
@property (weak, nonatomic) IBOutlet UIScrollView *categories_placeholder;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet MBProgressHUD *loading;
@end
