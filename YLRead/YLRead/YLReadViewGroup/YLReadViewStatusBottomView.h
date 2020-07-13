//
//  YLReadViewStatusBottomView.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/1.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
///电池
@interface YLReadBatteryView : UIImageView
/// 颜色
//@property (nonatomic ,strong) UIColor *tintColor;
/// BatteryLevel
@property (nonatomic ,assign) float batteryLevel;
/// BatteryLevelView
@property (nonatomic ,strong) UIView *batteryLevelView;
@end



@interface YLReadViewStatusBottomView : UIView

/// 进度
@property (nonatomic ,strong) UILabel *progress;

/// 电池
@property (nonatomic ,strong) YLReadBatteryView *batteryView;

/// 时间
@property (nonatomic ,strong) UILabel *timeLabel;

/// 计时器
@property (nonatomic ,strong) NSTimer *timer;

/// 删除定时器
- (void)removeTimer;

@end

NS_ASSUME_NONNULL_END
