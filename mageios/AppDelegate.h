//
//  AppDelegate.h
//  mageios
//
//  Created by KTPL - Mobile Development on 05/02/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "PPRevealSideViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, PPRevealSideViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PPRevealSideViewController *revealSideViewController;

@end
