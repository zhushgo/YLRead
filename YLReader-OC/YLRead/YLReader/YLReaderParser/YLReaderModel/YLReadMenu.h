//
//  YLReadMenu.h
//  YLRead
//
//  Created by 苏沫离 on 2020/6/30.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLReadTopView.h"
#import "YLReadBottomView.h"
#import "YLReadSettingView.h"

NS_ASSUME_NONNULL_BEGIN

@class YLReadMenu;
@protocol YLReadMenuDelegate <NSObject>

@optional;
/// 菜单将要显示
- (void)readMenuWillDisplay:(YLReadMenu *)readMenu;

/// 菜单完成显示
- (void)readMenuDidDisplay:(YLReadMenu *)readMenu;
    
/// 菜单将要隐藏
- (void)readMenuWillEndDisplay:(YLReadMenu *)readMenu;

/// 菜单完成隐藏
- (void)readMenuDidEndDisplay:(YLReadMenu *)readMenu;

/// 点击返回
- (void)readMenuClickBack:(YLReadMenu *)readMenu;

/// 点击书签
- (void)readMenuClickMark:(YLReadMenu *)readMenu topView:(YLReadTopView *)topView markButton:(UIButton *)markButton;

/// 点击目录
- (void)readMenuClickCatalogue:(YLReadMenu *)readMenu;

/// 点击切换日夜间
- (void)readMenuClickDayAndNight:(YLReadMenu *)readMenu;

/// 点击上一章
- (void)readMenuClickPreviousChapter:(YLReadMenu *)readMenu;

/// 点击下一章
- (void)readMenuClickNextChapter:(YLReadMenu *)readMenu;

/// 拖拽章节进度(分页进度)
- (void)readMenuDraggingProgress:(YLReadMenu *)readMenu toPage:(NSInteger)toPage;

/// 拖拽章节进度(总文章进度,网络文章也可以使用)
- (void)readMenuDraggingProgress:(YLReadMenu *)readMenu toChapterID:(NSInteger)toChapterID toPage:(NSInteger)toPage;

/// 点击切换背景颜色
- (void)readMenuClickBGColor:(YLReadMenu *)readMenu;

/// 点击切换字体
- (void)readMenuClickFont:(YLReadMenu *)readMenu;

/// 点击切换字体大小
- (void)readMenuClickFontSize:(YLReadMenu *)readMenu;

/// 切换进度显示(分页 || 总进度)
- (void)readMenuClickDisplayProgress:(YLReadMenu *)readMenu;

/// 点击切换间距
- (void)readMenuClickSpacing:(YLReadMenu *)readMenu;

/// 点击切换翻页效果
- (void)readMenuClickEffect:(YLReadMenu *)readMenu;

@end

@class YLReadController,YLReadContentView;
@interface YLReadMenu : NSObject

/// 控制器
@property (nonatomic ,weak) YLReadController *vc;

/// 阅读主视图
@property (nonatomic ,weak) YLReadContentView *contentView;

/// 代理
@property (nonatomic ,weak)id <YLReadMenuDelegate> delegate;

/// 菜单显示状态
@property (nonatomic ,assign) BOOL isMenuShow;

/// 单击手势
@property (nonatomic ,strong) UITapGestureRecognizer *singleTap;

/// TopView
@property (nonatomic ,strong) YLReadTopView *topView;

/// BottomView
@property (nonatomic ,strong) YLReadBottomView *bottomView;

/// SettingView
@property (nonatomic ,strong) YLReadSettingView *settingView;

/// 日夜间遮盖
@property (nonatomic ,strong) UIView *cover;

- (instancetype)initWithVC:(YLReadController *)vc delegate:(id<YLReadMenuDelegate>)delegate;

///  菜单展示
- (void)showMenuWithIsShow:(BOOL)isShow;

/// TopView展示
- (void)showTopViewWithIsShow:(BOOL)isShow completion:(void(^)(void))animationCompletion;

/// BottomView展示
- (void)showBottomViewWithIsShow:(BOOL)isShow  completion:(void(^)(void))animationCompletion;
   
/// SettingView展示
- (void)showSettingViewWithIsShow:(BOOL)isShow  completion:(void(^)(void))animationCompletion;

@end

NS_ASSUME_NONNULL_END
