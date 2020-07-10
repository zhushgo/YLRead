//
//  YLReadConfigure.h
//  FM
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

/// 主题颜色
FOUNDATION_EXPORT UIColor *kYLRead_Color_Main(void);
/// 菜单默认颜色
FOUNDATION_EXPORT UIColor *kYLRead_Color_Menu(void);
/// 菜单背景颜色
FOUNDATION_EXPORT UIColor *kYLRead_Color_MenuBG(void);
/// 阅读背景颜色列表
FOUNDATION_EXPORT NSArray<UIColor *> *kYLRead_Color_BG(void);

/// 阅读背景颜色支持 - 牛皮黄
FOUNDATION_EXPORT UIColor *kYLRead_Color_BG_0(void);




/// 阅读最小阅读字体大小
FOUNDATION_EXPORT NSInteger const kYLRead_FontSize_Min;
/// 阅读最大阅读字体大小
FOUNDATION_EXPORT NSInteger const kYLRead_FontSize_Max;
/// 阅读默认字体大小
FOUNDATION_EXPORT NSInteger const kYLRead_FontSize_Default;
/// 阅读字体大小叠加指数
FOUNDATION_EXPORT NSInteger const kYLRead_FontSize_Space;
/// 章节标题 - 在当前字体大小上叠加指数
FOUNDATION_EXPORT NSInteger const kYLRead_FontSize_TitleSpace;


/// 阅读翻页类型
typedef NS_ENUM(NSUInteger,YLEffectType) {
    YLEffectTypeSimulation = 0,/// 仿真
    YLEffectTypeCover,/// 覆盖
    YLEffectTypeTranslation,/// 平移
    YLEffectTypeScroll,/// 滚动
    YLEffectTypeNone,/// 无效果
};

/// 阅读进度类型
typedef NS_ENUM(NSUInteger,YLProgressType) {
    YLProgressTypeTotal = 0,/// 总进度
    YLProgressTypePage,/// 分页进度
};

/// 阅读字体类型
typedef NS_ENUM(NSUInteger,YLFontType) {
    YLFontTypeSystem = 0,/// 系统
    YLFontTypeOne,/// 黑体
    YLFontTypeTwo,/// 楷体
    YLFontTypeThree,/// 宋体
};

/// 阅读内容间距类型
typedef NS_ENUM(NSUInteger,YLSpacingType) {
    YLSpacingTypeBig = 0,/// 大间距
    YLSpacingTypeMiddle,/// 适中间距
    YLSpacingTypeSmall,/// 小间距
};


// MARK: 阅读页面配置
@interface YLReadConfigure : NSObject
/// 开启长按菜单功能 (滚动模式是不支持长按功能的),默认为 YES
@property (nonatomic ,assign) BOOL openLongPress;
///字体大小
@property (nonatomic ,assign) NSInteger fontSize;
/// 字体类型
@property (nonatomic ,assign) YLFontType fontType;
/// 翻页类型
@property (nonatomic ,assign) YLEffectType effectType;

/// 使用分页进度 || 总文章进度(网络文章也可以使用)
/// 总文章进度注意: 总文章进度需要有整本书的章节总数,以及当前章节带有从0开始排序的索引。
/// 如果还需要在拖拽底部功能条上进度条过程中展示章节名,则需要带上章节列表数据,并去 DZMRMProgressView 文件中找到 ASValueTrackingSliderDataSource 修改返回数据源为章节名。
/// 进度显示索引
@property (nonatomic ,assign) YLProgressType progressType;

/// 间距类型
@property (nonatomic ,assign) YLSpacingType spacingType;
/// 行间距(请设置整数,因为需要比较是否需要重新分页,小数点没法判断相等)
@property (nonatomic ,assign) CGFloat lineSpacing;
/// 段间距(请设置整数,因为需要比较是否需要重新分页,小数点没法判断相等)
@property (nonatomic ,assign) CGFloat paragraphSpacing;

///字体颜色
@property (nonatomic ,strong) UIColor *textColor;
/// 状态栏字体颜色
@property (nonatomic ,strong) UIColor *statusTextColor;
    
/// 背景颜色索引
@property (nonatomic ,assign) NSInteger bgColorIndex;
/// 背景颜色
@property (nonatomic ,strong) UIColor *bgColor;

- (void)save;

/// 字体属性
/// isPaging: 为YES的时候只需要返回跟分页相关的属性即可 (原因:包含UIColor,小数点相关的...不可返回,因为无法进行比较)
- (NSDictionary<NSAttributedStringKey,id> *)attributesWithIsTitle:(BOOL)isTitle;
- (NSDictionary<NSAttributedStringKey,id> *)attributesWithIsTitle:(BOOL)isTitle isPageing:(BOOL)isPageing;

+ (instancetype)shareConfigure;

@end

NS_ASSUME_NONNULL_END
