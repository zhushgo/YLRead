//
//  YLReadLongPressView.h
//  YLRead
//
//  Created by 苏沫离 on 2017/5/1.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLReadView.h"

NS_ASSUME_NONNULL_BEGIN
/// Pan手势状态
typedef NS_ENUM(NSUInteger,YLPanGesStatus) {
    YLPanGesStatusBegin = 0,// 开始手势
    YLPanGesStatusChange,// 变换中
    YLPanGesStatusEnd,// 结束手势
};

/// 长按阅读视图通知
FOUNDATION_EXPORT NSString *const kYLRead_ReadMonitor_Notification;

/// 长按阅读视图通知 info 数据 key
FOUNDATION_EXPORT NSString *const kYLRead_ReadMonitor_Notification_key;


/// 监控阅读长按视图通知
FOUNDATION_EXPORT void addNotification_ReadMonitor(id target,SEL action);
/// 发送阅读长按视图通知
FOUNDATION_EXPORT void postNotification_ReadMonitor(NSDictionary *userInfo);
/// 移除阅读长按视图通知
FOUNDATION_EXPORT void removeNotification_ReadMonitor(id target);


@interface YLReadLongPressView : YLReadView

/// 开启拖拽
@property (nonatomic ,assign) BOOL isOpenDrag;

/// 解析触摸事件
- (void)dragWithStatus:(YLPanGesStatus)status touches:(NSSet<UITouch *> *)touches;

 /// 拖拽事件解析
- (void)dragWithStatus:(YLPanGesStatus)status point:(CGPoint)point windowPoint:(CGPoint)windowPoint;

/// 创建放大镜
- (void)creatMagnifierView:(CGPoint)windowPoint;

/// 隐藏或显示菜单
- (void)showMenu:(BOOL)isShow;
/// 隐藏或显示光标
- (void)cursorWithIsShow:(BOOL)isShow;
/// 更新光标位置
- (void)updateCursorFrame;
/// 刷新选中区域
- (void)updateSelectRange:(NSInteger)location;

/// 重置页面数据
- (void)reset;


@end

NS_ASSUME_NONNULL_END
