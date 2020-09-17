//
//  YLReadChapterListModel.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/29.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadChapterListModel.h"

NSString *const kYLReadChapterListModelId = @"id";
NSString *const kYLReadChapterListModelName = @"name";
NSString *const kYLReadChapterListModelBookID = @"bookID";


@interface YLReadChapterListModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation YLReadChapterListModel

@synthesize id = _id;
@synthesize name = _name;
@synthesize bookID = _bookID;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.id = [[self objectOrNilForKey:kYLReadChapterListModelId fromDictionary:dict] doubleValue];
        self.name = [self objectOrNilForKey:kYLReadChapterListModelName fromDictionary:dict];
        self.bookID = [self objectOrNilForKey:kYLReadChapterListModelBookID fromDictionary:dict];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithInteger:self.id] forKey:kYLReadChapterListModelId];
    [mutableDict setValue:self.name forKey:kYLReadChapterListModelName];
    [mutableDict setValue:self.bookID forKey:kYLReadChapterListModelBookID];
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
    self.id = [aDecoder decodeIntegerForKey:kYLReadChapterListModelId];
    self.name = [aDecoder decodeObjectForKey:kYLReadChapterListModelName];
    self.bookID = [aDecoder decodeObjectForKey:kYLReadChapterListModelBookID];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInteger:_id forKey:kYLReadChapterListModelId];
    [aCoder encodeObject:_name forKey:kYLReadChapterListModelName];
    [aCoder encodeObject:_bookID forKey:kYLReadChapterListModelBookID];
}

- (id)copyWithZone:(NSZone *)zone{
    YLReadChapterListModel *copy = [[YLReadChapterListModel alloc] init];
    if (copy) {
        copy.id = self.id;
        copy.name = [self.name copyWithZone:zone];
        copy.bookID = [self.bookID copyWithZone:zone];
    }
    return copy;
}

@end
