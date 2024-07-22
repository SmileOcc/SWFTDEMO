//
//  ZFMergeRequestManager.m
//  ZZZZZ
//
//  Created by YW on 2019/5/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFMergeRequestManager.h"
#import "ZFMergeRequest.h"

@interface ZFMergeRequestManager ()

@property (nonatomic, strong) NSMutableArray *requestList;

@end

@implementation ZFMergeRequestManager

+ (ZFMergeRequestManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZFMergeRequestManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZFMergeRequestManager alloc] init];
    });
    return manager;
}

- (void)addBatchRequest:(ZFMergeRequest *)batchRequest
{
    @synchronized (self) {
        [self.requestList addObject:batchRequest];
    }
}

- (void)removeBatchRequest:(ZFMergeRequest *)batchRequest
{
    @synchronized (self) {
        [self.requestList removeObject:batchRequest];
    }
}

- (NSMutableArray *)requestList
{
    if (!_requestList) {
        _requestList = [[NSMutableArray alloc] init];
    }
    return _requestList;
}

@end
