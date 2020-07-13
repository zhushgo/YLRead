//
//  YLReadTextParser.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/3.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLReadParser.h"

NS_ASSUME_NONNULL_BEGIN

/** 解析本地文本：
 *
 * 取文本 URL后缀为小说名 ：file:///~.app/小说.txt
 * 以正则搜索 "第[0-9一二三四五六七八九十百千]*[章回].*"
 *
 * 文本内容：
 *   第n章
 *      xxxxxxxxxxxxxxxx
 *   第n+1章
 *      xxxxxxxxxxxxxxxx
 *
 * 符合此格式的文件，都能解析
 */
@class YLReadChapterListModel,YLReadChapterModel;
@interface YLReadTextParser : NSObject

/// 异步解析本地链接
///
/// - Parameters:
///   - url: 本地文件地址
///   - completion: 解析完成
+ (void)parserWithURL:(NSURL *)url completion:(ParserHanler)handler;


/// 解析本地链接
///
/// - Parameter url: 本地文件地址
/// - Returns: 阅读对象
+ (YLReadModel *)parserWithURL:(NSURL *)url;

/// 解析整本小说
///
/// - Parameters:
///   - bookID: 小说ID
///   - content: 小说内容
/// - Returns: 章节列表
+ (NSMutableArray<YLReadChapterListModel *> *)parserWithBookID:(NSString *)bookID content:(NSString *)contentString;


/// 获取章节列表对象
///
/// - Parameter chapterModel: 章节内容对象
/// - Returns: 章节列表对象
+ (YLReadChapterListModel *)getChapterListModel:(YLReadChapterModel *)chapterModel;

@end

NS_ASSUME_NONNULL_END
