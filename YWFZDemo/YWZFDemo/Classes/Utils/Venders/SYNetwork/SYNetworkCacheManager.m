//
//  SYNetworkCacheManager.m
//  SYNetwork
//
//  Created by YW on 16/5/28.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "SYNetworkCacheManager.h"
#import <YYWebImage/YYWebImage.h>

@interface SYNetworkCacheManager ()

@property (nonatomic, strong) YYCache *cache;

@end

@implementation SYNetworkCacheManager

+ (SYNetworkCacheManager *)sharedInstance {
    static SYNetworkCacheManager *instance;
    static dispatch_once_t SYNetworkCacheManagerToken;
    dispatch_once(&SYNetworkCacheManagerToken, ^{
        instance = [[SYNetworkCacheManager alloc] init];
    });
    return instance;
}

#pragma mark - Public method

- (id<NSCoding>)objectForKey:(NSString *)key {
    return [self.cache objectForKey:key];
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
    [self.cache setObject:object forKey:key];
}

- (void)removeObjectForKey:(NSString *)key {
    [self.cache removeObjectForKey:key];
}

- (void)clearCache {
    [self.cache removeAllObjects];
}

#pragma mark - Property method

- (YYCache *)cache {
    if (_cache == nil) {
        _cache = [YYCache cacheWithName:NSStringFromClass([self class])];
    }
    return _cache;
}

@end
