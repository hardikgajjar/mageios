//
//  Utility.m
//  mageios
//
//  Created by KTPL - Mobile Development on 11/04/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "Utility.h"
#import "MenuViewController.h"
#import "PPRevealSideViewController.h"

static UIViewController *self_vc = nil;

@implementation Utility

- (void)addLeftMenu:(UIViewController *)vc
{
    UIImage *image = [UIImage imageNamed:@"menu-btn"];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(showLeft)];
    self_vc = vc;
    vc.navigationItem.leftBarButtonItem = left;
}

- (void)showLeft
{
    MenuViewController *leftMenu = (MenuViewController*)[self_vc.storyboard
                                                         instantiateViewControllerWithIdentifier: @"MenuViewController"];
    PPRevealSideViewController *t = (PPRevealSideViewController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [t pushViewController:leftMenu onDirection:PPRevealSideDirectionLeft withOffset:70.0 animated:YES completion:nil];
}

@end
