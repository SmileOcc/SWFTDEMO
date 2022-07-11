//
//  OSSVChainsRequest.m
//  STLRequestHeader
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVChainsRequest.h"
#import "OSSVChainsRequestsManager.h"
#import "OSSVBasesRequests.h"
#import "OSSVRequestsUtils.h"

@interface OSSVChainsRequest () <STLBaseRequestDelegate>

@property (nonatomic, strong) NSMutableArray *requestArray;
@property (nonatomic, strong) NSMutableArray *requestCallbackArray;
@property (nonatomic, assign) NSUInteger nextRequestIndex;

@end

@implementation OSSVChainsRequest

#pragma mark - LifeCycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
        _requestCallbackArray = [NSMutableArray array];
        _nextRequestIndex = 0;
    }
    return self;
}

- (instancetype)initWithEnableAccessory:(BOOL)enableAccessory {
    self = [self init];
    if (self) {
        _enableAccessory = enableAccessory;
    }
    return self;
}

- (void)dealloc {
    [self clearChainRequest];
}

#pragma mark - SYBaseRequest Delegate

- (void)requestSuccess:(OSSVBasesRequests *)request {
    NSUInteger currentRequestIndex = self.nextRequestIndex - 1;
    SYChainRequestCallback callback = self.requestCallbackArray[currentRequestIndex];
    callback(self, request);
    if ([self startNextRequest] == NO) {
        [self accessoriesStopCallBack];
        if ([self.delegate respondsToSelector:@selector(chainRequestSuccess:)]) {
            [self.delegate chainRequestSuccess:self];
        }
        [self chainRequestDidStop];
    }
}

- (void)requestFailure:(OSSVBasesRequests *)request error:(NSError *)error {
    [self accessoriesStopCallBack];
    if ([self.delegate respondsToSelector:@selector(chainRequest:failure:)]) {
        [self.delegate chainRequest:self failure:request];
    }
    [self chainRequestDidStop];
}

#pragma mark - Public method

- (void)addRequest:(OSSVBasesRequests *)request callback:(SYChainRequestCallback)callback {
    [self.requestArray addObject:request];
    if (callback) {
        [self.requestCallbackArray addObject:callback];
    } else {
        [self.requestCallbackArray addObject:^(OSSVChainsRequest *chainRequest, OSSVBasesRequests *request) {}];
    }
}

- (void)start {
    if (self.nextRequestIndex > 0) {
        STLRequestLog(@"Error! BatchRequest has already started.");
        return;
    }
    if (self.requestArray.count > 0) {
        [self toggleAccessoriesStartCallBack];
        [self startNextRequest];
        [[OSSVChainsRequestsManager sharedInstance] addChainRequest:self];
    } else {
        STLRequestLog(@"Error! Chain request array is empty.");
    }
}

- (void)stop {
    [self clearChainRequest];
    [self accessoriesStopCallBack];
    [[OSSVChainsRequestsManager sharedInstance] removeChainRequest:self];
}

#pragma mark - Private method

- (BOOL)startNextRequest {
    if (self.nextRequestIndex < self.requestArray.count) {
        OSSVBasesRequests *request = self.requestArray[self.nextRequestIndex];
        self.nextRequestIndex++;
        request.delegate = self;
        [request start];
        return YES;
    } else {
        return NO;
    }
}

- (void)chainRequestDidStop {
    [self accessoriesStopCallBack];
    self.nextRequestIndex = 0;
    [self.requestArray removeAllObjects];
    [self.requestCallbackArray removeAllObjects];
    [[OSSVChainsRequestsManager sharedInstance] removeChainRequest:self];
}

- (void)clearChainRequest {
    NSUInteger currentRequestIndex = self.nextRequestIndex - 1;
    if (currentRequestIndex < self.requestArray.count) {
        OSSVBasesRequests *request = self.requestArray[currentRequestIndex];
        [request stop];
    }
    [self.requestArray removeAllObjects];
    [self.requestCallbackArray removeAllObjects];
}

#pragma mark - Property method

- (NSMutableArray<id<STLBaseRequestAccessory>> *)accessoryArray {
    if (_accessoryArray == nil) {
        _accessoryArray = [NSMutableArray array];
    }
    return _accessoryArray;
}

@end

@implementation OSSVChainsRequest (RequestAccessory)

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
