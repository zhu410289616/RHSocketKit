//
//  ViewController.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/7/4.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "ViewController.h"
#import "RHSocketChannel.h"

#import "RHSocketHttpCodec.h"
#import "RHPacketHttpRequest.h"

#import "RHSocketConfig.h"

#import "RHSocketService.h"

@interface ViewController () <RHSocketChannelDelegate>
{
    RHSocketChannel *_channel;
}

@end

@implementation ViewController

- (void)loadView
{
    [super loadView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectSocketServiceState:) name:kNotificationSocketServiceState object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *host = @"www.baidu.com";
    int port = 80;
    
    _channel = [[RHSocketChannel alloc] initWithHost:host port:port];
    _channel.delegate = self;
    _channel.codec = [[RHSocketHttpCodec alloc] init];
//    [_channel openConnection];
    
    [RHSocketService sharedInstance].codec = [[RHSocketHttpCodec alloc] init];
    [[RHSocketService sharedInstance] startServiceWithHost:host port:port];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RHSocketChannelDelegate

- (void)channelOpened:(RHSocketChannel *)channel host:(NSString *)host port:(int)port
{
    RHSocketLog(@"channelOpened: %@:%d", host, port);
    
    RHPacketHttpRequest *req = [[RHPacketHttpRequest alloc] init];
    [channel asyncSendPacket:req];
}

- (void)channelClosed:(RHSocketChannel *)channel error:(NSError *)error
{
    RHSocketLog(@"channelClosed: %@", error.description);
}

- (void)channel:(RHSocketChannel *)channel received:(id<RHDownstreamPacket>)packet
{
    RHSocketLog(@"received: %ld", [packet data].length);
}

#pragma mark - notification

- (void)detectSocketServiceState:(NSNotification *)notif
{
    NSLog(@"detectSocketServiceState: %@", notif);
    
    id state = notif.object;
    if (state && [state boolValue]) {
        RHPacketHttpRequest *req = [[RHPacketHttpRequest alloc] init];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
    } else {
        //
    }//if
}

@end
