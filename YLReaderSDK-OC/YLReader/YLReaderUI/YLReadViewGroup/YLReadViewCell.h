//
//  YLReadViewCell.h
//  YLRead
//
//  Created by 苏沫离 on 2017/5/1.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YLReadView,YLReadPageModel;
@interface YLReadViewCell : UITableViewCell

/// 阅读视图
@property (nonatomic ,strong) YLReadView *readView;

@property (nonatomic ,strong) YLReadPageModel *pageModel;

@end

NS_ASSUME_NONNULL_END