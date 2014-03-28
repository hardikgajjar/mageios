//
//  NewAddressViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 22/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SelectFromListViewController.h"

@interface NewAddressViewController : UITableViewController <SelectFromListViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MBProgressHUD *loading;
- (IBAction)goNext:(id)sender;

@end
