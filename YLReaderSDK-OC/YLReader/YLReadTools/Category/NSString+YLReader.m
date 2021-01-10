//
//  NSString+YLReader.m
//  YLRead
//
//  Created by 苏沫离 on 2017/5/7.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import "NSString+YLReader.h"

/// 段落头部双圆角空格
NSString *const kYLReadParagraphSpace = @"　　";

@implementation NSString (YLReader)

/// 正则替换字符
- (NSString *)replacingCharactersWithPattern:(NSString *)pattern template:(NSString *)template{
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    return [regularExpression stringByReplacingMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length) withTemplate:template];
}


/// 去除首尾空格和换行
- (NSString *)removeSEHeadAndTail{
    return [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

/// 去除所有换行
- (NSString *)removeEnterAll{
    return [[[self stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];;
}

/// 正则搜索相关字符位置
- (NSArray<NSTextCheckingResult *> *)matchesWithPattern:(NSString *)pattern{
    if (self.length < 1) {return @[];}
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    return [regularExpression matchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length)];
}

/** 内容排版整理
 * 1、去除换行符：单换行、多换行
 * 2、去除每行开头的空格：使用 \t 递进
 */
+ (NSString *)contentTypesettingWithContent:(NSString *)content{
    // 替换单换行
    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    // 替换换行 以及 多个换行 为 换行加空格
    // \s* 任意个空格   \n+ 任意个换行符
    return [content replacingCharactersWithPattern:@"\\s*\\n+\\s*" template:[NSString stringWithFormat:@"\n%@",kYLReadParagraphSpace]];
}

/// 根据 URL 解析文件 ， 默认 UTF8 编码
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


/** 根据 URL 解析文件
 * @param url 文件路径
 * @param encoding 进制编码
 * @return 内容
 */
+ (NSString *)encodeWithURL:(NSURL *)url encoding:(NSStringEncoding)encoding {
    return [NSString stringWithContentsOfURL:url encoding:encoding error:nil];
}


@end
