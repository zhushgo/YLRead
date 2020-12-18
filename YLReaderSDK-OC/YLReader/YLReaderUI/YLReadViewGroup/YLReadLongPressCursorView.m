//
//  YLReadLongPressCursorView.m
//  YLRead
//
//  Created by 苏沫离 on 2017/5/9.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import "YLReadLongPressCursorView.h"

@interface YLReadLongPressCursorView ()

@end


@implementation YLReadLongPressCursorView

@synthesize color = _color;

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

- (void)drawRect:(CGRect)rect{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self setColor:_color];
    
    CGFloat rectW = CGRectGetWidth(rect) / 2.0;
    
    CGContextAddRect(ctx, CGRectMake( (CGRectGetWidth(rect) - rectW) / 2.0 , _isTorB ? 1 : 0, rectW, CGRectGetHeight(rect) - 1));
    CGContextFillPath(ctx);
    if (_isTorB){
        CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetWidth(rect)));
    }else{
        CGContextAddEllipseInRect(ctx, CGRectMake(0, CGRectGetHeight(rect) - CGRectGetWidth(rect), CGRectGetWidth(rect), CGRectGetWidth(rect)));
    }
    [self setColor:_color];
    CGContextFillPath(ctx);
}

- (void)setIsTorB:(BOOL)isTorB{
    _isTorB = isTorB;
    [self setNeedsDisplay];
}

- (void)setColor:(UIColor *)color{
    _color = color;
    [self setNeedsDisplay];
}

- (UIColor *)color{
    if (_color == nil) {
        _color = kYLRead_Color_Main();
    }
    return _color;
}

@end

