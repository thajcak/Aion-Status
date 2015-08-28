//
//  ServerSelectionViewController.h
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/11/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kSearchServers,
    kAbyssServers
} serverListType;

@interface ServerSelectionViewController : UITableViewController

@property (nonatomic) serverListType serverList;

@end
