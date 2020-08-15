//
//  YLReadSettingView.h
//  YLRead
//
//  Created by 苏沫离 on 2020/6/29.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadBaseView.h"

NS_ASSUME_NONNULL_BEGIN

///字体大小
@interface YLReadSettingFontSizeView : YLReadBaseView
/// 刷新日夜间按钮显示状态
- (void)updateDisplayProgressButton;
@end

/// 亮度
@interface YLReadSettingLightView : YLReadBaseView

@end





FOUNDATION_EXPORT CGFloat getYLReadSettingViewHeight(void);
@interface YLReadSettingView : YLReadBaseView
/// 亮度
@property (nonatomic ,strong) YLReadSettingLightView *lightView;
/// 字体大小
@property (nonatomic ,strong) YLReadSettingFontSizeView *fontSizeView;

@end

NS_ASSUME_NONNULL_END
