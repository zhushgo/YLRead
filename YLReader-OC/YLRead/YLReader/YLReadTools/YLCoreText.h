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

/** 获取 CTFrame
 * @param attrString 绘制内容
 * @param rect 绘制区域
*/
CTFrameRef getCTFrameWithAttrString(NSAttributedString *attrString, CGRect rect);

/// 通过 [CGRect] 获得合适的 MenuRect
///
/// - Parameter rects: [CGRect]
/// - Parameter viewFrame: 目标ViewFrame
/// - Returns: MenuRect
CGRect getMenuRect(NSArray<NSValue *> *rects,CGRect viewFrame);

/// 通过 range 返回字符串所覆盖的位置 [CGRect]
///
/// - Parameter range: NSRange
/// - Parameter frameRef: CTFrame
/// - Parameter content: 内容字符串(有值则可以去除选中每一行区域内的 开头空格 - 尾部换行符 - 所占用的区域,不传默认返回每一行实际占用区域)
/// - Returns: 覆盖位置
NSMutableArray<NSValue *> *getRangeRects_0(NSRange range,CTFrameRef frameRef);
NSMutableArray<NSValue *> *getRangeRects(NSRange range,CTFrameRef frameRef,NSString *content);

@end





///分页
@interface YLCoreText (Page)

/** 根据页面 rect 将文本分页
 * @param attrString 内容
 * @param rect 显示范围
 * @return 返回每页需要展示的 Range
 */
NSMutableArray<NSValue *> *getPageRanges(NSAttributedString *attrString, CGRect rect);

@end





/// 计算高度
@interface YLCoreText (ContentHeight)

/** 获取指定 CTFrame 内容高度
 */
CGFloat getHeightWithCTFrame(CTFrameRef frameRef);

/** 获取指定内容大小
 * @param attrString 内容
 * @param widthLimit 宽度限制
 */
CGSize getSizeWithAttributedString(NSAttributedString *attrString,CGFloat widthLimit);

/** 获取指定 CTLine Size
 */
CGSize getSizeWithCTLine(CTLineRef lineRef);

@end




/// CTFrame 上触摸事件的处理
@interface YLCoreText (Touch)

/** 获取触摸位置所在的行 CTLine
 * @param point 触摸点
 */
CTLineRef getTouchLine(CGPoint point,CTFrameRef frameRef);

/** 获取触摸点的 CTRunRef
 * @param point 触摸点
 */
CTRunRef getTouchRun(CGPoint point,CTFrameRef frameRef);

/** 获得触摸位置那一行文字范围 Range
 * @param point 触摸点
 */
NSRange getTouchLineRange(CGPoint point,CTFrameRef frameRef);

/** 获得触摸位置文字的Location
 * @param point 触摸点
 */
signed long getTouchLocation(CGPoint point,CTFrameRef frameRef);

@end


NS_ASSUME_NONNULL_END
