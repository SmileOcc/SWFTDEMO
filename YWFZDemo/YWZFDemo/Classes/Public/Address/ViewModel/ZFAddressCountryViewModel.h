//
//  ZFAddressCountryViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/9/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFAddressCountryViewModel : BaseViewModel

/**
 * 收货地址:选择国家地址
 */
+ (void)requestAddressCountryData:(void (^)(NSArray *countryDataArr))completion
                          failure:(void (^)(NSString *tipStr))failure;

/**
 * 个人中心获取国家地址接口 (v3.4.0及以上支持)
 */
+ (void)getMemberCountryListData:(void (^)(NSArray *countryDataArr))completion
                         failure:(void (^)(NSString *tipStr))failure;

@end
