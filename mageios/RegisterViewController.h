//
//  RegisterViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 10/04/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface RegisterViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstname;
@property (weak, nonatomic) IBOutlet UITextField *lastname;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UISwitch *showPassword;

@property (weak, nonatomic) IBOutlet MBProgressHUD *loading;
@property (weak, nonatomic) UIViewController *sender;

- (IBAction)togglePassword:(id)sender;

- (IBAction)registerCustomer:(id)sender;

@end
