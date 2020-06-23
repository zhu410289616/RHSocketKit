//
//  RHDownstreamBuffer.m
//  Example
//
//  Created by zhuruhong on 2019/9/8.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import "RHDownstreamBuffer.h"

@implementation RHDownstreamBuffer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataBuffer = [[NSMutableData alloc] init];
        _maxBufferSize = 8192;
    }
    return self;
}

- (void)appendReceiveData:(NSData *)receiveData
                   decode:(RHDownstreamBufferDecode)decodeCallback
                 overflow:(RHDownstreamBufferOverflow)overflowCallback
{
    if (receiveData.length == 0) {
        return;
    }
    
    if (nil == decodeCallback) {
#ifdef DEBUG
        NSAssert(YES, @"[Error]: downstream buffer decodeCallback is nil :(");
#endif
        return;
    }
    
    @synchronized (self) {
        [self.dataBuffer appendData:receiveData];
        
        NSInteger decodedLength = 0;
        if (decodeCallback) {
            decodedLength = decodeCallback(self.dataBuffer);
        }
        
        if (decodedLength > 0) {
            NSRange remainRange = NSMakeRange(decodedLength, self.dataBuffer.length - decodedLength);
            NSData *remainData = [self.dataBuffer subdataWithRange:remainRange];
            [self.dataBuffer setData:remainData];
        }
        
        if (overflowCallback && self.dataBuffer.length > self.maxBufferSize) {
            overflowCallback(self);
        }
    }
}

@end
