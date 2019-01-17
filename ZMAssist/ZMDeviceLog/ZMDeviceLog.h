//
//  ZMDeviceLog.h
//  ZMAssist
//
//  Created by Yuri Boyka on 2019/1/17.
//  Copyright © 2019 Yuri Boyka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZMLogConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMDeviceLog : NSObject
@property(nonatomic, strong) ZMLogConfig *config;
@end

NS_ASSUME_NONNULL_END
