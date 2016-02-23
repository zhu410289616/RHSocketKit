//
//  RHSocketChannelProxy.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/21.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketChannel.h"
#import "RHSocketCodecProtocol.h"
#import "RHSocketCallReplyManager.h"
#import "RHConnectCallReply.h"

@interface RHSocketChannelProxy : NSObject <RHSocketChannelDelegate>

@property (nonatomic, strong, readonly) RHSocketChannel *channel;

@property (nonatomic, strong) id<RHSocketEncoderProtocol> encoder;
@property (nonatomic, strong) id<RHSocketDecoderProtocol> decoder;

@property (nonatomic, strong, readonly) RHSocketCallReplyManager *callReplyManager;

@property (nonatomic, strong, readonly) RHConnectCallReply *connectCallReply;

+ (instancetype)sharedInstance;

/**
 *  异步连接服务器
 *
 *  @param aCallReply 实现RHSocketCallReplyProtocol协议对象
 */
- (void)asyncConnect:(RHConnectCallReply *)aCallReply;

/**
 *  断开连接
 */
- (void)disconnect;

/**
 *  发送数据给服务端，并等待服务端返回数据
 *
 *  @param aCallReply 实现RHSocketCallReplyProtocol协议对象
 */
- (void)asyncCallReply:(id<RHSocketCallReplyProtocol>)aCallReply;

/**
 *  只发送数据给服务端，不等待服务端返回
 *
 *  @param aCallReply 实现RHSocketCallReplyProtocol协议对象
 */
- (void)asyncNotify:(id<RHSocketCallReplyProtocol>)aCallReply;

@end
