//
//  YLReadBottomView.h
//  FM
//
//  Created by 苏沫离 on 2020/6/29.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadBaseView.h"

NS_ASSUME_NONNULL_BEGIN

/// progressView 高度
FOUNDATION_EXPORT CGFloat getYLReadProgressViewHeight(void);
@interface YLReadProgressView : YLReadBaseView
/// 上一章
@property (nonatomic ,strong) UIButton *previousChapter;
/// 下一章
@property (nonatomic ,strong) UIButton *nextChapter;
/// 刷新阅读进度显示
- (void)reloadProgress;
@end

/// funcView 高度
FOUNDATION_EXPORT CGFloat getYLReadFuncViewHeight(void);
@interface YLReadFuncView : YLReadBaseView
/// 目录
@property (nonatomic ,strong) UIButton *catalogue;
/// 设置
@property (nonatomic ,strong) UIButton *setting;
/// 日夜间切换 (Day and Night)
@property (nonatomic ,strong) UIButton *dn;

/// 刷新日夜间按钮显示状态
- (void)updateDNButton;

@end


/// bottomView 高度 (TabBarHeight就包含了funcView高度, 所以只需要在上面在加progressView高度就好了)
FOUNDATION_EXPORT CGFloat getYLReadBottomViewHeight(void);
@interface YLReadBottomView : YLReadBaseView
/// 功能
@property (nonatomic ,strong) YLReadFuncView *funcView;
/// 进度
@property (nonatomic ,strong) YLReadProgressView *progressView;
@end

NS_ASSUME_NONNULL_END
