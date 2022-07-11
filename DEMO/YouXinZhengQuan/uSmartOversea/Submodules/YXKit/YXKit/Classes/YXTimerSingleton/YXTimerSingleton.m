//
//  YXTimerSingleton.m
//  YouXinZhengQuan
//
//  Created by ellison on 2018/11/9.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXTimerSingleton.h"

@interface YXTimerItem : NSObject
@property (nonatomic, copy) YXTimeOperaion operation;
@property (nonatomic, assign) NSInteger interval;
@property (nonatomic, assign) NSInteger repeatTimes;
@property (nonatomic, assign) NSInteger remainTimes;
@property (nonatomic, assign) NSInteger beginTimes;
@property (nonatomic, assign) BOOL pause;
@end

@implementation YXTimerItem
@end

@interface YXTimerSingleton ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableDictionary *timerPool;
@property (nonatomic, strong) NSMutableArray *invalidTimerFlags;
@property (nonatomic, assign) NSInteger runTimes;

@property (nonatomic, assign) BOOL isBackground;

@end

@implementation YXTimerSingleton

static YXTimerFlag flag = 0;

+ (instancetype)shareInstance {
    static YXTimerSingleton *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[self alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.runTimes = 0;
        self.isBackground = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterForground) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)handleEnterBackground {
    self.isBackground = YES;
}

- (void)handleEnterForground {
    self.isBackground = NO;
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

- (YXTimerFlag)transactOperation:(YXTimeOperaion)operation
                    timeInterval:(NSTimeInterval)interval
                     repeatTimes:(NSInteger)times
                          atOnce:(BOOL)atOnce {
    
    flag++;
    NSInteger remainTimes = times;
    if (atOnce) {
        operation(flag);
        remainTimes--;
    }
    
    YXTimerItem *item = [[YXTimerItem alloc] init];
    item.operation = operation;
    item.interval = interval;
    item.repeatTimes = times;
    item.remainTimes = remainTimes;
    item.pause = self.isBackground;
    item.beginTimes = self.runTimes;
    item.pause = NO;
    
    YXTimerFlag beginFlag = flag;
    
    @synchronized(self.timerPool) {
        [self.timerPool setObject: item forKey: @(beginFlag)];
    }
    
    if (!self.timer.isValid) {
        [self.timer fire];
    }
    return beginFlag;
}

- (void)invalidOperationWithFlag:(YXTimerFlag)flag {
    @synchronized(self.timerPool) {
        [self.timerPool removeObjectForKey: @(flag)];
    }
}

- (void)pauseOperationWithFlag:(YXTimerFlag)flag {
    YXTimerItem *item = [self.timerPool objectForKey:@(flag)];
    item.pause = YES;
}

- (void)resumeOperationWithFlag:(YXTimerFlag)flag {
    YXTimerItem *item = [self.timerPool objectForKey:@(flag)];
    item.pause = NO;
}

- (void)handleSingletonTimer:(NSTimer *)timer {
    self.runTimes++;
    
    @synchronized(self.timerPool) {
        [self.timerPool.allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            YXTimerItem *item = [self.timerPool objectForKey: obj];
            if (item) {
                if ((self.runTimes - item.beginTimes) % item.interval == 0 && item.pause == NO && self.isBackground == NO && item.remainTimes > 0) {
                    flag++;
                    
                    item.operation(flag);
                    item.remainTimes--;
                }
                
                if (item.remainTimes < 1) {
                    [self.invalidTimerFlags addObject: obj];
                }
            }
        }];
        
        [self.timerPool removeObjectsForKeys: self.invalidTimerFlags];
    }
    [self.invalidTimerFlags removeAllObjects];
}

- (NSMutableDictionary *)timerPool {
    if (!_timerPool) {
        _timerPool = [NSMutableDictionary dictionary];
    }
    return _timerPool;
}

- (NSMutableArray *)invalidTimerFlags {
    if (!_invalidTimerFlags) {
        _invalidTimerFlags = [NSMutableArray array];
    }
    return _invalidTimerFlags;
}

- (NSTimer *)timer
{
    if (!_timer || ![_timer isValid]) {
        _timer = [NSTimer timerWithTimeInterval: 1
                                         target: self
                                       selector: @selector(handleSingletonTimer:)
                                       userInfo: nil
                                        repeats: YES];
        //避免影响滑动事件，Mode设置为Default
        [[NSRunLoop mainRunLoop] addTimer: _timer
                                  forMode: NSDefaultRunLoopMode];
    }
    return _timer;
}

- (void)invalidate {
    [self.timerPool removeAllObjects];
    [self.invalidTimerFlags removeAllObjects];
    [_timer invalidate];
}

@end
