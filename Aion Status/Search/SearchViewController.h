//
//  SearchViewController.h
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/10/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kCharacterSearch,
    kLegionSearch
} searchTypeList;

@interface SearchViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) searchTypeList searchType;

@property (nonatomic) BOOL isSelectingCharacter;
@property (nonatomic, strong) UIViewController *originViewController;

- (void)showServerSelectionView;

@end
