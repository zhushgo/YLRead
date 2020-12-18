//
//  NSString+YLReader.h
//  YLRead
//
//  Created by 苏沫离 on 2017/5/7.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 段落头部双圆角空格
FOUNDATION_EXPORT NSString *const kYLReadParagraphSpace;

@interface NSString (YLReader)

///正则替代
- (NSString *)replacingCharactersWithPattern:(NSString *)pattern template:(NSString *)template;

/// 去除首尾空格和换行
- (NSString *)removeSEHeadAndTail;

/// 去除所有换行
- (NSString *)removeEnterAll;

/// 正则搜索相关字符位置
- (NSArray<NSTextCheckingResult *> *)matchesWithPattern:(NSString *)pattern;

/** 内容排版整理
 * 1、去除换行符：单换行、多换行
 * 2、去除每行开头的空格：使用 \t 递进
 */
+ (NSString *)contentTypesettingWithContent:(NSString *)content;


/// 根据 URL 解析文件 ， 默认 UTF8 编码
+ (NSString *)encodeWithURL:(NSURL *)url;

/** 根据 URL 解析文件
 * @param url 文件路径
 * @param encoding 进制编码
 * @return 内容
 */
+ (NSString *)encodeWithURL:(NSURL *)url encoding:(NSStringEncoding)encoding;


@end

NS_ASSUME_NONNULL_END
