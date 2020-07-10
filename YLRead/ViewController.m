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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    NSURL *url = [NSBundle.mainBundle URLForResource:@"求魔" withExtension:@"txt"];
    [YLReadTextParser parserWithURL:url completion:^(YLReadModel * _Nonnull readModel) {
        if (readModel) {
            YLReadController *readVC = [[YLReadController alloc] init];
            readVC.readModel = readModel;
            [self.navigationController pushViewController:readVC animated:YES];
        }
    }];

}


@end

