//
//  ZFAddressModifyViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFLocationInfoModel.h"
#import "ZFAddressOMSOrderAddressModel.h"

@interface ZFAddressModifyViewModel : BaseViewModel


//智能获取城市
- (void)requestAddressGetCity:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

//地址纠错
- (void)requestCheckShippingAddress:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

//城市对应邮编
- (void)requestCityZipAddress:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

/**
 * 获取当前国家
 */
- (void)requestCountryName:(void (^)(NSDictionary *countryInfoDic))completion;

/**
 * 获取内部定位地址信息
 */
- (void)requestLocationAddress:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

/**
 * 获取修改订单oms地址配置信息
 */
- (void)requestAddressOrderSN:(NSString *)orderSn completion:(void (^)(ZFAddressOMSOrderAddressModel *omsAddressModel, NSInteger status))completion;

/**
 * 保存修改订单地址信息
 */
- (void)requestSaveAddressOrder:(NSDictionary *)parmaters completion:(void (^)(NSString *msg,NSInteger status))completion;

@end
