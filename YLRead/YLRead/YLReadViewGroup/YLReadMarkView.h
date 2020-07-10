//
//  YLReadMarkView.h
//  FM
//
//  Created by 苏沫离 on 2020/6/30.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YLReadMarkView,YLReadMarkModel,YLReadModel;
@protocol YLReadMarkViewDelegate <NSObject>

/// 点击章节
- (void)markViewClickMark:(YLReadMarkView *)markView markModel:(YLReadMarkModel *)markModel;

@end

/// 标签
@interface YLReadMarkView : UIView

/// 代理
@property (nonatomic ,weak) id <YLReadMarkViewDelegate> delegate;

/// 数据源
@property (nonatomic ,strong) YLReadModel *readModel;

@property (nonatomic ,strong) UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
