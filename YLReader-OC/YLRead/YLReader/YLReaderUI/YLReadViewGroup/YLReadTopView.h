//
//  YLReadTopView.h
//  YLRead
//
//  Created by 苏沫离 on 2020/6/29.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLReadTopView : YLReadBaseView

@property (nonatomic ,strong) UIButton *back;/// 返回
@property (nonatomic ,strong) UIButton *mark;/// 书签

/// 刷新书签按钮显示状态
- (void)updateMarkButton;

- (void)checkForMark;

@end

NS_ASSUME_NONNULL_END
