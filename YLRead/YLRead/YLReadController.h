//
//  YLReadController.h
//  FM
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLReadContentView.h"
#import "YLReadModel.h"
#import "YLReadRecordModel.h"
#import "YLReadChapterModel.h"
#import "YLReadMenu.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLReadController : UIViewController

/// 阅读对象
@property (nonatomic ,strong) YLReadModel *readModel;
/// 阅读菜单
@property (nonatomic ,strong) YLReadMenu *readMenu;

@property (nonatomic ,strong) YLReadContentView *contentView;

@end


@class YLReadViewController,YLReadViewBGController;
@interface YLReadController (Operation)

/// 获取指定阅读记录阅读页
- (YLReadViewController *)getReadViewController:(YLReadRecordModel *)recordModel;

/// 获取当前阅读记录阅读页
- (YLReadViewController *)getCurrentReadViewController;
- (YLReadViewController *)getCurrentReadViewControllerWithIsUpdateFont:(BOOL)isUpdateFont;
    
/// 获取上一页控制器
- (UIViewController *)getAboveReadViewController;
/// 获取下一页控制器
- (UIViewController *)getBelowReadViewController;

/// 获取仿真模式背面(只用于仿真模式背面显示)
- (YLReadViewBGController *)getReadViewBGControllerWithRecordModel:(YLReadRecordModel *)recordModel;
- (YLReadViewBGController *)getReadViewBGControllerWithRecordModel:(YLReadRecordModel *)recordModel targetView:(UIView *)targetView;

/// 跳转指定章节(指定页面)
- (void)goToChapterWithChapterID:(NSInteger)chapterID;
- (void)goToChapterWithChapterID:(NSInteger)chapterID toPage:(NSInteger)toPage;

/// 跳转指定章节(指定坐标)
- (void)goToChapterWithChapterID:(NSInteger)chapterID location:(NSInteger)location;

/// 跳转指定章节 number:页码或者坐标 isLocation:是页码(false)还是坐标(true)
- (void)goToChapterWithChapterID:(NSInteger)chapterID  number:(NSInteger)number isLocation:(BOOL)isLocation;

/// 获取当前记录上一页阅读记录
- (YLReadRecordModel *)getAboveReadRecordModelWithRecordModel:(YLReadRecordModel *)recordModel;
/// 获取当前记录下一页阅读记录
- (YLReadRecordModel *)getBelowReadRecordModelWithRecordModel:(YLReadRecordModel *)recordModel;

/// 更新阅读记录(左右翻页模式)
- (void)updateReadRecordWithController:(YLReadViewController *)controller;
/// 更新阅读记录(左右翻页模式)
- (void)updateReadRecordWithRecordModel:(YLReadRecordModel *)recordModel;
@end


@interface YLReadController (EffectType)

/// 清理所有阅读控制器
- (void)clearPageController;

/// 创建阅读视图
- (void)creatPageController;
- (void)creatPageControllerWithDisplayController:(YLReadViewController *)displayController;

/// 手动设置翻页(注意: 非滚动模式调用)
- (void)setViewControllerWithDisplayController:(YLReadViewController *)displayController isAbove:(BOOL)isAbove animated:(BOOL)animated;


@end


NS_ASSUME_NONNULL_END
