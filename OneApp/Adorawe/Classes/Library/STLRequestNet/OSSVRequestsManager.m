//
//  OSSVRequestsManager.m
//  OSSVRequestsManager
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVRequestsManager.h"
#import "OSSVRequestsUtils.h"
#import "OSSVRequestsConfigs.h"
#import "OSSVRequestsCachesManager.h"
#import "OSSVBasesRequests.h"
#import "CountryModel.h"
#import "OSSVHomesChannelsApi.h"
#import "OSSVJSONRequestsSerializer.h"

@interface OSSVRequestsManager ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *requestIdentifierDictionary;
@property (nonatomic, strong) dispatch_queue_t requestProcessingQueue;

@end

@implementation OSSVRequestsManager

#pragma mark - Life Cycle

+ (OSSVRequestsManager *)sharedInstance {
    static OSSVRequestsManager *instance;
    static dispatch_once_t SYNetworkManagerToken;
    dispatch_once(&SYNetworkManagerToken, ^{
        instance = [[OSSVRequestsManager alloc] init];
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

- (void)addRequest:(OSSVBasesRequests *)request {
    dispatch_async(self.requestProcessingQueue, ^{
        [self handleRequest:request];
    });
}

-(void)handleRequest:(OSSVBasesRequests *)request
{
    NSString *url = request.requestURLString;

    
    STLRequestMethod method = request.requestMethod;
    id parameters = request.requestParameters;
    
    
    if (request.enableCache) {//缓存
        dispatch_async(dispatch_get_main_queue(), ^{//需要在主线程读取
            if (request.cacheJSONObject && request.cacheBlock) {
                request.isCacheData = YES;
                request.cacheBlock(request);
            }
        });
    }
    
    NSString *domainString = request.domainPath;
    
    id<STLConfigureDomainProtocol>domainModule = [OSSVConfigDomainsManager gainDomainModule:domainString];
    
    
    if ([domainModule isKindOfClass:[STLCommentModule class]]) {

    } else {
        
        //＝＝＝＝＝＝＝＝＝配置多语言＝＝＝＝＝＝＝＝＝
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parameters];
        NSString *currentLang = [STLLocalizationString shareLocalizable].nomarLocalizable;
        [dict setObject:currentLang forKey:@"lang"];
        
        
        //    [dict setObject:STLToString([OSSVAccountsManager sharedManager].device_id) forKey:@"device_id"];
        [dict setObject:[ExchangeManager localTypeCurrency] forKey:@"currency"];
        
        ////如果接口传了，就用接口的，自定义api_currency
        if (!STLIsEmptyString(dict[@"api_currency"])) {
            [dict setObject:dict[@"api_currency"] forKey:@"currency"];
        }
        [dict setObject:[OSSVNSStringTool buildCommparam] forKey:@"commparam"];
        
        
        ///性别不需要传到公共参数
        //    NSString *sex = [NSString stringWithFormat:@"%d", [OSSVAccountsManager sharedManager].account.sex];
        //    if ([OSSVAccountsManager sharedManager].account) {
        //        [dict setObject:sex forKey:@"sex"];
        //    } else {
        //        [dict setObject:sex forKey:@""];
        //    }
        
        if ([OSSVConfigDomainsManager isDistributionOnlineRelease]) {
            [dict setObject:@"false" forKey:@"is_debug"];
        } else {
            [dict setObject:@"true" forKey:@"is_debug"];
        }
        
        ///1.4.6 取消单独缓存
        ///网红用户使用特殊缓存
//        if(OSSVAccountsManager.sharedManager.account.is_kol){
//            [dict setObject:@"1" forKey:@"is_kol"];
//        }
        
        //换成token
        //    if (USERID) {
        //        [dict setObject:USER_TOKEN forKey:@"token"];
        //    } else {
        //        [dict setObject:@"" forKey:@"token"];
        //    }
        
        
        //    if ([OSSVAccountsManager sharedManager].countryModel && !STLIsEmptyString([OSSVAccountsManager sharedManager].countryModel.iosCodeName)) {//用户国家
        //        [dict setObject:[OSSVAccountsManager sharedManager].countryModel.iosCodeName forKey:@"countryCode"];
        //    }
        
        parameters = dict;
        
        //![NetworkConfigPlugin sharedInstance].closeUrlResponsePrintfLog
        NSString *tip = [[OSSVConfigDomainsManager sharedInstance] gainCustomerBranch];
        if (![OSSVConfigDomainsManager isDistributionOnlineRelease] && ![OSSVRequestsConfigs sharedInstance].closeUrlResponsePrintfLog) { //开发环境打印日志
            NSString *parJson = [dict yy_modelToJSONString];
            STLLog(@"\n🍀未加密🍀请求的URL %@:%@  \n参数:%@ \n👉json👈:%@",tip,url,dict,parJson);
        }
        
    }
    NSString *tempRequestJson = [OSSVNSStringTool jsonStringWithDict:parameters];
    
    
    //如果是正式环境而且请求地址包含Adorawe后台路径则加密
    //    if (domainModule.isEN C && [domainModule isKindOfClass:[STLMasterModule class]]) {
    if ([request isNewENC] && [domainModule isKindOfClass:[STLMasterModule class]]) {
        parameters = @{@"m_param": [OSSVNSStringTool encryptWithDict:parameters]};
    }

    NSLog(@"\n\nRequestParameters------------>\n\n==============\n\n %@\n\n===============\n\n",[parameters yy_modelToJSONString]);
    //Request Serializer
    switch (request.requestSerializerType) {
        case STLRequestSerializerTypeHTTP: {
            self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        }
        case STLRequestSerializerTypeJSON: {
            self.manager.requestSerializer = [OSSVJSONRequestsSerializer serializer];
            break;
        }
        default: {
            STLRequestLog(@"Error, unsupport method type");
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
    
    //V1.3.2 去掉公共参数中的token以及deviceId,放到请求header里面
    NSString *tokenString = @"";
    if (USERID) {
        tokenString = [NSString stringWithFormat:@"%@",[OSSVAccountsManager sharedManager].userToken];
        [self.manager.requestSerializer setValue:tokenString forHTTPHeaderField:@"adw-token"];
        NSLog(@"tokenString------:%@",tokenString);
    }

    NSString *deviceID = STLToString([OSSVAccountsManager sharedManager].device_id);
    NSString *sensiorId = [SensorsAnalyticsSDK sharedInstance].anonymousId;
    
    [self.manager.requestSerializer setValue:deviceID forHTTPHeaderField:@"adw-deviceid"];
    [self.manager.requestSerializer setValue:STLToString(sensiorId) forHTTPHeaderField:@"adw-anonymousId"];

    [self.manager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"adw-pf"];
    [self.manager.requestSerializer setValue:@"true" forHTTPHeaderField:@"onesite"];

    ///CND 缓存调试信息
    NSString *cacheDebugheader = @"akamai-x-get-cache-key, akamai-x-cache-on, akamai-x-cache-remote-on, akamai-x-get-true-cache-key, akamai-x-check-cacheable,akamai-x-get-request-id, akamai-x-serial-no, akamai-x-get-ssl-client-session-id, X-Akamai-CacheTrack, akamai-x-get-client-ip, akamai-x-feo-trace, akamai-x-tapioca-trace,akamai-x-check-cacheable";
    
    [self.manager.requestSerializer setValue:cacheDebugheader forHTTPHeaderField:@"Pragma"];

    switch (method) {
        case STLRequestMethodGET: {
            
//            request.sessionDataTask = [self.manager GET:url
//                                             parameters:parameters
//                                               progress:^(NSProgress * _Nonnull downloadProgress) {
//                                                   [self handleRequest:request progress:downloadProgress];
//                                               } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                                                   [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];
//                                               } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                                   [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];
//
//                                               }];
            
            request.sessionDataTask = [self.manager GET:url parameters:parameters headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                [self handleRequest:request progress:downloadProgress];

            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];

            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];

            }];
            break;
        }
        case STLRequestMethodPOST: {
            if (request.constructingBodyBlock) {
//                request.sessionDataTask = [self.manager POST:url
//                                                  parameters:parameters
//                                   constructingBodyWithBlock:request.constructingBodyBlock
//                                                    progress:^(NSProgress * _Nonnull uploadProgress) {
//                                                        [self handleRequest:request progress:uploadProgress];
//                                                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                                                        [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];
//                                                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                                        [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];
//                                                    }];
                
                request.sessionDataTask = [self.manager POST:url parameters:parameters headers:nil constructingBodyWithBlock:request.constructingBodyBlock progress:^(NSProgress * _Nonnull uploadProgress) {
                    [self handleRequest:request progress:uploadProgress];

                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];

                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];

                }];
            } else {
//                request.sessionDataTask = [self.manager POST:url
//                                                  parameters:parameters
//                                                    progress:^(NSProgress * _Nonnull downloadProgress) {
//                                                        [self handleRequest:request progress:downloadProgress];
//                                                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                                                        [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];
//                                                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                                        [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];
//                                                    }];
                
                request.sessionDataTask = [self.manager POST:url parameters:parameters headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
                    [self handleRequest:request progress:uploadProgress];

                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];

                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];

                }];
            }
            break;
        }
        case STLRequestMethodHEAD: {
//            request.sessionDataTask = [self.manager HEAD:url
//                                              parameters:parameters
//                                                 success:^(NSURLSessionDataTask * _Nonnull task) {
//                                                     [self handleRequestSuccessWithSessionDataTask:task responseObject:nil tempRequestJson:tempRequestJson];
//                                                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                                     [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];
//                                                 }];
            request.sessionDataTask = [self.manager HEAD:url parameters:parameters headers:nil success:^(NSURLSessionDataTask * _Nonnull task) {
                [self handleRequestSuccessWithSessionDataTask:task responseObject:nil tempRequestJson:tempRequestJson];

            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];

            }];
            break;
        }
        case STLRequestMethodPUT: {
//            request.sessionDataTask = [self.manager PUT:url
//                                             parameters:parameters
//                                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                                                    [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];
//                                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                                    [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];
//                                                }];
            request.sessionDataTask = [self.manager PUT:url parameters:parameters headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];

            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];

            }];
            break;
        }
        case STLRequestMethodDELETE: {
//            request.sessionDataTask = [self.manager DELETE:url
//                                                parameters:parameters
//                                                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                                                       [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];
//                                                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                                       [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];
//                                                   }];
            request.sessionDataTask = [self.manager DELETE:parameters parameters:parameters headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];

            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];

            }];
            break;
        }
        case STLRequestMethodPATCH: {
//            request.sessionDataTask = [self.manager PATCH:url
//                                               parameters:parameters
//                                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                                                      [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];
//                                                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                                      [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];
//                                                  }];
            
            request.sessionDataTask = [self.manager PATCH:url parameters:parameters headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject tempRequestJson:tempRequestJson];

            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleRequestFailureWithSessionDatatask:task error:error tempRequestJson:tempRequestJson];

            }];
            break;
        }
        default: {
            STLRequestLog(@"Error, unsupport method type");
            break;
        }
    }
    [self addRequestIdentifierWithRequest:request];
    
}

- (void)removeRequest:(OSSVBasesRequests *)request completion:(void (^)())completion {
    dispatch_async(self.requestProcessingQueue, ^{
        [request.sessionDataTask cancel];
        [self removeRequestIdentifierWithRequest:request];
        completion?completion():nil;
    });
}

- (void)removeAllRequest {
    NSDictionary *requestIdentifierDictionary = self.requestIdentifierDictionary.copy;
    for (NSString *key in requestIdentifierDictionary.allValues) {
        OSSVBasesRequests *request = self.requestIdentifierDictionary[key];
        [request.sessionDataTask cancel];
        [self.requestIdentifierDictionary removeObjectForKey:key];
    }
}

#pragma mark - Private method

- (BOOL)isValidResultWithRequest:(OSSVBasesRequests *)request {
    BOOL result = YES;
    if (request.jsonObjectValidator != nil) {
        result = [OSSVRequestsUtils isJSONObject:request.responseJSONObject
                             withJSONObjectValidator:request.jsonObjectValidator];
    }
    return result;
}

- (void)handleRequest:(OSSVBasesRequests *)request progress:(NSProgress *)progress {
    if ([request.delegate respondsToSelector:@selector(requestProgress:)]) {
        [request.delegate requestProgress:progress];
    }
    if (request.progressBlock) {
        request.progressBlock(progress);
    }
}

- (void)handleRequestSuccessWithSessionDataTask:(NSURLSessionDataTask *)sessionDataTask responseObject:(id)responseObject tempRequestJson:(NSString *)tempRequestJson {
    
    NSString *key = @(sessionDataTask.taskIdentifier).stringValue;
    OSSVBasesRequests *request = self.requestIdentifierDictionary[key];
    STLRequestLog(@"Finished Request: %@", NSStringFromClass([request class]));
    request.responseData = responseObject;
    request.isCacheData = NO;
    
    if (request) {
        if ([self isValidResultWithRequest:request]) {
            if (request.enableCache) {
                if (request.cacheJSONObject) {
                    
                }
                NSString *cacheKey = [OSSVRequestsUtils cacheKeyWithRequest:request];
                [[OSSVRequestsCachesManager sharedInstance] setObject:request.responseData forKey:cacheKey];
            }
            if ([request.delegate respondsToSelector:@selector(requestSuccess:)]) {
                [request.delegate requestSuccess:request];
            }
            if (request.successBlock) {
                request.successBlock(request);
            }
        
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            if (STLJudgeNSDictionary(requestJSON) && [requestJSON[kStatusCode] integerValue] == kStatusCode_302) {
                /////v1.0.2版本，与产品沟通
                [[OSSVAccountsManager sharedManager] clearUserInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_Logout object:nil];
                [OSSVAccountsManager reLogin];
            }

            [request accessoriesStopCallBack];
            
            [OSSVRequestsUtils debugLogWithRequest:request responseJSON:responseObject requestStatus:YES tempRequestJson:tempRequestJson];
        } else {
            
            NSString *errorLog = [NSString stringWithFormat:@"Request %@ failed, status code = %@", request.responseString, @(request.responseStatusCode)];
            
            STLRequestLog(@"Request %@ failed, status code = %@", NSStringFromClass([request class]), @(request.responseStatusCode));
            if ([request.delegate respondsToSelector:@selector(requestFailure:error:)]) {
                [request.delegate requestFailure:request error:nil];
            }
            if (request.failureBlock) {
                request.failureBlock(request, nil);
            }
            
            [request accessoriesStopCallBack];
            
            [OSSVRequestsUtils debugLogErrorWithRequest:request error:nil errorMsg:errorLog tempRequestJson:tempRequestJson];
        }
        
        //上传打印日志供测试人员使用
//        [self af_uploadRequestLogInfo:sessionDataTask
//                         responseJSON:request.responseJSONObject
//                        requestStatus:YES
//                      tempRequestJson:tempRequestJson];
    }
    [request clearCompletionBlock];
    [self removeRequestIdentifierWithRequest:request];
}

- (void)handleRequestFailureWithSessionDatatask:(NSURLSessionDataTask *)sessionDataTask error:(NSError *)error tempRequestJson:(NSString *)tempRequestJson {
    NSString *key = @(sessionDataTask.taskIdentifier).stringValue;
    OSSVBasesRequests *request = self.requestIdentifierDictionary[key];
    request.responseData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (request) {
        if ([request.delegate respondsToSelector:@selector(requestFailure:error:)]) {
            [request.delegate requestFailure:request error:error];
        }
        if (request.failureBlock) {
            request.failureBlock(request, error);
        }
        [OSSVRequestsUtils debugLogErrorWithRequest:request error:error errorMsg:nil tempRequestJson:tempRequestJson];
        [request accessoriesStopCallBack];
    }

    //上传打印日志供测试人员使用
//    NSString *tempJson = [NSString stringWithFormat:@"%@   <br/> <br/>❌❌❌❌请求报错:<br/> <br/> %@",tempRequestJson,error.description];
//    [self af_uploadRequestLogInfo:sessionDataTask
//                     responseJSON:error.description
//                    requestStatus:YES
//                  tempRequestJson:tempJson];

    
    [request clearCompletionBlock];
    [self removeRequestIdentifierWithRequest:request];
}

- (void)addRequestIdentifierWithRequest:(OSSVBasesRequests *)request {
    if (request.sessionDataTask != nil) {
        NSString *key = @(request.sessionDataTask.taskIdentifier).stringValue;
        @synchronized (self) {
            [self.requestIdentifierDictionary setObject:request forKey:key];
        }
    }
    STLRequestLog(@"Add request: %@", NSStringFromClass([request class]));
}

- (void)removeRequestIdentifierWithRequest:(OSSVBasesRequests *)request {
    NSString *key = @(request.sessionDataTask.taskIdentifier).stringValue;
    @synchronized (self) {
        [self.requestIdentifierDictionary removeObjectForKey:key];
    }
    STLRequestLog(@"Request queue size = %@", @(self.requestIdentifierDictionary.count));
}

#pragma mark - Property method

- (AFHTTPSessionManager *)manager {
    if (_manager == nil) {
        OSSVRequestsConfigs *config = [OSSVRequestsConfigs sharedInstance];
        _manager = [AFHTTPSessionManager manager];
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
        _requestProcessingQueue = dispatch_queue_create("com.adorawe.synetwork.request.processing", DISPATCH_QUEUE_SERIAL);
    }
    return _requestProcessingQueue;
}


#pragma mark -

/**
 * 上传打印日志
 */
- (void)af_uploadRequestLogInfo:(NSURLSessionDataTask *)requestParmaterTask
                   responseJSON:(NSString *)responseJSON
                  requestStatus:(BOOL)isSuccess
                tempRequestJson:(NSString *)tempRequestJson
{
    return;
    //[NetworkConfigPlugin sharedInstance].closeUrlResponsePrintfLog
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || [OSSVRequestsConfigs sharedInstance].closeUrlResponsePrintfLog) {
        return;//线上发布环境不上传日志
    }
    if (!requestParmaterTask) return;
    
    // 只有在控制面板中设置了抓包日志才上传远程日志
    if (![OSSVRequestsConfigs sharedInstance].uploadResponseJsonToLogSystem) return;
    
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
    NSString *inputCatchLogTag = [OSSVConfigDomainsManager localCatchLogTagKey];
    //开发环境打印日志
    NSString *hostTitle = [[OSSVConfigDomainsManager sharedInstance] gainCustomerBranch];
    NSString *logBody = @"";
//    if ([NetworkConfigPlugin sharedInstance].closeUrlResponsePrintfLog) {
//        logBody = [NSString stringWithFormat:@"<br/>%@%@请求接口地址 %@= %@<br/>请求参数json=<br/> %@ <br/>加密key===========%@<br/>加密Value=========%@<br/>",STLToString(inputCatchLogTag), successFlag, hostTitle, requestUrl, requestJson, requestKey, requestValue];
//    } else {
        logBody = [NSString stringWithFormat:@"<br/>%@%@请求接口地址 %@= %@<br/>请求参数json=<br/> %@ <br/>加密key===========%@<br/>加密Value=========%@<br/> <br/> 网络数据%@返回=<br/>%@",STLToString(inputCatchLogTag), successFlag, hostTitle, requestUrl, requestJson, requestKey, requestValue, requestStatus, [responseJSON yy_modelToJSONString]];
//    }
    
    NSString *responseStr = [responseJSON yy_modelToJSONString];
    NSDictionary *requestParams = @{ @"body"     : STLToString(logBody),
                                     @"level"    : @"iOS",
                                     @"domain"   : @"STL-iOS",
                                     @"platform" : [OSSVLocaslHosstManager appName],
                                     @"url"      : STLToString(requestUrl),
                                     @"request"  : STLToString(requestJson),
                                     @"response" : STLToString(responseStr),
                                     };

    NSString *uploadAddress = [OSSVConfigDomainsManager localRequestLogToUrl];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [OSSVJSONRequestsSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html", @"text/plain", nil];
    
    [manager POST:uploadAddress parameters:requestParams headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        STLLog(@"----日志上传成功");

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        STLLog(@"----日志上传失败");

    }];
}

@end
