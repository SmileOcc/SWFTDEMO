//
//  STLBindPhoneNumViewModel.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLBindPhoneNumViewModel.h"
#import "STLBindPhoneAPI.h"
#import "OSSVAddresseCheckePhoneAip.h"

@implementation STLBindPhoneNumViewModel
///请求接口

-(void)requestInfo:(void (^)(id obj, NSString *msg))completion failure:(void (^)(_Nullable id obj, NSString *msg))failure{
    
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        NSDictionary * dict = @{};
        STLBindPhoneAPI *bindApi = [[STLBindPhoneAPI alloc] initWithParam:dict];
        [bindApi.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [bindApi  startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            
            if ([[requestJSON objectForKey:@"statusCode"] intValue] != 200) {
                if (failure) {
                    failure(nil,STLLocalizedString_(@"networkFailed", nil));
                }
                return;
            }
            NSDictionary* result = [requestJSON objectForKey:@"result"];
            
            STLBindCountryResultModel *reaultModel = [STLBindCountryResultModel yy_modelWithJSON:result];
            self.countryModel = reaultModel;
            if (completion) {
                completion(reaultModel,@"");
            }
            
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil,STLLocalizedString_(@"networkFailed", nil));
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil,STLLocalizedString_(@"networkFailed", nil));
        }
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkErrorMsg", nil)];
    }];
}

-(void)checkPhoneNum:(id)parmaters completion:(void (^)(id obj, NSString *msg))completion failure:(void (^)(id obj, NSString *msg))failure{
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        OSSVAddresseCheckePhoneAip *api = [[OSSVAddresseCheckePhoneAip alloc] initCheckPhone:STLToString(parmaters[@"mobile"]) countryId:STLToString(parmaters[@"country_id"]) countryCode:STLToString(parmaters[@"country_code"])];
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            if (completion) {
                completion(requestJSON,nil);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            STLLog(@"%@", error);
            if (failure) {
                failure(nil,STLLocalizedString_(@"networkFailed", nil));
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil,STLLocalizedString_(@"networkFailed", nil));
        }
    }];
}


-(void)sendPhoneNum:(id)parms completion:(void (^)(id obj, NSString *msg))completion failure:(void (^)(id obj, NSString *msg))failure{
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        NSDictionary * dict = parms;
        STLBindPhoneAPI *bindApi = [[STLBindPhoneAPI alloc] initWithParam:dict];
        bindApi.sentPhoneNum = YES;
        [bindApi.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [bindApi  startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            NSString *mesage = [requestJSON objectForKey:@"message"];
            if ([[requestJSON objectForKey:@"statusCode"] intValue] != 200) {
                if (failure) {
                    failure(nil,mesage);
                }
                return;
            }
            
            if (completion) {
                completion(requestJSON,mesage);
            }
            
            
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil,STLLocalizedString_(@"networkFailed", nil));
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil,STLLocalizedString_(@"networkFailed", nil));
        }
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkErrorMsg", nil)];
    }];
}

-(void)setCountryModel:(STLBindCountryResultModel *)countryModel{
    _countryModel = countryModel;
    NSMutableDictionary<NSString *,NSMutableArray *> *dict = [[NSMutableDictionary alloc] init];
    for (STLBindCountryModel *country in countryModel.countries) {
        NSString *key = @"*";
//        if (country.country_code.length > 1) {
//            key = [country.country_code substringToIndex:1];
//        }
        if (country.country_name.length > 1) {
            key = [country.country_name substringToIndex:1];
        }
        NSMutableArray *arr = [dict objectForKey:key];
        if (!arr) {
            arr = [[NSMutableArray alloc] init];
            [dict setObject:arr forKey:key];
        }
        [arr addObject:country];
    }
    
    NSArray *keys = [dict.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    NSMutableArray<STLBIndCountryGroup *> *keyArr = [[NSMutableArray alloc] init];
    for (NSString *key in keys) {
        STLBIndCountryGroup *group = [[STLBIndCountryGroup alloc] init];
        group.key = key;
        group.countries = [dict objectForKey:key];
        [keyArr addObject:group];
    }
    _keyArr = [keyArr copy];
}
@end
