//
//  RHChannelReconnect.m
//  Pods
//
//  Created by zhuruhong on 2019/9/10.
//

#import "RHChannelReconnect.h"
#import "RHSocketMacros.h"

@interface RHChannelReconnect ()

/** 自动重连使用的计时器 */
@property (nonatomic, strong) NSTimer *connectTimer;
/** 尝试重连次数 */
@property (nonatomic, assign) NSInteger connectCount;

@end

@implementation RHChannelReconnect

- (instancetype)init
{
    self = [super init];
    if (self) {
        _interval = 15;
        _maxConnectCount = 100;
    }
    return self;
}

- (void)start
{
    _isOver = NO;
    [self startConnectTimer:_interval];
}

- (void)stop
{
    [self stopConnectTimer];
    _isOver = YES;
    RHSocketBlockRun(_overBlock, self);
}


#pragma mark -

- (void)stopConnectTimer
{
    if (_connectTimer) {
        [_connectTimer invalidate];
        _connectTimer = nil;
    }
}

- (void)startConnectTimer:(NSTimeInterval)interval
{
    [self stopConnectTimer];
    
    _connectTimer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(doConnectTimerFunction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_connectTimer forMode:NSRunLoopCommonModes];
}

- (void)doConnectTimerFunction
{
    if (_isOver || _connectCount > _maxConnectCount) {
        [self stopConnectTimer];
        return;
    }
    
    RHSocketBlockRun(_connectBlock, self);
    _connectCount++;
}

@end
