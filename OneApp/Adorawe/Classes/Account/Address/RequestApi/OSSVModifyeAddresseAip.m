//
//  ModifyAddressRequest.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVModifyeAddresseAip.h"
#import "OSSVAddresseBookeModel.h"

@interface OSSVModifyeAddresseAip ()
@property (nonatomic, strong) OSSVAddresseBookeModel *model;
@end

@implementation OSSVModifyeAddresseAip

- (instancetype)initEditAddressRequestWithModel:(OSSVAddresseBookeModel *)model {
    if (self = [super init]) {
        _model = model;
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
    return [OSSVNSStringTool buildRequestPath:kApi_AddressEdit];
}

- (id)requestParameters {

    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             @"address_id"       : STLToString(_model.addressId),
             @"first_name"       : STLToString(_model.firstName),
             @"last_name"        : STLToString(_model.lastName),
             @"email"            : STLToString([OSSVAccountsManager sharedManager].account.email),
             @"country_id"       : STLToString(_model.countryId),
             @"country"          : STLToString(_model.country),
             @"state"            : STLToString(_model.state),
             @"city"             : STLToString(_model.city),
             @"street"           : STLToString(_model.street),
             @"zip"              : STLToString(_model.zipPostNumber),
             @"phone"            : STLToString(_model.phone),
             @"streetmore"       : STLToString(_model.streetMore),
             @"is_default"       : @(_model.isDefault),
             //@"phone_head"       : STLToString(_model.phoneHead),
             //@"second_phone_head": STLToString(_model.secondPhoneHead),
             @"second_phone"     : STLToString(_model.secondPhone),
             @"latitude"         : @(_model.latitude),
             @"longitude"        : @(_model.longitude),
             @"district"         : STLToString(_model.district),
             @"state_id"         : STLToString(_model.stateId),
             @"city_id"          : STLToString(_model.cityId),
             @"id_card"         : STLToString(_model.idCard),
             @"address_type"     : STLToString(_model.addressType),
             @"area": STLToString(_model.area),
             @"area_id": STLToString(_model.area_id),
             };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
