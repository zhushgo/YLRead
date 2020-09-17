//
//  YLReadRecordModel.h
//  YLRead
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// 记录当前章节阅读到的坐标
extern NSUInteger kYLReadRecordCurrentChapterLocation;

@class YLReadChapterModel,YLReadPageModel;
@interface YLReadRecordModel : NSObject <NSCoding, NSCopying>

/// 小说ID
@property (nonatomic, strong) NSString *bookID;
/// 当前记录的阅读章节
@property (nonatomic, strong) YLReadChapterModel *chapterModel;

/// 阅读到的页码(上传阅读记录到服务器时传当前页面的 location 上去,从服务器拿回来 location 在转成页码。精准回到上次阅读位置)
@property (nonatomic, assign) NSUInteger page;

/// 当前记录分页模型
@property (nonatomic, strong) YLReadPageModel *pageModel;

/// 当前记录起始坐标
@property (nonatomic, assign) NSUInteger locationFirst;

/// 当前记录末尾坐标
@property (nonatomic, assign) NSUInteger locationLast;

/// 当前记录是否为第一个章节
@property (nonatomic, assign) BOOL isFirstChapter;

/// 当前记录是否为最后一个章节
@property (nonatomic, assign) BOOL isLastChapter;

/// 当前记录是否为第一页
@property (nonatomic, assign) BOOL isFirstPage;

/// 当前记录是否为最后一页
@property (nonatomic, assign) BOOL isLastPage;

/// 当前记录页码字符串
@property (nonatomic, strong) NSString *contentString;

/// 当前记录页码富文本
@property (nonatomic, strong) NSAttributedString *contentAttributedString;

@end



///阅读器业务
@interface YLReadRecordModel (Service)

/// 当前记录切到上一页
- (void)previousPage;

/// 当前记录切到下一页
- (void)nextPage;

/// 当前记录切到第一页
- (void)firstPage;

/// 修改阅读记录为指定章节位置
- (void)modifyWithChapterModel:(YLReadChapterModel *)chapterModel page:(NSInteger)page;
- (void)modifyWithChapterModel:(YLReadChapterModel *)chapterModel page:(NSInteger)page isSave:(BOOL)isSave;

/// 修改阅读记录为指定章节位置
- (void)modifyWithChapterID:(NSUInteger)chapterID location:(NSInteger)location;
- (void)modifyWithChapterID:(NSUInteger)chapterID location:(NSInteger)location isSave:(BOOL)isSave;

/// 修改阅读记录为指定章节页码 (toPage == kYLReadLastPage 为当前章节最后一页)
- (void)modifyWithChapterID:(NSUInteger)chapterID toPage:(NSInteger)toPage;
- (void)modifyWithChapterID:(NSUInteger)chapterID toPage:(NSInteger)toPage isSave:(BOOL)isSave;

/// 更新字体
- (void)updateFont;
- (void)updateFontWithIsSave:(BOOL)isSave;

/// 拷贝阅读记录
- (YLReadRecordModel *)copyTheModel;

/// 保存记录
- (void)save;

/// 是否存在阅读记录
+ (BOOL)isExistWithBookID:(NSString *)bookID;

/// 获取阅读记录对象,如果没有记录则创建对象返回
+ (YLReadRecordModel *)modelWithBookID:(NSString *)bookID;


@end


@interface YLReadRecordModel (JsonModel)

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
