//
//  ZMDeviceLog.m
//  ZMAssist
//
//  Created by Yuri Boyka on 2019/1/17.
//  Copyright © 2019 Yuri Boyka. All rights reserved.
//

#import "ZMDeviceLog.h"
#import <UIKit/UIKit.h>
#import <SDAutoLayout/SDAutoLayout.h>
#import "SWDance.h"

#define ZM_TIMESTAMP (long long)[[NSDate date] timeIntervalSince1970] * 1000
#define ZM_LOG_ROOT_PATH [ZMDeviceLog logCachePath]
#define DeviceLogCachePrefix @"com.zmlog"
#define APPDELEGATE [[UIApplication sharedApplication] delegate]

                               static ZMDeviceLog *_deviceLog;

@interface ZMDeviceLog ()
{
    UITextView *_logView;
}
@end

@implementation ZMDeviceLog

+ (ZMDeviceLog *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceLog = [ZMDeviceLog new];
    });
    return _deviceLog;
}

- (id)init
{
    if (self = [super init])
    {
        [self initialSetup];
    }
    return self;
}

- (void)initialSetup
{
    [self startLog];
    [self addGestureRecogniser];
}

- (void)startLog
{
    [NSFileManager.defaultManager removeItemAtPath:_config.logFilePath error:nil];
    freopen([_config.logFilePath fileSystemRepresentation], "a", stderr);
}

- (void)addGestureRecogniser
{
    UISwipeGestureRecognizer *recogniser =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showConsole)];
    [recogniser setDirection:UISwipeGestureRecognizerDirectionRight];
    [APPDELEGATE.window addGestureRecognizer:recogniser];
}

+ (NSString *)logCachePath { return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]; }
+ (NSString *)logFilePath
{
    NSDate *now = [NSDate date];
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [fmt stringFromDate:now];
    NSString *logParentDir = [ZM_LOG_ROOT_PATH
        stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.%@", DeviceLogCachePrefix,
                                                                  [dateString substringWithRange:NSMakeRange(0, 10)]]];
    NSString *logDir =
        [NSString stringWithFormat:@"%@/%@", logParentDir, [dateString substringWithRange:NSMakeRange(11, 2)]];
    [[NSFileManager defaultManager] createDirectoryAtPath:logDir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:logDir isDirectory:&isDir])
    {
        if (isDir)
        {
            NSString *logFileName = [dateString substringWithRange:NSMakeRange(14, 5)];
            NSString *logFilePath = [NSString stringWithFormat:@"%@/%@", logDir, logFileName];
            return logFilePath;
        }
        else
        {
            NSLog(@"文件夹出现异常");
        }
    }
    return nil;
}

- (ZMLogConfig *)defaultConfig
{
    ZMLogConfig *config = [ZMLogConfig new];
    config.logFilePath = [ZMDeviceLog logFilePath];
    config.autoClear = NO;
    config.clearCycle = ZMLogClearCycleDisable;
    return config;
}

- (ZMLogConfig *)config
{
    if (!_config)
    {
        _config = [self defaultConfig];
    }
    return _config;
}

- (void)showConsole
{
    if (_logView == nil)
    {
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGRect viewRectTextView = CGRectMake(30, bounds.size.height - bounds.size.height / 3 - 60,
                                             bounds.size.width - 30, bounds.size.height / 3);

        _logView = [[UITextView alloc] initWithFrame:viewRectTextView];
        [_logView setBackgroundColor:[UIColor blackColor]];
        [_logView setFont:[UIFont systemFontOfSize:10]];
        [_logView setEditable:NO];
        [_logView setTextColor:[UIColor whiteColor]];
        [[_logView layer] setOpacity:0.6];

        [APPDELEGATE.window addSubview:_logView];
        [APPDELEGATE.window bringSubviewToFront:_logView];

        UISwipeGestureRecognizer *recogniser =
            [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideWithAnimation)];
        [recogniser setDirection:UISwipeGestureRecognizerDirectionLeft];
        [_logView addGestureRecognizer:recogniser];

        [self moveThisViewTowardsLeftToRight:_logView duration:0.30];
        [self setUpToGetLogData];
        [self scrollToLast];
    }
}
- (void)hideWithAnimation
{
    [self moveThisViewTowardsLeft:_logView duration:0.30];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self hideConsole];
    });
}
- (void)hideConsole
{
    [_logView removeFromSuperview];
    [NSNotificationCenter.defaultCenter removeObserver:self];
    _logView = nil;
}
- (void)scrollToLast
{
    NSRange txtOutputRange;
    txtOutputRange.location = _logView.text.length;
    txtOutputRange.length = 0;
    _logView.editable = YES;
    [_logView scrollRangeToVisible:txtOutputRange];
    [_logView setSelectedRange:txtOutputRange];
    _logView.editable = NO;
}
- (void)setUpToGetLogData
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:_config.logFilePath];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(getData:)
                                               name:@"NSFileHandleReadCompletionNotification"
                                             object:fileHandle];
    [fileHandle readInBackgroundAndNotify];
}

- (void)getData:(NSNotification *)notification
{
    NSData *data = notification.userInfo[NSFileHandleNotificationDataItem];
    if (data.length)
    {
        NSString *string = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
        _logView.editable = YES;
        _logView.text = [_logView.text stringByAppendingString:string];
        _logView.editable = NO;
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self scrollToLast];
        });
        [notification.object readInBackgroundAndNotify];
    }
    else
    {
        [self performSelector:@selector(refreshLog:) withObject:notification afterDelay:1.0];
    }
}
- (void)refreshLog:(NSNotification *)notification { [notification.object readInBackgroundAndNotify]; }
- (void)moveThisViewTowardsLeft:(UIView *)view duration:(float)dur;
{
    [UIView animateWithDuration:dur
        animations:^{
            [view setFrame:CGRectMake(view.frame.origin.x - [[UIScreen mainScreen] bounds].size.width,
                                      view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
        }
        completion:^(BOOL finished){
        }];
}
- (void)moveThisViewTowardsLeftToRight:(UIView *)view duration:(float)dur;
{
    CGRect original = [view frame];
    [view setFrame:CGRectMake(view.frame.origin.x - [[UIScreen mainScreen] bounds].size.width, view.frame.origin.y,
                              view.frame.size.width, view.frame.size.height)];
    [UIView animateWithDuration:dur
        animations:^{
            [view setFrame:original];
        }
        completion:^(BOOL finished){
        }];
}

- (void)start
{
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [ZMDeviceLog logFilePath];
    });
}

@end
