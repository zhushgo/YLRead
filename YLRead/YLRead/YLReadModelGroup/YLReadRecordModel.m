//
//  YLReadRecordModel.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadRecordModel.h"
#import "YLReadChapterModel.h"
#import "YLGlobalTools.h"
#import "YLKeyedArchiver.h"


NSUInteger kYLReadRecordCurrentChapterLocation;


NSString *const kYLReadRecordModelBookID = @"bookID";
NSString *const kYLReadRecordModelChapterModel = @"chapterModel";
NSString *const kYLReadRecordModelPage = @"page";

@interface YLReadRecordModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation YLReadRecordModel

@synthesize bookID = _bookID;
@synthesize chapterModel = _chapterModel;
@synthesize page = _page;





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

/// 修改阅读记录为指定章节页码 (toPage == -1 为当前章节最后一页)
- (void)modifyWithChapterID:(NSUInteger)chapterID toPage:(NSInteger)toPage{
    [self modifyWithChapterID:chapterID toPage:toPage isSave:YES];
}
- (void)modifyWithChapterID:(NSUInteger)chapterID toPage:(NSInteger)toPage isSave:(BOOL)isSave{
    
    if ([YLReadChapterModel isExistWithBookID:self.bookID chapterID:chapterID]) {
        self.chapterModel = [YLReadChapterModel modelWithBookID:self.bookID chapterID:chapterID];
        
        if (toPage == -1) {
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


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.bookID = [self objectOrNilForKey:kYLReadRecordModelBookID fromDictionary:dict];
        self.chapterModel = [self objectOrNilForKey:kYLReadRecordModelChapterModel fromDictionary:dict];
        self.page = [[self objectOrNilForKey:kYLReadRecordModelPage fromDictionary:dict] integerValue];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.bookID forKey:kYLReadRecordModelBookID];
    [mutableDict setValue:self.chapterModel forKey:kYLReadRecordModelChapterModel];
    [mutableDict setValue:[NSNumber numberWithInteger:self.page] forKey:kYLReadRecordModelPage];
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
    self.bookID = [aDecoder decodeObjectForKey:kYLReadRecordModelBookID];
    self.chapterModel = [aDecoder decodeObjectForKey:kYLReadRecordModelChapterModel];
    self.page = [aDecoder decodeDoubleForKey:kYLReadRecordModelPage];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_bookID forKey:kYLReadRecordModelBookID];
    [aCoder encodeObject:_chapterModel forKey:kYLReadRecordModelChapterModel];
    [aCoder encodeDouble:_page forKey:kYLReadRecordModelPage];
}

- (id)copyWithZone:(NSZone *)zone{
    YLReadRecordModel *copy = [[YLReadRecordModel alloc] init];
    if (copy) {
        copy.bookID = [self.bookID copyWithZone:zone];
        copy.chapterModel = [self.chapterModel copyWithZone:zone];
        copy.page = self.page;
    }
    return copy;
}

@end
