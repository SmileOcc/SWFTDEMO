//
//  ZFAnalyticsOperation.m
//  ZZZZZ
//
//  Created by YW on 2019/6/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAnalyticsOperation.h"
#import "Constants.h"
#import "YWLocalHostManager.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>

typedef void(^operationBlock)(void);
@interface ZFAnalyticsOperation ()

@property (nonatomic, copy) operationBlock analyticsBlock;

@end

@implementation ZFAnalyticsOperation

- (void)dealloc
{
    YWLog(@"ZFAnalyticsOperation dealloc");
}

- (instancetype)initAnalyticsOperation
{
    self = [super init];
    
    if (self) {
        self.analyticsList = [[NSMutableArray alloc] init];
        [self addExecutionBlock:self.analyticsBlock];
    }
    
    return self;
}

- (operationBlock)analyticsBlock
{
    @weakify(self)
    return ^{
        //执行代码
        @strongify(self)
        [self.analyticsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *uploadValue = (NSDictionary *)obj;
                NSString *key = uploadValue.allKeys.firstObject;
                NSDictionary *value = uploadValue.allValues.firstObject;
                //YWLog(@"AppsFlyerTracker eventName=%@ \n value=%@", key, value);
                //YWLog(@"[NSThread currentThread] = %@", [NSThread currentThread]);
                if ([YWLocalHostManager isDistributionOnlineRelease]) {
                    [[AppsFlyerTracker sharedTracker] trackEvent:key withValues:value];
                }
            }
        }];
        [self.analyticsList removeAllObjects];
        if (self.doneBlock) {
            self.doneBlock();
        }
    };
}

@end
