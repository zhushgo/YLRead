//
//  YLCoreText.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/1.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import<CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface YLCoreText : NSObject

/// 获得 CTFrameRef
///
/// - Parameters:
///   - attrString: 内容
///   - rect: 显示范围
/// - Returns: CTFrameRef

CTFrameRef getFrameRefByAttrString(NSAttributedString *attrString, CGRect rect);

/// 获得内容分页列表
///
/// - Parameters:
///   - attrString: 内容
///   - rect: 显示范围
/// - Returns: 内容分页列表
NSMutableArray<NSValue *> *getPageingRanges(NSAttributedString *attrString, CGRect rect);

/// 获取指定内容高度
///
/// - Parameters:
///   - attrString: 内容
///   - maxW: 最大宽度
/// - Returns: 当前高度

CGFloat getAttrStringHeight(NSAttributedString *attrString,CGFloat maxW);


/// 通过 [CGRect] 获得合适的 MenuRect
///
/// - Parameter rects: [CGRect]
/// - Parameter viewFrame: 目标ViewFrame
/// - Returns: MenuRect
CGRect getMenuRect(NSArray<NSValue *> *rects,CGRect viewFrame);

/// 获得触摸位置在哪一行
///
/// - Parameters:
///   - point: 触摸位置
///   - frameRef: CTFrame
/// - Returns: CTLine
CTLineRef getTouchLine(CGPoint point,CTFrameRef frameRef);

/// 获得触摸位置那一行文字的Range
///
/// - Parameters:
///   - point: 触摸位置
///   - frameRef: CTFrame
/// - Returns: CTLine
NSRange getTouchLineRange(CGPoint point,CTFrameRef frameRef);

/// 获得触摸位置文字的Location
///
/// - Parameters:
///   - point: 触摸位置
///   - frameRef: CTFrame
/// - Returns: 触摸位置的Index
signed long getTouchLocation(CGPoint point,CTFrameRef frameRef);

/// 通过 range 返回字符串所覆盖的位置 [CGRect]
///
/// - Parameter range: NSRange
/// - Parameter frameRef: CTFrame
/// - Parameter content: 内容字符串(有值则可以去除选中每一行区域内的 开头空格 - 尾部换行符 - 所占用的区域,不传默认返回每一行实际占用区域)
/// - Returns: 覆盖位置
NSMutableArray<NSValue *> *getRangeRects_0(NSRange range,CTFrameRef frameRef);
NSMutableArray<NSValue *> *getRangeRects(NSRange range,CTFrameRef frameRef,NSString *content);

@end

NS_ASSUME_NONNULL_END
