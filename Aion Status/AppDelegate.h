//
//  AppDelegate.h
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/10/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP_DELEGATE        ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define USER_DEFAULTS       [NSUserDefaults standardUserDefaults]

#define COMMON_COLOR        [UIColor colorWithHexString:@"#CCCCCC"]
#define RARE_COLOR          [UIColor colorWithHexString:@"#46CC39"]
#define LEGEND_COLOR        [UIColor colorWithHexString:@"#44D5FF"]
#define UNIQUE_COLOR        [UIColor colorWithHexString:@"#FC0"]
#define EPIC_COLOR          [UIColor colorWithHexString:@"#F79646"]


@class AionOnlineEngine, AionOnlineStaticEngine, SimpleInkEngine;
@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) AionOnlineEngine *aionOnlineEngine;
@property (strong, nonatomic) AionOnlineStaticEngine *aionOnlineStaticEngine;
@property (strong, nonatomic) SimpleInkEngine *simpleInkEngine;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
