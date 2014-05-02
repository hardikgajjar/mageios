//
//  SelectOptionsViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 14/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectOptionsViewController;

@protocol SelectOptionsViewDelegate <NSObject>
- (void)addItemViewController:(SelectOptionsViewController *)controller didFinishEnteringItem:(NSArray *)options withAddToCart:(BOOL)addToCart;
@end

@interface SelectOptionsViewController : UITableViewController <UITextFieldDelegate>

@property(strong, nonatomic)NSArray *options;
@property (nonatomic, weak) id <SelectOptionsViewDelegate> delegate;

- (IBAction)addToCart:(id)sender;
@end
