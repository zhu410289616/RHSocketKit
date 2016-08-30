//
//  RHSocketByteBuf.m
//  Example
//
//  Created by zhuruhong on 16/8/19.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketByteBuf.h"

@implementation RHSocketByteBuf

- (instancetype)init
{
    if (self = [super init]) {
        _buffer = [[NSMutableData alloc] init];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        _buffer = [[NSMutableData alloc] initWithData:data];
    }
    return self;
}

- (NSData *)data
{
    return _buffer;
}

- (NSUInteger)length
{
    return _buffer.length;
}

- (void)clear
{
    _buffer = [[NSMutableData alloc] init];
}

@end

@implementation RHSocketByteBuf (NSInteger)

- (void)writeInt8:(int8_t)param
{
    [_buffer appendBytes:&param length:1];
}

- (void)writeInt16:(int16_t)param
{
    [_buffer appendBytes:&param length:2];
}

- (void)writeInt32:(int32_t)param
{
    [_buffer appendBytes:&param length:4];
}

- (void)writeInt64:(int64_t)param
{
    [_buffer appendBytes:&param length:8];
}

- (int8_t)readInt8:(NSUInteger)index
{
    NSAssert(index + 1 <= _buffer.length, @"index > _buffer.length");
    
    int8_t val = 0;
    [_buffer getBytes:&val range:NSMakeRange(index, 1)];
    return val;
}

- (int16_t)readInt16:(NSUInteger)index
{
    NSAssert(index + 2 <= _buffer.length, @"index > _buffer.length");
    
    int16_t val = 0;
    [_buffer getBytes:&val range:NSMakeRange(index, 2)];
    return val;
}

- (int32_t)readInt32:(NSUInteger)index
{
    NSAssert(index + 4 <= _buffer.length, @"index > _buffer.length");
    
    int32_t val = 0;
    [_buffer getBytes:&val range:NSMakeRange(index, 4)];
    return val;
}

- (int64_t)readInt64:(NSUInteger)index
{
    NSAssert(index + 8 <= _buffer.length, @"index > _buffer.length");
    
    int64_t val = 0;
    [_buffer getBytes:&val range:NSMakeRange(index, 8)];
    return val;
}

@end

@implementation RHSocketByteBuf (NSData)

- (void)writeData:(NSData *)param
{
    if (param.length == 0) {
        return;
    }
    [_buffer appendData:param];
}

- (NSData *)readData:(NSUInteger)index length:(NSUInteger)length
{
    NSAssert(index + length <= _buffer.length, @"index > _buffer.length");
    
    NSRange range = NSMakeRange(index, length);
    NSData *temp = [_buffer subdataWithRange:range];
    return temp;
}

@end

@implementation RHSocketByteBuf (NSString)

- (void)writeString:(NSString *)param
{
    if (param.length == 0) {
        return;
    }
    [_buffer appendBytes:param.UTF8String length:param.length];
}

- (NSString *)readString:(NSUInteger)index length:(NSUInteger)length
{
    NSAssert(index + length <= _buffer.length, @"index > _buffer.length");
    
    NSData *tempData = [self readData:index length:length];
    NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
    return tempStr;
}

@end