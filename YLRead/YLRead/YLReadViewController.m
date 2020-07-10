//
//  YLReadViewController.m
//  FM
//
//  Created by 苏沫离 on 2020/7/9.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadViewController.h"
#import "YLReadConfigure.h"
#import "YLReadModel.h"
#import "YLReadViewStatusTopView.h"
#import "YLReadViewStatusBottomView.h"
#import "YLReadView.h"
#import "YLReadHomeView.h"
#import "YLReadChapterModel.h"
#import "YLGlobalTools.h"

@interface YLReadViewController ()




/// 顶部状态栏
@property (nonatomic ,strong) YLReadViewStatusTopView *topView;

/// 底部状态栏
@property (nonatomic ,strong) YLReadViewStatusBottomView *bottomView;

/// 阅读视图
@property (nonatomic ,strong) YLReadView *readView;

/// 书籍首页视图
@property (nonatomic ,strong) YLReadHomeView *homeView;

@end

@implementation YLReadViewController

- (void)dealloc{
    [_bottomView removeTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = YLReadConfigure.shareConfigure.bgColor;
    self.extendedLayoutIncludesOpaqueBars = YES;
    if (@available(iOS 11.0, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
    [self initReadView];
    // 刷新阅读进度
    [self reloadProgress];
}

#pragma mark - public method

- (void)initReadView{
    if (self.recordModel.pageModel.isHomePage) {
        self.topView.hidden = YES;
        self.bottomView.hidden = YES;
        [_readView removeFromSuperview];
        [self.view addSubview:self.homeView];
    }else{
        [_homeView removeFromSuperview];
        [self.view addSubview:self.readView];
    }
}

/// 刷新阅读进度显示
- (void)reloadProgress{
    if (YLReadConfigure.shareConfigure.progressType == YLProgressTypeTotal) { // 总进度
        // 当前阅读进度
        float progress = getReadToalProgress(self.readModel,self.recordModel);
        // 显示进度
        self.bottomView.progress.text = getReadToalProgressString(progress);
    }else{ // 分页进度
        // 显示进度
        self.bottomView.progress.text = [NSString stringWithFormat:@"%ld",(self.recordModel.page + 1) / self.recordModel.chapterModel.pageCount];
    }
}

#pragma mark - setter and getter

// 顶部状态栏
- (YLReadViewStatusTopView *)topView{
    if (_topView == nil) {
        _topView = [[YLReadViewStatusTopView alloc] initWithFrame:CGRectMake(getReadRect().origin.x, getReadRect().origin.y, getReadRect().size.width, kYLReadStatusTopViewHeight)];
        _topView.bookName.text = self.readModel.bookName;
        _topView.chapterName.text = self.recordModel.chapterModel.name;
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

- (YLReadHomeView *)homeView{
    if (_homeView == nil) {
        _homeView = [[YLReadHomeView alloc] initWithFrame:getReadViewRect()];
        _homeView.readModel = self.readModel;
    }
    return _homeView;
}

- (YLReadView *)readView{
    if (_readView == nil) {
        _readView = [[YLReadView alloc] initWithFrame:getReadViewRect()];
        _readView.content = self.recordModel.contentAttributedString;
    }
    return _readView;
}

@end
