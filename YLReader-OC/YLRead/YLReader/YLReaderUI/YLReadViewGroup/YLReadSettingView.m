//
//  YLReadSettingView.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/29.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadSettingView.h"
#import "YLReadUserDefaults.h"
#import "YLReadMenu.h"
#import "YLReadChapterListModel.h"


typedef NS_ENUM(NSUInteger,YLReadSettingType) {
    YLReadSettingTypeLight = 0,
    YLReadSettingTypeFontSize,/// 字体大小
    YLReadSettingTypeBGColor,/// 背景色
    YLReadSettingTypeEffect,/// 翻页效果
    YLReadSettingTypeFont,/// 字体
    YLReadSettingTypeSpacing,/// 间距
};

@interface YLReadSettingCollectionCell : UICollectionViewCell
@property (nonatomic ,strong) UILabel *itemLable;
@property (nonatomic ,strong) UIImageView *itemImageView;
@end

@implementation YLReadSettingCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.contentView.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:self.itemLable];
        [self.contentView addSubview:self.itemImageView];
        
        self.layer.cornerRadius = 6;
        self.layer.borderWidth = 1;
        self.layer.borderColor = kYLRead_Color_Menu().CGColor;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _itemLable.frame = self.contentView.bounds;
    _itemImageView.center = CGPointMake(CGRectGetWidth(self.contentView.bounds) / 2.0, CGRectGetHeight(self.contentView.bounds) / 2.0);
}

- (void)reloadData:(id)data settingType:(YLReadSettingType)settingType index:(NSInteger)index{

    self.itemLable.hidden = YES;
    self.itemImageView.hidden = YES;
    self.backgroundColor = UIColor.clearColor;
    switch (settingType) {
        case YLReadSettingTypeBGColor:{
            UIColor *color = (UIColor *)data;
            self.backgroundColor = color;
            self.selected = YLReadConfigure.shareConfigure.bgColorIndex == index;
        }break;
        case YLReadSettingTypeEffect:
        case YLReadSettingTypeFont:{
            NSString *item = (NSString *)data;
            self.itemLable.text = item;
            self.itemLable.hidden = NO;
            if (settingType == YLReadSettingTypeFont) {
                self.selected = YLReadConfigure.shareConfigure.fontType == index;
            }else{
                self.selected = YLReadConfigure.shareConfigure.effectType == index;
            }
        }break;
        case YLReadSettingTypeSpacing:{
            NSString *imageName = (NSString *)data;
            self.itemImageView.image = [UIImage imageNamed:imageName];
            self.itemImageView.hidden = NO;
            self.selected = YLReadConfigure.shareConfigure.spacingType == index;
        }break;
        default:
            break;
    }
}

#pragma mark - setter and getter

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];

    if (selected) {
        self.itemLable.textColor = kYLRead_Color_Main();
        self.layer.borderColor = kYLRead_Color_Main().CGColor;
    }else{
        self.itemLable.textColor = kYLRead_Color_Menu();
        self.layer.borderColor = kYLRead_Color_Menu().CGColor;
    }
}

- (UILabel *)itemLable{
    if (_itemLable == nil){
        UILabel *lable = [[UILabel alloc] init];
        lable.font = [UIFont systemFontOfSize:12];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.textColor = kYLRead_Color_Menu();
        _itemLable = lable;
    }
    return _itemLable;
}

- (UIImageView *)itemImageView{
    if (_itemImageView == nil) {
        _itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
        _itemImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _itemImageView;
}

@end

#define TableCellIdentifer @"YLReadSettingTableCell"
@interface YLReadSettingTableCell : UITableViewCell
<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic ,strong) UICollectionView *collectionView;
@property (nonatomic ,strong) NSArray *itemArray;
@property (nonatomic ,assign) YLReadSettingType settingType;
@property (nonatomic ,copy) void(^didSelectItemHandler)(id data,NSInteger index);
@end

@implementation YLReadSettingTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:self.collectionView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.collectionView.frame = self.contentView.bounds;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(80, 30 * (CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0));
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.itemArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    YLReadSettingCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    [cell reloadData:self.itemArray[indexPath.row] settingType:_settingType index:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.didSelectItemHandler) {
        self.didSelectItemHandler(self.itemArray[indexPath.row],indexPath.row);
    }
    [collectionView reloadData];
}

#pragma mark - setter and getters

- (void)setSettingType:(YLReadSettingType)settingType{
    _settingType = settingType;
    switch (settingType) {
        case YLReadSettingTypeLight:{
            
        }break;
        case YLReadSettingTypeFontSize:{
            
        }break;
        case YLReadSettingTypeBGColor:{
            self.itemArray = kYLRead_Color_BG();
        }break;
        case YLReadSettingTypeEffect:{
            self.itemArray = @[@"仿真",@"覆盖",@"平移",@"滚动",@"无效果"];
        }break;
        case YLReadSettingTypeFont:{
          self.itemArray = @[@"系统",@"黑体",@"楷体",@"宋体"];
        }break;
        case YLReadSettingTypeSpacing:{
           self.itemArray = @[@"spacing_0",@"spacing_1",@"spacing_2"];
        }break;
        default:
            break;
    }
    [self.collectionView reloadData];
}

- (UICollectionView *)collectionView{
    if (_collectionView == nil){
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.clearColor;
        [_collectionView registerClass:[YLReadSettingCollectionCell class] forCellWithReuseIdentifier:@"CollectionCell"];
    }
    return _collectionView;
}


@end



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






@interface YLReadSettingView ()
<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray<NSNumber *> *itemArray;

@end


@implementation YLReadSettingView

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu{
    self = [super initWithReadMenu:readMenu];
    if (self) {
        self.frame = CGRectMake(0, CGRectGetHeight(UIScreen.mainScreen.bounds), CGRectGetWidth(UIScreen.mainScreen.bounds), ylReadIsIPhoneNotchScreen() ? (50 * 6.0 + 34) : 50 * 6.0);
        
        _lightView = [[YLReadSettingLightView alloc]initWithReadMenu:readMenu];
        [self addSubview:_lightView];
        
        _fontSizeView = [[YLReadSettingFontSizeView alloc]initWithReadMenu:readMenu];
        [self addSubview:_fontSizeView];
        
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat x = 16;
    CGFloat width = CGRectGetWidth(self.bounds) - 16 * 2.0;
    CGFloat height = 50;
    _lightView.frame = CGRectMake(x, 0, width, height);
    _fontSizeView.frame = CGRectMake( x,CGRectGetMaxY(_lightView.frame),width, height);
    self.tableView.frame = CGRectMake(x, CGRectGetMaxY(_fontSizeView.frame), width, height * 4.0);
}

#pragma mark - response click

- (void)didSelectItem:(id)data settingType:(YLReadSettingType)settingType index:(NSInteger)index{
    switch (settingType) {
        case YLReadSettingTypeBGColor:{
            YLReadConfigure.shareConfigure.bgColorIndex = index;
            [YLReadConfigure.shareConfigure save];
            if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickBGColor:)]) {
                [self.readMenu.delegate readMenuClickBGColor:self.readMenu];
            }
        }break;
        case YLReadSettingTypeEffect:{
            YLReadConfigure.shareConfigure.effectType = index;
            [YLReadConfigure.shareConfigure save];
            if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickEffect:)]) {
                [self.readMenu.delegate readMenuClickEffect:self.readMenu];
            }
        }break;
        case YLReadSettingTypeFont:{
            YLReadConfigure.shareConfigure.fontType = index;
            [YLReadConfigure.shareConfigure save];
            if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickFont:)]) {
                [self.readMenu.delegate readMenuClickFont:self.readMenu];
            }
        }break;
        case YLReadSettingTypeSpacing:{
            YLReadConfigure.shareConfigure.spacingType = index;
            [YLReadConfigure.shareConfigure save];
            if (self.readMenu.delegate && [self.readMenu.delegate respondsToSelector:@selector(readMenuClickSpacing:)]) {
                [self.readMenu.delegate readMenuClickSpacing:self.readMenu];
            }
        }break;
        default:
            break;
    }
    
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YLReadSettingTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TableCellIdentifer];
    YLReadSettingType settingType = self.itemArray[indexPath.row].integerValue;
    cell.settingType = settingType;
    __weak typeof(self) weakSelf = self;
    cell.didSelectItemHandler = ^(id data, NSInteger index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf didSelectItem:data settingType:settingType index:index];
    };
    return cell;
}

#pragma mark - getter and setter

- (NSMutableArray<NSNumber *> *)itemArray{
    if (_itemArray == nil) {
        _itemArray = [NSMutableArray array];
        [_itemArray addObject:@(YLReadSettingTypeBGColor)];
        [_itemArray addObject:@(YLReadSettingTypeEffect)];
        [_itemArray addObject:@(YLReadSettingTypeFont)];
        [_itemArray addObject:@(YLReadSettingTypeSpacing)];
    }
    return _itemArray;
}

- (UITableView *)tableView{
    if(_tableView == nil){
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen.bounds), 200) style:UITableViewStylePlain];
        tableView.scrollEnabled = NO;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = UIColor.clearColor;
        tableView.rowHeight = 50;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:YLReadSettingTableCell.class forCellReuseIdentifier:TableCellIdentifer];
        _tableView = tableView;
    }
    return _tableView;
}


@end

