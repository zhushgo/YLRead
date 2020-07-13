//
//  ViewController.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/10.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "ViewController.h"
#import "YLReadTextParser.h"
#import "YLReadController.h"
#import "LingDianParser.h"

NSBundle *bookBundle(void){
    return [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:@"BookResources" ofType:@"bundle"]];
}

NSURL *bookURL(NSString *name,NSString *extension){
    return [bookBundle() URLForResource:name withExtension:extension];
}

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
//    [LingDianParser getBookAllStringByBookID:@"343014"];
    
    NSLog(@"%@", [NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()]);
        
//    [YLReadTextParser parserWithURL:bookURL(@"万族之劫", @"txt") completion:^(YLReadModel * _Nonnull readModel) {
//        if (readModel) {
//            YLReadController *readVC = [[YLReadController alloc] init];
//            readVC.readModel = readModel;
//            [self.navigationController pushViewController:readVC animated:YES];
//        }
//    }];
}

@end

