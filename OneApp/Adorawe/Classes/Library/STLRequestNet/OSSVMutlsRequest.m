//
//  STLBatchRequest.m
//  STLRequestHeader
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMutlsRequest.h"
#import "OSSVMutlsRequestsManager.h"
#import "OSSVBasesRequests.h"
#import "OSSVRequestsUtils.h"

@interface OSSVMutlsRequest () <STLMutlRequestDelegate>

@property (nonatomic, strong) NSArray *requestArray;
@property (nonatomic, assign) NSInteger finishedRequestCount;

@end

@implementation OSSVMutlsRequest

#pragma mark - LifeCycle

- (instancetype)initWithRequestArray:(NSArray<OSSVBasesRequests *> *)requestArray enableAccessory:(BOOL)enableAccessory {
    self = [super init];
    if (self) {
        _requestArray = requestArray.copy;
        _enableAccessory = enableAccessory;
        _finishedRequestCount = 0;
    }
    return self;
}

- (void)dealloc {
    [self clearBatchRequest];
}

#pragma mark - SYBaseRequest Delegate

- (void)requestSuccess:(OSSVBasesRequests *)request {
    self.finishedRequestCount++;
    if (self.finishedRequestCount == self.requestArray.count) {
        if ([self.delegate respondsToSelector:@selector(batchRequestSuccess:)]) {
            [self.delegate batchRequestSuccess:self];
        }
        if (self.successCompletionBlock) {
            self.successCompletionBlock(self);
        }
        [self batchRequestDidStop];
    }
}

- (void)requestFailure:(OSSVBasesRequests *)request error:(NSError *)error {
    for (OSSVBasesRequests *reqeust in self.requestArray) {
        [reqeust stop];
    }
    if ([self.delegate respondsToSelector:@selector(batchRequestFailure:)]) {
        [self.delegate batchRequestFailure:self];
    }
    if (self.failureCompletionBlock) {
        self.failureCompletionBlock(self);
    }
    [self batchRequestDidStop];
}

#pragma mark - Public method

- (void)start {
    if (self.finishedRequestCount > 0) {
        STLRequestLog(@"Error! BatchRequest has already started.");
        return;
    }
    [self toggleAccessoriesStartCallBack];
    [[OSSVMutlsRequestsManager sharedInstance] addMutlRequest:self];
    for (OSSVBasesRequests *request in self.requestArray) {
        request.delegate = self;
        [request start];
    }
}

- (void)stop {
    [self clearBatchRequest];
    [self accessoriesStopCallBack];
    [[OSSVMutlsRequestsManager sharedInstance] removeBatchRequest:self];
}

- (void)startWithBlockSuccess:(void (^)(OSSVMutlsRequest *))success failure:(void (^)(OSSVMutlsRequest *))failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    [self start];
}

- (void)clearCompletionBlock {
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

#pragma mark - Property method

- (NSMutableArray<id<STLBaseRequestAccessory>> *)accessoryArray {
    if (_accessoryArray == nil) {
        _accessoryArray = [NSMutableArray array];
    }
    return _accessoryArray;
}

#pragma mark - Private method

- (void)batchRequestDidStop {
    [self clearCompletionBlock];
    [self accessoriesStopCallBack];
    self.finishedRequestCount = 0;
    self.requestArray = nil;
    [[OSSVMutlsRequestsManager sharedInstance] removeBatchRequest:self];
}

- (void)clearBatchRequest {
    self.delegate = nil;
    for (OSSVBasesRequests *request in self.requestArray) {
        [request stop];
    }
    [self clearCompletionBlock];
}

@end

@implementation OSSVMutlsRequest (RequestAccessory)

- (void)toggleAccessoriesStartCallBack {
    if (self.enableAccessory) {
        for (id<STLBaseRequestAccessory> accessory in self.accessoryArray) {
            if ([accessory respondsToSelector:@selector(requestStart:)]) {
                [accessory requestStart:self];
            }
        }
    }
}

- (void)accessoriesStopCallBack {
    if (self.enableAccessory) {
        for (id<STLBaseRequestAccessory> accessory in self.accessoryArray) {
            if ([accessory respondsToSelector:@selector(requestStop:)]) {
                [accessory requestStop:self];
            }
        }
    }
}

@end
