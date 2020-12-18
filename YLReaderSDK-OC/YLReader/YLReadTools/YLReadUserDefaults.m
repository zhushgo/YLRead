//
//  YLReadUserDefaults.m
//  YLRead
//
//  Created by 苏沫离 on 2017/5/7.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import "YLReadUserDefaults.h"

NSString *const kYLRead_Save_Configure = @"kYLRead_Save_Configure";
NSString *const kYLRead_Save_Day_Night = @"kYLRead_Save_Day_Night";
@implementation YLReadUserDefaults

/// 清空
+ (void)clear{
    NSDictionary *dictionary = NSUserDefaults.standardUserDefaults.dictionaryRepresentation;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:key];
    }];
    [NSUserDefaults.standardUserDefaults  synchronize];
}

/// 删除
+ (void)removeWithKey:(NSString *)key{
    [NSUserDefaults.standardUserDefaults removeObjectForKey:key];
    [NSUserDefaults.standardUserDefaults  synchronize];
}

/// 存储Object
+ (void)setObjectWithKey:(NSString *)key object:(id)value{
    [NSUserDefaults.standardUserDefaults setObject:value forKey:key];
    [NSUserDefaults.standardUserDefaults  synchronize];
}

/// 获取Object
+ (id)getObjectWithKey:(NSString *)key{
    return [NSUserDefaults.standardUserDefaults objectForKey:key];
}

/// 存储String
+ (void)setObjectWithKey:(NSString *)key string:(NSString *)value{
    [NSUserDefaults.standardUserDefaults setObject:value forKey:key];
    [NSUserDefaults.standardUserDefaults  synchronize];
}

+ (NSString *)getStringWithKey:(NSString *)key{
    return [NSUserDefaults.standardUserDefaults objectForKey:key];
}

/// 存储NSInteger
+ (void)setObjectWithKey:(NSString *)key integer:(NSInteger)value{
    [NSUserDefaults.standardUserDefaults setObject:@(value) forKey:key];
    [NSUserDefaults.standardUserDefaults  synchronize];
}

+ (NSInteger)getIntegerWithKey:(NSString *)key{
    return [[NSUserDefaults.standardUserDefaults objectForKey:key] integerValue];
}


/// 存储Bool
+ (void)setObjectWithKey:(NSString *)key boo:(BOOL)value{
    [NSUserDefaults.standardUserDefaults setObject:@(value) forKey:key];
    [NSUserDefaults.standardUserDefaults  synchronize];
}

+ (BOOL)getBoolWithKey:(NSString *)key{
    return [[NSUserDefaults.standardUserDefaults objectForKey:key] boolValue];
}

/// 存储Float
+ (void)setObjectWithKey:(NSString *)key floa:(float)value{
    [NSUserDefaults.standardUserDefaults setObject:@(value) forKey:key];
    [NSUserDefaults.standardUserDefaults  synchronize];
}

+ (float)getFloatWithKey:(NSString *)key{
    return [[NSUserDefaults.standardUserDefaults objectForKey:key] floatValue];
}

/// 存储Double
+ (void)setObjectWithKey:(NSString *)key doubl:(double)value{
    [NSUserDefaults.standardUserDefaults setObject:@(value) forKey:key];
    [NSUserDefaults.standardUserDefaults  synchronize];
}

+ (double)getDoubleWithKey:(NSString *)key{
    return [[NSUserDefaults.standardUserDefaults objectForKey:key] doubleValue];
}

/// 存储TimeInterval
+ (void)setObjectWithKey:(NSString *)key timeInterval:(NSTimeInterval)value{
    [NSUserDefaults.standardUserDefaults setObject:@(value) forKey:key];
    [NSUserDefaults.standardUserDefaults  synchronize];
}

+ (NSTimeInterval)getTimeIntervalWithKey:(NSString *)key{
    return [[NSUserDefaults.standardUserDefaults objectForKey:key] doubleValue];
}

/// 存储url
+ (void)setObjectWithKey:(NSString *)key url:(NSURL *)url{
    [NSUserDefaults.standardUserDefaults setObject:url forKey:key];
    [NSUserDefaults.standardUserDefaults  synchronize];
}

+ (NSURL *)getURLWithKey:(NSString *)key{
    return [NSUserDefaults.standardUserDefaults objectForKey:key];
}

@end

