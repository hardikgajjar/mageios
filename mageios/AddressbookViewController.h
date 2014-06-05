//
//  AddressbookViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 28/05/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface AddressbookViewController : UITableViewController

@property (weak, nonatomic) IBOutlet MBProgressHUD *loading;

@property(strong, nonatomic)NSArray *data;

@end
