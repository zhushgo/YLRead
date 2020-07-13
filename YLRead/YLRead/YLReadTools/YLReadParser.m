//
//  YLReadParser.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/7.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadParser.h"
#import "YLReadPageModel.h"
#import "YLGlobalTools.h"
#import "YLCoreText.h"
#import "YLReadConfigure.h"
#import "NSString+Extend.h"


@implementation YLReadParser

// MARK: -- 内容分页

/// 内容分页
///
/// - Parameters:
///   - attrString: 内容
///   - rect: 显示范围
///   - isFirstChapter: 是否为本文章第一个展示章节,如果是则加入书籍首页。(小技巧:如果不需要书籍首页,可不用传,默认就是不带书籍首页)
/// - Returns: 内容分页列表

+ (NSMutableArray<YLReadPageModel *> *)pageingWithAttrString:(NSAttributedString *)attrString rect:(CGRect)rect{
    return [self pageingWithAttrString:attrString rect:rect isFirstChapter:NO];
}

+ (NSMutableArray<YLReadPageModel *> *)pageingWithAttrString:(NSAttributedString *)attrString rect:(CGRect)rect isFirstChapter:(BOOL)isFirstChapter{
    
    NSMutableArray<YLReadPageModel *> *pageModels = [NSMutableArray array];
    
    if (isFirstChapter) { // 第一页为书籍页面
        YLReadPageModel *pageModel = [[YLReadPageModel alloc]init];
        pageModel.range = NSMakeRange(-1, 1);
        pageModel.contentSize = getReadViewRect().size;
        [pageModels addObject:pageModel];
    }
    
    NSMutableArray<NSValue *> *ranges = getPageingRanges(attrString, rect);
    if (ranges && ranges.count) {
        [ranges enumerateObjectsUsingBlock:^(NSValue * _Nonnull rangeValue, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = rangeValue.rangeValue;
            NSAttributedString *content = [attrString attributedSubstringFromRange:range];

            YLReadPageModel *pageModel = [[YLReadPageModel alloc]init];
            pageModel.range = range;
            pageModel.content = content;
            pageModel.page = idx;
            
            
            // --- (滚动模式 || 长按菜单) 使用 ---
            
            // 注意: 为什么这些数据会放到这里赋值，而不是封装起来， 原因是 contentSize 计算封装在 pageModel内部计算出现宽高为0的情况，所以放出来到这里计算，原因还未找到，但是放到这里计算就没有问题。封装起来则会出现宽高度不计算的情况。
            
            // 内容Size (滚动模式 || 长按菜单)
            CGFloat maxW = getReadViewRect().size.width;
            pageModel.contentSize = CGSizeMake(maxW, getAttrStringHeight(attrString, maxW));
            
            
            // 当前页面开头是什么数据开头 (滚动模式)
            if (idx == 0) {
                pageModel.headType = YLPageHeadTypeChapterName;
                pageModel.headTypeHeight = 0;
            }else if ([content.string hasPrefix:@"　　"]) {
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

// MARK: -- 内容整理排版

/// 内容排版整理
///
/// - Parameter content: 内容
/// - Returns: 整理好的内容
+ (NSString *)contentTypesettingWithContent:(NSString *)content{
    // 替换单换行
    content = [content stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"&nbsp" withString:@" "];
    content = [content stringByReplacingOccurrencesOfString:@"&amp" withString:@"&"];
    content = [content stringByReplacingOccurrencesOfString:@"&lt" withString:@"<"];
    content = [content stringByReplacingOccurrencesOfString:@"&gt" withString:@">"];
    content = [content stringByReplacingOccurrencesOfString:@"&quot" withString:@"\""];
    content = [content stringByReplacingOccurrencesOfString:@"&qpos" withString:@"'"];
    
    // 替换换行 以及 多个换行 为 换行加空格
    [content replacingCharactersWithPattern:@"\\s*\\n+\\s*" template:@"\n　　"];
    
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@"    "];
    // 返回
    return content;
}

// MARK: -- 解码URL

/// 解码URL
///
/// - Parameter url: 文件路径
/// - Returns: 内容
+ (NSString *)encodeWithURL:(NSURL *)url{
    NSString *content = @"";
    if (url.absoluteString.length < 1) {
        return content;
    }
    // utf8
    content = [self encodeWithURL:url encoding:NSUTF8StringEncoding];
    // 进制编码
    if (content.length < 1) {
        content = [self encodeWithURL:url encoding:0x80000632];
    }
    if (content.length < 1) {
        content = [self encodeWithURL:url encoding:0x80000631];
    }
    if (content.length < 1) {
        content = @"";
    }
    return content;
}

/// 解析URL
///
/// - Parameters:
///   - url: 文件路径
///   - encoding: 进制编码
/// - Returns: 内容
+ (NSString *)encodeWithURL:(NSURL *)url encoding:(NSStringEncoding)encoding {
    return [NSString stringWithContentsOfURL:url encoding:encoding error:nil];
}

@end

