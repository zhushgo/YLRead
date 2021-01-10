//
//  YLKeyedArchiver.h
//  YLRead
//
//  Created by 苏沫离 on 2017/5/2.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YLKeyedArchiver : NSObject

/// 归档文件
+ (void)archiverWithFolderName:(NSString *)folderName fileName:(NSString *)fileName object:(id)object;

/// 解档文件
+ (id)unarchiverWithFolderName:(NSString *)folderName fileName:(NSString *)fileName;

/// 删除归档文件
+ (BOOL)removeWithFolderName:(NSString *)folderName fileName:(NSString *)fileName;

/// 清空归档文件
+ (BOOL)clear;

/// 是否存在归档文件
+ (BOOL)isExistWithFolderName:(NSString *)folderName fileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
