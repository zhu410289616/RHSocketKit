//
//  RHSocketDelimiterDecoder.m
//  RHToolkit
//
//  Created by zhuruhong on 15/6/30.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketDelimiterDecoder.h"
#import "RHPacketFrame.h"

@interface RHSocketDelimiterDecoder ()
{
    NSMutableData *_receiveData;
}

@end

@implementation RHSocketDelimiterDecoder

- (instancetype)init
{
    if (self = [super init]) {
        _maxFrameSize = 8192;
        _delimiter = 0xff;
    }
    return self;
}

- (NSUInteger)decodeData:(NSData *)data decoderOutput:(id<RHSocketDecoderOutputDelegate>)output tag:(long)tag
{
    @synchronized(self) {
        if (_receiveData) {
            [_receiveData appendData:data];
        } else {
            _receiveData = [NSMutableData dataWithData:data];
        }
        
        NSUInteger dataLen = _receiveData.length;
        NSUInteger headIndex = 0;
        
        for (NSUInteger i=0; i<dataLen; i++) {
            NSAssert(i < _maxFrameSize, @"Decode data is too long ...");
            uint8_t byte;
            [_receiveData getBytes:&byte range:NSMakeRange(i, 1)];
            if (byte == _delimiter) {
                NSInteger frameLen = i - headIndex;
                NSData *frameData = [_receiveData subdataWithRange:NSMakeRange(headIndex, frameLen)];
                RHPacketFrame *frame = [[RHPacketFrame alloc] initWithData:frameData];
                [output didDecode:frame tag:tag];
                headIndex = i + 1;
            }
        }
        
        NSData *remainData = [_receiveData subdataWithRange:NSMakeRange(headIndex, dataLen-headIndex)];
        [_receiveData setData:remainData];
        
        return _receiveData.length;
    }//@synchronized
}

@end
