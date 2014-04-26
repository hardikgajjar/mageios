//
//  PaypalViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 04/04/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"
#import "MBProgressHUD.h"

@class PaypalViewController;

@protocol PaypalViewDelegate <NSObject>
- (void)paymentCompleteWithResponse:(PayPalPayment *)response;
@end

@interface PaypalViewController : UIViewController <PayPalPaymentDelegate>

@property(nonatomic, strong, readwrite) NSString *environment;
@property (weak, nonatomic) IBOutlet MBProgressHUD *loading;
@property (nonatomic, weak) id <PaypalViewDelegate> delegate;

@end
