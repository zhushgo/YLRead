//
//  HTTPResponseSerialization.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/14.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HTTPResponseSerializationDelegate <NSObject, NSSecureCoding, NSCopying>

/** 将待解析的响应数据解码为一个对象
 *
 * @param response 待处理的响应
 * @param data 待解析的响应数据。
 * @param error 解码响应数据时遇到的错误
 * @return 解析得到的对象
 */
- (nullable id)responseObjectForResponse:(nullable NSURLResponse *)response
                           data:(nullable NSData *)data
                          error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NOTHROW;

@end

@interface HTTPResponseSerialization : NSObject

@end

NS_ASSUME_NONNULL_END
