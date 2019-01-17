//
//  ZMLogConfig.h
//  ZMAssist
//
//  Created by Yuri Boyka on 2019/1/17.
//  Copyright © 2019 Yuri Boyka. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 日志清除周期

 - ZMLogClearCycleDisable: 禁止清除
 - ZMLogClearCycleDay: 每天清除
 - ZMLogClearCycleWeek: 每周清除
 - ZMLogClearCycleMonth: 每月清除
 */
typedef NS_ENUM(NSUInteger, ZMLogClearCycle) {
    ZMLogClearCycleDisable = 0,
    ZMLogClearCycleDay,
    ZMLogClearCycleWeek,
    ZMLogClearCycleYear,
};

@interface ZMLogConfig : NSObject
@property(nonatomic, copy) NSString *logFilePath;            // 日志文件路径
@property(nonatomic, copy, readonly) NSString *lastLogPath;  // 上次日志路径
@property(nonatomic, assign) BOOL autoClear;                 // 自动清除日志
@property(nonatomic, assign) ZMLogClearCycle clearCycle;     // 清除周期(默认每天清除)
@end

NS_ASSUME_NONNULL_END
