//
//  ZFBranchAnalytics.m
//  ZZZZZ
//
//  Created by YW on 2019/3/26.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import "ZFBranchAnalytics.h"
#import <Branch/Branch.h>
#import "AccountManager.h"
#import "YWCFunctionTool.h"
#import "NSStringUtils.h"
#import "Constants.h"
#import "GoodsDetailModel.h"
#import "ZFOrderCheckDoneDetailModel.h"
#import "CheckOutGoodListModel.h"
#import "ZFOrderCheckInfoDetailModel.h"
#import "ZFBaseOrderModel.h"
#import "YWLocalHostManager.h"
#import <YYModel/YYModel.h>
#import "ZFNetworkManager.h"
#import "ZFRequestModel.h"
#import "ZFAppsflyerAnalytics.h"

@implementation ZFBranchAnalytics

+ (ZFBranchAnalytics *)sharedManager {
    static ZFBranchAnalytics *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZFBranchAnalytics alloc] init];
    });
    return sharedInstance;
}

/**
 事件上传

 @param event 事件
 */
- (void)branchLogEvent:(BranchEvent *)event {
    // 公共参数
    if (!ZFIsEmptyString([AccountManager sharedManager].af_user_type)) {
        event.customData[@"UserType"] = ZFToString([AccountManager sharedManager].af_user_type);
    }
    
    // 只有在线上才统计
    if ([YWLocalHostManager isDistributionOnlineRelease]) {
        [event logEvent];
    } else {
        //非发布环境才上传Branch统计日志
        [self branchLogUploadEvent:event];
    }
}

/**
 上报日志系统

 @param event 事件
 */
- (void)branchLogUploadEvent:(BranchEvent *)event {
    NSMutableDictionary *jsonEvent = [NSMutableDictionary dictionaryWithDictionary:[event yy_modelToJSONObject]];
    BNCPreferenceHelper *preferenceHelper = [[Branch getInstance] valueForKey:@"preferenceHelper"];
    jsonEvent[@"metadata"] = preferenceHelper.requestMetadataDictionary;
    [self uploadAppsflyerLogWithEvent:[event valueForKey:@"eventName"] withValues:jsonEvent];
}

/**
 日志系统过滤时，只需要在输入的关键字后面拼接上"~"，日志系统就只打印Branch事件
 */
- (void)uploadAppsflyerLogWithEvent:(NSString *)eventName
                         withValues:(NSDictionary *)values {
    if (!ZFJudgeNSDictionary(values)) return;
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.forbidEncrypt = YES;
    requestModel.parmaters = values;
    NSString *inputCatchLogTag = [[NSUserDefaults standardUserDefaults] objectForKey:@"kInputCatchLogTagKey"];
    requestModel.url = [NSString stringWithFormat:@"Branch统计日志->%@~ %@", inputCatchLogTag, ZFToString(eventName)];
    [ZFNetworkHttpRequest uploadStatisticsLog:requestModel responseObject:values];
}

/**
 登录
 */
- (void)branchLoginWithUserId:(NSString *)userId {
    // login
    [[Branch getInstance] setIdentity:ZFToString(userId)];
}

/**
 登出
 */
- (void)branchLogout {
    // logout
    [[Branch getInstance] logout];
}

/**
 Complete Registration
 
 @param type 注册类型
 */
- (void)branchCompleteRegistrationType:(NSString *)type {
    BranchEvent *event = [BranchEvent standardEvent:BranchStandardEventCompleteRegistration];
    //    event.transactionID = @"tx1234";
    event.customData[@"userid"] = ZFIsEmptyString(USERID) ? @"0" : USERID;
    event.customData[@"register_type"] = ZFToString(type);  // 注册类型：facebook  google  email
    [self branchLogEvent:event];
}

/**
 Complete Login
 
 @param type 登陆类型
 */
- (void)branchLoginType:(NSString *)type {
    BranchEvent *event = [BranchEvent standardEvent:@"LOGIN"];
    //    event.transactionID = @"tx1234";
    event.currency         = BNCCurrencyUSD;
    event.customData[@"userid"] = ZFIsEmptyString(USERID) ? @"0" : USERID;
    event.customData[@"register_type"] = ZFToString(type);  // 注册类型：facebook  google  email
    [self branchLogEvent:event];
}

/**
 搜索事件
 @param searchKey 搜索词
 */
- (void)branchSearchEvenWithSearchKey:(NSString *)searchKey searchType:(NSString *)searchType {
    BranchEvent *event = [BranchEvent standardEvent:BranchStandardEventSearch];
    event.searchQuery = ZFToString(searchKey);
    if (!ZFIsEmptyString(searchType)) {
        event.customData[@"searchType"] = ZFToString(searchType);
    }
    [self branchLogEvent:event];
}

/**
 商品详情展示
 
 @param product 商品
 */
- (void)branchViewItemDetailWithProduct:(GoodsDetailModel *)product {
    // Create a BranchUniversalObject with your content data:
    BranchUniversalObject *branchUniversalObject = [BranchUniversalObject new];
    branchUniversalObject.canonicalIdentifier = ZFToString(product.goods_id);
    branchUniversalObject.title = ZFToString(product.goods_name);
    branchUniversalObject.contentMetadata.contentSchema    = BranchContentSchemaCommerceProduct;
    branchUniversalObject.contentMetadata.quantity         = 1;
    branchUniversalObject.contentMetadata.price            = [NSDecimalNumber decimalNumberWithString:ZFToString(product.shop_price)];
    branchUniversalObject.contentMetadata.currency         = BNCCurrencyUSD;
    branchUniversalObject.contentMetadata.sku              = ZFToString(product.goods_sn);
    branchUniversalObject.contentMetadata.productName      = ZFToString(product.goods_name);
    branchUniversalObject.contentMetadata.productBrand     = ZFToString(product.long_cat_name);
    
    // Create an event and add the BranchUniversalObject to it.
    BranchEvent *event     = [BranchEvent standardEvent:BranchStandardEventViewItem];
    
    // Add the BranchUniversalObjects with the content:
    event.contentItems     = [@[branchUniversalObject] mutableCopy];
    
    // Add relevant event data:
    event.currency         = BNCCurrencyUSD;
    [self branchLogEvent:event];
}

/**
 加入购物车事件
 
 @param product 商品
 */
- (void)branchAddToCartWithProduct:(GoodsDetailModel *)product number:(NSInteger)number {
    // Create a BranchUniversalObject with your content data:
    BranchUniversalObject *branchUniversalObject = [BranchUniversalObject new];
    branchUniversalObject.canonicalIdentifier = ZFToString(product.goods_id);
    branchUniversalObject.title = ZFToString(product.goods_name);
    branchUniversalObject.contentMetadata.contentSchema    = BranchContentSchemaCommerceProduct;
    branchUniversalObject.contentMetadata.quantity         = number;
    branchUniversalObject.contentMetadata.price            = [NSDecimalNumber decimalNumberWithString:ZFToString(product.shop_price)];
    branchUniversalObject.contentMetadata.currency         = BNCCurrencyUSD;
    branchUniversalObject.contentMetadata.sku              = ZFToString(product.goods_sn);
    branchUniversalObject.contentMetadata.productName      = ZFToString(product.goods_name);
    branchUniversalObject.contentMetadata.productBrand     = ZFToString(product.long_cat_name);
    
    // Create an event and add the BranchUniversalObject to it.
    BranchEvent *event     = [BranchEvent standardEvent:BranchStandardEventAddToCart];
    
    // Add the BranchUniversalObjects with the content:
    event.contentItems     = [@[branchUniversalObject] mutableCopy];
    
    // Add relevant event data:
    event.currency         = BNCCurrencyUSD;
    [self branchLogEvent:event];
}

/**
 订单确认事件 checkout
 */
- (void)branchProcessToPayWithCheckModel:(ZFOrderCheckInfoDetailModel *)checkOutModel {
    NSMutableArray *goodsArray = [NSMutableArray array];
    for (CheckOutGoodListModel *goodsModel in checkOutModel.cart_goods.goods_list) {
        // Create a BranchUniversalObject with your content data:
        BranchUniversalObject *branchUniversalObject = [BranchUniversalObject new];
        branchUniversalObject.canonicalIdentifier = ZFToString(goodsModel.goods_id);
        branchUniversalObject.title = ZFToString(goodsModel.goods_name);
        branchUniversalObject.contentMetadata.contentSchema    = BranchContentSchemaCommerceProduct;
        branchUniversalObject.contentMetadata.quantity         = [goodsModel.goods_number integerValue];
        branchUniversalObject.contentMetadata.price            = [NSDecimalNumber decimalNumberWithString:ZFToString(goodsModel.shop_price)];
        branchUniversalObject.contentMetadata.currency         = BNCCurrencyUSD;
        branchUniversalObject.contentMetadata.sku              = ZFToString(goodsModel.goods_sn);
        branchUniversalObject.contentMetadata.productName      = ZFToString(goodsModel.goods_name);
        branchUniversalObject.contentMetadata.productBrand     = ZFToString(goodsModel.cat_name);
        
        [goodsArray addObject:branchUniversalObject];
    }
    // Create an event and add the BranchUniversalObject to it.
    BranchEvent *event     = [BranchEvent standardEvent:@"PROCESS_TO_PAY"];
    
    // Add the BranchUniversalObjects with the content:
    event.contentItems     = goodsArray;
    
    // Add relevant event data:
    event.currency         = BNCCurrencyUSD;
    event.coupon = ZFToString(checkOutModel.total.coupon_code);
    [self branchLogEvent:event];
}

/**
 创建订单成功事件
 
 @param goodsArray 订单商品列表
 */
- (void)branchInitiatePurchaseWithCheckModel:(ZFOrderCheckDoneDetailModel *)checkDoneModel checkoutModel:(ZFOrderCheckInfoDetailModel *)checkOutModel {
    NSMutableArray *goodsArray = [NSMutableArray array];
    for (CheckOutGoodListModel *goodsModel in checkOutModel.cart_goods.goods_list) {
        // Create a BranchUniversalObject with your content data:
        BranchUniversalObject *branchUniversalObject = [BranchUniversalObject new];
        branchUniversalObject.canonicalIdentifier = ZFToString(goodsModel.goods_id);
        branchUniversalObject.title = ZFToString(goodsModel.goods_name);
        branchUniversalObject.contentMetadata.contentSchema    = BranchContentSchemaCommerceProduct;
        branchUniversalObject.contentMetadata.quantity         = [goodsModel.goods_number integerValue];
        if (!ZFIsEmptyString(goodsModel.shop_price)) {
            branchUniversalObject.contentMetadata.price            = [NSDecimalNumber decimalNumberWithString:ZFToString(goodsModel.shop_price)];
        }
        branchUniversalObject.contentMetadata.currency         = BNCCurrencyUSD;
        branchUniversalObject.contentMetadata.sku              = ZFToString(goodsModel.goods_sn);
        branchUniversalObject.contentMetadata.productName      = ZFToString(goodsModel.goods_name);
        branchUniversalObject.contentMetadata.productBrand     = ZFToString(goodsModel.cat_name);
        
        [goodsArray addObject:branchUniversalObject];
    }
    // Create an event and add the BranchUniversalObject to it.
    BranchEvent *event     = [BranchEvent standardEvent:BranchStandardEventInitiatePurchase];
    
    // Add the BranchUniversalObjects with the content:
    event.contentItems     = goodsArray;
    
    // Add relevant event data:
    event.transactionID    = ZFToString(checkDoneModel.order_sn);
    event.currency         = BNCCurrencyUSD;
    event.shipping = [NSDecimalNumber decimalNumberWithString:ZFToString(checkDoneModel.shipping_fee)];
    event.revenue          = [NSDecimalNumber decimalNumberWithString:ZFToString(checkDoneModel.hacker_point.order_real_pay_amount)];
    event.coupon = ZFToString(checkDoneModel.hacker_point.coupon_name);
    [self branchLogEvent:event];
}

/**
 订单结算统计
 
 @param goodsList 订单商品列表
 */
- (void)branchAnalyticsOrderModel:(ZFBaseOrderModel *)orderModel goodsList:(NSMutableArray<BranchUniversalObject *> *)goodsList
{
    // Create an event and add the BranchUniversalObject to it.
    BranchEvent *event     = [BranchEvent standardEvent:BranchStandardEventPurchase];
    // Add the BranchUniversalObjects with the content:
    event.contentItems     = goodsList;
    // Add relevant event data:
    event.transactionID    = ZFToString(orderModel.order_sn);
    event.currency         = BNCCurrencyUSD;
    NSString *revenue      = @"0.00";
    if (!ZFIsEmptyString(orderModel.hacker_point.order_real_pay_amount)) {
        revenue = orderModel.hacker_point.order_real_pay_amount;
    }
    event.revenue          = [NSDecimalNumber decimalNumberWithString:revenue];
    NSString *shippingfee = @"0.00";
    if (!ZFIsEmptyString(orderModel.shipping_fee)) {
        shippingfee = orderModel.shipping_fee;
    }
    event.shipping         = [NSDecimalNumber decimalNumberWithString:shippingfee];
    event.tax              = [NSDecimalNumber decimalNumberWithString:@"0.00"];
    event.coupon           = ZFToString(orderModel.hacker_point.coupon_name);
    NSString *payWay       = orderModel.hacker_point.order_pay_way;
    if (ZFIsEmptyString(payWay)) {
        payWay = ZFToString(orderModel.pay_id);
    }
    if (!ZFIsEmptyString(payWay)) {
        event.customData[@"pay_method"] = ZFToString(payWay);
    }
    [self branchLogEvent:event];
}


/**
 社区帖子浏览

 @param postId 帖子ID
 @param postType 帖子类型
 */
- (void)branchAnalyticsPostViewWithPostId:(NSString *)postId postType:(NSString *)postType {
    BranchEvent *event = [BranchEvent standardEvent:@"POST_VIEW"];
    event.customData[@"post_id"] = ZFToString(postId);
    event.customData[@"post_type"] = ZFToString(postType);
    event.customData[@"user_id"] = ZFIsEmptyString(USERID) ? @"0" : USERID;
    [self branchLogEvent:event];
}


/**
 帖子点赞

 @param postId 帖子ID
 @param postType 帖子类型
 @param isLike 点攒/取消点攒
 */
- (void)branchAnalyticsPostLikeWithPostId:(NSString *)postId postType:(NSString *)postType isLike:(BOOL)isLike {
    BranchEvent *event = [BranchEvent standardEvent:@"POST_LIKE"];
    event.customData[@"post_id"] = ZFToString(postId);
    event.customData[@"post_type"] = ZFToString(postType);
    event.customData[@"like_type"] = isLike ? @"1" : @"0";
    event.customData[@"user_id"] = ZFIsEmptyString(USERID) ? @"0" : USERID;
    [self branchLogEvent:event];
}

/**
 帖子收藏
 
 @param postId 帖子ID
 @param postType 帖子类型
 @param isSave 收藏/取消收藏
 */
- (void)branchAnalyticsPostSaveWithPostId:(NSString *)postId postType:(NSString *)postType isSave:(BOOL)isSave {
    BranchEvent *event = [BranchEvent standardEvent:@"POST_SAVE"];
    event.customData[@"post_id"] = ZFToString(postId);
    event.customData[@"post_type"] = ZFToString(postType);
    event.customData[@"save_type"] = isSave ? @"1" : @"0";
    event.customData[@"user_id"] = ZFIsEmptyString(USERID) ? @"0" : USERID;
    [self branchLogEvent:event];
}

/**
 帖子评论
 
 @param postId 帖子ID
 @param postType 帖子类型
 */
- (void)branchAnalyticsPostReviewWithPostId:(NSString *)postId postType:(NSString *)postType {
    BranchEvent *event = [BranchEvent standardEvent:@"POST_REVIEW"];
    event.customData[@"post_id"] = ZFToString(postId);
    event.customData[@"post_type"] = ZFToString(postType);
    event.customData[@"user_id"] = ZFIsEmptyString(USERID) ? @"0" : USERID;
    [self branchLogEvent:event];
}

/**
 帖子分享
 
 @param postId 帖子ID
 @param postType 帖子类型
 @param shareType 分享类型
 */
- (void)branchAnalyticsPostShareWithPostId:(NSString *)postId postType:(NSString *)postType shareType:(NSString *)shareType {
    BranchEvent *event = [BranchEvent standardEvent:@"POST_SHARE"];
    event.customData[@"post_id"] = ZFToString(postId);
    event.customData[@"post_type"] = ZFToString(postType);
    event.customData[@"share_type"] = ZFToString(shareType);
    event.customData[@"user_id"] = ZFIsEmptyString(USERID) ? @"0" : USERID;
    [self branchLogEvent:event];
}

@end
