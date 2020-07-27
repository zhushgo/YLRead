//
//  BookModel.m
//
//  Created by 沫离 苏 on 2020/7/27
//  Copyright (c) 2020 __MyCompanyName__. All rights reserved.
//

#import "BookModel.h"


NSString *const kBookModelAuthor = @"author";
NSString *const kBookModelEnd = @"isEnd";
NSString *const kBookModelBookName = @"bookName";
NSString *const kBookModelIntro = @"intro";
NSString *const kBookModelCover = @"cover";


@interface BookModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation BookModel

@synthesize author = _author;
@synthesize isEnd = _isEnd;
@synthesize bookName = _bookName;
@synthesize intro = _intro;
@synthesize cover = _cover;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.author = [self objectOrNilForKey:kBookModelAuthor fromDictionary:dict];
            self.isEnd = [[self objectOrNilForKey:kBookModelEnd fromDictionary:dict] boolValue];
            self.bookName = [self objectOrNilForKey:kBookModelBookName fromDictionary:dict];
            self.intro = [self objectOrNilForKey:kBookModelIntro fromDictionary:dict];
            self.cover = [self objectOrNilForKey:kBookModelCover fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.author forKey:kBookModelAuthor];
    [mutableDict setValue:[NSNumber numberWithBool:self.isEnd] forKey:kBookModelEnd];
    [mutableDict setValue:self.bookName forKey:kBookModelBookName];
    [mutableDict setValue:self.intro forKey:kBookModelIntro];
    [mutableDict setValue:self.cover forKey:kBookModelCover];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    self.author = [aDecoder decodeObjectForKey:kBookModelAuthor];
    self.isEnd = [aDecoder decodeBoolForKey:kBookModelEnd];
    self.bookName = [aDecoder decodeObjectForKey:kBookModelBookName];
    self.intro = [aDecoder decodeObjectForKey:kBookModelIntro];
    self.cover = [aDecoder decodeObjectForKey:kBookModelCover];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_author forKey:kBookModelAuthor];
    [aCoder encodeBool:_isEnd forKey:kBookModelEnd];
    [aCoder encodeObject:_bookName forKey:kBookModelBookName];
    [aCoder encodeObject:_intro forKey:kBookModelIntro];
    [aCoder encodeObject:_cover forKey:kBookModelCover];
}

- (id)copyWithZone:(NSZone *)zone
{
    BookModel *copy = [[BookModel alloc] init];
    
    if (copy) {

        copy.author = [self.author copyWithZone:zone];
        copy.isEnd = self.isEnd;
        copy.bookName = [self.bookName copyWithZone:zone];
        copy.intro = [self.intro copyWithZone:zone];
        copy.cover = [self.cover copyWithZone:zone];
    }
    
    return copy;
}


@end


NSBundle *bookBundle(void){
    return [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:@"BookResources" ofType:@"bundle"]];
}

@implementation BookModel (Loader)

- (NSURL *)fileUrl{
    return [bookBundle() URLForResource:self.bookName withExtension:@"txt"];
}

- (NSString *)cover{
    return [NSString stringWithFormat:@"BookResources.bundle/%@.jpg",self.bookName];
}

- (UIImage *)coverImage{
    
    return [UIImage imageNamed:self.cover];
}

+ (void)getBooks:(void(^)(NSMutableArray<BookModel *> *bookArray))handler{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *array = [NSMutableArray array];
        NSString *path = [bookBundle() pathForResource:@"BookMenu" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSArray<NSDictionary *> *array1 = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [array1 enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BookModel *model = [BookModel modelObjectWithDictionary:obj];
            [array addObject:model];
        }];
         dispatch_async(dispatch_get_main_queue(), ^{
             handler(array);
         });
    });
}


@end
    
