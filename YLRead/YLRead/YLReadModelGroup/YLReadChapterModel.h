//
//  YLReadChapterModel.h
//  FM
//
//  Created by 苏沫离 on 2020/6/28.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YLReadPageModel;
@interface YLReadChapterModel : NSObject <NSCoding, NSCopying>

 /// 小说ID
@property (nonatomic, strong) NSString *bookID;

 /// 章节ID
@property (nonatomic, assign) NSInteger id;
  /// 上一章ID
@property (nonatomic, assign) NSInteger previousChapterID;
 /// 下一章ID
@property (nonatomic, assign) NSInteger nextChapterID;

/// 章节名称
@property (nonatomic, strong) NSString *name;

 /// 内容属性变化记录(我这里就只判断内容了字体属性变化了，标题也就跟着变化或者保存变化都无所谓了。如果有需求可以在加上比较标题属性变化)
 @property (nonatomic, strong) NSDictionary<NSAttributedStringKey,id> *attributes;


 /// 内容
 /// 此处 content 是经过排版好且双空格开头的内容。
 /// 如果是网络数据需要确认是否处理好了,也就是在网络章节数据拿到之后, 使用排版接口进行排版并在开头加上双空格。(例如: DZM_READ_PH_SPACE + 排版好的content )
 /// 排版内容搜索 contentTypesetting 方法
@property (nonatomic, strong) NSString *content;

 /// 优先级 (一般章节段落都带有排序的优先级 从0开始)
@property (nonatomic, assign) NSInteger priority;

/// 本章有多少页
@property (nonatomic, assign) NSInteger pageCount;

/// 分页数据
@property (nonatomic, strong) NSArray<YLReadPageModel *> *pageModels;

  
 // MARK: 快捷获取
 
 /// 当前章节是否为第一个章节
@property (nonatomic, assign) BOOL isFirstChapter;
 
/// 当前章节是否为最后一个章节
@property (nonatomic, assign) BOOL isLastChapter;
 
 /// 完整章节名称
@property (nonatomic, strong) NSString *fullName;
 
 /// 完整富文本内容
@property (nonatomic, strong) NSAttributedString *fullContent;

 
 /// 分页总高 (上下滚动模式使用)
@property (nonatomic, assign) float pageTotalHeight;



/// 更新字体
- (void)updateFont;

/// 完整内容排版
- (NSMutableAttributedString *)fullContentAttrString;

/// 获取指定页码字符串
- (NSString *)contentString:(NSUInteger)page;

/// 获取指定页码富文本
- (NSAttributedString *)contentAttributedString:(NSUInteger)page;

/// 获取指定页开始坐标
- (NSUInteger)locationFirst:(NSUInteger)page;

/// 获取指定页码末尾坐标
- (NSUInteger)locationLast:(NSUInteger)page;

/// 获取指定页中间
- (NSUInteger)locationCenter:(NSUInteger)page;

/// 获取存在指定坐标的页码
- (NSUInteger)page:(NSUInteger)location;

/// 保存
- (void)save;

/// 是否存在章节内容
+ (BOOL)isExistWithBookID:(NSString *)bookID chapterID:(NSInteger)chapterID;

/// 获取章节对象,如果则创建对象返回
/// 获取章节对象,如果则创建对象返回
+ (instancetype)modelWithBookID:(NSString *)bookID chapterID:(NSInteger)chapterID;
+ (instancetype)modelWithBookID:(NSString *)bookID chapterID:(NSInteger)chapterID isUpdateFont:(BOOL)isUpdateFont;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;


@end

NS_ASSUME_NONNULL_END
