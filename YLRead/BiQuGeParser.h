//
//  BiQuGeParser.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/21.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BiQuGeParser : NSObject
/** 获取小说的纯文本
 *
 * &nbsp;&nbsp;&nbsp;&nbsp;
 */
+ (NSMutableString *)getBookAllStringByBookID:(NSString *)bookID;

/** 获取小说的章节与内容
 */
+ (NSMutableArray<NSMutableDictionary *> *)getCatalogueByBookID:(NSString *)bookID;

/** 获取章节内容：根据章节链接
 * @param sectionLink 章节链接
 * @return 章节内容（纯文本）
 */
+ (NSString *)getSectionContentByLink:(NSString *)sectionLink;


@end

NS_ASSUME_NONNULL_END
