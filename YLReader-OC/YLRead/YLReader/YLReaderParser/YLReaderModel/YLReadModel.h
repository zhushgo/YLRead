//
//  YLReadModel.h
//  YLRead
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 书籍来源类型
typedef NS_ENUM(NSUInteger,YLBookSourceType) {
    YLBookSourceTypeNetwork = 0,/// 网络小说
    YLBookSourceTypeLocal,/// 本地小说
};

@class YLReadRecordModel,YLReadMarkModel,YLReadChapterListModel;
@interface YLReadModel : NSObject <NSCoding, NSCopying>

/// 小说ID
@property (nonatomic, strong) NSString *bookID;
/// 小说名称
@property (nonatomic, strong) NSString *bookName;
/// 小说来源类型：默认网络
@property (nonatomic, assign) YLBookSourceType bookSourceType;
/// 当前阅读记录
@property (nonatomic, strong) YLReadRecordModel *recordModel;
/// 章节列表索引：简单的记录章节 id，name 数据
@property (nonatomic, strong) NSArray<YLReadChapterListModel *> *chapterListModels;
/// 书签列表
@property (nonatomic, strong) NSMutableArray<YLReadMarkModel *> *markModels;
/// 章节内容范围数组 [章节ID:[indexInChapterList:章节内容Range]]
@property (nonatomic, strong) NSMutableDictionary<NSString *,NSDictionary<NSString *,NSValue *> *> *ranges;
/// 本地小说全文
@property (nonatomic, strong) NSString *fullText;
/// 保存
- (void)save;

/// 是否存在阅读对象
+ (BOOL)isExistWithBookID:(NSString *)bookID;

/// 获取阅读对象,如果则创建对象返回
+ (YLReadModel *)modelWithBookID:(NSString *)bookID;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end




@interface YLReadModel (Mark)

/// 添加书签,默认使用当前阅读记录!
- (void)insetMark;
- (void)insetMarkWithRecordModel:(YLReadRecordModel *)recordModel;

/// 移除当前书签
- (BOOL)removeMark;
- (BOOL)removeMarkWithIndex:(NSInteger)index;

/// 移除当前书签
- (BOOL)removeMarkWithRecordModel:(YLReadRecordModel *)recordModel;

/// 是否存在书签
- (YLReadMarkModel *)isExistMark;
- (YLReadMarkModel *)isExistMarkWithRecordModel:(YLReadRecordModel *)recordModel;

@end




/// 总进度字符串 
FOUNDATION_EXPORT NSString *getReadToalProgressString(float progress);

/// 计算总进度
FOUNDATION_EXPORT float getReadToalProgress(YLReadModel *readModel,YLReadRecordModel *recordModel);


NS_ASSUME_NONNULL_END
