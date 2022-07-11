//
//  OSSVGoogleeMapAddresseCollectAip.m
// XStarlinkProject
//
//  Created by Kevin on 2021/4/24.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVGoogleeMapAddresseCollectAip.h"

@interface OSSVGoogleeMapAddresseCollectAip (){
    
    NSString *_countryCode;
    NSString *_countryName;
    NSString *_proviceName;
    NSString *_cityName;
    NSString *_latitude;
    NSString *_longitude;
    NSString *_addressDetail;
    NSString *_areaName;

}
@end

@implementation OSSVGoogleeMapAddresseCollectAip

- (instancetype)initGoogleMapAddressWithCountryCode:(NSString *)countryCode countryName:(NSString *)countryName proviceName:(NSString *)proviceName cityName:(NSString *)cityName latitude:(NSString *)latitude longitude:(NSString *)longitude address:(NSString *)addressDetail areaName:(NSString *)areaName {
    if (self = [super init]) {
        _countryCode = countryCode;
        _countryName = countryName;
        _proviceName = proviceName;
        _cityName    = cityName;
        _latitude    = latitude;
        _longitude   = longitude;
        _addressDetail = addressDetail;
        _areaName    = areaName;

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
    return [OSSVNSStringTool buildRequestPath:kApi_googleMapAddressCollect];
}

- (id)requestParameters {

    return @{
             @"country_code"     : STLToString(_countryCode),
             @"country_name"     : STLToString(_countryName),
             @"province_name"    : STLToString(_proviceName),
             @"city_name"        : STLToString(_cityName),
             @"area_name"        : STLToString(_areaName),
             @"address_info"     : STLToString(_addressDetail),
             @"longitude"        : STLToString(_longitude),
             @"latitude"         : STLToString(_latitude)

             };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
