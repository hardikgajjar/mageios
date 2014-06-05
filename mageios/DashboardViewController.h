//
//  DashboardViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 27/05/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface DashboardViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MBProgressHUD *loading;

- (IBAction)save:(id)sender;

@end
