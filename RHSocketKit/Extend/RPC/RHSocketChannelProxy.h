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

@interface RHSocketChannelProxy : NSObject

@property (nonatomic, strong, readonly) RHSocketChannel *channel;
@property (nonatomic, strong) id<RHSocketCodecProtocol> codec;
@property (nonatomic, strong, readonly) RHSocketCallReplyManager *callReplyManager;

+ (instancetype)sharedInstance;

- (void)asyncConnect:(RHConnectCallReply *)aCallReply;
- (void)disconnect;

- (void)asyncCallReply:(id<RHSocketCallReplyProtocol>)aCallReply;
- (void)asyncNotify:(id<RHSocketCallReplyProtocol>)aCallReply;

@end
