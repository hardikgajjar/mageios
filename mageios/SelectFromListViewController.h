//
//  SelectFromListViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 22/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectFromListViewController;

@protocol SelectFromListViewDelegate <NSObject>
- (void)selectItemViewController:(SelectFromListViewController *)controller didFinishSelectingItem:(NSDictionary *)value;
@end

@interface SelectFromListViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, weak) id <SelectFromListViewDelegate> delegate;

@property(strong, nonatomic)NSArray *options;

@property (strong,nonatomic) NSMutableArray *filteredOptions;
@property IBOutlet UISearchBar *searchBar;

@end
