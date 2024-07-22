//
//  SYNetworkUtil.h
//  SYNetwork
//
//  Created by YW on 16/5/28.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT void SYNetworkLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@class SYBaseRequest;

@interface SYNetworkUtil : NSObject

+ (BOOL)isValidateJSONObject:(id)jsonObject withJSONObjectValidator:(id)jsonObjectValidator;
+ (NSString *)cacheKeyWithRequest:(SYBaseRequest *)request;

@end
