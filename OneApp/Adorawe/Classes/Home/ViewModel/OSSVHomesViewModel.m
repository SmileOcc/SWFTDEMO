//
//  HomeViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomesViewModel.h"
#import "OSSVHomesChannelsApi.h"
#import "OSSVHomeChannelsModel.h"
#import "UpdateAppModel.h"
#import "OSSVMessageListAip.h"
#import "OSSVMessageListModel.h"
#import "OSSVCurrentsCountysAip.h"
#import "OSSVBannersHomesFloatAip.h"
#import "OSSVOrdersWarnsCountrysInfoModel.h"

@interface OSSVHomesViewModel ()

@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation OSSVHomesViewModel

#pragma mark - Requset
// 获取当前用户国家编码
//- (void)requestNetworkWithOrderWarnWithCompletion:(void (^)(id))completion failure:(void (^)(id))failure {
//    
//    @weakify(self)
//    [[STLNetworkStateManager sharedManager] networkState:^{
//        STLCurrentCountryApi *api = [[STLCurrentCountryApi alloc] init];
//        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
//            @strongify(self)
//            id requestJSON = [OSSVNSStringTool desEncrypt:request];
//            if (completion) {
//                completion([self dataAnalysisFromJson: requestJSON request:api]);
//            }
//        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
//        }];
//    } exception:^{
//    }];
//}

- (void)homeRequest:(id)parmaters completion:(void (^)(id result, BOOL isCache, BOOL isEqualData))completion failure:(void (^)(id))failure{
    
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVHomesChannelsApi *api = [[OSSVHomesChannelsApi alloc] init];
        
        if (api.cacheJSONObject) {
            id requestJSON = api.cacheJSONObject;
            self.hadGetCacheJSONObject = requestJSON;
            self.dataArray = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(self.dataArray, YES, NO);
            }
        }
        
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            if(self.hadGetCacheJSONObject && [self.hadGetCacheJSONObject isEqualToDictionary: requestJSON]) {
                if (completion) {
                    completion(self.dataArray, NO, YES);
                }
                return;
            }
            
            self.dataArray = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(self.dataArray, NO, NO);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
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

- (void)messageRequest:(id)parmaters
            completion:(void (^)(id))completion
               failure:(void (^)(id))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVMessageListAip *api = [[OSSVMessageListAip alloc] init];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            OSSVMessageListModel *messageModel = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(messageModel);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure){
                failure(nil);
            }
        }];
    } exception:^{
        if (failure)
        {
            failure(nil);
        }
    }];
}

///首页浮窗
- (void)requestHomeFloatWithCompletion:(void (^)(OSSVAdvsEventsModel *))completion failure:(void (^)(id))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVBannersHomesFloatAip *api = [[OSSVBannersHomesFloatAip alloc] init];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            OSSVAdvsEventsModel *messageModel = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(messageModel);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure){
                failure(nil);
            }
        }];
    } exception:^{
        if (failure)
        {
            failure(nil);
        }
    }];
}
- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request
{
    if ([request isKindOfClass:[OSSVHomesChannelsApi class]])
    {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
            return [NSArray yy_modelArrayWithClass:[OSSVHomeChannelsModel class] json:json[kResult]];
        }
        else
        {
             [self alertMessage:json[@"message"]];
        }
    }
    else if ([request isKindOfClass:[OSSVMessageListAip class]])
    {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
            return [OSSVMessageListModel yy_modelWithJSON:json[kResult]];
        }
    }
    else if ([request isKindOfClass:[OSSVCurrentsCountysAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
            return [OSSVOrdersWarnsCountrysInfoModel yy_modelWithJSON:json[kResult]];
        }
    } else if ([request isKindOfClass:[OSSVBannersHomesFloatAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
            return [OSSVAdvsEventsModel yy_modelWithJSON:json[kResult]];
        }
    }
    return nil;
}

@end
