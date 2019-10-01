//
//  NSMutableDictionary+RHExtends.m
//  Pods
//
//  Created by zhuruhong on 2019/10/1.
//

#import "NSMutableDictionary+RHExtends.h"

@implementation NSDictionary (RHExtends)

- (NSString *)rh_stringForKey:(id)key
{
    id value = [self objectForKey:key];
    
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString *)value;
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    
    return nil;
}

- (NSString *)rh_stringForKey:(id)key defaultValue:(NSString *)defaultValue
{
    NSString *value = [self rh_stringForKey:key];
    return value ?: defaultValue;
}

- (NSNumber *)rh_numberForKey:(id)key
{
    id value = [self objectForKey:key];
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)value;
    }
    
    return nil;
}

- (NSString *)rh_JSONString
{
    NSString *jsonString = [self rh_JSONStringWithOptions:NSJSONWritingPrettyPrinted];
    return jsonString;
}

- (NSString *)rh_JSONStringWithOptions:(NSJSONWritingOptions)opt
{
    if (![NSJSONSerialization isValidJSONObject:self]) {
        return nil;
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:opt error:&error];
    if (jsonData == nil) {
#ifdef DEBUG
        NSLog(@"[Error] dictionary: %@, error: %@", self, error);
#endif
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end

@implementation NSMutableDictionary (RHExtends)

- (void)rh_setValue:(id)value forKey:(NSString *)key
{
    if (!key) {
        NSParameterAssert(key);
        return;
    }
    
    if (value != nil) {
        [self setValue:value forKey:key];
    }
}

- (void)rh_setValueEx:(id)aValue forKey:(NSString *)aKey
{
    if (!aKey) {
        NSParameterAssert(aKey);
        return;
    }
    
    if (aValue != nil) {
        [self setValue:aValue forKey:aKey];
    } else {
        [self removeObjectForKey:aKey];
    }
}

@end
