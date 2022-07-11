//
//  OSSVRecomendGoodViewModel.m
// XStarlinkProject
//
//  Created by odd on 2020/8/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVRecomendGoodViewModel.h"
#import "OSSVAccountRecomendGoodssAip.h"
#import "Adorawe-Swift.h"

@implementation OSSVRecomendGoodViewModel

- (void)recommendRequest:(id)parmaters completion:(void (^)(id,NSString *))completion failure:(void (^)(id))failure {
    
    OSSVAccountRecomendGoodssAip *recommendGoodsApi = [[OSSVAccountRecomendGoodssAip alloc] init];
    
    //第一次读取缓存
//    if (recommendGoodsApi.cacheJSONObject && self.dataArrays.count <= 0) {
//        id requestJSON = recommendGoodsApi.cacheJSONObject;
//        NSArray *array = [self dataAnalysisFromJson: requestJSON request:recommendGoodsApi];
//
//        if (completion) {
//            completion(array);
//        }
//    }
    
    // 开始请求
    @weakify(self)
    [recommendGoodsApi  startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        NSArray *array = [self dataAnalysisFromJson: requestJSON request:recommendGoodsApi];
        
        if (completion) {
            if(STLJudgeNSDictionary(requestJSON[kResult])){
                NSString *requestId =  [ABTestTools Recommand_abWithRequestId:requestJSON[kResult][@"request_id"]];
                completion(array,STLToString(requestId));
            }else{
                completion(array,@"");
            }
            
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

-(NSMutableArray<OSSVHomeGoodsListModel *> *)dataArrays {
    if (!_dataArrays) {
        _dataArrays = [[NSMutableArray alloc] init];
    }
    return _dataArrays;
}

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[OSSVAccountRecomendGoodssAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            if(STLJudgeNSDictionary(json[kResult])){
                return [NSArray yy_modelArrayWithClass:OSSVHomeGoodsListModel.class json:json[kResult][@"goodsList"] ?: @{}];
            }else{
                return [NSArray yy_modelArrayWithClass:OSSVHomeGoodsListModel.class json:json[kResult] ?: @{}];
            }
            
        }
        else {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}

@end
