//
//  YLReadViewController.h
//  YLRead
//
//  Created by 苏沫离 on 2017/5/9.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLReadRecordModel.h"

NS_ASSUME_NONNULL_BEGIN
@class YLReadModel;
@interface YLReadViewController : UIViewController

/// 当前页阅读记录对象
@property (nonatomic ,strong) YLReadRecordModel *recordModel;

/// 阅读对象(用于显示书名以及书籍首页显示书籍信息)
@property (nonatomic ,strong) YLReadModel *readModel;

/// 刷新阅读进度显示
- (void)reloadProgress;

- (void)initReadView;
@end

NS_ASSUME_NONNULL_END
