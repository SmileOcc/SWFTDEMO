//
//  OSSVPhoneeAreaeCodeModel.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVPhoneeAreaeCodeModel.h"

@implementation OSSVPhoneeAreaeCodeModel


+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"countryAreaCode"       : @"country_area_code",
             @"ruleModel"             : @"phone_rule"
//             @"phoneNumberHeader"     : @"phone_rule.phone_number_header",
//             @"phoneNumberLength"  : @"phone_rule.phone_number_length",
//             @"phoneOperatorsHeadNumbe"     : @"phone_rule.mobile_operators_head_number",
//             @"phoneRemainLength"   : @"phone_rule.remain_number_length",
//             @"phoneErrorTextEn"    : @"phone_rule.error_text_en",
//             @"phoneErrorTextAr"    : @"phone_rule.error_text_ar"

             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"countryAreaCode",
             @"ruleModel"
//             @"phoneNumberHeader",
//             @"phoneNumberLength",
//             @"phoneOperatorsHeadNumbe",
//             @"phoneRemainLength",
//             @"phoneErrorTextEn",
//             @"phoneErrorTextAr"
             ];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"ruleModel"      : [STLPhoneRuleModel class],
             };
}

@end


@implementation STLPhoneRuleModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
//             @"countryAreaCode"       : @"country_area_code",
             @"phoneNumberHeader"     : @"phone_rule.phone_number_header",
             @"phoneNumberLength"  : @"phone_rule.phone_number_length",
             @"phoneOperatorsHeadNumbe"     : @"phone_rule.mobile_operators_head_number",
             @"phoneRemainLength"   : @"phone_rule.remain_number_length",
             @"phoneErrorTextEn"    : @"phone_rule.error_text_en",
             @"phoneErrorTextAr"    : @"phone_rule.error_text_ar"

             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
//             @"countryAreaCode",
             @"phoneNumberHeader",
             @"phoneNumberLength",
             @"phoneOperatorsHeadNumbe",
             @"phoneRemainLength",
             @"phoneErrorTextEn",
             @"phoneErrorTextAr"
             ];
}

@end
