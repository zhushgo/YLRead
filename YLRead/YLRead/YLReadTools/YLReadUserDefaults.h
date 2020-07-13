//
//  YLReadUserDefaults.h
//  YLRead
//
//  Created by 苏沫离 on 2020/7/7.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Key - 配置
FOUNDATION_EXPORT NSString *const kYLRead_Save_Configure;
/// Key - 日夜间模式 NO:日间 YES:夜间
FOUNDATION_EXPORT NSString *const kYLRead_Save_Day_Night;



@interface YLReadUserDefaults : NSObject

/// 清空
+ (void)clear;
/// 删除
+ (void)removeWithKey:(NSString *)key;

/// 存储Object
+ (void)setObjectWithKey:(NSString *)key object:(id)value;
+ (id)getObjectWithKey:(NSString *)key;

/// 存储String
+ (void)setObjectWithKey:(NSString *)key string:(NSString *)value;
+ (NSString *)getStringWithKey:(NSString *)key;

/// 存储NSInteger
+ (void)setObjectWithKey:(NSString *)key integer:(NSInteger)value;
+ (NSInteger)getIntegerWithKey:(NSString *)key;


/// 存储Bool
+ (void)setObjectWithKey:(NSString *)key boo:(BOOL)value;
+ (BOOL)getBoolWithKey:(NSString *)key;

/// 存储Float
+ (void)setObjectWithKey:(NSString *)key floa:(float)value;
+ (float)getFloatWithKey:(NSString *)key;

/// 存储Double
+ (void)setObjectWithKey:(NSString *)key doubl:(double)value;
+ (double)getDoubleWithKey:(NSString *)key;

/// 存储TimeInterval
+ (void)setObjectWithKey:(NSString *)key timeInterval:(NSTimeInterval)value;
+ (NSTimeInterval)getTimeIntervalWithKey:(NSString *)key;

/// 存储url
+ (void)setObjectWithKey:(NSString *)key url:(NSURL *)url;
+ (NSURL *)getURLWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
