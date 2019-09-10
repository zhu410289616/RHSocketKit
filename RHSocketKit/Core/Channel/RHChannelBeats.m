//
//  RHChannelBeats.m
//  Pods
//
//  Created by zhuruhong on 2019/9/10.
//

#import "RHChannelBeats.h"
#import "RHSocketMacros.h"

@interface RHChannelBeats ()

@property (nonatomic, strong) NSTimer *beatsTimer;

@end

@implementation RHChannelBeats

- (instancetype)init
{
    self = [super init];
    if (self) {
        _interval = 20;
    }
    return self;
}

- (void)start
{
    _isOver = NO;
    [self startBeatsTimerWithInterval:_interval];
}

- (void)stop
{
    [self stopBeatsTimer];
    _isOver = YES;
    RHSocketBlockRun(_overBlock, self);
}

#pragma mark - beats timer

- (void)stopBeatsTimer
{
    if (_beatsTimer) {
        [_beatsTimer invalidate];
        _beatsTimer = nil;
    }
}

- (void)startBeatsTimerWithInterval:(double)interval
{
    [self stopBeatsTimer];
    
    _beatsTimer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(doBeatsTimerFunction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_beatsTimer forMode:NSRunLoopCommonModes];
}

- (void)doBeatsTimerFunction
{
    if (_isOver) {
        [self stopBeatsTimer];
        return;
    }
    RHSocketBlockRun(_beatBlock, self);
}

@end
