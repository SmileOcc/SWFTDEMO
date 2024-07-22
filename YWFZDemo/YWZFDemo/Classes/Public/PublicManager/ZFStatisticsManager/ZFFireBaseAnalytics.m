//
//  ZFFireBaseAnalytics.m
//  ZZZZZ
//
//  Created by YW on 2017/11/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFFireBaseAnalytics.h"

#import <Firebase/Firebase.h>
#import <FirebaseAnalytics/FIREventNames.h>
#import <FirebaseAnalytics/FIRParameterNames.h>

#import "GoodsDetailModel.h"
#import "ZFOrderCheckDoneDetailModel.h"
#import "ZFOrderCheckInfoDetailModel.h"
#import "ExchangeManager.h"
#import "ZFBaseOrderModel.h"

@implementation ZFFireBaseAnalytics

+ (void)firebaseLogEventWithName:(NSString *)eventName parameters:(nullable NSDictionary<NSString *, id> *)parameters {
    [FIRAnalytics logEventWithName:eventName parameters:parameters];
}

+ (void)screenRecordWithName:(nonnull NSString *)screenName screenClass:(nullable NSString *)screenClass {
    [FIRAnalytics setScreenName:screenName screenClass:screenClass];
}

+ (void)appOpen {
    [self firebaseLogEventWithName:kFIREventAppOpen parameters:nil];
}

+ (void)addPaymentInfo {
    [self firebaseLogEventWithName:kFIREventAddPaymentInfo parameters:nil];
}

+ (void)scanGoodsWithGoodsModel:(GoodsDetailModel *)goodsModel {
    [self firebaseLogEventWithName:kFIREventViewItem parameters:@{
                                                                  kFIRParameterItemID: [ZFFireBaseAnalytics filterString:goodsModel.goods_sn],
                                                                  kFIRParameterItemName: [ZFFireBaseAnalytics filterString:goodsModel.goods_name],
                                                                  kFIRParameterItemCategory: [ZFFireBaseAnalytics filterString:goodsModel.long_cat_name]
                                                                  }];
}

+ (void)scanGoodsListWithCategory:(NSString *)categaory {
    [self firebaseLogEventWithName:kFIREventViewItemList parameters:@{
                                                                      kFIRParameterItemCategory: [ZFFireBaseAnalytics filterString:categaory]
                                                                      }];
}

+ (void)searchResultWithTerm:(NSString *)term {
    [self firebaseLogEventWithName:kFIREventViewSearchResults parameters:@{
                                                                           kFIRParameterSearchTerm: [ZFFireBaseAnalytics filterString:term]
                                                                           }];
}

+ (void)addToCartWithGoodsModel:(GoodsDetailModel *)goodsModel {
    [self firebaseLogEventWithName:kFIREventAddToCart parameters:@{
                                                                   kFIRParameterItemID: [ZFFireBaseAnalytics filterString:goodsModel.goods_sn],
                                                                   kFIRParameterItemName: [ZFFireBaseAnalytics filterString:goodsModel.goods_name],
                                                                   kFIRParameterItemCategory: [ZFFireBaseAnalytics filterString:goodsModel.long_cat_name],
                                                                   kFIRParameterQuantity: goodsModel.buyNumbers > 0 ? @(goodsModel.buyNumbers) : @(1),
                                                                   kFIRParameterPrice: @([goodsModel.shop_price floatValue]),
                                                                   kFIRParameterCurrency: @"USD",
                                                                   kFIRParameterValue: @([goodsModel.shop_price floatValue])
                                                                   }];
}

+ (void)addCollectionWithGoodsModel:(GoodsDetailModel *)goodsModel {
    [self firebaseLogEventWithName:kFIREventAddToWishlist parameters:@{
                                                                   kFIRParameterItemID: [ZFFireBaseAnalytics filterString:goodsModel.goods_sn],
                                                                   kFIRParameterItemName: [ZFFireBaseAnalytics filterString:goodsModel.goods_name],
                                                                   kFIRParameterItemCategory: [ZFFireBaseAnalytics filterString:goodsModel.long_cat_name],
                                                                   kFIRParameterQuantity: @(1),
                                                                   kFIRParameterPrice: @([goodsModel.shop_price floatValue]),
                                                                   kFIRParameterCurrency: @"USD",
                                                                   kFIRParameterValue: @([goodsModel.shop_price floatValue])
                                                                   }];
}

+ (void)beginCheckOutWithGoodsInfo:(nullable ZFOrderCheckInfoDetailModel *)goodsInfo {
    NSDictionary *params;
    if (goodsInfo == nil) {
        params = nil;
    } else {
        params = @{
                                 kFIRParameterCurrency: @"USD",
                                 kFIRParameterValue: @([[ZFFireBaseAnalytics filterString:goodsInfo.total.goods_price] floatValue]),
                                 kFIRParameterCoupon: [ZFFireBaseAnalytics filterString:goodsInfo.total.coupon_code]
                                 };
    }
    [self firebaseLogEventWithName:kFIREventBeginCheckout parameters:params];
}

+ (void)createOrderWithOrderModel:(nullable ZFOrderCheckDoneDetailModel *)orderModel {
    [self firebaseLogEventWithName:@"creat_order_susccess" parameters:@{
                                                                           kFIRParameterTransactionID: [ZFFireBaseAnalytics filterString:orderModel.order_sn],
                                                                           kFIRParameterValue: @([[ZFFireBaseAnalytics filterString:orderModel.hacker_point.order_real_pay_amount] floatValue]),
                                                                           kFIRParameterShipping: @([[ZFFireBaseAnalytics filterString:orderModel.shipping_fee] floatValue]),
                                                                           kFIRParameterCurrency: @"USD",
                                                                           kFIRParameterCoupon:[ZFFireBaseAnalytics filterString:orderModel.hacker_point.coupon_name]
                                                                           }];
}

+ (void)finishedPurchaseWithOrderModel:(ZFBaseOrderModel *)orderModel {
    [self firebaseLogEventWithName:kFIREventEcommercePurchase parameters:@{
                                                                           kFIRParameterTransactionID: [ZFFireBaseAnalytics filterString:orderModel.order_sn],
                                                                           kFIRParameterValue: @([[ZFFireBaseAnalytics filterString:orderModel.hacker_point.order_real_pay_amount] floatValue]),
                                                                           kFIRParameterShipping: @([[ZFFireBaseAnalytics filterString:orderModel.shipping_fee] floatValue]),
                                                                           kFIRParameterCurrency: @"USD",
                                                                           kFIRParameterCoupon:[ZFFireBaseAnalytics filterString:orderModel.hacker_point.coupon_name]
                                                                           }];
}

+ (void)signUpWithType:(NSString *)typeName {
    [self firebaseLogEventWithName:kFIREventSignUp parameters:@{
                                                                kFIRParameterSignUpMethod: typeName
                                                                }];
}

+ (void)signInWithTypeName:(NSString *)typeName {
    [self firebaseLogEventWithName:kFIREventLogin parameters:@{
                                                                kFIRParameterSignUpMethod: typeName
                                                                }];
}

+ (void)selectContentWithItemId:(NSString *)itemId
                       itemName:(NSString *)itemName
                    ContentType:(NSString *)contentType
                   itemCategory:(NSString *)category {
    [self firebaseLogEventWithName:kFIREventSelectContent parameters:@{
                                                                       kFIRParameterItemID: [ZFFireBaseAnalytics filterString:itemId],
                                                                       kFIRParameterItemName: [ZFFireBaseAnalytics filterString:itemName],
                                                                       kFIRParameterContentType: [ZFFireBaseAnalytics filterString:contentType],
                                                                       kFIRParameterItemCategory: [ZFFireBaseAnalytics filterString:category]
                                                                       }];
}
    
+ (void)checkoutProgressWithStep:(NSInteger)step checkInfoModel:(ZFOrderCheckInfoDetailModel *)checkInfoModel {
    [self firebaseLogEventWithName:kFIREventCheckoutProgress parameters:@{
                                                                          kFIRParameterCheckoutStep: @(step),
                                                                          kFIRParameterContentType: @"OrderDetail",
                                                                          kFIRParameterPrice: @([[ZFFireBaseAnalytics filterString:checkInfoModel.total.goods_price] floatValue]),
                                                                          kFIRParameterCoupon: [ZFFireBaseAnalytics filterString:checkInfoModel.total.coupon_code],
                                                                          kFIRParameterCurrency: [ExchangeManager localCurrency]
                                                                          }];
}

// 过滤特殊字符，不然统计闪退（数据库不能保存特殊字符）
+ (NSString *)filterString:(NSString *)string {
    if (![string isKindOfClass:[NSString class]]
        || [string length] == 0) {
        return @"";
    }
    NSCharacterSet *notAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）「」＂、[]{}#%*+=\\|~＜＞^•'@#%^&*()+'\""];
    NSString *resultString = [[string componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    
    return resultString;
}

@end
