//
//  YLReadHomeView.h
//  FM
//
//  Created by 苏沫离 on 2020/6/30.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YLReadModel;
@interface YLReadHomeView : UIView
/// 当前阅读模型
@property (nonatomic ,strong) YLReadModel *readModel;

/// 书籍名称
@property (nonatomic ,strong) UILabel *name;

@end

NS_ASSUME_NONNULL_END
