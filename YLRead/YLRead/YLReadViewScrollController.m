//
//  YLReadViewScrollController.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#define HomeCellIdentifer @"YLReadHomeViewCell"
#define ReadCellIdentifer @"YLReadViewCell"

#import "YLReadViewScrollController.h"
#import "YLReadHomeViewCell.h"
#import "YLReadViewCell.h"

#import "YLReadConfigure.h"
#import "YLReadViewStatusTopView.h"
#import "YLReadViewStatusBottomView.h"

#import "YLReadController.h"
#import "YLReadPageModel.h"
#import "YLReadChapterModel.h"
#import "YLGlobalTools.h"
#import "YLReadConfigure.h"
#import "YLReadTextFastParser.h"

@interface YLReadViewScrollController ()
<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>


/// 顶部状态栏
@property (nonatomic ,strong) YLReadViewStatusTopView *topView;
/// 底部状态栏
@property (nonatomic ,strong) YLReadViewStatusBottomView *bottomView;
/// 阅读视图
@property (nonatomic ,strong) UITableView *tableView;
/// 当前阅读章节ID列表(只会存放本次阅读的列表)
@property (nonatomic ,strong) NSMutableArray<NSNumber *> *chapterIDs;
/// 当前正在加载的章节
@property (nonatomic ,strong) NSMutableArray<NSNumber *> *loadChapterIDs;
/// 当前阅读的章节列表,通过已有的章节ID列表,来获取章节模型。
@property (nonatomic ,strong) NSMutableDictionary<NSString * , YLReadChapterModel *> *chapterModels;


/// 记录滚动坐标
@property (nonatomic ,assign) CGPoint scrollPoint;
/// 是否为向上滚动
@property (nonatomic ,assign) BOOL isScrollUp;

@end

@implementation YLReadViewScrollController

- (void)setReadVC:(UIViewController *)readVC{
    _vc = readVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isScrollUp = YES;
    self.view.backgroundColor = YLReadConfigure.shareConfigure.bgColor;
    self.extendedLayoutIncludesOpaqueBars = YES;
    if (@available(iOS 11.0, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.topView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomView];
    
    // 阅读记录开始阅读
    [self.chapterIDs addObject:@(self.vc.readModel.recordModel.chapterModel.id)];
    
    // 刷新阅读进度
    [self reloadProgress];
    
    // 定位上次阅读位置
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.vc.readModel.recordModel.page inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark - public method

/// 刷新阅读进度显示
- (void)reloadProgress{
    if (YLReadConfigure.shareConfigure.progressType == YLProgressTypeTotal) {// 总进度
        // 当前阅读进度
        float progress = getReadToalProgress(self.vc.readModel, self.vc.readModel.recordModel);
        // 显示进度
        self.bottomView.progress.text = getReadToalProgressString(progress);
        
    }else{ // 分页进度
        // 显示进度
        self.bottomView.progress.text = [NSString stringWithFormat:@"%ld",(self.vc.readModel.recordModel.page + 1) / self.vc.readModel.recordModel.chapterModel.pageCount];
    }
}

/// 获取章节内容模型
- (YLReadChapterModel *)getChapterModelWithChapterID:(NSInteger)chapterID{
    YLReadChapterModel *chapterModel = nil;
    if ([self.chapterModels.allKeys containsObject:[NSString stringWithFormat:@"%ld",chapterID]]) {// 内存中存在章节内容
        chapterModel = self.chapterModels[[NSString stringWithFormat:@"%ld",chapterID]];
    }else{ // 内存中不存在章节列表
        // 检查是否存在章节内容
        BOOL isExist = [YLReadChapterModel isExistWithBookID:self.vc.readModel.bookID chapterID:chapterID];
        if (isExist || self.vc.readModel.bookSourceType == YLBookSourceTypeLocal) {// 存在 || 不存在(但是为本地阅读)
            // 获取章节数据
            if (!isExist) {
                chapterModel = [YLReadTextFastParser parserWithReadModel:self.vc.readModel chapterID:chapterID];
            }else{
                chapterModel = [YLReadChapterModel modelWithBookID:self.vc.readModel.bookID chapterID:chapterID];
            }
            [self.chapterModels setValue:chapterModel forKey:[NSString stringWithFormat:@"%ld",chapterID]];
        }
    }
    return chapterModel;
}

 
/// 预加载上一个章节
- (void)preloadingPrevious:(YLReadChapterModel *)chapterModel{
    // 章节ID
    NSInteger chapterID = chapterModel.previousChapterID;
    
    // 是否有章节 || 是否为第一章 || 是否正在加载 || 是否已经存在阅读列表
    if ((chapterModel == nil) || chapterModel.isFirstChapter ||
        [self.loadChapterIDs containsObject:@(chapterID)] ||
        [self.chapterIDs containsObject:@(chapterID)]) {
        return;
    }
    
    // 加入加载列表
    [self.loadChapterIDs addObject:@(chapterID)];
    // 书籍ID
    NSString *bookID = chapterModel.bookID;
    
    // 预加载下一章
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isExist = [YLReadChapterModel isExistWithBookID:bookID chapterID:chapterID];
        if (isExist || self.vc.readModel.bookSourceType == YLBookSourceTypeLocal) {// 存在 || 不存在(但是为本地阅读)
            YLReadChapterModel *tempChapterModel = nil;// 章节内容
            // 获取章节数据
               if (!isExist) {
                   tempChapterModel = [YLReadTextFastParser parserWithReadModel:self.vc.readModel chapterID:chapterID];
               }else{
                   tempChapterModel = [YLReadChapterModel modelWithBookID:bookID chapterID:chapterID];
               }
            // 加入阅读内容列表
            [self.chapterModels setValue:tempChapterModel forKey:[NSString stringWithFormat:@"%ld",chapterID]];

            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self){
                    
                    // 当前章节索引
                    NSInteger previousIndex = MAX(0, [self.chapterIDs indexOfObject:@(chapterModel.id)] - 1);
                    
                    // 加载列表索引
                    NSInteger loadIndex = [self.loadChapterIDs indexOfObject:@(chapterID)];
                    
                    // 阅读章节ID列表加入
                    [self.chapterIDs insertObject:@(chapterID) atIndex:previousIndex];
                    
                    // 移除加载列表
                    [self.loadChapterIDs removeObjectAtIndex:loadIndex];
                    
                    // 刷新
                    [self.tableView reloadData];
                    
                    // 定位
                    self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + tempChapterModel.pageTotalHeight);
                }
            });
            
        }else{// 加载网络章节数据
            
        }
    });
}
        
/// 预加载下一个章节
- (void)preloadingNext:(YLReadChapterModel *)chapterModel{
    // 章节ID
    NSInteger chapterID = chapterModel.nextChapterID;
    // 是否有章节 || 是否为最后一章 || 是否正在加载 || 是否已经存在阅读列表
    if ((chapterModel == nil) || chapterModel.isLastChapter ||
        [self.loadChapterIDs containsObject:@(chapterID)] ||
        [self.chapterIDs containsObject:@(chapterID)]) {
        return;
    }
        
    // 加入加载列表
    [self.loadChapterIDs addObject:@(chapterID)];
    // 书籍ID
    NSString *bookID = chapterModel.bookID;
    
    // 预加载下一章
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 检查是否存在章节内容
        BOOL isExist = [YLReadChapterModel isExistWithBookID:bookID chapterID:chapterID];
        // 存在 || 不存在(但是为本地阅读)
        if (isExist || self.vc.readModel.bookSourceType == YLBookSourceTypeLocal) {// 存在 || 不存在(但是为本地阅读)
            YLReadChapterModel *tempChapterModel = nil;// 章节内容
            // 获取章节数据
               if (!isExist) {
                   tempChapterModel = [YLReadTextFastParser parserWithReadModel:self.vc.readModel chapterID:chapterID];
               }else{
                   tempChapterModel = [YLReadChapterModel modelWithBookID:bookID chapterID:chapterID];
               }
            // 加入阅读内容列表
            [self.chapterModels setValue:tempChapterModel forKey:[NSString stringWithFormat:@"%ld",chapterID]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self){
                    
                    // 当前章节索引
                    NSInteger nextIndex = [self.chapterIDs indexOfObject:@(chapterModel.id)] + 1;
                    
                    // 加载列表索引
                    NSInteger loadIndex = [self.loadChapterIDs indexOfObject:@(chapterID)];
                    
                    // 阅读章节ID列表加入
                    [self.chapterIDs insertObject:@(chapterID) atIndex:nextIndex];
                    
                    // 移除加载列表
                    [self.loadChapterIDs removeObjectAtIndex:loadIndex];
                    
                    // 刷新
                    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:nextIndex] withRowAnimation:UITableViewRowAnimationNone];
                }
            });
        }else{ // 加载网络章节数据
                // ----- 搜索网络小说 -----
        }
            
    });
}

/// 更新阅读记录(滚动模式) isRollingUp:是否为往上滚动
- (void)updateReadRecord:(BOOL)isRollingUp{
    NSArray<NSIndexPath *> *indexPaths = self.tableView.indexPathsForVisibleRows;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (indexPaths.count) {
            
            NSIndexPath *indexPath = isRollingUp ? indexPaths.lastObject : indexPaths.firstObject;
                  
            NSInteger chapterID = self.chapterIDs[indexPath.section].integerValue;
                  
            YLReadChapterModel *chapterModel = [self getChapterModelWithChapterID:chapterID];
            [self.vc.readModel.recordModel modifyWithChapterModel:chapterModel page:indexPath.row];
            kYLReadRecordCurrentChapterLocation = self.vc.readModel.recordModel.locationFirst;
                      
            dispatch_async(dispatch_get_main_queue(), ^{
                self.topView.chapterName.text = chapterModel.name;
                [self reloadProgress];
            });
        }
    });
}

#pragma mark - UIScrollViewDelegate

// 开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // 隐藏菜单
    [self.vc.readMenu showMenuWithIsShow:NO];
    // 重置属性
    self.isScrollUp = YES;
    self.scrollPoint = CGPointZero;
}

// 结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    // 更新阅读记录
    [self updateReadRecord:self.isScrollUp];
}
   
// 开始减速
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    // 更新阅读记录
    [self updateReadRecord:self.isScrollUp];
}

// 结束减速
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // 更新阅读记录
    [self updateReadRecord:self.isScrollUp];
}

// 正在滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint point = [scrollView.panGestureRecognizer translationInView:scrollView];
    if (point.y < _scrollPoint.y) { // 上滚
        _isScrollUp = YES;
    }else if (point.y > _scrollPoint.y) { // 下滚
        _isScrollUp = NO;
    }
    // 记录坐标
    _scrollPoint = point;
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.chapterIDs.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger chapterID = self.chapterIDs[section].integerValue;
     // 获取章节内容模型
    YLReadChapterModel *chapterModel = [self getChapterModelWithChapterID:chapterID];
    if (chapterModel) {
        return chapterModel.pageCount;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger chapterID = self.chapterIDs[indexPath.section].integerValue;
    YLReadChapterModel *chapterModel = [self getChapterModelWithChapterID:chapterID];
    return chapterModel.pageModels[indexPath.row].cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger chapterID = self.chapterIDs[indexPath.section].integerValue;
    YLReadChapterModel *chapterModel = [self getChapterModelWithChapterID:chapterID];
    YLReadPageModel *pageModel = chapterModel.pageModels[indexPath.row];
    
    // 是否为书籍首页
    if (pageModel.isHomePage) {
        YLReadHomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HomeCellIdentifer forIndexPath:indexPath];
        cell.homeView.readModel = self.vc.readModel;
        return cell;
        
    }else{
        YLReadViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReadCellIdentifer forIndexPath:indexPath];
        cell.pageModel = pageModel;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    NSInteger chapterID = self.chapterIDs[section].integerValue;
    YLReadChapterModel *chapterModel = self.chapterModels[[NSString stringWithFormat:@"%ld",chapterID]];
    // 预加载上一章
    [self preloadingPrevious:chapterModel];
    // 预加载下一章
    [self preloadingNext:chapterModel];
}

/// 书籍首页将要出现
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != 0) { return; }
    NSInteger chapterID = self.chapterIDs[indexPath.section].integerValue;
    YLReadChapterModel *chapterModel = [self getChapterModelWithChapterID:chapterID];
    YLReadPageModel *pageModel = chapterModel.pageModels[indexPath.row];
    if (pageModel.isHomePage) {
        self.topView.hidden = YES;
        self.bottomView.hidden = YES;
    }
}

/// 书籍首页消失
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != 0) { return; }
    NSInteger chapterID = self.chapterIDs[indexPath.section].integerValue;
    YLReadChapterModel *chapterModel = [self getChapterModelWithChapterID:chapterID];
    YLReadPageModel *pageModel = chapterModel.pageModels[indexPath.row];
    if (pageModel.isHomePage) {
        self.topView.hidden = NO;
        self.bottomView.hidden = NO;
    }
}

#pragma mark - setter and getter

- (NSMutableArray *)chapterIDs{
    if (_chapterIDs == nil) {
        _chapterIDs = [NSMutableArray array];
    }
    return _chapterIDs;
}

- (NSMutableArray *)loadChapterIDs{
    if (_loadChapterIDs == nil) {
        _loadChapterIDs = [NSMutableArray array];
    }
    return _loadChapterIDs;
}

- (NSMutableDictionary<NSString *,YLReadChapterModel *> *)chapterModels{
    if (_chapterModels == nil) {
        _chapterModels = [NSMutableDictionary dictionary];
    }
    return _chapterModels;
}

// 阅读视图
- (UITableView *)tableView{
    if (_tableView == nil) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:getReadViewRect() style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.rowHeight = 100;
        [tableView registerClass:YLReadHomeViewCell.class forCellReuseIdentifier:HomeCellIdentifer];
                [tableView registerClass:YLReadViewCell.class forCellReuseIdentifier:ReadCellIdentifer];
        tableView.sectionHeaderHeight = 0.01;
        tableView.backgroundColor = UIColor.clearColor;
        tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        if (@available(iOS 11.0, *)) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
        }
        
        _tableView = tableView;
    }
    return _tableView;
}

// 顶部状态栏
- (YLReadViewStatusTopView *)topView{
    if (_topView == nil) {
        _topView = [[YLReadViewStatusTopView alloc] initWithFrame:CGRectMake(getReadRect().origin.x, getReadRect().origin.y, getReadRect().size.width, kYLReadStatusTopViewHeight)];
        _topView.bookName.text = self.vc.readModel.bookName;
        _topView.chapterName.text = self.vc.readModel.recordModel.chapterModel.name;
    }
    return _topView;
}

// 底部状态栏
- (YLReadViewStatusBottomView *)bottomView{
    if (_bottomView == nil) {
        _bottomView = [[YLReadViewStatusBottomView alloc] initWithFrame:CGRectMake(getReadRect().origin.x, CGRectGetMaxY(getReadRect()) - kYLReadStatusBottomViewHeight, getReadRect().size.width, kYLReadStatusBottomViewHeight)];
    }
    return _bottomView;
}

@end
