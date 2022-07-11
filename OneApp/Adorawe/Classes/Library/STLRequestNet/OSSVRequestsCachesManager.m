//
//  OSSVRequestsCachesManager.m
//  OSSVRequestsCachesManager
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVRequestsCachesManager.h"

@interface OSSVRequestsCachesManager ()

@end

@implementation OSSVRequestsCachesManager

+ (OSSVRequestsCachesManager *)sharedInstance {
    static OSSVRequestsCachesManager *instance;
    static dispatch_once_t STLCacheManagerToken;
    dispatch_once(&STLCacheManagerToken, ^{
        instance = [[OSSVRequestsCachesManager alloc] init];
    });
    return instance;
}

- (id<NSCoding>)objectForKey:(NSString *)key {
    return [self.cache objectForKey:key];
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
    if (object && !STLIsEmptyString(key)) {    
        [self.cache setObject:object forKey:key];
    }
}

- (void)removeObjectForKey:(NSString *)key {
    [self.cache removeObjectForKey:key];
}

- (void)clearCache {
    [self.cache removeAllObjects];
}

- (YYCache *)cache {
    if (_cache == nil) {
        _cache = [YYCache cacheWithName:NSStringFromClass([self class])];
    }
    return _cache;
}

@end
