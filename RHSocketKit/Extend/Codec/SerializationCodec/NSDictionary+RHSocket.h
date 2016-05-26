//
//  NSDictionary+RHSocket.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/23.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (RHSocket)

/**
 *  json的二进制数据NSData通过NSJSONSerialization转换为NSDictionary
 *
 *  @param jsonData json的二进制数据NSData
 *
 *  @return NSDictionary，失败时返回nil
 */
+ (NSDictionary *)dictionaryWithJsonData:(NSData *)jsonData;

/**
 *  json的字符串数据NSString通过NSJSONSerialization转换为NSDictionary
 *
 *  @param jsonString json的字符串数据NSString
 *
 *  @return NSDictionary，失败时返回nil
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end
