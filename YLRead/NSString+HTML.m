//
//  NSString+HTML.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/11.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "NSString+HTML.h"
#import <UIKit/UIKit.h>

@implementation NSString (HTML)

+ (void)getBeisong{
    NSString *htmlString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://m.lingdiankanshu.co/410820/all.html"] encoding:NSUTF8StringEncoding error:nil];
    NSString *path = [NSString stringWithFormat:@"%@/Documents/beiSong_Catalogue",NSHomeDirectory()];
    NSMutableArray<NSMutableDictionary *> *beiSong_Catalogue = [htmlString beiSong_Catalogue];
    [beiSong_Catalogue writeToFile:path atomically:YES];
    NSLog(@"path ====== %@",path);
    [beiSong_Catalogue enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull dictionary, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *sectionLink = [NSString stringWithFormat:@"https://m.lingdiankanshu.co/410820/%@",dictionary[@"sectionLink"]];
        dictionary[@"sectionContent"] = [NSString beiSong_sectionLink:sectionLink];
        [beiSong_Catalogue writeToFile:path atomically:YES];
    }];
    
    NSLog(@"beiSong_Catalogue ========= %@",beiSong_Catalogue);
}

+ (void)writeBeisong{
    NSMutableString *allString = [[NSMutableString alloc] init];
    
    NSString *path = [NSBundle.mainBundle pathForResource:@"beiSong" ofType:@""];
    NSMutableArray<NSMutableDictionary *> *beiSong_Catalogue = [NSMutableArray arrayWithContentsOfFile:path];
    [beiSong_Catalogue enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *content = [NSString stringWithFormat:@"\n %@ \n\n %@",dict[@"sectionName"],dict[@"sectionContent"]];
        [allString appendString:content];
    }];
    
    NSString *filepath = [NSString stringWithFormat:@"%@/Documents/beiSong_allString",NSHomeDirectory()];
    [allString writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"filepath ===== %@",filepath);
}


/** <p><a style="" href="2152124.html">第0167章 平叛</a></p>
 * regula = @"(?<=\\<p> <a style=\"\" href=\").*?(?=\\</a></p>)";
 * @{@"sectionName":sectionName,@"sectionLink":sectionLink}
 */
- (NSMutableArray<NSMutableDictionary *> *)beiSong_Catalogue{
    NSString *string = [self copy];

    NSMutableArray<NSDictionary *> *catalogueArray = [NSMutableArray array];
    
    NSString *regula = @"(?<=\\<p> <a style=\"\" href=\").*?(?=\\</a></p>)";
    NSError *error;
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regula options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray<NSTextCheckingResult *> *matches = [regularExpression matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    if (error) {
        NSLog(@"error === %@",error);
    }else{
        NSLog(@"count === %ld",matches.count);
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *matchString = [string substringWithRange:obj.range];
            if ([matchString containsString:@"第"] &&
                [matchString containsString:@"章"]) {
                NSArray<NSString *> *array = [matchString componentsSeparatedByString:@"\">"];
                NSString *sectionName = array.lastObject;
                NSString *sectionLink = array.firstObject;
                [catalogueArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"sectionName":sectionName,@"sectionLink":sectionLink,@"sectionContent":@""}]];
            }
        }];
    }
    return catalogueArray;
}


+ (NSString *)beiSong_sectionLink:(NSString *)sectionLink{
    NSMutableString *sectionContent = [[NSMutableString alloc] init];

    NSString *regula = @"(?<=\\</div>\n</div>\n</div>).*?(?=\\</div>)";

    NSString *sectionHTMLString;
    NSString *ling = [sectionLink copy];;
    int page = 1;
    do {
        ling = [NSString stringWithFormat:@"%@_%d.html",[sectionLink componentsSeparatedByString:@".html"].firstObject,page];
        NSLog(@"ling ===== %@",ling);
        sectionHTMLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:ling] encoding:NSUTF8StringEncoding error:nil];
        NSError *error;
        NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regula options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray<NSTextCheckingResult *> *matches = [regularExpression matchesInString:sectionHTMLString options:0 range:NSMakeRange(0, [sectionHTMLString length])];
        if (error) {
            NSLog(@"error === %@",error);
        }else if(matches.count) {
            [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *matchString = [sectionHTMLString substringWithRange:obj.range];
                [sectionContent appendString:matchString];
            }];
        }else{
            NSLog(@"sectionHTMLString === %@",sectionHTMLString);
        }
        page++;
    } while ([sectionHTMLString containsString:@"下一页"]);
    NSString *result = [sectionContent stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    NSLog(@"sectionContent === %@",result);
    return result;
}

@end









@implementation NSString (MUSehnJi)

+ (void)getMUSehnJi{
    NSString *htmlString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://m.lingdiankanshu.co/187917/all.html"] encoding:NSUTF8StringEncoding error:nil];
    NSString *path = [NSString stringWithFormat:@"%@/Documents/MUSehnJi_Catalogue",NSHomeDirectory()];
    NSMutableArray<NSMutableDictionary *> *beiSong_Catalogue = [htmlString beiSong_Catalogue];
    [beiSong_Catalogue writeToFile:path atomically:YES];
    NSLog(@"path ====== %@",path);
    [beiSong_Catalogue enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull dictionary, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *sectionLink = [NSString stringWithFormat:@"https://m.lingdiankanshu.co/187917/%@",dictionary[@"sectionLink"]];
        dictionary[@"sectionContent"] = [NSString beiSong_sectionLink:sectionLink];
        [beiSong_Catalogue writeToFile:path atomically:YES];
    }];
    
    NSLog(@"MUSehnJi_Catalogue ========= %@",beiSong_Catalogue);
}

+ (void)writeMUSehnJi{
    NSMutableString *allString = [[NSMutableString alloc] init];
    
    NSString *path = [NSBundle.mainBundle pathForResource:@"beiSong" ofType:@""];
    NSMutableArray<NSMutableDictionary *> *beiSong_Catalogue = [NSMutableArray arrayWithContentsOfFile:path];
    [beiSong_Catalogue enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *content = [NSString stringWithFormat:@"\n %@ \n\n %@",dict[@"sectionName"],dict[@"sectionContent"]];
        [allString appendString:content];
    }];
    
    NSString *filepath = [NSString stringWithFormat:@"%@/Documents/MUSehnJi_allString",NSHomeDirectory()];
    [allString writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"filepath ===== %@",filepath);
}

/** <p><a style="" href="2152124.html">第0167章 平叛</a></p>
 * regula = @"(?<=\\<p> <a style=\"\" href=\").*?(?=\\</a></p>)";
 * @{@"sectionName":sectionName,@"sectionLink":sectionLink,@"sectionContent":@""
*/
- (NSMutableArray<NSMutableDictionary *> *)MUSehnJi_Catalogue{
    NSString *string = [self copy];

    NSMutableArray<NSDictionary *> *catalogueArray = [NSMutableArray array];
    
    NSString *regula = @"(?<=\\<p> <a style=\"\" href=\").*?(?=\\</a></p>)";
    NSError *error;
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regula options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray<NSTextCheckingResult *> *matches = [regularExpression matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    if (error) {
        NSLog(@"error === %@",error);
    }else{
        NSLog(@"count === %ld",matches.count);
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *matchString = [string substringWithRange:obj.range];
            if ([matchString containsString:@"第"] &&
                [matchString containsString:@"章"]) {
                NSArray<NSString *> *array = [matchString componentsSeparatedByString:@"\">"];
                NSString *sectionName = array.lastObject;
                NSString *sectionLink = array.firstObject;
                [catalogueArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"sectionName":sectionName,@"sectionLink":sectionLink,@"sectionContent":@""}]];
            }
        }];
    }
    return catalogueArray;
}


+ (NSString *)MUSehnJi_sectionLink:(NSString *)sectionLink{
    NSMutableString *sectionContent = [[NSMutableString alloc] init];

    NSString *regula = @"(?<=\\</div>\n</div>\n</div>).*?(?=\\</div>)";

    NSString *sectionHTMLString;
    NSString *ling = [sectionLink copy];;
    int page = 1;
    do {
        ling = [NSString stringWithFormat:@"%@_%d.html",[sectionLink componentsSeparatedByString:@".html"].firstObject,page];
        NSLog(@"ling ===== %@",ling);
        sectionHTMLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:ling] encoding:NSUTF8StringEncoding error:nil];
        NSError *error;
        NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regula options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray<NSTextCheckingResult *> *matches = [regularExpression matchesInString:sectionHTMLString options:0 range:NSMakeRange(0, [sectionHTMLString length])];
        if (error) {
            NSLog(@"error === %@",error);
        }else if(matches.count) {
            [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *matchString = [sectionHTMLString substringWithRange:obj.range];
                [sectionContent appendString:matchString];
            }];
        }else{
            NSLog(@"sectionHTMLString === %@",sectionHTMLString);
        }
        page++;
    } while ([sectionHTMLString containsString:@"下一页"]);
    NSString *result = [sectionContent stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    NSLog(@"sectionContent === %@",result);
    return result;
}


@end
