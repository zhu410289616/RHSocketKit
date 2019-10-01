//
//  NSMutableDictionary+RHExtends.h
//  Pods
//
//  Created by zhuruhong on 2019/10/1.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (RHExtends)

- (NSString *)rh_stringForKey:(id)key;
- (NSString *)rh_stringForKey:(id)key defaultValue:(NSString *)defaultValue;
- (NSNumber *)rh_numberForKey:(id)key;

- (NSString *)rh_JSONString;
- (NSString *)rh_JSONStringWithOptions:(NSJSONWritingOptions)opt;

@end

@interface NSMutableDictionary (RHExtends)

/** 安全使用value */
- (void)rh_setValue:(id)value forKey:(NSString *)key;
/** 在aValue为nil时，删除原来的key */
- (void)rh_setValueEx:(id)aValue forKey:(NSString *)aKey;

@end

//NS_ASSUME_NONNULL_END
