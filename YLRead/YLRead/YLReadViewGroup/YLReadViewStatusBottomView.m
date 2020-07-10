//
//  YLReadViewStatusBottomView.m
//  FM
//
//  Created by 苏沫离 on 2020/7/1.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadViewStatusBottomView.h"
#import "YLReadConfigure.h"
#import "YLGlobalTools.h"


@interface YLReadBatteryView ()

@end

@implementation YLReadBatteryView

@synthesize tintColor = _tintColor;

- (instancetype)init{
    return [self initWithFrame:CGRectMake(0, 0, 25, 10)];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _batteryLevel = 0;
        self.tintColor = YLReadConfigure.shareConfigure.statusTextColor;
        [self addSubview:self.batteryLevelView];
        
        // 设置样式
        self.image = [[UIImage imageNamed:@"battery_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat scale = 20 / 25.0;
    
    CGFloat spaceW = width / 25.0 * scale;
    CGFloat spaceH = height / 10.0 * scale;
    CGFloat batteryLevelViewY = 2.1 * spaceH;
    CGFloat batteryLevelViewX = 1.4 * spaceW;
    CGFloat batteryLevelViewH = height - 3.4 * spaceH;
    CGFloat batteryLevelViewW = width * scale;
    CGFloat batteryLevelViewWScale = batteryLevelViewW / 100;
    
    // 判断电量
    float tempBatteryLevel = MAX(0, MIN(1, _batteryLevel));
    
    _batteryLevelView.frame = CGRectMake(batteryLevelViewX, batteryLevelViewY, tempBatteryLevel * 100 * batteryLevelViewWScale, batteryLevelViewH);
    _batteryLevelView.layer.cornerRadius = batteryLevelViewH * 0.125;
}


- (void)setTintColor:(UIColor *)tintColor{
    _tintColor = tintColor;
    self.batteryLevelView.backgroundColor = tintColor;
}

- (void)setBatteryLevel:(float)batteryLevel{
    _batteryLevel = batteryLevel;
    [self setNeedsLayout];
}

- (UIView *)batteryLevelView{
    if (_batteryLevelView == nil) {
        _batteryLevelView = [[UIView alloc] init];
        _batteryLevelView.layer.mask.masksToBounds = YES;
    }
    return _batteryLevelView;
}

@end







@interface YLReadViewStatusBottomView ()

@end

@implementation YLReadViewStatusBottomView

- (void)dealloc{
    [self removeTimer];
}

- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.progress];
        [self addSubview:self.timeLabel];
        [self addSubview:self.batteryView];
        
        // 初始化调用
        [self didChangeTime];
        // 添加定时器
        [self timer];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);
    // 电池
    self.batteryView.frame = CGRectMake(w - 25, (h - 10) / 2.0, 25, 10);
    // 时间
    self.timeLabel.frame = CGRectMake(CGRectGetMinX(self.batteryView.frame) - 50, 0, 50, h);
    // 进度
    self.progress.frame = CGRectMake(0, 0, 50, h);
}

/// 时间变化
- (void)didChangeTime{
    self.timeLabel.text = getTimeByFormat(@"HH:mm", NSDate.date);
    self.batteryView.batteryLevel = UIDevice.currentDevice.batteryLevel;
}

/// 删除定时器
- (void)removeTimer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - setter and getters
/// 进度
- (UILabel *)progress{
    if (_progress == nil) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = YLReadConfigure.shareConfigure.statusTextColor;
        label.textAlignment = NSTextAlignmentLeft;
        _progress = label;
    }
    return _progress;
}

// 电池
- (YLReadBatteryView *)batteryView{
    if (_batteryView == nil) {
        _batteryView = [[YLReadBatteryView alloc] initWithFrame:CGRectMake(0, 0, 25, 10)];
    }
    return _batteryView;
}

/// 时间
- (UILabel *)timeLabel{
    if (_timeLabel == nil) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = YLReadConfigure.shareConfigure.statusTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        _timeLabel = label;
    }
    return _timeLabel;
}

- (NSTimer *)timer{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(didChangeTime) userInfo:nil repeats:YES];
        [NSRunLoop.currentRunLoop addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end
