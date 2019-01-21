//
//  ZMDeviceLog.h
//  ZMAssist
//
//  Created by Yuri Boyka on 2019/1/17.
//  Copyright © 2019 Yuri Boyka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZMLogConfig.h"
#import <asl.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZMLogMessage : NSObject
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, copy) NSString *sender;
@property (nonatomic, copy) NSString *messageText;
@property (nonatomic, assign) long long messageID;
@end

@interface ZMDeviceLog : NSObject
@property(nonatomic, strong) ZMLogConfig *config;
+ (ZMDeviceLog *)sharedInstance;
- (void)start;
@end

NS_ASSUME_NONNULL_END
