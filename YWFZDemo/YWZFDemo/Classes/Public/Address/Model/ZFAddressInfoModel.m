//
//  ZFAddressInfoModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressInfoModel.h"
#import "AccountManager.h"

@implementation ZFAddressInfoModel
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"address_id",
             @"is_default",
             @"user_id",
             @"firstname",
             @"lastname",
             @"id_card",
             @"email",
             @"tel",
             @"country_id",
             @"country_str",
             @"ownState",
             @"province_id",
             @"province",
             @"ownCity",
             @"city",
             @"addressline1",
             @"addressline2",
             @"supplier_number_list",
             @"scut_number_list",
             @"supplier_number",
             @"number",
             @"zipcode",
             @"code",
             @"configured_number",
             @"landmark",
             @"whatsapp",
             @"telspare",
             @"supplier_number_spare",
             @"is_cod",
             @"google_longitude",
             @"google_latitude",
             @"region_code",
             @"barangay",
             @"showFourLevel",
             @"ownBarangay",
             @"support_zip_code",
             ];
}

#pragma mark - multible copying
- (id)mutableCopyWithZone:(NSZone *)zone {
    ZFAddressInfoModel *model = [[ZFAddressInfoModel allocWithZone:zone] init];
    model.address_id = self.address_id;
    model.user_id = self.user_id;
    model.firstname = self.firstname;
    model.lastname = self.lastname;
    model.email = self.email != nil ? self.email : [AccountManager sharedManager].account.email;
    model.tel = self.tel;
    model.code = self.code;
    model.country_id = self.country_id;
    model.country_str = self.country_str;
    model.province_id = self.province_id;
    model.province = self.province;
    model.city = self.city;
    model.id_card = self.id_card;
    model.zipcode = self.zipcode;
    model.addressline1 = self.addressline1;
    model.addressline2 = self.addressline2;
    model.supplier_number_list = self.supplier_number_list;
    model.supplier_number = self.supplier_number;
//    model.number = self.number;
    model.scut_number_list = self.scut_number_list;
    model.is_default = self.is_default;
    model.ownState = self.ownState;
    model.ownCity = self.ownCity;
    model.configured_number = self.configured_number;
    model.landmark = self.landmark;
    model.telspare = self.telspare;
    model.whatsapp = self.whatsapp;
    model.supplier_number_spare = self.supplier_number_spare;
    model.is_cod = self.is_cod;
    model.google_latitude = self.google_latitude;
    model.google_longitude = self.google_longitude;
    model.region_code = self.region_code;
    model.barangay = self.barangay;
    model.showFourLevel = self.showFourLevel;
    model.ownBarangay = self.ownBarangay;
    model.support_zip_code = self.support_zip_code;
    return model;
}

/**
 * 防止服务端返回空的号码尾数 (V3.5.0废弃)
- (NSString *)number {
    if (!_number || ZFIsEmptyString(_number) || [_number isEqualToString:@"0"]) {
        _number = @"20";
    }
    return _number;
}
*/

/**
 * 最大兼容数固定20位, 非服务端返回, 本地写死的
 */
- (NSString *)maxPhoneLength
{
    return @"20";
}

/**
 * 最小兼容数固定6位, 非服务端返回, 本地写死的
 */
- (NSString *)minPhoneLength
{
    return @"6";
}


- (BOOL)isMustZip {
    if ([self.country_id isEqualToString:kZF_IRELAND_ID]
        || [self.country_id isEqualToString:kZF_CHINA_HONG_KONG_ID]
        || [self.country_id isEqualToString:kZF_SAUDI_ARABIA_ID]
        || [self.country_id isEqualToString:kZF_UNITED_ARAB_EMIRATES_ID]
        || [self.country_id isEqualToString:kZF_PERU_ID]
        || [self.country_id isEqualToString:kZF_COLOMBIA_ID]) {
        return NO;
    }
    return YES;
}

- (BOOL)isIndiaCountry {
    if ([self.country_id isEqualToString:kZF_INDIA_ID]) {
        return YES;
    }
    return NO;
}

- (BOOL)isSouthKoreaCountry
{
    if ([self.country_id isEqualToString:@"235"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isCanadaCountry {
    if ([self.country_id isEqualToString:kZF_CANADA_ID]) {
        return YES;
    }
    return NO;
}

- (BOOL)isPhilippinesCountry {
    if ([self.country_id isEqualToString:kZF_PHILIPPINES_ID]) {
        return YES;
    }
    return NO;
}

- (BOOL)isRomaniaCountry {
    if ([self.country_id isEqualToString:kZF_ROMANIA_ID]) {
        return YES;
    }
    return NO;
}

- (BOOL)isAllNumberFirstAddressLine {

    if ([self.addressline1 length] > 0) {
        NSString *stringRegex = @"^[0-9]*$";
        NSPredicate *stringTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
        return [stringTest evaluateWithObject:self.addressline1];
    }
    return NO;
}

- (BOOL)isContainSpecialMarkFirstAddressLine {
    if ([self.addressline1 length] > 0) {
        NSRange validRange = [self.addressline1 rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @"“”\""]];
        if (validRange.location != NSNotFound) {
            return YES;
        }        
    }
    return NO;
}

- (BOOL)isContainSpecialEmailMarkFirstAddressLine {
    if ([self.addressline1 length] > 0) {
        NSRange validRange = [self.addressline1 rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @"@@"]];
        if (validRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isContainSpecialMarkName:(NSString *)name {
    if ([name length] > 0) {
        NSRange validRange = [name rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @"（~`#$%^*()=[]{}\\‘“;<>）"]];
        if (validRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isTestCountry {
    // occ测试数据
    return YES;
    if ([self.country_id isEqualToString:kZF_TEST_ID]) {
        return YES;
    }
    return NO;
}
@end
