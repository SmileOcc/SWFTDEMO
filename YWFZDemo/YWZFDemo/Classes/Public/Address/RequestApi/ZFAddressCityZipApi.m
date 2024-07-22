//
//  ZFAddressCityZipApi.m
//  ZZZZZ
//
//  Created by YW on 2019/4/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressCityZipApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation ZFAddressCityZipApi{
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
    [dic setValue:@"address/by_city_query_zip_code" forKey: @"action"];
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
