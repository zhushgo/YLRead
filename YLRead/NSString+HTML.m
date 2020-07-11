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


/** <p><a style="" href="2152124.html">第0167章 平叛</a></p>
 * regula = @"(?<=\\<p> <a style=\"\" href=\").*?(?=\\</a></p>)";
 * @{@"sectionName":sectionName,@"sectionLink":sectionLink}
 */
- (NSMutableArray<NSDictionary *> *)beiSong_Catalogue{
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
                [catalogueArray addObject:@{@"sectionName":sectionName,@"sectionLink":sectionLink}];
            }
        }];
    }
    return catalogueArray;
}


+ (NSString *)beiSong_sectionLink:(NSString *)sectionLink{
    NSMutableString *sectionContent = [[NSMutableString alloc] init];

    NSString *regula = @"(?<=\\</div>\n</div>\n</div>).*?(?=\\</div>)";

    NSString *sectionHTMLString;
    int page = 1;
    do {
        sectionLink = [NSString stringWithFormat:@"%@_%d.html",[sectionLink componentsSeparatedByString:@".html"].firstObject,page];
        NSLog(@"sectionLink ===== %@",sectionLink);
        sectionHTMLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:sectionLink] encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"sectionHTMLString ===== %@",sectionHTMLString);
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
    


    

    NSLog(@"sectionContent === %@",sectionContent);
    return sectionContent;
}

@end
