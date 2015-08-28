//
//  AbyssViewController.h
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/11/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kAbyssMap,
    kBalaureaMap
} pvpLocation;

@interface AbyssViewController : UIViewController <UIScrollViewDelegate, UIPopoverControllerDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>

@end
