//
//  YLReadParser.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/7.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YLReadModel.h"
#import "YLReadChapterListModel.h"

NS_ASSUME_NONNULL_BEGIN

/** 本地 txt 文本解析
 */
@class YLReadPageModel,YLReadChapterListModel,YLReadChapterModel;

@interface YLReadParser : NSObject

@end



///解析书本
@interface YLReadParser (Book)

+ (NSString *)getBookNameWithFileURL:(NSURL *)fileURL;

/// 同步解析本地 txt
+ (YLReadModel *)parserLocalTxtWithFileURL:(NSURL *)fileURL;

/// 异步解析本地 txt
+ (void)parserLocalTxtWithFileURL:(NSURL *)fileURL completion:(void(^)(YLReadModel *readModel))parserHanler;

@end


///解析章节
@interface YLReadParser (Chapter)
/// 获取单个指定章节
+ (YLReadChapterModel *)parserWithReadModel:(YLReadModel *)readModel chapterID:(NSInteger)chapterID;
+ (YLReadChapterModel *)parserWithReadModel:(YLReadModel *)readModel chapterID:(NSInteger)chapterID isUpdateFont:(BOOL)isUpdateFont;

/** 解析整本小说的章节
 * @param bookID 小说ID
 * @param contentString 小说内容
 * @return 章节列表
 */
+ (NSMutableArray<YLReadChapterListModel *> *)parserWithBookID:(NSString *)bookID content:(NSString *)contentString;

@end



///内容分页
@interface YLReadParser (Page)

/** 内容分页
 * param attrString 内容
 * @param rect 内容显示范围
 * @param isFirstChapter 是否为本文章第一个展示章节,如果是则加入书籍首页
 * @return 内容分页列表
 */
+ (NSMutableArray<YLReadPageModel *> *)pageingWithAttrString:(NSAttributedString *)attrString rect:(CGRect)rect isFirstChapter:(BOOL)isFirstChapter;
+ (NSMutableArray<YLReadPageModel *> *)pageingWithAttrString:(NSAttributedString *)attrString rect:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
