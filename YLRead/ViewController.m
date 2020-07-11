//
//  ViewController.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/10.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#define SLog(format, ...) printf("class: <%p %s:(%d) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )



#import "ViewController.h"
#import "YLReadTextParser.h"
#import "YLReadController.h"
#import "NSString+HTML.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [NSString getMUSehnJi];
    
    NSURL *url = [NSBundle.mainBundle URLForResource:@"北颂_2" withExtension:@"txt"];
    [YLReadTextParser parserWithURL:url completion:^(YLReadModel * _Nonnull readModel) {
        if (readModel) {
            YLReadController *readVC = [[YLReadController alloc] init];
            readVC.readModel = readModel;
            [self.navigationController pushViewController:readVC animated:YES];
        }
    }];

}

@end

