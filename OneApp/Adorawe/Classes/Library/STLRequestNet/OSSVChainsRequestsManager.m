//
//  OSSVChainsRequestsManager.m
//  STLRequestHeader
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVChainsRequestsManager.h"
#import "OSSVChainsRequest.h"

@interface OSSVChainsRequestsManager ()

@property (nonatomic, strong) NSMutableArray *requestArray;

@end

@implementation OSSVChainsRequestsManager

+ (OSSVChainsRequestsManager *)sharedInstance {
    static OSSVChainsRequestsManager *instance;
    static dispatch_once_t SYChainRequestManagerToken;
    dispatch_once(&SYChainRequestManagerToken, ^{
        instance = [[OSSVChainsRequestsManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
    }
    return self;
}

- (void)addChainRequest:(OSSVChainsRequest *)chainRequest {
    @synchronized (self) {
        [self.requestArray addObject:chainRequest];
    }
}

- (void)removeChainRequest:(OSSVChainsRequest *)chainRequest {
    @synchronized (self) {
        [self.requestArray removeObject:chainRequest];
    }
}

@end
