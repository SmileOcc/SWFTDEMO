//
//  OSSVRequestsUtils.m
//  OSSVRequestsUtils
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVRequestsUtils.h"
#import "OSSVBasesRequests.h"
#import "ZJJTimeCountDownDateTool.h"
#import <CommonCrypto/CommonCrypto.h>
#import "CountryModel.h"
#import "OSSVJSONRequestsSerializer.h"

void STLRequestLog(NSString *format, ...) {
#ifdef DEBUG
    va_list argptr;
    va_start(argptr, format);
    NSLogv(format, argptr);
    va_end(argptr);
#endif
}

@implementation OSSVRequestsUtils

+ (NSString *)md5StringWithString:(NSString *)string {
    if(string == nil || [string length] == 0) {
        return nil;
    } else {
        const char *value = [string UTF8String];
        unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
        CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
        NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
            [outputString appendFormat:@"%02x",outputBuffer[count]];
        }
        return outputString;
    }
}

+ (NSString *)methodStringWithRequest:(OSSVBasesRequests *)request {
    switch (request.requestMethod) {
        case STLRequestMethodGET:
            return @"GET";
            break;
        case STLRequestMethodPOST:
            return @"POST";
            break;
        case STLRequestMethodPUT:
            return @"PUT";
            break;
        case STLRequestMethodDELETE:
            return @"DELETE";
            break;
        case STLRequestMethodHEAD:
            return @"HEAD";
            break;
        case STLRequestMethodPATCH:
            return @"PATCH";
            break;
        default:
            return nil;
            break;
    }
}

+ (NSString *)parameterStringWithRequest:(OSSVBasesRequests *)request {
    id parameters = request.requestParameters;
    if ([parameters isKindOfClass:[NSDictionary class]] || [parameters isKindOfClass:[NSArray class]]) {
        NSError *error = nil;
        NSData *parametersData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
        if (!error) {
            return [[NSString alloc] initWithData:parametersData encoding:NSUTF8StringEncoding];
        } else {
            return nil;
        }
    } else if ([parameters isKindOfClass:[NSString class]]) {
        return parameters;
    } else {
        return nil;
    }
}

+ (BOOL)isValidateJSONObject:(id)jsonObject withJSONObjectValidator:(id)jsonObjectValidator {
    if ([jsonObject isKindOfClass:[NSDictionary class]] && [jsonObjectValidator isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = jsonObject;
        NSDictionary *validator = jsonObjectValidator;
        BOOL result = YES;
        NSEnumerator *enumerator = [validator keyEnumerator];
        NSString *key = nil;
        while ((key = [enumerator nextObject]) != nil) {
            id value = dictionary[key];
            id format = validator[key];
            if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
                result = [self isValidateJSONObject:value withJSONObjectValidator:format];
                if (!result) {
                    break;
                }
            } else {
                if ([value isKindOfClass:format] == NO && [value isKindOfClass:[NSNull class]] == NO) {
                    result = NO;
                    break;
                }
            }
        }
        return result;
    } else if ([jsonObject isKindOfClass:[NSArray class]] && [jsonObjectValidator isKindOfClass:[NSArray class]]) {
        NSArray *validatorArray = jsonObjectValidator;
        if (validatorArray.count > 0) {
            NSArray *array = jsonObject;
            NSDictionary *validator = jsonObjectValidator[0];
            for (id item in array) {
                BOOL result = [self isValidateJSONObject:item withJSONObjectValidator:validator];
                if (!result) {
                    return NO;
                }
            }
        }
        return YES;
    } else if ([jsonObject isKindOfClass:jsonObjectValidator]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)cacheKeyWithRequest:(OSSVBasesRequests *)request {
    NSString *methodString = [OSSVRequestsUtils methodStringWithRequest:request];
    NSString *prarameterString = [OSSVRequestsUtils parameterStringWithRequest:request];
    NSString *parameterMD5String = [OSSVRequestsUtils md5StringWithString:prarameterString]?:@"";
    return [NSString stringWithFormat:@"%@:%@:%@", methodString, request.requestURLString, parameterMD5String];
}

+ (void)debugLogWithRequest:(OSSVBasesRequests *)request responseJSON:(NSString *)responseJSON
  requestStatus:(BOOL)isSuccess
tempRequestJson:(NSString *)tempRequestJson
{
    
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || [OSSVRequestsConfigs sharedInstance].closeUrlResponsePrintfLog) {
        return;//线上发布环境不上传日志
    }
    
    // 只有在控制面板中设置了抓包日志才上传远程日志
    if (![OSSVRequestsConfigs sharedInstance].uploadResponseJsonToLogSystem) return;
    
    if (request.isCacheData) {
        return;
    }
    
//    if ([request.requestURLString containsString:kApi_CountryList]) {//这个数据太大了
//        return;
//    }

    id requestJSON = [OSSVNSStringTool desEncrypt:request];
    DLog(@"\nApiName----------->\n\n%@\n\n=========================================================\n\nApiUrl------------>\n\n%@\n\n=========================================================\n\nApiParams--------->\n\n%@\n\nApiParamsJson----------->\n\n%@\n\n=========================================================\n\nApiResults-------->\n\n%@", NSStringFromClass(request.class), request.requestURLString, request.requestParameters, [request.requestParameters yy_modelToJSONString], [requestJSON yy_modelToJSONString]);
    [OSSVRequestsUtils af_PostRequest:request responseJSON:[OSSVNSStringTool jsonStringWithDict:requestJSON] requestStatus:YES tempRequestJson:tempRequestJson];
    
}

+ (void)debugLogErrorWithRequest:(OSSVBasesRequests *)request error:(NSError *)error errorMsg:(NSString *)msg tempRequestJson:(NSString *)tempRequestJson
{

    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || [OSSVRequestsConfigs sharedInstance].closeUrlResponsePrintfLog) {
        return;//线上发布环境不上传日志
    }
    
    // 只有在控制面板中设置了抓包日志才上传远程日志
    if (![OSSVRequestsConfigs sharedInstance].uploadResponseJsonToLogSystem) return;
    
    if (request.isCacheData) {
        return;
    }
    //id requestJSON = [OSSVNSStringTool desEncrypt:request];
    DLog(@"\nApiName----------->\n\n%@\n\n=========================================================\n\nApiUrl------------>\n\n%@\n\n=========================================================\n\nApiParams--------->\n\n%@\n\nApiParamsJson----------->\n\n%@\n\n=========================================================\n\nApiResults-------->\n\n%@\nErrorInfo----------->\n%@", NSStringFromClass(request.class), request.requestURLString, request.requestParameters,[request.requestParameters yy_modelToJSONString], request.responseString, error);
    
    NSString *errorMsg = [NSString stringWithFormat:@"%@ <br/> <br/>❌❌❌❌请求报错:<br/> <br/> %@",request.responseString,error ? error.description : msg];
    [OSSVRequestsUtils af_PostRequest:request responseJSON:errorMsg requestStatus:NO tempRequestJson:tempRequestJson];
}

+ (void)debugLogWithParams:(NSDictionary *)params url:(NSString *)url
{
#ifdef DEBUG
    DLog(@"\n\n加密前参数\n\nApiurl----------->\n\n%@\n\n=========================================================\n\nApiParamsJson----------->%@\n\n=========================================================\n\nApiParams%@", url, [params yy_modelToJSONString], params);
    
    DLog(@"\n\n加密后参数\n\nApiurl----------->\n\n%@\n\n=========================================================\n\nApiParamsJson----------->%@\n\n=========================================================\n\nApiParams%@", url, [OSSVNSStringTool encryptWithDict:params], params);
#endif
}

+ (void)debugLogWithPlatform:(NSString *)platform paramsJSON:(NSString *)paramsJSON {
    [OSSVRequestsUtils af_PostLogPlatform:platform paramsJSON:paramsJSON];
}

+(void)af_PostRequest:(OSSVBasesRequests *)request responseJSON:(NSString *)responseJSON
  requestStatus:(BOOL)isSuccess
tempRequestJson:(NSString *)tempRequestJson
{
    
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || [OSSVRequestsConfigs sharedInstance].closeUrlResponsePrintfLog) {
        return;//线上发布环境不上传日志
    }
    
    // 只有在控制面板中设置了抓包日志才上传远程日志
    if (![OSSVRequestsConfigs sharedInstance].uploadResponseJsonToLogSystem) return;
    
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.operationQueue.maxConcurrentOperationCount = 5;
        manager.requestSerializer = [OSSVJSONRequestsSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html", @"text/plain", nil];
        
    });
    
    NSString *successFlag = isSuccess ? @"✅✅✅" : @"❌❌❌";
    NSString *requestStatus = isSuccess ? @"成功" : @"失败";
    NSString *inputCatchLogTag = [OSSVConfigDomainsManager localCatchLogTagKey];
    //开发环境打印日志
    NSString *hostTitle = [[OSSVConfigDomainsManager sharedInstance] gainCustomerBranch];
    
    NSMutableString *mutBody = [[NSMutableString alloc] init];
    NSString *requestUrl = request.requestURLString;
    
    [mutBody appendFormat:@"<br/>抓取标签: <font color='red'>%@</font> ",STLToString(inputCatchLogTag)];
    [mutBody appendFormat:@"请求分支 : <font color='red'>%@</font>", STLToString(hostTitle)];
    
    
    [mutBody appendFormat:@"<br/>请求链接 : <br/> <font color='red'>%@</font>", requestUrl];
    
    [mutBody appendFormat:@"<br/>"];
    
    [mutBody appendFormat:@"请求参数 : <br/> <font color='yellow'>%@</font>", tempRequestJson];
    
    [mutBody appendFormat:@"<br/>"];
    
    [mutBody appendFormat:@"返回结果 :%@  %@ <br/><br/> <font>%@</font>",successFlag,requestStatus,responseJSON];
    
    [mutBody appendFormat:@"<br/><br/> =========================================================== <br/>"];
    
    [mutBody appendFormat:@"%@", [OSSVLocaslHosstManager appName]];
    

    NSString *requestJson = tempRequestJson;
    //    NSData *requestData = requestParmaterTask.originalRequest.HTTPBody;
    //    if (requestData) {
    //        requestJson = [[NSString alloc] initWithData:requestData encoding:(NSUTF8StringEncoding)];
    //    }
    
//    NSString *requestKey = nil;
//    NSString *requestValue = nil;
//    NSDictionary *httpHeadDic = request.allHTTPHeaderFields;
//    for (NSString *httpHeadStr in httpHeadDic.allKeys) {
//        if (httpHeadStr.length > 25) {
//            requestKey = httpHeadStr;
//            requestValue = httpHeadDic[httpHeadStr] ? : @"";
//            break;
//        }
//    }
    
    NSString *responseStr = [responseJSON yy_modelToJSONString];
    NSDictionary *requestParams = @{ @"body"     : STLToString(mutBody),
                                     @"level"    : @"iOS",
                                     @"domain"   : @"STL-iOS",
                                     @"platform" : [OSSVLocaslHosstManager appName],
                                     @"url"      : STLToString(requestUrl),
                                     @"request"  : STLToString(requestJson),
                                     @"response" : STLToString(responseStr),
    };
    
    NSString *uploadAddress = [OSSVConfigDomainsManager localRequestLogToUrl];
//    [manager POST:uploadAddress parameters:requestParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        STLLog(@"----日志上传成功");
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        STLLog(@"----日志上传失败");
//        
//    }];
    [manager POST:uploadAddress parameters:requestParams headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        STLLog(@"----日志上传成功");

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        STLLog(@"----日志上传失败");

    }];
}


+(void)af_PostLogPlatform:(NSString *)platform paramsJSON:(NSString *)paramsJSON
{
    
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || [OSSVRequestsConfigs sharedInstance].closeUrlResponsePrintfLog) {
        return;//线上发布环境不上传日志
    }
    
    // 只有在控制面板中设置了抓包日志才上传远程日志
    if (![OSSVRequestsConfigs sharedInstance].uploadResponseJsonToLogSystem) return;
    
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.operationQueue.maxConcurrentOperationCount = 5;
        manager.requestSerializer = [OSSVJSONRequestsSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html", @"text/plain", nil];
        
    });
    
    NSString *inputCatchLogTag = [OSSVConfigDomainsManager localCatchLogTagKey];
    //开发环境打印日志
    NSString *hostTitle = [[OSSVConfigDomainsManager sharedInstance] gainCustomerBranch];
    
    NSMutableString *mutBody = [[NSMutableString alloc] init];
    
    [mutBody appendFormat:@"<br/>埋点>>>>抓取标签: <font color='red'>%@</font> ",STLToString(inputCatchLogTag)];
    [mutBody appendFormat:@"请求分支 : <font color='red'>%@</font>", STLToString(hostTitle)];
    
    [mutBody appendFormat:@"<br/>平台 : <br/> <font color='red'>%@</font>", platform];
    
    [mutBody appendFormat:@"<br/>"];
    
    [mutBody appendFormat:@"埋点参数 : <br/> <font color='yellow'>%@</font>", paramsJSON];
    
    
    [mutBody appendFormat:@"<br/><br/> =========================================================== <br/>"];
    
    [mutBody appendFormat:@"%@", [OSSVLocaslHosstManager appName]];
    
    
    NSDictionary *requestParams = @{ @"body"     : STLToString(mutBody),
                                     @"level"    : @"iOS",
                                     @"domain"   : @"STL-iOS",
                                     @"platform" : [OSSVLocaslHosstManager appName],
                                     @"platform"      : STLToString(platform),
                                     @"request"  : STLToString(paramsJSON),
                                     //@"response" : STLToString(responseStr),
    };
    
//    NSString *uploadAddress = [OSSVConfigDomainsManager localRequestLogToUrl];
//
//    [manager POST:uploadAddress parameters:requestParams headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        STLLog(@"----埋点 日志上传失败");
//
//    }];
}
@end
