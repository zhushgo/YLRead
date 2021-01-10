//
//  YLReadBaseView.m
//  YLRead
//
//  Created by 苏沫离 on 2017/6/28.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import "YLReadBaseView.h"
#import "YLReadMenu.h"

@implementation YLReadBaseView

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        /// 菜单背景颜色
        self.backgroundColor = [UIColor colorWithRed:46/255.0 green:46/255.0 blue:46/255.0 alpha:0.95];
        self.readMenu = readMenu;
    }
    return self;
}

@end
