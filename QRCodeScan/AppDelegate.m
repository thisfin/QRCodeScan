//
//  AppDelegate.m
//  QRCodeScan
//
//  Created by wenyou on 2016/10/8.
//  Copyright © 2016年 wenyou. All rights reserved.
//

#import "AppDelegate.h"

#import "ScanViewController.h"
#import "HistoryViewController.h"
#import "WYIconfont.h"


@interface AppDelegate ()
@end


@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.backgroundColor = [UIColor whiteColor];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[({
        ScanViewController *controller = [[ScanViewController alloc] init];
        controller.title = @"扫描";
        controller.tabBarItem.image = [WYIconfont imageWithIcon:@"\uf029" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] fontSize:24];
        controller;
    }), ({
        HistoryViewController *controller = [[HistoryViewController alloc] init];
        controller.title = @"历史";
        controller.tabBarItem.image = [WYIconfont imageWithIcon:@"\uf03a" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] fontSize:24];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
//        navController.navigationBar.barStyle = UIBarStyleBlack;
        navController;
    })];
    tabBarController.tabBar.barStyle = UIBarStyleBlack;
    tabBarController.tabBar.tintColor = [UIColor colorWithHexValue:0x8bddd1];
    
    _window.rootViewController = tabBarController;
    [_window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}
@end
