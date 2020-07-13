//
//  YLReadLongPressView.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/1.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadLongPressView.h"
#import "YLReadLongPressCursorView.h"
#import "YLCoreText.h"
#import "YLReadConfigure.h"
#import <CoreGraphics/CoreGraphics.h>



@interface YLReadMagnifierView : UIWindow

/// 目标视图Window (注意: 传视图的Window 例子: self.view.window)
@property (nonatomic, weak, nullable) UIView *targetWindow;

/// 目标视图展示位置 (放大镜需要展示的位置)
@property (nonatomic, assign) CGPoint targetPoint;

/// 放大镜位置偏移调整 (调整放大镜在原始位置上的偏移 默认: CGPointMake(0, -40))
@property (nonatomic, assign) CGPoint offsetPoint;

/// 放大比例 默认: DZM_MV_SCALE
@property (nonatomic, assign) CGFloat scale;

/// 弱引用接收对象 (内部已经强引用,如果外部也强引用需要自己释放)
+ (nonnull instancetype)magnifierView;

/// 移除 (移除对象 并释放内部强引用)
- (void)remove:(nullable void (^)(void))complete;

@end

/// 动画时间
#define DZM_MV_AD_TIME 0.08
/// 放大比例
#define DZM_MV_SCALE 1.3
/// 放大区域
#define DZM_MV_WH 120

@interface YLReadMagnifierView ()

@property (nonatomic, strong) YLReadMagnifierView *strongSelf;

@property (nonatomic, weak) CALayer *contentLayer;

@property (nonatomic, weak) UIImageView *coverOne;

@property (nonatomic, weak) UIImageView *coverTwo;

@end


@implementation YLReadMagnifierView

+ (instancetype)magnifierView {
    YLReadMagnifierView *mv = [[YLReadMagnifierView alloc] init];
    mv.strongSelf = mv;
    return mv;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) { }
    
    return self;
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.offsetPoint = CGPointMake(0, -40);
        self.scale = DZM_MV_SCALE;
        
        self.frame = CGRectMake(0, 0, DZM_MV_WH, DZM_MV_WH);
        self.layer.cornerRadius = DZM_MV_WH / 2;
        self.layer.masksToBounds = YES;
        self.windowLevel = UIWindowLevelAlert;
        
        CALayer *contentLayer = [CALayer layer];
        contentLayer.frame = self.bounds;
        contentLayer.delegate = self;
        contentLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:contentLayer];
        self.contentLayer = contentLayer;
        
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        UIImageView *coverOne = [[UIImageView alloc] init];
        coverOne.image = [UIImage imageNamed:@"magnifier_0"];
        coverOne.frame = CGRectMake(0, 0, DZM_MV_WH, DZM_MV_WH);
        [self addSubview: coverOne];
        self.coverOne = coverOne;
        
        UIImageView *coverTwo = [[UIImageView alloc] init];
        coverTwo.image = [UIImage imageNamed:@"magnifier_1"];
        coverTwo.frame = CGRectMake(0, 0, DZM_MV_WH, DZM_MV_WH);
        [self addSubview:coverTwo];
        self.coverTwo = coverTwo;
    }
    
    return self;
}

- (void)setoffsetPoint:(CGPoint)offsetPoint {
    
    _offsetPoint = offsetPoint;
    
    [self setTargetPoint:self.targetPoint];
}

- (void)setScale:(CGFloat)scale {
    
    _scale = scale;
    
    [self.contentLayer setNeedsDisplay];
}

- (void)setTargetWindow:(UIView *)targetWindow {
    
    _targetWindow = targetWindow;
    
    [self makeKeyAndVisible];
    
    __weak YLReadMagnifierView *weakSelf = self;
    
    [UIView animateWithDuration:DZM_MV_AD_TIME animations:^{
        
        weakSelf.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
    
    [self setTargetPoint:self.targetPoint];
}

- (void)setTargetPoint:(CGPoint)targetPoint {
    
    _targetPoint = targetPoint;
    
    if (self.targetWindow) {
        
        CGPoint center = CGPointMake(targetPoint.x, self.center.y);
        
        if (targetPoint.y > CGRectGetHeight(self.bounds) * 0.5) {
            
            center.y = targetPoint.y -  CGRectGetHeight(self.bounds) / 2;
        }
        
        self.center = CGPointMake(center.x + self.offsetPoint.x, center.y + self.offsetPoint.y);
        
        [self.contentLayer setNeedsDisplay];
    }
}

- (void)remove:(void (^)(void))complete {
    
    __weak YLReadMagnifierView *weakSelf = self;
    
    [UIView animateWithDuration:DZM_MV_AD_TIME animations:^{
        
        weakSelf.coverOne.alpha = 0;
        
        weakSelf.coverTwo.alpha = 0;
        
        weakSelf.alpha = 0;
        
        weakSelf.transform = CGAffineTransformMakeScale(0.2, 0.2);
        
    } completion:^(BOOL finished) {
        
        [weakSelf.coverOne removeFromSuperview];
        
        [weakSelf.coverTwo removeFromSuperview];
        
        [weakSelf removeFromSuperview];
        
        weakSelf.strongSelf = nil;
        
        if (complete != nil) { complete(); }
    }];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextTranslateCTM(ctx, DZM_MV_WH / 2, DZM_MV_WH / 2);
    
    CGContextScaleCTM(ctx, self.scale, self.scale);
    
    CGContextTranslateCTM(ctx, -1 * self.targetPoint.x, -1 * self.targetPoint.y);
    
    [self.targetWindow.layer renderInContext:ctx];
}

- (void)dealloc
{
    [self.contentLayer removeFromSuperlayer];
    
    self.contentLayer = nil;
}

@end














/// 光标拖拽触发范围
static CGFloat kYLReadLongPressCursorViewOffet = -20;

/// 长按阅读视图通知
NSString *const kYLRead_ReadMonitor_Notification = @"kYLRead_ReadMonitor_Notification";
NSString *const kYLRead_ReadMonitor_Notification_key = @"kYLRead_ReadMonitor_Notification_key";
void addNotification_ReadMonitor(id target,SEL action){
    [NSNotificationCenter.defaultCenter addObserver:target selector:action name:kYLRead_ReadMonitor_Notification object:nil];
}

void postNotification_ReadMonitor(NSDictionary *userInfo){
    [NSNotificationCenter.defaultCenter postNotificationName:kYLRead_ReadMonitor_Notification object:nil userInfo:userInfo];
}

void removeNotification_ReadMonitor(id target){
    [NSNotificationCenter.defaultCenter removeObserver:target name:kYLRead_ReadMonitor_Notification object:nil];
}


@interface YLReadLongPressView ()


 /// 光标颜色
@property (nonatomic ,strong) UIColor *color;
/// 选中区域
@property (nonatomic ,assign) NSRange selectRange;
/// 选中区域CGRect数组
@property (nonatomic ,strong) NSMutableArray<NSValue *> *rects;

/// 长按
@property (nonatomic ,strong) UILongPressGestureRecognizer *longGes;
/// 单击
@property (nonatomic ,strong) UITapGestureRecognizer *tapGes;

/// 左光标
@property (nonatomic ,strong) YLReadLongPressCursorView *LCursorView;
/// 右光标
@property (nonatomic ,strong) YLReadLongPressCursorView *RCursorView;
/// 放大镜
@property (nonatomic ,strong) YLReadMagnifierView *magnifierView;

/// 触摸的光标是左还是右
@property (nonatomic ,assign) BOOL isCursorLorR;
/// 是否触摸到左右光标
@property (nonatomic ,assign) BOOL isTouchCursor;
/// 动画时间
@property (nonatomic ,assign) NSTimeInterval duration;

@end

@implementation YLReadLongPressView

/// 释放
- (void)dealloc{
    _tapGes = nil;
    _longGes = nil;
}

- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _isOpenDrag = NO;
        _isCursorLorR = YES;
        _isTouchCursor = NO;
        _duration = 0.2;
        
        [self addGestureRecognizer:self.longGes];
        [self addGestureRecognizer:self.tapGes];

    }
    return self;
}

/// 绘制
- (void)drawRect:(CGRect)rect{
    
    if (self.frameRef == nil) {return;}
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, CGRectGetHeight(rect));
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    if (!NSEqualRanges(_selectRange, NSMakeRange(0, 0)) && self.rects.count) {
        CGMutablePathRef path = CGPathCreateMutable();
        [[kYLRead_Color_Main() colorWithAlphaComponent:0.5] setFill];
        NSInteger count = self.rects.count;
        CGRect rects[count];
        for (int i = 0; i < count; i++) {
            rects[i] = self.rects[i].CGRectValue;
        }
        CGPathAddRects(path, nil, rects, count);
        CGContextAddPath(ctx, path);
        CGContextFillPath(ctx);
    }
    
    CTFrameDraw(self.frameRef, ctx);
}

/// 允许菜单事件
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(clickCopy)) {
        return YES;
    }
    return NO;
}

/// 允许成为响应者
- (BOOL)canBecomeFirstResponder{
    return YES;
}

#pragma mark - public method

/// 创建放大镜
- (void)creatMagnifierView:(CGPoint)windowPoint {
    self.magnifierView.targetPoint = windowPoint;
}

/// 隐藏或显示菜单
- (void)showMenu:(BOOL)isShow{
    if (isShow) { // 显示
        if (self.rects.count) {
            CGRect rect = getMenuRect(self.rects, self.bounds);
            [self becomeFirstResponder];
            
            UIMenuController *menuController = UIMenuController.sharedMenuController;
            UIMenuItem *copy = [[UIMenuItem alloc]initWithTitle:@"复制" action:@selector(clickCopy)];
            menuController.menuItems = @[copy];
            [menuController setTargetRect:rect inView:self];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [menuController setMenuVisible:YES animated:YES];
            });
        }
    }else{ // 隐藏
        [UIMenuController.sharedMenuController setMenuVisible:NO animated:YES];
    }
}


/// 隐藏或显示光标
- (void)cursorWithIsShow:(BOOL)isShow{
    if (isShow) {
        if (self.rects.count && _LCursorView == nil) {
            [self addSubview:self.LCursorView];
            [self addSubview:self.RCursorView];
            [self updateCursorFrame];
        }
        
    }else{
        
        if (_LCursorView) {
            
            [_LCursorView removeFromSuperview];
            _LCursorView = nil;
            
            [_RCursorView removeFromSuperview];
            _RCursorView = nil;
        }
    }
}

/// 更新光标位置
- (void)updateCursorFrame{
    if (self.rects.count && _LCursorView) {

        CGFloat cursorViewW = 10;
        CGFloat cursorViewSpaceW = cursorViewW / 4.0;
        CGFloat cursorViewSpaceH = cursorViewW / 1.1;
        CGRect first = self.rects.firstObject.CGRectValue;
        CGRect last = self.rects.lastObject.CGRectValue;
        
        _LCursorView.frame = CGRectMake(CGRectGetMinX(first) - cursorViewW + cursorViewSpaceW, CGRectGetHeight(self.bounds) - CGRectGetMinY(first) - cursorViewSpaceH, cursorViewW, CGRectGetHeight(first) + cursorViewSpaceH);
        _RCursorView.frame = CGRectMake(CGRectGetMaxX(last) - cursorViewSpaceW, CGRectGetHeight(self.bounds) - CGRectGetMinY(last) - CGRectGetHeight(last), cursorViewW, CGRectGetHeight(last)  + cursorViewSpaceH);
    }
}

/// 重置页面数据
- (void)reset{
    // 发送通知
    postNotification_ReadMonitor(@{kYLRead_ReadMonitor_Notification_key:@YES});
    
    // 手势状态
    self.tapGes.enabled = NO;
    self.isOpenDrag = NO;
    self.longGes.enabled = YES;
    
    // 移除菜单
    [self showMenu:NO];
    
    // 清空选中
    _selectRange = NSMakeRange(0, 0);
    [self.rects removeAllObjects];
    
    // 移除光标
    [self cursorWithIsShow:NO];
    
    // (如果有放大镜)移除放大镜
    __weak typeof(self) weakSelf = self;
    [self.magnifierView remove:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->_magnifierView = nil;// 清空
    }];
    
    // 重绘
    [self setNeedsDisplay];
}


/// 刷新选中区域
- (void)updateSelectRange:(NSInteger)location{
    // 左右 Location 位置
    NSInteger LLocation = _selectRange.location;
    NSInteger RLocation = _selectRange.location + _selectRange.length;
    
    // 判断触摸
    if (_isCursorLorR) { // 左边
        if (location < RLocation) {
            if (location > LLocation) {
                _selectRange.length -= location - LLocation;
                _selectRange.location = location;
            }else if (location < LLocation) {
                _selectRange.length += LLocation - location;
                _selectRange.location = location;
            }
        }else{
            _isCursorLorR = NO;
            
            NSInteger length = location - RLocation;
            NSInteger tempLength = (length == 0 ? 1 : 0);
            length = (length == 0 ? 1 : length);
            _selectRange.length = length;
            _selectRange.location = RLocation - tempLength;
            [self updateSelectRange:location];
        }
    }else{ // 右边
        
        if (location > LLocation) {
            if (location > RLocation) {
                _selectRange.length += location - RLocation;
            }else if (location < RLocation) {
                _selectRange.length -= RLocation - location;
            }
        }else{
            _isCursorLorR = YES;
            NSInteger tempLength = LLocation - location;
            NSInteger length = (tempLength == 0 ? 1 : tempLength);
            _selectRange.length = length;
            _selectRange.location = LLocation - tempLength;
            [self updateSelectRange:location];
        }
    }
}

/// 解析触摸事件
- (void)dragWithStatus:(YLPanGesStatus)status touches:(NSSet<UITouch *> *)touches{
    if (_isOpenDrag) {
        UITouch *touch = touches.allObjects.firstObject;
        CGPoint point = [touch locationInView:self];
        CGPoint windowPoint = [touch locationInView:UIApplication.sharedApplication.delegate.window];
        [self dragWithStatus:status point:point windowPoint:windowPoint];
    }
}
 
 /// 拖拽事件解析
- (void)dragWithStatus:(YLPanGesStatus)status point:(CGPoint)point windowPoint:(CGPoint)windowPoint{
     // 检查是否超出范围
     point = CGPointMake(MIN(MAX(point.x, 0), self.pageModel.contentSize.width),  MIN(MAX(point.y, 0), self.pageModel.contentSize.height));

     // 触摸开始
     if (status == YLPanGesStatusBegin) {
         // 隐藏菜单
         [self showMenu:NO];
         
         
         
         if (CGRectContainsPoint(CGRectInset(_LCursorView.frame , kYLReadLongPressCursorViewOffet, kYLReadLongPressCursorViewOffet), point)) { // 触摸到左边光标
             _isCursorLorR = YES;
             _isTouchCursor = YES;
         }else if (CGRectContainsPoint(CGRectInset(_RCursorView.frame , kYLReadLongPressCursorViewOffet, kYLReadLongPressCursorViewOffet), point)) { // 触摸到右边光标
             _isCursorLorR = NO;
             _isTouchCursor = YES;
         }else{ // 没有触摸到光标
             _isTouchCursor = NO;
         }
         
         // 触摸到了光标
         if (_isTouchCursor) {
             // 放大镜
             [self creatMagnifierView:windowPoint];
         }
     }else if (status == YLPanGesStatusChange) { // 触摸中
      
         // 触摸到光标
         if (_isTouchCursor) {
             // 设置放大镜位置
             self.magnifierView.targetPoint = windowPoint;
         }
         
         // 判断触摸
         if (_isTouchCursor && !NSEqualRanges(_selectRange, NSMakeRange(0, 0))) {
             
             // 触摸到的位置
             long location = getTouchLocation(point, self.frameRef);
             
             // 无结果
             if (location == -1) { return; }
          
             // 刷新选中区域
             [self updateSelectRange:location];
             
             // 获得选中选中范围
             self.rects = getRangeRects(self.selectRange, self.frameRef, self.pageModel.content.string);
             
             // 更新光标位置
             [self updateCursorFrame];
         }
         
     }else{ // 触摸结束

         // 触摸到光标
         if (_isTouchCursor) {
             // 设置放大镜位置
             self.magnifierView.targetPoint = windowPoint;
             // 移除
             __weak typeof(self) weakSelf = self;
             [self.magnifierView remove:^{
                 __strong typeof(weakSelf) strongSelf = weakSelf;
                 strongSelf->_magnifierView = nil;// 清空
                 [strongSelf showMenu:YES];// 显示菜单
             }];
         }else{
             
             // 显示菜单
             [self showMenu:YES];// 显示菜单
         }
         // 结束触摸
         _isTouchCursor = NO;
     }
     
     // 重绘
     [self setNeedsDisplay];
 }


#pragma mark - response click

/// 长按事件
- (void)longAction:(UILongPressGestureRecognizer *)longGes{
    // 触摸位置
    CGPoint point = [longGes locationInView:self];
    // 触摸位置
    CGPoint windowPoint = [longGes locationInView:UIApplication.sharedApplication.delegate.window];

    // 触摸开始 触摸中
    if (longGes.state == UIGestureRecognizerStateBegan) {
        // 发送通知
        postNotification_ReadMonitor(@{kYLRead_ReadMonitor_Notification_key: @YES});
        // 放大镜
        [self creatMagnifierView:windowPoint];
    }else if (longGes.state == UIGestureRecognizerStateChanged) {
        // 设置放大镜位置
        self.magnifierView.targetPoint = windowPoint;
    }else{ // 触摸结束
        // 获得选中区域
        _selectRange = getTouchLineRange(point, self.frameRef);

        
        // 获得选中选中范围
        self.rects = getRangeRects(self.selectRange, self.frameRef, self.pageModel.content.string);

        // 显示光标
        [self cursorWithIsShow:YES];
        // 设置放大镜位置
        self.magnifierView.targetPoint = windowPoint;

        // 移除
        __weak typeof(self) weakSelf = self;
        [self.magnifierView remove:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf->_magnifierView = nil;// 清空
            [strongSelf showMenu:YES];// 显示菜单
        }];
        // 重绘
        [self setNeedsDisplay];
        // 开启手势
        if (self.rects.count) {

            // 手势状态
            self.longGes.enabled = NO;
            self.tapGes.enabled = YES;
            self.isOpenDrag = YES;
            // 发送通知
            postNotification_ReadMonitor(@{kYLRead_ReadMonitor_Notification_key : @NO});
        }
    }
}

/// 单击事件
- (void)tapAction:(UITapGestureRecognizer *)tapGes{
    // 重置页面数据
    [self reset];
}

/// 复制事件
- (void)clickCopy{
    
    if (!NSEqualRanges(_selectRange, NSMakeRange(0, 0))){
        
        NSRange temSelectRange = _selectRange;
        
        NSAttributedString *tempContent = self.pageModel.content;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIPasteboard.generalPasteboard.string = [tempContent.string substringWithRange:temSelectRange];
        });
        
        // 重置页面数据
        [self reset];
    }
}

/// 触摸开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dragWithStatus:YLPanGesStatusBegin touches:touches];
}

/// 触摸移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dragWithStatus:YLPanGesStatusChange touches:touches];
}

/// 触摸结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dragWithStatus:YLPanGesStatusEnd touches:touches];
}

/// 触摸取消
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dragWithStatus:YLPanGesStatusEnd touches:touches];
}

#pragma mark - setter and getters

- (NSMutableArray<NSValue *> *)rects{
    if (_rects == nil) {
        _rects = [NSMutableArray array];
    }
    return _rects;
}

- (UILongPressGestureRecognizer *)longGes{
    if (_longGes == nil) {
        _longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:)];
    }
    return _longGes;
}

- (UITapGestureRecognizer *)tapGes{
    if (_tapGes == nil) {
        _tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        _tapGes.enabled = NO;
    }
    return _tapGes;
}

- (YLReadMagnifierView *)magnifierView{
    if (_magnifierView) {
        _magnifierView = [[YLReadMagnifierView alloc] init];
        _magnifierView.targetWindow = UIApplication.sharedApplication.delegate.window;
    }
    return _magnifierView;
}

- (YLReadLongPressCursorView *)LCursorView{
    if (_LCursorView == nil) {
        _LCursorView = [[YLReadLongPressCursorView alloc] init];
        _LCursorView.isTorB = YES;
    }
    return _LCursorView;
}

- (YLReadLongPressCursorView *)RCursorView{
    if (_RCursorView == nil) {
        _RCursorView = [[YLReadLongPressCursorView alloc] init];
        _RCursorView.isTorB = NO;
    }
    return _RCursorView;
}
@end


