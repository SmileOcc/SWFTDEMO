//
//  ZFTimerManager.m
//  WZHLibrary
//
//  Created by YW on 2017/5/16.
//  Copyright © 2017年 karl.luo. All rights reserved.
//

#import "ZFTimerManager.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

NSString * const kTimerManagerUpdate = @"kTimerManagerUpdate";
static ZFTimerManager *_timerManager = nil;

@implementation ZFTimerModel
@end

@interface ZFTimerManager ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableDictionary *timerModelDict;
@property (nonatomic, assign) NSTimeInterval timeInterval; // 倒计时执行次数
@property (nonatomic, assign) NSTimeInterval appBackgroundStartTime; // app 开始后台运行的时间戳
@property (nonatomic, assign) NSInteger appBackgroundTimeInterval;   // app 在后台运行的时间
@end

@implementation ZFTimerManager

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _timerManager = [super allocWithZone:zone];
        [_timerManager initData];
    });
    return _timerManager;
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _timerManager = [[self alloc] init];
        [_timerManager initData];
    });
    return _timerManager;
}

- (id)copyWithZone:(NSZone *)zone {
    return _timerManager;
}

/**
 * 初始化数据
 */
- (void)initData {
    [_timerManager setTimeInterval:0];
    _timerManager.duration = 1.0;
    _timerManager.appBackgroundTimeInterval = 0;
    _timerManager.timerModelDict = [NSMutableDictionary new];
}

- (void)startTimer:(NSString *)operaterKey {
    if (ZFIsEmptyString(operaterKey)) {
        return;
    }
    [self stopTimer:operaterKey];
    
    ZFTimerModel *timerModel = [[ZFTimerModel alloc] init];
    timerModel.startTimeInterval = self.timeInterval;
    [self.timerModelDict setObject:timerModel forKey:operaterKey];
    
    if (!self.timer) {
        self.timer  = [NSTimer scheduledTimerWithTimeInterval:self.duration
                                                   target:self
                                                 selector:@selector(remainTimeAction)
                                                 userInfo:nil
                                                  repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self addNotification];
    }
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundopen) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundstop) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)backgroundopen {
    self.appBackgroundStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)backgroundstop {
    NSTimeInterval appBackgroundFinishedTime = [[NSDate date] timeIntervalSince1970];
    self.appBackgroundTimeInterval = appBackgroundFinishedTime - self.appBackgroundStartTime;
}

- (void)stopTimer:(NSString *)operaterKey {
    if (!operaterKey) {
        return;
    }
    [self.timerModelDict removeObjectForKey:operaterKey];
    if (self.timerModelDict.count <= 0) {
        self.timeInterval = 0;
        [self.timer invalidate];
        self.timer = nil;
        [self removeNotification];
    }
}

- (void)remainTimeAction {
    self.timeInterval++;
    [[NSNotificationCenter defaultCenter] postNotificationName:kTimerManagerUpdate object:nil];
//    YWLog(@"定时器任务=====%f", self.timeInterval);
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    _timeInterval   = timeInterval;
}

- (NSTimeInterval)timeInterval:(NSString *)operaterKey {
    ZFTimerModel *timerModel       = [self.timerModelDict objectForKey:operaterKey];
    self.timeInterval              = self.timeInterval + self.appBackgroundTimeInterval;
    NSTimeInterval downCountTime   = self.timeInterval - timerModel.startTimeInterval;
    //YWLog(@"####### %ld %f", self.appBackgroundTimeInterval, downCountTime);
    self.appBackgroundTimeInterval = 0;
    return downCountTime;
}

@end
