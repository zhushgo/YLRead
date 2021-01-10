//
//  YLReadTopView.m
//  YLRead
//
//  Created by 苏沫离 on 2017/6/29.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import "YLReadTopView.h"

@implementation YLReadTopView

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu{
    self = [super initWithReadMenu:readMenu];
    if (self) {
        [self addSubview:self.mark];
        [self addSubview:self.back];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
        
    CGFloat y = ylReadGetStatusBarHeight();
    CGFloat wh = ylReadGetNavigationBarHeight() - y;
    
    self.back.frame = CGRectMake(0, y, wh, wh);
    self.mark.frame = CGRectMake(CGRectGetWidth(self.frame) - wh, y, wh, wh);
}

#pragma mark - response click

/// 点击返回
- (void)clickBack{
    if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickBack:)]) {
        [self.readMenu.delegate readMenuClickBack:self.readMenu];
    }    
}

- (void)clickMark:(UIButton *)sender{
    if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickMark:topView:markButton:)]) {
        [self.readMenu.delegate readMenuClickMark:self.readMenu topView:self markButton:sender];
    }
}

#pragma mark - public method

/// 检查是否存在书签
- (void)checkForMark{
    NSLog(@"self.mark.selected ===== %d",self.mark.selected);
    self.mark.selected = self.readMenu.vc.readModel.isExistMark;
    NSLog(@"self.mark.selected ------ %d",self.mark.selected);
    [self updateMarkButton];
}

/// 刷新书签按钮显示状态
- (void)updateMarkButton{
    if (self.mark.selected) {
        self.mark.tintColor = kYLRead_Color_Main();
    }else{
        self.mark.tintColor = kYLRead_Color_Menu();
    }
}

#pragma mark - setter and getters

- (UIButton *)back{
    if (_back == nil) {
        // 返回
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
        button.tintColor = kYLRead_Color_Menu();
        _back = button;
    }
    return _back;
}

- (UIButton *)mark{
    if (_mark == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.contentMode = UIViewContentModeCenter;
        //改变图片颜色
        [button setImage:[[UIImage imageNamed:@"mark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickMark:) forControlEvents:UIControlEventTouchUpInside];
        button.tintColor = kYLRead_Color_Menu();
        _mark = button;
    }
    return _mark;
}


@end
