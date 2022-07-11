//
//  OSSVAddresseDeleteeAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAddresseDeleteeAip.h"


@implementation OSSVAddresseDeleteeAip {
    
    NSString *_addressId;
}

- (instancetype)initWithAddressDeleteId:(NSString *)addressId {
    
    self = [super init];
    if (self) {
        _addressId = addressId;
    }
    return self;
}

- (BOOL)isNewENC {
    if ([OSSVConfigDomainsManager domainEnvironment] == DomainType_DeveTrunk ||
        [OSSVConfigDomainsManager domainEnvironment] == DomainType_DeveInput) {
        return NO;
    }
    return YES;
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
    return [OSSVNSStringTool buildRequestPath:kApi_AddressDelete];
}

- (id)requestParameters {

    return @{
             @"commparam"   : [OSSVNSStringTool buildCommparam],
             @"address_id"  : _addressId
             };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}


@end
