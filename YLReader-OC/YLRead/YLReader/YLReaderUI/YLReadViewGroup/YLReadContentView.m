//
//  YLReadContentView.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadContentView.h"

@interface YLReadContentView ()

/// 遮盖
@property (nonatomic ,strong) UIControl *cover;

/// 是否显示遮盖
@property (nonatomic ,assign) BOOL isShowCover;

@end

@implementation YLReadContentView

- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.cover];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.cover.frame = self.bounds;
}

#pragma mark - public method

/// 遮盖展示
- (void)showCover:(BOOL)isShow{
    if (self.isShowCover == isShow) {
        return;
    }
    if (isShow) {
        [self bringSubviewToFront:self.cover];
        self.cover.userInteractionEnabled = YES;
    }
    self.isShowCover = isShow;
    [UIView animateWithDuration:0.2 animations:^{
        self.cover.alpha = isShow;
    }];
}

#pragma mark - response click

- (void)clickCover{
    _cover.userInteractionEnabled = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewClickCover:)]) {
        [self.delegate contentViewClickCover:self];
    }
    [self showCover:NO];
}

#pragma mark - setter and getters

- (UIControl *)cover{
    if (_cover == nil) {
        _cover = [[UIControl alloc] init];
        _cover.alpha = 0;
        _cover.userInteractionEnabled = NO;
        _cover.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
        [_cover addTarget:self action:@selector(clickCover) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cover;
}

@end

