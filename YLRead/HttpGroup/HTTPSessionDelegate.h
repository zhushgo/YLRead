//
//  HTTPSessionDelegate.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/14.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSURL *_Nonnull(^YLReadURLSessionDownloadTaskDidFinishDownloadingBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location);
typedef void (^YLReadURLSessionDownloadTaskDidWriteDataBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void (^YLReadURLSessionDownloadTaskDidResumeBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes);
typedef void (^YLReadURLSessionTaskProgressBlock)(NSProgress *);

typedef void (^YLReadURLSessionTaskCompletionHandler)(NSURLResponse *response, id responseObject, NSError *error);



@class HTTPManager;
@interface HTTPSessionDelegate : NSObject

- (instancetype)initWithTask:(NSURLSessionTask *)task;
@property (nonatomic, weak) HTTPManager *manager;//弱引用
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSProgress *uploadProgress;//上传进度
@property (nonatomic, strong) NSProgress *downloadProgress;//下载进度
@property (nonatomic, copy) NSURL *downloadFileURL;//下载文件地址
@property (nonatomic, strong) NSURLSessionTaskMetrics *sessionTaskMetrics;
@property (nonatomic, copy) YLReadURLSessionDownloadTaskDidFinishDownloadingBlock downloadTaskDidFinishDownloading;
@property (nonatomic, copy) YLReadURLSessionTaskProgressBlock uploadProgressBlock;
@property (nonatomic, copy) YLReadURLSessionTaskProgressBlock downloadProgressBlock;
@property (nonatomic, copy) YLReadURLSessionTaskCompletionHandler completionHandler;

@end

NS_ASSUME_NONNULL_END
