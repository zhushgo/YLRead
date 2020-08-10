//
//  LingDianParser.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/12.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//https://route.51mypc.cn/novels/search/牧神记
//https://route.51mypc.cn/novels/download/185607
//https://m.lingdiankanshu.co/445252/all.html

/** 零点看书小说网：提取小说文本内容
 * 牧神记：187917
 * 北颂  ：410820
 * 万族之劫 ： 445252
 * 全球高武 ： 343014
 * 赘婿：4626
 * 大泼猴：5910
 * 人道至尊：3416
 * 明朝败家子：333717 
 * 马前卒：107884
 * 纵兵夺鼎：147913
 * 我是秦二世：22829
 * 完美世界：774
 * 官居一品：343736
 * 蓝白社：340799
 * 手术直播间：361130
 * 大将：106074
 * 将血：1237
 * 锦衣当国：51560
 * 甲壳狂潮 ： 130348
 *
 */
@interface LingDianParser : NSObject

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

+ (void)textRegula;

@end

NS_ASSUME_NONNULL_END
