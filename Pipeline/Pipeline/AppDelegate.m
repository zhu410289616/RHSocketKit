//
//  AppDelegate.m
//  Pipeline
//
//  Created by zhuruhong on 2019/9/8.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import "AppDelegate.h"

#import "RHTcpServer.h"

#import "RHTabBarViewController.h"
#import "RHHomeViewController.h"
#import "RHAboutViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) RHTcpServer *echoServer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _echoServer = [[RHTcpServer alloc] init];
    
    // 界面
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self createTabBarController];
    
    return YES;
}

- (void)createTabBarController {
    RHTabBarViewController *tabBarViewController = [[RHTabBarViewController alloc] init];

    // home
    RHHomeViewController *home = [[RHHomeViewController alloc] init];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:home];
    homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:0];
    
    // about
    RHAboutViewController *about = [[RHAboutViewController alloc] init];
    UINavigationController *aboutNav = [[UINavigationController alloc] initWithRootViewController:about];
    aboutNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"About" image:nil tag:0];

    // window root controller
    tabBarViewController.viewControllers = @[homeNav, aboutNav];
    self.window.rootViewController = tabBarViewController;
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [_echoServer stopTcpServer];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [_echoServer startTcpServer];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
