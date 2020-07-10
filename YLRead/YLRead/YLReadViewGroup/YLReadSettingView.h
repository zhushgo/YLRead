//
//  YLReadSettingView.h
//  FM
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


///字体类型
@interface YLReadSettingFontTypeView : YLReadBaseView

@end


///背景色
@interface YLReadSettingBGColorView : YLReadBaseView

@end

/// 亮度
@interface YLReadSettingLightView : YLReadBaseView

@end


///翻页类型
@interface YLReadSettingEffectTypeView : YLReadBaseView

@end


///间距
@interface YLReadSettingSpacingView : YLReadBaseView

@end




FOUNDATION_EXPORT CGFloat getYLReadSettingViewHeight(void);
@interface YLReadSettingView : YLReadBaseView
/// 亮度
@property (nonatomic ,strong) YLReadSettingLightView *lightView;
/// 字体大小
@property (nonatomic ,strong) YLReadSettingFontSizeView *fontSizeView;
/// 背景
@property (nonatomic ,strong) YLReadSettingBGColorView *bgColorView;
/// 翻页效果
@property (nonatomic ,strong) YLReadSettingEffectTypeView *effectTypeView;
/// 字体
@property (nonatomic ,strong) YLReadSettingFontTypeView *fontTypeView;
/// 间距
@property (nonatomic ,strong) YLReadSettingSpacingView *spacingView;
@end

NS_ASSUME_NONNULL_END
