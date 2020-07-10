//
//  YLReadLongPressViewController.m
//  FM
//
//  Created by 苏沫离 on 2020/7/1.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadLongPressViewController.h"
#import "YLReadLongPressView.h"
#import "YLReadConfigure.h"
#import "YLGlobalTools.h"

@interface YLReadLongPressViewController ()

/// 阅读视图
@property (nonatomic ,strong) YLReadLongPressView *readView;

@end

@implementation YLReadLongPressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = YLReadConfigure.shareConfigure.bgColor;
    self.extendedLayoutIncludesOpaqueBars = YES;
    if (@available(iOS 11.0, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)initReadView{
    if (self.recordModel.pageModel.isHomePage) {
        [super initReadView];
    }else{
        // 长按功能需要内容高度防止拖拽超出界限
        [self.view addSubview:self.readView];
    }
}

#pragma mark - response click

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


/// 解析触摸事件
- (void)dragWithStatus:(YLPanGesStatus)status touches:(NSSet<UITouch *> *)touches{
    // 是否为书籍首页
    if (self.recordModel.pageModel.isHomePage) { return; }
    if (self.readView.isOpenDrag) {
        CGPoint windowPoint = [touches.allObjects.firstObject locationInView:self.view];
        CGPoint point = [self.view convertPoint:windowPoint toView:self.readView];
        [self.readView dragWithStatus:status point:point windowPoint:windowPoint];
    }
}

#pragma mark - setter and getter

// 阅读视图
- (YLReadLongPressView *)readView{
    if (_readView == nil) {
        _readView = [[YLReadLongPressView alloc] initWithFrame:CGRectMake(getReadViewRect().origin.x, getReadViewRect().origin.y, getReadViewRect().size.width, self.recordModel.pageModel.contentSize.height)];
        _readView.pageModel = self.recordModel.pageModel;
    }
    return _readView;
}

@end
