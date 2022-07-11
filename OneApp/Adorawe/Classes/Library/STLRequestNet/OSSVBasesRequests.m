//
//  OSSVBasesRequests.m
//  STLRequestHeader
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"
#import "OSSVRequestsUtils.h"
#import "OSSVRequestsConfigs.h"
#import "OSSVRequestsManager.h"
#import "OSSVRequestsCachesManager.h"

@implementation OSSVBasesRequests

-(BOOL)isNewENC
{
    return NO;
}

//默认设为开启缓存
- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return NO;
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodGET;
}

- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeHTTP;
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

-(NSString *)domainPath {
    ///默认是主域名, 可配置
    return masterDomain;
}

- (id)requestParameters {
    return nil;
}

- (NSTimeInterval)requestTimeoutInterval {
    return 15.0;
}

- (id)jsonObjectValidator {
    return nil;
}

- (NSDictionary<NSString *, NSString *> *)requestHeader {
    return nil;
}

- (AFConstructingBlock)constructingBodyBlock {
    return nil;
}

#pragma mark - Public

- (void)start {
    [self accessoriesStartCallBack];
    [[OSSVRequestsManager sharedInstance] addRequest:self];
}

- (void)stop {
    self.delegate = nil;
    [[OSSVRequestsManager sharedInstance] removeRequest:self completion:^{
        [self accessoriesStopCallBack];
    }];
}

- (void)startWithBlockSuccess:(STLRequestSuccessBlock)success
                      failure:(STLRequestFailureBlock)failure {
    self.successBlock = success;
    self.failureBlock = failure;
    [self start];
}

- (void)startWithBlockSuccess:(STLRequestSuccessBlock)success
                      failure:(STLRequestFailureBlock)failure
                        cache:(STLRequestSuccessBlock)cache {
    self.successBlock = success;
    self.failureBlock = failure;
    self.cacheBlock = cache;
    
    [self start];
}


- (void)startWithBlockProgress:(STLRequestProgressBlock)progress
                       success:(STLRequestSuccessBlock)success
                       failure:(STLRequestFailureBlock)failure {
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

- (NSMutableArray<id<STLBaseRequestAccessory>> *)accessoryArray {
    if (_accessoryArray == nil) {
        _accessoryArray = [NSMutableArray array];
    }
    return _accessoryArray;
}

- (NSString *)requestURLString {
    NSString *baseURL = nil;
    NSString *domainUrl = @"";

    if (self.baseURL.length > 0) {// 特殊请求地址STLHitsApi
        baseURL = self.baseURL;
        return baseURL;
    }
    
    id <STLConfigureDomainProtocol> domainModule = [OSSVConfigDomainsManager gainDomainModule:self.domainPath];
    
    DomainType domainType = [OSSVConfigDomainsManager domainEnvironment];
    
    
    if (domainType == DomainType_Release) {
        domainUrl = [domainModule releaseDomainBranch];
    }else if(domainType == DomainType_Pre_Release){
        domainUrl = [domainModule preReleaseDomainBranch];
    } else{
        domainUrl = [domainModule testDomainBranch];
//        NSString *branchStr = [[OSSVConfigDomainsManager sharedInstance] gainCustomerBranch];
//        NSString *currentBranch = [domainModule testBranch];
//        if ([branchStr isEqualToString:@"主分支"]) {
//            branchStr = [domainModule testBranch];
//        }
        //暂时不用
//        NSString *branchNum = [[OSSVConfigDomainsManager sharedInstance] gainCustomerBranchNum];
//        if (branchNum.integerValue > 0) {
//            branchStr = [NSString stringWithFormat:@"%@%@", branchStr, branchNum];
//        }
        //不用了，现在只有测试分支与线上分支了
//        if (![domainUrl containsString:@"review.cloudsdlk.com"]) {
//            domainUrl = [domainUrl stringByReplacingOccurrencesOfString:currentBranch withString:branchStr];
//        }
    }
    
    NSString *version = domainModule.domainVersion;
    if (version.length) {
        ///如果配置了版本号
        
        if (![OSSVConfigDomainsManager isDistributionOnlineRelease]) {
            
            NSString *localVersion = [[OSSVConfigDomainsManager sharedInstance] gainCustomerVersion];
            if (!STLIsEmptyString(localVersion)) {
                version = localVersion;
            }
        }
        if ([version rangeOfString:@"/"].location == NSNotFound) {
            domainUrl = [NSString stringWithFormat:@"%@%@/", domainUrl, version];
        }else{
            domainUrl = [NSString stringWithFormat:@"%@%@", domainUrl, version];
        }
    }
    
    domainUrl = [NSString stringWithFormat:@"%@%@", domainUrl, self.requestPath];
    
    ///是否加密
//    BOOL isEnc = [domainModule isENC];
    BOOL isEnc = [self isNewENC];
    BOOL isContaine = [domainUrl containsString:@"?"];
    
    /// 1 加密 0 不加密
    if (isEnc) {
        if (isContaine) {
            domainUrl = [NSString stringWithFormat:@"%@&is_enc=%@", domainUrl, @"1"];
        }else{
            domainUrl = [NSString stringWithFormat:@"%@?is_enc=%@", domainUrl, @"1"];
        }
    }
    
    //releas 线上环境包 不传
    NSString *empUrl = domainUrl;
    if (isContaine) {
#if DEBUG
        domainUrl = [NSString stringWithFormat:@"%@&is_debug=1",empUrl];
#endif
        if (![OSSVConfigDomainsManager isDistributionOnlineRelease]) {
            domainUrl = [NSString stringWithFormat:@"%@&is_debug=1",empUrl];
        }
    } else {
#if DEBUG
        domainUrl = [NSString stringWithFormat:@"%@?is_debug=1",empUrl];
#endif
        if (![OSSVConfigDomainsManager isDistributionOnlineRelease]) {
            domainUrl = [NSString stringWithFormat:@"%@?is_debug=1",empUrl];
        }
    }
    
    return domainUrl;
}

- (NSInteger)responseStatusCode {
    return ((NSHTTPURLResponse *)self.sessionDataTask.response).statusCode;
}

- (NSDictionary *)responseHeader {
    return ((NSHTTPURLResponse *)self.sessionDataTask.response).allHeaderFields;
}

- (NSString *)responseString {
    if (![self.responseData isKindOfClass:[NSData class]]) {
        return @"";
    }
    return [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
}

- (id)responseJSONObject {
    if (![self.responseData isKindOfClass:[NSData class]]) {
        return nil;
    }
    NSError *error = nil;
    id responseJSONObject = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        STLRequestLog(@"%@", error.localizedDescription);
        return nil;
    } else {
        return responseJSONObject;
    }
}

- (NSData *)cacheData {
    NSString *cacheKey = [OSSVRequestsUtils cacheKeyWithRequest:self];
    return (NSData *)[[OSSVRequestsCachesManager sharedInstance] objectForKey:cacheKey];
}

- (id)cacheJSONObject {
    if (![self.cacheData isKindOfClass:[NSData class]]) {
        return nil;
    }
    NSError *error = nil;
    
    id cacheJSONObject = nil;
    //如果是正式环境,请求地址包含Adorawe路径则加密
    id <STLConfigureDomainProtocol> domainModule = [OSSVConfigDomainsManager gainDomainModule:self.domainPath];
//    BOOL isEnc = [domainModule isENC];
    
    BOOL isEnc = [self isNewENC];

    if (isEnc && [domainModule isKindOfClass:[STLMasterModule class]]) {
        cacheJSONObject =[OSSVNSStringTool desCacheDataEncrypt:[[NSString alloc] initWithData:self.cacheData  encoding:NSUTF8StringEncoding]];
    } else {
        cacheJSONObject = [NSJSONSerialization JSONObjectWithData:self.cacheData options:NSJSONReadingMutableContainers error:&error];
    }
    
    if (error) {
        STLRequestLog(@"%@", error.localizedDescription);
        return nil;
    } else {
        return cacheJSONObject;
    }
}

@end

@implementation OSSVBasesRequests (RequestAccessory)

- (void)accessoriesStartCallBack {
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
