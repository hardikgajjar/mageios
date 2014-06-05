//
//  MenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "MenuViewController.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "MyAccountViewController.h"
#import "PPRevealSideViewController.h"
#import "Validation.h"
#import "Customer.h"


@implementation MenuViewController {
    Customer *customer;
}

- (void) observer:(NSNotification *) notification
{
    // perform ui updates from main thread so that they updates correctly
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(observer:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    [self.loading hide:YES];
}

- (void)addObservers
{
    // Add request completed observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"requestCompletedNotification"
                                               object:nil];
    // Add logout observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"loggedOutNotification"
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    customer = [Customer getInstance];
    
    [self addObservers];
}

#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (customer.isLoggedIn)
        return 3;
    else
        return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
	
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"Home";
            break;
            
        case 1:
            if (customer.isLoggedIn) {
                cell.textLabel.text = @"Logout";
            } else {
                cell.textLabel.text = @"Login";
            }
            break;
        case 2:
            cell.textLabel.text = @"My Account";
            break;
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITabBarController *root = (UITabBarController *)self.revealSideViewController.rootViewController;
    
	switch (indexPath.row) {
        case 0: {
            // go to home
            root.selectedIndex = 0;
            [self.revealSideViewController popViewControllerAnimated:YES];
            break;
        }
        case 1: {
            if (customer.isLoggedIn) {
            
                [self.revealSideViewController popViewControllerAnimated:YES];
                
                // show loading
                self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                self.loading.labelText = @"Loading";
                
                // logout
                [customer logout];
                
            } else {
                // go to login
                LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
                [(UINavigationController *)root.selectedViewController pushViewController:loginVC animated:YES];
                [self.revealSideViewController popViewControllerAnimated:YES];
            }
            
            break;
        }
        case 2: {
            // go to my account
            MyAccountViewController *accountVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAccountController"];
            [(UINavigationController *)root.selectedViewController pushViewController:accountVC animated:YES];
            [self.revealSideViewController popViewControllerAnimated:YES];
        }
    }
    
}

@end
