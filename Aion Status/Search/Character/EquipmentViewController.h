//
//  EquipmentViewController.h
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/7/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EquipmentViewController : UITableViewController

@property (nonatomic, retain) NSDictionary *equipmentDictionary;
@property (nonatomic, retain) NSString *characterId;
@property (nonatomic, retain) NSString *serverId;

@property (nonatomic, retain) UIViewController *characterViewController;

@end
