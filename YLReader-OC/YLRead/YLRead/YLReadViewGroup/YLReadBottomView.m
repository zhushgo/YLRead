//
//  YLReadBottomView.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/29.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadBottomView.h"
#import "YLReadUserDefaults.h"
#import "YLReadMenu.h"
#import "YLReadChapterListModel.h"

/// 进度条
#import "YLReadTrackingSlider.h"


CGFloat getYLReadProgressViewHeight(void){
    return 55 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
}
@interface YLReadProgressView ()
<YLReadTrackingSliderDelegate,YLReadTrackingSliderDataSource>

/// 进度
@property (nonatomic ,strong) YLReadTrackingSlider *slider;

@end

@implementation YLReadProgressView

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu{
    self = [super initWithReadMenu:readMenu];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self addSubview:self.previousChapter];
        [self addSubview:self.nextChapter];
        [self addSubview:self.slider];
        [self reloadProgress];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    CGFloat buttonW = 55 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat x = 5 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);

    // 上一章
    self.previousChapter.frame = CGRectMake(x,0, buttonW,h);
    // 下一章
    self.nextChapter.frame = CGRectMake(w - buttonW - x, 0, buttonW,h);
    
    // 进度条
    CGFloat sliderX = CGRectGetMaxX(self.previousChapter.frame) + 10 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat sliderW = w - 2 * sliderX;
    self.slider.frame = CGRectMake(sliderX, 0, sliderW, h);
}

#pragma mark - response click

/// 上一章
- (void)clickPreviousChapter{
    if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickPreviousChapter:)]) {
        [self.readMenu.delegate readMenuClickPreviousChapter:self.readMenu];
    }
}

/// 下一章
- (void)clickNextChapter{
    if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickNextChapter:)]) {
        [self.readMenu.delegate readMenuClickNextChapter:self.readMenu];
    }
}

#pragma mark - YLReadTrackingSliderDataSource

- (NSString *)slider:(YLReadTrackingSlider *)slider stringForValue:(float)value{
    if (YLReadConfigure.shareConfigure.progressType == YLProgressTypeTotal) { // 总进度
        // 如果有需求可显示章节名
        return getReadToalProgressString(value);
    }else{// 分页进度
        return [NSString stringWithFormat:@"%d",(int)value];
    }
}

#pragma mark - YLReadTrackingSliderDelegate
/// 进度显示将要显示
- (void)sliderWillDisplayPopUpView:(YLReadTrackingSlider *)slider{}
  
/// 进度显示将要隐藏
- (void)sliderWillHidePopUpView:(YLReadTrackingSlider *)slider{

      if (YLReadConfigure.shareConfigure.progressType == YLProgressTypeTotal) { // 总进度

          // 有阅读数据
          YLReadModel *readModel = self.readMenu.vc.readModel;

          // 有阅读记录以及章节数据
          if (readModel && readModel.recordModel.chapterModel) {
              // 总章节个数
              NSInteger count = (readModel.chapterListModels.count - 1);
              // 获得当前进度的章节索引
              NSInteger index = count * self.slider.value;
              // 获得章节列表模型
              YLReadChapterListModel *chapterListModel = readModel.chapterListModels[index];
              // 页码
              NSInteger toPage = (index == count) ? kYLReadChapterLastPage : 0;
              
              // 传递
              if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuDraggingProgress:toChapterID:toPage:)]) {
                  [self.readMenu.delegate readMenuDraggingProgress:self.readMenu toChapterID:chapterListModel.id toPage:toPage];
              }
          }
          
      }else{ // 分页进度
          if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuDraggingProgress:toPage:)]) {
              [self.readMenu.delegate readMenuDraggingProgress:self.readMenu toPage:self.slider.value - 1];
          }
      }
  }

#pragma mark - public method

/// 刷新阅读进度显示
- (void)reloadProgress{
    // 有阅读数据
    YLReadModel *readModel = self.readMenu.vc.readModel;
    // 有阅读记录以及章节数据
    if (readModel && readModel.recordModel.chapterModel) {
        if (YLReadConfigure.shareConfigure.progressType == YLProgressTypeTotal) { // 总进度
            self.slider.minimumValue = 0;
            self.slider.maximumValue = 1;
            self.slider.value = getReadToalProgress(readModel,readModel.recordModel);
        }else{ // 分页进度
            self.slider.minimumValue = 1;
            self.slider.maximumValue = readModel.recordModel.chapterModel.pageCount;
            self.slider.value = readModel.recordModel.page + 1;
        }
    }else{ // 没有则清空
        self.slider.minimumValue = 0;
        self.slider.maximumValue = 0;
        self.slider.value = 0;
    }
}

#pragma mark - setter and getters

// 上一章
- (UIButton *)previousChapter{
    if (_previousChapter == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"上一章" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:kYLRead_Color_Menu() forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickPreviousChapter) forControlEvents:UIControlEventTouchUpInside];
        _previousChapter = button;
    }
    return _previousChapter;
}

// 下一章
- (UIButton *)nextChapter{
    if (_nextChapter == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"下一章" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:kYLRead_Color_Menu() forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickNextChapter) forControlEvents:UIControlEventTouchUpInside];
        _nextChapter = button;
    }
    return _nextChapter;
}

// 进度条
- (YLReadTrackingSlider *)slider{
    if (_slider == nil) {
        YLReadTrackingSlider *slider = [[YLReadTrackingSlider alloc]init];
        slider.delegate = self;
        slider.dataSource = self;
        [slider setThumbImage:[[UIImage imageNamed:@"slider"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        // 设置气泡背景颜色
        slider.popUpViewColor = kYLRead_Color_Main();
        // 设置气泡字体颜色
        slider.textColor = kYLRead_Color_Menu();
        // 设置气泡字体以及字体大小
        slider.font = [UIFont fontWithName: @"Futura-CondensedExtraBold" size:22];
        // 设置气泡箭头高度
        slider.popUpViewArrowLength = 5 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
        // 设置当前进度颜色
        slider.minimumTrackTintColor = kYLRead_Color_Main();
        // 设置总进度颜色
        slider.maximumTrackTintColor = kYLRead_Color_Menu();
        // 设置当前拖拽圆圈颜色
        slider.tintColor = kYLRead_Color_Menu();
        _slider = slider;
    }
    return _slider;
}


@end




CGFloat getYLReadFuncViewHeight(void){
    return 55 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);;
}
@implementation YLReadFuncView

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu{
    self = [super initWithReadMenu:readMenu];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self addSubview:self.catalogue];
        [self addSubview:self.setting];
        [self addSubview:self.dn];
        [self updateDNButton];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat y = 3 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat wh = self.frame.size.height;
    self.catalogue.frame = CGRectMake(0, y, wh, wh);
    self.dn.frame = CGRectMake((self.frame.size.width - wh)/2, y, wh, wh);
    self.setting.frame = CGRectMake(self.frame.size.width - wh, y, wh, wh);
}

#pragma mark - response click

/// 点击目录
- (void)clickCatalogue{
    if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickCatalogue:)]) {
        [self.readMenu.delegate readMenuClickCatalogue:self.readMenu];
    }
}
/// 点击设置
- (void)clickSetting{
    [self.readMenu showTopViewWithIsShow:NO completion:^{
        
    }];
    [self.readMenu showBottomViewWithIsShow:NO completion:^{
        
    }];
    [self.readMenu showSettingViewWithIsShow:YES completion:^{
        
    }];
}
/// 点击日夜间
- (void)clickDN:(UIButton *)sender{
    sender.selected = !sender.selected;
    // 切换日夜间
    self.readMenu.cover.alpha = sender.isSelected;
    // 刷新显示
    [self updateDNButton];
    // 记录日夜间状态
    [YLReadUserDefaults setObjectWithKey:kYLRead_Save_Day_Night boo:sender.isSelected];

    if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickDayAndNight:)]) {
        [self.readMenu.delegate readMenuClickDayAndNight:self.readMenu];
    }
}

#pragma mark - public method

/// 刷新日夜间按钮显示状态
- (void)updateDNButton{
    if (_dn.isSelected) {
        _dn.tintColor = kYLRead_Color_Main();
    }else{
        _dn.tintColor = kYLRead_Color_Menu();
    }
}

#pragma mark - setter and getters


- (UIButton *)catalogue{
    if (_catalogue == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[[UIImage imageNamed:@"bar_0"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickCatalogue) forControlEvents:UIControlEventTouchUpInside];
        button.tintColor = kYLRead_Color_Menu();
        _catalogue = button;
    }
    return _catalogue;
}

// 设置
- (UIButton *)setting{
    if (_setting == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[[UIImage imageNamed:@"bar_1"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickSetting) forControlEvents:UIControlEventTouchUpInside];
        button.tintColor = kYLRead_Color_Menu();
        _setting = button;
    }
    return _setting;
}

// 日夜间
- (UIButton *)dn{
    if (_dn == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[[UIImage imageNamed:@"bar_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickDN:) forControlEvents:UIControlEventTouchUpInside];
        button.tintColor = kYLRead_Color_Menu();
        button.selected = [YLReadUserDefaults getBoolWithKey:kYLRead_Save_Day_Night];
        _dn = button;
    }
    return _dn;
}


@end



CGFloat getYLReadBottomViewHeight(void){
    return getYLReadProgressViewHeight() + ylReadGetTabBarHeight();
}

@implementation YLReadBottomView

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu{
    self = [super initWithReadMenu:readMenu];
    if (self) {
        _progressView = [[YLReadProgressView alloc] initWithReadMenu:readMenu];
        [self addSubview:_progressView];
        _funcView = [[YLReadFuncView alloc] initWithReadMenu:readMenu];
        [self addSubview:_funcView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.progressView.frame = CGRectMake(0, 0, self.frame.size.width, getYLReadProgressViewHeight());
    self.funcView.frame = CGRectMake(0, CGRectGetMaxY(self.progressView.frame),  self.frame.size.width, getYLReadFuncViewHeight());
}


@end



