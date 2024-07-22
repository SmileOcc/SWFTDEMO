//
//  ZFMyOrderListViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"
@class ZFTrackingPackageModel, ZFMyOrderListModel;

@interface ZFMyOrderListViewModel : BaseViewModel

/*
 * 请求订单列表信息
 */
- (void)requestOrderListNetwork:(BOOL)isFirstPage
                     completion:(void (^)(ZFMyOrderListModel *orderlistModel, NSDictionary *pageDic))completion;

/*
 * 请求将订单商品放回购物车
 */
- (void)requestReturnToBag:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

/*
 * 请求物流追踪信息
 */
- (void)requestTrackingPackageData:(id)parmaters completion:(void (^)(NSArray<ZFTrackingPackageModel *> *array, NSString *trackMessage, NSString *trackingState))completion failure:(void (^)(id obj))failure;

/**
 * 催付接口
 */
+ (void)requestRushPay:(NSString *)orderID;

/*
 * 请求订单退款
 */
- (void)requestRefundNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;
@end

