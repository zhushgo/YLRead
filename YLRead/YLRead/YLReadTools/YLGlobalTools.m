//
//  YLGlobalTools.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/29.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLGlobalTools.h"

#pragma mark - 屏幕适配

//判断是否是刘海屏
BOOL isIPhoneNotchScreen(void){
    /* iPhone8 Plus  UIEdgeInsets: {20, 0, 0, 0}
     * iPhone8       UIEdgeInsets: {20, 0, 0, 0}
     * iPhone XR     UIEdgeInsets: {44, 0, 34, 0}
     * iPhone XS     UIEdgeInsets: {44, 0, 34, 0}
     * iPhone XS Max UIEdgeInsets: {44, 0, 34, 0}
     */
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets;
        
        CGFloat bottomSpace = 0;
        switch (UIApplication.sharedApplication.statusBarOrientation) {
            case UIInterfaceOrientationPortrait:{
                bottomSpace = safeAreaInsets.bottom;
            }break;
            case UIInterfaceOrientationLandscapeLeft:{
                bottomSpace = safeAreaInsets.right;
            }break;
            case UIInterfaceOrientationLandscapeRight:{
                bottomSpace = safeAreaInsets.left;
            } break;
            case UIInterfaceOrientationPortraitUpsideDown:{
                bottomSpace = safeAreaInsets.top;
            }break;
            default:
                bottomSpace = safeAreaInsets.bottom;
                break;
        }
        return bottomSpace > 0 ? YES : NO;
    } else {
        return NO;
    }
}


CGFloat getStatusBarHeight(void){
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets;
        CGFloat topSpace = 0;
        switch (UIApplication.sharedApplication.statusBarOrientation) {
            case UIInterfaceOrientationPortrait:{
                topSpace = safeAreaInsets.top;
            }break;
            case UIInterfaceOrientationLandscapeLeft:{
                topSpace = safeAreaInsets.left;
            }break;
            case UIInterfaceOrientationLandscapeRight:{
                topSpace = safeAreaInsets.right;
            } break;
            case UIInterfaceOrientationPortraitUpsideDown:{
                topSpace = safeAreaInsets.bottom;
            }break;
            default:
                topSpace = safeAreaInsets.top;
                break;
        }
        
        if (topSpace == 0) {
            topSpace = 20.0f;
        }
        return topSpace;
    }else{
        return 20.0;
    }
}


//获取导航栏高度
CGFloat getNavigationBarHeight(void){
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets;
        CGFloat topSpace = 0;
        switch (UIApplication.sharedApplication.statusBarOrientation) {
            case UIInterfaceOrientationPortrait:{
                topSpace = safeAreaInsets.top;
            }break;
            case UIInterfaceOrientationLandscapeLeft:{
                topSpace = safeAreaInsets.left;
            }break;
            case UIInterfaceOrientationLandscapeRight:{
                topSpace = safeAreaInsets.right;
            } break;
            case UIInterfaceOrientationPortraitUpsideDown:{
                topSpace = safeAreaInsets.bottom;
            }break;
            default:
                topSpace = safeAreaInsets.top;
                break;
        }
        
        if (topSpace == 0) {
            topSpace = 20.0f;
        }
        return topSpace + 44.0f;
    } else {
        return 64.0f;
    }
}

//获取tabBar高度
CGFloat getTabBarHeight(void){
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets;
        CGFloat bottomSpace = 0;
        switch (UIApplication.sharedApplication.statusBarOrientation) {
            case UIInterfaceOrientationPortrait:{
                bottomSpace = safeAreaInsets.bottom;
            }break;
            case UIInterfaceOrientationLandscapeLeft:{
                bottomSpace = safeAreaInsets.right;
            }break;
            case UIInterfaceOrientationLandscapeRight:{
                bottomSpace = safeAreaInsets.left;
            } break;
            case UIInterfaceOrientationPortraitUpsideDown:{
                bottomSpace = safeAreaInsets.top;
            }break;
            default:
                bottomSpace = safeAreaInsets.bottom;
                break;
        }
        return bottomSpace + 49.0;
    } else {
        return 49.0;
    }
}
CGFloat getPageSafeAreaHeight(BOOL isShowNavBar){
    
    CGFloat screenHeight = CGRectGetHeight(UIScreen.mainScreen.bounds);
    
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets;
        CGFloat topSpace = 0;
        CGFloat bottomSpace = 0;
        
        switch (UIApplication.sharedApplication.statusBarOrientation) {
            case UIInterfaceOrientationPortrait:{
                topSpace = safeAreaInsets.top;
                bottomSpace = safeAreaInsets.bottom;
            }break;
            case UIInterfaceOrientationLandscapeLeft:{
                topSpace = safeAreaInsets.left;
                bottomSpace = safeAreaInsets.right;
            }break;
            case UIInterfaceOrientationLandscapeRight:{
                topSpace = safeAreaInsets.right;
                bottomSpace = safeAreaInsets.left;
            } break;
            case UIInterfaceOrientationPortraitUpsideDown:{
                topSpace = safeAreaInsets.bottom;
                bottomSpace = safeAreaInsets.top;
            }break;
            default:
                topSpace = safeAreaInsets.top;
                bottomSpace = safeAreaInsets.bottom;
                break;
        }
        
        if (topSpace == 0) {
            topSpace = 20.0f;
        }
        
        if (isShowNavBar) {
            topSpace += 44.0f;
            return screenHeight - topSpace - bottomSpace;
        }else{
            return screenHeight - bottomSpace;
        }
    } else {
        return screenHeight - 64.0f;
    }
}




/// 设置行间距
NSAttributedString *textLineSpacing_1(NSString *string ,CGFloat lineSpacing){
    return textLineSpacing_2(string, lineSpacing, NSLineBreakByTruncatingTail);
}

NSAttributedString *textLineSpacing_2(NSString *string ,CGFloat lineSpacing ,NSLineBreakMode lineBreakMode){
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = lineSpacing;
    style.lineBreakMode = lineBreakMode;
    
    NSAttributedString *attrs = [[NSAttributedString alloc] initWithString:string attributes:@{NSParagraphStyleAttributeName:style}];
    return attrs;
}

NSDate *getDateByStamp(NSTimeInterval timeStamp){
    return [NSDate dateWithTimeIntervalSince1970:(timeStamp / 1000)];

}

NSString *transformTimeToMMSS(NSTimeInterval timeStamp){
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:getDateByStamp(timeStamp)];;
}

/// topView 高度
CGFloat const kYLReadStatusTopViewHeight = 40;

/// bottomView 高度
CGFloat const kYLReadStatusBottomViewHeight = 30;

/// 长按阅读视图通知 info 数据 key
NSString *const kYLReadLongPressViewKey = @"kYLReadLongPressViewKey";
/// 长按阅读视图通知
NSString *const kYLReadLongPressViewNotification = @"kYLReadLongPressViewNotification";

/// Key - 阅读记录
NSString *const kYLReadRecordKey = @"kYLReadRecordKey";
/// Key - 阅读对象
NSString *const kYLReadObjectKey = @"kYLReadObjectKey";


/// 阅读范围(阅读顶部状态栏 + 阅读View + 阅读底部状态栏)
CGRect getReadRect(void){
    // 适配 X 顶部
    CGFloat top = isIPhoneNotchScreen() ? (getStatusBarHeight() - 15) : 0;
    // 适配 X 底部
    CGFloat bottom = isIPhoneNotchScreen() ? 30 : 0;
    return CGRectMake(15, top, CGRectGetWidth(UIScreen.mainScreen.bounds) - 15 * 2.0, CGRectGetHeight(UIScreen.mainScreen.bounds) - top - bottom);
}

/// 阅读View范围
CGRect getReadViewRect(void){
    CGRect rect = getReadRect();
    return CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + kYLReadStatusTopViewHeight, CGRectGetWidth(rect), CGRectGetHeight(rect) - kYLReadStatusTopViewHeight - kYLReadStatusBottomViewHeight );
}

NSTimeInterval getTimer1970(void){
    return [NSDate.date timeIntervalSince1970];
}

NSString *getTimeByFormat(NSString *format,NSDate *date){
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    return [dateFormatter stringFromDate:date ?: NSDate.date];
}



/// 对指定视图截屏:isSave = false
UIImage *screenCapture(UIView *view,BOOL isSave){
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (isSave) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    return image;
    
}
