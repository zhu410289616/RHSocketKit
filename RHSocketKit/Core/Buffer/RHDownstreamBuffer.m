//
//  RHDownstreamBuffer.m
//  Example
//
//  Created by zhuruhong on 2019/9/8.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import "RHDownstreamBuffer.h"

@interface RHDownstreamBuffer ()

@property (nonatomic, strong) NSMutableData *dataBuffer;

@end

@implementation RHDownstreamBuffer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataBuffer = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)appendReceiveData:(NSData *)receiveData
{
    if (receiveData.length == 0) {
        return;
    }
    
    NSAssert(_delegate, @"[Error]: RHDownstreamBuffer delegate is nil");
    
    @synchronized (self) {
        [_dataBuffer appendData:receiveData];
        
        NSInteger decodedLength = [_delegate dataWillDecode:_dataBuffer];
        if (decodedLength > 0) {
            NSRange remainRange = NSMakeRange(decodedLength, _dataBuffer.length - decodedLength);
            NSData *remainData = [_dataBuffer subdataWithRange:remainRange];
            [_dataBuffer setData:remainData];
            
            if ([_delegate respondsToSelector:@selector(dataDidDecode:)]) {
                [_delegate dataDidDecode:_dataBuffer.length];
            }
        }
        
        if (_dataBuffer.length > _maxBufferSize) {
            [_delegate bufferOverflow:_dataBuffer];
        }
    }
}

@end
