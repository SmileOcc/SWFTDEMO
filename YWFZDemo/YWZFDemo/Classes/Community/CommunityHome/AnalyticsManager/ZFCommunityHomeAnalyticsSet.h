//
//  ZFCommunityHomeAnalyticsSet.h
//  ZZZZZ
//
//  Created by YW on 2019/6/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityHomeAnalyticsSet : NSObject

+ (instancetype)sharedInstance;

- (void)addObject:(NSString *)object;

- (BOOL)containsObject:(NSString *)object;

- (void)removeObject:(NSString *)object;

- (void)removeAllObjects;

@end

NS_ASSUME_NONNULL_END
