//
//  OSSVRequestsUtils.h
//  OSSVRequestsUtils
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT void STLRequestLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@class OSSVBasesRequests;

@interface OSSVRequestsUtils : NSObject

+ (NSString *)md5StringWithString:(NSString *)string;

+ (BOOL)isJSONObject:(id)jsonObject withJSONObjectValidator:(id)jsonObjectValidator;
+ (NSString *)cacheKeyWithRequest:(OSSVBasesRequests *)request;

+ (void)debugLogWithParams:(NSDictionary *)params url:(NSString *)url;

+ (void)debugLogWithRequest:(OSSVBasesRequests *)request responseJSON:(NSString *)responseJSON
  requestStatus:(BOOL)isSuccess
tempRequestJson:(NSString *)tempRequestJson;

+ (void)debugLogErrorWithRequest:(OSSVBasesRequests *)request error:(NSError *)error errorMsg:(NSString *)msg tempRequestJson:(NSString *)tempRequestJson;


+ (void)debugLogWithPlatform:(NSString *)platform paramsJSON:(NSString *)paramsJSON;
@end
