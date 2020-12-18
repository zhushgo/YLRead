//
//  YLReadViewStatusTopView.m
//  YLRead
//
//  Created by 苏沫离 on 2017/6/28.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import "YLReadViewStatusTopView.h"

@interface YLReadViewStatusTopView ()

@end

@implementation YLReadViewStatusTopView

- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bookName];
        [self addSubview:self.chapterName];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.bookName.frame = CGRectMake(0, 0, (CGRectGetWidth(self.bounds) - 15) / 2.0, CGRectGetHeight(self.bounds));
    self.chapterName.frame = CGRectMake(CGRectGetMaxX(self.bookName.frame), 0, CGRectGetWidth(self.bookName.frame), CGRectGetHeight(self.bounds));
}

#pragma mark - setter and getters

- (UILabel *)bookName{
    if (_bookName == nil) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = YLReadConfigure.shareConfigure.statusTextColor;
        label.textAlignment = NSTextAlignmentLeft;
        _bookName = label;
    }
    return _bookName;
}

- (UILabel *)chapterName{
    if (_chapterName == nil) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = YLReadConfigure.shareConfigure.statusTextColor;
        label.textAlignment = NSTextAlignmentRight;
        _chapterName = label;
    }
    return _chapterName;
}

@end
