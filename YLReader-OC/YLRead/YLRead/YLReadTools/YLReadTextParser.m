//
//  YLReadTextParser.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/3.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadTextParser.h"
#import "YLReadRecordModel.h"
#import "YLReadChapterListModel.h"
#import "YLReadChapterModel.h"
#import "NSString+Extend.h"

@implementation YLReadTextParser

/// 异步解析本地链接
///
/// - Parameters:
///   - url: 本地文件地址
///   - completion: 解析完成
+ (void)parserWithURL:(NSURL *)url completion:(ParserHanler)handler{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
        YLReadModel *model = [self parserWithURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(model);
        });
    });
}

/// 解析本地链接
///
/// - Parameter url: 本地文件地址
/// - Returns: 阅读对象
+ (YLReadModel *)parserForceWithURL:(NSURL *)url{
    // 链接不为空且是本地文件路径
    if (url == nil || url.absoluteString.length < 1 || !url.isFileURL) {
        return nil;
    }
    // 获取文件后缀名作为 bookName
    NSString *bookName = [url.absoluteString stringByRemovingPercentEncoding].lastPathComponent.stringByDeletingPathExtension ? : @"";
    // bookName 作为 bookID
    NSString *bookID = bookName;
    if (bookID.length < 1) {// bookID 为空
        return nil;
    }
    // 解析数据
    NSString *content = [YLReadParser encodeWithURL:url];
    // 解析失败
    if (content.length < 1) {
        return nil;
    }
    // 解析内容并获得章节列表
    NSMutableArray<YLReadChapterListModel *> *chapterListModels = [self parserWithBookID:bookID content:content];
    // 解析内容失败
    if (chapterListModels.count < 1) {
        return nil;
    }
    // 阅读模型
    YLReadModel *readModel = [YLReadModel modelWithBookID:bookID];
    // 书籍类型
    readModel.bookSourceType = YLBookSourceTypeLocal;
    // 小说名称
    readModel.bookName = bookName;
    // 记录章节列表
    readModel.chapterListModels = chapterListModels;
    // 设置第一个章节为阅读记录
    if (![YLReadRecordModel isExistWithBookID:readModel.bookID]) {
        [readModel.recordModel modifyWithChapterID:readModel.chapterListModels.firstObject.id toPage:0 isSave:NO];
    }
    // 保存
    [readModel save];
    // 返回
    return readModel;
}

+ (YLReadModel *)parserWithURL:(NSURL *)url{
    // 链接不为空且是本地文件路径
    if (url == nil || url.absoluteString.length < 1 || !url.isFileURL) {
        return nil;
    }
        
    // 获取文件后缀名作为 bookName
    NSString *bookName = [url.absoluteString stringByRemovingPercentEncoding].lastPathComponent.stringByDeletingPathExtension ? : @"";
    // bookName 作为 bookID
    NSString *bookID = bookName;
    if (bookID.length < 1) {// bookID 为空
        return nil;
    }
    if (![YLReadModel isExistWithBookID:bookID]) {// 不存在
        return [YLReadTextParser parserForceWithURL:url];
    }else{ // 存在
        // 返回
        return [YLReadModel modelWithBookID:bookID];
    }
}

/**  解析整本小说
 * @param bookID 小说ID
 * @param contentString 小说内容
 * @return 章节列表
 */
+ (NSMutableArray<YLReadChapterListModel *> *)parserWithBookID:(NSString *)bookID content:(NSString *)contentString{
    // 章节列表
    NSMutableArray<YLReadChapterListModel *> *chapterListModels = [NSMutableArray array];
    
    // 文字排版
    NSString *content = [YLReadParser contentTypesettingWithContent:contentString];
    
    // 正则匹配
    NSString *parten = @"第[0-9一二两三四五六七八九十零百千]*[章回].*";
    parten = @"第[0-9一二两三四五六七八九十零百千]*[章].*";
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:parten options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *results = [regularExpression matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length)];
    // 章节数量
    NSInteger count = results.count;
    
    // 解析匹配结果
    if (count) {
        // 记录最后一个Range
        NSRange lastRange = NSMakeRange(0, 0);
        // 记录最后一个章节对象
        YLReadChapterModel *lastChapterModel = nil;
        // 判断是否有前言
        BOOL isHavePreface = [[content substringToIndex:10] containsString:@"前言"];
        // 遍历
        for (int i = 0; i < count + 1; i ++) {
            // 章节数量分析: count + 1  = 前言内容 + 匹配到的章节数量
            NSRange range = NSMakeRange(0, 0);
            NSUInteger location = 0;
            if (i < count) {
                range = results[i].range;
                location = range.location;
            }
            // 章节内容
            YLReadChapterModel *curentChapter = [[YLReadChapterModel alloc]init];
            // 书ID
            curentChapter.bookID = bookID;
            // 章节ID
            curentChapter.id = i + isHavePreface;
            // 优先级
            curentChapter.priority = i - !isHavePreface;
            if (i == 0) { // 前言
                // 章节名
                curentChapter.name = @"前言";
                // 内容
                curentChapter.content = [content substringWithRange:NSMakeRange(0, location)];
                // 记录
                lastRange = range;
                // 没有内容则不需要添加列表
                if (!isHavePreface) {
                    continue;
                }
            }else if (i == count) { // 结尾:最后一章
                // 章节名
                curentChapter.name = [content substringWithRange:lastRange];
                // 内容(不包含章节名)
                curentChapter.content = [content substringWithRange:NSMakeRange(lastRange.location + lastRange.length, content.length - lastRange.location - lastRange.length)];
            }else { // 中间章节
                // 章节名
                curentChapter.name = [content substringWithRange:lastRange];
                // 内容(不包含章节名)
                curentChapter.content = [content substringWithRange:NSMakeRange(lastRange.location + lastRange.length, location - lastRange.location - lastRange.length)];
            }
            
            // 章节开头双空格 + 章节纯内容
            curentChapter.content = [NSString stringWithFormat:@"%@%@",kYLReadParagraphSpace,curentChapter.content.removeSEHeadAndTail];
            // 设置上一个章节ID
            if (i == 0) {
                curentChapter.previousChapterID = kYLReadChapterIDMin;
            }else{
                curentChapter.previousChapterID = lastChapterModel.id;
            }
            // 设置下一个章节ID
            if (i == count) { // 最后一章
                curentChapter.nextChapterID = kYLReadChapterIDMax;
            }
            // 保存
            [curentChapter save];
            
            lastChapterModel.nextChapterID = curentChapter.id;
            [lastChapterModel save];
            
            // 记录
            lastRange = range;
            // 通过章节内容生成章节列表
            [chapterListModels addObject:[self getChapterListModel:curentChapter]];
            
            lastChapterModel = curentChapter;
        }
    }else{
        // 章节内容
        YLReadChapterModel *chapterModel = [[YLReadChapterModel alloc] init];
        // 书ID
        chapterModel.bookID = bookID;
        // 章节ID
        chapterModel.id = 1;
        // 章节名
        chapterModel.name = @"前言";
        // 优先级
        chapterModel.priority = 0;
        // 内容
        chapterModel.content = [NSString stringWithFormat:@"%@%@",kYLReadParagraphSpace,content.removeSEHeadAndTail];
        // 保存
        [chapterModel save];
        // 添加章节列表模型
        [chapterListModels addObject:[self getChapterListModel:chapterModel]];
    }
    return chapterListModels;
}

/// 获取章节列表对象
///
/// - Parameter chapterModel: 章节内容对象
/// - Returns: 章节列表对象
+ (YLReadChapterListModel *)getChapterListModel:(YLReadChapterModel *)chapterModel{
    YLReadChapterListModel *chapterListModel = [[YLReadChapterListModel alloc]init];
    chapterListModel.bookID = chapterModel.bookID;
    chapterListModel.id = chapterModel.id;
    chapterListModel.name = chapterModel.name;
    return chapterListModel;
}

@end

