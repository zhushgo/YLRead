//
//  YLReadHomeViewCell.m
//  FM
//
//  Created by 苏沫离 on 2020/6/30.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadHomeViewCell.h"

@implementation YLReadHomeViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        _homeView = [[YLReadHomeView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:_homeView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.homeView.frame =self.bounds;
}

@end
