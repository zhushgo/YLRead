//
//  BookModel.h
//
//  Created by 沫离 苏 on 2017/7/27
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BookModel : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *bookName;
@property (nonatomic, strong) NSString *intro;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) BOOL isEnd;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end


FOUNDATION_EXPORT NSBundle *bookBundle(void);
@interface BookModel (Loader)

@property (nonatomic, strong) NSString *readChapter;

- (NSURL *)fileUrl;
- (UIImage *)coverImage;

+ (void)getBooks:(void(^)(NSMutableArray<BookModel *> *bookArray))handler;

@end
