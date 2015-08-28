//
//  GADMasterViewController.h
//  Aion Status
//
//  Created by Thomas Hajcak on 10/6/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "GADBannerView.h"

@interface GADMasterViewController : UIViewController <GADBannerViewDelegate>

+ (GADMasterViewController *)sharedInstance;
- (void)resetAdView:(UIViewController *)rootViewController;

@end
