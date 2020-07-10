//
//  YLReadMenu.m
//  FM
//
//  Created by 苏沫离 on 2020/6/30.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadMenu.h"
#import "YLReadController.h"
#import "YLGlobalTools.h"
#import "YLReadConfigure.h"
#import "YLReadUserDefaults.h"

#import "UINavigationController+FDFullscreenPopGesture.h"

@interface YLReadMenu ()
<UIGestureRecognizerDelegate>

@property (nonatomic ,strong) NSArray<NSString *> *classStrings;

/// 动画是否完成
@property (nonatomic ,assign) BOOL isAnimateComplete;

@end

@implementation YLReadMenu


- (instancetype)initWithVC:(YLReadController *)vc delegate:(id<YLReadMenuDelegate>)delegate{
    self = [super init];
    
    if (self) {
        _isMenuShow = NO;
        _isAnimateComplete = YES;
        // 记录
        self.vc = vc;
        self.contentView = vc.contentView;
        self.delegate = delegate;
        
        // 隐藏状态栏
        UIApplication.sharedApplication.statusBarHidden = self.isMenuShow;
        // 允许获取电量信息
        UIDevice.currentDevice.batteryMonitoringEnabled = YES;
        // 隐藏导航栏
        vc.fd_prefersNavigationBarHidden = YES;
        // 禁止手势返回
        vc.fd_interactivePopDisabled = YES;
        
        // 添加单机手势
        [vc.contentView addGestureRecognizer:self.singleTap];
        // 初始化日夜间遮盖
        [vc.view addSubview:self.cover];
        self.cover.frame = vc.view.bounds;
        // 初始化TopView
        [self.contentView addSubview:self.topView];
        // 初始化SettingView
        [self.contentView addSubview:self.settingView];
        // 初始化BottomView
        [self.contentView addSubview:self.bottomView];
    }
    
    return self;
}

#pragma mark - public method

// MARK: 菜单展示
- (void)showMenuWithIsShow:(BOOL)isShow{
    if (_isMenuShow == isShow || !_isAnimateComplete) {
       return;
    }
    _isAnimateComplete = NO;
    if (isShow) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuWillDisplay:)]) {
            [self.delegate readMenuWillDisplay:self];
        }
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuWillEndDisplay:)]) {
            [self.delegate readMenuWillEndDisplay:self];
        }
    }
    _isMenuShow = isShow;
    
    [self showBottomViewWithIsShow:isShow completion:^{
        
    }];
    
    [self showSettingViewWithIsShow:NO completion:^{
        
    }];
    [self showTopViewWithIsShow:isShow completion:^{
        self.isAnimateComplete = YES;
        if (isShow) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuDidDisplay:)]) {
                [self.delegate readMenuDidDisplay:self];
            }
        }else{
            if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuDidEndDisplay:)]) {
                [self.delegate readMenuDidEndDisplay:self];
            }
        }
    }];
}
      
/// TopView展示
- (void)showTopViewWithIsShow:(BOOL)isShow completion:(void(^)(void))animationCompletion {

    UIApplication.sharedApplication.statusBarHidden = self.isMenuShow;
    if (isShow) {
       _topView.hidden = NO;
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGFloat y = isShow ? 0 : -getNavigationBarHeight();
        CGRect topFrame = self.topView.frame;
        topFrame.origin = CGPointMake(0, y);
        self.topView.frame = topFrame;
        
    } completion:^(BOOL finished) {
        
        if (!isShow) {
            self.topView.hidden = YES;
        }
        
        animationCompletion();
    }];
}
   
/// BottomView展示
- (void)showBottomViewWithIsShow:(BOOL)isShow  completion:(void(^)(void))animationCompletion {
    if (isShow) {
       _bottomView.hidden = NO;
    }
    [UIView animateWithDuration:0.2 animations:^{
        
        CGFloat y = isShow ? (UIScreen.mainScreen.bounds.size.height - getYLReadBottomViewHeight()) : UIScreen.mainScreen.bounds.size.height;
        CGRect topFrame = self.bottomView.frame;
        topFrame.origin = CGPointMake(0, y);
        self.bottomView.frame = topFrame;
        
    } completion:^(BOOL finished) {
        if (!isShow) {
            self.bottomView.hidden = YES;
        }
        
        animationCompletion();
    }];
}

/// SettingView展示
- (void)showSettingViewWithIsShow:(BOOL)isShow completion:(void(^)(void))animationCompletion {
    if (isShow) {
       _settingView.hidden = NO;
    }
     [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
         
         CGFloat y = isShow ? (CGRectGetHeight(UIScreen.mainScreen.bounds) - getYLReadSettingViewHeight()) : CGRectGetHeight(UIScreen.mainScreen.bounds);
         CGRect topFrame = self.settingView.frame;
         topFrame.origin = CGPointMake(0, y);
         self.settingView.frame = topFrame;
         
     } completion:^(BOOL finished) {
         if (!isShow) {
             self.settingView.hidden = YES;
         }
         animationCompletion();
     }];
}

#pragma mark - response click

/// 点击返回
- (void)clickBack:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(readMenuClickBack:)]) {
        [self.delegate readMenuClickBack:self];
    }
}

// 触发单击手势
- (void)touchSingleTap{
    [self showMenuWithIsShow:!_isMenuShow];
}

#pragma mark - UIGestureRecognizerDelegate
/// 手势拦截
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([self.classStrings containsObject:NSStringFromClass(touch.view.class)]) {
        return NO;
    }
    return YES;
}

#pragma mark - setter and getters

/// 点击这些控件不需要执行手势
- (NSArray<NSString *> *)classStrings{
    if (_classStrings == nil) {
        _classStrings = @[@"YLReadTopView",@"YLReadBottomView",@"YLReadSettingView",
                          @"YLReadSettingFontSizeView", @"YLReadSettingFontTypeView",@"YLReadSettingLightView",
                          @"YLReadSettingSpacingView",@"YLReadSettingEffectTypeView",@"YLReadSettingBGColorView",
                          @"YLReadFuncView",@"YLReadProgressView",@"UIControl",
                          @"UISlider",@"ASValueTrackingSlider"];
    }
    return _classStrings;
}

// 单击手势
- (UITapGestureRecognizer *)singleTap{
    if (_singleTap == nil) {
        _singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchSingleTap)];
        _singleTap.numberOfTapsRequired = 1;
        _singleTap.delegate = self;
    }
    return _singleTap;
}

/// 初始化日夜间遮盖
- (UIView *)cover{
    if (_cover == nil) {
        _cover = [[UIView alloc] init];
        _cover.alpha = [YLReadUserDefaults getBoolWithKey:kYLRead_Save_Day_Night];
        _cover.userInteractionEnabled = NO;
        _cover.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    }
    return _cover;
}

/// 初始化TopView
- (YLReadTopView *)topView{
    if (_topView == nil) {
        _topView = [[YLReadTopView alloc] initWithReadMenu:self];
        _topView.hidden = !self.isMenuShow;
        _topView.frame = CGRectMake(0, self.isMenuShow ? 0 : -getNavigationBarHeight(), CGRectGetWidth(UIScreen.mainScreen.bounds), getNavigationBarHeight());
    }
    return _topView;
}

 /// 初始化BottomView
- (YLReadBottomView *)bottomView{
    if (_bottomView == nil) {
        _bottomView = [[YLReadBottomView alloc] initWithReadMenu:self];
        _bottomView.hidden = !self.isMenuShow;
        CGFloat y = _isMenuShow ? (CGRectGetHeight(UIScreen.mainScreen.bounds) - getYLReadBottomViewHeight()) : CGRectGetHeight(UIScreen.mainScreen.bounds);
        _bottomView.frame = CGRectMake(0, y, CGRectGetWidth(UIScreen.mainScreen.bounds), getYLReadBottomViewHeight());
        
        // 绘制中间虚线(如果不需要虚线可以去掉自己加个分割线)
        CAShapeLayer *shapeLayer = CAShapeLayer.layer;
        shapeLayer.bounds = _bottomView.bounds;
        shapeLayer.position = CGPointMake(CGRectGetWidth(_bottomView.bounds) / 2.0, CGRectGetHeight(_bottomView.bounds) / 2.0);
        shapeLayer.fillColor = UIColor.clearColor.CGColor;
        shapeLayer.strokeColor = kYLRead_Color_Menu().CGColor;
        shapeLayer.lineWidth = 0.5;
        shapeLayer.lineJoin = kCALineJoinRound;
        shapeLayer.lineDashPhase = 0;
        shapeLayer.lineDashPattern = @[@1,@2];
        
        UIBezierPath *path = UIBezierPath.bezierPath;
        [path moveToPoint:CGPointMake(0, getYLReadProgressViewHeight())];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(_bottomView.bounds), getYLReadProgressViewHeight())];
        shapeLayer.path = path.CGPath;
        [_bottomView.layer addSublayer:shapeLayer];
    }
    return _bottomView;
}

/// 初始化SettingView
- (YLReadSettingView *)settingView{
    if (_settingView == nil) {
        _settingView = [[YLReadSettingView alloc] initWithReadMenu:self];
        _settingView.hidden = YES;
        _settingView.frame = CGRectMake(0, CGRectGetHeight(UIScreen.mainScreen.bounds), CGRectGetWidth(UIScreen.mainScreen.bounds), getYLReadSettingViewHeight());
    }
    return _settingView;
}
 
@end

