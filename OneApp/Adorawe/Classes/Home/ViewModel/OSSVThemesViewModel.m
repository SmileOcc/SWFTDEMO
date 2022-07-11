//
//  STLThemeViewModel.m
// XStarlinkProject
//
//  Created by odd on 2021/4/1.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVThemesViewModel.h"

@import FirebasePerformance;

@implementation OSSVThemesViewModel

#pragma mark --原生专题页数据请求
- (void)themeOldRequest:(id)parmaters completion:(void (^)(id result, BOOL isCache, BOOL isEqualData))completion failure:(void (^)(id))failure {
    
    if (!STLJudgeNSDictionary(parmaters)) {
        parmaters = @{};
    }
//    STLThemeSpecialApi *api = [[STLThemeSpecialApi alloc] initWithCustomeId:STLToString(parmaters[@"specialId"])];
    OSSVThemesSpecialsAip *api = [[OSSVThemesSpecialsAip alloc] initWithCustomeId:STLToString(parmaters[@"specialId"]) deepLinkId:STLToString(parmaters[@"deep_link_id"])];
    __block FIRTrace *trace = [FIRPerformance startTraceWithName:@"special/index"];
    if (self.isShowLoad) {
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.contentView]];
    }
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        [trace stop];
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        OSSVThemesMainsModel *resultModel = [self dataAnalysisFromJson: requestJSON request:api];
        if (resultModel) {
            if (completion) {
                completion(resultModel,NO,NO);
            }
        } else {
            if (failure) {
                failure(nil);
            }
        }

    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        NSLog(@"%@", error);
        [trace stop];
        if (failure) {
            failure(nil);
        }
    }];
}

#pragma mark ---原生专题 新----数据请求
- (void)themeRequest:(id)parmaters completion:(void (^)(id result, BOOL isCache, BOOL isEqualData))completion failure:(void (^)(id))failure {
    
    if (!STLJudgeNSDictionary(parmaters)) {
        parmaters = @{};
    }
    OSSVThemesSpecialActiviyAip *api = [[OSSVThemesSpecialActiviyAip alloc] initWithCustomeId:STLToString(parmaters[@"specialId"])];
    if (self.isShowLoad) {    
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.contentView]];
    }
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        OSSVThemesMainsModel *resultModel = [self dataAnalysisFromJson: requestJSON request:api];
        if (resultModel) {
            if (completion) {
                completion(resultModel,NO,NO);
            }
        } else {
            if (failure) {
                failure(nil);
            }
        }

    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        NSLog(@"%@", error);

        if (failure) {
            failure(nil);
        }
    }];
}

#pragma mark --///原生专题商品 新 数据请求
- (void)themeActivityGoodsRequest:(id)parmaters completion:(void (^)(id result, BOOL isRanking))completion failure:(void (^)(id))failure {
    
    if (!STLJudgeNSDictionary(parmaters)) {
        parmaters = @{};
    }
    OSSVThemesActivtyGoodAip *api = [[OSSVThemesActivtyGoodAip alloc] initWithCustomeId:STLToString(parmaters[@"specialId"]) type:STLToString(parmaters[@"type"]) page:[parmaters[@"page"] intValue] pageSize:20];
    if (self.isShowLoad) {    
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.contentView]];
    }
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        NSDictionary *resultDic = [self dataAnalysisFromJson: requestJSON request:api];
        
        if (STLJudgeNSDictionary(resultDic)) {
            NSArray *resultArr = [NSArray yy_modelArrayWithClass:[STLHomeCGoodsModel class] json:resultDic[@"goodsList"]];;
            if (completion) {
                completion(resultArr, [resultDic[@"ranking"] intValue] == 1 ? YES : NO);
            }
        } else {
            if (failure) {
                failure(nil);
            }
        }

    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        NSLog(@"%@", error);

        if (failure) {
            failure(nil);
        }
    }];
}

#pragma mark //原生专题导航商品 数据请求
- (void)themeOldActivityGoodsRequest:(id)parmaters completion:(void (^)(id result, BOOL isRanking))completion failure:(void (^)(id))failure {
    
    if (!STLJudgeNSDictionary(parmaters)) {
        parmaters = @{};
    }
    OSSVCustomThemesChannelsGoodsAip *api = [[OSSVCustomThemesChannelsGoodsAip alloc] initWithCustomeId:STLToString(parmaters[@"specialId"]) sort:@"" type:STLToString(parmaters[@"type"]) page:[parmaters[@"page"] intValue]];
//    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        //拿到数据，拼接，然后保存到customProductListCache缓存
//        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
            NSArray *goodsList = [NSArray yy_modelArrayWithClass:[STLHomeCGoodsModel class] json:requestJSON[kResult][@"goodsList"]];
                if (completion) {
                    completion(goodsList, 1);
                }
        } else {
            if (completion) {
                completion(@[], 1);
            }
        }
       
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (completion) {
            completion(@[], 0);
        }
    }];
}

// 加入了ranking_type字段 （排序方式 1是销量 2是收藏）
- (void)themeOldActivityGoodsRequestWithType:(id)parmaters completion:(void (^)(id result, BOOL isRanking, NSInteger ranking_type))completion failure:(void (^)(id))failure{
    
    if (!STLJudgeNSDictionary(parmaters)) {
        parmaters = @{};
    }
    OSSVCustomThemesChannelsGoodsAip *api = [[OSSVCustomThemesChannelsGoodsAip alloc] initWithCustomeId:STLToString(parmaters[@"specialId"]) sort:@"" type:STLToString(parmaters[@"type"]) page:[parmaters[@"page"] intValue]];
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        //拿到数据，拼接，然后保存到customProductListCache缓存
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
            NSArray *goodsList = [NSArray yy_modelArrayWithClass:[STLHomeCGoodsModel class] json:requestJSON[kResult][@"goodsList"]];
            NSInteger ranking_type = [requestJSON[kResult][@"ranking"] integerValue];
                if (completion) {
                    completion(goodsList, 1, ranking_type);
                }
        } else {
            if (completion) {
                completion(@[], 1, 0);
            }
        }
       
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (completion) {
            completion(@[], 0, 0);
        }
    }];
}


- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request
{
    if ([request isKindOfClass:[OSSVThemesSpecialActiviyAip class]])
    {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
            return [OSSVThemesMainsModel yy_modelWithJSON:json[kResult]];
        } else {
             [self alertMessage:json[@"message"]];
        }
    }
    else if ([request isKindOfClass:[OSSVThemesActivtyGoodAip class]])
    {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
//            return [NSArray yy_modelArrayWithClass:[STLHomeCGoodsModel class] json:json[kResult][@"goodsList"]];
            return json[kResult];

        }
    } else if([request isKindOfClass:[OSSVThemesSpecialsAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
            return [OSSVThemesMainsModel yy_modelWithJSON:json[kResult]];
        } else {
             [self alertMessage:json[@"message"]];
        }
    } else if([request isKindOfClass:[OSSVCustomThemesChannelsGoodsAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
//            return [NSArray yy_modelArrayWithClass:[STLHomeCGoodsModel class] json:json[kResult][@"goodsList"]];
            return json[kResult];

        }
    }
    return nil;
}
@end
