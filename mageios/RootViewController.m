//
//  RootViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 12/04/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "RootViewController.h"
#import "UIColor+CreateMethods.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setTabBarAppearance];
}

- (void)setTabBarAppearance
{
    // set tabbar color
    //[[UITabBar appearance] setTintColor:[UIColor colorWithHex:@"#f1f1f1" alpha:1.0]];
    // background color
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithHex:@"#f1f1f1" alpha:1.0]];
    
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tab-active.jpg"]];
    
    UITabBarItem *tabBarItem = [[self.tabBar items] objectAtIndex:0];
    [tabBarItem setTitle:nil];
    tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    [tabBarItem setImage: [[UIImage imageNamed:@"tab-home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem setSelectedImage: [[UIImage imageNamed:@"tab-home-active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    tabBarItem = [[self.tabBar items] objectAtIndex:1];
    [tabBarItem setTitle:nil];
    tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    [tabBarItem setImage: [[UIImage imageNamed:@"tab-shop"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem setSelectedImage: [[UIImage imageNamed:@"tab-shop-active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    tabBarItem = [[self.tabBar items] objectAtIndex:2];
    [tabBarItem setTitle:nil];
    tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    [tabBarItem setImage: [[UIImage imageNamed:@"tab-cart"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem setSelectedImage: [[UIImage imageNamed:@"tab-cart-active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    tabBarItem = [[self.tabBar items] objectAtIndex:3];
    [tabBarItem setTitle:nil];
    tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    [tabBarItem setImage: [[UIImage imageNamed:@"tab-about"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem setSelectedImage: [[UIImage imageNamed:@"tab-about-active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    //if (tabBarController.selectedIndex == 2) {
        [(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
    //}
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
