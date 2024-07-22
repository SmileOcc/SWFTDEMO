//
//  ZFOrderDetailViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderDetailViewModel.h"
#import "OrderDetailApi.h"
#import "OrdersCancelApi.h"
#import "ZFTrackingPackageApi.h"
#import "RemindersApi.h"
#import "ZFReturnToBagApi.h"
#import "ZFOrderRefundApi.h"

#import "ZFOrderDeatailListModel.h"
#import "ZFTrackingPackageModel.h"
#import "ZFTrackingListModel.h"
#import "ZFOrderRefundModel.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "YWLocalHostManager.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import <YYModel/YYModel.h>
#import "Constants.h"
#import "ZFCommunityMoreHotTopicListModel.h"

@implementation ZFOrderDetailViewModel

#pragma mark - request methods

- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    NSDictionary *dict = parmaters;
    ShowLoadingToView(dict);
    OrderDetailApi *api = [[OrderDetailApi alloc] initWithOrderId:dict[@"order_id"]];
    api.taget = self.controller;
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            NSDictionary *resultDict = requestJSON[ZFResultKey];
            if (ZFJudgeNSDictionary(resultDict)) {
                NSDictionary *returnInfoDict = resultDict[@"returnInfo"];
                if (returnInfoDict) {
                    ZFOrderDeatailListModel *model = [ZFOrderDeatailListModel yy_modelWithJSON:returnInfoDict];
                    [self requestOrderDetailTopicBanner:^(ZFCommunityMoreHotTopicModel *obj) {
                        HideLoadingFromView(dict);
                        if (completion) {
                            model.orderTopicImageUrl = obj.ios_orderpic;
                            model.orderTopicId = obj.topicId;
                            completion(model);
                        }
                    } failure:^(id obj) {
                        HideLoadingFromView(dict);
                        if (completion) {
                            completion(model);
                        }
                    }];
                    return ;
                }
            }
        }
        if (failure) {
            HideLoadingFromView(dict);
            failure(nil);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(dict);
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestCancelOrderNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    __block BOOL isSuccess = NO;
    NSDictionary *dict = parmaters;
    ShowLoadingToView(dict);
    OrdersCancelApi *api = [[OrdersCancelApi alloc] initWithOrderId:dict[@"order_id"]];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(dict);
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200){
            if ([requestJSON[ZFResultKey][@"error"] integerValue] == 0) {
                isSuccess = YES;
            }else{
                ShowToastToViewWithText(dict, requestJSON[ZFResultKey][@"msg"]);
            }
            if (completion) {
                completion(@(isSuccess));
            }
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        ShowToastToViewWithText(dict, ZFLocalizedString(@"Global_Network_Not_Available",nil));
    }];
}

- (void)requestTrackingPackageData:(id)parmaters completion:(void (^)(NSArray<ZFTrackingPackageModel *> *array, NSString *trackMessage, NSString *trackingState))completion failure:(void (^)(id obj))failure {
    NSDictionary *dict = parmaters;
    ShowLoadingToView(dict);
    ZFTrackingPackageApi *api = [[ZFTrackingPackageApi alloc] initWithOrderID:dict[@"order_id"]];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(dict);
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            NSArray<ZFTrackingPackageModel *> *dataArray = [NSArray yy_modelArrayWithClass:[ZFTrackingPackageModel class] json:requestJSON[ZFResultKey][@"data"]];
            //修改物流时间逆序排序
            [dataArray enumerateObjectsUsingBlock:^(ZFTrackingPackageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *sortArray = [self sortTrackingInfoListWithTrakingArray:obj.track_list];
                obj.track_list = sortArray;
            }];
            NSString *trackingMessage = requestJSON[ZFResultKey][@"msg"];
            NSString *trackingState  = requestJSON[ZFResultKey][@"state"];
            if (completion) {
                completion(dataArray, trackingMessage, trackingState);
            }
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(dict);
        YWLog(@"\n-------------------------- 错误日志 --------------------------\n接口:%@\n状态码:%ld\n报错信息:%@",NSStringFromClass(api.class),(long)api.responseStatusCode,api.responseString);
    }];
}

- (void)requestReturnToBag:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSDictionary *dict = parmaters;
    //针对问卷调查添加的字段，默认为0
    NSString *force_add = @"0";
    if (dict[@"force_add"]) {
        force_add = dict[@"force_add"];
    }
    ZFReturnToBagApi *api = [[ZFReturnToBagApi alloc] initWithorderID:dict[@"order_id"] forceId:force_add];
    ShowLoadingToView(dict);
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(dict);
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            if ([requestJSON[ZFResultKey][@"error"] integerValue] == 0) {
                ShowToastToViewWithText(dict, ZFLocalizedString(@"ReturnToBagSuccessfully", nil));
                if (completion) {
                    completion(nil);
                }
            }else{
                ShowToastToViewWithText(dict, requestJSON[ZFResultKey][@"msg"]);
            }
        }else{
            if (failure) {
                failure(nil);
            }
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(dict);
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestRefundNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    ZFRequestModel *model = [[ZFRequestModel alloc] init];
    model.url = API(@"order/request_refund");
    model.parmaters = parmaters;
    [ZFNetworkHttpRequest sendRequestWithParmaters:model success:^(id responseObject) {
        ZFOrderRefundModel *model = [ZFOrderRefundModel yy_modelWithJSON:responseObject[ZFResultKey]];
        if (completion) {
            completion(model);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

/*
 *  确认订单
 */
- (void)requestConfirmOrder:(NSString *)orderSn completion:(void (^)(NSInteger status, NSError *error))completion
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(@"order/confirm_cod_order_address");
    requestModel.parmaters = @{
                               @"order_sn" : orderSn
                               };
    ShowLoadingToView(nil);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        HideLoadingFromView(nil);
        NSDictionary *result = responseObject[ZFResultKey];
        NSInteger status = [result[@"status"] integerValue];
        if (status) {
            if (completion) {
                completion(status, nil);
            }
        } else {
            NSString *msg = result[@"errorMsg"];
            ShowToastToViewWithText(nil, (ZFToString(msg)));
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);
        if (completion) {
            completion(0, error);
        }
    }];
}

- (NSArray *)sortTrackingInfoListWithTrakingArray:(NSArray <ZFTrackingListModel *>*)array {
    //先扫描数组处理一遍时间
    [array enumerateObjectsUsingBlock:^(ZFTrackingListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm MMM.dd yyyy";
        NSDate *createDate = [formatter dateFromString:obj.ondate];
        obj.trackTime = [createDate timeIntervalSince1970];
    }];
    NSArray *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(ZFTrackingListModel *  _Nonnull obj1, ZFTrackingListModel *  _Nonnull obj2) {
        if(obj1.trackTime < obj2.trackTime) {
            return NSOrderedDescending;
        }
        if(obj1.trackTime > obj2.trackTime){
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    return sortArray;
}

/*
 *  请求一个商品详情的社区banner
 */
- (void)requestOrderDetailTopicBanner:(void(^)(ZFCommunityMoreHotTopicModel *obj))completion failure:(void (^)(id obj))failure;
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"type"] = @"9";
    info[@"directory"] = @"45";
    info[@"site"] = @"ZZZZZcommunity";
    info[@"app_type"] = @"2";
    info[@"user_id"] = USERID ?: @"0";
    info[@"pageSize"] = @"15";
    info[@"version"] = ZFToString(ZFSYSTEM_VERSION);
    info[@"curPage"] = @"1";
    info[@"orderStatus"] = @"1";
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.parmaters = info;
    requestModel.url = CommunityAPI;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        NSDictionary *result = responseObject[@"data"];
        ZFCommunityMoreHotTopicListModel *model = [ZFCommunityMoreHotTopicListModel yy_modelWithJSON:result];
        if ([model.topic.firstObject isKindOfClass:[ZFCommunityMoreHotTopicModel class]]) {
            ZFCommunityMoreHotTopicModel *topicModel = model.topic.firstObject;
            if (completion) {
                completion(topicModel);
            }
        } else {
            if (failure) {
                failure(nil);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

@end

