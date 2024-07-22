//
//  ZFAddressModifyViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressModifyViewModel.h"
#import "ZFCheckShippingAddressModel.h"

#import "ZFAddressAddApi.h"
#import "ZFAddressGetCityApi.h"
#import "ZFAddressCheckShippingApi.h"
#import "ZFAddressCityZipApi.h"

#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "AccountManager.h"
#import "ZFPubilcKeyDefiner.h"
#import "ZFApiDefiner.h"
#import "YWLocalHostManager.h"
#import "NSDictionary+SafeAccess.h"
#import <GGBrainKeeper/BrainKeeperManager.h>
#import "AFNetworking.h"
#import "Constants.h"
#import <YYModel/YYModel.h>

@implementation ZFAddressModifyViewModel

- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSDictionary *dict = parmaters;
    ShowLoadingToView(dict);
    ZFAddressAddApi *addressBookApi = [[ZFAddressAddApi alloc] initWithDic:parmaters];// 接口address/edit_address
    addressBookApi.eventName = @"save_address";
    addressBookApi.taget = self.controller;
    [addressBookApi  startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(dict);
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(addressBookApi.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            if ([requestJSON[ZFResultKey][@"error"] integerValue] == 0) {
                [[AccountManager sharedManager] updateUserDefaultAddressId:[NSString stringWithFormat:@"%@",requestJSON[ZFResultKey][@"address_id"]]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    ShowToastToViewWithText(dict, ZFLocalizedString(@"ModifyAddress_Success_Show_Message",nil));
                });
                if (completion) {
                    completion(requestJSON[@"result"]);
                }
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    ShowToastToViewWithText(dict, requestJSON[ZFResultKey][@"msg"]);
                });
                if (failure) {
                    failure(requestJSON[ZFResultKey]);
                }
            }
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(dict);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ShowToastToViewWithText(dict, ZFLocalizedString(@"Global_Network_Not_Available",nil));
        });
        if (failure) {
            failure(nil);
        }
    }];
}



- (void)requestAddressGetCity:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    NSDictionary *dict = parmaters;
    //ShowLoadingToView(dict);
    ZFAddressGetCityApi *addressCityApi = [[ZFAddressGetCityApi alloc] initWithDic:parmaters];
    [addressCityApi  startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        //HideLoadingFromView(dict);
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(addressCityApi.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            if ([requestJSON[ZFResultKey][@"error"] integerValue] == 0) {
                //[[AccountManager sharedManager] updateUserDefaultAddressId:[NSString stringWithFormat:@"%@",requestJSON[ZFResultKey][@"address_id"]]];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    ShowToastToViewWithText(dict, ZFLocalizedString(@"ModifyAddress_Success_Show_Message",nil));
//                });
                if (completion) {
                    completion(requestJSON[@"result"]);
                }
            } else {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    ShowToastToViewWithText(dict, requestJSON[ZFResultKey][@"msg"]);
//                });
            }
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(dict);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            ShowToastToViewWithText(dict, ZFLocalizedString(@"Global_Network_Not_Available",nil));
//        });
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestCheckShippingAddress:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    ZFAddressCheckShippingApi *addressBookApi = [[ZFAddressCheckShippingApi alloc] initWithDic:parmaters];
    addressBookApi.eventName = @"check_shipping";
    addressBookApi.taget = self.controller;
    [addressBookApi  startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        ZFCheckShippingAddressModel *checkModel;
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(addressBookApi.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            if ([requestJSON[ZFResultKey][@"code"] integerValue] == 1) {//地址有问题
                
                NSDictionary *dateDic = requestJSON[ZFResultKey][ZFDataKey];
                if (ZFJudgeNSDictionary(dateDic)) {
                    checkModel = [ZFCheckShippingAddressModel yy_modelWithJSON:dateDic];
                }
            }
        }
        if (completion) {
            completion(checkModel);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}


//城市对应邮编
- (void)requestCityZipAddress:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    ZFAddressCityZipApi *addressZipApi = [[ZFAddressCityZipApi alloc] initWithDic:parmaters];
    [addressZipApi  startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        NSArray *zipArray;
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(addressZipApi.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            if ([requestJSON[ZFResultKey][@"error"] integerValue] == 0) {
                NSDictionary *dataDic = requestJSON[ZFResultKey][ZFDataKey];
                if (ZFJudgeNSDictionary(dataDic)) {
                    zipArray = dataDic[@"zipcode"];
                }
            }
        }
        
        if (ZFJudgeNSArray(zipArray)) {
            if (completion) {
                completion(zipArray);
            }
        } else {
            if (failure) {
                failure(nil);
            }
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        
        if (failure) {
            failure(nil);
        }
    }];
}

/**
 * 请求当前国家信息
 */
- (void)requestCountryName:(void (^)(NSDictionary *countryInfoDic))completion {
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_get_cur_country_info);
    requestModel.taget = self.controller;
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *resultDic = responseObject[ZFResultKey];
        if (completion) {
            if (ZFJudgeNSDictionary(resultDic)) {
                completion(resultDic);
            } else {
                completion(nil);
            }
        }
        
        if (ZFJudgeNSDictionary(resultDic)) {
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSString *country = [resultDic ds_stringForKey:@"country"];
            [user setObject:country forKey:kCountryName];
            [user synchronize];
        }
    } failure:^(NSError *error) {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:@"United States" forKey:kCountryName];
        [user synchronize];
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)requestLocationAddress:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    NSDictionary *parDic = @{@"latitude"  : ZFToString(parmaters[@"latitude"]),
                             @"longitude" : ZFToString(parmaters[@"longitude"]),
                             @"site"      : @"ZZZZZ_ios",
                             @"return_number": @1,//默认返回一条
                             @"out_language":ZFToString(lang)};
    NSDictionary *formDataParms = @{ @"method" : @"aas.address.auto-latlng",
                                     @"content" : [parDic yy_modelToJSONString],};

    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    [sessionManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    [sessionManager POST:[YWLocalHostManager addressLocationApiURL] parameters:formDataParms constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData){
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nonnull responseObject){
        
        YWLog(@"ZZZZZ内部定位: 成功======%@",responseObject);
        ZFAddressLocationInfoModel *inforModel;
        if (ZFJudgeNSDictionary(responseObject)) {
            if ([responseObject[@"code"] integerValue] == 0) {
                NSArray *datas = responseObject[@"data"];
                if (ZFJudgeNSArray(datas)) {
                    NSDictionary *firstDic = datas.firstObject;
                    inforModel = [ZFAddressLocationInfoModel yy_modelWithJSON:firstDic];
                }
            }
        }
        if (completion) {
            completion(inforModel);
        }
        
        if (![ZFNetworkConfigPlugin sharedInstance].isDistributionOnlineRelease) { //线上发布环境不上传日志
            ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
            requestModel.url = [YWLocalHostManager addressLocationApiURL];
            requestModel.parmaters = formDataParms;
            [ZFNetworkHttpRequest uploadStatisticsLog:requestModel responseObject:responseObject];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        YWLog(@"ZZZZZ内部定位: 失败======%@",error);
        if (completion) {
            completion(nil);
        }
        
        if (![ZFNetworkConfigPlugin sharedInstance].isDistributionOnlineRelease) { //线上发布环境不上传日志
            ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
            requestModel.url = [YWLocalHostManager addressLocationApiURL];
            requestModel.parmaters = formDataParms;
            [ZFNetworkHttpRequest uploadStatisticsLog:requestModel responseObject:error];
        }
    }];
}

- (void)requestAddressOrderSN:(NSString *)orderSn completion:(void (^)(ZFAddressOMSOrderAddressModel *omsAddressModel, NSInteger status))completion {
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_get_oms_order_address);
    requestModel.taget = self.controller;
    requestModel.parmaters = @{@"order_sn" : ZFToString(orderSn),
                               @"user_id"  : USERID ?: @"0",};
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        NSDictionary *resultDic = responseObject[ZFResultKey];
        ZFAddressOMSOrderAddressModel *omsAddressModel;
        NSInteger status = 404;
        
        if (completion) {
            if (ZFJudgeNSDictionary(resultDic)) {
                NSDictionary *dataDic = resultDic[@"data"];
                
                if (ZFJudgeNSDictionary(dataDic)) {
                    status = [dataDic[@"status"] integerValue];
                    if (status == 1) {
                        omsAddressModel = [ZFAddressOMSOrderAddressModel yy_modelWithJSON:dataDic];
                    }
                }
            }
            completion(omsAddressModel,status);
        }
        
    } failure:^(NSError *error) {
        if (completion) {
            completion(nil,404);
        }
    }];
}

- (void)requestSaveAddressOrder:(NSDictionary *)parmaters completion:(void (^)(NSString *msg,NSInteger status))completion {
    
    NSDictionary *parDic = @{@"order_sn"  : ZFToString(parmaters[@"order_sn"]),
                             @"landmark"  : ZFToString(parmaters[@"landmark"]),
                             @"country"   : ZFToString(parmaters[@"country"]),
                             @"province"  : ZFToString(parmaters[@"province"]),
                             @"city"      : ZFToString(parmaters[@"city"]),
                             @"barangay"  : ZFToString(parmaters[@"barangay"]),
                             @"zipcode"   : ZFToString(parmaters[@"zipcode"]),
                             @"tel"       : ZFToString(parmaters[@"tel"]),
                             @"address1"  : ZFToString(parmaters[@"address1"]),
                             @"address2"  : ZFToString(parmaters[@"address2"])};
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_order_Detail_Change_Address);
    requestModel.taget = self.controller;
    requestModel.parmaters = parDic;
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        NSDictionary *resultDic = responseObject[ZFResultKey];
        NSInteger status = 404;
        NSString *msg = @"";
        if (completion) {
            if (ZFJudgeNSDictionary(resultDic)) {
                NSDictionary *dataDic = resultDic[@"data"];
                
                if (ZFJudgeNSDictionary(dataDic)) {
                    status = [dataDic[@"status"] integerValue];
                    msg = ZFToString(dataDic[@"msg"]);
                }
            }
            completion(msg,status);
        }
    } failure:^(NSError *error) {
        
        if (completion) {
            completion(nil,404);
        }
    }];
}
@end
