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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // set tabbar color
    [[UITabBar appearance] setTintColor:[UIColor colorWithHex:@"#f47727" alpha:1.0]];
    // background color
    //[[UITabBar appearance] setBarTintColor:[UIColor colorWithHex:@"#efeff4" alpha:1.0]];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    
//    UITabBarItem *tabBarItem = [[self.tabBar items] objectAtIndex:1];
//    
//    UIImage *unselectedImage = [UIImage imageNamed:@"icon-unselected"];
//    UIImage *selectedImage = [UIImage imageNamed:@"icon-selected"];
//    
//    [tabBarItem setImage: [unselectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//    [tabBarItem setSelectedImage: selectedImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
