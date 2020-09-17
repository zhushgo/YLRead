//
//  YLReadParser.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/7.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadParser.h"
#import "YLReadPageModel.h"
#import "YLCoreText.h"
#import "NSString+YLReader.h"
#import "YLReadRecordModel.h"
#import "YLReadChapterListModel.h"
#import "YLReadChapterModel.h"

@implementation YLReadParser

/// 异步解析本地 txt
+ (void)parserLocalTxtWithFileURL:(NSURL *)fileURL completion:(ParserHanler)handler{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
        YLReadModel *model = [self parserLocalTxtWithFileURL:fileURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(model);
        });
    });
}

/// 同步解析本地 txt
+ (YLReadModel *)parserLocalTxtWithFileURL:(NSURL *)fileURL{
    // 获取文件后缀名作为 bookName
    NSString *bookName = [YLReadParser getBookNameWithFileURL:fileURL];
    // bookName 作为 bookID
    NSString *bookID = bookName;
    if (bookID.length < 1) {// bookID 为空
        return nil;
    }
    if (![YLReadModel isExistWithBookID:bookID]) {// 不存在
        // 解析数据
        NSString *content = [NSString encodeWithURL:fileURL];
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
        return readModel;
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
    NSString *content = [NSString contentTypesettingWithContent:contentString];
    
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
            [chapterListModels addObject:curentChapter.toListModel];
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
        [chapterListModels addObject:chapterModel.toListModel];
    }
    return chapterListModels;
}

@end


///解析书本
@implementation YLReadParser (Book)

+ (NSString *)getBookNameWithFileURL:(NSURL *)fileURL{
    // 链接不为空且是本地文件路径
    if (fileURL == nil || fileURL.absoluteString.length < 1 || !fileURL.isFileURL) {
        return nil;
    }
    // 获取文件后缀名作为 bookName
    NSString *bookName = [fileURL.absoluteString stringByRemovingPercentEncoding].lastPathComponent.stringByDeletingPathExtension ? : @"";
    return bookName;
}

@end



///解析章节
@implementation YLReadParser (Chapter)

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
        NSInteger previousChapterID = isFirstChapter ? kYLReadChapterIDMin : readModel.chapterListModels[priority - 1].id;
        // 下一个章节ID
        NSInteger nextChapterID  = isLastChapter ? kYLReadChapterIDMax : readModel.chapterListModels[priority + 1].id;
        
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
        chapterModel.content = [NSString stringWithFormat:@"%@%@",kYLReadParagraphSpace,[readModel.fullText substringWithRange:range].removeSEHeadAndTail];
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


///内容分页
@implementation YLReadParser (Page)

+ (NSMutableArray<YLReadPageModel *> *)pageingWithAttrString:(NSAttributedString *)attrString rect:(CGRect)rect{
    return [self pageingWithAttrString:attrString rect:rect isFirstChapter:NO];
}

/** 内容分页
 * param attrString 内容
 * @param rect 内容显示范围
 * @param isFirstChapter 是否为本文章第一个展示章节,如果是则加入书籍首页
 * @return 内容分页列表
*/
+ (NSMutableArray<YLReadPageModel *> *)pageingWithAttrString:(NSAttributedString *)attrString rect:(CGRect)rect isFirstChapter:(BOOL)isFirstChapter{
    NSMutableArray<YLReadPageModel *> *pageModels = [NSMutableArray array];
    if (isFirstChapter) { // 第一页为书籍页面
        YLReadPageModel *pageModel = [[YLReadPageModel alloc]init];
        pageModel.range = NSMakeRange(kYLReadBookHomePage, 1);
        pageModel.contentSize = getReadViewRect().size;
        [pageModels addObject:pageModel];
    }
    NSMutableArray<NSValue *> *ranges = getPageRanges(attrString, rect);
    if (ranges && ranges.count) {
        [ranges enumerateObjectsUsingBlock:^(NSValue * _Nonnull rangeValue, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = rangeValue.rangeValue;
            NSAttributedString *content = [attrString attributedSubstringFromRange:range];

            YLReadPageModel *pageModel = [[YLReadPageModel alloc]init];
            pageModel.range = range;
            pageModel.content = content;
            pageModel.page = idx;
            
            // --- (滚动模式 || 长按菜单) 使用 ---
            // 内容Size (滚动模式 || 长按菜单)
            CGFloat maxW = getReadViewRect().size.width;
            pageModel.contentSize = CGSizeMake(maxW, getSizeWithAttributedString(content, maxW).height);
            // 当前页面开头是什么数据开头 (滚动模式)
            if (idx == 0) {
                pageModel.headType = YLPageHeadTypeChapterName;
                pageModel.headTypeHeight = 0;
            }else if ([content.string hasPrefix:kYLReadParagraphSpace]) {
                pageModel.headType = YLPageHeadTypeParagraph;
                pageModel.headTypeHeight = YLReadConfigure.shareConfigure.paragraphSpacing;
            }else{
                pageModel.headType = YLPageHeadTypeLine;
                pageModel.headTypeHeight = YLReadConfigure.shareConfigure.lineSpacing;
            }
            // --- (滚动模式 || 长按菜单) 使用 ---
            [pageModels addObject:pageModel];
        }];
    }
    return pageModels;
}

@end
