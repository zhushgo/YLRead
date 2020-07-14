//
//  YLReadSettingView.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/29.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadSettingView.h"
#import "YLReadConfigure.h"
#import "YLReadUserDefaults.h"
#import "YLReadMenu.h"
#import "YLReadController.h"
#import "YLReadChapterListModel.h"
#import "YLGlobalTools.h"

///字体大小
@interface YLReadSettingFontSizeView ()
@property (nonatomic ,strong) UIButton *leftButton;
@property (nonatomic ,strong) UIButton *rightButton;
@property (nonatomic ,strong) UILabel *fontSize;
@property (nonatomic ,strong) UIButton *displayProgress;
@end
@implementation YLReadSettingFontSizeView

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu{
    self = [super initWithReadMenu:readMenu];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self addSubview:self.leftButton];
        [self addSubview:self.rightButton];
        [self addSubview:self.fontSize];
        [self addSubview:self.displayProgress];
        [self updateDisplayProgressButton];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;

    CGFloat itemW = 100 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat itemH = 30 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat itemY = (h - itemH) / 2;
    CGFloat displayProgressWH = 45 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);;
    
    self.leftButton.frame = CGRectMake(0,itemY,itemW, itemH);
    self.rightButton.frame = CGRectMake(w - itemW - displayProgressWH - 25 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0),itemY, itemW,itemH);
    
    self.fontSize.frame = CGRectMake(CGRectGetMaxX(self.leftButton.frame),itemY,self.rightButton.frame.origin.x - CGRectGetMaxX(self.leftButton.frame),itemH);
    
    self.displayProgress.frame = CGRectMake(w - displayProgressWH - 2 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0),(h - displayProgressWH) / 2,displayProgressWH, displayProgressWH);
}

#pragma mark - response click

- (void)clickLeftButton{
    NSInteger size = YLReadConfigure.shareConfigure.fontSize - kYLRead_FontSize_Space;
    if (size >= kYLRead_FontSize_Min) {
        _fontSize.text = [NSString stringWithFormat:@"%ld",size];
        YLReadConfigure.shareConfigure.fontSize = size;
        [YLReadConfigure.shareConfigure save];
        if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickFontSize:)]) {
            [self.readMenu.delegate readMenuClickFontSize:self.readMenu];
        }
    }
}

- (void)clickRightButton{
    NSInteger size = YLReadConfigure.shareConfigure.fontSize + kYLRead_FontSize_Space;
    if (size <= kYLRead_FontSize_Max) {
        _fontSize.text = [NSString stringWithFormat:@"%ld",size];
        YLReadConfigure.shareConfigure.fontSize = size;
        [YLReadConfigure.shareConfigure save];
        if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickFontSize:)]) {
            [self.readMenu.delegate readMenuClickFontSize:self.readMenu];
        }
    }
}

/// 点击日夜间
- (void)clickDisplayProgress:(UIButton *)sender{
    sender.selected = !sender.selected;
    [self updateDisplayProgressButton];
    YLReadConfigure.shareConfigure.progressType = sender.selected;
    [YLReadConfigure.shareConfigure save];

    if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickDisplayProgress:)]) {
        [self.readMenu.delegate readMenuClickDisplayProgress:self.readMenu];
    }
}

#pragma mark - public method

/// 刷新日夜间按钮显示状态
- (void)updateDisplayProgressButton{
    if (_displayProgress.isSelected) {
        _displayProgress.tintColor = kYLRead_Color_Main();
    }else{
        _displayProgress.tintColor = kYLRead_Color_Menu();
    }
}

#pragma mark - setter and getters

- (UIButton *)leftButton{
    if (_leftButton == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"A-" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setTitleColor:kYLRead_Color_Menu() forState:UIControlStateNormal];
        button.layer.cornerRadius = 6 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
        button.layer.borderColor = kYLRead_Color_Menu().CGColor;
        button.layer.borderWidth = 1;
        [button addTarget:self action:@selector(clickLeftButton) forControlEvents:UIControlEventTouchUpInside];
        _leftButton = button;
    }
    return _leftButton;
}

- (UIButton *)rightButton{
    if (_rightButton == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"A+" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:kYLRead_Color_Menu() forState:UIControlStateNormal];
        button.layer.cornerRadius = 6 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
        button.layer.borderColor = kYLRead_Color_Menu().CGColor;
        button.layer.borderWidth = 1;
        [button addTarget:self action:@selector(clickRightButton) forControlEvents:UIControlEventTouchUpInside];
        _rightButton = button;
    }
    return _rightButton;
}

- (UILabel *)fontSize{
    if (_fontSize == nil) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:16];
        label.textColor =  kYLRead_Color_Menu();
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%ld",YLReadConfigure.shareConfigure.fontSize];
        _fontSize = label;
    }
    return _fontSize;
}

- (UIButton *)displayProgress{
    if (_displayProgress == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[[UIImage imageNamed:@"page"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickDisplayProgress:) forControlEvents:UIControlEventTouchUpInside];
        button.selected = YLReadConfigure.shareConfigure.progressType;
        _displayProgress = button;
    }
    return _displayProgress;
}

@end





///字体类型
@interface YLReadSettingFontTypeView ()
@property (nonatomic ,strong) NSArray<NSString *> *fontNames;
@property (nonatomic ,strong) NSMutableArray<UIButton *> *items;
@property (nonatomic ,strong) UIButton *selectItem;
@end
@implementation YLReadSettingFontTypeView

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu{
    self = [super initWithReadMenu:readMenu];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        __weak typeof(self) weakSelf = self;
        [self.fontNames enumerateObjectsUsingBlock:^(NSString * _Nonnull fontName, NSUInteger idx, BOOL * _Nonnull stop) {
           __strong typeof(weakSelf) strongSelf = weakSelf;

            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = idx;
            [button setTitle:fontName forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            [button setTitleColor:kYLRead_Color_Menu() forState:UIControlStateNormal];
            [button setTitleColor:kYLRead_Color_Main() forState:UIControlStateSelected];
            button.layer.cornerRadius = 6 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
            button.layer.borderColor = kYLRead_Color_Menu().CGColor;
            button.layer.borderWidth = 1;
            [button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];

            [strongSelf addSubview:button];
            [strongSelf.items addObject:button];
            if (YLReadConfigure.shareConfigure.fontType == idx) {
                [strongSelf selectCurrentItem:button];
            }
        }];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    NSInteger count = self.fontNames.count;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    CGFloat itemW = 70 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat itemH = 30 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat itemY = (h - itemH) / 2;
    CGFloat itemSpaceW = (w - count * itemW) / (count - 1);
    [self.items enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        button.frame = CGRectMake(idx * (itemW + itemSpaceW), itemY,itemW, itemH);
    }];
}

#pragma mark - response click

- (void)clickItem:(UIButton *)sender{
    if (self.selectItem == sender) {
        return;
    }
    [self selectCurrentItem:sender];
    YLReadConfigure.shareConfigure.fontType = sender.tag;
    NSLog(@"fontType ==== %lu",(unsigned long)YLReadConfigure.shareConfigure.fontType);
    [YLReadConfigure.shareConfigure save];
    if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickFont:)]) {
        [self.readMenu.delegate readMenuClickFont:self.readMenu];
    }
}

- (void)selectCurrentItem:(UIButton *)item{
    self.selectItem.selected = NO;
    self.selectItem.layer.borderColor = kYLRead_Color_Menu().CGColor;
    item.selected = YES;
    item.layer.borderColor = kYLRead_Color_Main().CGColor;
    self.selectItem = item;
}

#pragma mark - setter and getters

- (NSArray<NSString *> *)fontNames{
    if (_fontNames == nil) {
        _fontNames = @[@"系统",@"黑体",@"楷体",@"宋体"];
    }
    return _fontNames;
}

- (NSMutableArray<UIButton *> *)items{
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

@end



///背景色
@interface YLReadSettingBGColorView ()
@property (nonatomic ,strong) NSMutableArray<UIButton *> *items;
@property (nonatomic ,strong) UIButton *selectItem;
@end
@implementation YLReadSettingBGColorView

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu{
    self = [super initWithReadMenu:readMenu];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        
        __weak typeof(self) weakSelf = self;
        [kYLRead_Color_BG() enumerateObjectsUsingBlock:^(UIColor * _Nonnull color, NSUInteger idx, BOOL * _Nonnull stop) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = idx;
            button.backgroundColor = color;
            button.layer.cornerRadius = 6 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
            button.layer.borderColor = kYLRead_Color_Main().CGColor;
            button.layer.borderWidth = 0;
            [button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
            [strongSelf addSubview:button];
            [strongSelf.items addObject:button];
            if (YLReadConfigure.shareConfigure.bgColorIndex == idx) {
                [strongSelf selectCurrentItem:button];
            }
        }];
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    NSInteger count = kYLRead_Color_BG().count;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    CGFloat itemWH = 30 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat itemY = (h - itemWH) / 2;
    CGFloat itemSpaceW = (w - count * itemWH) / (count - 1);
    [self.items enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        button.frame = CGRectMake(idx * (itemWH + itemSpaceW), itemY,itemWH, itemWH);
    }];
}

#pragma mark - response click

- (void)clickItem:(UIButton *)sender{
    if (self.selectItem == sender) {
        return;
    }
    [self selectCurrentItem:sender];
    YLReadConfigure.shareConfigure.bgColorIndex = sender.tag;
    [YLReadConfigure.shareConfigure save];
    if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickBGColor:)]) {
        [self.readMenu.delegate readMenuClickBGColor:self.readMenu];
    }
}

- (void)selectCurrentItem:(UIButton *)item{
    self.selectItem.layer.borderWidth = 0;
    item.layer.borderWidth = 1.5;
    self.selectItem = item;
}


#pragma mark - setter and getters

- (NSMutableArray<UIButton *> *)items{
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

@end







@interface YLReadSettingLightView ()
@property (nonatomic ,strong) UIImageView *leftIcon;
@property (nonatomic ,strong) UISlider *slider;
@property (nonatomic ,strong) UIImageView *rightIcon;
@end
@implementation YLReadSettingLightView

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu{
    self = [super initWithReadMenu:readMenu];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self addSubview:self.leftIcon];
        [self addSubview:self.slider];
        [self addSubview:self.rightIcon];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    CGFloat iconWH = 20 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat iconY = (h - iconWH) / 2;
    self.leftIcon.frame = CGRectMake(0,iconY, iconWH, iconWH);
    self.rightIcon.frame = CGRectMake(w - iconWH, iconY,iconWH,iconWH);
    CGFloat sliderX = CGRectGetMaxX(self.leftIcon.frame) + 15 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat sliderW = self.rightIcon.frame.origin.x - 15 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0) - sliderX;
    self.slider.frame = CGRectMake( sliderX, 0, sliderW, h);
}

#pragma mark - response click
 
/// 滑块变化
- (void)sliderChanged:(UISlider *)sender{
    UIScreen.mainScreen.brightness = sender.value;
}

#pragma mark - setter and getters

- (UIImageView *)leftIcon{
    if (_leftIcon == nil) {
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"light_0"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        imageView.tintColor = kYLRead_Color_Menu();
        _leftIcon = imageView;
    }
    return _leftIcon;
}

- (UIImageView *)rightIcon{
    if (_rightIcon == nil) {
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"light_1"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        imageView.tintColor = kYLRead_Color_Menu();
        _rightIcon = imageView;
    }
    return _rightIcon;
}

// 进度条
- (UISlider *)slider{
    if (_slider == nil) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0.0;
        slider.maximumValue = 1.0;
        slider.value = UIScreen.mainScreen.brightness;
        [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [slider setThumbImage:[[UIImage imageNamed:@"slider"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
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







///翻页类型
@interface YLReadSettingEffectTypeView ()
@property (nonatomic ,strong) NSArray<NSString *> *effectNames;
@property (nonatomic ,strong) NSMutableArray<UIButton *> *items;
@property (nonatomic ,strong) UIButton *selectItem;
@end
@implementation YLReadSettingEffectTypeView

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu{
    self = [super initWithReadMenu:readMenu];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        
        __weak typeof(self) weakSelf = self;
        [self.effectNames enumerateObjectsUsingBlock:^(NSString * _Nonnull effectName, NSUInteger idx, BOOL * _Nonnull stop) {
           __strong typeof(weakSelf) strongSelf = weakSelf;

            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = idx;
            [button setTitle:effectName forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            [button setTitleColor:kYLRead_Color_Menu() forState:UIControlStateNormal];
            [button setTitleColor:kYLRead_Color_Main() forState:UIControlStateSelected];
            button.layer.cornerRadius = 6 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
            button.layer.borderColor = kYLRead_Color_Menu().CGColor;
            button.layer.borderWidth = 1;
            [button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];

            [strongSelf addSubview:button];
            [strongSelf.items addObject:button];
            if (YLReadConfigure.shareConfigure.effectType == idx) {
                [strongSelf selectCurrentItem:button];
            }
        }];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    NSInteger count = self.effectNames.count;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    CGFloat itemW = 60 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat itemH = 30 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat itemY = (h - itemH) / 2;
    CGFloat itemSpaceW = (w - count * itemW) / (count - 1);
    [self.items enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        button.frame = CGRectMake(idx * (itemW + itemSpaceW), itemY,itemW, itemH);
    }];
}

#pragma mark - response click

- (void)clickItem:(UIButton *)sender{
    if (self.selectItem == sender) {
        return;
    }
    [self selectCurrentItem:sender];
    YLReadConfigure.shareConfigure.effectType = sender.tag;
    [YLReadConfigure.shareConfigure save];
    if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickEffect:)]) {
        [self.readMenu.delegate readMenuClickEffect:self.readMenu];
    }
}

- (void)selectCurrentItem:(UIButton *)item{
    self.selectItem.selected = NO;
    self.selectItem.layer.borderColor = kYLRead_Color_Menu().CGColor;
    item.selected = YES;
    item.layer.borderColor = kYLRead_Color_Main().CGColor;
    self.selectItem = item;
}

#pragma mark - setter and getters

- (NSArray<NSString *> *)effectNames{
    if (_effectNames == nil) {
        _effectNames = @[@"仿真",@"覆盖",@"平移",@"滚动",@"无效果"];
    }
    return _effectNames;
}

- (NSMutableArray<UIButton *> *)items{
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

@end





@interface YLReadSettingSpacingItem : UIButton
@end
@implementation YLReadSettingSpacingItem
- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat x = 25 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat y = 20 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    return CGRectMake( (CGRectGetWidth(contentRect) - x) / 2.0, (CGRectGetHeight(contentRect) - y) / 2.0, x, y);
}
@end


///间距
@interface YLReadSettingSpacingView ()
@property (nonatomic ,strong) NSArray<NSString *> *spacingIcons;
@property (nonatomic ,strong) NSMutableArray<YLReadSettingSpacingItem *> *items;
@property (nonatomic ,strong) YLReadSettingSpacingItem *selectItem;
@end
@implementation YLReadSettingSpacingView

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu{
    self = [super initWithReadMenu:readMenu];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        
        __weak typeof(self) weakSelf = self;
        [self.spacingIcons enumerateObjectsUsingBlock:^(NSString * _Nonnull spacingIcon, NSUInteger idx, BOOL * _Nonnull stop) {
           __strong typeof(weakSelf) strongSelf = weakSelf;

            YLReadSettingSpacingItem *button = [YLReadSettingSpacingItem buttonWithType:UIButtonTypeCustom];
            button.tag = idx;
            [button setImage:[[UIImage imageNamed:spacingIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            [button setTitleColor:kYLRead_Color_Menu() forState:UIControlStateNormal];
            [button setTitleColor:kYLRead_Color_Main() forState:UIControlStateSelected];
            button.layer.cornerRadius = 6 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
            button.layer.borderColor = kYLRead_Color_Menu().CGColor;
            button.layer.borderWidth = 1;
            button.tintColor = kYLRead_Color_Menu();
            [button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];

            [strongSelf addSubview:button];
            [strongSelf.items addObject:button];
            if (YLReadConfigure.shareConfigure.spacingType == idx) {
                [strongSelf selectCurrentItem:button];
            }
        }];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    NSInteger count = self.spacingIcons.count;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    CGFloat itemW = 70 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat itemH = 30 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat itemY = (h - itemH) / 2;
    CGFloat itemSpaceW = (w - count * itemW) / (count - 1);
    [self.items enumerateObjectsUsingBlock:^(YLReadSettingSpacingItem * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        button.frame = CGRectMake(idx * (itemW + itemSpaceW), itemY,itemW, itemH);
    }];
}

#pragma mark - response click

- (void)clickItem:(YLReadSettingSpacingItem *)sender{
    if (self.selectItem == sender) {
        return;
    }
    [self selectCurrentItem:sender];
    YLReadConfigure.shareConfigure.spacingType = sender.tag;
    [YLReadConfigure.shareConfigure save];
    if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickSpacing:)]) {
        [self.readMenu.delegate readMenuClickSpacing:self.readMenu];
    }
}

- (void)selectCurrentItem:(YLReadSettingSpacingItem *)item{
    self.selectItem.tintColor = kYLRead_Color_Menu();
    self.selectItem.layer.borderColor = kYLRead_Color_Menu().CGColor;
    item.tintColor = kYLRead_Color_Main();
    item.layer.borderColor = kYLRead_Color_Main().CGColor;
    self.selectItem = item;
}

#pragma mark - setter and getters

- (NSArray<NSString *> *)spacingIcons{
    if (_spacingIcons == nil) {
        _spacingIcons = @[@"spacing_0",@"spacing_1",@"spacing_2"];
    }
    return _spacingIcons;
}

- (NSMutableArray<YLReadSettingSpacingItem *> *)items{
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

@end








/// 子视图高度

CGFloat getYLReadMenuSettingSubViewHeight(void){
    return 50 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
}
/// settingView 内容高度

CGFloat getYLReadMenuSettingContentHeight(void){
    return getYLReadMenuSettingSubViewHeight() * 6.0;
}

/// settingView 总高度(内容高度 + iphoneX情况下底部间距)
CGFloat getYLReadSettingViewHeight(void){
    return isIPhoneNotchScreen() ? (getYLReadMenuSettingContentHeight() + 20 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0)) : getYLReadMenuSettingContentHeight();
}

@implementation YLReadSettingView

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu{
    self = [super initWithReadMenu:readMenu];
    if (self) {
        self.backgroundColor = kYLRead_Color_MenuBG();

        _lightView = [[YLReadSettingLightView alloc]initWithReadMenu:readMenu];
        [self addSubview:_lightView];

        _fontSizeView = [[YLReadSettingFontSizeView alloc]initWithReadMenu:readMenu];
        [self addSubview:_fontSizeView];

        _effectTypeView = [[YLReadSettingEffectTypeView alloc]initWithReadMenu:readMenu];
        [self addSubview:_effectTypeView];

        _fontTypeView = [[YLReadSettingFontTypeView alloc]initWithReadMenu:readMenu];
        [self addSubview:_fontTypeView];

        _bgColorView = [[YLReadSettingBGColorView alloc]initWithReadMenu:readMenu];
        [self addSubview:_bgColorView];

        _spacingView = [[YLReadSettingSpacingView alloc]initWithReadMenu:readMenu];
        [self addSubview:_spacingView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat x = 15 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);;
    CGFloat w = UIScreen.mainScreen.bounds.size.width - 30 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0);
    CGFloat h = getYLReadMenuSettingSubViewHeight();
    _lightView.frame = CGRectMake(x, 0, w, h);
    _fontSizeView.frame = CGRectMake( x,CGRectGetMaxY(_lightView.frame),w, h);
    _effectTypeView.frame = CGRectMake(x,CGRectGetMaxY(_fontSizeView.frame), w, h);
    _fontTypeView.frame = CGRectMake(x,CGRectGetMaxY(_effectTypeView.frame), w, h);
    _bgColorView.frame = CGRectMake(x,CGRectGetMaxY(_fontTypeView.frame), w, h);
    _spacingView.frame = CGRectMake(x,CGRectGetMaxY(_bgColorView.frame), w, h);
}


@end

