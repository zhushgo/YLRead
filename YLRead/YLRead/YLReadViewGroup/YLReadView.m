//
//  YLReadView.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/30.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadView.h"
#import "YLGlobalTools.h"

@implementation YLReadView

- (void)dealloc{
    if (_frameRef) {
        CFRelease(_frameRef);
    }
}

- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

/// 绘制
- (void)drawRect:(CGRect)rect{
    if (_frameRef == nil) {
        return;
    }
     //1.获取当前绘图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //2.旋转坐坐标系(默认和UIKit坐标是相反的)
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, CGRectGetHeight(rect));
    CGContextScaleCTM(context, 1.0, -1.0);
    //5.开始绘制
    CTFrameDraw(_frameRef, context);
}

/// 当前页模型(使用contentSize绘制)
- (void)setPageModel:(YLReadPageModel *)pageModel{
    _pageModel = pageModel;
    self.frameRef = getFrameRefByAttrString(pageModel.showContent, CGRectMake(0, 0, pageModel.contentSize.width, pageModel.contentSize.height));
}

/// 当前页内容(使用固定范围绘制)
- (void)setContent:(NSAttributedString *)content{
    _content = content;
    self.frameRef = getFrameRefByAttrString(content, CGRectMake(0, 0,getReadViewRect().size.width, getReadViewRect().size.height));
}

//CoreFoundation不支持ARC，需要手动去管理内存的释放
- (void)setFrameRef:(CTFrameRef)frameRef{
    if (_frameRef) {
        CFRelease(_frameRef);
        _frameRef = nil;
    }
    _frameRef = frameRef;
    if (frameRef) {
        [self setNeedsDisplay];
    }
}

@end

