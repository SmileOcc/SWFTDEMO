//
//  ZFOrderDetailViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFCommunityMoreHotTopicModel.h"

@class ZFTrackingPackageModel;

@interface ZFOrderDetailViewModel : BaseViewModel
/*
 * 订单详情数据请求接口
 * parmaters : orderId
 */
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

/*
 * 取消订单
 * parmaters : orderId
 */
- (void)requestCancelOrderNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

/*
 * 请求物流追踪信息
 */
- (void)requestTrackingPackageData:(id)parmaters completion:(void (^)(NSArray<ZFTrackingPackageModel *> *array, NSString *trackMessage, NSString *trackingState))completion failure:(void (^)(id obj))failure;

/*
 * 请求将订单商品放回购物车
 */
- (void)requestReturnToBag:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

/*
 * 请求订单退款
 */
- (void)requestRefundNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

/*
 *  确认订单
 */
- (void)requestConfirmOrder:(NSString *)orderSn completion:(void (^)(NSInteger status, NSError *error))completion;

@end

