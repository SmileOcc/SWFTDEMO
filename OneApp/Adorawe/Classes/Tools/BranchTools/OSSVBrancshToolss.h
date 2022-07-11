//
//  OSSVBrancshToolss.h
// XStarlinkProject
//
//  Created by fan wang on 2021/6/4.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBranchUtmSource @"branchUtmSource"

NS_ASSUME_NONNULL_BEGIN
///Branch 埋点归因
@interface OSSVBrancshToolss : NSObject

///浏览商品详情
+(void)logViewItem:(NSDictionary *)productInfo;
///加入购物车 复用神策的dict
+(void)logAddToCart:(NSDictionary *)product;
///开始结账
+(void)logInitPurchase:(NSDictionary *)product;
///生成订单
+(void)logAddPaymentInfo:(NSDictionary *)product;
///计入GMV
+(void)logPurchaseGMV:(NSDictionary *)info;


///统计push
+(void)logPush:(NSDictionary *)pushInfo;

///注册
+(void)logCompleteRegistration:(NSDictionary *)registerInfo;
@end

NS_ASSUME_NONNULL_END
