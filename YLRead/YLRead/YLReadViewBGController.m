//
//  YLReadViewBGController.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/8.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadViewBGController.h"
#import "YLReadConfigure.h"
#import "YLReadRecordModel.h"
#import "YLGlobalTools.h"

@interface YLReadViewBGController ()


@end

@implementation YLReadViewBGController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = YLReadConfigure.shareConfigure.bgColor;
    self.extendedLayoutIncludesOpaqueBars = YES;
    if (@available(iOS 11.0, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.imageView];
    
    [self funcTwo];
    
    // 清空视图
    _targetView = nil;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.imageView.frame = self.view.bounds;
}

/// 方式一
- (void)funcOne{
    // 展示图片
    if (_targetView) {
        self.imageView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        self.imageView.image = screenCapture(_targetView,NO);
    }
}

/// 方式二
- (void)funcTwo{
    // 展示图片
    if (_targetView) {
        CGRect rect = _targetView.frame;
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGAffineTransform transform = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, rect.size.width, 0.0);
        CGContextConcatCTM(context, transform);
        [_targetView.layer renderInContext:context];
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}
   
#pragma mark - setter and getter

- (UIImageView *)imageView{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = YLReadConfigure.shareConfigure.bgColor;

    }
    return _imageView;
}

//- (UIView *)targetView{
//    if (_targetView == nil) {
//        _targetView = [[UIView alloc] init];
//    }
//    return _targetView;
//}

@end

