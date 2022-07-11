//
//  OSSVFlashSaleViewModel.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVFlashSaleViewModel.h"
#import "OSSVFlashSaleChannelAip.h"
#import "OSSVFlashSaleGoodsAip.h"

#import "OSSVFlashMainModel.h"
#import "OSSVFlashChannelModel.h"
#import "OSSVFlashSaleGoodsModel.h"

@interface OSSVFlashSaleViewModel ()

@property (nonatomic, strong) OSSVFlashMainModel *flashMianModel;
@property (nonatomic, strong) NSDictionary *dataDic;
@end

@implementation OSSVFlashSaleViewModel

-(void)followSwitch:(NSInteger)followId success:(void(^)(void))success{
    [[STLNetworkStateManager sharedManager] networkState:^{
        OSSVFlashSaleGoodsAip *api = [[OSSVFlashSaleGoodsAip alloc] init];
        api.followId = followId;
        api.requestType = STLFLashRequestTypeFlowSwitch;
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            if (success) {
                success();
            }
        } failure:nil];
    } exception:nil];
}

-(void)requestFlashGoodsWithParmater:(NSString *)activeId
                                     page:(NSInteger )page
                             pageSize:(NSInteger )pageSize
                          completion:(void (^)(id))completion
                             failure:(void (^)(id))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVFlashSaleGoodsAip *api = [[OSSVFlashSaleGoodsAip alloc] initWithFlashSaleGoodsWithActiveId:activeId page:page pageSize:pageSize];
        api.requestType = STLFLashRequestTypeGetGoods;
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)

            id requestJSON = [OSSVNSStringTool desEncrypt:request];

            self.dataDic = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(self.dataDic);
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
- (void)requestFlashSaleChannelWithParmater:(NSString *)channelId completion:(void (^)(id))completion failure:(void (^)(id))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVFlashSaleChannelAip *api = [[OSSVFlashSaleChannelAip alloc] initWithHomeChannelId:channelId];
          //不做缓存
//        if (api.cacheJSONObject) {
//            id requestJSON = api.cacheJSONObject;
//            self.hadGetCacheJSONObject = requestJSON;
////            self.dataArray = [self dataAnalysisFromJson: requestJSON request:api];
//            if (completion) {
//            }
//        }

        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)

            id requestJSON = [OSSVNSStringTool desEncrypt:request];

            self.flashMianModel = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(self.flashMianModel);
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

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[OSSVFlashSaleChannelAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            //NSArray *modellist = [NSArray yy_modelArrayWithClass:[OSSVFlashChannelModel class] json:json[kResult]];
            return [OSSVFlashMainModel yy_modelWithJSON:json[kResult]];
        } else {
            [self alertMessage:json[@"message"]];

          }
        } else if ([request isKindOfClass:[OSSVFlashSaleGoodsAip class]]){
            if ([json[kStatusCode] integerValue] == kStatusCode_200) {
//            NSArray *modellist = [NSArray yy_modelArrayWithClass:[OSSVFlashSaleGoodsModel class] json:json[kResult][@"goodsList"]];
//            return modellist;
                return [STLFlashTotalModel yy_modelWithJSON:json[kResult]];
            }
        } else {
            [self alertMessage:json[@"message"]];

        }
    return nil;
}
    




@end
