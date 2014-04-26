//
//  LoginViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 19/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface LoginViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UISwitch *showPassword;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet MBProgressHUD *loading;


- (IBAction)login:(id)sender;
- (IBAction)forgotPassword:(id)sender;
- (IBAction)togglePassword:(id)sender;
@end
