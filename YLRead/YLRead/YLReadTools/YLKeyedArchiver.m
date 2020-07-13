//
//  YLKeyedArchiver.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/2.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLKeyedArchiver.h"


NSString *filePath(NSString *folderName, NSString *fileName){
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Archiver"];
    NSString *path = [NSString stringWithFormat:@"%@/%@",filePath,folderName];
    //如果文件夹不存在，则创建
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path] == NO){
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSString stringWithFormat:@"%@/%@",path,fileName];;
}

@implementation YLKeyedArchiver

/// 归档文件
+ (void)archiverWithFolderName:(NSString *)folderName fileName:(NSString *)fileName object:(id)object{
    [NSKeyedArchiver archiveRootObject:object toFile:filePath(folderName, fileName)];
}

/// 解档文件
+ (id)unarchiverWithFolderName:(NSString *)folderName fileName:(NSString *)fileName{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath(folderName, fileName)];
}

/// 删除归档文件
+ (BOOL)removeWithFolderName:(NSString *)folderName fileName:(NSString *)fileName{
    return [NSFileManager.defaultManager removeItemAtPath:filePath(folderName, fileName) error:nil];
}
   
/// 清空归档文件
+ (BOOL)clear{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Archiver"];
    return [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
}
    
/// 是否存在归档文件
+ (BOOL)isExistWithFolderName:(NSString *)folderName fileName:(NSString *)fileName{
    return [NSFileManager.defaultManager fileExistsAtPath:filePath(folderName, fileName)];
}

@end
