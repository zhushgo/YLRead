//
//  YLGlobalTools.h
//  YLRead
//
//  Created by 苏沫离 on 2020/6/29.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 屏幕适配

FOUNDATION_EXPORT BOOL isIPhoneNotchScreen(void);//是否是刘海屏
FOUNDATION_EXPORT CGFloat getStatusBarHeight(void);
FOUNDATION_EXPORT CGFloat getNavigationBarHeight(void);
FOUNDATION_EXPORT CGFloat getTabBarHeight(void);
FOUNDATION_EXPORT CGFloat getPageSafeAreaHeight(BOOL isShowNavBar);

#pragma mark -


/// 设置行间距
FOUNDATION_EXPORT NSAttributedString *textLineSpacing_1(NSString *string ,CGFloat lineSpacing);
FOUNDATION_EXPORT NSAttributedString *textLineSpacing_2(NSString *string ,CGFloat lineSpacing ,NSLineBreakMode lineBreakMode);


FOUNDATION_EXPORT NSDate *getDateByStamp(NSTimeInterval timeStamp);
FOUNDATION_EXPORT NSString *transformTimeToMMSS(NSTimeInterval timeStamp);



/// topView 高度
FOUNDATION_EXPORT CGFloat const kYLReadStatusTopViewHeight;
/// bottomView 高度
FOUNDATION_EXPORT CGFloat const kYLReadStatusBottomViewHeight;
/// 长按阅读视图通知 info 数据 key
FOUNDATION_EXPORT NSString *const kYLReadLongPressViewKey;
/// 长按阅读视图通知
FOUNDATION_EXPORT NSString *const kYLReadLongPressViewNotification;


/// Key - 阅读记录
FOUNDATION_EXPORT NSString *const kYLReadRecordKey;

/// Key - 阅读对象
FOUNDATION_EXPORT NSString *const kYLReadObjectKey;


/// 阅读范围(阅读顶部状态栏 + 阅读View + 阅读底部状态栏)
FOUNDATION_EXPORT CGRect getReadRect(void);
/// 阅读View范围
FOUNDATION_EXPORT CGRect getReadViewRect(void);





/// 获得当前时间戳
FOUNDATION_EXPORT NSTimeInterval getTimer1970(void);

/// 获取指定时间字符串 (format: "YYYY-MM-dd-HH-mm-ss")
FOUNDATION_EXPORT NSString *getTimeByFormat(NSString *format,NSDate *date);

/// 对指定视图截屏:isSave = false
FOUNDATION_EXPORT UIImage *screenCapture(UIView *view,BOOL isSave);


NS_ASSUME_NONNULL_END
