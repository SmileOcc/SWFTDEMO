//
//  OSSVAddresseCheckePhoneAip.m
// XStarlinkProject
//
//  Created by odd on 2020/10/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVAddresseCheckePhoneAip.h"



@interface OSSVAddresseCheckePhoneAip ()
@property (nonatomic, copy) NSString *countryId;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *countryCode;
@end


@implementation OSSVAddresseCheckePhoneAip

- (instancetype)initCheckPhone:(NSString *)phone countryId:(NSString *)countryId countryCode:(NSString *)countryCode {
    if (self = [super init]) {
        _countryId = countryId;
        _mobile = phone;
        _countryCode = countryCode;
    }
    return self;
}

- (BOOL)isNewENC {
    return NO;
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
    return [OSSVNSStringTool buildRequestPath:kApi_CountryCheckCountryPhone];
}

- (id)requestParameters {

    return @{
             @"country_id" : STLToString(_countryId),
             @"mobile"     : STLToString(_mobile),
             @"country_code": STLToString(_countryCode),
             };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
