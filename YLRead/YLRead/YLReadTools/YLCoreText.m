//
//  YLCoreText.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/1.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLCoreText.h"
#import "NSString+Extend.h"



@implementation YLCoreText


/// 获得 CTFrame
///
/// - Parameters:
///   - attrString: 内容
///   - rect: 显示范围
/// - Returns: CTFrame

CTFrameRef getFrameRefByAttrString(NSAttributedString *attrString, CGRect rect){
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    CGPathRef path = CGPathCreateWithRect(rect, nil);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil);
    return frameRef;
}

/// 获得内容分页列表
///
/// - Parameters:
///   - attrString: 内容
///   - rect: 显示范围
/// - Returns: 内容分页列表
NSMutableArray<NSValue *> *getPageingRanges(NSAttributedString *attrString, CGRect rect){
    NSMutableArray *rangeArray = [NSMutableArray array];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    CGPathRef path = CGPathCreateWithRect(rect, nil);
    CFRange range = CFRangeMake(0, 0);
    NSInteger rangeOffset = 0;
    do {
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(rangeOffset, 0), path, nil);
        range = CTFrameGetVisibleStringRange(frame);
        [rangeArray addObject:[NSValue valueWithRange:NSMakeRange(rangeOffset, range.length)]];
        rangeOffset += range.length;
    } while (range.location + range.length < attrString.length);
    return rangeArray;
}


/// 获取指定内容高度
///
/// - Parameters:
///   - attrString: 内容
///   - maxW: 最大宽度
/// - Returns: 当前高度

CGFloat getAttrStringHeight(NSAttributedString *attrString,CGFloat maxW){
    CGFloat height = 0;
    if (attrString.length > 0){
        // 注意设置的高度必须大于文本高度
        CGFloat maxH = 1000;
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
        CGRect drawingRect = CGRectMake(0, 0, maxW, maxH);
        CGPathRef path = CGPathCreateWithRect(drawingRect, nil);
        CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil);

        CFArrayRef lines = CTFrameGetLines(frameRef);//as! [CTLine]
        int lineCount = (int)CFArrayGetCount(lines);
        
        CGPoint origins[lineCount];
        for (int i = 0; i < lineCount; i++) {
            origins[i] = CGPointZero;
        }
        CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
        
        CGPoint point = origins[lineCount - 1];
        CGFloat lineY = point.y;
        CGFloat lineAscent = 0;
        CGFloat lineDescent = 0;
        CGFloat lineLeading = 0;
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineCount - 1);
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        height = maxH - lineY + ceil(lineDescent);
    }
    return height;
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
    if (rects.count == 1) {
        menuRect = rects.firstObject.CGRectValue;
    }else{
        menuRect = rects.firstObject.CGRectValue;
        NSInteger count = rects.count;
        
        for (int i = 0; i < count + 1; i++) {
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

/// 获得触摸位置在哪一行
///
/// - Parameters:
///   - point: 触摸位置
///   - frameRef: CTFrame
/// - Returns: CTLine
CTLineRef getTouchLine(CGPoint point,CTFrameRef frameRef){
    
    CTLineRef line = nil;
    
    if (frameRef == nil) { return line; }
    
    CGPathRef path = CTFrameGetPath(frameRef);
    CGRect bounds = CGPathGetBoundingBox(path);
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    int lineCount = (int)CFArrayGetCount(lines);
    
    if (lineCount < 1) { return line; }
    
    CGPoint origins[lineCount];
    for (int i = 0; i < lineCount; i++) {
        origins[i] = CGPointZero;
    }
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    for (int i = 0; i < lineCount; i ++) {
        CGPoint origin = origins[i];
        CTLineRef tempLine = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent = 0;
        CGFloat lineDescent = 0;
        CGFloat lineLeading = 0;
        CTLineGetTypographicBounds(tempLine, &lineAscent, &lineDescent, &lineLeading);
        CGFloat lineWidth = bounds.size.width;
        CGFloat lineheight = lineAscent + lineDescent + lineLeading;
        
        CGRect lineFrame = CGRectMake(origin.x, bounds.size.height - origin.y - lineAscent, lineWidth, lineheight);
        lineFrame = CGRectInset(lineFrame, -5, -5);
        if (CGRectContainsPoint(lineFrame, point)) {
            line = tempLine;
            break;
        }
    }
    return line;
}

/// 获得触摸位置那一行文字的Range
///
/// - Parameters:
///   - point: 触摸位置
///   - frameRef: CTFrame
/// - Returns: CTLine
NSRange getTouchLineRange(CGPoint point,CTFrameRef frameRef){
    NSRange range = NSMakeRange(NSNotFound, 0);
    CTLineRef line = getTouchLine(point, frameRef);    
    if (line) {
        CFRange lineRange = CTLineGetStringRange(line);
        range = NSMakeRange(lineRange.location == kCFNotFound ? NSNotFound : lineRange.location, lineRange.length);
    }
    return range;
}

/// 获得触摸位置文字的Location
///
/// - Parameters:
///   - point: 触摸位置
///   - frameRef: CTFrame
/// - Returns: 触摸位置的Index
signed long getTouchLocation(CGPoint point,CTFrameRef frameRef){
    signed long location = -1;
    CTLineRef line = getTouchLine(point,frameRef);
    if (line != nil) {
        location = CTLineGetStringIndexForPosition(line, point);
    }
    return location;
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
    
    if (lineCount < 1) { return rects; }
    
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
