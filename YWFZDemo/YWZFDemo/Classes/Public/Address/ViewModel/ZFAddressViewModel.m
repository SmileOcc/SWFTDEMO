//
//  ZFAddressViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressViewModel.h"
#import "ZFAddressInfoModel.h"
#import "ZFAddressLocationModel.h"
#import "ZFAddressLocationManager.h"
#import "YWLocalHostManager.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"

@interface ZFAddressViewModel ()
@property (nonatomic, strong) NSMutableArray<ZFAddressInfoModel *>      *dataArray;
@end

@implementation ZFAddressViewModel
/**
 * 请求地址列表
 */
- (void)requestAddressListNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    // source : 0 个人中心，1 结算页
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_AddressList);
    requestModel.taget = self.controller;
    requestModel.parmaters = @{
                               @"token"      :   TOKEN,
                               @"source"     :   ZFToString(parmaters[@"source"])
                               };
    @weakify(self);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        @strongify(self);
        NSArray *tempArray = [NSArray yy_modelArrayWithClass:[ZFAddressInfoModel class] json:responseObject[ZFResultKey][@"data"]];
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:tempArray];
        if (completion) {
            completion(self.dataArray);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

/**
 * 删除地址
 */
- (void)requestDeleteAddressNetwork:(id)parmaters completion:(void (^)(BOOL isOK))completion {
    NSDictionary *dict = parmaters;
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_DeleteAddress);
    requestModel.parmaters = @{
                               @"token"       :   TOKEN,
                               @"address_id"  :   dict[@"address_id"] ?: @""
                               };
    ShowLoadingToView(dict);
    __block BOOL _isOK = NO;
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        HideLoadingFromView(dict);
        if ([responseObject[ZFResultKey][@"error"] integerValue] == 0) {
            _isOK = YES;
        }
        if (completion) {
            completion(_isOK);
        }
        
    } failure:^(NSError *error) {
        HideLoadingFromView(dict);
        ShowToastToViewWithText(dict, ZFLocalizedString(@"Global_Network_Not_Available",nil));
    }];
}

/**
 * 选择默认地址
 */
- (void)requestsetDefaultAddressNetwork:(id)parmaters completion:(void (^)(BOOL isOK))completion {
    NSDictionary *dict = parmaters;
    ShowLoadingToView(dict);
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_ChooseDefaulAddress);
    requestModel.parmaters = @{
                               @"action"      :   @"address/default_address",
                               @"token"       :   TOKEN,
                               @"address_id"  :   dict[@"address_id"] ?: @""
                               };
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        HideLoadingFromView(dict);
        if (completion) {
            completion(YES);
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(dict);
        ShowToastToViewWithText(dict, ZFLocalizedString(@"Global_Network_Not_Available",nil));
        if (completion) {
            completion(NO);
        }
    }];
}

- (void)requestAddressLocationInfoNetwork:(id)parmaters completion:(void (^)(id obj))completion {
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_GetMapAreaList);
    requestModel.parmaters = @{
                               @"timestamp"  :   @"",
                               };
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        ZFAddressLocationModel *model = [ZFAddressLocationModel yy_modelWithJSON:responseObject[ZFResultKey]];
        //进行缓存本地
        [ZFAddressLocationManager shareManager].isOpenLocation = model.is_open;
        [[ZFAddressLocationManager shareManager] parseLocationData:model.data];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - deal with data
- (NSMutableArray<ZFAddressInfoModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
@end
