//
//  YLReadPageViewController.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/9.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YLReadPageViewController;
@protocol YLReadPageViewControllerDelegate <NSObject>

/// 获取上一页
- (void)pageViewController:(YLReadPageViewController *)pageViewController getBeforeViewController:(UIViewController *)viewController;

/// 获取下一页
- (void)pageViewController:(YLReadPageViewController *)pageViewController getAfterViewController:(UIViewController *)viewController;

@end

/// 翻页控制器 (仿真)
@interface YLReadPageViewController : UIPageViewController

@property (nonatomic ,weak) id <YLReadPageViewControllerDelegate> YLDelegate;

@end


NS_ASSUME_NONNULL_END
