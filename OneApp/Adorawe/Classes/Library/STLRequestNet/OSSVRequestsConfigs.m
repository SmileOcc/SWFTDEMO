//
//  OSSVRequestsConfigs.m
//  OSSVRequestsConfigs
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVRequestsConfigs.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation OSSVRequestsConfigs

#pragma mark - LifeCycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxConcurrentOperationCount = 4;
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    }
    return self;
}

+ (OSSVRequestsConfigs *)sharedInstance {
    static OSSVRequestsConfigs *instance;
    static dispatch_once_t STLConfigToken;
    dispatch_once(&STLConfigToken, ^{
        instance = [[OSSVRequestsConfigs alloc] init];
    });
    return instance;
}

@end
