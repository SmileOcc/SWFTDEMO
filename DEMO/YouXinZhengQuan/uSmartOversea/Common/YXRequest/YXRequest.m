//
//  YXRequest.m
//  YouXinZhengQuan
//
//  Created by RuiQuan Dai on 2018/7/2.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//
#import "YXRequest.h"
#import "uSmartOversea-Swift.h"
#import <QMUIKit/QMUIKit.h>
#import "YXRequestProtocol.h"

@interface YXRequest ()

@property (nonatomic, strong, readwrite) YXModel<YXRequestProtocol> *requestModel;
@property (nonatomic, assign) YXRequestType requestType;
@end

@implementation YXRequest

- (instancetype)initWithRequestModel:(YXModel<YXRequestProtocol> *)requestModel {
    if (self = [super init]) {
        self.requestModel = requestModel;
        self.delegate = self;
        if ([requestModel isKindOfClass:[YXHZBaseRequestModel class]]) {
            _requestType = YXRequestTypeHzRequest;
        } else if ([requestModel isKindOfClass:[YXJYBaseRequestModel class]]) {
            _requestType = YXRequestTypeJyRequest;
        } else if ([requestModel isKindOfClass:[YXWJBaseRequestModel class]]) {
            _requestType = YXRequestTypeWjRequest;
        }
//        else if ([requestModel isKindOfClass:[YXZXBaseRequestModel class]]) {
//            _requestType = YXRequestTypeZxRequest;
//        }
    }
    return self;
}

- (YTKRequestMethod)requestMethod {
    if ([self.requestModel respondsToSelector:@selector(yx_requestMethod)]) {
        return [self.requestModel yx_requestMethod];
    }
    return YTKRequestMethodPOST;
}

- (YTKRequestSerializerType)requestSerializerType {
    if ([self.requestModel respondsToSelector:@selector(yx_requestSerializerType)]) {
       return [self.requestModel yx_requestSerializerType];
    }
    return YTKRequestSerializerTypeJSON;
}

- (YTKResponseSerializerType)responseSerializerType {
    if ([self.requestModel respondsToSelector:@selector(yx_responseSerializerType)]) {
        return [self.requestModel yx_responseSerializerType];
    }
    return [super responseSerializerType];
}

- (NSDictionary<NSString *,NSString *> * _Nullable)requestHeaderFieldValueDictionary {
    NSMutableDictionary *header = [[YXHeaders httpHeaders] mutableCopy];
    
    if ([self.requestModel respondsToSelector:@selector(yx_requestHeaderFieldValueDictionary)]) {
        [header addEntriesFromDictionary:[self.requestModel yx_requestHeaderFieldValueDictionary]];
    }
    
    // 如果使用了全局配置的url，就不需要写host
    NSString *globalConfigHZUrl = [YXGlobalConfigManager configURLWithType:YXGlobalConfigURLTypeHzCenter];
    NSString *globalConfigJYUrl = [YXGlobalConfigManager configURLWithType:YXGlobalConfigURLTypeJyCenter];
    NSString *globalConfigWJUrl = [YXGlobalConfigManager configURLWithType:YXGlobalConfigURLTypeWjCenter];
    NSString *globalConfigZXUrl = [YXGlobalConfigManager configURLWithType:YXGlobalConfigURLTypeZxCenter];
    
    if (self.requestType == YXRequestTypeHzRequest) {
        if (![globalConfigHZUrl isEqualToString: self.requestModel.yx_baseUrl]) {
            [header setObject:[YXUrlRouterConstant hzBaseUrlWithoutScheme] forKey:@"Host"];
        }
    } else if (self.requestType == YXRequestTypeJyRequest) {
        if (![globalConfigJYUrl isEqualToString: self.requestModel.yx_baseUrl]) {
            [header setObject:[YXUrlRouterConstant jyBaseUrlWithoutScheme] forKey:@"Host"];
        }
    } else if (self.requestType == YXRequestTypeWjRequest) {
        if (![globalConfigWJUrl isEqualToString: self.requestModel.yx_baseUrl]) {
            [header setObject:[YXUrlRouterConstant wjBaseUrlWithoutScheme] forKey:@"Host"];
        }
    } else if (self.requestType == YXRequestTypeZxRequest) {
        if (![globalConfigZXUrl isEqualToString: self.requestModel.yx_baseUrl]) {
            [header setObject:[YXUrlRouterConstant zxBaseUrlWithoutScheme] forKey:@"Host"];
        }
    }
    
    return header;
}

- (NSString *)baseUrl {
    if ([self.requestModel respondsToSelector:@selector(yx_baseUrl)]) {
        return [self.requestModel yx_baseUrl];
    }
    return [super baseUrl];
}

- (NSString *)requestUrl {
    if ([self.requestModel respondsToSelector:@selector(yx_requestUrl)]) {
        return [self.requestModel yx_requestUrl];
    }
    return [super requestUrl];
}

- (id)requestArgument {
    return [self.requestModel yy_modelToJSONObject];
}

- (NSTimeInterval)requestTimeoutInterval{
    if ([self.requestModel respondsToSelector:@selector(yx_requestTimeoutInterval)]) {
        return [self.requestModel yx_requestTimeoutInterval];
    }
    return 10;
}

- (void)startWithHud {
    [self start];
}

#pragma mark - YTKRequestDelegate
- (void)requestFailed:(YXRequest *)request {
    if (request.error.code == NSURLErrorTimedOut
        && request.currentRequest.URL.host != nil
        && [request.currentRequest.URL.host length] > 0) {
        [YXUrlRouterConstant setStatusWithIP:request.currentRequest.URL.host status:NO];
    }
    
    if ([self.yx_delegate respondsToSelector:@selector(yx_requestFailed:)]) {
        [self.yx_delegate yx_requestFailed:request];
        
        if (![request statusCodeValidator] && request.responseStatusCode != 0) {
            // 如果请求失败则上报日志
            [YXRealLogger.shareInstance realLogWithType:@"ApiError" name:@"接口Error" url:request.currentRequest.URL.absoluteString code:[NSString stringWithFormat:@"%ld", (long)request.responseStatusCode] desc:@"" extend_msg:nil];
        }
       
        LOG_WARNING(kNetwork, @"request_failure \n %@, \n response=%@ \n token=%@ \n localizedDescription=%@", request, request.responseString, [[YXUserManager shared] token], request.error.localizedDescription);
    }
}

- (void)requestFinished:(YXRequest *)request {
    if ([self.yx_delegate respondsToSelector:@selector(yx_requestFinished:responseModel:)]
        && [self.requestModel respondsToSelector:@selector(yx_responseModelClass)] ) {
        YXResponseModel *model = [[self.requestModel yx_responseModelClass] yy_modelWithJSON:request.responseJSONObject];
        [self.yx_delegate yx_requestFinished:request responseModel:model];
        if (model.code == YXResponseStatusCodeAccountTokenFailure) {
            [[YXUserManager shared] tokenFailureAction];
        }
    }
}

#pragma mark - YTKRequest block
- (void)startWithBlockWithSuccess:(YXRequestCompletionBlock)success failure:(YTKRequestCompletionBlock)failure {
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        YXResponseModel *model;
        if ([self isKindOfClass:[YXRequestV2 class]]) {
            YXRequestV2 *request = (YXRequestV2 *)self;
            model = [[request responseModelClass] yy_modelWithJSON:request.responseJSONObject];
        }else {
            model = [[self.requestModel yx_responseModelClass] yy_modelWithJSON:request.responseJSONObject];
        }
        
        if (model == nil) {
            if (failure) {
                failure(request);
            }
            return;
        }
        if (success) {
            success(model);
        }
        if (model.code == YXResponseStatusCodeAccountTokenFailure) {
            [[YXUserManager shared] tokenFailureAction];
        }
        if (model.code == YXResponseStatusCodeMRTestError) {
            if (model.msg) {
                [YXProgressHUD showError:model.msg];
            }
        }
        if (model.code != YXResponseStatusCodeSuccess ) {
            if (model.code != YXResponseStatusCodeVersionDifferent && model.code != YXResponseStatusCodeVersionEqual && model.code != 800002 && model.code != 800000) {
                [YXRealLogger.shareInstance realLogWithType:@"ApiError" name:@"接口Error" url:request.currentRequest.URL.absoluteString code:[NSString stringWithFormat:@"%lu", (unsigned long)model.code] desc:model.msg extend_msg:nil];
            }
        }
     
        LOG_INFO(kNetwork, @"request_success \n %@, \n response=%@ \n token=%@", request, request.responseJSONObject, [[YXUserManager shared] token]);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (failure) {
            failure(request);
        }
        
        if (request.error.code == NSURLErrorTimedOut
            && request.currentRequest.URL.host != nil
            && [request.currentRequest.URL.host length] > 0) {
            [YXUrlRouterConstant setStatusWithIP:request.currentRequest.URL.host status:NO];
        }
        
        if (![request statusCodeValidator] && request.responseStatusCode != 0) {
            // 如果请求失败则上报日志
            [YXRealLogger.shareInstance realLogWithType:@"ApiError" name:@"接口Error" url:request.currentRequest.URL.absoluteString code:[NSString stringWithFormat:@"%ld", (long)request.responseStatusCode] desc:@"" extend_msg:nil];
        }

        LOG_WARNING(kNetwork, @"request_failure \n %@, \n requestHeaders = %@ \n response=%@ \n token=%@ \n localizedDescription=%@", request, request.requestHeaderFieldValueDictionary, request.responseString, [[YXUserManager shared] token], request.error.localizedDescription);
    }];
}


@end
