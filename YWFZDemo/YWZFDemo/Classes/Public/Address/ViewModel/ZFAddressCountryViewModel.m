//
//  ZFAddressCountryViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/9/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressCountryViewModel.h"
#import "ZFAddressCountryModel.h"
#import "YWLocalHostManager.h"
#import "ZFLocalizationString.h"
#import "ZFRequestModel.h"
#import <YYModel/YYModel.h>
#import "Constants.h"

@implementation ZFAddressCountryViewModel

#pragma mark - Requsetcompletion

+ (void)requestAddressCountryData:(void (^)(NSArray *countryDataArr))completion
                          failure:(void (^)(NSString *tipStr))failure {
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_CountryListAddress);
    requestModel.parmaters = @{ @"token" :  TOKEN };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSArray *dataArray = [NSArray arrayWithArray:[NSArray yy_modelArrayWithClass:[ZFAddressCountryModel class] json:responseObject[ZFResultKey]]];
        if (completion) {
            completion(dataArray);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(ZFLocalizedString(@"Global_Network_Not_Available",nil));
        }
    }];
}

/**
 * 个人中心获取国家地址接口 (v3.4.0及以上支持)
 */
+ (void)getMemberCountryListData:(void (^)(NSArray *countryDataArr))completion
                         failure:(void (^)(NSString *tipStr))failure {
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_getMemberCountryList);
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSArray *dataArray = [NSArray arrayWithArray:[NSArray yy_modelArrayWithClass:[ZFAddressCountryModel class] json:responseObject[ZFResultKey]]];
        if (completion) {
            completion(dataArray);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error.domain);
        }
    }];
}

@end
