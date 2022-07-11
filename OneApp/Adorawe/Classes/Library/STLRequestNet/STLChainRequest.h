//
//  OSSVChainsRequest.h
//  STLRequestHeader
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSSVBasesRequests;
@class OSSVChainsRequest;
@protocol STLBaseRequestAccessory;

@protocol STLChainRequestDelegate <NSObject>

- (void)chainRequestSuccess:(OSSVChainsRequest *)chainRequest;
- (void)chainRequest:(OSSVChainsRequest *)chainRequest failure:(OSSVBasesRequests *)request;

@end

typedef void (^SYChainRequestCallback)(OSSVChainsRequest *chainRequest, __kindof OSSVBasesRequests *request);

@interface OSSVChainsRequest : NSObject

@property (nonatomic, weak) id <STLChainRequestDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableArray *requestArray;
@property (nonatomic, assign, readonly) BOOL enableAccessory;
@property (nonatomic, strong) NSMutableArray<id<STLBaseRequestAccessory>> *accessoryArray;

- (instancetype)initWithEnableAccessory:(BOOL)enableAccessory;

- (void)addRequest:(OSSVBasesRequests *)request callback:(SYChainRequestCallback)callback;
- (void)start;
- (void)stop;

@end

@interface OSSVChainsRequest (RequestAccessory)

- (void)toggleAccessoriesStartCallBack;
- (void)accessoriesStopCallBack;

@end
