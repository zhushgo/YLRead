//
//  YLReadTextFastParser.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/7.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLReadParser.h"

NS_ASSUME_NONNULL_BEGIN

@class YLReadChapterModel;
@interface YLReadTextFastParser : NSObject

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
///   - readModel: readModel
///   - content: 小说内容
+ (void)parserWithReadModel:(YLReadModel *)readModel content:(NSString *)content;


/// 获取单个指定章节
+ (YLReadChapterModel *)parserWithReadModel:(YLReadModel *)readModel chapterID:(NSInteger)chapterID;
+ (YLReadChapterModel *)parserWithReadModel:(YLReadModel *)readModel chapterID:(NSInteger)chapterID isUpdateFont:(BOOL)isUpdateFont;

@end

NS_ASSUME_NONNULL_END
