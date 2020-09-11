//
//  HTTPManager.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/14.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPRequestSerializer.h"
#import "HTTPResponseSerialization.h"
NS_ASSUME_NONNULL_BEGIN

/** 任务关联的响应序列化器
 */
FOUNDATION_EXPORT NSString * const YLReadNetworkingTaskDidCompleteResponseSerializerKey;

FOUNDATION_EXPORT NSString * const YLReadNetworkingTaskDidCompleteNotification;



@interface HTTPManager : NSObject
@property (readonly, nonatomic ,strong) NSOperationQueue *sessionQueue;
@property (readonly, nonatomic, strong) NSURLSession *session;
@property (class, readonly, strong) HTTPManager *shareManager;

/** 工具类：用于将请求参数序列化，不能为 nil。
 * 默认配置的实例，它会将 GET 、HEAD 和 DELETE 请求的查询字符串参数序列化，或者以其他url形式对HTTP消息体进行编码。
 */
@property (nonatomic, strong) HTTPRequestSerializer <HTTPRequestSerialization> *requestSerializer;

/** 工具类：将从服务器接收到的 GET/POST 请求的响应数据序列化，不能为 nil。
 */
@property (nonatomic, strong) id <HTTPResponseSerializationDelegate> responseSerializer;

/** 请求完成后的回调队列，默认为 NULL，在主线程处理；
 * 如果请求到的数据还需要在分线程解析，可以设置该队列，解析完成后自己回到主队列去刷新UI！
 */
@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;



- (nullable NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
       URLString:(NSString *)URLString
      parameters:(nullable id)parameters
         headers:(nullable NSDictionary <NSString *, NSString *> *)headers
  uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
         success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
         failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
