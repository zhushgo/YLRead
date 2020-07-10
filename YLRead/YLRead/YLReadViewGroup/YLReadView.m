//
//  YLReadView.m
//  FM
//
//  Created by 苏沫离 on 2020/6/30.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadView.h"
#import "YLGlobalTools.h"

@interface YLReadView ()


@end


@implementation YLReadView

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
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, CGRectGetHeight(rect));
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CTFrameDraw(_frameRef, ctx);
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

- (void)setFrameRef:(CTFrameRef)frameRef{
    _frameRef = frameRef;
    if (frameRef) {
        [self setNeedsDisplay];
    }
}

@end

