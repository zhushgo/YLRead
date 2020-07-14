//
//  HTTPRequestSerializer.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/14.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 根据 RFC3986 规范进行编码后的字符串
 *
 * @Abstract 由于 URL 的字符串中某些字符可能引起歧义，需要对 URL 编码：
 *          URL 编码格式采用 ASCII 码，而不是 Unicode，这也就是说不能在 URL 中包含任何非ASCII字符，如中文 ；
 *          URL 编码原则就是使用安全的字符（没有特殊用途或者特殊意义的可打印字符）去表示那些不安全的字符。
 *
 * @need 哪些字符需要编码? RFC3986文档规定，URL 中只允许包含英文字母（a-zA-Z）、数字（0-9）、-_.~ 4个特殊字符以及下述保留字符：
 *  <ul>
 *     <li> 普通的分隔符 ":", "#", "[", "]", "@", "?", "/"
 *     <li> 子分隔符: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
 *  </ul>
 *
 * @param string 待编码请求参数，'?'和'/'可以不用编码，其他的都要进行编码。
 */
FOUNDATION_EXPORT NSString * YLReadPercentEscapedStringFromString(NSString *string);

/** 将 parameters 中的参数附加到 URL 末尾并编码
 * @case 如 @{@"name":@"zhangsan",@"age":20} 附加为 name=zhangsan&age=20
 */
FOUNDATION_EXPORT NSString * YLReadQueryStringFromParameters(NSDictionary *parameters);


@protocol HTTPRequestSerialization <NSObject, NSSecureCoding, NSCopying>

/** 将参数 parameters 编码到 NSURLRequest ，并返回副本
 * @param request 最初的 request 请求
 * @param parameters 待编码的参数
 * @param error 编码时遇到的错误
 */
- (nullable NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(nullable id)parameters
                                        error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NOTHROW;
@end


@interface HTTPRequestSerializer : NSObject

/** HTTP 请求头部信息 ，默认包含以下内容:
 *   <li> `Accept-Language` 包含NSLocale 的 +preferredLanguages 内容
 *   <li> `User-Agent` 带有各种 Bundle 标识符和 OS 名称的内容
 * @discussion 使用 -setValue:forHTTPHeaderField: 添加或删除默认的请求头字段
 */
@property (readonly, nonatomic, strong) NSDictionary <NSString *, NSString *> *HTTPRequestHeaders;

/** 将参数编码为字符串的HTTP方法，默认为 GET、HEAD 和 DELETE
 */
@property (nonatomic, strong) NSSet <NSString *> *HTTPMethodsEncodingParametersInURI;

/** 字符串编码格式，默认 NSUTF8StringEncoding
 */
@property (nonatomic, assign) NSStringEncoding stringEncoding;

/**  创建具有默认配置的序列化器
 */
+ (instancetype)serializer;



/** 使用指定的 HTTP 方法和 URL 字符串创建一个 NSMutableURLRequest 对象
 * @param method HTTP请求方法，如GET、POST、PUT 或DELETE，不能为 nil
 * @param URLString 用于请求的URL
 * @param parameters 可以附加到 URL 中，也可以设置在HTTP的 request body 中
 * @param error 创建请求时发生的错误。
 *
 * @note 如果HTTP方法是 GET、HEAD 或 DELETE ，parameters 将被附加到URL字符串后面。否则，parameters 将根据 parameterEncoding 属性的值进行编码，并设置为 request body
*/
- (nullable NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                          URLString:(NSString *)URLString
                                         parameters:(nullable id)parameters
                                              error:(NSError * _Nullable __autoreleasing *)error;


@end

NS_ASSUME_NONNULL_END
