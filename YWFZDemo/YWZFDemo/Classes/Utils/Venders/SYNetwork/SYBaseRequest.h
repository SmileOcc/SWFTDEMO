//
//  SYBaseRequest.h
//  SYNetwork
//
//  Created by YW on 16/5/28.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFURLRequestSerialization.h"
#import <GGBrainKeeper/BKSpanModel.h>

#import "YWLocalHostManager.h"
#import "ZFApiDefiner.h"

@class SYBaseRequest;

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^SYRequestSuccessBlock)(__kindof SYBaseRequest *request);
typedef void (^SYRequestFailureBlock)(__kindof SYBaseRequest *request, NSError *error);
typedef void (^SYRequestProgressBlock)(NSProgress *progress);

typedef NS_ENUM(NSInteger , SYRequestMethod) {
    SYRequestMethodGET = 0,
    SYRequestMethodPOST,
    SYRequestMethodHEAD,
    SYRequestMethodPUT,
    SYRequestMethodDELETE,
    SYRequestMethodPATCH
};

typedef NS_ENUM(NSUInteger, SYRequestSerializerType) {
    SYRequestSerializerTypeHTTP = 0,
    SYRequestSerializerTypeJSON
};

@protocol SYBaseRequestDelegate <NSObject>

@optional
- (void)requestSuccess:(SYBaseRequest *)request;
- (void)requestFailure:(SYBaseRequest *)request error:(NSError *)error;
- (void)requestProgress:(NSProgress *)progress;

@end

@protocol SYBaseRequestAccessory <NSObject>

@optional
- (void)requestStart:(id)request;
- (void)requestStop:(id)request;

@end

@interface SYBaseRequest : NSObject

@property (nonatomic, weak) id <SYBaseRequestDelegate> delegate;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;
@property (nonatomic, strong) NSMutableArray<id<SYBaseRequestAccessory>> *accessoryArray;
@property (nonatomic, copy) SYRequestSuccessBlock successBlock;
@property (nonatomic, copy) SYRequestFailureBlock failureBlock;
@property (nonatomic, copy) SYRequestProgressBlock progressBlock;

//Response
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong, readonly) NSString *requestURLString;
@property (nonatomic, assign, readonly) NSInteger responseStatusCode;
@property (nonatomic, strong, readonly) NSDictionary *responseHeader;
@property (nonatomic, strong, readonly) NSString *responseString;
@property (nonatomic, strong, readonly) id responseJSONObject;

//Cache
@property (nonatomic, strong, readonly) NSData *cacheData;
@property (nonatomic, strong, readonly) id cacheJSONObject;

//新增是否加密
- (BOOL)encryption;
- (BOOL)enableCache;
- (BOOL)enableAccessory;
- (SYRequestMethod)requestMethod;
- (SYRequestSerializerType)requestSerializerType;
- (NSURLRequestCachePolicy)requestCachePolicy;
- (NSString *)baseURL;
- (NSString *)requestPath;
- (id)requestParameters;
- (NSTimeInterval)requestTimeoutInterval;
- (id)jsonObjectValidator;
- (NSDictionary<NSString *, NSString *> *)requestHeader;
- (AFConstructingBlock)constructingBodyBlock;
- (BOOL)isCommunityRequest;

- (BOOL)isCommunityLiveRequest;

- (NSString *)communityLiveURLAppendPublicArgument:(NSString *)requestURL;


- (void)start;
- (void)stop;
- (void)startWithBlockSuccess:(SYRequestSuccessBlock)success
                      failure:(SYRequestFailureBlock)failure;
- (void)startWithBlockProgress:(SYRequestProgressBlock)progress
                       success:(SYRequestSuccessBlock)success
                       failure:(SYRequestFailureBlock)failure;

- (void)clearCompletionBlock;

@end

@interface SYBaseRequest (RequestAccessory)

- (void)toggleAccessoriesStartCallBack;
- (void)toggleAccessoriesStopCallBack;

@end

#pragma mark --------------- 链路 ----------------
@interface SYBaseRequest (BK)

/**
 过程Model对象
 */
@property (nonatomic, strong) BKSpanModel *spanModel;
/**
 是否自动提交链路，默认自动提交链路
 */
@property (nonatomic, assign) BOOL notAutoSubmit;
/**
 是否为链式请求, 默认为否
 */
@property (nonatomic, assign) BOOL isChained;
/**
 请求所属的控制器
 */
@property (nonatomic, weak) id taget;

/**
 请求的完整链接
 */
@property (nonatomic, copy) NSString *url;

/**
 链路名称 (事件链路时可传可不传，页面链路不需要传)
 */
@property (nonatomic, copy) NSString *pageName;

/**
 链路事件名称 (事件链路时传，页面链路不需要传) 该字段用于区分页面链路与事件链路
 */
@property (nonatomic, copy) NSString *eventName;

/**
 添加RPC过程
 */
- (void)addNetToTrace;

/**
 RPC过程结束
 */
- (void)netSpanEnd;

/**
 结束渲染，并自动提交
 */
- (void)endRender;

/**
 请求失败

 @param error 错误信息
 */
- (void)netSpanError:(NSError *)error;

@end
