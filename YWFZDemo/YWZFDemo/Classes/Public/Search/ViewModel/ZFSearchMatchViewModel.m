
//
//  ZFSearchMatchViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/12/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchMatchViewModel.h"
#import "ZFSearchKeyMatchApi.h"
#import "ZFSearchMatchModel.h"
#import "NSStringUtils.h"
#import <YYModel/YYModel.h>
#import "ZFNetworkHttpRequest.h"
#import "ZFRequestModel.h"
#import "ZFApiDefiner.h"
#import "YWLocalHostManager.h"
#import "ZFPubilcKeyDefiner.h"

@interface ZFSearchMatchViewModel()

@end

@implementation ZFSearchMatchViewModel

- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    ZFSearchKeyMatchApi *api = [[ZFSearchKeyMatchApi alloc] initSearchResultApiWithSearchString:parmaters];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        ZFSearchMatchModel *matchModel = [ZFSearchMatchModel yy_modelWithJSON:requestJSON];
        if (matchModel.statusCode == 200) {
            if (completion) {
                completion(matchModel.result);
            }
        } else {
            failure(nil);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        
    }];
}

- (void)requestGetHotWordData:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_getHotWord);
    requestModel.needToCache = YES;
    requestModel.parmaters = parmaters;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        NSArray * resultArray = responseObject[ZFResultKey];
        if (completion) {
            completion(resultArray);
        }
    } failure:nil];
}

@end
