//
//  NSString+Extend.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/7.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 段落头部双圆角空格
FOUNDATION_EXPORT NSString *const kYLReadParagraphSpace;

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extend)
- (NSString *)replacingCharactersWithPattern:(NSString *)pattern template:(NSString *)template;

/// 去除首尾空格和换行
- (NSString *)removeSEHeadAndTail;

/// 去除所有换行
- (NSString *)removeEnterAll;

/// 正则搜索相关字符位置
- (NSArray<NSTextCheckingResult *> *)matchesWithPattern:(NSString *)pattern;

@end

NS_ASSUME_NONNULL_END
