//
//  ZFMyOrderListViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFMyOrderListViewModel.h"
#import "MyOrdersListApi.h"
#import "ZFReturnToBagApi.h"
#import "RemindersApi.h"
#import "ZFTrackingPackageApi.h"
#import "ZFOrderRefundApi.h"
#import "MyOrdersModel.h"
#import "ZFMyOrderListModel.h"
#import "ZFTrackingPackageModel.h"
#import "ZFTrackingListModel.h"
#import "ZFOrderRefundModel.h"
#import "YWLocalHostManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ZFAnalyticsTimeManager.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import <YYModel/YYModel.h>
#import "Constants.h"

@interface ZFMyOrderListViewModel()
@property (nonatomic, assign) NSInteger                 curPage;
@property (nonatomic, strong) ZFMyOrderListModel        *listModel;
@property (nonatomic, strong) NSMutableArray            *dataArray;
@end

@implementation ZFMyOrderListViewModel

#pragma mark - request methods
- (void)requestOrderListNetwork:(BOOL)isFirstPage
                     completion:(void (^)(ZFMyOrderListModel *orderlistModel, NSDictionary *pageDic))completion
{
    if (isFirstPage) {
        self.curPage = 1;
    } else {
        self.curPage = ++self.curPage;
    }
    MyOrdersListApi *api = [[MyOrdersListApi alloc] initWithPage:self.curPage];
    api.taget = self.controller;
    
    [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:@"order/index" requestTime:ZFRequestTimeBegin];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:@"order/index" requestTime:ZFRequestTimeEnd];
        
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            
            self.listModel = [ZFMyOrderListModel yy_modelWithJSON:requestJSON[ZFResultKey]];
            if (isFirstPage) {
                [self.dataArray removeAllObjects];
            }
            [self.dataArray addObjectsFromArray:self.listModel.data];
            self.listModel.data = self.dataArray;
            
            if (completion) {
                NSDictionary *pageDic = @{kTotalPageKey:@([self.listModel.total_page integerValue]),
                                          kCurrentPageKey:@([self.listModel.page integerValue])};
                completion(self.listModel, pageDic);
            }
        } else { //失败
            --self.curPage;
            if (completion) {
                completion(self.listModel, nil);
            }
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        --self.curPage;
        if (completion) {
            completion(self.listModel, nil);
        }
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
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestReturnToBag:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSDictionary *dict = parmaters;
    ShowLoadingToView(dict);
    
    ZFReturnToBagApi *api = [[ZFReturnToBagApi alloc] initWithOrderID:dict[@"order_id"]];
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
    ZFOrderRefundApi *api = [[ZFOrderRefundApi alloc] initWithOrderSn:parmaters];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            ZFOrderRefundModel *model = [ZFOrderRefundModel yy_modelWithJSON:requestJSON[ZFResultKey]];
            if (completion) {
                completion(model);
            }
        } else {
            if (failure) {
                failure(nil);
            }
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

+ (void)requestRushPay:(NSString *)orderID {
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_orderRushPay);
    requestModel.parmaters = @{
                               @"order_id"    :   ZFToString(orderID),
                               @"pid"         :   [NSStringUtils getPid],
                               @"c"           :   [NSStringUtils getC],
                               @"is_retargeting": [NSStringUtils getIsRetargeting]
                               };
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
    } failure:^(NSError *error) {
    }];
}

#pragma mark - data methods
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


#pragma mark - getter
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
