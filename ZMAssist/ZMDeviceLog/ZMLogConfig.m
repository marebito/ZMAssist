//
//  ZMLogConfig.m
//  ZMAssist
//
//  Created by Yuri Boyka on 2019/1/17.
//  Copyright © 2019 Yuri Boyka. All rights reserved.
//

#import "ZMLogConfig.h"

@implementation ZMLogConfig

- (void)setLogFilePath:(NSString *)logFilePath
{
    _logFilePath = logFilePath;
    _lastLogPath = _logFilePath;
}

@end
