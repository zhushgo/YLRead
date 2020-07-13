//
//  YLReadBaseView.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/28.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadBaseView.h"
#import "YLReadConfigure.h"
#import "YLReadMenu.h"

@implementation YLReadBaseView

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = kYLRead_Color_MenuBG();
        self.readMenu = readMenu;
    }
    return self;
}

@end
