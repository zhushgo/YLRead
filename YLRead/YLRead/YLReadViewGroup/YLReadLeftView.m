//
//  YLReadLeftView.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadLeftView.h"
#import "YLReadConfigure.h"
#import "YLGlobalTools.h"
#import "YLReadUserDefaults.h"

@interface YLReadSegmentedControl()
/// 默认字体
@property (nonatomic, strong) NSMutableArray<UIButton *> *items;
/// 滑动条
@property (nonatomic, strong) UIView *sliderView;
/// 当前选中按钮
@property (nonatomic, weak) UIButton *selectItem;
@end

@implementation YLReadSegmentedControl

- (NSMutableArray<UIButton *> *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.normalFont = [UIFont systemFontOfSize:14];
        self.selectFont = [UIFont boldSystemFontOfSize:16];
        self.normalColor = [UIColor grayColor];
        self.selectColor = [UIColor redColor];
        self.sliderColor = [UIColor redColor];
        self.sliderHeight = 2;
        self.sliderBottom = 0;
        self.sliderWidth = -1;
        self.itemSpace = 0;
        self.sliderView = [[UIView alloc] init];
        self.insets = UIEdgeInsetsZero;
        _selectIndex = -1;
    }
    
    return self;
}

/// 刷新列表
- (void)reloadTitles:(NSArray <NSString *>*)titles {
    
    [self reloadTitles:titles index:0];
}

/// 刷新列表 并 选中指定按钮
- (void)reloadTitles:(NSArray <NSString *>*)titles index:(NSInteger)index {
    
    if (titles.count <= 0) { return ; }
    
    for (UIButton *item in self.items) {
        
        [item removeFromSuperview];
    }
    
    [self.items removeAllObjects];
    
    NSInteger count = titles.count;
    
    for (int i = 0; i < count; i++) {
        
        UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
        
        item.tag = i;
        
        [item setTitle:titles[i] forState:UIControlStateNormal];
        
        [item setTitle:titles[i] forState:UIControlStateSelected];
        
        [self.items addObject:item];
        
        [self addSubview:item];
        
        [item addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self addSubview:self.sliderView];
    
    [self scrollIndex:index animated:NO];
    
    [self reloadUI];
}

/// 选中索引
- (void)scrollIndex:(NSInteger)index animated:(BOOL)animated {
    
    [self selectItem:index];
    
    if (_selectIndex == index) { return ; }
    
    _selectIndex = index;
    
    if (animated) {
        
        __weak YLReadSegmentedControl *weakSelf = self;
        
        [UIView animateWithDuration:0.2 animations:^{
            
            weakSelf.sliderView.frame = CGRectMake(weakSelf.selectItem.center.x - weakSelf.sliderView.frame.size.width / 2, weakSelf.frame.size.height - weakSelf.sliderHeight + self.sliderBottom, weakSelf.sliderView.frame.size.width, weakSelf.sliderHeight);
            
        }];
        
    }else{
        
        self.sliderView.frame = CGRectMake(self.selectItem.center.x - self.sliderView.frame.size.width / 2, self.frame.size.height - self.sliderHeight + self.sliderBottom, self.sliderView.frame.size.width, self.sliderHeight);
    }
    
    if ([self.delegate respondsToSelector:@selector(segmentedControl:scrollIndex:)]) {
        
        [self.delegate segmentedControl:self scrollIndex:index];
    }
}

/// 选中按钮
- (void)selectItem:(NSInteger)index {
    
    self.selectItem.selected = NO;
    
    self.selectItem.titleLabel.font = self.normalFont;
    
    UIButton *item = self.items[index];
    
    item.selected = YES;
    
    item.titleLabel.font = self.selectFont;
    
    self.selectItem = item;
}

/// 刷新当前页面布局
- (void)reloadUI {
    
    NSInteger count = self.items.count;
    
    if (count <= 0) { return ; }
    
    CGFloat itemX = self.insets.left;
    
    CGFloat itemY = self.insets.top;
    
    CGFloat itemW = ((self.frame.size.width - self.insets.left - self.insets.right) - ((count - 1) * self.itemSpace)) / count;
    
    CGFloat itemH = self.frame.size.height - self.insets.top - self.insets.bottom;
    
    for (int i = 0; i < count; i++) {
        
        UIButton *item = self.items[i];
        
        item.frame = CGRectMake(itemX + i * (itemW + self.itemSpace), itemY, itemW, itemH);
        
        if (item.isSelected) { item.titleLabel.font = self.selectFont;
            
        }else{ item.titleLabel.font = self.normalFont; }
        
        [item setTitleColor:self.normalColor forState:UIControlStateNormal];
        
        [item setTitleColor:self.selectColor forState:UIControlStateSelected];
    }
    
    CGFloat sliderWidth = (self.sliderWidth < 0) ? self.frame.size.width : self.sliderWidth;
    
    sliderWidth = MIN(sliderWidth, itemW);
    
    self.sliderView.backgroundColor = self.sliderColor;
    
    self.sliderView.frame = CGRectMake(self.selectItem.center.x - sliderWidth / 2, self.frame.size.height - self.sliderHeight + self.sliderBottom, sliderWidth, self.sliderHeight);
}

/// 滑动滑条
- (void)scrollSlider:(UIScrollView *)scrollView {
    
}

- (void)clickItem:(UIButton *)item {
    
    if (self.selectIndex == item.tag) { return ; }
    
    [self scrollIndex:item.tag animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(segmentedControl:clickIndex:)]) {
        
        [self.delegate segmentedControl:self clickIndex:item.tag];
    }
}

@end




/// leftView 宽高度
CGFloat kYLReadLeft_Width(void){
    return 335 * CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0;
}
CGFloat kYLReadLeft_Height(void){
    return CGRectGetHeight(UIScreen.mainScreen.bounds);
}

///// leftView headerView 高度
CGFloat const kYLReadLeft_Header_Height = 50;

@interface YLReadLeftView ()
<YLReadSegmentedControlDelegate>

@end


@implementation YLReadLeftView

- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.segmentedControl];
        [self addSubview:self.spaceLine];
        [self addSubview:self.catalogView];
        [self addSubview:self.markView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.segmentedControl.frame = CGRectMake(0,ylReadIsIPhoneNotchScreen() ? ylReadGetStatusBarHeight() : 0 , CGRectGetWidth(self.bounds), kYLReadLeft_Header_Height);
    self.spaceLine.frame = CGRectMake(0, CGRectGetMaxY(self.segmentedControl.frame), CGRectGetWidth(self.bounds),0.5);
    self.catalogView.frame = CGRectMake(0, CGRectGetMaxY(self.spaceLine.frame), CGRectGetWidth(self.bounds),CGRectGetHeight(UIScreen.mainScreen.bounds) - CGRectGetMaxY(self.spaceLine.frame));
    self.markView.frame = self.catalogView.frame;
}


/// 刷新UI 例如: 日夜间可以根据需求判断修改目录背景颜色,文字颜色等等
- (void)updateUI{
    
    // 日夜间切换修改
    if ([YLReadUserDefaults getBoolWithKey:kYLRead_Save_Day_Night]){
        self.spaceLine.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:0.2];
        self.backgroundColor = [UIColor colorWithRed:46/255.0 green:46/255.0 blue:46/255.0 alpha:1];
    }else{
        self.spaceLine.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
        self.backgroundColor = UIColor.whiteColor;
    }
    
    // 刷新分割线颜色(如果不需要刷新分割线颜色可以去掉,目前我是做了日夜间修改分割线颜色的操作)
    [self.catalogView.tableView reloadData];
    [self.markView.tableView reloadData];
}

#pragma mark - DZMSegmentedControlDelegate

- (void)segmentedControl:(YLReadSegmentedControl *)segmentedControl clickIndex:(NSInteger)index{
    
    [UIView animateWithDuration:0.2 animations:^{
        
        if (index == 0) {// 显示目录
            [self bringSubviewToFront:self.catalogView];
            self.catalogView.alpha = 1;
            self.markView.alpha = 0;
        }else{// 显示书签
            [self bringSubviewToFront:self.markView];
                self.markView.alpha = 1;
                self.catalogView.alpha = 0;
        }
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - setter and getters

// 工具栏
- (YLReadSegmentedControl *)segmentedControl{
    if (_segmentedControl == nil) {
        _segmentedControl = [[YLReadSegmentedControl alloc]initWithFrame:CGRectMake(0, 0, kYLReadLeft_Width(), kYLReadLeft_Header_Height)];
        _segmentedControl.delegate = self;
        _segmentedControl.normalFont = [UIFont systemFontOfSize:14];
        _segmentedControl.normalColor= [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0];
        _segmentedControl.selectFont = [UIFont systemFontOfSize:14];
        _segmentedControl.selectColor = kYLRead_Color_Main();
        _segmentedControl.sliderColor = kYLRead_Color_Main();
        _segmentedControl.sliderWidth = 30 * CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0;;
        _segmentedControl.sliderHeight = 2;
        [_segmentedControl reloadTitles:@[@"目录",@"书签"]];
    }
    return _segmentedControl;;
}


- (YLReadCatalogView *)catalogView{
    if (_catalogView == nil) {
        _catalogView = [[YLReadCatalogView alloc] initWithFrame:CGRectZero];
    }
    return _catalogView;
}

- (YLReadMarkView *)markView{
    if (_markView == nil) {
        _markView = [[YLReadMarkView alloc] initWithFrame:CGRectZero];
        _markView.alpha = 0;
    }
    return _markView;
}

- (UIView *)spaceLine{
    if (_spaceLine == nil) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        _spaceLine = view;
    }
    return _spaceLine;
}

@end
