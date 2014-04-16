//
//  CartViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 10/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CartViewController : UITableViewController <UIActionSheetDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MBProgressHUD *loading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkout_btn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *edit_btn;

- (IBAction)showCheckoutOptions:(id)sender;
- (IBAction)editCart:(id)sender;


@end
