//
//  YLReadPageModel.h
//  FM
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 分页内容是以什么开头
typedef NS_ENUM(NSUInteger,YLPageHeadType) {
    YLPageHeadTypeChapterName = 0,/// 章节名
    YLPageHeadTypeParagraph,/// 段落
    YLPageHeadTypeLine,/// 行内容
};

@interface YLReadPageModel : NSObject <NSCoding, NSCopying>

/// 当前页内容
@property (nonatomic, strong) NSAttributedString *content;
/// 当前页范围
@property (nonatomic, assign) NSRange range;
/// 当前页序号
@property (nonatomic, assign) NSInteger page;

/// 根据开头类型返回开头高度 (目前主要是滚动模式使用)
@property (nonatomic, assign) CGFloat headTypeHeight;

/// 当前内容Size (目前主要是(滚动模式 || 长按模式)使用)
@property (nonatomic, assign) CGSize contentSize;

/// 当前内容头部类型 (目前主要是滚动模式使用)
//@property (nonatomic, assign) double headTypeIndex;
@property (nonatomic, assign) YLPageHeadType headType;

/// 当前内容总高(cell 高度)
@property (nonatomic, assign) CGFloat cellHeight;

/// 书籍首页
@property (nonatomic, assign) BOOL isHomePage;

/// 获取显示内容(考虑可能会变换字体颜色的情况)
@property (nonatomic, strong) NSAttributedString *showContent;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
