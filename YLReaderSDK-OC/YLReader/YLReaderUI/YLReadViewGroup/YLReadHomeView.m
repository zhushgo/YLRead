//
//  YLReadHomeView.m
//  YLRead
//
//  Created by 苏沫离 on 2017/6/30.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import "YLReadHomeView.h"
#import "YLReadModel.h"

@interface YLReadHomeView ()

@end

@implementation YLReadHomeView

- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.name];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.name.frame = self.bounds;
}

#pragma mark - setter and getters

- (void)setReadModel:(YLReadModel *)readModel{
    _readModel = readModel;
    self.name.text = readModel.bookName;
}

- (UILabel *)name{
    if (_name == nil) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:50];
        label.textColor = YLReadConfigure.shareConfigure.textColor;
        label.textAlignment = NSTextAlignmentCenter;
        _name = label;
    }
    return _name;
}


@end
