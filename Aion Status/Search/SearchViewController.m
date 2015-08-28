//
//  SearchViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/10/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "SearchViewController.h"
#import "ServerSelectionViewController.h"
#import "CharacterViewController.h"
#import "LegionViewController.h"

#import "AionOnlineEngine.h"
#import "AionOnlineStaticEngine.h"
#import "Server.h"

@interface SearchViewController ()
{
    UIBarButtonItem *_searchTypeSwitchButton;
    UISearchBar *_searchBar;
    UITableView *_tableView;
    
    UIView *_overlay;
    
    NSArray *_searchResults;
    
    Server *_selectedServer;
    
    CoreDataStore *_dataStore;
    MKNetworkOperation *_searchOperation;
    
    NSMutableCharacterSet *_lettersOnly;
}

@end

@implementation SearchViewController

@synthesize searchType = _searchType;

@synthesize isSelectingCharacter = _isSelectingCharacter;
@synthesize originViewController = _originViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Search"];
        
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [_searchBar setBackgroundColor:[UIColor clearColor]];
        [_searchBar setDelegate:self];
        [_searchBar setShowsBookmarkButton:YES];
        
        _dataStore = [CoreDataStore createStore];
        
        if ([USER_DEFAULTS objectForKey:@"searchType"] == nil) {
            [USER_DEFAULTS setInteger:kCharacterSearch forKey:@"searchType"];
            [USER_DEFAULTS synchronize];
        }
        
        _searchType = [USER_DEFAULTS integerForKey:@"searchType"];
        
        UIBarButtonItem *selectServerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"globe_2.png"]
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:SEL(showServerSelectionView)];
        [self.navigationItem setLeftBarButtonItem:selectServerButton];
        
        _isSelectingCharacter = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitleView:_searchBar];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, self.navigationController.view.height-44-20-(DID_PAY_PREMIUM ? 0 : 50)) style:UITableViewStylePlain];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [self.view addSubview:_tableView];
    
    _overlay = [[UIView alloc] initWithFrame:_tableView.frame];
    [_overlay setBackgroundColor:[UIColor blackColor]];
    [_overlay setAlpha:0];
    [_overlay setUserInteractionEnabled:NO];
    [self.view insertSubview:_overlay belowSubview:_searchBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _selectedServer = [Server firstWithKey:@"isSelectedSearch" value:BOX_BOOL(YES) inStore:_dataStore];
    
    if (_selectedServer == nil) {
        _selectedServer = [Server firstWithKey:@"id" value:@"0"];
    }
    [_searchBar setPlaceholder:[NSString stringWithFormat:@"Searching %@", _selectedServer.name]];
    
    if (_isSelectingCharacter) {
//        [_searchBar setScopeButtonTitles:nil];
        [_searchBar setShowsBookmarkButton:NO];
        _searchType = kCharacterSearch;
    }
    
    if ([userDefaults boolForKey:didPayPremium]) {
        
    } else {
        [[GADMasterViewController sharedInstance] resetAdView:self];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

//- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 44.0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *sectionHeader = [[UIView alloc] initWithFrame:_searchBar.frame];
//    [sectionHeader addSubview:_searchBar];
//    
//    return sectionHeader;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        IBHTMLLabel *nameLabel = [[IBHTMLLabel alloc] initWithFrame:RECT_INSET_BY_LEFT_RIGHT(cell.contentView.frame, 36, 20)];
        [nameLabel setUserInteractionEnabled:NO];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextColor:[UIColor blackColor]];
        [nameLabel setTag:100];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *detailsLabel = [[UILabel alloc] initWithFrame:RECT_INSET_BY_LEFT_TOP_RIGHT_BOTTOM(cell.contentView.frame, 44, 25, 20, 0)];
        [detailsLabel setFont:[UIFont systemFontOfSize:10]];
        [detailsLabel setBackgroundColor:[UIColor clearColor]];
        [detailsLabel setTextColor:[UIColor darkGrayColor]];
        [detailsLabel setTag:101];
        [cell.contentView addSubview:detailsLabel];
        
        UIImageView *characterImage = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 39, 39)];
        [characterImage setContentMode:UIViewContentModeScaleAspectFit];
        [characterImage setTag:110];
        [cell.contentView addSubview:characterImage];
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView setCenter:characterImage.center];
        [activityView setTag:120];
        [cell.contentView insertSubview:activityView belowSubview:characterImage];
    }
    
    // reset all the values so nothing will be stale
    
    IBCoreTextLabel *nameLabel = (IBCoreTextLabel *)[cell viewWithTag:100];
    [nameLabel setText:nil];
    
    UILabel *detailsLabel = (UILabel *)[cell viewWithTag:101];
    [detailsLabel setText:nil];
    
    UIImageView *characterImage = (UIImageView *)[cell viewWithTag:110];
    [characterImage setImage:nil];
    
    UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[cell viewWithTag:120];
    [activityView startAnimating];
    [activityView setHidesWhenStopped:YES];
    
    // set the actual values for the results
    
    NSDictionary *resultDictionary = [_searchResults objectAtIndex:indexPath.row];
    
    switch (_searchType) {
        case kCharacterSearch:
        {
            [nameLabel setText:[resultDictionary valueForKey:@"name"]];
            [detailsLabel setText:[NSString stringWithFormat:@"Level %@ %@ %@%@", 
                                   [resultDictionary valueForKey:@"level"], 
                                   [resultDictionary valueForKey:@"race_name"], 
                                   [resultDictionary valueForKey:@"class_name"],
                                   ([_selectedServer.id integerValue] == 0 ? [NSString stringWithFormat:@" of %@", [resultDictionary valueForKey:@"server_name"]] : @"")]];
            
            NSURL *imageURL = [NSURL URLWithString:[resultDictionary valueForKey:@"image"]];
            [APP_DELEGATE.aionOnlineStaticEngine imageAtURL:imageURL
                                                      onCompletion:^(UIImage *fetchedImage, NSURL *fetchUrl, BOOL isInCache) {
                                                          if (imageURL == fetchUrl) {
                                                              if (isInCache) {
                                                                  [characterImage setImage:fetchedImage];
                                                              }
                                                              else {
                                                                  [characterImage setAlpha:0];
                                                                  [characterImage setImage:fetchedImage];
                                                                  [UIView animateWithDuration:0.4
                                                                                   animations:^{
                                                                                       [characterImage setAlpha:1];
                                                                                   }];
                                                                  [activityView stopAnimating];
                                                              }
                                                          }
                                                      }];
            break;
        }
        case kLegionSearch:
        {
            [nameLabel setText:[resultDictionary valueForKey:@"legion_name"]];
            [detailsLabel setText:[NSString stringWithFormat:@"Level %@ %@ Legion with %@ members",
                                   [resultDictionary valueForKey:@"level"],
                                   [resultDictionary valueForKey:@"race_name"],
                                   [resultDictionary valueForKey:@"user_count"]]];
            switch ([[resultDictionary valueForKey:@"race_id"] integerValue]) {
                case 0:
                    [characterImage setImage:[UIImage imageNamed:@"Elyos.png"]];
                    break;
                case 1:
                    [characterImage setImage:[UIImage imageNamed:@"Asmodian.png"]];
                    break;
            }
            [activityView stopAnimating];
            break;
        }
    }
    
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *resultDictionary = [_searchResults objectAtIndex:indexPath.row];
    
    if (_isSelectingCharacter) {
        
    }
    else {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:nil
                                                                      action:nil];
        [self.navigationItem setBackBarButtonItem:backButton];
        
        switch (_searchType) {
            case kCharacterSearch:
            {
                CharacterViewController *cVC = [[CharacterViewController alloc] init];
                [cVC setHidesBottomBarWhenPushed:YES];
                
                [cVC setServerId:[[resultDictionary valueForKey:@"server_id"] integerValue]];
                [cVC setCharacterId:[resultDictionary valueForKey:@"char_id"]];
                
                [self.navigationController pushViewController:cVC animated:YES];
                break;
            }   
            case kLegionSearch:
            {
                LegionViewController *lVC = [[LegionViewController alloc] init];
                [lVC setHidesBottomBarWhenPushed:YES];
                
                [lVC setServerId:[[resultDictionary valueForKey:@"server_id"] integerValue]];
                [lVC setLegionId:[resultDictionary valueForKey:@"legion_id"]];
                
                [self.navigationController pushViewController:lVC animated:YES];
                break;
            }
        }
    }
}

#pragma mark - Search Bar Delegate

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];

    [_overlay setAlpha:0.0f];
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [_overlay setAlpha:0.0];
                     }
                     completion:^(BOOL finished) {}];
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    [_overlay setUserInteractionEnabled:YES];
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [_overlay setAlpha:0.8];
                     }
                     completion:^(BOOL finished) {}];

    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self closeSearchDisplay];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    [self closeSearchDisplay];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    switch (_searchType) {
        case kCharacterSearch:
        {
            _searchOperation = [APP_DELEGATE.aionOnlineEngine searchForCharacterNamed:_searchBar.text 
                                                                                    onServer:[_selectedServer.id integerValue]
                                                                                onCompletion:^(NSArray *resultsArray) {
                                                                                    _searchResults = resultsArray;
                                                                                    [_tableView reloadData];
                                                                                }
                                                                                     onError:^(NSError *error) {
                                                                                         [IBAlertView  showAlertWithTitle:[error domain]
                                                                                                                  message:[error localizedDescription]
                                                                                                             dismissTitle:@"Okay"
                                                                                                             dismissBlock:^{}];
                                                                                     }];
            break;
        }   
        case kLegionSearch:
        {
            _searchOperation = [APP_DELEGATE.aionOnlineEngine searchForLegionNamed:_searchBar.text 
                                                                                    onServer:[_selectedServer.id integerValue]
                                                                                onCompletion:^(NSArray *resultsArray) {
                                                                                    _searchResults = resultsArray;
                                                                                    [_tableView reloadData];
                                                                                }
                                                                                     onError:^(NSError *error) {
                                                                                         [IBAlertView  showAlertWithTitle:[error domain]
                                                                                                                  message:[error localizedDescription]
                                                                                                             dismissTitle:@"Okay"
                                                                                                             dismissBlock:^{}];
                                                                                     }];
            break;
        }
    }
    
    [self closeSearchDisplay];
}

- (void)closeSearchDisplay
{
    [_searchBar resignFirstResponder];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        return YES;
    }
    
    if (range.length == 0) {
        if ([text rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound) {
            return NO;
        }
    }
    
    return YES;
}

//- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
//{
//    _searchType = selectedScope;
//}

#pragma mark - Search Results

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [controller.searchResultsTableView setAlpha:0.0];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [_overlay removeFromSuperview];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (searchString.length > 0) {
        [_overlay setAlpha:0.8];
        [self.view insertSubview:_overlay belowSubview:_searchBar];
    }
    else {
        [UIView animateWithDuration:0.4
                         animations:^{
                             [_overlay setAlpha:0.0];
                         }
                         completion:^(BOOL finished) {
                             [_overlay removeFromSuperview];
                         }];
    }
    
    return NO;
}

#pragma mark - Select Server

- (void)showServerSelectionView
{
    ServerSelectionViewController *ssVC = [[ServerSelectionViewController alloc] init];
    [ssVC setServerList:kSearchServers];
    
    UINavigationController *ssNC = [[UINavigationController alloc] initWithRootViewController:ssVC];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonSystemItemDone
                                                                  target:ssVC
                                                                  action:SEL(dismissModalViewControllerAnimated:)];
    [ssVC.navigationItem setLeftBarButtonItem:doneButton];
    
    [self presentModalViewController:ssNC animated:YES];
}

#pragma mark - Actions

- (void)changeSearchType
{
    switch (_searchType) {
        case kCharacterSearch:
        {
            _searchType = kLegionSearch;
            break;
        }
        case kLegionSearch:
        {
            _searchType = kCharacterSearch;
            break;
        }
    }
    
    [USER_DEFAULTS setInteger:_searchType forKey:@"searchType"];
    [USER_DEFAULTS synchronize];
    
//    [self setInterfaceForSearchAnimated:YES];
}

@end