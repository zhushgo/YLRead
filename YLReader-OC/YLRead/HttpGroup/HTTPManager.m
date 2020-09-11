//
//  HTTPManager.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/14.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "HTTPManager.h"
#import "HTTPSessionDelegate.h"

NSString * const YLReadNetworkingTaskDidCompleteResponseSerializerKey = @"com.netTask.complete.responseserializer";
static NSString * const YLReadNSURLSessionTaskDidResumeNotification  = @"com.netTask.resume";
static NSString * const YLReadNSURLSessionTaskDidSuspendNotification = @"com.netTask.suspend";
//任务开始的通知
NSString * const YLReadNetworkingTaskDidResumeNotification = @"com.networking.task.resume";
//任务完成的通知
NSString * const YLReadNetworkingTaskDidCompleteNotification = @"com.networking.task.complete";
//任务暂停的通知
NSString * const YLReadNetworkingTaskDidSuspendNotification = @"com.networking.task.suspend";

@interface HTTPManager ()
<NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDataDelegate>

@property (readwrite, nonatomic, strong) NSOperationQueue *sessionQueue;
@property (readwrite, nonatomic, strong) NSURLSession *session;
@property (readwrite, nonatomic, strong) NSLock *lock;

//用来让每一个请求task和我们自定义的代理来建立映射用的，对task的代理进行了一个封装，并且转发代理到自定义的代理
@property (readwrite, nonatomic, strong) NSMutableDictionary *mutableTaskDelegatesKeyedByTaskIdentifier;
@end



@implementation HTTPManager

+ (HTTPManager *)shareManager{
    static HTTPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HTTPManager alloc] init];
        manager.sessionQueue = [[NSOperationQueue alloc] init];
    });
    return manager;
}

- (NSURLSession *)session {
    @synchronized (self) {
        if (!_session) {
            _session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration delegate:self delegateQueue:self.sessionQueue];
        }
    }
    return _session;
}

#pragma mark - public method

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method URLString:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary <NSString *, NSString *> *)headers uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure{
    
    NSError *serializationError = nil;
    
    
    /********* 1、创建并配置 NSMutableURLRequest  *********/
    //把参数，还有各种东西转化为一个request
    NSParameterAssert(method);//断言，debug模式下，如果缺少改参数，crash
    NSParameterAssert(URLString);
    NSURL *url = [NSURL URLWithString:URLString];
    NSParameterAssert(url);
    
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    mutableRequest.HTTPMethod = method;//请求方法 GET POST
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString] absoluteString] parameters:parameters error:&serializationError];
    for (NSString *headerField in headers.keyEnumerator) {//设置请求头信息
        [request setValue:headers[headerField] forHTTPHeaderField:headerField];
    }
    if (serializationError) {
        if (failure) {//如果解析错误，直接返回
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
        }
        return nil;
    }
    
    /********* 2、通过 NSMutableURLRequest 实例创建一个任务 NSURLSessionDataTask   *********/
    __block NSURLSessionDataTask *dataTask = nil;
//    dataTask = [self dataTaskWithRequest:request uploadProgress:uploadProgress downloadProgress:downloadProgress
//                       completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
//        if (error) {
//            if (failure) {
//                failure(dataTask, error);
//            }
//        } else {
//            if (success) {
//                success(dataTask, responseObject);
//            }
//        }
//    }];
    return dataTask;
}

#pragma mark - Private method

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler {

    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    [self addDelegateForDataTask:dataTask uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:completionHandler];
    return dataTask; //到这里我们整个对task的处理就完成了。
}

/** 总结一下:
1）这个方法，生成了一个YLReadURLSessionManagerTaskDelegate,这个其实就是YLRead的自定义代理。我们请求传来的参数，都赋值给这个YLRead的代理了。
2）delegate.manager = self;代理把YLReadURLSessionManager这个类作为属性了,我们可以看到：
   @property (nonatomic, weak) YLReadURLSessionManager *manager;
   这个属性是弱引用的，所以不会存在循环引用的问题。
3）我们调用了[self setDelegate:delegate forTask:dataTask];
*/
- (void)addDelegateForDataTask:(NSURLSessionDataTask *)dataTask
                uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
              downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
             completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler{
    
    HTTPSessionDelegate *delegate = [[HTTPSessionDelegate alloc] initWithTask:dataTask];
    delegate.manager = self;// YLReadURLSessionManagerTaskDelegate与YLReadURLSessionManager建立相互关系
    delegate.completionHandler = completionHandler;

    //这个taskDescriptionForSessionTasks用来发送开始和挂起通知的时候会用到,就是用这个值来 Post 通知，来两者对应
    //任务描述：值为 session 的内存地址
    dataTask.taskDescription = self.taskDescriptionForSessionTasks;
    [self setDelegate:delegate forTask:dataTask]; /** 将 YLRead代理和task建立映射 */
    
    // 设置YLRead delegate的上传进度，下载进度块。
    delegate.uploadProgressBlock = uploadProgressBlock;
    delegate.downloadProgressBlock = downloadProgressBlock;
}

- (NSString *)taskDescriptionForSessionTasks {
    return [NSString stringWithFormat:@"%p", self];
}

/** 将 代理和task建立映射 */
- (void)setDelegate:(HTTPSessionDelegate *)delegate forTask:(NSURLSessionTask *)task{
    NSParameterAssert(task);
    NSParameterAssert(delegate);
    [self.lock lock];
    //taskIdentifier 由所属会话分配且唯一的任务标识符，
    self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)] = delegate;
    [self addNotificationObserverForTask:task];//添加task开始和暂停的通知
    [self.lock unlock];
}


///网络任务 监听 启动 和 暂停
- (void)addNotificationObserverForTask:(NSURLSessionTask *)task {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidResume:) name:YLReadNSURLSessionTaskDidResumeNotification object:task];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidSuspend:) name:YLReadNSURLSessionTaskDidSuspendNotification object:task];
}

- (void)removeNotificationObserverForTask:(NSURLSessionTask *)task {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YLReadNSURLSessionTaskDidSuspendNotification object:task];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YLReadNSURLSessionTaskDidResumeNotification object:task];
}

- (void)taskDidResume:(NSNotification *)notification {
    NSURLSessionTask *task = notification.object;
    if ([task respondsToSelector:@selector(taskDescription)]) {
        if ([task.taskDescription isEqualToString:self.taskDescriptionForSessionTasks]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:YLReadNetworkingTaskDidResumeNotification object:task];
            });
        }
    }
}

- (void)taskDidSuspend:(NSNotification *)notification {
    NSURLSessionTask *task = notification.object;
    if ([task respondsToSelector:@selector(taskDescription)]) {
        if ([task.taskDescription isEqualToString:self.taskDescriptionForSessionTasks]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:YLReadNetworkingTaskDidSuspendNotification object:task];
            });
        }
    }
}

#pragma mark - NSURLSessionDelegate

//当对 session 对象执行了 invalidate 的相关方法后，会调用此代理方法。之后 session 会释放对代理对象的强引用。
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error{
    NSLog(@"%s \n%@ ",__func__,[NSThread currentThread]);
}


//当在 SSL 握手阶段，如果服务器要求验证客户端身份或向客户端提供其证书用于验证时，则会调用 此代理方法
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    NSLog(@"%s \n%@ ",__func__,[NSThread currentThread]);

    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling; // 相当于未执行代理方法，使用默认的处理方式，不使用参数 credential
    
    __block NSURLCredential *credential = nil;
    
    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    
    if (credential) {
        disposition = NSURLSessionAuthChallengeUseCredential;// 指明通过另一个参数 credential 提供证书
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }

}


#pragma mark - NSURLSessionTaskDelegate

/*
 客户端告知服务器端需要HTTP重定向。不现在此代理：默认是按重定向。
 此方法只会在default session或者ephemeral session中调用，而在background session中，session task会自动重定向。
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
    NSLog(@"%s \n%@ ",__func__,[NSThread currentThread]);
    completionHandler(request);//必须完成重定向
}

/* 证书处理
 *
 任务已收到请求特定身份验证的挑战。
 如果不实现此代理，将返回默认挑战类型
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    NSLog(@"%s \n%@ ",__func__,[NSThread currentThread]);

    //挑战处理类型为 默认
    /*
     NSURLSessionAuthChallengePerformDefaultHandling：默认方式处理
     NSURLSessionAuthChallengeUseCredential：使用指定的证书
     NSURLSessionAuthChallengeCancelAuthenticationChallenge：取消挑战
     */
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    
    if (credential) {
        disposition = NSURLSessionAuthChallengeUseCredential;
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

//请求完成(成功|失败)的时候会调用该方法，如果请求失败，则error有值
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    NSLog(@"%s \n%@ ",__func__,[NSThread currentThread]);
}


#pragma mark - NSURLSessionDataDelegate

// 1. 接受到服务器的响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"%s \n%@ ",__func__,[NSThread currentThread]);

    // 必须设置对响应进行允许处理才会执行后面两个操作。
    completionHandler(NSURLSessionResponseAllow);
}

// 2. 接收到服务器的数据（可能调用多次）
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    NSLog(@"%s \n%@ \n %@",__func__,[NSThread currentThread],object);
}


@end
