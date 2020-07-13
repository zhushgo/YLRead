//
//  UIPageViewController+Extend.h
//  YLRead
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIPageViewController (Extend)

/// 手势启用
@property (nonatomic ,assign) BOOL gestureRecognizerEnabled;

/// tap手势
@property (nonatomic ,strong) UITapGestureRecognizer *tapGestureRecognizer;

/// tap手势启用
@property (nonatomic ,assign) BOOL tapGestureRecognizerEnabled;


@end

NS_ASSUME_NONNULL_END
