//
//  STLGetPhoneAreaCode.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVGetePhoneAreaeCodeAip.h"

@interface OSSVGetePhoneAreaeCodeAip (){
    NSString *_countryCode;
}
@end

@implementation OSSVGetePhoneAreaeCodeAip
   
- (instancetype)initGetPhoneAreaCodeForCountryCode:(NSString *)countryCode {
    if (self = [super init]) {
        _countryCode  = countryCode;
    }
    return self;
    
}

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}


- (NSString *)requestPath {
    return kApi_GetPhoneAreaCode;
}

-(NSString *)domainPath{
    return masterDomain;
}

- (id)requestParameters {
    return @{@"country_code":STLToString(_countryCode)};
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
