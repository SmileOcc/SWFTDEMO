//
//  ZFCommunityHomeAnalyticsSet.m
//  ZZZZZ
//
//  Created by YW on 2019/6/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeAnalyticsSet.h"

@interface ZFCommunityHomeAnalyticsSet ()

@property (nonatomic, strong) NSMutableArray *list;

@end

@implementation ZFCommunityHomeAnalyticsSet

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZFCommunityHomeAnalyticsSet *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ZFCommunityHomeAnalyticsSet alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.list = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addObject:(NSString *)object
{
    [self.list addObject:object];
}

- (BOOL)containsObject:(NSString *)object
{
    return [self.list containsObject:object];
}

- (void)removeObject:(NSString *)object
{
    [self.list removeObject:object];
}

- (void)removeAllObjects
{
    [self.list removeAllObjects];
}

@end
