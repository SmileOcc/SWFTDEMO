//
//  STLBatchRequest.h
//  STLRequestHeader
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSSVBasesRequests;
@class OSSVMutlsRequest;
@protocol STLBaseRequestAccessory;

@protocol STLMutlRequestDelegate <NSObject>

- (void)batchRequestSuccess:(OSSVMutlsRequest *)batchRequest;
- (void)batchRequestFailure:(OSSVMutlsRequest *)batchRequest;

@end

@interface OSSVMutlsRequest : NSObject

@property (nonatomic, weak) id <STLMutlRequestDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray *requestArray;
@property (nonatomic, assign, readonly) BOOL enableAccessory;
@property (nonatomic, strong) NSMutableArray<id<STLBaseRequestAccessory>> *accessoryArray;
@property (nonatomic, copy) void (^successCompletionBlock)(OSSVMutlsRequest *request);
@property (nonatomic, copy) void (^failureCompletionBlock)(OSSVMutlsRequest *request);

- (instancetype)initWithRequestArray:(NSArray<OSSVBasesRequests *> *)requestArray enableAccessory:(BOOL)enableAccessory;

- (void)start;
- (void)stop;
- (void)startWithBlockSuccess:(void (^)(OSSVMutlsRequest *batchRequest))success
                      failure:(void (^)(OSSVMutlsRequest *batchRequest))failure;

- (void)clearCompletionBlock;

@end

@interface OSSVMutlsRequest (RequestAccessory)

- (void)toggleAccessoriesStartCallBack;
- (void)accessoriesStopCallBack;

@end
