//
//  GADMasterViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak on 10/6/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "GADMasterViewController.h"

@interface GADMasterViewController ()
{
    GADBannerView *adBanner_;
    BOOL didCloseWebsiteView_;
    BOOL isLoaded_;
    id currentDelegate_;
}
@end

@implementation GADMasterViewController

+ (GADMasterViewController *)sharedInstance
{
    static dispatch_once_t pred;
    static GADMasterViewController *shared;

    dispatch_once(&pred, ^{
        shared = [[GADMasterViewController alloc] init];
    });
    return shared;
}

- (id)init
{
    if (self = [super init]) {
        adBanner_ = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0, 0.0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
        isLoaded_ = NO;
    }
    return self;
}

- (void)resetAdView:(UIViewController *)rootViewController {
    // Always keep track of currentDelegate for notification forwarding
    currentDelegate_ = rootViewController;
    
    [adBanner_ setBottom:rootViewController.view.height];
    [adBanner_ setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    
    // Ad already requested, simply add it into the view
    if (isLoaded_) {
        [rootViewController.view addSubview:adBanner_];
    } else {
        
        adBanner_.delegate = self;
        adBanner_.rootViewController = rootViewController;

        [adBanner_ setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
        
        GADRequest *request = [GADRequest request];
        [adBanner_ loadRequest:request];
        [rootViewController.view addSubview:adBanner_];
        isLoaded_ = YES;
    }
}

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    // Make sure that the delegate actually responds to this notification
    if  ([currentDelegate_ respondsToSelector:@selector(adViewDidReceiveAd:)]) {
        [currentDelegate_ adViewDidReceiveAd:view];
    }
}

@end
