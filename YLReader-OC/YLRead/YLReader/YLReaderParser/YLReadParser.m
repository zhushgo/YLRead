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

/// 异步解析本地 txt
+ (void)parserLocalTxtWithFileURL:(NSURL *)fileURL completion:(void(^)(YLReadModel *readModel))parserHanler{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
        YLReadModel *model = [self parserLocalTxtWithFileURL:fileURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            parserHanler(model);
        });
    });
}

/// 同步解析本地 txt
+ (YLReadModel *)parserLocalTxtWithFileURL:(NSURL *)fileURL{
    // 获取文件后缀名作为 bookName
    NSString *bookName = [YLReadParser getBookNameWithFileURL:fileURL];
    NSString *bookID = bookName;// bookName 作为 bookID
    if (bookID.length < 1) {// bookID 为空
        return nil;
    }
    if (![YLReadModel isExistWithBookID:bookID]) {// 不存在
        NSString *content = [NSString encodeWithURL:fileURL];
        if (content.length < 1) {
            return nil;
        }
        // 解析内容并获得章节列表
        NSMutableArray<YLReadChapterListModel *> *chapterListModels = [self parserWithBookID:bookID content:content];
        if (chapterListModels.count < 1) {
            return nil;
        }
        // 阅读模型
        YLReadModel *readModel = [YLReadModel modelWithBookID:bookID];
        readModel.bookSourceType = YLBookSourceTypeLocal;
        readModel.bookName = bookName;
        readModel.chapterListModels = chapterListModels;
        if (![YLReadRecordModel isExistWithBookID:bookID]) {///没有阅读记录，则设置第一个章节为阅读记录
            [readModel.recordModel modifyWithChapterID:readModel.chapterListModels.firstObject.id toPage:0 isSave:NO];
        }
        [readModel save];
        return readModel;
    }else{
        return [YLReadModel modelWithBookID:bookID];
    }
}

@end



///解析章节
@implementation YLReadParser (Chapter)

/// 获取单个指定章节
+ (YLReadChapterModel *)parserWithReadModel:(YLReadModel *)readModel chapterID:(NSInteger)chapterID {
    return [self parserWithReadModel:readModel chapterID:chapterID isUpdateFont:YES];
}

+ (YLReadChapterModel *)parserWithReadModel:(YLReadModel *)readModel chapterID:(NSInteger)chapterID isUpdateFont:(BOOL)isUpdateFont{
    NSDictionary<NSString *,NSValue *> *rangeDict = readModel.ranges[[NSString stringWithFormat:@"%ld",chapterID]];
    if (rangeDict) {
         // 当前优先级
        NSInteger indexInChapterList = rangeDict.allKeys.firstObject.integerValue;
        // 章节内容范围
        NSRange range = rangeDict.allValues.firstObject.rangeValue;
        // 当前章节
        YLReadChapterListModel *chapterListModel = readModel.chapterListModels[indexInChapterList];
        BOOL isFirstChapter = (indexInChapterList == 0);
        BOOL isLastChapter = (indexInChapterList == (readModel.chapterListModels.count - 1));
        NSInteger previousChapterID = isFirstChapter ? kYLReadChapterIDMin : readModel.chapterListModels[indexInChapterList - 1].id;
        NSInteger nextChapterID  = isLastChapter ? kYLReadChapterIDMax : readModel.chapterListModels[indexInChapterList + 1].id;
        
        YLReadChapterModel *chapterModel = [[YLReadChapterModel alloc] init];
        chapterModel.bookID = chapterListModel.bookID;
        chapterModel.id = chapterListModel.id;
        chapterModel.name = chapterListModel.name;
        chapterModel.indexInChapterList = indexInChapterList;
        chapterModel.previousChapterID = previousChapterID;
        chapterModel.nextChapterID = nextChapterID;
        chapterModel.content = [NSString stringWithFormat:@"%@%@",kYLReadParagraphSpace,[readModel.fullText substringWithRange:range].removeSEHeadAndTail];
        if (isUpdateFont) {
            [chapterModel updateFont];
        }else{
            [chapterModel save];
        }
        return chapterModel;
    }
    return nil;
}

/**  解析整本小说
 * @param bookID 小说ID
 * @param contentString 小说内容
 * @return 章节列表
 */
+ (NSMutableArray<YLReadChapterListModel *> *)parserWithBookID:(NSString *)bookID content:(NSString *)contentString{
    NSMutableArray<YLReadChapterListModel *> *chapterListModels = [NSMutableArray array];// 章节列表
    // 文字排版
    NSString *content = [NSString contentTypesettingWithContent:contentString];
    
    // 正则匹配
    NSString *parten = @"第[0-9一二两三四五六七八九十零百千]*[章回].*";
    // "[\n\r\t\\s]第[0-9一二两三四五六七八九十零百千]*[章回].*"
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:parten options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *results = [regularExpression matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length)];
    NSInteger count = results.count;// 章节数量
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
            curentChapter.bookID = bookID;
            curentChapter.id = i + isHavePreface;
            curentChapter.indexInChapterList = i - !isHavePreface;
            
            if (i == 0) { // 前言
                curentChapter.name = @"前言";
                curentChapter.content = [content substringWithRange:NSMakeRange(0, location)];
                // 记录
                lastRange = range;
                // 没有内容则不需要添加列表
                if (!isHavePreface) {
                    continue;
                }
            }else if (i == count) { // 结尾:最后一章
                curentChapter.name = [content substringWithRange:lastRange];
                // 内容(不包含章节名)
                curentChapter.content = [content substringWithRange:NSMakeRange(lastRange.location + lastRange.length, content.length - lastRange.location - lastRange.length)];
            }else { // 中间章节
                curentChapter.name = [content substringWithRange:lastRange];
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
        YLReadChapterModel *chapterModel = [[YLReadChapterModel alloc] init];
        chapterModel.bookID = bookID;
        chapterModel.content = [NSString stringWithFormat:@"%@%@",kYLReadParagraphSpace,content.removeSEHeadAndTail];
        [chapterModel save];
        [chapterListModels addObject:chapterModel.toListModel];
    }
    return chapterListModels;
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
            pageModel.contentSize = getSizeWithAttributedString(content, getReadViewRect().size.width);
            // 当前页面开头是什么数据开头
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
            [pageModels addObject:pageModel];
        }];
    }
    return pageModels;
}

@end
