//
//  YLReadChapterModel.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/28.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadChapterModel.h"
#import "YLReadPageModel.h"
#import "YLKeyedArchiver.h"
#import "YLReadParser.h"

NSString *const kYLReadChapterModelBookID = @"bookID";
NSString *const kYLReadChapterModelContent = @"content";
NSString *const kYLReadChapterModelPreviousChapterID = @"previousChapterID";
NSString *const kYLReadChapterModelId = @"id";
NSString *const kYLReadChapterModelFullContent = @"fullContent";
NSString *const kYLReadChapterModelNextChapterID = @"nextChapterID";
NSString *const kYLReadChapterModelPageCount = @"pageCount";
NSString *const kYLReadChapterModelPageModels = @"pageModels";
NSString *const kYLReadChapterModelAttributes = @"attributes";
NSString *const kYLReadChapterModelPriority = @"priority";
NSString *const kYLReadChapterModelName = @"name";


@interface YLReadChapterModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end


@implementation YLReadChapterModel

@synthesize bookID = _bookID;
@synthesize content = _content;
@synthesize previousChapterID = _previousChapterID;
@synthesize id = _id;
@synthesize fullContent = _fullContent;
@synthesize nextChapterID = _nextChapterID;
@synthesize pageCount = _pageCount;
@synthesize pageModels = _pageModels;
@synthesize attributes = _attributes;
@synthesize priority = _priority;
@synthesize name = _name;

- (instancetype)init{
    self = [super init];
    if (self) {
        self.id = 1;
        self.nextChapterID = kYLReadChapterIDMax;
        self.previousChapterID = kYLReadChapterIDMin;
        self.name = @"前言";
        self.priority = 0;
    }
    return self;
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
    self.bookID = [aDecoder decodeObjectForKey:kYLReadChapterModelBookID];
    self.content = [aDecoder decodeObjectForKey:kYLReadChapterModelContent];
    self.previousChapterID = [aDecoder decodeDoubleForKey:kYLReadChapterModelPreviousChapterID];
    self.id = [aDecoder decodeDoubleForKey:kYLReadChapterModelId];
    self.fullContent = [aDecoder decodeObjectForKey:kYLReadChapterModelFullContent];
    self.nextChapterID = [aDecoder decodeDoubleForKey:kYLReadChapterModelNextChapterID];
    self.pageCount = [aDecoder decodeDoubleForKey:kYLReadChapterModelPageCount];
    self.pageModels = [aDecoder decodeObjectForKey:kYLReadChapterModelPageModels];
    self.attributes = [aDecoder decodeObjectForKey:kYLReadChapterModelAttributes];
    self.priority = [aDecoder decodeDoubleForKey:kYLReadChapterModelPriority];
    self.name = [aDecoder decodeObjectForKey:kYLReadChapterModelName];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_bookID forKey:kYLReadChapterModelBookID];
    [aCoder encodeObject:_content forKey:kYLReadChapterModelContent];
    [aCoder encodeDouble:_previousChapterID forKey:kYLReadChapterModelPreviousChapterID];
    [aCoder encodeDouble:_id forKey:kYLReadChapterModelId];
    
    [aCoder encodeObject:_fullContent forKey:kYLReadChapterModelFullContent];
    [aCoder encodeDouble:_nextChapterID forKey:kYLReadChapterModelNextChapterID];
    [aCoder encodeDouble:_pageCount forKey:kYLReadChapterModelPageCount];
    [aCoder encodeObject:_pageModels forKey:kYLReadChapterModelPageModels];
    
    [aCoder encodeObject:_attributes forKey:kYLReadChapterModelAttributes];
    [aCoder encodeDouble:_priority forKey:kYLReadChapterModelPriority];
    [aCoder encodeObject:_name forKey:kYLReadChapterModelName];
}

- (id)copyWithZone:(NSZone *)zone{
    YLReadChapterModel *copy = [[YLReadChapterModel alloc] init];
    if (copy) {
        copy.bookID = [self.bookID copyWithZone:zone];
        copy.content = [self.content copyWithZone:zone];
        copy.previousChapterID = self.previousChapterID;
        copy.id = self.id;
        
        copy.fullContent = [self.fullContent copyWithZone:zone];
        copy.nextChapterID = self.nextChapterID;
        copy.pageCount = self.pageCount;
        copy.pageModels = [self.pageModels copyWithZone:zone];
        
        copy.attributes = [self.attributes copyWithZone:zone];
        copy.priority = self.priority;
        copy.name = [self.name copyWithZone:zone];
    }
    return copy;
}

- (NSMutableArray<YLReadPageModel *> *)pageModels{
    if (_pageModels == nil) {
        _pageModels = [NSMutableArray array];
    }
    return _pageModels;
}

@end









@implementation YLReadChapterModel (Service)

/// 更新字体
- (void)updateFont{
    NSDictionary<NSAttributedStringKey,id> *tempAttributes = [YLReadConfigure.shareConfigure attributesWithIsTitle:NO isPageing:YES];
    if (![self.attributes isEqualToDictionary:tempAttributes]) {
        self.attributes = [tempAttributes copy];
        self.fullContent = [self fullContentAttrString];        
        self.pageModels = [YLReadParser pageingWithAttrString:self.fullContent rect:CGRectMake(0, 0, getReadViewRect().size.width, getReadViewRect().size.height) isFirstChapter:self.isFirstChapter];
        self.pageCount = self.pageModels.count;
        [self save];
    }
}

/// 完整内容排版
- (NSMutableAttributedString *)fullContentAttrString{
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:self.fullName attributes:[YLReadConfigure.shareConfigure attributesWithIsTitle:YES]];
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:self.content attributes:[YLReadConfigure.shareConfigure attributesWithIsTitle:NO]];
    [titleString appendAttributedString:contentString];
    return titleString;
}

/// 获取指定页码字符串
- (NSString *)contentString:(NSUInteger)page{
    return self.pageModels[page].content.string;
}

/// 获取指定页码富文本
- (NSAttributedString *)contentAttributedString:(NSUInteger)page{
    return self.pageModels[page].showContent;
}

/// 获取指定页开始坐标
- (NSUInteger)locationFirst:(NSUInteger)page{
    return self.pageModels[page].range.location;
}

/// 获取指定页码末尾坐标
- (NSUInteger)locationLast:(NSUInteger)page{
    return self.pageModels[page].range.location + self.pageModels[page].range.length;
}

/// 获取指定页中间
- (NSUInteger)locationCenter:(NSUInteger)page{
    NSRange range = self.pageModels[page].range;
    return range.location + (range.location + range.length) / 2;
}

/// 获取存在指定坐标的页码
- (NSUInteger)page:(NSUInteger)location{
    __block NSUInteger page = 0;
    [self.pageModels enumerateObjectsUsingBlock:^(YLReadPageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = obj.range;
        if (location < (range.location + range.length)) {
            page = idx;
            * stop = YES;
        }
    }];
    return page;
}

/// 保存
- (void)save{
    [YLKeyedArchiver archiverWithFolderName:self.bookID fileName:[NSString stringWithFormat:@"%ld",self.id] object:self];
}

/// 是否存在章节内容
+ (BOOL)isExistWithBookID:(NSString *)bookID chapterID:(NSInteger)chapterID{
    return [YLKeyedArchiver isExistWithFolderName:bookID fileName:[NSString stringWithFormat:@"%ld",chapterID]];
}

+ (instancetype)modelWithBookID:(NSString *)bookID chapterID:(NSInteger)chapterID{
    return [self modelWithBookID:bookID chapterID:chapterID isUpdateFont:YES];
}
/// 获取章节对象,如果则创建对象返回
+ (instancetype)modelWithBookID:(NSString *)bookID chapterID:(NSInteger)chapterID isUpdateFont:(BOOL)isUpdateFont{
    YLReadChapterModel *model;
    if ([self isExistWithBookID:bookID chapterID:chapterID]) {
        model = [YLKeyedArchiver unarchiverWithFolderName:bookID fileName:[NSString stringWithFormat:@"%ld",chapterID]];
        if (isUpdateFont) {
            [model updateFont];
        }        
    }else{
        model = [[YLReadChapterModel alloc] init];
        model.bookID = bookID;
        model.id = chapterID;
    }
    return model;
}

- (BOOL)isFirstChapter{
     return self.previousChapterID == kYLReadChapterIDMin;
}

- (BOOL)isLastChapter{
    return self.nextChapterID == kYLReadChapterIDMax;
}

- (float)pageTotalHeight{
    __block float height = 0;
    [self.pageModels enumerateObjectsUsingBlock:^(YLReadPageModel * _Nonnull pageModel, NSUInteger idx, BOOL * _Nonnull stop) {
        height += pageModel.contentSize.height + pageModel.headTypeHeight;
    }];
    return height;
}

- (NSString *)fullName{
    return [NSString stringWithFormat:@"\n\%@\n\n",self.name];
}

@end




@implementation YLReadChapterModel (JsonModel)

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.bookID = [self objectOrNilForKey:kYLReadChapterModelBookID fromDictionary:dict];
        self.content = [self objectOrNilForKey:kYLReadChapterModelContent fromDictionary:dict];
        self.previousChapterID = [[self objectOrNilForKey:kYLReadChapterModelPreviousChapterID fromDictionary:dict] doubleValue];
        self.id = [[self objectOrNilForKey:kYLReadChapterModelId fromDictionary:dict] doubleValue];
        self.fullContent = [self objectOrNilForKey:kYLReadChapterModelFullContent fromDictionary:dict];
        self.nextChapterID = [[self objectOrNilForKey:kYLReadChapterModelNextChapterID fromDictionary:dict] doubleValue];
        self.pageCount = [[self objectOrNilForKey:kYLReadChapterModelPageCount fromDictionary:dict] doubleValue];
        self.pageModels = [self objectOrNilForKey:kYLReadChapterModelPageModels fromDictionary:dict];
        self.attributes = [self objectOrNilForKey:kYLReadChapterModelAttributes fromDictionary:dict];
        self.priority = [[self objectOrNilForKey:kYLReadChapterModelPriority fromDictionary:dict] doubleValue];
        self.name = [self objectOrNilForKey:kYLReadChapterModelName fromDictionary:dict];
    }
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.bookID forKey:kYLReadChapterModelBookID];
    [mutableDict setValue:self.content forKey:kYLReadChapterModelContent];
    [mutableDict setValue:[NSNumber numberWithDouble:self.previousChapterID] forKey:kYLReadChapterModelPreviousChapterID];
    [mutableDict setValue:[NSNumber numberWithDouble:self.id] forKey:kYLReadChapterModelId];
    [mutableDict setValue:self.fullContent forKey:kYLReadChapterModelFullContent];
    [mutableDict setValue:[NSNumber numberWithDouble:self.nextChapterID] forKey:kYLReadChapterModelNextChapterID];
    [mutableDict setValue:[NSNumber numberWithDouble:self.pageCount] forKey:kYLReadChapterModelPageCount];
    [mutableDict setValue:self.pageModels forKey:kYLReadChapterModelPageModels];
    [mutableDict setValue:self.attributes forKey:kYLReadChapterModelAttributes];
    [mutableDict setValue:[NSNumber numberWithDouble:self.priority] forKey:kYLReadChapterModelPriority];
    [mutableDict setValue:self.name forKey:kYLReadChapterModelName];
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

@end
