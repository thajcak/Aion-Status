//
//  AppDelegate.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/10/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "AppDelegate.h"

#import "AionOnlineEngine.h"
#import "AionOnlineStaticEngine.h"
#import "SimpleInkEngine.h"

#import "ServerStatusViewController.h"
#import "AbyssViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"

#import "Setting.h"
#import "MKStoreManager.h"

#import "DCIntrospect.h"

#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

@synthesize aionOnlineEngine = _aionOnlineEngine;
@synthesize aionOnlineStaticEngine = _aionOnlineStaticEngine;
@synthesize simpleInkEngine = _simpleInkEngine;

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [userDefaults setBool:([[UIScreen mainScreen] bounds].size.height == 568 ? YES : NO) forKey:@"isiPhone5"];
    
    ServerStatusViewController *serverStatusVC = [[ServerStatusViewController alloc] init];
    UINavigationController *serverStatusNC = [[UINavigationController alloc] initWithRootViewController:serverStatusVC];
    UITabBarItem *serverStatusTBI = [[UITabBarItem alloc] initWithTitle:@"Status"
                                                                  image:[UIImage imageNamed:@"newspaper.png"]
                                                                    tag:0];
    [serverStatusNC setTabBarItem:serverStatusTBI];
    
    AbyssViewController *abyssVC = [[AbyssViewController alloc] init];
    UINavigationController *abyssNC = [[UINavigationController alloc] initWithRootViewController:abyssVC];
    UITabBarItem *abyssTBI = [[UITabBarItem alloc] initWithTitle:@"PvP"
                                                           image:[UIImage imageNamed:@"worldIcon.png"]
                                                             tag:0];
    [abyssNC setTabBarItem:abyssTBI];

    SearchViewController *searchVC = [[SearchViewController alloc] init];
    UINavigationController *searchNC = [[UINavigationController alloc] initWithRootViewController:searchVC];
    UITabBarItem *searchTBI = [[UITabBarItem alloc] initWithTitle:@"Search"
                                                            image:[UIImage imageNamed:@"zoom.png"]
                                                              tag:0];
    [searchNC setTabBarItem:searchTBI];
    
    SettingsViewController *settingsVC = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *settingsNC = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    UITabBarItem *settingsTBI = [[UITabBarItem alloc] initWithTitle:@"Settings"
                                                              image:[UIImage imageNamed:@"dashboard.png"]
                                                                tag:0];
    [settingsNC setTabBarItem:settingsTBI];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:serverStatusNC, abyssNC, searchNC, settingsNC, nil];
    
    self.window.rootViewController = self.tabBarController;
    
    _aionOnlineEngine = [[AionOnlineEngine alloc] initWithHostName:@"na.aiononline.com" customHeaderFields:nil];
    [_aionOnlineEngine useCache];
    
    _aionOnlineStaticEngine = [[AionOnlineStaticEngine alloc] initWithHostName:@"static.na.aiononline.com" customHeaderFields:nil];
    [_aionOnlineStaticEngine useCache];
    
    _simpleInkEngine = [[SimpleInkEngine alloc] initWithHostName:@"www.simpleinkdev.com" customHeaderFields:nil];
    
    Setting *userSetting = [Setting first];
    if (userSetting == nil) {
        userSetting = [Setting create];
        [[CoreDataStore mainStore] save];
    }
    
    [MKStoreManager sharedManager];
    
    [self.window makeKeyAndVisible];
    
#if TARGET_IPHONE_SIMULATOR
    [[DCIntrospect sharedIntrospector] start];
#endif
    
//    [userDefaults setBool:NO forKey:didPayPremium];
    
    [Crashlytics startWithAPIKey:@"key"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    MKNetworkOperation *op = [_simpleInkEngine getAvailableServers:^{} onError:^(NSError *error){}];
    [_simpleInkEngine enqueueOperation:op];
    
    MKNetworkOperation *alerts = [_simpleInkEngine getAlerts:^{} onError:^(NSError *error){}];
    [_simpleInkEngine enqueueOperation:alerts];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
