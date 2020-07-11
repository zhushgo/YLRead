//
//  NSString+HTML.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/11.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (HTML)

+ (void)getBeisong;

+ (void)writeBeisong;

/** <p><a style="" href="2152124.html">第0167章 平叛</a></p>
 * regula = @"(?<=\\<p> <a style=\"\" href=\").*?(?=\\</a></p>)";
 * @{@"sectionName":sectionName,@"sectionLink":sectionLink,@"sectionContent":@""
*/
- (NSMutableArray<NSMutableDictionary *> *)beiSong_Catalogue;

+ (NSString *)beiSong_sectionLink:(NSString *)sectionLink;


@end

NS_ASSUME_NONNULL_END

