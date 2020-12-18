//
//  YLReadRecordModel.m
//  YLRead
//
//  Created by 苏沫离 on 2017/6/24.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import "YLReadRecordModel.h"
#import "YLReadChapterModel.h"
#import "YLKeyedArchiver.h"


NSUInteger kYLReadRecordCurrentChapterLocation;


NSString *const kYLReadRecordModelBookID = @"bookID";
NSString *const kYLReadRecordModelChapterModel = @"chapterModel";
NSString *const kYLReadRecordModelContentAttributedString = @"contentAttributedString";
NSString *const kYLReadRecordModelContentString = @"contentString";
NSString *const kYLReadRecordModelIsFirstChapter = @"isFirstChapter";
NSString *const kYLReadRecordModelIsFirstPage = @"isFirstPage";
NSString *const kYLReadRecordModelIsLastChapter = @"isLastChapter";
NSString *const kYLReadRecordModelIsLastPage = @"isLastPage";
NSString *const kYLReadRecordModelLocationFirst = @"locationFirst";
NSString *const kYLReadRecordModelLocationLast = @"locationLast";
NSString *const kYLReadRecordModelPage = @"page";
NSString *const kYLReadRecordModelPageModel = @"pageModel";


@implementation YLReadRecordModel

@synthesize bookID = _bookID;
@synthesize chapterModel = _chapterModel;
@synthesize contentAttributedString = _contentAttributedString;
@synthesize contentString = _contentString;
@synthesize isFirstChapter = _isFirstChapter;
@synthesize isFirstPage = _isFirstPage;
@synthesize isLastChapter = _isLastChapter;
@synthesize isLastPage = _isLastPage;
@synthesize locationFirst = _locationFirst;
@synthesize locationLast = _locationLast;
@synthesize page = _page;
@synthesize pageModel = _pageModel;


#pragma mark - Helper Method

///重写 -description 方法
- (NSString *)description {
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - NSCoding Methods

///实现 NSCoding 的序列化方法
- (void)encodeWithCoder:(NSCoder *)aCoder{
    if(self.bookID != nil){
        [aCoder encodeObject:_bookID forKey:kYLReadRecordModelBookID];
    }
    if(_chapterModel != nil){
        [aCoder encodeObject:self.chapterModel forKey:kYLReadRecordModelChapterModel];
    }
    if(self.contentAttributedString != nil){
        [aCoder encodeObject:_contentAttributedString forKey:kYLReadRecordModelContentAttributedString];
    }
    if(self.contentString != nil){
        [aCoder encodeObject:_contentString forKey:kYLReadRecordModelContentString];
    }
    [aCoder encodeObject:@(_isFirstChapter) forKey:kYLReadRecordModelIsFirstChapter];
    [aCoder encodeObject:@(_isFirstPage) forKey:kYLReadRecordModelIsFirstPage];
    [aCoder encodeObject:@(_isLastChapter) forKey:kYLReadRecordModelIsLastChapter];
    [aCoder encodeObject:@(_isLastPage) forKey:kYLReadRecordModelIsLastPage];
    [aCoder encodeObject:@(_locationFirst) forKey:kYLReadRecordModelLocationFirst];
    [aCoder encodeObject:@(_locationLast) forKey:kYLReadRecordModelLocationLast];
    [aCoder encodeObject:@(_page) forKey:kYLReadRecordModelPage];
    if(_pageModel != nil){
        [aCoder encodeObject:self.pageModel forKey:kYLReadRecordModelPageModel];
    }
}

///实现 NSCoding 的反序列化方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    self.bookID = [aDecoder decodeObjectForKey:kYLReadRecordModelBookID];
    self.chapterModel = [aDecoder decodeObjectForKey:kYLReadRecordModelChapterModel];
    self.contentAttributedString = [aDecoder decodeObjectForKey:kYLReadRecordModelContentAttributedString];
    self.contentString = [aDecoder decodeObjectForKey:kYLReadRecordModelContentString];
    self.isFirstChapter = [[aDecoder decodeObjectForKey:kYLReadRecordModelIsFirstChapter] boolValue];
    self.isFirstPage = [[aDecoder decodeObjectForKey:kYLReadRecordModelIsFirstPage] boolValue];
    self.isLastChapter = [[aDecoder decodeObjectForKey:kYLReadRecordModelIsLastChapter] boolValue];
    self.isLastPage = [[aDecoder decodeObjectForKey:kYLReadRecordModelIsLastPage] boolValue];
    self.locationFirst = [[aDecoder decodeObjectForKey:kYLReadRecordModelLocationFirst] integerValue];
    self.locationLast = [[aDecoder decodeObjectForKey:kYLReadRecordModelLocationLast] integerValue];
    self.page = [[aDecoder decodeObjectForKey:kYLReadRecordModelPage] integerValue];
    self.pageModel = [aDecoder decodeObjectForKey:kYLReadRecordModelPageModel];
    return self;
}

///实现该方法，确保实例被 copy 时自身的参数也被 copy
- (instancetype)copyWithZone:(NSZone *)zone{
    YLReadRecordModel *copy = [[YLReadRecordModel alloc] init];
    if (copy) {
        copy.bookID = [self.bookID copy];
        copy.chapterModel = [self.chapterModel copy];
        copy.contentAttributedString = [self.contentAttributedString copy];
        copy.contentString = [self.contentString copy];
        copy.isFirstChapter = self.isFirstChapter;
        copy.isFirstPage = self.isFirstPage;
        copy.isLastChapter = self.isLastChapter;
        copy.isLastPage = self.isLastPage;
        copy.locationFirst = self.locationFirst;
        copy.locationLast = self.locationLast;
        copy.page = self.page;
        //copy.pageModel = [self.pageModel copy];
    }
    return copy;
}

@end







@implementation YLReadRecordModel (Service)

- (YLReadPageModel *)pageModel{
    return self.chapterModel.pageModels[self.page];
}

- (NSUInteger)locationFirst{
    return [self.chapterModel locationFirst:self.page];
}

- (NSUInteger)locationLast{
    return [self.chapterModel locationLast:self.page];
}

- (BOOL)isFirstChapter{
    return self.chapterModel.isFirstChapter;
}

- (BOOL)isLastChapter{
    return self.chapterModel.isLastChapter;
}

- (BOOL)isFirstPage{
    return self.page == 0;
}

- (BOOL)isLastPage{
    return self.page == self.chapterModel.pageCount - 1;
}

- (NSString *)contentString{
    return [self.chapterModel contentString:self.page];
}

- (NSAttributedString *)contentAttributedString{
    return [self.chapterModel contentAttributedString:self.page];
}

/// 当前记录切到上一页
- (void)previousPage{
    self.page = MAX(_page - 1, 0);
}

/// 当前记录切到下一页
- (void)nextPage{
    self.page = MIN(_page + 1, self.chapterModel.pageCount - 1);
}

/// 当前记录切到第一页
- (void)firstPage{
    self.page = 0;
}

/// 当前记录切到最后一页
- (void)lastPage{
    self.page = self.chapterModel.pageCount - 1;
}

/// 修改阅读记录为指定章节位置
- (void)modifyWithChapterModel:(YLReadChapterModel *)chapterModel page:(NSInteger)page{
    [self modifyWithChapterModel:chapterModel page:page isSave:YES];
}

- (void)modifyWithChapterModel:(YLReadChapterModel *)chapterModel page:(NSInteger)page isSave:(BOOL)isSave{
    self.chapterModel = chapterModel;
    self.page = page;
    if (isSave) {
        [self save];
    }
}


/// 修改阅读记录为指定章节位置
- (void)modifyWithChapterID:(NSUInteger)chapterID location:(NSInteger)location{
    [self modifyWithChapterID:chapterID location:location isSave:YES];
}
- (void)modifyWithChapterID:(NSUInteger)chapterID location:(NSInteger)location isSave:(BOOL)isSave{
    
    if ([YLReadChapterModel isExistWithBookID:self.bookID chapterID:chapterID]) {
        self.chapterModel = [YLReadChapterModel modelWithBookID:self.bookID chapterID:chapterID];
        self.page = [self.chapterModel page:location];
        
        if (isSave) {
            [self save];
        }
    }
}

/// 修改阅读记录为指定章节页码 (toPage == kYLReadChapterLastPage 为当前章节最后一页)
- (void)modifyWithChapterID:(NSUInteger)chapterID toPage:(NSInteger)toPage{
    [self modifyWithChapterID:chapterID toPage:toPage isSave:YES];
}
- (void)modifyWithChapterID:(NSUInteger)chapterID toPage:(NSInteger)toPage isSave:(BOOL)isSave{
    
    if ([YLReadChapterModel isExistWithBookID:self.bookID chapterID:chapterID]) {
        self.chapterModel = [YLReadChapterModel modelWithBookID:self.bookID chapterID:chapterID];
        
        if (toPage == kYLReadChapterLastPage) {
            [self lastPage];
        }else{
            self.page = toPage;
        }
        
       if (isSave) {
           [self save];
       }
    }
}

/// 更新字体
- (void)updateFont{
    [self updateFontWithIsSave:YES];
}
- (void)updateFontWithIsSave:(BOOL)isSave{
    if (_chapterModel) {
        [self.chapterModel updateFont];
        self.page = [self.chapterModel page:kYLReadRecordCurrentChapterLocation];
        if (isSave) {
            [self save];
        }
    }
}

/// 拷贝阅读记录
- (YLReadRecordModel *)copyTheModel{
    YLReadRecordModel *model = [[YLReadRecordModel alloc] init];
    model.bookID = self.bookID;
    model.chapterModel = self.chapterModel;
    model.page = self.page;
    return model;
}

/// 保存记录
- (void)save{
    [YLKeyedArchiver archiverWithFolderName:kYLReadRecordKey fileName:self.bookID object:self];
}

/// 是否存在阅读记录
+ (BOOL)isExistWithBookID:(NSString *)bookID{
    return [YLKeyedArchiver isExistWithFolderName:kYLReadRecordKey fileName:bookID];
}

/// 获取阅读记录对象,如果则创建对象返回
+ (YLReadRecordModel *)modelWithBookID:(NSString *)bookID{
    YLReadRecordModel *model = [[YLReadRecordModel alloc] init];
    model.bookID = bookID;
    if ([YLReadRecordModel isExistWithBookID:bookID]) {
        model = [YLKeyedArchiver unarchiverWithFolderName:kYLReadRecordKey fileName:bookID];
        [model.chapterModel updateFont];
    }
    return model;
}

@end














@implementation YLReadRecordModel (JsonModel)

/// 根据传递的 Dictionary 创建一个实例
+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dictionary{
    if (dictionary && [dictionary isKindOfClass:[NSDictionary class]] && dictionary.allKeys > 0){
        return [[self alloc]initWithDictionary:dictionary];
    }else{
        return nil;
    }
}

/// 根据传递的 Dictionary 初始化该实例
-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if(self && [dictionary isKindOfClass:[NSDictionary class]]) {
        if(![dictionary[kYLReadRecordModelBookID] isKindOfClass:[NSNull class]]){
            self.bookID = dictionary[kYLReadRecordModelBookID];
        }
        if(![dictionary[kYLReadRecordModelChapterModel] isKindOfClass:[NSNull class]]){
            self.chapterModel = [[YLReadChapterModel alloc] initWithDictionary:dictionary[kYLReadRecordModelChapterModel]];
        }
        if(![dictionary[kYLReadRecordModelContentAttributedString] isKindOfClass:[NSNull class]]){
            self.contentAttributedString = dictionary[kYLReadRecordModelContentAttributedString];
        }
        if(![dictionary[kYLReadRecordModelContentString] isKindOfClass:[NSNull class]]){
            self.contentString = dictionary[kYLReadRecordModelContentString];
        }
        if(![dictionary[kYLReadRecordModelIsFirstChapter] isKindOfClass:[NSNull class]]){
            self.isFirstChapter = [dictionary[kYLReadRecordModelIsFirstChapter] boolValue];
        }
        if(![dictionary[kYLReadRecordModelIsFirstPage] isKindOfClass:[NSNull class]]){
            self.isFirstPage = [dictionary[kYLReadRecordModelIsFirstPage] boolValue];
        }
        if(![dictionary[kYLReadRecordModelIsLastChapter] isKindOfClass:[NSNull class]]){
            self.isLastChapter = [dictionary[kYLReadRecordModelIsLastChapter] boolValue];
        }
        if(![dictionary[kYLReadRecordModelIsLastPage] isKindOfClass:[NSNull class]]){
            self.isLastPage = [dictionary[kYLReadRecordModelIsLastPage] boolValue];
        }
        if(![dictionary[kYLReadRecordModelLocationFirst] isKindOfClass:[NSNull class]]){
            self.locationFirst = [dictionary[kYLReadRecordModelLocationFirst] integerValue];
        }
        if(![dictionary[kYLReadRecordModelLocationLast] isKindOfClass:[NSNull class]]){
            self.locationLast = [dictionary[kYLReadRecordModelLocationLast] integerValue];
        }
        if(![dictionary[kYLReadRecordModelPage] isKindOfClass:[NSNull class]]){
            self.page = [dictionary[kYLReadRecordModelPage] integerValue];
        }
        if(![dictionary[kYLReadRecordModelPageModel] isKindOfClass:[NSNull class]]){
            //self.pageModel = [[YLReadPageModel alloc] initWithDictionary:dictionary[kYLReadRecordModelPageModel]];
        }
    }
    return self;
}

///返回该实例的可用属性值
-(NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if(self.bookID != nil){
        dictionary[kYLReadRecordModelBookID] = self.bookID;
    }
    if(self.chapterModel != nil){
        dictionary[kYLReadRecordModelChapterModel] = [self.chapterModel dictionaryRepresentation];
    }
    if(self.contentAttributedString != nil){
        dictionary[kYLReadRecordModelContentAttributedString] = self.contentAttributedString;
    }
    if(self.contentString != nil){
        dictionary[kYLReadRecordModelContentString] = self.contentString;
    }
    dictionary[kYLReadRecordModelIsFirstChapter] = @(self.isFirstChapter);
    dictionary[kYLReadRecordModelIsFirstPage] = @(self.isFirstPage);
    dictionary[kYLReadRecordModelIsLastChapter] = @(self.isLastChapter);
    dictionary[kYLReadRecordModelIsLastPage] = @(self.isLastPage);
    dictionary[kYLReadRecordModelLocationFirst] = @(self.locationFirst);
    dictionary[kYLReadRecordModelLocationLast] = @(self.locationLast);
    dictionary[kYLReadRecordModelPage] = @(self.page);
    if(self.pageModel != nil){
        dictionary[kYLReadRecordModelPageModel] = self.pageModel;
    }
    return dictionary;
}

@end
