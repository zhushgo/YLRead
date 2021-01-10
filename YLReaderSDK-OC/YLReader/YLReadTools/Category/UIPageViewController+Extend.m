//
//  UIPageViewController+Extend.m
//  YLRead
//
//  Created by 苏沫离 on 2017/6/24.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import "UIPageViewController+Extend.h"
#import <objc/message.h>

NSString *const IsGestureRecognizerEnabled = @"IsGestureRecognizerEnabled";
NSString *const TapIsGestureRecognizerEnabled = @"TapIsGestureRecognizerEnabled";


@implementation UIPageViewController (Extend)

/// 手势启用
- (void)setGestureRecognizerEnabled:(BOOL)gestureRecognizerEnabled{
    [self.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull gesture, NSUInteger idx, BOOL * _Nonnull stop) {
        gesture.enabled = gestureRecognizerEnabled;
    }];
    
    objc_setAssociatedObject(self, @selector(gestureRecognizerEnabled), @(gestureRecognizerEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gestureRecognizerEnabled{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/// tap手势
- (UITapGestureRecognizer *)tapGestureRecognizer{
    __block UITapGestureRecognizer *tapGestureRecognizer;
    [self.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull gesture, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([gesture isKindOfClass:UITapGestureRecognizer.class]) {
            tapGestureRecognizer = gesture;
            *stop = YES;
        }
    }];
    return tapGestureRecognizer;
}

/// tap手势启用
- (void)setTapGestureRecognizerEnabled:(BOOL)tapGestureRecognizerEnabled{
    self.tapGestureRecognizer.enabled = tapGestureRecognizerEnabled;
    objc_setAssociatedObject(self, @selector(tapGestureRecognizerEnabled), @(tapGestureRecognizerEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tapGestureRecognizerEnabled{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
