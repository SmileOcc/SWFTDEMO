//
//  OSSVMutlsRequestsManager.m
//  STLRequestHeader
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMutlsRequestsManager.h"

@interface OSSVMutlsRequestsManager ()

@property (nonatomic, strong) NSMutableArray *requestArray;

@end

@implementation OSSVMutlsRequestsManager

#pragma mark - LifeCycle

+ (OSSVMutlsRequestsManager *)sharedInstance {
    static OSSVMutlsRequestsManager *instance;
    static dispatch_once_t STLMutlRequestManagerToken;
    dispatch_once(&STLMutlRequestManagerToken, ^{
        instance = [[OSSVMutlsRequestsManager alloc] init];
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

- (void)addMutlRequest:(OSSVMutlsRequest *)batchRequest {
    @synchronized (self) {
        [_requestArray addObject:batchRequest];
    }
}

- (void)removeBatchRequest:(OSSVMutlsRequest *)batchRequest {
    @synchronized (self) {
        [_requestArray removeObject:batchRequest];
    }
}

@end
