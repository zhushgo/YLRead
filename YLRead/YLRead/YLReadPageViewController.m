//
//  YLReadPageViewController.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/9.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadPageViewController.h"
#import "UIPageViewController+Extend.h"

// 左边上一页点击区域
#define LeftWidth (CGRectGetWidth(UIScreen.mainScreen.bounds) / 3.0)
// 右边下一页点击区域
#define RightWidth (CGRectGetWidth(UIScreen.mainScreen.bounds) / 3.0)


@interface YLReadPageViewController ()
<UIGestureRecognizerDelegate>
{
    // 自定义Tap手势
    UITapGestureRecognizer *_customTapGestureRecognizer;
}
@end

@implementation YLReadPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tapGestureRecognizerEnabled = NO;
    
    _customTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerClick:)];
    _customTapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_customTapGestureRecognizer];
}


- (void)tapGestureRecognizerClick:(UITapGestureRecognizer *)tap{
    CGPoint touchPoint = [tap locationInView:self.view];
    if (touchPoint.x < LeftWidth) { // 左边
        if (self.YLDelegate && [self.YLDelegate respondsToSelector:@selector(pageViewController:getBeforeViewController:)]) {
            [self.YLDelegate pageViewController:self getBeforeViewController:self.viewControllers.firstObject];
        }
    }else if (touchPoint.x > (CGRectGetWidth(UIScreen.mainScreen.bounds) - RightWidth)) { // 右边
        if (self.YLDelegate && [self.YLDelegate respondsToSelector:@selector(pageViewController:getAfterViewController:)]) {
            [self.YLDelegate pageViewController:self getAfterViewController:self.viewControllers.firstObject];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer{
    if ([gestureRecognizer isKindOfClass:UITapGestureRecognizer.class] &&
        [gestureRecognizer isEqual:_customTapGestureRecognizer]) {
        CGPoint touchPoint = [_customTapGestureRecognizer locationInView:self.view];
        if (touchPoint.x > LeftWidth && touchPoint.x < (CGRectGetWidth(UIScreen.mainScreen.bounds) - RightWidth)) {
            return YES;
        }
    }
    return NO;
}

@end
