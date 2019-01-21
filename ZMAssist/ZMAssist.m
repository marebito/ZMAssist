//
//  ZMAssist.m
//  ZMAssist
//
//  Created by Yuri Boyka on 2019/1/17.
//  Copyright © 2019 Yuri Boyka. All rights reserved.
//

#import "ZMAssist.h"
#import "GCDAsyncSocket.h"

@interface ZMAssist ()
{
    dispatch_queue_t _sock_server_queue;
    GCDAsyncSocket *_serverSocket;
    NSMutableDictionary *currentPacketHead;
}
@end

@implementation ZMAssist

@end
