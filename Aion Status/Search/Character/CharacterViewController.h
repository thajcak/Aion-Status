//
//  CharacterViewController.h
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/6/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import <UIKit/UIKit.h>

#define CONTAINER_WIDTH     300.0f

@interface CharacterViewController : UIViewController

@property (nonatomic) NSInteger serverId;
@property (nonatomic, retain) NSString *characterId;

@end
