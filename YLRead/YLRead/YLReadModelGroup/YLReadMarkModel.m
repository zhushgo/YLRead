//
//  YLReadMarkModel.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/29.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadMarkModel.h"

NSString *const kYLReadMarkModelBookID = @"bookID";
NSString *const kYLReadMarkModelChapterID = @"chapterID";
NSString *const kYLReadMarkModelContent = @"content";
NSString *const kYLReadMarkModelName = @"name";
NSString *const kYLReadMarkModelTime = @"time";
NSString *const kYLReadMarkModelLocation = @"location";


@interface YLReadMarkModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation YLReadMarkModel

@synthesize bookID = _bookID;
@synthesize chapterID = _chapterID;
@synthesize content = _content;
@synthesize name = _name;
@synthesize time = _time;
@synthesize location = _location;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.bookID = [self objectOrNilForKey:kYLReadMarkModelBookID fromDictionary:dict];
        self.chapterID = [[self objectOrNilForKey:kYLReadMarkModelChapterID fromDictionary:dict] integerValue];
        self.content = [self objectOrNilForKey:kYLReadMarkModelContent fromDictionary:dict];
        self.name = [self objectOrNilForKey:kYLReadMarkModelName fromDictionary:dict];
        self.time = [[self objectOrNilForKey:kYLReadMarkModelTime fromDictionary:dict] integerValue];
        self.location = [[self objectOrNilForKey:kYLReadMarkModelLocation fromDictionary:dict] integerValue];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.bookID forKey:kYLReadMarkModelBookID];
    [mutableDict setValue:[NSNumber numberWithInteger:self.chapterID] forKey:kYLReadMarkModelChapterID];
    [mutableDict setValue:self.content forKey:kYLReadMarkModelContent];
    [mutableDict setValue:self.name forKey:kYLReadMarkModelName];
    [mutableDict setValue:[NSNumber numberWithInteger:self.time] forKey:kYLReadMarkModelTime];
    [mutableDict setValue:[NSNumber numberWithInteger:self.location] forKey:kYLReadMarkModelLocation];
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
    self.bookID = [aDecoder decodeObjectForKey:kYLReadMarkModelBookID];
    self.chapterID = [aDecoder decodeIntegerForKey:kYLReadMarkModelChapterID];
    self.content = [aDecoder decodeObjectForKey:kYLReadMarkModelContent];
    self.name = [aDecoder decodeObjectForKey:kYLReadMarkModelName];
    self.time = [aDecoder decodeIntegerForKey:kYLReadMarkModelTime];
    self.location = [aDecoder decodeIntegerForKey:kYLReadMarkModelLocation];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_bookID forKey:kYLReadMarkModelBookID];
    [aCoder encodeInteger:_chapterID forKey:kYLReadMarkModelChapterID];
    [aCoder encodeObject:_content forKey:kYLReadMarkModelContent];
    [aCoder encodeObject:_name forKey:kYLReadMarkModelName];
    [aCoder encodeInteger:_time forKey:kYLReadMarkModelTime];
    [aCoder encodeInteger:_location forKey:kYLReadMarkModelLocation];
}

- (id)copyWithZone:(NSZone *)zone{
    YLReadMarkModel *copy = [[YLReadMarkModel alloc] init];
    if (copy) {
        copy.bookID = [self.bookID copyWithZone:zone];
        copy.chapterID = self.chapterID;
        copy.content = [self.content copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.time = self.time;
        copy.location = self.location;
    }
    return copy;
}

@end
