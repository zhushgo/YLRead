//
//  NSString+Extend.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/7.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "NSString+Extend.h"

@implementation NSString (Extend)

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

@end
