//
//  AppDelegate.m
//  Demo
//
//  Created by 苏沫离 on 2020/10/27.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) UINavigationController *nav;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];

    self.window.rootViewController = self.nav;
    
    return YES;
}

#pragma mark - setters and getters

- (UINavigationController *)nav{
    if (_nav == nil) {
        _nav = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc]init]];
        _nav.navigationBarHidden = YES;
    }
    return _nav;
}

@end

