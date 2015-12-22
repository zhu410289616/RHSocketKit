//
//  ViewController.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/7/4.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "ViewController.h"
#import "RHSocketChannel.h"

#import "RHSocketDelimiterCodec.h"

#import "RHSocketVariableLengthCodec.h"

#import "RHSocketHttpCodec.h"
#import "RHPacketHttpRequest.h"

#import "RHSocketConfig.h"

//
#import "RHSocketService.h"

//
#import "RHSocketChannelProxy.h"
#import "RHConnectCallReply.h"

@interface ViewController () <RHSocketChannelDelegate, RHSocketReplyProtocol>
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
    
    host = @"127.0.0.1";
    port = 7878;
//    RHSocketDelimiterCodec *codec = [[RHSocketDelimiterCodec alloc] init];
//    codec.delimiter = 10;
    
    RHSocketVariableLengthCodec *codec = [[RHSocketVariableLengthCodec alloc] init];
    
//    RHSocketHttpCodec *codec = [[RHSocketHttpCodec alloc] init];
    
    _channel = [[RHSocketChannel alloc] initWithHost:host port:port];
    _channel.delegate = self;
    _channel.codec = codec;
//    [_channel openConnection];
    
//    [RHSocketService sharedInstance].codec = [[RHSocketHttpCodec alloc] init];
//    [[RHSocketService sharedInstance] startServiceWithHost:host port:port];
    
    RHConnectCallReply *connect = [[RHConnectCallReply alloc] init];
    connect.delegate = self;
    [RHSocketChannelProxy sharedInstance].codec = codec;
    [[RHSocketChannelProxy sharedInstance] asyncConnect:connect];
    
}

- (void)onSuccess:(id<RHSocketCallReplyProtocol>)aCallReply response:(id<RHDownstreamPacket>)response
{
    RHPacketRequest *req = [[RHPacketRequest alloc] init];
    NSMutableData *tempData = [NSMutableData dataWithData:[@"123456" dataUsingEncoding:NSUTF8StringEncoding]];
    uint8_t delimiter = 10;
    [tempData appendBytes:&delimiter length:1];
    req.data = tempData;
    
    RHSocketCallReply *callReply = [[RHSocketCallReply alloc] init];
    callReply.request = req;
    
    [[RHSocketChannelProxy sharedInstance] asyncCallReply:callReply];
}

- (void)onFailure:(id<RHSocketCallReplyProtocol>)aCallReply error:(NSError *)error
{}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RHSocketChannelDelegate

- (void)channelOpened:(RHSocketChannel *)channel host:(NSString *)host port:(int)port
{
    RHSocketLog(@"channelOpened: %@:%d", host, port);
    
    RHPacketRequest *req = [[RHPacketRequest alloc] init];
//    req.data = [@"RHPacketRequest" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *tempData = [NSMutableData dataWithData:[@"123456" dataUsingEncoding:NSUTF8StringEncoding]];
    uint8_t delimiter = 10;
    [tempData appendBytes:&delimiter length:1];
    req.data = tempData;
    
//    RHPacketHttpRequest *req = [[RHPacketHttpRequest alloc] init];
    
    [channel asyncSendPacket:req];
}

- (void)channelClosed:(RHSocketChannel *)channel error:(NSError *)error
{
    RHSocketLog(@"channelClosed: %@", error.description);
}

- (void)channel:(RHSocketChannel *)channel received:(id<RHDownstreamPacket>)packet
{
    RHSocketLog(@"received: %ld", [packet data].length);
    
    NSData *body = [[packet data] subdataWithRange:NSMakeRange(2, [packet data].length - 2)];
    RHSocketLog(@"received: %@", [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]);
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
