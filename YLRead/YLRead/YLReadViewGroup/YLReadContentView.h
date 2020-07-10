//
//  YLReadContentView.h
//  FM
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YLReadContentView;
@protocol YLReadContentViewDelegate <NSObject>
/// 点击遮罩
- (void)contentViewClickCover:(YLReadContentView *)contentView;
@end


@interface YLReadContentView : UIView

@property (nonatomic ,weak) id<YLReadContentViewDelegate> delegate;

/// 遮盖展示
- (void)showCover:(BOOL)isShow;

@end


NS_ASSUME_NONNULL_END
