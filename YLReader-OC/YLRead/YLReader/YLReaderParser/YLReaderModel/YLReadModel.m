//
//  YLReadModel.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadModel.h"
#import "YLReadRecordModel.h"
#import "YLReadMarkModel.h"
#import "YLReadChapterModel.h"
#import "YLReadPageModel.h"
#import "YLKeyedArchiver.h"
#import "NSString+YLReader.h"

NSString *const kYLReadModelBookID = @"bookID";
NSString *const kYLReadModelChapterListModels = @"chapterListModels";
NSString *const kYLReadModelMarkModels = @"markModels";
NSString *const kYLReadModelRanges = @"ranges";
NSString *const kYLReadModelBookName = @"bookName";
NSString *const kYLReadModelFullText = @"fullText";
NSString *const kYLReadModelBookSourceType = @"bookSourceType";


NSString *getReadToalProgressString(float progress){
    return [NSString stringWithFormat:@"%.1f%%",floor(progress * 1000) / 10.0];
}


/// 计算总进度
float getReadToalProgress(YLReadModel *readModel,YLReadRecordModel *recordModel){
    // 当前阅读进度
    float progress = 0.0;
    if (!readModel || !recordModel) {
        return progress;
    }
    
    
    if (recordModel.isLastChapter && recordModel.isLastPage) { // 最后一章最后一页
        // 获得当前阅读进度
        progress = 1.0;
    }else{
        
        // 当前章节在所有章节列表中的位置
        float chapterIndex = recordModel.chapterModel.priority;
        // 章节总数量
        float chapterCount = readModel.chapterListModels.count;
        // 阅读记录首位置
        float locationFirst = recordModel.locationFirst;
        // 阅读记录内容长度
        float fullContentLength = recordModel.chapterModel.fullContent.length;
        // 获得当前阅读进度
        progress = (chapterIndex / chapterCount + locationFirst / fullContentLength / chapterCount);
    }
    
    // 返回
    return progress;
}



@interface YLReadModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation YLReadModel

@synthesize bookID = _bookID;
@synthesize chapterListModels = _chapterListModels;
@synthesize markModels = _markModels;
@synthesize ranges = _ranges;
@synthesize bookName = _bookName;
@synthesize fullText = _fullText;
@synthesize bookSourceType = _bookSourceType;

/// 保存
- (void)save{
    [self.recordModel save];
//    [YLKeyedArchiver archiverWithFolderName:kYLReadObjectKey fileName:self.bookID object:self];
    [YLKeyedArchiver archiverWithFolderName:self.bookID fileName:kYLReadObjectKey object:self];
}

/// 是否存在阅读对象
+ (BOOL)isExistWithBookID:(NSString *)bookID{
//    return [YLKeyedArchiver isExistWithFolderName:kYLReadObjectKey fileName:bookID];
    return [YLKeyedArchiver isExistWithFolderName:bookID fileName:kYLReadObjectKey];
}

/// 获取阅读对象,如果则创建对象返回
+ (YLReadModel *)modelWithBookID:(NSString *)bookID{
    YLReadModel *model = [[YLReadModel alloc] init];
    model.bookID = bookID;
    if ([YLReadModel isExistWithBookID:bookID]) {
       model = (YLReadModel *)[YLKeyedArchiver unarchiverWithFolderName:bookID fileName:kYLReadObjectKey];
        //model = (YLReadModel *)[YLKeyedArchiver unarchiverWithFolderName:kYLReadObjectKey fileName:bookID];
    }
    // 获取阅读记录
    model.recordModel = [YLReadRecordModel modelWithBookID:bookID];
    return model;
}

- (YLReadRecordModel *)recordModel{
    if (_recordModel == nil) {
        _recordModel = [YLReadRecordModel modelWithBookID:self.bookID];
    }
    return _recordModel;
}

- (NSMutableArray<YLReadMarkModel *> *)markModels{
    if (_markModels == nil) {
        _markModels = [NSMutableArray array];
    }
    return _markModels;
}





+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.bookID = [self objectOrNilForKey:kYLReadModelBookID fromDictionary:dict];
        self.chapterListModels = [self objectOrNilForKey:kYLReadModelChapterListModels fromDictionary:dict];
        self.markModels = [self objectOrNilForKey:kYLReadModelMarkModels fromDictionary:dict];
        self.ranges = [self objectOrNilForKey:kYLReadModelRanges fromDictionary:dict];
        self.bookName = [self objectOrNilForKey:kYLReadModelBookName fromDictionary:dict];
        self.fullText = [self objectOrNilForKey:kYLReadModelFullText fromDictionary:dict];
        self.bookSourceType = [[self objectOrNilForKey:kYLReadModelBookSourceType fromDictionary:dict] integerValue];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.bookID forKey:kYLReadModelBookID];
    [mutableDict setValue:self.chapterListModels forKey:kYLReadModelChapterListModels];
    [mutableDict setValue:self.markModels forKey:kYLReadModelMarkModels];
    [mutableDict setValue:self.ranges forKey:kYLReadModelRanges];
    [mutableDict setValue:self.bookName forKey:kYLReadModelBookName];
    [mutableDict setValue:self.fullText forKey:kYLReadModelFullText];
    [mutableDict setValue:[NSNumber numberWithInteger:self.bookSourceType] forKey:kYLReadModelBookSourceType];
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
    self.bookID = [aDecoder decodeObjectForKey:kYLReadModelBookID];
    self.chapterListModels = [aDecoder decodeObjectForKey:kYLReadModelChapterListModels];
    self.markModels = [aDecoder decodeObjectForKey:kYLReadModelMarkModels];
    self.ranges = [aDecoder decodeObjectForKey:kYLReadModelRanges];
    self.bookName = [aDecoder decodeObjectForKey:kYLReadModelBookName];
    self.fullText = [aDecoder decodeObjectForKey:kYLReadModelFullText];
    self.bookSourceType = [aDecoder decodeIntegerForKey:kYLReadModelBookSourceType];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_bookID forKey:kYLReadModelBookID];
    [aCoder encodeObject:_chapterListModels forKey:kYLReadModelChapterListModels];
    [aCoder encodeObject:_markModels forKey:kYLReadModelMarkModels];
    [aCoder encodeObject:_ranges forKey:kYLReadModelRanges];
    [aCoder encodeObject:_bookName forKey:kYLReadModelBookName];
    [aCoder encodeObject:_fullText forKey:kYLReadModelFullText];
    [aCoder encodeInteger:_bookSourceType forKey:kYLReadModelBookSourceType];
}

- (id)copyWithZone:(NSZone *)zone{
    YLReadModel *copy = [[YLReadModel alloc] init];
    if (copy) {
        copy.bookID = [self.bookID copyWithZone:zone];
        copy.chapterListModels = [self.chapterListModels copyWithZone:zone];
        copy.markModels = [self.markModels copyWithZone:zone];
        copy.ranges = [self.ranges copyWithZone:zone];
        copy.bookName = [self.bookName copyWithZone:zone];
        copy.fullText = [self.fullText copyWithZone:zone];
        copy.bookSourceType = self.bookSourceType;
    }
    return copy;
}


@end








@implementation YLReadModel (Mark)

/// 添加书签,默认使用当前阅读记录!

- (void)insetMark{
    [self insetMarkWithRecordModel:nil];
}

- (void)insetMarkWithRecordModel:(YLReadRecordModel *)recordModel{
    if (recordModel == nil) {
        recordModel = self.recordModel;
    }
    
    YLReadMarkModel *mark = [[YLReadMarkModel alloc] init];
    mark.bookID = recordModel.bookID;
    mark.chapterID = recordModel.chapterModel.id;
    
    if (recordModel.pageModel.isHomePage) {
        mark.name = @"(无章节名)";
        mark.content = self.bookName;
    }else{
        mark.name = recordModel.chapterModel.name;
        mark.content = recordModel.contentString.removeSEHeadAndTail.removeEnterAll;
    }
    mark.time = getTimer1970();
    mark.location = recordModel.locationFirst;
    [self.markModels insertObject:mark atIndex:0];
    [self save];
}

/// 移除当前书签
- (BOOL)removeMarkWithIndex:(NSInteger)index{
    [self.markModels removeObjectAtIndex:index];
    [self save];
    return YES;
}

/// 移除当前书签
- (BOOL)removeMark{
    return [self removeMarkWithRecordModel:nil];
}

- (BOOL)removeMarkWithRecordModel:(YLReadRecordModel *)recordModel{
    if (recordModel == nil) {
        recordModel = self.recordModel;
    }
    YLReadMarkModel *mark = [self isExistMarkWithRecordModel:recordModel];
    if (mark) {
        [self.markModels removeObject:mark];
        [self save];
        return YES;
    }
    return NO;
}

/// 是否存在书签
- (YLReadMarkModel *)isExistMark;{
    return [self isExistMarkWithRecordModel:nil];
}

- (YLReadMarkModel *)isExistMarkWithRecordModel:(YLReadRecordModel *)recordModel{
    __block YLReadMarkModel *mark = nil;

    if (self.markModels.count < 1) {
        return nil;
    }
    if (recordModel == nil) {
        recordModel = self.recordModel;
    }
    
    NSInteger locationFirst = recordModel.locationFirst;
    NSInteger locationLast = recordModel.locationLast;
    
    [self.markModels enumerateObjectsUsingBlock:^(YLReadMarkModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.chapterID == recordModel.chapterModel.id) {
            if (obj.location >= locationFirst &&
                obj.location <= locationLast) {
                mark = obj;
                * stop = YES;
            }
        }
    }];
    
    return mark;
}

@end


