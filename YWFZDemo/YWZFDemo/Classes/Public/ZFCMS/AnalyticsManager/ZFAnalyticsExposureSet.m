//
//  ZFAnalyticsExposureSet.m
//  ZZZZZ
//
//  Created by YW on 2019/6/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAnalyticsExposureSet.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@interface ZFAnalyticsExposureSet ()

@property (nonatomic, strong) NSMutableDictionary *listDic;

@end

@implementation ZFAnalyticsExposureSet

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZFAnalyticsExposureSet *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ZFAnalyticsExposureSet alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.listDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addObject:(NSString *)object analyticsId:(NSString *)idx
{
    if (ZFIsEmptyString(idx) || ZFIsEmptyString(object)) {
        YWLog(@"CMS组件统计有问题addObject:%@_object:%@",idx,object);
        return;
    }
    if (idx) {
        NSMutableArray *datasArray = [self.listDic objectForKey:idx];
        if (ZFJudgeNSArray(datasArray)) {
            [datasArray addObject:object];
        } else {
            datasArray = [[NSMutableArray alloc] init];
            [datasArray addObject:object];
            [self.listDic setObject:datasArray forKey:idx];
        }
    }
}

- (BOOL)containsObject:(NSString *)object analyticsId:(NSString *)idx
{
    if (ZFIsEmptyString(idx) || ZFIsEmptyString(object)) {
        YWLog(@"CMS组件统计有问题containsObject");
        return YES;
    }
    BOOL isConatins = NO;
    if (idx) {
        NSMutableArray *datasArray = [self.listDic objectForKey:idx];
        if (ZFJudgeNSArray(datasArray)) {
            isConatins = [datasArray containsObject:object];
        }
    }
    
    return isConatins;
}

- (void)removeObject:(NSString *)object analyticsId:(NSString *)idx
{
    if (ZFIsEmptyString(idx) || ZFIsEmptyString(object)) {
        YWLog(@"CMS组件统计有问题removeObject");
        return;
    }
    if (idx) {
        NSMutableArray *datasArray = [self.listDic objectForKey:idx];
        if (ZFJudgeNSArray(datasArray)) {
            [datasArray removeObject:object];
        }
    }
}

- (void)removeAllObjectsAnalyticsId:(NSString *)idx
{
    if (ZFIsEmptyString(idx)) {
        YWLog(@"CMS组件统计有问题 removeAll");
        return;
    }
    if (idx) {
        NSMutableArray *datasArray = [self.listDic objectForKey:idx];
        if (ZFJudgeNSArray(datasArray)) {
            [datasArray removeAllObjects];
        }
    }
}

- (void)removeAllObjects {
    if (ZFJudgeNSDictionary(self.listDic)) {
        [self.listDic removeAllObjects];
    }
}

- (NSMutableArray *)nativeThemeAnalyticsArray {
    if (!_nativeThemeAnalyticsArray) {
        _nativeThemeAnalyticsArray = [NSMutableArray array];
    }
    return _nativeThemeAnalyticsArray;
}

@end
