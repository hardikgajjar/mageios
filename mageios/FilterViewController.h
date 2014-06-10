//
//  FilterViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 09/06/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterViewController : UITableViewController

@property(nonatomic, strong)NSString *filter_code;
@property(nonatomic, strong)NSMutableDictionary *filter_options;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)clear:(id)sender;
@end
