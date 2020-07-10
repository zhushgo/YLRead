//
//  YLReadParser.h
//  FM
//
//  Created by 苏沫离 on 2020/7/7.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YLReadModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 解析完成
typedef void(^ParserHanler)(YLReadModel *readModel);

@class YLReadPageModel;
@interface YLReadParser : NSObject

/// 内容分页
///
/// - Parameters:
///   - attrString: 内容
///   - rect: 显示范围
///   - isFirstChapter: 是否为本文章第一个展示章节,如果是则加入书籍首页。(小技巧:如果不需要书籍首页,可不用传,默认就是不带书籍首页)
/// - Returns: 内容分页列表

+ (NSMutableArray<YLReadPageModel *> *)pageingWithAttrString:(NSAttributedString *)attrString rect:(CGRect)rect;
+ (NSMutableArray<YLReadPageModel *> *)pageingWithAttrString:(NSAttributedString *)attrString rect:(CGRect)rect isFirstChapter:(BOOL)isFirstChapter;

/// 内容排版整理
///
/// - Parameter content: 内容
/// - Returns: 整理好的内容
+ (NSString *)contentTypesettingWithContent:(NSString *)content;

/// 解码URL
///
/// - Parameter url: 文件路径
/// - Returns: 内容
+ (NSString *)encodeWithURL:(NSURL *)url;

/// 解析URL
///
/// - Parameters:
///   - url: 文件路径
///   - encoding: 进制编码
/// - Returns: 内容
+ (NSString *)encodeWithURL:(NSURL *)url encoding:(NSStringEncoding)encoding;
@end

NS_ASSUME_NONNULL_END
