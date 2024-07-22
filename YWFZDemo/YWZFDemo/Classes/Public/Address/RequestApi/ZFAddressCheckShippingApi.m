//
//  ZFAddressCheckShippingApi.m
//  ZZZZZ
//
//  Created by YW on 2018/12/21.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFAddressCheckShippingApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation ZFAddressCheckShippingApi{
    NSDictionary *_addressDic;
}

- (instancetype)initWithDic:(NSDictionary *)addressDic
{
    self = [super init];
    if (self) {
        _addressDic = addressDic;
    }
    return self;
}

- (BOOL)enableCache {
    return YES;
}

- (BOOL)enableAccessory {
    return YES;
}

-(BOOL)encryption {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return ENCPATH;
}

- (id)requestParameters {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:_addressDic];
    [dic setValue:@"address/check_shipping_address" forKey: @"action"];
    [dic setValue:TOKEN forKey: @"token"];
    [dic removeObjectForKey:kLoadingView];
    return dic;
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end
