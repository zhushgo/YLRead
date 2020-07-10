//
//  YLReadMarkModel.h
//  FM
//
//  Created by 苏沫离 on 2020/6/29.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YLReadMarkModel : NSObject <NSCoding, NSCopying>

/// 小说ID
@property (nonatomic, strong) NSString *bookID;
/// 章节ID
@property (nonatomic, assign) NSInteger chapterID;
/// 章节名称
@property (nonatomic, strong) NSString *name;
/// 内容
@property (nonatomic, strong) NSString *content;
/// 时间戳
@property (nonatomic, assign) NSInteger time;
/// 位置
@property (nonatomic, assign) NSInteger location;



+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end


NS_ASSUME_NONNULL_END
