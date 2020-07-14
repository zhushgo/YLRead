//
//  YLReadPageModel.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadPageModel.h"
#import "YLReadConfigure.h"

NSString *const kYLReadPageModelHeadTypeHeight = @"headTypeHeight";
NSString *const kYLReadPageModelRange = @"range";
NSString *const kYLReadPageModelContent = @"content";
NSString *const kYLReadPageModelContentSize = @"contentSize";
NSString *const kYLReadPageModelHeadType= @"headType";
NSString *const kYLReadPageModelPage = @"page";


@interface YLReadPageModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation YLReadPageModel

@synthesize headTypeHeight = _headTypeHeight;
@synthesize range = _range;
@synthesize content = _content;
@synthesize contentSize = _contentSize;
@synthesize headType = _headType;
@synthesize page = _page;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.headTypeHeight = [[self objectOrNilForKey:kYLReadPageModelHeadTypeHeight fromDictionary:dict] doubleValue];
        self.range = [[self objectOrNilForKey:kYLReadPageModelRange fromDictionary:dict] rangeValue];
        self.content = [self objectOrNilForKey:kYLReadPageModelContent fromDictionary:dict];
        self.contentSize = [[self objectOrNilForKey:kYLReadPageModelContentSize fromDictionary:dict] CGSizeValue];
        self.headType = [[self objectOrNilForKey:kYLReadPageModelHeadType fromDictionary:dict] doubleValue];
        self.page = [[self objectOrNilForKey:kYLReadPageModelPage fromDictionary:dict] doubleValue];
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _headTypeHeight = 0;
        _contentSize = CGSizeZero;
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.headTypeHeight] forKey:kYLReadPageModelHeadTypeHeight];
    [mutableDict setValue:[NSValue valueWithRange:self.range] forKey:kYLReadPageModelRange];
    [mutableDict setValue:self.content forKey:kYLReadPageModelContent];
    [mutableDict setValue:[NSValue valueWithCGSize:self.contentSize] forKey:kYLReadPageModelContentSize];
    [mutableDict setValue:[NSNumber numberWithInteger:self.headType] forKey:kYLReadPageModelHeadType];
    [mutableDict setValue:[NSNumber numberWithDouble:self.page] forKey:kYLReadPageModelPage];
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    self.content = [aDecoder decodeObjectForKey:kYLReadPageModelContent];
    self.range = [[aDecoder decodeObjectForKey:kYLReadPageModelRange] rangeValue];
    self.contentSize = [[aDecoder decodeObjectForKey:kYLReadPageModelContentSize] CGSizeValue];
    self.page = [aDecoder decodeIntegerForKey:kYLReadPageModelPage];
    self.headTypeHeight = [aDecoder decodeDoubleForKey:kYLReadPageModelHeadTypeHeight];
    self.headType = [aDecoder decodeIntegerForKey:kYLReadPageModelHeadType];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_content forKey:kYLReadPageModelContent];
    [aCoder encodeObject:[NSValue valueWithRange:_range] forKey:kYLReadPageModelRange];
    [aCoder encodeObject:[NSValue valueWithCGSize:_contentSize] forKey:kYLReadPageModelContentSize];
    [aCoder encodeInteger:_page forKey:kYLReadPageModelPage];
    [aCoder encodeDouble:_headTypeHeight forKey:kYLReadPageModelHeadTypeHeight];
    [aCoder encodeInteger:_headType forKey:kYLReadPageModelHeadType];
}

- (id)copyWithZone:(NSZone *)zone{
    YLReadPageModel *copy = [[YLReadPageModel alloc] init];
    if (copy) {
        copy.content = [self.content copyWithZone:zone];
        copy.headTypeHeight = self.headTypeHeight;
        copy.range = self.range;
        copy.contentSize = self.contentSize;
        copy.headType = self.headType;
        copy.page = self.page;
    }
    return copy;
}

/// 当前内容总高(cell 高度)
- (CGFloat)cellHeight{
    // 内容高度 + 头部高度
    return self.contentSize.height + _headTypeHeight;
}

/// 书籍首页
- (BOOL)isHomePage{
    return self.range.location == -1;
}

/// 获取显示内容(考虑可能会变换字体颜色的情况)
- (NSAttributedString *)showContent{
    NSMutableAttributedString *tempShowContent = [[NSMutableAttributedString alloc]initWithAttributedString:self.content];
    [tempShowContent addAttributes:@{NSForegroundColorAttributeName:YLReadConfigure.shareConfigure.textColor} range:NSMakeRange(0, self.content.length)];
    return tempShowContent;
}

@end
