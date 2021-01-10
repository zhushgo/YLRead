//
//  NSString+TypeseHelper.m
//  TextTypesetting
//
//  Created by 苏沫离 on 2017/7/22.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import "NSString+TypeseHelper.h"

@implementation NSString (TypeseHelper)

+ (void)startTypeseter{
    NSString *path = [NSBundle.mainBundle pathForResource:@"DemoText" ofType:@"html"];
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [string typesettingString_1];
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
    return [content replacingCharactersWithPattern:@"\\s*\\n+\\s*" template:[NSString stringWithFormat:@"\n   "]];
}


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

// @"第[0-9一二两三四五六七八九十零百千]*[章回].*"

- (NSString *)typesettingString{
    NSString *string = [NSString contentTypesettingWithContent:self];
    NSLog(@"string === %@",string);
//@"(ps)[\\s\\S]*?第"
//    string = [string replacingCharactersWithPattern:@"ps.第[0-9一二两三四五六七八九十零百千]*[章更].*" template:@"\n第"];
//    string = [string replacingCharactersWithPattern:@"(―{1,100}分割线)[\\s\\S]*?第" template:@"\n第"];
//    string = [string replacingCharactersWithPattern:@"(ps)[\\s\\S]*?第" template:@"\n第"];
    
//    例:包含admin且不包含abc : ^((?!abc).)*admin((?!abc).)*$
//    例:包含'abcd'且不包含'中zabcd' : ^((?!中zabcd).)*abcd((?!中zabcd).)*$

    //"[^\u4e00-\u9fa5]第[0-9一二两三四五六七八九十零百千]*[章回].*"
    // ^((?!abc).)*admin((?!abc).)*$
    // "[\n\r\t\\s]第[0-9一二两三四五六七八九十零百千]*[章回].*"
    NSError *error;
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"[\u4e00-\u9fa5].(\.).[\u4e00-\u9fa5]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray<NSTextCheckingResult *> *matches = [regularExpression matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    __block NSRange lastRange = NSMakeRange(0, 0);
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [string substringWithRange:obj.range];
        NSString *content = [string substringWithRange:NSMakeRange(lastRange.location + lastRange.length, obj.range.location - lastRange.location - lastRange.length)];
        NSLog(@"name : %@ ,range : %@,content : %@",name,[NSValue valueWithRange:obj.range],content);
        lastRange = obj.range;
    }];
    
//    string = [string replacingCharactersWithPattern:@"http://www.shuquge.com/txt/1959/[0-9]{7,9}.html" template:@""];

    // 替换换行 以及 多个换行 为 换行加空格
    string = [string replacingCharactersWithPattern:@"\\s*\\n+\\s*" template:@"\n"];
    return string;
}

- (NSString *)typesettingString_1{
    NSString *string = [NSString contentTypesettingWithContent:self];

    NSString *regula = @"(?<=\\</div>\n</div>\n</div>).*?(?=\\</div>)";//根据正则表达式，取出指定文本
    regula = @"(?<=</div>\\s{0,20}\n\\s{0,20}</div>\\s{0,20}\n\\s{0,20}</div>)[\\s\\S]*?</div>";
    regula = @"(?<=\\<div class)[\\s\\S]*?(?=\\<script)";
//    regula = @"(?<=\\</div>).*?(?=\\</div>)";
    regula = @"(?<=\\</div>)((?!div).)*?(?=\\<script)";
//    regula = @"(?<=\\<ul class)((?!div).)*?(?=\\</ul>)";
//    regula = @"(?<=\\<ul class)[\\s\\S]*?(?=\\</ul>)";
//    regula = @"(?<=\\</div>)((?!div).)*?(?=\\<script)";
    regula = @"(?<=\\。</div>)[\\s\\S]*?(?=\\<script)";

    NSError *error;
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regula options:NSRegularExpressionCaseInsensitive error:&error];
    NSMutableString *sectionContent = [[NSMutableString alloc] init];
    if (error) {
        NSLog(@"error ---------- %@",error);
    }else{
        NSArray<NSTextCheckingResult *> *matches = [regularExpression matchesInString:string options:0 range:NSMakeRange(0, [string length])];
        NSLog(@"matches ---------- %ld",matches.count);
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *matchString = [string substringWithRange:obj.range];
            NSLog(@"matchString ---------- %@",matchString);
            [sectionContent appendString:matchString];
        }];
    }
    return sectionContent;
}


+ (NSString *)getSectionContent{
    NSMutableString *sectionContent = [[NSMutableString alloc] init];
    NSString *sectionHTMLString;
    NSString *sectionLink = @"https://m.lingdiankanshu.co/60231/";
    NSString *ling = @"https://m.lingdiankanshu.co/60231/";
    int page = 1;
    do {
        ling = [NSString stringWithFormat:@"%@%d/",sectionLink,page];
        NSLog(@"ling ===== %@",ling);
        sectionHTMLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:ling] encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"ling ===== %@",ling);

        [sectionContent appendString:sectionHTMLString.typesettingString_1];
        page++;
        
        if ([ling containsString:@"60231/3558179_2"]) {
            break;
        }
    } while ([sectionHTMLString containsString:@"下一页"]);
    NSLog(@"sectionContent === %@",sectionContent);
    return sectionContent;
}

@end
