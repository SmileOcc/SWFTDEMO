//
//  ZFInitializeModel.m
//  ZZZZZ
//
//  Created by YW on 2018/7/26.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFInitializeModel.h"

@implementation ZFInitCopywritingModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"registerStr"     : @"register"
             };
}

@end

@implementation ZFInitCountryInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"support_lang" : [ZFSupportLangModel class],
             };
}

@end

@implementation ZFInitExchangeModel
@end

@implementation ZFSupportLangModel
@end

@implementation ZFInitAccountContactModel
@end

@implementation ZFInitUrlList
@end

@implementation ZFInitializeModel

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"copywriting" : [ZFInitCopywritingModel class],
             @"countryInfo" : [ZFInitCountryInfoModel class],
             @"exchange" : [ZFInitExchangeModel class],
             @"contact_us" : [ZFInitAccountContactModel class],
             @"set_url_list" : [ZFInitUrlList class]
             };
}

@end
