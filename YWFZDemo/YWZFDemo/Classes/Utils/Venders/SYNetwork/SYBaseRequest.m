//
//  SYBaseRequest.m
//  SYNetwork
//
//  Created by YW on 16/5/28.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "SYBaseRequest.h"
#import "SYNetworkUtil.h"
#import "SYNetworkConfig.h"
#import "SYNetworkManager.h"
#import "SYNetworkCacheManager.h"
#import "YWLocalHostManager.h"
#import "NSStringUtils.h"
#import "Configuration.h"
#import <objc/runtime.h>
#import <GGBrainKeeper/BrainKeeperManager.h>
#import "YWCFunctionTool.h"
#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>
#import "Constants.h"
#import "ZFBTSDataSets.h"

@implementation SYBaseRequest

#pragma mark - Default Config

- (BOOL)encryption {
    //v4.5.1 occ 添加,只要不是线上发布包，都不加密，方便其他方调试
    if ([YWLocalHostManager isDistributionOnlineRelease]) {
         return YES;
    } else {
         return NO;
    }
}

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return NO;
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodGET;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeHTTP;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestUseProtocolCachePolicy;
}

- (NSString *)baseURL {
    return @"";
}

- (NSString *)requestPath {
    return @"";
}

- (id)requestParameters {
    return nil;
}

- (NSTimeInterval)requestTimeoutInterval {
    return 30.0;
}

- (id)jsonObjectValidator {
    return nil;
}

- (NSDictionary<NSString *, NSString *> *)requestHeader {

    NSString *userAgent = [YWLocalHostManager requestFlagePushUserAgent];
    if (!ZFIsEmptyString(userAgent)) {
        return @{@"Content-Type":@"application/json",
                 @"User-Agent":userAgent};
    }
    return @{
             @"Content-Type":@"application/json"
             };
}

- (AFConstructingBlock)constructingBodyBlock {
    return nil;
}

#pragma mark - Public method

- (void)start {
    [self toggleAccessoriesStartCallBack];
    [[SYNetworkManager sharedInstance] addRequest:self];

}

- (void)stop {
    self.delegate = nil;
    [[SYNetworkManager sharedInstance] removeRequest:self completion:^{
        [self toggleAccessoriesStopCallBack];
    }];
}

- (void)startWithBlockSuccess:(SYRequestSuccessBlock)success
                      failure:(SYRequestFailureBlock)failure {
    self.successBlock = success;
    self.failureBlock = failure;
    [self start];
}

- (void)startWithBlockProgress:(SYRequestProgressBlock)progress
                       success:(SYRequestSuccessBlock)success
                       failure:(SYRequestFailureBlock)failure {
    self.progressBlock = progress;
    self.successBlock = success;
    self.failureBlock = failure;
    [self start];
}

- (void)clearCompletionBlock {
    self.progressBlock = nil;
    self.successBlock = nil;
    self.failureBlock = nil;
}

#pragma mark - Property method

- (NSMutableArray<id<SYBaseRequestAccessory>> *)accessoryArray {
    if (_accessoryArray == nil) {
        _accessoryArray = [NSMutableArray array];
    }
    return _accessoryArray;
}

- (NSString *)requestURLString {
    NSString *baseURL = nil;
    
    if (self.isCommunityRequest) {
        if (self.baseURL.length > 0) {
            baseURL = self.baseURL;
        } else {
            baseURL = [SYNetworkConfig sharedInstance].communityBaseURL;
        }
    }else{
        if (self.baseURL.length > 0) {
            baseURL = self.baseURL;
        } else {
            baseURL = [SYNetworkConfig sharedInstance].baseURL;
        }
    }
    
    return [NSString stringWithFormat:@"%@%@", baseURL, self.requestPath];
}

- (NSInteger)responseStatusCode {
    return ((NSHTTPURLResponse *)self.sessionDataTask.response).statusCode;
}

- (NSDictionary *)responseHeader {
    return ((NSHTTPURLResponse *)self.sessionDataTask.response).allHeaderFields;
}

- (NSString *)responseString {
    if (self.responseData == nil) {
        return nil;
    }
    return [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
}

- (id)responseJSONObject {
    if (self.responseData == nil) {
        return nil;
    }
    NSError *error = nil;
    id responseJSONObject = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        SYNetworkLog(@"%@", error.localizedDescription);
        return nil;
    } else {
        return responseJSONObject;
    }
}

- (NSData *)cacheData {
    NSString *cacheKey = [SYNetworkUtil cacheKeyWithRequest:self];
    return (NSData *)[[SYNetworkCacheManager sharedInstance] objectForKey:cacheKey];
}

- (id)cacheJSONObject {
    if (self.cacheData == nil) {
        return nil;
    }
    NSError *error = nil;

    id cacheJSONObject = nil;
    NSString *requestBaseUrl = [YWLocalHostManager appBaseUR];
    //如果是正式环境而且请求地址包含DEzzal后台路径则加密
    if ([ISENC boolValue] && [self.requestURLString containsString:requestBaseUrl] && self.encryption) {
        cacheJSONObject =[NSStringUtils desEncryptWithString:[[NSString alloc] initWithData:self.cacheData  encoding:NSUTF8StringEncoding]];
    } else {
        cacheJSONObject = [NSJSONSerialization JSONObjectWithData:self.cacheData options:NSJSONReadingMutableContainers error:&error];
    }

    if (error) {
        SYNetworkLog(@"%@", error.localizedDescription);
        return nil;
    } else {
        return cacheJSONObject;
    }
}

-(BOOL)isCommunityRequest{
    return NO;
}

- (BOOL)isCommunityLiveRequest {
    return NO;
}


/// 社区直播公共参数，拼接在 URL 地址后面
- (NSDictionary *)requestCommunityLivePublicArgument {
    
    NSMutableDictionary *tempMDictionary = [NSMutableDictionary dictionary];
 
    
    return [tempMDictionary copy];
}

- (NSString *)communityLiveURLAppendPublicArgument:(NSString *)requestURL{
    
    NSDictionary *publicArgument = [self requestCommunityLivePublicArgument];
    
    NSMutableString *tempMString = [NSMutableString stringWithString:requestURL];
    
    [publicArgument.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == 0) {
            [tempMString appendString:@"?"];
        }
        
        [tempMString appendString:obj];
        [tempMString appendString:@"="];
        [tempMString appendString:publicArgument[obj]];
        
        if (idx < publicArgument.count - 1) {
            [tempMString appendString:@"&"];
        }
    }];
    
    return [tempMString copy];
    
}
@end

@implementation SYBaseRequest (RequestAccessory)

- (void)toggleAccessoriesStartCallBack {
    if (self.enableAccessory) {
        for (id<SYBaseRequestAccessory> accessory in self.accessoryArray) {
            if ([accessory respondsToSelector:@selector(requestStart:)]) {
                [accessory requestStart:self];
            }
        }
    }
}

- (void)toggleAccessoriesStopCallBack {
    if (self.enableAccessory) {
        for (id<SYBaseRequestAccessory> accessory in self.accessoryArray) {
            if ([accessory respondsToSelector:@selector(requestStop:)]) {
                [accessory requestStop:self];
            }
        }
    }
}

@end

@implementation SYBaseRequest (BK)

- (void)addNetToTrace {
    if ([NSStringUtils isEmptyString:self.eventName]) {
        // 页面链路
        if (self.taget && [self.taget isKindOfClass:NSClassFromString(@"ZFBaseViewController")]) {
            self.spanModel = [[BrainKeeperManager sharedManager] startNetWithPageName:nil event:nil target:self.taget url:self.url parentId:nil isNew:NO isChained:self.isChained];
        }
    } else {
        // 事件链路
        if (self.taget && [self.taget isKindOfClass:NSClassFromString(@"ZFBaseViewController")]) {
            self.spanModel = [[BrainKeeperManager sharedManager] startNetWithPageName:self.pageName event:self.eventName target:self.taget url:self.url parentId:nil isNew:YES isChained:self.isChained];
        }
    }
    
}

- (void)netSpanEnd {
    if (self.spanModel) {
        [self.spanModel end];
        if ([NSStringUtils isEmptyString:self.eventName]) {
            // 页面链路
            if (self.taget && [self.taget isKindOfClass:NSClassFromString(@"ZFBaseViewController")]) {
                
            }
        } else {
            // 事件链路
            if (!self.notAutoSubmit) {
                [[BrainKeeperManager sharedManager] subTrackWithPageName:self.pageName event:self.eventName target:self.taget];
            }
        }
    }
}

- (void)endRender {
    if (self.taget && [self.taget isKindOfClass:NSClassFromString(@"ZFBaseViewController")] && !self.notAutoSubmit && [NSStringUtils isEmptyString:self.eventName]) {
        [[BrainKeeperManager sharedManager] endRenderAndTrackWithPageName:nil event:nil target:self.taget];
    }
}

- (void)netSpanError:(NSError *)error {
    if (self.spanModel) {
        // 过滤取消请求链路
        if (error.code == -999 || [error.localizedDescription isEqualToString:@"cancelled"]) return;
        [self.spanModel endWithError:ZFToString(error.localizedDescription) statusCode:@(self.responseStatusCode)];
        if ([NSStringUtils isEmptyString:self.eventName]) {
            // 页面链路
            if (self.taget && [self.taget isKindOfClass:NSClassFromString(@"ZFBaseViewController")]) {
                if (!self.notAutoSubmit) {
                    [[BrainKeeperManager sharedManager] subTrackWithPageName:nil event:nil target:self.taget];
                }
            }
        } else {
            // 事件链路
            if (!self.notAutoSubmit) {
                [[BrainKeeperManager sharedManager] subTrackWithPageName:self.pageName event:self.eventName target:self.taget];
            }
        }
    }
    
}

- (void)setSpanModel:(BKSpanModel *)spanModel
{
    objc_setAssociatedObject(self, "SpanModel", spanModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BKSpanModel *)spanModel
{
    return objc_getAssociatedObject(self, "SpanModel");
}

- (void)setUrl:(NSString *)url {
    objc_setAssociatedObject(self, "fullUrl", url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)url {
    return objc_getAssociatedObject(self, "fullUrl");
}

- (void)setNotAutoSubmit:(BOOL)notAutoSubmit {
    objc_setAssociatedObject(self, "notAutoSubmit", @(notAutoSubmit), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)notAutoSubmit {
    return [objc_getAssociatedObject(self, "notAutoSubmit") boolValue];
}

- (void)setIsChained:(BOOL)isChained {
    objc_setAssociatedObject(self, "isChained", @(isChained), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isChained {
    return [objc_getAssociatedObject(self, "isChained") boolValue];
}

- (void)setTaget:(id)taget {
    objc_setAssociatedObject(self, "Taget", taget, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)taget {
    return objc_getAssociatedObject(self, "Taget");
}

- (void)setPageName:(NSString *)pageName {
    objc_setAssociatedObject(self, "pageName", pageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)pageName {
    return objc_getAssociatedObject(self, "pageName");
}

- (void)setEventName:(NSString *)eventName {
    objc_setAssociatedObject(self, "eventName", eventName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)eventName {
    return objc_getAssociatedObject(self, "eventName");
}

@end
