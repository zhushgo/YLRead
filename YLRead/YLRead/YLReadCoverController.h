//
//  YLReadCoverController.h
//  FM
//
//  Created by 苏沫离 on 2020/7/9.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 翻页控制器 (无效果,覆盖)


@class YLReadCoverController;

@protocol YLReadCoverControllerDelegate <NSObject>

@optional

/**
 *  切换是否完成
 *
 *  @param coverController   coverController
 *  @param currentController 当前正在显示的控制器
 *  @param isFinish          切换是否成功
 */
- (void)coverController:(YLReadCoverController * _Nonnull)coverController currentController:(UIViewController * _Nullable)currentController finish:(BOOL)isFinish;

/**
 *  将要显示的控制器
 *
 *  @param coverController   coverController
 *  @param pendingController 将要显示的控制器
 */
- (void)coverController:(YLReadCoverController * _Nonnull)coverController willTransitionToPendingController:(UIViewController * _Nullable)pendingController;

/**
 *  获取上一个控制器
 *
 *  @param coverController   coverController
 *  @param currentController 当前正在显示的控制器
 *
 *  @return 返回当前显示控制器的上一个控制器
 */
- (UIViewController * _Nullable)coverController:(YLReadCoverController * _Nonnull)coverController getAboveControllerWithCurrentController:(UIViewController * _Nullable)currentController;

/**
 *  获取下一个控制器
 *
 *  @param coverController   coverController
 *  @param currentController 当前正在显示的控制器
 *
 *  @return 返回当前显示控制器的下一个控制器
 */
- (UIViewController * _Nullable)coverController:(YLReadCoverController * _Nonnull)coverController getBelowControllerWithCurrentController:(UIViewController * _Nullable)currentController;

@end

@interface YLReadCoverController : UIViewController

/**
 *  代理
 */
@property (nonatomic,weak,nullable) id<YLReadCoverControllerDelegate> delegate;

/**
 *  手势启用状态 default:YES
 */
@property (nonatomic,assign) BOOL gestureRecognizerEnabled;

/**
 *  Tap手势启用状态 default:YES
 */
@property (nonatomic,assign) BOOL tapGestureRecognizerEnabled;

/**
 *  当前手势操作是否带动画效果 default: YES
 */
@property (nonatomic,assign) BOOL openAnimate;

/**
 *  当前控制器
 */
@property (nonatomic,strong,readonly,nullable) UIViewController *currentController;

/**
 *  手动设置显示控制器 无动画
 *
 *  @param controller 设置显示的控制器
 */
- (void)setController:(UIViewController * _Nullable)controller;

/**
 *  手动设置显示控制器
 *
 *  @param controller 设置显示的控制器
 *  @param animated   是否需要动画
 *  @param isAbove    动画是否从上面显示 YES   从下面显示 NO
 */
- (void)setController:(UIViewController * _Nullable)controller animated:(BOOL)animated isAbove:(BOOL)isAbove;

@end


NS_ASSUME_NONNULL_END
