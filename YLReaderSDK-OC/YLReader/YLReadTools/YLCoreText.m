//
//  YLCoreText.m
//  YLRead
//
//  Created by 苏沫离 on 2017/5/1.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import "YLCoreText.h"
#import "NSString+YLReader.h"

@implementation YLCoreText


/** 获取 CTFrame
 * @param attrString 绘制内容
 * @param rect 绘制区域
*/
CTFrameRef getCTFrameWithAttrString(NSAttributedString *attrString, CGRect rect){
    ///绘制局域
    CGPathRef path = CGPathCreateWithRect(rect, nil);
    //设置绘制内容
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil);
    CFRelease(framesetter);
    CGPathRelease(path);
    return frameRef;
}

/// 通过 [CGRect] 获得合适的 MenuRect
///
/// - Parameter rects: [CGRect]
/// - Parameter viewFrame: 目标ViewFrame
/// - Returns: MenuRect
CGRect getMenuRect(NSArray<NSValue *> *rects,CGRect viewFrame){
    CGRect menuRect = CGRectZero;
    if (rects.count < 1) {
        return menuRect;
    }
    menuRect = rects.firstObject.CGRectValue;

    if (rects.count > 1) {
        NSInteger count = rects.count;
        
        for (int i = 0; i < count; i++) {
            CGRect rect = rects[i].CGRectValue;
            
            CGFloat minX = MIN(menuRect.origin.x, rect.origin.x);
            CGFloat maxX = MAX(menuRect.origin.x + menuRect.size.width, rect.origin.x + rect.size.width);
            CGFloat minY = MIN(menuRect.origin.y, rect.origin.y);
            CGFloat maxY = MAX(menuRect.origin.y + menuRect.size.height, rect.origin.y + rect.size.height);
            
            menuRect.origin.x = minX;
            menuRect.origin.y = minY;
            menuRect.size.width = maxX - minX;
            menuRect.size.height = maxY - minY;
        }
    }
    menuRect.origin.y = viewFrame.size.height - menuRect.origin.y - menuRect.size.height;
    return menuRect;
}

/// 通过 range 返回字符串所覆盖的位置 [CGRect]
///
/// - Parameter range: NSRange
/// - Parameter frameRef: CTFrame
/// - Parameter content: 内容字符串(有值则可以去除选中每一行区域内的 开头空格 - 尾部换行符 - 所占用的区域,不传默认返回每一行实际占用区域)
/// - Returns: 覆盖位置
NSMutableArray<NSValue *> *getRangeRects_0(NSRange range,CTFrameRef frameRef){
    return getRangeRects(range, frameRef,nil);
}

NSMutableArray<NSValue *> *getRangeRects(NSRange range,CTFrameRef frameRef,NSString *content){
    NSMutableArray<NSValue *> *rects = [NSMutableArray array];
    if (frameRef == nil) { return rects; }
    if (range.length == 0 || range.location == NSNotFound) { return rects; }
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    int lineCount = (int)CFArrayGetCount(lines);
    
    if (lineCount < 1) {

        return rects;
    }
    
    CGPoint origins[lineCount];
    for (int i = 0; i < lineCount; i++) {
        origins[i] = CGPointZero;
    }
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    
    for (int i = 0; i < lineCount; i ++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange lineCFRange = CTLineGetStringRange(line);
        NSRange lineRange = NSMakeRange(lineCFRange.location == kCFNotFound ? NSNotFound : lineCFRange.location, lineCFRange.length);
        NSRange contentRange = NSMakeRange(NSNotFound, 0);
        
        if ((lineRange.location + lineRange.length) > range.location &&
            lineRange.location < (range.location + range.length)) {
            contentRange.location = MAX(lineRange.location, range.location);
            CGFloat end = MIN(lineRange.location + lineRange.length, range.location + range.length);
            contentRange.length = end - contentRange.location;
        }
        
        if (contentRange.length > 0) {
            
            // 去掉 -> 开头空格 - 尾部换行符 - 所占用的区域
            if (content.length > 0) {
                NSString *tempContent = [content substringWithRange:contentRange];
                NSArray<NSTextCheckingResult *> *spaceRanges = [tempContent matchesWithPattern:@"\\s\\s"];
                if (spaceRanges.count) {
                    NSRange spaceRange = spaceRanges.firstObject.range;
                    contentRange = NSMakeRange(contentRange.location + spaceRange.length, contentRange.length - spaceRange.length);
                }
                NSArray<NSTextCheckingResult *> *enterRanges = [tempContent matchesWithPattern:@"\\n"];
                if (enterRanges.count) {
                    NSRange enterRange = enterRanges.firstObject.range;
                    contentRange = NSMakeRange(contentRange.location, contentRange.length - enterRange.length);
                }
            }
            
            // 正常使用(如果不需要排除段头空格跟段尾换行符可将上面代码删除)
            
            CGFloat xStart = CTLineGetOffsetForStringIndex(line, contentRange.location, nil);
            CGFloat xEnd = CTLineGetOffsetForStringIndex(line, contentRange.location + contentRange.length, nil);
            CGPoint origin = origins[i];
            CGFloat lineAscent = 0;
            CGFloat lineDescent = 0;
            CGFloat lineLeading = 0;
            CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
            
            CGRect contentRect = CGRectMake(origin.x + xStart, origin.y - lineDescent, fabs(xEnd - xStart),lineAscent + lineDescent + lineLeading);
            [rects addObject:[NSValue valueWithCGRect:contentRect]];
        }
    }
    return rects;
}

@end




@implementation YLCoreText (Page)

/** 根据页面 rect 将文本分页
 * @param attrString 内容
 * @param rect 显示范围
 * @return 返回每页需要展示的 Range
 */
NSMutableArray<NSValue *> *getPageRanges(NSAttributedString *attrString, CGRect rect){
    NSMutableArray *rangeArray = [NSMutableArray array];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    CGPathRef path = CGPathCreateWithRect(rect, nil);
    CFRange range = CFRangeMake(0, 0);
    NSInteger rangeOffset = 0;
    do {
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(rangeOffset, 0), path, nil);
        range = CTFrameGetVisibleStringRange(frame);
        [rangeArray addObject:[NSValue valueWithRange:NSMakeRange(rangeOffset, range.length)]];
        CFRelease(frame);
        rangeOffset += range.length;
    } while (range.location + range.length < attrString.length);
    CFRelease(framesetter);
    CGPathRelease(path);
    return rangeArray;
}
@end











/// 获取高度
@implementation YLCoreText (ContentHeight)

/** 获取 CTFrameRef 的内容高度
 * @note CTFrameRef 的坐标系是以左下角为原点
 */
CGFloat getHeightWithCTFrame(CTFrameRef frameRef){
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    int lineCount = (int)CFArrayGetCount(lines);
    
    CGPoint origins[lineCount];//以左下角为原点的坐标系
    for (int i = 0; i < lineCount; i++) {
        origins[i] = CGPointZero;
    }
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    
    CGPoint point = origins[lineCount - 1];//最后一行的 point.y 是最小值
    CGFloat lineAscent = 0;  //上行高度
    CGFloat lineDescent = 0; //下行高度
    CGFloat lineLeading = 0; //行距
    CTLineRef line = CFArrayGetValueAtIndex(lines, lineCount - 1);
    CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
    
    /// 获取该页面的高度 pageHeight
    CGPathRef path = CTFrameGetPath(frameRef);
    CGRect bounds = CGPathGetBoundingBox(path);
    CGFloat pageHeight = CGRectGetHeight(bounds);
        
    /// 空白高度 = point.y 是最小值 - 下行高度 - 行距
    /// 内容高度 = 页面高度 - 空白高度
    return pageHeight - (point.y - ceil(lineDescent) - lineLeading);
}

/** 获取指定内容大小
 * @param attrString 内容
 * @param widthLimit 宽度限制
 */
CGSize getSizeWithAttributedString(NSAttributedString *attrString,CGFloat widthLimit){
    CGSize size = CGSizeZero;
    if (attrString.length > 0){
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
        size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(widthLimit, CGFLOAT_MAX), NULL);
        CFRelease(framesetter);/// 释放资源
    }
    return size;
}

/** 获取指定 CTLine 高度
 */
CGSize getSizeWithCTLine(CTLineRef lineRef){
    if (lineRef == nil) {
        return CGSizeZero;
    }
    CGFloat lineAscent = 0;  //上行高度
    CGFloat lineDescent = 0; //下行高度
    CGFloat lineLeading = 0; //行距
    CGFloat width = CTLineGetTypographicBounds(lineRef, &lineAscent, &lineDescent, &lineLeading);/// 获取CTLine的字形度量
    CGFloat height = lineAscent + fabs(lineDescent) + lineLeading;
    return CGSizeMake(width,height);
}

CGSize getSizeWithCTLine_1(CTLineRef lineRef){
    if (lineRef == nil) {
        return CGSizeZero;
    }
    CGRect bounds = CTLineGetBoundsWithOptions(lineRef, kCTLineBoundsExcludeTypographicLeading);
    return bounds.size;
}

@end





/// CTFrame 上触摸事件的处理：
@implementation YLCoreText (Touch)

/** 获取触摸位置所在的行 CTLine
 * @param point 触摸点
 */
CTLineRef getTouchLine(CGPoint point,CTFrameRef frameRef){
    CTLineRef line = nil;
    if (frameRef == nil) { return line; }
    
    CGPathRef path = CTFrameGetPath(frameRef);
    CGRect bounds = CGPathGetBoundingBox(path);/// 页面边界
    CGFloat pageWidth = CGRectGetWidth(bounds);/// 页面宽度
    CGFloat pageHeight = CGRectGetHeight(bounds);/// 页面高度
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    int lineCount = (int)CFArrayGetCount(lines);
    if (lineCount < 1) {
        return line;
    }
    
    CGPoint origins[lineCount];
    for (int i = 0; i < lineCount; i++) {
        origins[i] = CGPointZero;
    }
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    for (int i = 0; i < lineCount; i ++) {
        CGPoint origin = origins[i];
        CTLineRef tempLine = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent = 0;  //上行高度
        CGFloat lineDescent = 0; //下行高度
        CGFloat lineLeading = 0; //行距
        CTLineGetTypographicBounds(tempLine, &lineAscent, &lineDescent, &lineLeading);/// 获取CTLine的字形度量
        CGFloat lineHeight = lineAscent + fabs(lineDescent) + lineLeading;
        CGRect lineFrame = CGRectMake(origin.x, pageHeight - (origin.y + lineAscent), pageWidth, lineHeight);
        lineFrame = CGRectInset(lineFrame, -5, -5);
        if (CGRectContainsPoint(lineFrame, point)) {
            line = tempLine;
            break;
        }
    }
    return line;
}

/** 获取触摸点的 CTRunRef
 * @param point 触摸点
 */
CTRunRef getTouchRun(CGPoint point,CTFrameRef frameRef){
    CTRunRef getRun = NULL;
    CTLineRef lineRef = getTouchLine(point, frameRef);
    CFArrayRef glyphRuns = CTLineGetGlyphRuns(lineRef);
    int runCount = (int)CFArrayGetCount(glyphRuns);
    CGFloat startPoint = 0;
    for (int j = 0; j < runCount ; j ++) {
        CTRunRef run = CFArrayGetValueAtIndex(glyphRuns, j);
        CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), NULL, NULL, NULL);//获取 CTRun 的宽度
        if (point.x > startPoint && point.x < (startPoint + width)) {
            getRun = run;
            break;
        }
        startPoint += width;
    }
    return getRun;
}

/** 获得触摸位置那一行文字范围 Range
 * @param point 触摸点
 */
NSRange getTouchLineRange(CGPoint point,CTFrameRef frameRef){
    NSRange range = NSMakeRange(NSNotFound, 0);
    CTLineRef line = getTouchLine(point, frameRef);
    if (line) {
        CFRange lineRange = CTLineGetStringRange(line);
        range = NSMakeRange(lineRange.location == kCFNotFound ? NSNotFound : lineRange.location, lineRange.length);
    }
    return range;
}

/** 获得触摸位置文字的Location
 * @param point 触摸点
 */
signed long getTouchLocation(CGPoint point,CTFrameRef frameRef){
    signed long location = -1;
    CTLineRef line = getTouchLine(point,frameRef);
    if (line != nil) {
        location = CTLineGetStringIndexForPosition(line, point);
    }
    return location;
}

@end
