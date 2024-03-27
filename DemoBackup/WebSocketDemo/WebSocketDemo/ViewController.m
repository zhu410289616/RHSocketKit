//
//  ViewController.m
//  WebSocketDemo
//
//  Created by zhuruhong on 16/6/6.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "ViewController.h"

#import "RHWebSocketChannel.h"

@interface ViewController () <SRWebSocketDelegate>

@property (nonatomic, strong) RHWebSocketChannel *webSocketChannel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //
    _webSocketChannel = [[RHWebSocketChannel alloc] initWithURL:@"ws://115.29.193.48:8088"];
    _webSocketChannel.delegate = self;
    [_webSocketChannel openConnection];
}

#pragma mark - SRWebSocketDelegate

// message will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"Received: %@", message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"Websocket Connected ...");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@":( Websocket Failed With Error %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"WebSocket closed: code-[%ld], reason-[%@]", code, reason);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    NSLog(@"Websocket received pong");
}

@end
