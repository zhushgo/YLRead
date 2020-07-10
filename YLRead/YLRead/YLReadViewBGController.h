//
//  YLReadViewBGController.h
//  FM
//
//  Created by 苏沫离 on 2020/7/8.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class YLReadRecordModel;
@interface YLReadViewBGController : UIViewController
/// 当前页阅读记录
@property (nonatomic ,strong) YLReadRecordModel *recordModel;
/// 目标视图(无值则跟阅读背景颜色保持一致)
@property (nonatomic ,strong) UIView *targetView;
/// imageView
@property (nonatomic ,strong) UIImageView *imageView;

/// 方式一
- (void)funcOne;

/// 方式二
- (void)funcTwo;
@end

NS_ASSUME_NONNULL_END
