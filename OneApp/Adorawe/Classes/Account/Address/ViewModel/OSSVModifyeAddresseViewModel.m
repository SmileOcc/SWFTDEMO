//
//  OSSVModifyeAddresseViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVModifyeAddresseViewModel.h"
#import "OSSVModifyeAddresseAip.h"
#import "OSSVAddresseAddeAip.h"
#import "OSSVAddresseCheckePhoneAip.h"
#import "OSSVAddresseBookeModel.h"


@implementation OSSVModifyeAddresseViewModel
#pragma mark - Requset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVAddresseAddeAip *api = [[OSSVAddresseAddeAip alloc] initAddressAddRequestWithModel:parmaters];
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
//            [self dataAnalysisFromJson:request.responseJSONObject request:api];
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            if([self dataAnalysisFromJson: requestJSON request:api]) {
                
                
                if ([requestJSON[kResult] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *addressDic = requestJSON[kResult];
                    if (completion) {
                        NSString *addressId = [addressDic[@"address_id"] stringValue];
                        completion(addressId);
                    }
                    return ;
                }
                if (completion) {
                    completion(@"");
                }
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            STLLog(@"%@", error);
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
    
}

- (void)requestEditAddressNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVModifyeAddresseAip *api = [[OSSVModifyeAddresseAip alloc]initEditAddressRequestWithModel:parmaters];
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
//            [self dataAnalysisFromJson:request.responseJSONObject request:api];
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            if([self dataAnalysisFromJson: requestJSON request:api]) {
                if (completion) {
                    completion(nil);
                }
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            STLLog(@"%@", error);
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}


- (void)requestAddressPhoneCheckNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVAddresseCheckePhoneAip *api = [[OSSVAddresseCheckePhoneAip alloc] initCheckPhone:STLToString(parmaters[@"mobile"]) countryId:STLToString(parmaters[@"country_id"]) countryCode:STLToString(parmaters[@"country_code"])];

        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            NSString *msg = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(msg);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            STLLog(@"%@", error);
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}


- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    
    if ([request isKindOfClass:[OSSVModifyeAddresseAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            [self alertMessage:json[@"message"]];
            return @YES;
        }
        else {
            [self alertMessage:json[@"message"]];
        }
    } else if ([request isKindOfClass:[OSSVAddresseAddeAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            [self alertMessage:json[@"message"]];
            return @YES;
        }
        else {
            [self alertMessage:json[@"message"]];
        }
    }  else if ([request isKindOfClass:[OSSVAddresseCheckePhoneAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_201) {
            [self alertMessage:json[@"message"]];
            return STLToString(json[@"message"]);
        } else {
            return nil;
        }
    }
    return nil;
}


@end
