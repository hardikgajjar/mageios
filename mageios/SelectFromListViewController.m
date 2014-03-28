//
//  SelectFromListViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 22/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "SelectFromListViewController.h"
#import "Core.h"

@interface SelectFromListViewController ()

@end

@implementation SelectFromListViewController {
    NSArray *arrayOfCharacters;
    NSDictionary *objectsForCharacters;
}

@synthesize options,filteredOptions,searchBar;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // prepare array of letters
    NSMutableArray *labels = [[NSMutableArray alloc] init];
    for (NSDictionary *item in self.options) {
        [labels addObject:[item valueForKey:@"label"]];
    }
    arrayOfCharacters = [Core indexLettersForStrings:labels];
    objectsForCharacters = [Core objectsByCharacters:self.options];
    
    self.filteredOptions = [NSMutableArray arrayWithCapacity:[self.options count]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return arrayOfCharacters.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:section]] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    // Return table index
    return arrayOfCharacters;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    // Match the section titls with the sections
    NSInteger count = 0;
    
    // Loop through the array of characters
    for (NSString *character in arrayOfCharacters) {
        
        if ([character isEqualToString:title]) {
            return count;
        }
        count ++;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [arrayOfCharacters objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"fieldCell"];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"fieldCell" forIndexPath:indexPath];
    }
    
    // Configure the cell...
    NSDictionary *field = [[objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

    cell.textLabel.text = [field valueForKey:@"label"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *field = [[objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    // pass selected value back to delegate controller
    [self.delegate selectItemViewController:self didFinishSelectingItem:field];
    
    // go back
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

#pragma mark Content Filtering

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredOptions removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.label contains[c] %@",searchText];
    filteredOptions = [NSMutableArray arrayWithArray:[options filteredArrayUsingPredicate:predicate]];
    
    // refresh other arrays too
    NSMutableArray *labels = [[NSMutableArray alloc] init];
    for (NSDictionary *item in filteredOptions) {
        [labels addObject:[item valueForKey:@"label"]];
    }
    arrayOfCharacters = [Core indexLettersForStrings:labels];
    objectsForCharacters = [Core objectsByCharacters:filteredOptions];
}

#pragma mark - UISearchDisplayController Delegate Methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
