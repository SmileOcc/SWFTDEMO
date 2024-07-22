//
//  SYNetworkManager.m
//  SYNetwork
//
//  Created by YW on 16/5/28.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "SYNetworkManager.h"
#import "SYNetworkUtil.h"
#import "SYNetworkConfig.h"
#import "SYNetworkCacheManager.h"
#import "SYBaseRequest.h"
#import "PostApi.h"
#import "YWLocalHostManager.h"
#import "AFNetworking.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "ZFNetworkConfigPlugin.h"
#import "ZFAnalytics.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>

@interface SYNetworkManager ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *requestIdentifierDictionary;
@property (nonatomic, strong) dispatch_queue_t requestProcessingQueue;

@end

@implementation SYNetworkManager

#pragma mark - Life Cycle

+ (SYNetworkManager *)sharedInstance {
    static SYNetworkManager *instance;
    static dispatch_once_t SYNetworkManagerToken;
    dispatch_once(&SYNetworkManagerToken, ^{
        instance = [[SYNetworkManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self manager];
        [self requestIdentifierDictionary];
    }
    return self;
}

#pragma mark - Public method
- (void)addRequest:(SYBaseRequest *)request {
    dispatch_async(self.requestProcessingQueue, ^{
        //启动cookies
        self.manager.requestSerializer.HTTPShouldHandleCookies = YES;
//        NSString *url = request.requestURLString;
        SYRequestMethod method = request.requestMethod;
        id parameters = request.requestParameters;
        
        //Request Serializer
        switch (request.requestSerializerType) {
            case SYRequestSerializerTypeHTTP: {
                self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                break;
            }
            case SYRequestSerializerTypeJSON: {
                self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
                break;
            }
            default: {
                SYNetworkLog(@"Error, unsupport method type");
                break;
            }
        }
        self.manager.requestSerializer.cachePolicy = request.requestCachePolicy;
        self.manager.requestSerializer.timeoutInterval = request.requestTimeoutInterval;
        
        //HTTPHeaderFields
        NSDictionary *requestHeaderFieldDictionary = request.requestHeader;
        if (requestHeaderFieldDictionary) {
            for (NSString *key in requestHeaderFieldDictionary.allKeys) {
                NSString *value = requestHeaderFieldDictionary[key];
                [self.manager.requestSerializer setValue:value forHTTPHeaderField:key];
            }
        }
        
        NSString *url = request.requestURLString;
        request.url = url;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parameters];
        NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
        [dict setValue:lang forKey:ZFApiLangKey];
        [dict setValue:[NSString stringWithFormat:@"%@",ZFSYSTEM_VERSION] forKey:ZFApiVersionKey];
        [dict setValue:TOKEN forKey:ZFApiTokenKey];
        [dict setValue:@"0" forKey:ZFApiIsencKey];//默认不加密
        [dict setValue:ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]) forKey:ZFApiAppsFlyerUID];
        [dict setValue:ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]) forKey:ZFApiBtsUniqueID];
        
        //国家Id, 供后期每个接口运营配置数据
        ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
        [dict setValue:ZFToString(accountModel.region_id) forKey:ZFApiCountryIdKey];
        [dict setValue:ZFToString(accountModel.region_code) forKey:ZFApiCountryCodeKey];
        
        if (request.isCommunityRequest) {
            [dict setValue:@"2" forKey:@"app_type"];
            
            NSString *countryId = [[NSUserDefaults standardUserDefaults] valueForKey:kLocationInfoCountryId];
            if (ZFIsEmptyString(countryId)) {
                countryId = ZFToString(accountModel.region_id);
            }
            [dict setValue:countryId forKey:ZFApiCommunityCountryId];
        }
        
        // 关于购物车中的公共参数
        if (![dict.allKeys containsObject:ZFTestForbidUserCoupon]) {
            
            // 购物车显示了优惠券一栏
            dict[@"ab_cart_price"] = @(1);
            
            // 是否在购物车页面选择了优惠券: 0选择  1不选中
            if (!ISLOGIN) {
                dict[@"no_login_select"] = [AccountManager sharedManager].no_login_select_coupon ? @"1" : @"0";
            }
            
            if ([AccountManager sharedManager].hasSelectedAppCoupon) {
                dict[@"auto_coupon"] = @"0";    // 是否为最优优惠券 0不是最优, 1最优
                dict[@"coupon"] = ZFToString([AccountManager sharedManager].selectedAppCouponCode);// 选择的优优惠券码
            } else {
                dict[@"auto_coupon"] = @"0";//V5.4.0版本改成不自动使用最优coupon
                if (![dict.allKeys containsObject:@"coupon"]) {
                    dict[@"coupon"] = @"";
                }
            }
        }
        
        //设备唯一标识,即使删除再次安装也是唯一
        NSString *device_id = [AccountManager sharedManager].device_id;
        dict[ZFApiDeviceId] = ZFToString(device_id);
        
        /** by: YW
         *  V3.5.0版本RUM需求请求接口改版, 所有请求参数中不加action, 请求url中拼接: 版本号 + action参数
         */
        if (!request.isCommunityRequest) {
            for (NSString *parametersKey in dict.allKeys) {
                if ([parametersKey isEqualToString:ZFApiActionKey]) {
                    NSString *actionValue = [dict valueForKey:ZFApiActionKey];
                    if (actionValue.length>0) {
                        url = [NSString stringWithFormat:@"%@%@",[SYNetworkConfig sharedInstance].baseURL, actionValue];
                        [dict removeObjectForKey:ZFApiActionKey];
                        // 用于链路上传
                        request.url = url;
                    }
                }
            }
        }
        
        
        [dict copy];
        parameters = dict;
        
        NSString *tip = [YWLocalHostManager currentLocalHostTitle];
        if (![YWLocalHostManager isDistributionOnlineRelease] && ![ZFNetworkConfigPlugin sharedInstance].closeUrlResponsePrintfLog) { //开发环境打印日志
            YWLog(@"\n🍀未加密🍀请求的URL %@:%@  \n参数:%@ \n👉json👈:%@",tip,url,dict,[dict yy_modelToJSONString]);
        }
        
        NSString *tempRequestJson = [parameters yy_modelToJSONString];
        
        if (request.encryption && !request.isCommunityRequest) {
            parameters = @{@"data":[NSStringUtils encryptWithDict:dict]};
            
            if (![YWLocalHostManager isDistributionOnlineRelease] && ![ZFNetworkConfigPlugin sharedInstance].closeUrlResponsePrintfLog) { //开发环境打印日志
                YWLog(@"\n✅加密后✅URL %@:%@  \n参数:%@ \n👉json👈:%@",tip,url,parameters,[parameters yy_modelToJSONString]);
            }
        }
        NSString *headerKey = @"";
        NSString *headerValue = @"";
        
        if (![dict[@"action"] isEqualToString:@"Community/review"]) {
            // 做header签名处理
            NSString *requestJson =  [parameters yy_modelToJSONString];
            NSString *key = @"";
            if (request.isCommunityRequest) {
                
                if ([request isKindOfClass:[PostApi class]]) {
                    key = [NSString stringWithFormat:@"%@%@",[YWLocalHostManager appCommunityPostApiPrivateKey],[YWLocalHostManager appCommunityPrivateKey]];
                    headerKey = [NSStringUtils ZFNSStringMD5:key];
                    headerValue = [NSStringUtils ZFNSStringMD5:[NSString stringWithFormat:@"%@%@%@",[YWLocalHostManager appCommunityPostApiPrivateKey],headerKey,[YWLocalHostManager appCommunityPrivateKey]]];
                }else{
                    key = [YWLocalHostManager appCommunityPrivateKey];
                    
                    // v5.5.0 社区直播----
                    if (request.isCommunityLiveRequest) {
                        key = [YWLocalHostManager appCommunityLivePrivateKey];
                    }
                    headerKey = [NSStringUtils ZFNSStringMD5:[requestJson stringByAppendingString:key]];
                    headerValue = [NSStringUtils ZFNSStringMD5:[[requestJson stringByAppendingString:headerKey] stringByAppendingString:key]];
                }
                
            }else{
                key = [YWLocalHostManager appPrivateKey];
                headerKey = [NSStringUtils ZFNSStringMD5:[requestJson stringByAppendingString:key]];
                headerValue = [NSStringUtils ZFNSStringMD5:[[requestJson stringByAppendingString:headerKey] stringByAppendingString:key]];
            }
           
            YWLog(@"\n-----key:%@\n-----value:%@",headerKey,headerValue);
            [self.manager.requestSerializer setValue:headerValue forHTTPHeaderField:headerKey];
        }
        // 请求开始
        [request addNetToTrace];
        switch (method) {
            case SYRequestMethodGET: {
                request.sessionDataTask = [self.manager GET:url
                                                 parameters:parameters
                                                   progress:^(NSProgress * _Nonnull downloadProgress) {
                                                       [self handleRequest:request progress:downloadProgress];
                                                       
                                                   } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                       [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];
                                                       
                                                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                       [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];
                                                   }];
                break;
            }
            case SYRequestMethodPOST: {
                if (request.constructingBodyBlock) {
                    request.sessionDataTask = [self.manager POST:url
                                                      parameters:parameters
                                       constructingBodyWithBlock:request.constructingBodyBlock
                                                        progress:^(NSProgress * _Nonnull uploadProgress) {
                                                            [self handleRequest:request progress:uploadProgress];
                                                            
                                                        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                            [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];
                                                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                            [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];
                                                        }];
                } else {
                    request.sessionDataTask = [self.manager POST:url
                                                      parameters:parameters
                                                        progress:^(NSProgress * _Nonnull downloadProgress) {
                                                            [self handleRequest:request progress:downloadProgress];
                                                            
                                                        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                            [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];
                                                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                            [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];
                                                        }];
                }
                break;
            }
            case SYRequestMethodHEAD: {
                request.sessionDataTask = [self.manager HEAD:url
                                                  parameters:parameters
                                                     success:^(NSURLSessionDataTask * _Nonnull task) {
                                                         [self handleRequestSuccessWithSessionDataTask:task responseObject:nil tempRequestJson:tempRequestJson];
                                                         
                                                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                         [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];
                                                     }];
                break;
            }
            case SYRequestMethodPUT: {
                request.sessionDataTask = [self.manager PUT:url
                                                 parameters:parameters
                                                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                        [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];
                                                        
                                                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                        [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];
                                                    }];
                break;
            }
            case SYRequestMethodDELETE: {
                request.sessionDataTask = [self.manager DELETE:url
                                                    parameters:parameters
                                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                           [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];
                                                           
                                                       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                           [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];
                                                       }];
                break;
            }
            case SYRequestMethodPATCH: {
                request.sessionDataTask = [self.manager PATCH:url
                                                   parameters:parameters
                                                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                          [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];
                                                          
                                                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                          [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];
                                                      }];
                break;
            }
            default: {
                SYNetworkLog(@"Error, unsupport method type");
                break;
            }
        }
        [self addRequestIdentifierWithRequest:request];
    });
}

- (void)removeRequest:(SYBaseRequest *)request completion:(void (^)(void))completion {
    dispatch_async(self.requestProcessingQueue, ^{
        [request.sessionDataTask cancel];
        [self removeRequestIdentifierWithRequest:request];
        completion?completion():nil;
    });
}

- (void)removeAllRequest {
    NSDictionary *requestIdentifierDictionary = self.requestIdentifierDictionary.copy;
    for (NSString *key in requestIdentifierDictionary.allValues) {
        SYBaseRequest *request = self.requestIdentifierDictionary[key];
        [request.sessionDataTask cancel];
        [self.requestIdentifierDictionary removeObjectForKey:key];
    }
}

#pragma mark - Private method

- (BOOL)isValidResultWithRequest:(SYBaseRequest *)request {
    BOOL result = YES;
    if (request.jsonObjectValidator != nil) {
        result = [SYNetworkUtil isValidateJSONObject:request.responseJSONObject
                             withJSONObjectValidator:request.jsonObjectValidator];
    }
    return result;
}

- (void)handleRequest:(SYBaseRequest *)request progress:(NSProgress *)progress {
    if ([request.delegate respondsToSelector:@selector(requestProgress:)]) {
        [request.delegate requestProgress:progress];
    }
    if (request.progressBlock) {
        request.progressBlock(progress);
    }
}

/**
 * 上传打印日志供测试人员使用
 * add by: YW
 */
- (void)af_uploadRequestLogInfo:(NSURLSessionDataTask *)requestParmaterTask
                   responseJSON:(NSString *)responseJSON
                  requestStatus:(BOOL)isSuccess
                tempRequestJson:(NSString *)tempRequestJson
{
    if ([YWLocalHostManager isDistributionOnlineRelease] || [ZFNetworkConfigPlugin sharedInstance].closeUrlResponsePrintfLog) {
        return;//线上发布环境不上传日志
    }
    if (!requestParmaterTask) return;
    
    // 只有在控制面板中设置了抓包日志才上传远程日志    
    if (![ZFNetworkConfigPlugin sharedInstance].uploadResponseJsonToLogSystem) return;
    
    NSString *requestJson = tempRequestJson;
//    NSData *requestData = requestParmaterTask.originalRequest.HTTPBody;
//    if (requestData) {
//        requestJson = [[NSString alloc] initWithData:requestData encoding:(NSUTF8StringEncoding)];
//    }
    
    NSString *requestKey = nil;
    NSString *requestValue = nil;
    NSDictionary *httpHeadDic = requestParmaterTask.originalRequest.allHTTPHeaderFields;
    for (NSString *httpHeadStr in httpHeadDic.allKeys) {
        if (httpHeadStr.length > 25) {
            requestKey = httpHeadStr;
            requestValue = httpHeadDic[httpHeadStr] ? : @"";
            break;
        }
    }
    
    NSString *successFlag = isSuccess ? @"✅✅✅" : @"❌❌❌";
    NSString *requestStatus = isSuccess ? @"成功" : @"失败";
    NSString *requestUrl = requestParmaterTask.originalRequest.URL.absoluteString ? : @"";
    NSString *inputCatchLogTag = [[NSUserDefaults standardUserDefaults] objectForKey:kInputCatchLogTagKey];
    
    //开发环境打印日志
    NSString *hostTitle = [YWLocalHostManager currentLocalHostTitle];
    NSString *logBody = @"";
    if ([ZFNetworkConfigPlugin sharedInstance].closeUrlResponsePrintfLog) {
        logBody = [NSString stringWithFormat:@"<br/>%@%@请求接口地址 %@= %@<br/>请求参数json=<br/> %@ <br/>加密key===========%@<br/>加密Value=========%@<br/>",ZFToString(inputCatchLogTag), successFlag, hostTitle, requestUrl, requestJson, requestKey, requestValue];
    } else {
        logBody = [NSString stringWithFormat:@"<br/>%@%@请求接口地址 %@= %@<br/>请求参数json=<br/> %@ <br/>加密key===========%@<br/>加密Value=========%@<br/> <br/> 网络数据%@返回=<br/>%@",ZFToString(inputCatchLogTag), successFlag, hostTitle, requestUrl, requestJson, requestKey, requestValue, requestStatus, [responseJSON yy_modelToJSONString]];
    }
    
    NSDictionary *requestParams = @{ @"body"     : logBody,
                                     @"level"    : @"iOS",
                                     @"domain"   : @"ZF-iOS",
                                     @"platform" : @"ZZZZZ",
                                     @"url"      : requestUrl,
                                     @"request"  : requestJson,
                                     @"response" : [responseJSON yy_modelToJSONString],
                                     };
    ZFRequestModel *model = [[ZFRequestModel alloc] init];
    NSString *uploadAddress = model.uploadRequestLogToUrl;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html", @"text/plain", nil];
    [manager POST:uploadAddress parameters:requestParams progress:nil success:nil failure:nil];
}


/**
 * 判断是否需要登录
 * add by: YW
 */
- (void)judgeNeedLogin:(NSInteger)responseStatusCode
{
    if (responseStatusCode == 202) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
    }
}

- (void)handleRequestSuccessWithSessionDataTask:(NSURLSessionDataTask *)sessionDataTask
                                 responseObject:(id)responseObject
                                tempRequestJson:(NSString *)tempRequestJson
{
    NSString *key = @(sessionDataTask.taskIdentifier).stringValue;
    SYBaseRequest *request = self.requestIdentifierDictionary[key];
    request.responseData = responseObject;
    if (request) {
        if ([self isValidResultWithRequest:request]) {
            // 请求成功
            [request netSpanEnd];
            if (request.enableCache) {
                NSString *cacheKey = [SYNetworkUtil cacheKeyWithRequest:request];
                [[SYNetworkCacheManager sharedInstance] setObject:request.responseData forKey:cacheKey];
            }
            if ([request.delegate respondsToSelector:@selector(requestSuccess:)]) {
                [request.delegate requestSuccess:request];
            }
            if (self.manager.completionQueue) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (request.successBlock) {
                        request.successBlock(request);
                    }
                });
            }else{
                if (request.successBlock) {
                    request.successBlock(request);
                }
            }
            // 完成渲染
            [request endRender];
            [request toggleAccessoriesStopCallBack];
        } else {
            if (request.responseStatusCode == 200) {
                // 请求成功
                [request netSpanEnd];
            } else {
                // 请求失败
                [request netSpanError:nil];
            }
            SYNetworkLog(@"Request %@ failed, status code = %@", NSStringFromClass([request class]), @(request.responseStatusCode));
            if ([request.delegate respondsToSelector:@selector(requestFailure:error:)]) {
                [request.delegate requestFailure:request error:nil];
            }
            if (request.failureBlock) {
                request.failureBlock(request, nil);
            }
            if (request.responseStatusCode == 200) {
                // 完成渲染
                [request endRender];
            }
            [request toggleAccessoriesStopCallBack];
        }
        
        //判断是否需要登录 modify by YW
        [self judgeNeedLogin:request.responseStatusCode];
        
        //上传打印日志供测试人员使用
        [self af_uploadRequestLogInfo:sessionDataTask
                         responseJSON:request.responseJSONObject
                        requestStatus:YES
                      tempRequestJson:tempRequestJson];
        
    }
    [request clearCompletionBlock];
    [self removeRequestIdentifierWithRequest:request];
}

- (void)handleRequestFailureWithSessionDatatask:(NSURLSessionDataTask *)sessionDataTask
                                          error:(NSError *)error
                                tempRequestJson:(NSString *)tempRequestJson
{
    NSString *key = @(sessionDataTask.taskIdentifier).stringValue;
    SYBaseRequest *request = self.requestIdentifierDictionary[key];
    request.responseData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (request) {
        // 请求失败
        [request netSpanError:error];
        if ([request.delegate respondsToSelector:@selector(requestFailure:error:)]) {
            [request.delegate requestFailure:request error:error];
        }
        if (request.failureBlock) {
            request.failureBlock(request, error);
        }
        [request toggleAccessoriesStopCallBack];
        
        //判断是否需要登录 modify by YW
        [self judgeNeedLogin:request.responseStatusCode];
        
        //上传打印日志供测试人员使用
        [self af_uploadRequestLogInfo:sessionDataTask
                         responseJSON:request.responseJSONObject
                        requestStatus:NO
                      tempRequestJson:tempRequestJson];
    }
    [request clearCompletionBlock];
    [self removeRequestIdentifierWithRequest:request];
}

- (void)addRequestIdentifierWithRequest:(SYBaseRequest *)request {
    if (request.sessionDataTask != nil) {
        NSString *key = @(request.sessionDataTask.taskIdentifier).stringValue;
        @synchronized (self) {
            [self.requestIdentifierDictionary setObject:request forKey:key];
        }
    }
    SYNetworkLog(@"Add request: %@", NSStringFromClass([request class]));
}

- (void)removeRequestIdentifierWithRequest:(SYBaseRequest *)request {
    NSString *key = @(request.sessionDataTask.taskIdentifier).stringValue;
    @synchronized (self) {
        [self.requestIdentifierDictionary removeObjectForKey:key];
    }
    SYNetworkLog(@"Request queue size = %@", @(self.requestIdentifierDictionary.count));
}

#pragma mark - Property method

- (AFHTTPSessionManager *)manager {
    if (_manager == nil) {
        SYNetworkConfig *config = [SYNetworkConfig sharedInstance];
//        _manager = [AFHTTPSessionManager manager];
        NSURLSessionConfiguration *customeConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        Class class = NSClassFromString(@"ZFURLInjectManager");
        if (class) {
            customeConfiguration.protocolClasses = @[class];
        }
        if (@available(iOS 11.0, *)) {
            //多路径TCP服务，提供Wi-Fi和蜂窝之间的无缝切换，以保持连接。
            customeConfiguration.multipathServiceType = NSURLSessionMultipathServiceTypeHandover;
        }
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:customeConfiguration];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.securityPolicy = config.securityPolicy;
        _manager.operationQueue.maxConcurrentOperationCount = config.maxConcurrentOperationCount;
    }
    return _manager;
}

- (NSMutableDictionary *)requestIdentifierDictionary {
    if (_requestIdentifierDictionary == nil) {
        _requestIdentifierDictionary = [NSMutableDictionary dictionary];
    }
    return _requestIdentifierDictionary;
}

- (dispatch_queue_t)requestProcessingQueue {
    if (_requestProcessingQueue == nil) {
        _requestProcessingQueue = dispatch_queue_create("com.ZZZZZ.synetwork.request.processing", DISPATCH_QUEUE_SERIAL);
    }
    return _requestProcessingQueue;
}

@end
