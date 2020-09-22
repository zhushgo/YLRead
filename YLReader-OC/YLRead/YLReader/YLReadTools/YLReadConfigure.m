//
//  YLReadConfigure.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadConfigure.h"
#import "YLReadUserDefaults.h"

UIColor * kYLRead_Color_Main(void){
    return [UIColor colorWithRed:253/255.0 green:85/255.0 blue:103/255.0 alpha:1];
}

UIColor *kYLRead_Color_Menu(void){
    return [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
}

NSArray<UIColor *> *kYLRead_Color_BG(void){
    return @[[UIColor colorWithPatternImage:[UIImage imageNamed:@"read_bg_0_icon"]],
             [UIColor colorWithPatternImage:[UIImage imageNamed:@"read_bg_1_icon"]],
             [UIColor colorWithPatternImage:[UIImage imageNamed:@"read_bg_2_icon"]],
             [UIColor colorWithRed:58/255.0 green:52/255.0 blue:54/255.0 alpha:0.95],
             [UIColor colorWithRed:234/255.0 green:234/255.0 blue:239/255.0 alpha:1],
             [UIColor colorWithRed:250/255.0 green:249/255.0 blue:222/255.0 alpha:1],];
}

NSInteger const kYLRead_FontSize_Min = 10;
NSInteger const kYLRead_FontSize_Max = 30;
NSInteger const kYLRead_FontSize_Default = 18;
NSInteger const kYLRead_FontSize_Space = 2;
NSInteger const kYLRead_FontSize_TitleSpace = 8;

@implementation YLReadConfigure

+ (instancetype)shareConfigure{
    static YLReadConfigure *configure;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configure = [[YLReadConfigure alloc] init];
    });
    return configure;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
        NSDictionary *dict = [YLReadUserDefaults getObjectWithKey:kYLRead_Save_Configure];
        if (dict) {
            _bgColorIndex = [dict[@"bgColorIndex"] integerValue];
            _fontType = [dict[@"fontType"] integerValue];
            _effectType = [dict[@"effectType"] integerValue];
            _spacingType = [dict[@"spacingType"] integerValue];
            _progressType = [dict[@"progressType"] integerValue];
            _fontSize = [dict[@"fontSize"] intValue];
        }else{
            _bgColorIndex = 0; // 背景
            _fontType = YLFontTypeTwo;// 字体类型
            _effectType = YLEffectTypeSimulation;// 翻页类型
            _spacingType = YLSpacingTypeSmall;// 间距类型
            _progressType = YLProgressTypePage;// 显示进度类型
            _fontSize = kYLRead_FontSize_Default;// 字体大小
        }
        _openLongPress = YES;
    }
    return self;
}

/// 阅读字体
- (UIFont *)font{
    return [self fontWithIsTitle:NO];
}
- (UIFont *)fontWithIsTitle:(BOOL)isTitle{
    /// isTitle 章节标题 - 在当前字体大小上叠加 8
    CGFloat size = (self.fontSize + (isTitle ? 8 : 0)) * CGRectGetWidth(UIScreen.mainScreen.bounds) / 375.0;
    if (self.fontType == YLFontTypeOne) { // 黑体
        return [UIFont fontWithName:@"EuphemiaUCAS-Italic" size:size];
    }else if (self.fontType == YLFontTypeTwo) { // 楷体
        return [UIFont fontWithName:@"AmericanTypewriter-Light" size:size];
    }else if (self.fontType == YLFontTypeThree) { // 宋体
        return [UIFont fontWithName:@"Papyrus" size:size];
    }else{ // 系统
        return [UIFont systemFontOfSize:size];
    }
}

/// 字体属性
/// isPaging: 为YES的时候只需要返回跟分页相关的属性即可 (原因:包含UIColor,小数点相关的...不可返回,因为无法进行比较)
- (NSDictionary<NSAttributedStringKey,id> *)attributesWithIsTitle:(BOOL)isTitle{
    return [self attributesWithIsTitle:isTitle isPageing:NO];
}

- (NSDictionary<NSAttributedStringKey,id> *)attributesWithIsTitle:(BOOL)isTitle isPageing:(BOOL)isPageing{
     // 段落配置
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    // 当前行间距(lineSpacing)的倍数(可根据字体大小变化修改倍数)
    paragraphStyle.lineHeightMultiple = 1.0;
    
    if (isTitle) {
        // 行间距
        paragraphStyle.lineSpacing = 0;
        // 段间距
        paragraphStyle.paragraphSpacing = 0;
        // 对其
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
    }else{
        // 行间距
        paragraphStyle.lineSpacing = self.lineSpacing;
        // 段间距
        paragraphStyle.paragraphSpacing = self.paragraphSpacing;
        // 对其
        paragraphStyle.alignment = NSTextAlignmentJustified;
    }
    
    if (isPageing) {
        return @{NSFontAttributeName:[self fontWithIsTitle:isTitle],NSParagraphStyleAttributeName:paragraphStyle};
    }else{
        return @{NSFontAttributeName:[self fontWithIsTitle:isTitle],
                 NSForegroundColorAttributeName:self.textColor,
                 NSParagraphStyleAttributeName:paragraphStyle};
    }
}

/// 保存配置修改
- (void)save{
    NSDictionary *dict = @{@"bgColorIndex": @(_bgColorIndex),
        @"fontType": @(_fontType),
        @"effectType": @(_effectType),
        @"spacingType": @(_spacingType),
        @"progressType": @(_progressType),
        @"fontSize": @(_fontSize)};
    [YLReadUserDefaults setObjectWithKey:kYLRead_Save_Configure object:dict];
}

- (UIColor *)textColor{
    return [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1];
}

- (UIColor *)statusTextColor{
    return [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1];
}

- (UIColor *)bgColor{
    return kYLRead_Color_BG()[_bgColorIndex];
}

- (CGFloat)lineSpacing{
    if (self.spacingType == YLSpacingTypeBig) {
        return 10.0;
    }else if (self.spacingType == YLSpacingTypeMiddle){
        return 7.0;
    }else{
        return 5.0;
    }
}

- (CGFloat)paragraphSpacing{
    if (self.spacingType == YLSpacingTypeBig) {
        return 20.0;
    }else if (self.spacingType == YLSpacingTypeMiddle){
        return 15.0;
    }else{
        return 10.0;
    }
}

- (void)setFontSize:(NSInteger)fontSize{
    _fontSize = fontSize;
}

@end
