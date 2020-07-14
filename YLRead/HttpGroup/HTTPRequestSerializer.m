//
//  HTTPRequestSerializer.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/14.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "HTTPRequestSerializer.h"


NSString * YLReadPercentEscapedStringFromString(NSString *string) {
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";

    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];

    // FIXME: https://github.com/YLReadNetworking/YLReadNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];

    static NSUInteger const batchSize = 50;

    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;

    while (index < string.length) {
        NSUInteger length = MIN(string.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);

        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];

        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];

        index += range.length;
    }

    return escaped;
}


///全局方法指定了request请求序列化要观察的属性列表、是一个数组，里面有对蜂窝数据、缓存策略、cookie、管道、网络状态、超时这几个元素。
static NSArray * YLReadHTTPRequestSerializerObservedKeyPaths() {
    static NSArray *_AFHTTPRequestSerializerObservedKeyPaths = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _AFHTTPRequestSerializerObservedKeyPaths = @[NSStringFromSelector(@selector(allowsCellularAccess)), NSStringFromSelector(@selector(cachePolicy)), NSStringFromSelector(@selector(HTTPShouldHandleCookies)), NSStringFromSelector(@selector(HTTPShouldUsePipelining)), NSStringFromSelector(@selector(networkServiceType)), NSStringFromSelector(@selector(timeoutInterval))];
    });
    //就是一个数组里装了很多方法的名字,
    return _AFHTTPRequestSerializerObservedKeyPaths;
}



@interface YLReadQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (instancetype)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValue;
@end

@implementation YLReadQueryStringPair

- (instancetype)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.field = field;
    self.value = value;

    return self;
}

- (NSString *)URLEncodedStringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return YLReadPercentEscapedStringFromString([self.field description]);
    } else {
        return [NSString stringWithFormat:@"%@=%@", YLReadPercentEscapedStringFromString([self.field description]), YLReadPercentEscapedStringFromString([self.value description])];
    }
}

@end



NSArray * YLReadQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];

    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:YLReadQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:YLReadQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:YLReadQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[YLReadQueryStringPair alloc] initWithField:key value:value]];
    }

    return mutableQueryStringComponents;
}


NSArray * YLReadQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return YLReadQueryStringPairsFromKeyAndValue(nil, dictionary);
}

///从字典中查询字符串  @{@"name":@"zhangsan",@"age":20} ; name=zhangsan&age=20
NSString * YLReadQueryStringFromParameters(NSDictionary *parameters) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (YLReadQueryStringPair *pair in YLReadQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValue]];
    }
    return [mutablePairs componentsJoinedByString:@"&"];
}

@interface HTTPRequestSerializer ()
///某个request需要观察的属性集合
@property (readwrite, nonatomic, strong) NSMutableSet *mutableObservedChangedKeyPaths;

///存储request的请求头域
@property (readwrite, nonatomic, strong) NSMutableDictionary *mutableHTTPRequestHeaders;

///用于修改或者设置请求体域的dispatch_queue_t。
@property (readwrite, nonatomic, strong) dispatch_queue_t requestHeaderModificationQueue;
//@property (readwrite, nonatomic, assign) YLReadHTTPRequestQueryStringSerializationStyle queryStringSerializationStyle;
//
/////手动指定parameters参数序列化的Block
//@property (readwrite, nonatomic, copy) YLReadQueryStringSerializationBlock queryStringSerialization;
@end


@implementation HTTPRequestSerializer





- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                                     error:(NSError *__autoreleasing *)error{
    NSParameterAssert(method);//断言，debug模式下，如果缺少改参数，crash
    NSParameterAssert(URLString);

    NSURL *url = [NSURL URLWithString:URLString];

    NSParameterAssert(url);

    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    mutableRequest.HTTPMethod = method;//请求方法 GET POST

    //将request的各种属性循环遍历
    for (NSString *keyPath in YLReadHTTPRequestSerializerObservedKeyPaths()) {
        //如果自己观察到的发生变化的属性，在这些方法里
        if ([self.mutableObservedChangedKeyPaths containsObject:keyPath]) {
            //把给自己设置的属性给request设置
            [mutableRequest setValue:[self valueForKeyPath:keyPath] forKey:keyPath];
            /*
                keyPath : allowsCellularAccess  value : 1(是否允许蜂窝网)
                keyPath : cachePolicy           value : 0(缓存策略，基础缓存)
                keyPath : timeoutInterval       value : 15

                 keyPath : allowsCellularAccess  value : 0
                 keyPath : cachePolicy           value : 2
                (缓存策略，首先使用缓存，如果没有本地缓存，才从原地址下载)
                 keyPath : timeoutInterval       value : 15
             */
        }
    }
    //将传入的parameters进行编码，并添加到request中
    mutableRequest = [[self requestBySerializingRequest:mutableRequest withParameters:parameters error:error] mutableCopy];

    return mutableRequest;
}

#pragma mark - HTTPRequestSerialization


/* 协议方法
 这个方法做了3件事：
 1.从self.HTTPRequestHeaders中拿到设置的参数，赋值要请求的request里去
 2.把请求网络的参数，从array dic set这些容器类型转换为字符串，具体转码方式，我们可以使用自定义的方式，也可以用YLRead默认的转码方式
 3.紧接着这个方法还根据该request中请求类型，来判断参数字符串应该如何设置到request中去。如果是GET、HEAD、DELETE，则把参数quey是拼接到url后面的。而POST、PUT是把query拼接到http body中的:
 */
- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error{
    NSParameterAssert(request);

    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    //从自己的head里去遍历，如果有值则设置给request的head
    [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
        if (![request valueForHTTPHeaderField:field]) {
            [mutableRequest setValue:value forHTTPHeaderField:field];
            /*
             NSLog(@"field : %@ \n value : %@",field,value);
             field : Accept-Language   value : zh-Hans-CN;q=1
             field : Authorization     value : Basic MTM4MDAwMDAwMDA6YTEyMzQ1Njc=
             field : User-Agent  value : objective_c_language/1.0 (iPhone; iOS 10.3.3; Scale/2.00)
             */
        }
    }];

    NSString *query = YLReadQueryStringFromParameters(parameters);;//来把各种类型的参数，array dic set转化成字符串，给request

    //最后判断该request中是否包含了GET、HEAD、DELETE（都包含在HTTPMethodsEncodingParametersInURI）。因为这几个method的quey是拼接到url后面的。而POST、PUT是把query拼接到http body中的。

    if ([self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
        if (query && query.length > 0) {
            mutableRequest.URL = [NSURL URLWithString:[[mutableRequest.URL absoluteString] stringByAppendingFormat:mutableRequest.URL.query ? @"&%@" : @"?%@", query]];
        }
    } else {
        
         //post put请求
        // #2864: an empty string is a valid x-www-form-urlencoded payload
        if (!query) {
            query = @"";
        }
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            [mutableRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        }
        
        //设置请求体
        [mutableRequest setHTTPBody:[query dataUsingEncoding:self.stringEncoding]];
    }

    //至此，我们生成了一个request
    return mutableRequest;
}



// 返回请求头域key和vaue
- (NSDictionary *)HTTPRequestHeaders {
    NSDictionary __block *value;
    dispatch_sync(self.requestHeaderModificationQueue, ^{
        value = [NSDictionary dictionaryWithDictionary:self.mutableHTTPRequestHeaders];
    });
    return value;
}

@end
