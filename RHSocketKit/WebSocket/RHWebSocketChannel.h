//
//  RHWebSocketChannel.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/5/25.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

/*
 https://tools.ietf.org/html/rfc6455#section-5.2
 
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
 +-+-+-+-+-------+-+-------------+-------------------------------+
 |F|R|R|R| opcode|M| Payload len |    Extended payload length    |
 |I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
 |N|V|V|V|       |S|             |   (if payload len==126/127)   |
 | |1|2|3|       |K|             |                               |
 +-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
 |     Extended payload length continued, if payload len == 127  |
 + - - - - - - - - - - - - - - - +-------------------------------+
 |                               |Masking-key, if MASK set to 1  |
 +-------------------------------+-------------------------------+
 | Masking-key (continued)       |          Payload Data         |
 +-------------------------------- - - - - - - - - - - - - - - - +
 :                     Payload Data continued ...                :
 + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
 |                     Payload Data continued ...                |
 +---------------------------------------------------------------+
 */

@interface RHWebSocketChannel : NSObject <SRWebSocketDelegate>

@property (nonatomic, strong, readonly) SRWebSocket *webSocket;

/** ws://115.29.193.48:8088 */
@property (nonatomic, strong) NSString *urlString;

@property (nonatomic, weak) id<SRWebSocketDelegate> delegate;

- (instancetype)initWithURL:(NSString *)aURL;

- (void)openConnection;
- (void)closeConnection;
- (BOOL)isConnected;

@end
