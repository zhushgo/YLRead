//
//  AppDelegate.m
//  YLRead
//
//  Created by 苏沫离 on 2017/7/10.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "NSString+TypeseHelper.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    ViewController *vc = [[ViewController alloc]init];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:vc];
    return YES;
}

@end
