//
//  OSSVBasesRequests.h
//  STLRequestHeader
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFURLRequestSerialization.h"
#import "OSSVConfigDomainsManager.h"

@class OSSVBasesRequests;

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^STLRequestSuccessBlock)(__kindof OSSVBasesRequests *request);
typedef void (^STLRequestFailureBlock)(__kindof OSSVBasesRequests *request, NSError *error);
typedef void (^STLRequestProgressBlock)(NSProgress *progress);

typedef NS_ENUM(NSInteger , STLRequestMethod) {
    STLRequestMethodGET = 0,
    STLRequestMethodPOST,
    STLRequestMethodHEAD,
    STLRequestMethodPUT,
    STLRequestMethodDELETE,
    STLRequestMethodPATCH
};

typedef NS_ENUM(NSUInteger, STLRequestSerializerType) {
    STLRequestSerializerTypeHTTP = 0,
    STLRequestSerializerTypeJSON
};

@protocol STLBaseRequestDelegate <NSObject>

@optional
- (void)requestSuccess:(OSSVBasesRequests *)request;
- (void)requestFailure:(OSSVBasesRequests *)request error:(NSError *)error;
- (void)requestProgress:(NSProgress *)progress;

@end

@protocol STLBaseRequestAccessory <NSObject>

@optional
- (void)requestStart:(id)request;
- (void)requestStop:(id)request;

@end

@interface OSSVBasesRequests : NSObject

@property (nonatomic, weak) id <STLBaseRequestDelegate> delegate;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;
@property (nonatomic, strong) NSMutableArray<id<STLBaseRequestAccessory>> *accessoryArray;
@property (nonatomic, copy) STLRequestSuccessBlock successBlock;
@property (nonatomic, copy) STLRequestSuccessBlock cacheBlock;
@property (nonatomic, copy) STLRequestFailureBlock failureBlock;
@property (nonatomic, copy) STLRequestProgressBlock progressBlock;

//Response
@property (nonatomic, strong, readonly) NSDictionary  *responseHeader;
@property (nonatomic, strong, readonly) NSString      *requestURLString;
@property (nonatomic, assign, readonly) NSInteger     responseStatusCode;
@property (nonatomic, strong) NSData                  *responseData;
@property (nonatomic, strong, readonly) NSString      *responseString;
@property (nonatomic, strong, readonly) id            responseJSONObject;

//Cache
@property (nonatomic, assign) BOOL                    isCacheData;
@property (nonatomic, strong, readonly) NSData        *cacheData;
@property (nonatomic, strong, readonly) id            cacheJSONObject;

-(BOOL)isNewENC;
- (BOOL)enableCache;
- (BOOL)enableAccessory;
- (STLRequestMethod)requestMethod;
- (STLRequestSerializerType)requestSerializerType;
- (NSURLRequestCachePolicy)requestCachePolicy;

//完整的URL
- (NSString *)baseURL;
//请求地址
- (NSString *)requestPath;
//域名
- (NSString *)domainPath;
//参数
- (id)requestParameters;
//时间超时
- (NSTimeInterval)requestTimeoutInterval;
- (id)jsonObjectValidator;
//请求头
- (NSDictionary<NSString *, NSString *> *)requestHeader;
- (AFConstructingBlock)constructingBodyBlock;

- (void)start;
- (void)stop;
- (void)startWithBlockSuccess:(STLRequestSuccessBlock)success
                      failure:(STLRequestFailureBlock)failure;

- (void)startWithBlockSuccess:(STLRequestSuccessBlock)success
                    failure:(STLRequestFailureBlock)failure
                        cache:(STLRequestSuccessBlock)cache;

- (void)startWithBlockProgress:(STLRequestProgressBlock)progress
                       success:(STLRequestSuccessBlock)success
                       failure:(STLRequestFailureBlock)failure;

- (void)clearCompletionBlock;

@end

@interface OSSVBasesRequests (RequestAccessory)

- (void)accessoriesStartCallBack;
- (void)accessoriesStopCallBack;

@end
