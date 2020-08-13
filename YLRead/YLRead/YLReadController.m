//
//  YLReadController.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadController.h"
#import "YLReadLeftView.h"
#import "YLReadCatalogView.h"
#import "YLReadMarkView.h"
#import "YLReadLongPressView.h"

#import "YLReadPageViewController.h"
#import "YLReadViewScrollController.h"
#import "YLReadCoverController.h"
#import "UIPageViewController+Extend.h"
#import "YLReadLongPressViewController.h"
#import "YLReadViewBGController.h"

#import "YLReadMarkModel.h"
#import "YLReadConfigure.h"
#import "YLReadChapterListModel.h"

#import "YLGlobalTools.h"
#import "YLReadTextFastParser.h"

@interface YLReadController ()
<YLReadMenuDelegate,
UIPageViewControllerDelegate,UIPageViewControllerDataSource,
YLReadPageViewControllerDelegate,YLReadCoverControllerDelegate,
YLReadContentViewDelegate,YLReadCatalogViewDelegate,YLReadMarkViewDelegate>

{
    /// 用于区分正反面的值(勿动)
    NSInteger _tempNumber;
}



/// 章节列表
@property (nonatomic ,strong) YLReadLeftView *leftView;
/// 翻页控制器 (仿真)
@property (nonatomic ,strong) YLReadPageViewController *pageViewController;
/// 翻页控制器 (滚动)
@property (nonatomic ,strong) YLReadViewScrollController *scrollController;
/// 翻页控制器 (无效果,覆盖)
@property (nonatomic ,strong) YLReadCoverController *coverController;
/// 非滚动模式时,当前显示 YLReadController
@property (nonatomic ,strong) YLReadViewController *currentDisplayController;

@end

@implementation YLReadController

- (void)dealloc{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    // 清理阅读控制器
    [self clearPageController];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _tempNumber = 1;
    self.view.backgroundColor = YLReadConfigure.shareConfigure.bgColor;
    self.extendedLayoutIncludesOpaqueBars = YES;
    if (@available(iOS 11.0, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.leftView];
    [self.view addSubview:self.contentView];

    // 初始化书籍阅读记录
    [self updateReadRecordWithRecordModel:self.readModel.recordModel];
    // 初始化菜单
    _readMenu = [[YLReadMenu alloc]initWithVC:self delegate:self];
    // 初始化控制器
    [self creatPageControllerWithDisplayController:[self getCurrentReadViewControllerWithIsUpdateFont:YES]];
    // 监控阅读长按视图通知
    [self monitorReadLongPressView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Notification

// 监控阅读长按视图通知
- (void)monitorReadLongPressView{
    if (YLReadConfigure.shareConfigure.openLongPress) {
        addNotification_ReadMonitor(self, @selector(longPressViewNotification:));
    }
}

// 处理通知
- (void)longPressViewNotification:(NSNotification *)notification {
    // 获得状态
    NSDictionary *info = notification.userInfo;
    
    // 隐藏菜单
    [self.readMenu showMenuWithIsShow:NO];
        
    // 解析状态
    if (info && [info.allKeys containsObject:kYLRead_ReadMonitor_Notification_key]) {
        BOOL isOpen = [info[kYLRead_ReadMonitor_Notification_key] boolValue];
        self.coverController.gestureRecognizerEnabled = isOpen;
        self.pageViewController.gestureRecognizerEnabled = isOpen;
        self.readMenu.singleTap.enabled = isOpen;
    }
}

#pragma mark - private method

- (void)showLeftViewWithIsShow:(BOOL)isShow{
    [self showLeftViewWithIsShow:isShow completion:nil];
}

/// 辅视图展示
- (void)showLeftViewWithIsShow:(BOOL)isShow completion:(void(^)(void))animationCompletion{
    if (isShow) { // leftView 将要显示
        // 刷新UI
        [self.leftView updateUI];
        // 滚动到阅读记录
        [self.leftView.catalogView scrollRecord];
        // 允许显示
        self.leftView.hidden = NO;
    }
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (isShow) {
            CGRect leftFrame = self.leftView.frame;
            leftFrame.origin = CGPointZero;
            self.leftView.frame = leftFrame;
            
            CGRect contentFrame = self.contentView.frame;
            contentFrame.origin = CGPointMake(kYLReadLeft_Width(), 0);
            self.contentView.frame = contentFrame;
        }else{
            CGRect leftFrame = self.leftView.frame;
            leftFrame.origin = CGPointMake(-kYLReadLeft_Width(), 0);
            self.leftView.frame = leftFrame;
            
            CGRect contentFrame = self.contentView.frame;
            contentFrame.origin = CGPointZero;
            self.contentView.frame = contentFrame;
        }
    } completion:^(BOOL finished) {
        if (!isShow) {
            self.leftView.hidden = YES;
        }
        if (animationCompletion) {
            animationCompletion();
        }
    }];
}

#pragma mark - YLReadCatalogViewDelegate

/// 章节目录选中章节
- (void)catalogViewClickChapter:(YLReadCatalogView *)catalogView chapterListModel:(YLReadChapterListModel *)chapterListModel{
    [self showLeftViewWithIsShow:NO];
    [self.contentView showCover:NO];
    if (self.readModel.recordModel.chapterModel.id == chapterListModel.id) {
        return;
    }
    [self goToChapterWithChapterID:chapterListModel.id toPage:0];
}

#pragma mark - YLReadMarkViewDelegate

/// 书签列表选中书签
- (void)markViewClickMark:(YLReadMarkView *)markView markModel:(YLReadMarkModel *)markModel{
    [self showLeftViewWithIsShow:NO];
    [self.contentView showCover:NO];
    [self goToChapterWithChapterID:markModel.chapterID location:markModel.location];
}

#pragma mark - YLReadContentViewDelegate

/// 点击遮罩
- (void)contentViewClickCover:(YLReadContentView *)contentView{
    [self showLeftViewWithIsShow:NO];
}

#pragma mark - YLReadMenuDelegate

/// 菜单将要显示
- (void)readMenuWillDisplay:(YLReadMenu *)readMenu{
    // 检查当前内容是否包含书签    
    [readMenu.topView checkForMark];
    // 刷新阅读进度
    [readMenu.bottomView.progressView reloadProgress];
}

/// 点击返回
- (void)readMenuClickBack:(YLReadMenu *)readMenu{
    // 移除 DZMPageViewController，因为这个仿真模式的 UIPageViewController 不手动移除会照成内存泄漏，对象不释放
    // 它需要提前手动移除，要不然会导致释放不了走不了 deinit() 函数
    if (YLReadConfigure.shareConfigure.effectType == YLEffectTypeSimulation) {
        [self clearPageController];
    }
    // 清空坐标
    kYLReadRecordCurrentChapterLocation = -1;

    // 返回
    [self.navigationController popViewControllerAnimated:YES];
}

/// 点击书签
- (void)readMenuClickMark:(YLReadMenu *)readMenu topView:(YLReadTopView *)topView markButton:(UIButton *)markButton{
    markButton.selected = !markButton.selected;
    if (markButton.selected) {
        [self.readModel insetMark];
    }else{
        [self.readModel removeMark];
    }
    [topView updateMarkButton];
}

/// 点击目录
- (void)readMenuClickCatalogue:(YLReadMenu *)readMenu{
    [self showLeftViewWithIsShow:YES];
    [self.contentView showCover:YES];
    [readMenu showMenuWithIsShow:NO];
}

/// 点击上一章
- (void)readMenuClickPreviousChapter:(YLReadMenu *)readMenu{
    if (self.readModel.recordModel.isFirstChapter) {
        NSLog(@"已经是第一章了");
    }else{
        [self goToChapterWithChapterID:self.readModel.recordModel.chapterModel.previousChapterID toPage:0];
        // 检查当前内容是否包含书签
        [readMenu.topView checkForMark];
        // 刷新阅读进度
        [readMenu.bottomView.progressView reloadProgress];
    }
}

/// 点击下一章
- (void)readMenuClickNextChapter:(YLReadMenu *)readMenu {
    if (self.readModel.recordModel.isLastChapter) {
        NSLog(@"已经是最后一章了");
    }else{
        [self goToChapterWithChapterID:self.readModel.recordModel.chapterModel.nextChapterID toPage:0];
        // 检查当前内容是否包含书签
        [readMenu.topView checkForMark];
        // 刷新阅读进度
        [readMenu.bottomView.progressView reloadProgress];
    }
}

/// 拖拽阅读记录
- (void)readMenuDraggingProgress:(YLReadMenu *)readMenu toPage:(NSInteger)toPage{
    if (self.readModel.recordModel.page != toPage){
        self.readModel.recordModel.page = toPage;
        [self creatPageControllerWithDisplayController:[self getCurrentReadViewController]];
         // 检查当前内容是否包含书签
        [readMenu.topView checkForMark];
     }
}

/// 拖拽章节进度(总文章进度,网络文章也可以使用)
- (void)readMenuDraggingProgress:(YLReadMenu *)readMenu toChapterID:(NSInteger)toChapterID toPage:(NSInteger)toPage{
    // 不是当前阅读记录章节
    if (toChapterID != self.readModel.recordModel.chapterModel.id) {
        [self goToChapterWithChapterID:toChapterID toPage:toPage];
        // 检查当前内容是否包含书签
        [readMenu.topView checkForMark];
    }
}

/// 切换进度显示(分页 || 总进度)
- (void)readMenuClickDisplayProgress:(YLReadMenu *)readMenu{
    [self creatPageControllerWithDisplayController:[self getCurrentReadViewController]];
}

/// 点击切换背景颜色
- (void)readMenuClickBGColor:(YLReadMenu *)readMenu{
    // 切换背景颜色可以根据需求判断修改目录背景颜色,文字颜色等等(目前放在showLeftView方法中,leftView将要出现的时候处理)
    self.view.backgroundColor = YLReadConfigure.shareConfigure.bgColor;
    [self creatPageControllerWithDisplayController:[self getCurrentReadViewController]];
}

/// 点击切换字体
- (void)readMenuClickFont:(YLReadMenu *)readMenu{
    [self creatPageControllerWithDisplayController:[self getCurrentReadViewControllerWithIsUpdateFont:YES]];
}

/// 点击切换字体大小
- (void)readMenuClickFontSize:(YLReadMenu *)readMenu{
    [self creatPageControllerWithDisplayController:[self getCurrentReadViewControllerWithIsUpdateFont:YES]];
}

/// 点击切换间距
- (void)readMenuClickSpacing:(YLReadMenu *)readMenu{
    [self creatPageControllerWithDisplayController:[self getCurrentReadViewControllerWithIsUpdateFont:YES]];
}

/// 点击切换翻页效果
- (void)readMenuClickEffect:(YLReadMenu *)readMenu{
    [self creatPageControllerWithDisplayController:[self getCurrentReadViewController]];
}

#pragma mark - setter and getter

// 目录侧滑栏
- (YLReadLeftView *)leftView{
    if (_leftView == nil) {
        _leftView = [[YLReadLeftView alloc] initWithFrame:CGRectMake(-kYLReadLeft_Width(), 0, kYLReadLeft_Width(), kYLReadLeft_Height())];
        _leftView.catalogView.readModel = self.readModel;
        _leftView.catalogView.delegate = self;
        _leftView.markView.readModel = self.readModel;
        _leftView.markView.delegate = self;
        _leftView.hidden = YES;
    }
    return _leftView;
}

// 阅读视图
- (YLReadContentView *)contentView{
    if (_contentView == nil) {
        _contentView = [[YLReadContentView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds))];
        _contentView.delegate = self;
    }
    return _contentView;
}

@end

    


@implementation YLReadController (Operation)

/// 获取指定阅读记录阅读页
- (YLReadViewController *)getReadViewController:(YLReadRecordModel *)recordModel{
    if (recordModel){
        if (YLReadConfigure.shareConfigure.openLongPress) { // 需要返回支持长按的控制器
            YLReadLongPressViewController *controller = [[YLReadLongPressViewController alloc]init];
            controller.recordModel = recordModel;
            controller.readModel = self.readModel;
            return controller;
        }else{ // 无长按功能
            YLReadViewController *controller = [[YLReadViewController alloc]init];
            controller.recordModel = recordModel;
            controller.readModel = self.readModel;
            return controller;
        }
    }
    return nil;
}

/// 获取当前阅读记录阅读页
- (YLReadViewController *)getCurrentReadViewController{
    return [self getCurrentReadViewControllerWithIsUpdateFont:NO];
}

- (YLReadViewController *)getCurrentReadViewControllerWithIsUpdateFont:(BOOL)isUpdateFont{
    if (YLReadConfigure.shareConfigure.effectType != YLEffectTypeScroll) { // 滚动模式不需要创建
        if (isUpdateFont) {
            [self.readModel.recordModel updateFont];
        }
        return [self getReadViewController:[self.readModel.recordModel copyTheModel]];
    }
    return nil;
}

/// 获取上一页控制器
- (UIViewController *)getAboveReadViewController{
    YLReadRecordModel *recordModel = [self getAboveReadRecordModelWithRecordModel:self.readModel.recordModel];
    if (recordModel == nil) { return nil; }
    return [self getReadViewController:recordModel];
}

/// 获取下一页控制器
- (UIViewController *)getBelowReadViewController{
    YLReadRecordModel *recordModel = [self getBelowReadRecordModelWithRecordModel:self.readModel.recordModel];
    if (recordModel == nil) { return nil; }
    return [self getReadViewController:recordModel];
}

/// 获取当前记录上一页阅读记录
- (YLReadRecordModel *)getAboveReadRecordModelWithRecordModel:(YLReadRecordModel *)recordModel{
    // 阅读记录为空
    if (recordModel.chapterModel == nil) { return nil; }
    // 复制
    recordModel = [recordModel copyTheModel];
    // 书籍ID
    NSString *bookID = recordModel.bookID;
    // 章节ID
    NSInteger chapterID = recordModel.chapterModel.previousChapterID;
    // 第一章 第一页
    if (recordModel.isFirstChapter && recordModel.isFirstPage) {
        NSLog(@"已经是第一页了");
        return nil;
    }
    // 第一页
    if (recordModel.isFirstPage) {
        // 检查是否存在章节内容
        BOOL isExist = [YLReadChapterModel isExistWithBookID:bookID chapterID:chapterID];
        // 存在 || 不存在(但是为本地阅读)
        if (isExist || self.readModel.bookSourceType == YLBookSourceTypeLocal) {
            if (!isExist) {
                // 获取章节数据
                [YLReadTextFastParser parserWithReadModel:self.readModel chapterID:chapterID];
            }
            // 修改阅读记录
            [recordModel modifyWithChapterID:chapterID toPage:-1 isSave:NO];
        }else{ // 加载网络章节数据
            // ----- 搜索网络小说 -----
            return nil;
        }
        
    }else{
        [recordModel previousPage];
    }
    return recordModel;
}

/// 获取当前记录下一页阅读记录
- (YLReadRecordModel *)getBelowReadRecordModelWithRecordModel:(YLReadRecordModel *)recordModel{
    // 阅读记录为空
    if (recordModel.chapterModel == nil) { return nil; }
    // 复制
    recordModel = [recordModel copyTheModel];
    // 书籍ID
    NSString *bookID = recordModel.bookID;
    // 章节ID
    NSInteger chapterID = recordModel.chapterModel.nextChapterID;
    // 最后一章 最后一页
    if (recordModel.isLastChapter && recordModel.isLastPage) {
        NSLog(@"已经是最后一页了");
        return nil;
    }
    // 最后一页
    if (recordModel.isLastPage) {
            
        // 检查是否存在章节内容
        BOOL isExist = [YLReadChapterModel isExistWithBookID:bookID chapterID:chapterID];
        // 存在 || 不存在(但是为本地阅读)
        if (isExist || self.readModel.bookSourceType == YLBookSourceTypeLocal) {
            if (!isExist) {
                // 获取章节数据
                [YLReadTextFastParser parserWithReadModel:self.readModel chapterID:chapterID];
            }
            // 修改阅读记录
            [recordModel modifyWithChapterID:chapterID toPage:0 isSave:NO];
        }else{ // 加载网络章节数据
            // ----- 搜索网络小说 -----
            return nil;
        }
    }else{
        [recordModel nextPage];
    }
    return recordModel;    
}

/// 获取仿真模式背面(只用于仿真模式背面显示)
- (YLReadViewBGController *)getReadViewBGControllerWithRecordModel:(YLReadRecordModel *)recordModel{
    return [self getReadViewBGControllerWithRecordModel:recordModel targetView:[self getReadViewController:recordModel].view];
}

- (YLReadViewBGController *)getReadViewBGControllerWithRecordModel:(YLReadRecordModel *)recordModel targetView:(UIView *)targetView{
    YLReadViewBGController *vc = [[YLReadViewBGController alloc]init];
    vc.recordModel = recordModel;
    targetView = targetView ? : [self getReadViewController:recordModel].view;
    vc.targetView = targetView;
    return vc;
}





/// 跳转指定章节(指定页面)
- (void)goToChapterWithChapterID:(NSInteger)chapterID{
    [self goToChapterWithChapterID:chapterID toPage:0];
}
- (void)goToChapterWithChapterID:(NSInteger)chapterID toPage:(NSInteger)toPage{
    [self goToChapterWithChapterID:chapterID number:toPage isLocation:NO];
}

/// 跳转指定章节(指定坐标)
- (void)goToChapterWithChapterID:(NSInteger)chapterID location:(NSInteger)location{
    [self goToChapterWithChapterID:chapterID number:location isLocation:YES];
}

/// 跳转指定章节 number:页码或者坐标 isLocation:是页码(false)还是坐标(true)
- (void)goToChapterWithChapterID:(NSInteger)chapterID  number:(NSInteger)number isLocation:(BOOL)isLocation{
       
    // 复制阅读记录
    YLReadRecordModel *recordModel = [self.readModel.recordModel copyTheModel];
    // 书籍ID
    NSString *bookID = recordModel.bookID;
       
    // 检查是否存在章节内容
    BOOL isExist = [YLReadChapterModel isExistWithBookID:bookID chapterID:chapterID];
    
     // 存在 || 不存在(但是为本地阅读)
    if (isExist || self.readModel.bookSourceType == YLBookSourceTypeLocal) {
        if (!isExist) {
            // 获取章节数据
            [YLReadTextFastParser parserWithReadModel:self.readModel chapterID:chapterID];
        }
        if (isLocation) {
            // 坐标定位
            [recordModel modifyWithChapterID:chapterID location:number isSave:NO];
        }else{
            // 分页定位
            [recordModel modifyWithChapterID:chapterID toPage:number isSave:NO];
        }
        // 阅读阅读记录
        [self updateReadRecordWithRecordModel:recordModel];
        // 展示阅读
        [self creatPageControllerWithDisplayController:[self getReadViewController:recordModel]];
        
    }else{ // 加载网络章节数据
        
    }
    // ----- 搜索网络小说 -----
}

/// 更新阅读记录(左右翻页模式)
- (void)updateReadRecordWithController:(YLReadViewController *)controller{
    [self updateReadRecordWithRecordModel:controller.recordModel];
}

/// 更新阅读记录(左右翻页模式)
- (void)updateReadRecordWithRecordModel:(YLReadRecordModel *)recordModel{
    if (recordModel) {
        self.readModel.recordModel = recordModel;
        [self.readModel.recordModel save];
        kYLReadRecordCurrentChapterLocation = recordModel.locationFirst;
    }
}

@end


@implementation YLReadController (EffectType)

/// 清理所有阅读控制器
- (void)clearPageController{
    [self.currentDisplayController removeFromParentViewController];
    _currentDisplayController = nil;
    
    if (_pageViewController) {
        [_pageViewController.view removeFromSuperview];
        [_pageViewController removeFromParentViewController];
        _pageViewController = nil;
    }
    
    if (_coverController) {
        [_coverController.view removeFromSuperview];
        [_coverController removeFromParentViewController];
        _coverController = nil;
    }
    
    if (_scrollController) {
        [_scrollController.view removeFromSuperview];
        [_scrollController removeFromParentViewController];
        _scrollController = nil;
    }
}


/// 创建阅读视图
- (void)creatPageController{
    [self creatPageControllerWithDisplayController:nil];
}

- (void)creatPageControllerWithDisplayController:(YLReadViewController *)displayController{
    // 清理
    [self clearPageController];
    
    // 翻页类型
    switch (YLReadConfigure.shareConfigure.effectType) {
        case YLEffectTypeSimulation:{// 仿真
            if (displayController == nil) { return; }

            // 创建
            NSDictionary *options = @{UIPageViewControllerOptionSpineLocationKey:@(UIPageViewControllerSpineLocationMin)};
            _pageViewController = [[YLReadPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
            // 自定义tap手势的相关代理
            _pageViewController.YLDelegate = self;
            _pageViewController.delegate = self;
            _pageViewController.dataSource = self;
            [self.contentView insertSubview:_pageViewController.view atIndex:0];
            _pageViewController.view.backgroundColor = UIColor.clearColor;
            _pageViewController.view.frame = self.contentView.bounds;
            // 翻页背部带文字效果
            _pageViewController.doubleSided = YES;
            [_pageViewController setViewControllers:(displayController ? @[displayController] : nil) direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            
        } break;
        case YLEffectTypeTranslation:{// 平移
            
            if (displayController == nil) { return; }
            
            // 创建
            NSDictionary *options = @{UIPageViewControllerOptionSpineLocationKey:@(UIPageViewControllerSpineLocationMin)};
            _pageViewController = [[YLReadPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
            // 自定义tap手势的相关代理
            _pageViewController.YLDelegate = self;
            _pageViewController.delegate = self;
            _pageViewController.dataSource = self;
            [self.contentView insertSubview:_pageViewController.view atIndex:0];
            _pageViewController.view.backgroundColor = UIColor.clearColor;
            _pageViewController.view.frame = self.contentView.bounds;
            [_pageViewController setViewControllers:(displayController ? @[displayController] : nil) direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        } break;
        case YLEffectTypeScroll:{// 滚动
            _scrollController = [[YLReadViewScrollController alloc]init];
            _scrollController.vc = self;
            [self.contentView insertSubview:_scrollController.view atIndex:0];
            _scrollController.view.frame = self.contentView.bounds;
            _scrollController.view.backgroundColor = UIColor.clearColor;
            [self addChildViewController:_scrollController];
        } break;
        default:{// 覆盖 无效果
            if (displayController == nil) { return; }
            _coverController = [[YLReadCoverController alloc]init];
            _coverController.delegate = self;
            [self.contentView insertSubview:_coverController.view atIndex:0];
            _coverController.view.frame = self.contentView.bounds;
            _coverController.view.backgroundColor = UIColor.clearColor;
            [_coverController setController:displayController];
            if (YLReadConfigure.shareConfigure.effectType == YLEffectTypeNone) {
                _coverController.openAnimate = NO;
            }
        }break;
    }
    // 记录
    _currentDisplayController = displayController;
}

/// 手动设置翻页(注意: 非滚动模式调用)
- (void)setViewControllerWithDisplayController:(YLReadViewController *)displayController isAbove:(BOOL)isAbove animated:(BOOL)animated{
    
    if (displayController != nil) {
        // 仿真
        if (_pageViewController != nil) {
            UIPageViewControllerNavigationDirection direction = isAbove ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward;

            if (YLReadConfigure.shareConfigure.effectType == YLEffectTypeTranslation) { // 平移
                [_pageViewController setViewControllers:(displayController ? @[displayController] : nil) direction:direction animated:animated completion:nil];
            } else { // 仿真
                [_pageViewController setViewControllers:@[displayController,[self getReadViewBGControllerWithRecordModel:displayController.recordModel targetView:displayController.view]] direction:direction animated:animated completion:nil];
            }
            return;
        }
        
        // 覆盖 无效果
        if (_coverController != nil) {
            [_coverController setController:displayController animated:animated isAbove:isAbove];
            return;
        }
        
        // 记录
        _currentDisplayController = displayController;
    }
}

#pragma mark - YLReadCoverControllerDelegate

/// 切换结果
- (void)coverController:(YLReadCoverController *)coverController currentController:(UIViewController *)currentController finish:(BOOL)isFinish{
    // 记录
    _currentDisplayController = (YLReadViewController *)currentController;
    // 更新阅读记录
    [self updateReadRecordWithController:_currentDisplayController];
}

/// 将要显示的控制器
- (void)coverController:(YLReadCoverController *)coverController willTransitionToPendingController:(UIViewController *)pendingController{
    [self.readMenu showMenuWithIsShow:NO];
}

/// 获取上一个控制器
- (UIViewController *)coverController:(YLReadCoverController *)coverController getAboveControllerWithCurrentController:(UIViewController *)currentController{
    return [self getAboveReadViewController];
}

/// 获取下一个控制器
- (UIViewController *)coverController:(YLReadCoverController *)coverController getBelowControllerWithCurrentController:(UIViewController *)currentController{
    return [self getBelowReadViewController];
}

#pragma mark - UIPageViewControllerDelegate

/// 切换结果
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    // 记录
    _currentDisplayController = (YLReadViewController *)pageViewController.viewControllers.firstObject;
    // 更新阅读记录
    [self updateReadRecordWithController:_currentDisplayController];
}

/// 准备切换
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
    [self.readMenu showMenuWithIsShow:NO];
}

#pragma mark - YLReadPageViewControllerDelegate

/// 获取上一页
- (void)pageViewController:(YLReadPageViewController *)pageViewController getBeforeViewController:(UIViewController *)viewController{
    // 获取上一页
    YLReadViewController *readViewController = (YLReadViewController *)[self getAboveReadViewController];
    // 手动设置
    [self setViewControllerWithDisplayController:readViewController isAbove:YES animated:YES];
    // 更新阅读记录
    [self updateReadRecordWithController:readViewController];
    // 关闭菜单
    [self.readMenu showMenuWithIsShow:NO];
}

/// 获取下一页
- (void)pageViewController:(YLReadPageViewController *)pageViewController getAfterViewController:(UIViewController *)viewController{
    // 获取下一页
    YLReadViewController *readViewController = (YLReadViewController *)[self getBelowReadViewController];
    // 手动设置
    [self setViewControllerWithDisplayController:readViewController isAbove:NO animated:YES];
    // 更新阅读记录
    [self updateReadRecordWithController:readViewController];
    // 关闭菜单
    [self.readMenu showMenuWithIsShow:NO];
}

#pragma mark - UIPageViewControllerDataSource

/// 获取上一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    if (YLReadConfigure.shareConfigure.effectType == YLEffectTypeTranslation) { // 平移
        return [self getAboveReadViewController];
    } else { // 仿真
        // 翻页累计
        _tempNumber -= 1;
        // 获取当前页阅读记录
        YLReadRecordModel *recordModel = ((YLReadViewController *)viewController).recordModel;
        // 如果没有则从背面页面获取
        if (recordModel == nil) {
            recordModel = ((YLReadViewBGController *)viewController).recordModel;
        }
        
        if (labs(_tempNumber) % 2 == 0) { // 背面
            recordModel = [self getAboveReadRecordModelWithRecordModel:recordModel];
            
            return [self getReadViewBGControllerWithRecordModel:recordModel];
            
        }else{ // 内容
            return [self getReadViewController:recordModel];
        }
    }
}

/// 获取下一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    if (YLReadConfigure.shareConfigure.effectType == YLEffectTypeTranslation) { // 平移
        return [self getBelowReadViewController];
    } else { // 仿真
        // 翻页累计
        _tempNumber += 1;
        // 获取当前页阅读记录
        YLReadRecordModel *recordModel = ((YLReadViewController *)viewController).recordModel;
        // 如果没有则从背面页面获取
        if (recordModel == nil) {
            recordModel = ((YLReadViewBGController *)viewController).recordModel;
        }
        
        if (labs(_tempNumber) % 2 == 0) { // 背面
            return [self getReadViewBGControllerWithRecordModel:recordModel];
        }else{ // 内容
            recordModel = [self getBelowReadRecordModelWithRecordModel:recordModel];
            return [self getReadViewController:recordModel];
        }
    }
}
    

@end
