//
//  OSSVRequestsCachesManager.h
//  OSSVRequestsCachesManager
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVRequestsCachesManager : NSObject

@property (nonatomic, strong) YYCache *cache;


+ (OSSVRequestsCachesManager *)sharedInstance;

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key;
- (id<NSCoding>)objectForKey:(NSString *)key;

- (void)clearCache;
- (void)removeObjectForKey:(NSString *)key;

@end
