//
//  YLReadViewCell.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/1.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadViewCell.h"
#import "YLReadView.h"
#import "YLReadPageModel.h"
#import "YLGlobalTools.h"

@implementation YLReadViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        _readView = [[YLReadView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:_readView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    // 分页顶部高度
    CGFloat y = self.pageModel.headTypeHeight;
    // 内容高度
    CGFloat h = self.pageModel.contentSize.height;
    self.readView.frame = CGRectMake(0, y, getReadViewRect().size.width, h);
}

- (void)setPageModel:(YLReadPageModel *)pageModel{
    _pageModel = pageModel;
    [self layoutIfNeeded];
}


@end

