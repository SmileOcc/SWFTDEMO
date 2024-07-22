//
//  ZFPaySuccessViewModel.m
//  ZZZZZ
//
//  Created by YW on 7/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFPaySuccessViewModel.h"
#import "ZFPaySuccessModel.h"
#import "YWLocalHostManager.h"
#import "ZFProgressHUD.h"
#import "ZFRequestModel.h"
#import <YYModel/YYModel.h>
#import "ZFPubilcKeyDefiner.h"

@implementation ZFPaySuccessViewModel

- (void)requestPaySuccessNetwork:(NSString *)orderSN completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    ZFRequestModel *model = [[ZFRequestModel alloc] init];
    model.url = API(Port_paySuccess);
    model.parmaters = @{@"order_sn" : orderSN};
    model.taget = self.controller;
    
    ShowLoadingToView(nil);
    [ZFNetworkHttpRequest sendRequestWithParmaters:model success:^(id responseObject) {
        HideLoadingFromView(nil);
        ZFPaySuccessModel *model = [ZFPaySuccessModel yy_modelWithJSON:responseObject[ZFResultKey]];
        if (completion) {
            completion(model);
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);
        if (failure) {
            failure(nil);
        }
    }];
}

@end
