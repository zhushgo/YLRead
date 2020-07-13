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
        [readModel.recordModel modifyWithChapterID:readModel.chapterListModels.firstObject.id toPage:0 isSave:NO];
        // 保存
        [readModel save];
        // 返回
        return readModel;
    }else{ // 存在
        // 返回
        return [YLReadModel modelWithBookID:bookID];
    }
}

/// 解析整本小说
///
/// - Parameters:
///   - bookID: 小说ID
///   - content: 小说内容
/// - Returns: 章节列表
+ (NSMutableArray<YLReadChapterListModel *> *)parserWithBookID:(NSString *)bookID content:(NSString *)contentString{
    // 章节列表
    NSMutableArray<YLReadChapterListModel *> *chapterListModels = [NSMutableArray array];
    // 正则
    NSString *parten = @"第[0-9一二三四五六七八九十百千]*[章回].*";
    // 排版
    NSString *content = [YLReadParser contentTypesettingWithContent:contentString];
    // 开始匹配
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:parten options:NSRegularExpressionCaseInsensitive error:nil];
    // 正则匹配结果
    NSArray<NSTextCheckingResult *> *results = [regularExpression matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length)];
    // 解析匹配结果
    if (results.count) {
        // 章节数量
        NSInteger count = results.count;
        // 记录最后一个Range
        NSRange lastRange;
        // 记录最后一个章节对象C
        YLReadChapterModel *lastChapterModel = nil;
        // 有前言
        BOOL isHavePreface = YES;
        // 遍历
        for (int i = 0; i < count + 1; i ++) {
            // 章节数量分析:
            // count + 1  = 匹配到的章节数量 + 最后一个章节
            // 1 + count + 1  = 第一章前面的前言内容 + 匹配到的章节数量 + 最后一个章节
            NSLog(@"章节总数: \(%ld + 1)  当前正在解析: \(%d + 1)",count,i);
            NSRange range = NSMakeRange(0, 0);
            NSUInteger location = 0;
            if (i < count) {
                range = results[i].range;
                location = range.location;
            }
            // 章节内容
            YLReadChapterModel *chapterModel = [[YLReadChapterModel alloc]init];
            // 书ID
            chapterModel.bookID = bookID;
            // 章节ID
            chapterModel.id = i + isHavePreface;
            // 优先级
            chapterModel.priority = i - !isHavePreface;
            if (i == 0) { // 前言
                // 章节名
                chapterModel.name = @"前言";
                // 内容
                chapterModel.content = [content substringWithRange:NSMakeRange(0, location)];
                // 记录
                lastRange = range;
                // 没有内容则不需要添加列表
                if (chapterModel.content.length < 1) {
                    isHavePreface = NO;
                    continue;
                }
            }else if (i == count) { // 结尾
                // 章节名
                chapterModel.name = [content substringWithRange:lastRange];
                // 内容(不包含章节名)
                chapterModel.content = [content substringWithRange:NSMakeRange(lastRange.location + lastRange.length, content.length - lastRange.location - lastRange.length)];
            }else { // 中间章节
                // 章节名
                chapterModel.name = [content substringWithRange:lastRange];
                // 内容(不包含章节名)
                chapterModel.content = [content substringWithRange:NSMakeRange(lastRange.location + lastRange.length, location - lastRange.location - lastRange.length)];
            }
            
            // 章节开头双空格 + 章节纯内容
            chapterModel.content = [NSString stringWithFormat:@"　　　　%@",chapterModel.content.removeSEHeadAndTail];
            // 设置上一个章节ID
            chapterModel.previousChapterID = lastChapterModel.id;
            
            // 设置下一个章节ID
            if (i == (count - 1)) { // 最后一个章节了
                chapterModel.nextChapterID = -1;
            }else{
                lastChapterModel.nextChapterID = chapterModel.id;
            }
                
            // 保存
            [chapterModel save];
            [lastChapterModel save];
            
            // 记录
            lastRange = range;
            lastChapterModel = chapterModel;
            
            // 通过章节内容生成章节列表
            [chapterListModels addObject:[self getChapterListModel:chapterModel]];
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
        chapterModel.content = [NSString stringWithFormat:@"　　　　%@",content.removeSEHeadAndTail];
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

