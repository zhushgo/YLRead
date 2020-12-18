//
//  YLReadSettingView.h
//  YLRead
//
//  Created by 苏沫离 on 2017/6/29.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import "YLReadBaseView.h"

NS_ASSUME_NONNULL_BEGIN

///字体大小
@interface YLReadSettingFontSizeView : YLReadBaseView
/// 刷新日夜间按钮显示状态
- (void)updateDisplayProgressButton;
@end




@interface YLReadSettingView : YLReadBaseView
/// 字体大小
@property (nonatomic ,strong) YLReadSettingFontSizeView *fontSizeView;

@end

NS_ASSUME_NONNULL_END
