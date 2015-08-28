//
//  CharacterStatsViewController.h
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/7/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CharacterStatsViewController : UITableViewController

@property (nonatomic, retain) NSDictionary *statsDictionary;

- (void)updateTableHeaderView;

@end
