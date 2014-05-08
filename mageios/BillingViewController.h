//
//  BillingViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 12/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface BillingViewController : UITableViewController

@property(strong, nonatomic)NSDictionary *data;
@property (weak, nonatomic) IBOutlet MBProgressHUD *loading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *continueBtn;

- (IBAction)saveDefaultAddress:(id)sender;

@end
