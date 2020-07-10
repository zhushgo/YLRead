//
//  YLReadChapterListModel.h
//  FM
//
//  Created by 苏沫离 on 2020/6/29.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface YLReadChapterListModel : NSObject <NSCoding, NSCopying>

 /// 章节ID
@property (nonatomic, assign) NSInteger id;
 /// 章节名称
@property (nonatomic, strong) NSString *name;
 /// 小说ID
@property (nonatomic, strong) NSString *bookID;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end


NS_ASSUME_NONNULL_END
