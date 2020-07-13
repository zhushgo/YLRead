//
//  YLReadTextFastParser.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/7.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadTextFastParser.h"
#import "YLReadChapterListModel.h"
#import "YLReadRecordModel.h"
#import "YLReadChapterModel.h"
#import "NSString+Extend.h"

@implementation YLReadTextFastParser

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
        
        // 阅读模型
        YLReadModel *readModel = [YLReadModel modelWithBookID:bookID];

        // 书籍类型
        readModel.bookSourceType = YLBookSourceTypeLocal;
        
        // 小说名称
        readModel.bookName = bookName;
                
        // 解析内容并获得章节列表
        [self parserWithReadModel:readModel content:content];
        
        // 解析内容失败
        if (readModel.chapterListModels.count < 1) {
            return nil;
        }
        
        // 首章
        YLReadChapterListModel *chapterListModel = readModel.chapterListModels.firstObject;
        
        // 加载首章
        [self parserWithReadModel:readModel chapterID:chapterListModel.id];
        
        // 设置第一个章节为阅读记录
        [readModel.recordModel modifyWithChapterID:chapterListModel.id toPage:0 isSave:NO];
        
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
///   - readModel: readModel
///   - content: 小说内容
+ (void)parserWithReadModel:(YLReadModel *)readModel content:(NSString *)content{
    
    // 章节列表
    NSMutableArray<YLReadChapterListModel *> *chapterListModels = [NSMutableArray array];
    
    // 章节范围列表 @{章节ID:@{章节优先级:章节内容Range}}
    NSMutableDictionary<NSString *,NSDictionary *> *ranges = [NSMutableDictionary dictionary];
    
    // 正则
    NSString *parten = @"第[0-9一二三四五六七八九十百千]*[章回].*";
    // 排版
    content = [YLReadParser contentTypesettingWithContent:content];

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
        // 有前言
        BOOL isHavePreface = true;
        // 便利
        for (int i = 0; i < count + 1; i ++){
            
            // 章节数量分析:
            // count + 1  = 匹配到的章节数量 + 最后一个章节
            // 1 + count + 1  = 第一章前面的前言内容 + 匹配到的章节数量 + 最后一个章节
            
            NSRange range = NSMakeRange(0, 0);
            NSUInteger location = 0;
            if (i < count) {
                range = results[i].range;                
                location = range.location;
            }
            
            // 章节列表
            YLReadChapterListModel *chapterListModel = [[YLReadChapterListModel alloc]init];
            // 书ID
            chapterListModel.bookID = readModel.bookID;
            // 章节ID
            chapterListModel.id = i + isHavePreface;
            // 优先级
            NSInteger priority = i - !isHavePreface;
            
            if (i == 0) { // 前言
                
                // 章节名
                chapterListModel.name = @"开始";
                // 内容Range
                [ranges setValue:@{[NSString stringWithFormat:@"%ld",priority]:[NSValue valueWithRange:NSMakeRange(0, location)]} forKey:[NSString stringWithFormat:@"%ld",chapterListModel.id]];
                
                // 内容
                content = [content substringWithRange:NSMakeRange(0, location)];
                // 记录
                lastRange = range;
                
                // 没有内容则不需要添加列表
                if (content.length < 1) {
                    isHavePreface = NO;
                    continue;
                }
            }else if (i == count) { // 结尾
                // 章节名
                chapterListModel.name = [content substringWithRange:lastRange];
                // 内容Range
                [ranges setValue:@{[NSString stringWithFormat:@"%ld",priority]:[NSValue valueWithRange:NSMakeRange(lastRange.location + lastRange.length, content.length - lastRange.location - lastRange.length)]} forKey:[NSString stringWithFormat:@"%ld",chapterListModel.id]];
            }else { // 中间章节
                
                // 章节名
                chapterListModel.name = [content substringWithRange:lastRange];
                
                // 内容Range
                [ranges setValue:@{[NSString stringWithFormat:@"%ld",priority]:[NSValue valueWithRange:NSMakeRange(lastRange.location + lastRange.length, location - lastRange.location - lastRange.length)]} forKey:[NSString stringWithFormat:@"%ld",chapterListModel.id]];
            }
            
            // 记录
            lastRange = range;
            
            // 通过章节内容生成章节列表
            [chapterListModels addObject:chapterListModel];
        }
        
    }else{
        
        // 章节列表
        YLReadChapterListModel *chapterListModel = [[YLReadChapterListModel alloc] init];
        
        // 章节名
        chapterListModel.name = @"开始";
        
        // 书ID
        chapterListModel.bookID = readModel.bookID;
        
        // 章节ID
        chapterListModel.id = 1;
        
        // 优先级
        NSInteger priority = 0;
        
        // 内容Range
        [ranges setValue:@{[NSString stringWithFormat:@"%ld",priority]:[NSValue valueWithRange:NSMakeRange(0, content.length)]} forKey:[NSString stringWithFormat:@"%ld",chapterListModel.id]];
        // 添加章节列表模型
        [chapterListModels addObject:chapterListModel];
    }
    
    
    // 小说全文
    readModel.fullText = content;
    
    // 章节列表
    readModel.chapterListModels = chapterListModels;
    
    // 章节内容范围
    readModel.ranges = ranges;
}

/// 获取单个指定章节
+ (YLReadChapterModel *)parserWithReadModel:(YLReadModel *)readModel chapterID:(NSInteger)chapterID {
    return [self parserWithReadModel:readModel chapterID:chapterID isUpdateFont:YES];
}

+ (YLReadChapterModel *)parserWithReadModel:(YLReadModel *)readModel chapterID:(NSInteger)chapterID isUpdateFont:(BOOL)isUpdateFont{
    // 获得[章节优先级:章节内容Range]
    NSDictionary<NSString *,NSValue *> *rangeDict = readModel.ranges[[NSString stringWithFormat:@"%ld",chapterID]];
    
    // 没有了
    if (rangeDict) {
         // 当前优先级
        NSInteger priority = rangeDict.allKeys.firstObject.integerValue;
        
        // 章节内容范围
        NSRange range = rangeDict.allValues.firstObject.rangeValue;
        
        // 当前章节
        YLReadChapterListModel *chapterListModel = readModel.chapterListModels[priority];
                
        /// 第一个章节
        BOOL isFirstChapter = (priority == 0);
                
        /// 最后一个章节
        BOOL isLastChapter = (priority == (readModel.chapterListModels.count - 1));
                
        // 上一个章节ID
        NSInteger previousChapterID = isFirstChapter ? -1 : readModel.chapterListModels[priority - 1].id;
                
        // 下一个章节ID
        NSInteger nextChapterID  = isLastChapter ? -1 : readModel.chapterListModels[priority + 1].id;
            
        // 章节内容
        YLReadChapterModel *chapterModel = [[YLReadChapterModel alloc] init];
        // 书ID
        chapterModel.bookID = chapterListModel.bookID;
        // 章节ID
        chapterModel.id = chapterListModel.id;
        // 章节名
        chapterModel.name = chapterListModel.name;
        // 优先级
        chapterModel.priority = priority;
        // 上一个章节ID
        chapterModel.previousChapterID = previousChapterID;
        // 下一个章节ID
        chapterModel.nextChapterID = nextChapterID;
        // 章节内容
        chapterModel.content = [NSString stringWithFormat:@"　　%@",[readModel.fullText substringWithRange:range].removeSEHeadAndTail];
        // 保存
        if (isUpdateFont) {
            [chapterModel updateFont];
        }else{
            [chapterModel save];
        }            
        // 返回
        return chapterModel;
        
    }
    return nil;
}


@end
