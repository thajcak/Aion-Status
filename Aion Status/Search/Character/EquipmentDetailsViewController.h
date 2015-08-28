//
//  EquipmentDetailsViewController.h
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/8/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EquipmentDetailsViewController : UITableViewController

@property (nonatomic, retain) NSDictionary *pieceDictionary;
@property (nonatomic, retain) NSString *characterId;
@property (nonatomic, retain) NSString *serverId;

@end
