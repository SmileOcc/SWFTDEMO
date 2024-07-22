//
//  ZFAnalytics.m
//  ZZZZZ
//
//  Created by YW on 2016/10/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAnalytics.h"

#import "MyOrdersModel.h"
#import "GoodListModel.h"
#import "GoodsDetailModel.h"
#import "ZFGoodsModel.h"
#import "MyOrderGoodListModel.h"
#import "GoodsDetailSameModel.h"
#import "CheckOutGoodListModel.h"
#import "OrderDetailGoodModel.h"
#import "OrderDetailOrderModel.h"
#import "ZFOrderCheckDoneDetailModel.h"
#import "CommendModel.h"
#import "ZFCartGoodsModel.h"
#import "UIDevice+Identifier.h"
#import "ZFAppsflyerAnalytics.h"
#import "YWCFunctionTool.h"

@implementation ZFAnalytics


#pragma mark - AppsFlyerAnalytics
/**
 *  事件统计量
 *
 *  @param
 */
+ (void)appsFlyerTrackEventWithContentType:(NSString *)contentType {
#ifdef AppsFlyerAnalyticsEnabled
    [ZFAppsflyerAnalytics zfTrackEvent:contentType withValues:@{AFEventParamContentType : contentType}];
#endif
}

/**
 *  事件统计量
 *  @param
 */
+ (void)appsFlyerTrackEvent:(NSString *)eventName withValues:(NSDictionary *)values {
#ifdef AppsFlyerAnalyticsEnabled
    [ZFAppsflyerAnalytics zfTrackEvent:eventName withValues:values];
#endif
}

+ (void)appsFlyerTrackFinishGoodsIds:(NSString *)goodsIds
                         goodsPrices:(NSString *)goodsPrices
                           quantitys:(NSString *)quantitys
                             orderSn:(NSString *)orderSn
                        orderPayMent:(NSString *)orderPayment
                        orderRealPay:(NSString *)orderRealPay
                             payment:(NSString *)payment
                            btsModel:(ZFCartBtsModel *)model
                       bigDataParams:(NSArray<NSDictionary *> *)bigDataParams
{
#ifdef AppsFlyerAnalyticsEnabled
    NSDictionary *dic = @{AFEventParamContentId   : ZFToString(goodsIds),
                          AFEventParamPrice       : ZFToString(goodsPrices),
                          AFEventParamQuantity    : ZFToString(quantitys),
                          @"af_reciept_id"        : ZFToString(orderSn),
                          AFEventParamRevenue     : ZFToString(orderRealPay),
                          AFEventParamCurrency    : @"USD",
                          @"af_payment"           : ZFToString(orderPayment),
                          AFEventParamContentType : @"product",
                          @"af_order_id"          : ZFToString(orderSn),
                          //@"af_real_payment" : ZFToString(orderPayment),
                          BigDataParams : bigDataParams,
                          };
    [ZFAnalytics appsFlyerTrackEvent:@"af_purchase" withValues:dic];
#endif
}

+ (void)showSearchProductsWithProducts:(NSArray *)products
                              position:(int)position
                        impressionList:(NSString *)impressionList
                            screenName:(NSString *)screenName
                                 event:(NSString *)event
{
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    
    tracker.allowIDFACollection = YES;
    // 自定义字段
    [[self class] fillTrackerWithCustomInfo:tracker];
    
    GAIDictionaryBuilder *builder = nil;
    if (event.length > 0) { // 以event发送
        builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce" action:event label:nil value:nil];
    } else { // 以screenview发送
        builder = [GAIDictionaryBuilder createScreenView];
    }
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    for (ZFGoodsModel *sd_product in products) {
        GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
        if (sd_product.goods_sn.length > 0) {
            [product setId:sd_product.goods_sn];
        }
        if (sd_product.goods_title.length > 0) {
            [product setName:sd_product.goods_title];
            [product setBrand:sd_product.goods_title];
        }
        if (sd_product.cat_name.length > 0) {
            [product setCategory:sd_product.cat_name];
        }
        if (position > 0) [product setPosition:@(position)];
        
        [builder addProductImpression:product impressionList:impressionList impressionSource:nil];
    }
    
    [tracker send:[builder build]];
    
#endif
}



+ (void)showCategoryProductsWithProducts:(NSArray *)products
                                position:(int)position
                          impressionList:(NSString *)impressionList
                              screenName:(NSString *)screenName
                                   event:(NSString *)event
{
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    
    tracker.allowIDFACollection = YES;
    // 自定义字段
    [[self class] fillTrackerWithCustomInfo:tracker];
    
    GAIDictionaryBuilder *builder = nil;
    if (event.length > 0) { // 以event发送
        builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce" action:event label:nil value:nil];
    } else { // 以screenview发送
        builder = [GAIDictionaryBuilder createScreenView];
    }
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    for (ZFGoodsModel *sd_product in products) {
        GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
        if (sd_product.goods_sn.length > 0) {
            [product setId:sd_product.goods_sn];
        }
        if (sd_product.goods_title.length > 0) {
            [product setName:sd_product.goods_title];
            [product setBrand:sd_product.goods_title];
        }
        if (sd_product.cat_name.length > 0) {
            [product setCategory:sd_product.cat_name];
        }
        if (position > 0) [product setPosition:@(position)];
        
        [builder addProductImpression:product impressionList:impressionList impressionSource:nil];
    }
    
    [tracker send:[builder build]];
    
#endif
}

+ (void)clickCategoryProductWithProduct:(ZFGoodsModel *)product
                               position:(int)position
                             actionList:(NSString *)actionList
{
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    GAIEcommerceProduct *eproduct = [[GAIEcommerceProduct alloc] init];
    [eproduct setId:product.goods_sn];
    [eproduct setName:product.goods_title];
    [eproduct setCategory:product.cat_name];
    [eproduct setBrand:product.goods_title];
    [eproduct setPosition:@(position)];
    
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPAClick];
    [action setProductActionList:actionList];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce" action:@"ProductClick" label:@"Click" value:nil];
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    [builder setProductAction:action];
    [builder addProduct:eproduct];
    
    [tracker send:[builder build]];
    
#endif
}

#pragma mark - 屏幕浏览量

/**
 *  屏幕浏览量
 *
 *  @param screenName 当前屏幕名称
 */
+ (void)screenViewQuantityWithScreenName:(NSString *)screenName {
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    tracker.allowIDFACollection = YES;
    [tracker set:kGAIScreenName value:screenName];
    
    // 自定义字段
    [[self class] fillTrackerWithCustomInfo:tracker];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    [tracker send:[builder build]];
    
#endif
}

/**
 * 统计每个接口的请求时间
 */
+(void)logSpeedWithCategory:(NSString *)cateName
                  eventName:(NSString *)name
                   interval:(NSTimeInterval)interval
                      label:(NSString *)label
{
#ifdef googleAnalyticsV3Enabled
    if (!(cateName && cateName && label)) return;
    id tracker = [[GAI sharedInstance] defaultTracker];
    //GA是以秒显示的
    NSNumber *timeInterval = @((CGFloat)(interval / 1000.0));
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:cateName
                                                         interval:timeInterval
                                                             name:name
                                                            label:label] build]];
#endif
}

#pragma mark - 广告

/**
 *  站内广告展示
 *
 *  @param banners 站内广告  其中id和name必须传一个
 *  @param position 站内广告位置  非必须
 *  @param screenName 当前屏幕名称
 */
+ (void)showAdvertisementWithBanners:(NSArray *)banners
                            position:(NSString *)position
                          screenName:(NSString *)screenName
{
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    tracker.allowIDFACollection = YES;
    
    // 自定义字段
    [[self class] fillTrackerWithCustomInfo:tracker];
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce"
                                                                           action:@"InternalPromotions"
                                                                            label:@"PromotionImpression"
                                                                            value:nil];
    [[self class] fillBuilderWithCustomInfo:builder];
    
    for (NSDictionary *banner in banners) {
        GAIEcommercePromotion *promotion = [[GAIEcommercePromotion alloc] init];
        [promotion setName:banner[@"name"]];
        NSString *positionName = banner[@"position"];
        if (positionName.length > 0) {
            [promotion setPosition:positionName];
        }
        
        [builder addPromotion:promotion];
    }
    
    [tracker send:[builder build]];
    
#endif
}

/**
 *  站内广告点击
 *
 *  @param pid 站内广告id  id和name必须传一个
 *  @param name 站内广告名称
 *  @param position 站内广告位置  非必须
 */
+ (void)clickAdvertisementWithId:(NSString *)pid
                            name:(NSString *)name
                        position:(NSString *)position
{
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    GAIEcommercePromotion *promotion = [[GAIEcommercePromotion alloc] init];
    if (pid.length > 0) [promotion setId:pid];
    if (name.length > 0) [promotion setName:name];
    if (position.length > 0) [promotion setPosition:position];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce"
                                                                           action:@"InternalPromotions"
                                                                            label:@"PromotionClick"
                                                                            value:nil];
    [[self class] fillBuilderWithCustomInfo:builder];
    
    [builder set:kGAIPromotionClick forKey:kGAIPromotionAction];
    [builder addPromotion:promotion];
    
    [tracker send:[builder build]];
    
#endif
}

#pragma mark - 产品

/**
 *  产品展示
 *
 *  @param products 展示的产品数组，其中的id和name必传一个，其他非必须
 *  @param position 产品所在位置
 *  @param impressionList 产品所在列表的名称
 *  @param screenName 产品所在页
 *  @param event 下拉加载更多名称，按event发送
 */
+ (void)showProductsWithProducts:(NSArray *)products
                        position:(int)position
                  impressionList:(NSString *)impressionList
                      screenName:(NSString *)screenName
                           event:(NSString *)event
{
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    
    tracker.allowIDFACollection = YES;
    // 自定义字段
    [[self class] fillTrackerWithCustomInfo:tracker];
    
    GAIDictionaryBuilder *builder = nil;
    if (event.length > 0) { // 以event发送
        builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce" action:event label:nil value:nil];
    } else { // 以screenview发送
        builder = [GAIDictionaryBuilder createScreenView];
    }
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    for (ZFGoodsModel *sd_product in products) {
        GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
        if (sd_product.goods_sn.length > 0) {
            [product setId:sd_product.goods_sn];
        }
        if (sd_product.goods_title.length > 0) {
            [product setName:sd_product.goods_title];
            [product setBrand:sd_product.goods_title];
        }
        if (sd_product.cat_name.length > 0) {
            [product setCategory:sd_product.cat_name];
        }
        if (position > 0) [product setPosition:@(position)];
        
        [builder addProductImpression:product impressionList:impressionList impressionSource:nil];
    }
    
    [tracker send:[builder build]];
    
#endif
}

/**
 *  详情推荐产品展示
 *
 *  @param products 展示的产品数组，其中的id和name必传一个，其他非必须
 *  @param position 产品所在位置
 *  @param impressionList 产品所在列表的名称
 *  @param screenName 产品所在页
 *  @param event 下拉加载更多名称，按event发送
 */
+ (void)showDetailProductsWithProducts:(NSArray *)products
                              position:(int)position
                        impressionList:(NSString *)impressionList
                            screenName:(NSString *)screenName
                                 event:(NSString *)event
{
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    
    tracker.allowIDFACollection = YES;
    // 自定义字段
    [[self class] fillTrackerWithCustomInfo:tracker];
    
    GAIDictionaryBuilder *builder = nil;
    if (event.length > 0) { // 以event发送
        builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce" action:event label:nil value:nil];
    } else { // 以screenview发送
        builder = [GAIDictionaryBuilder createScreenView];
    }
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    for (GoodsDetailSameModel *sd_product in products) {
        GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
        if (sd_product.goods_sn > 0) {
            [product setId:sd_product.goods_sn];
        }
        if (sd_product.goods_title.length > 0) {
            [product setName:sd_product.goods_title];
            [product setBrand:sd_product.goods_title];
        }
        if (sd_product.cat_id > 0) {
            [product setCategory:sd_product.cat_id];
        }
        if (position > 0) [product setPosition:@(position)];
        
        [builder addProductImpression:product impressionList:impressionList impressionSource:nil];
    }
    
    [tracker send:[builder build]];
    
#endif
}

/**
 *  收藏产品展示
 *
 *  @param products 展示的产品数组，其中的id和name必传一个，其他非必须
 *  @param position 产品所在位置
 *  @param impressionList 产品所在列表的名称
 *  @param screenName 产品所在页
 *  @param event 下拉加载更多名称，按event发送
 */
+ (void)showCollectionProductsWithProducts:(NSArray *)products
                                  position:(int)position
                            impressionList:(NSString *)impressionList
                                screenName:(NSString *)screenName
                                     event:(NSString *)event
{
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    
    tracker.allowIDFACollection = YES;
    // 自定义字段
    [[self class] fillTrackerWithCustomInfo:tracker];
    
    GAIDictionaryBuilder *builder = nil;
    if (event.length > 0) { // 以event发送
        builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce" action:event label:nil value:nil];
    } else { // 以screenview发送
        builder = [GAIDictionaryBuilder createScreenView];
    }
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    for (ZFGoodsModel *sd_product in products) {
        GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
        if (sd_product.goods_sn > 0) {
            [product setId:sd_product.goods_sn];
        }
        if (sd_product.goods_title.length > 0) {
            [product setName:sd_product.goods_title];
            [product setBrand:sd_product.goods_title];
        }
        if (sd_product.cat_name.length > 0) {
            [product setCategory:sd_product.cat_name];
        }
        if (position > 0) [product setPosition:@(position)];
        
        [builder addProductImpression:product impressionList:impressionList impressionSource:nil];
    }
    
    [tracker send:[builder build]];
    
#endif
}

/**
 *  产品点击
 *
 *  @param sd_product 展示的产品，id和name必传一个，其他非必须
 *  @param position 产品所在位置
 *  @param actionList 产品所在列表的名称
 */
+ (void)clickProductWithProduct:(ZFGoodsModel *)product
                       position:(int)position
                     actionList:(NSString *)actionList {
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    GAIEcommerceProduct *eproduct = [[GAIEcommerceProduct alloc] init];
    [eproduct setId:ZFToString(product.goods_sn)];
    [eproduct setName:ZFToString(product.goods_title)];
    [eproduct setCategory:ZFToString(product.cat_name)];
    [eproduct setBrand:ZFToString(product.goods_title)];
    [eproduct setPosition:@(position)];
    
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPAClick];
    [action setProductActionList:actionList];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce"
                                                                           action:@"ProductClick"
                                                                            label:@"Click"
                                                                            value:nil];
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    [builder setProductAction:action];
    [builder addProduct:eproduct];
    
    [tracker send:[builder build]];
    
#endif
}

/**
 *  产品点击-收藏
 *
 *  @param sd_product 展示的产品，id和name必传一个，其他非必须
 *  @param position 产品所在位置
 *  @param actionList 产品所在列表的名称
 */
+ (void)clickCollectionProductWithProduct:(ZFGoodsModel *)product
                                 position:(int)position
                               actionList:(NSString *)actionList {
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    GAIEcommerceProduct *eproduct = [[GAIEcommerceProduct alloc] init];
    [eproduct setId:product.goods_sn];
    [eproduct setName:product.goods_title];
    [eproduct setCategory:product.cat_name];
    [eproduct setBrand:product.goods_title];
    [eproduct setPosition:@(position)];
    
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPAClick];
    [action setProductActionList:actionList];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce" action:@"ProductClick" label:@"Click" value:nil];
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    [builder setProductAction:action];
    [builder addProduct:eproduct];
    
    [tracker send:[builder build]];
    
#endif
}

/**
 *  产品详情浏览
 *
 *  @param sd_product 展示的产品，id和name必传一个，其他非必须
 *  @param screenName 产品所在页
 */
+ (void)scanProductDetailWithProduct:(GoodsDetailModel *)product
                          screenName:(NSString *)screenName {
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    tracker.allowIDFACollection = YES;
    
    // 自定义字段
    [[self class] fillTrackerWithCustomInfo:tracker];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    GAIEcommerceProduct *eproduct = [[GAIEcommerceProduct alloc] init];
    [eproduct setId:product.goods_sn];
    [eproduct setName:product.goods_name];
    [eproduct setBrand:product.goods_name];
    
    if (product.specification.length > 0) {
        [eproduct setVariant:product.specification];
    }
    
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPADetail];
    
    [builder setProductAction:action];
    [builder addProduct:eproduct];
    
    [tracker send:[builder build]];
    
#endif
}

#pragma mark - 结账

/**
 *  结账流程--个人中心
 *
 *  @param sd_order 订单，id和name必传一个，其他非必须
 *  @param step 结账进行到哪一步
 *  @param option 结账类型、方式  不必须
 *  @param screenName 产品所在页
 */
+ (void)settleAccountProcedureWithProduct:(NSArray *)goodsList step:(int)step option:(NSString *)option screenName:(NSString *)screenName {
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    tracker.allowIDFACollection = YES;
    
    // 自定义字段
    [[self class] fillTrackerWithCustomInfo:tracker];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];
    [[self class] fillBuilderWithCustomInfo:builder];
    
    for (MyOrderGoodListModel *cartItem in goodsList) {
        GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
        [product setPrice:@([cartItem.promote_price floatValue])];
        [product setQuantity:[NSNumber numberWithUnsignedInteger:[cartItem.goods_number integerValue]]];
        if ([cartItem.goods_sn length] > 0) {
            [product setId:cartItem.goods_sn];
        }
        if (cartItem.goods_title.length > 0) {
            [product setName:cartItem.goods_title];
        }
        
        [builder addProduct:product];
    }
    
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPACheckout];
    [action setCheckoutStep:@(step)];
    if (option.length > 0) [action setCheckoutOption:option];
    
    [builder setProductAction:action];
    
    [tracker send:[builder build]];
    
#endif
}

/**
 *  结账流程--个人中心--订单详情
 *
 *  @param sd_order 订单，id和name必传一个，其他非必须
 *  @param step 结账进行到哪一步
 *  @param option 结账类型、方式  不必须
 *  @param screenName 产品所在页
 */
+ (void)settleAccountInfoProcedureWithProduct:(NSArray *)goodsList step:(int)step option:(NSString *)option screenName:(NSString *)screenName {
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    tracker.allowIDFACollection = YES;
    
    // 自定义字段
    [[self class] fillTrackerWithCustomInfo:tracker];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];
    [[self class] fillBuilderWithCustomInfo:builder];
    
    for (OrderDetailGoodModel *cartItem in goodsList) {
        GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
        [product setPrice:@([cartItem.goods_price floatValue])];
        [product setQuantity:[NSNumber numberWithUnsignedInteger:[cartItem.goods_number integerValue]]];
        if ([cartItem.goods_sn length] > 0) {
            [product setId:cartItem.goods_sn];
        }
        if (cartItem.goods_name.length > 0) {
            [product setName:cartItem.goods_name];
        }
        
        [builder addProduct:product];
    }
    
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPACheckout];
    [action setCheckoutStep:@(step)];
    if (option.length > 0) [action setCheckoutOption:option];
    
    [builder setProductAction:action];
    
    [tracker send:[builder build]];
    
#endif
}

/**
 *  结账流程--详情
 *
 *  @param sd_order 订单，id和name必传一个，其他非必须
 *  @param step 结账进行到哪一步
 *  @param option 结账类型、方式  不必须
 *  @param screenName 产品所在页
 */
+ (void)settleInfoProcedureWithProduct:(NSArray *)goodsList
                                  step:(int)step
                                option:(NSString *)option
                            screenName:(NSString *)screenName
{
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    tracker.allowIDFACollection = YES;
    
    // 自定义字段
    [[self class] fillTrackerWithCustomInfo:tracker];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];
    [[self class] fillBuilderWithCustomInfo:builder];
    
    for (CheckOutGoodListModel *cartItem in goodsList) {
        GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
        [product setPrice:@([cartItem.goods_price floatValue])];
        [product setQuantity:[NSNumber numberWithUnsignedInteger:[cartItem.goods_number integerValue]]];
        
        if ([cartItem.goods_sn length] > 0) {
            [product setId:cartItem.goods_sn];
        }
        
        if (cartItem.goods_title.length > 0) {
            [product setName:cartItem.goods_title];
        }
        [builder addProduct:product];
    }
    
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPACheckout];
    [action setCheckoutStep:@(step)];
    if (option.length > 0) [action setCheckoutOption:option];
    
    [builder setProductAction:action];
    
    [tracker send:[builder build]];
    
#endif
}

/**
 *  结账流程选项
 *
 *  @param step 结账进行到哪一步
 *  @param option 结账类型、方式
 */
+ (void)optionAccountProcedureWithStep:(int)step option:(NSString *)option {
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPACheckoutOption];
    [action setCheckoutStep:@(step)];
    [action setCheckoutOption:option];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce" action:@"CheckoutOptions" label:@"ClickOption" value:nil];
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    [builder setProductAction:action];
    
    [tracker send:[builder build]];
    
#endif
}

/**
 *  交易--详情
 *
 *  @param sd_order 订单，id和name必传一个，其他非必须
 *  @param screenName 产品所在页，如首页、专题页、搜索页、收藏夹
 */
+ (void)trasactionInfoWithProduct:(NSArray *)products
                            order:(ZFOrderCheckDoneDetailModel *)order
                       screenName:(NSString *)screenName
{
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    tracker.allowIDFACollection = YES;
    
    // 自定义字段
    [[self class] fillTrackerWithCustomInfo:tracker];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce" action:@"Transaction" label:@"Transaction" value:nil];
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    for (CheckOutGoodListModel *cartItem in products) {
        GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
        [product setPrice:@([cartItem.goods_price floatValue])];
        [product setQuantity:[NSNumber numberWithUnsignedInteger:[cartItem.goods_number integerValue]]];
        
        [product setId:cartItem.goods_sn];
        if (cartItem.goods_title.length > 0) {
            [product setName:cartItem.goods_title];
        }
        [builder addProduct:product];
    }
    
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPAPurchase];
    [action setTransactionId:order.order_sn];
    [action setRevenue:@([order.hacker_point.order_real_pay_amount floatValue])];
    [action setTax:@0];
    [action setShipping:@([order.shipping_fee floatValue])];
    [action setCouponCode:order.promote_pcode];
    
    [builder setProductAction:action];
    
    [tracker send:[builder build]];
    
#endif
}

/**
 *  交易--个人中心
 *
 *  @param sd_order 订单，id和name必传一个，其他非必须
 *  @param screenName 产品所在页，如首页、专题页、搜索页、收藏夹
 */
+ (void)trasactionAccountWithProduct:(ZFBaseOrderModel *)order screenName:(NSString *)screenName {
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    tracker.allowIDFACollection = YES;
    
    // 自定义字段
    [[self class] fillTrackerWithCustomInfo:tracker];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce" action:@"Transaction" label:@"Transaction" value:nil];
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    for (MyOrderGoodListModel *cartItem in order.baseGoodsList) {
        GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
        
        [product setId:cartItem.goods_sn];
        if (cartItem.goods_title.length > 0) {
            [product setName:cartItem.goods_title];
        }
        [builder addProduct:product];
    }
    
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPAPurchase];
    [action setTransactionId:order.order_sn];
    [action setRevenue:@([order.hacker_point.order_real_pay_amount floatValue])];
    [action setTax:@0];
    [action setShipping:@([order.shipping_fee floatValue])];
    [action setCouponCode:order.hacker_point.coupon_name];
    
    [builder setProductAction:action];
    
    [tracker send:[builder build]];
    
#endif
}

/**
 *  交易--个人中心--详情
 *
 *  @param sd_order 订单，id和name必传一个，其他非必须
 *  @param screenName 产品所在页，如首页、专题页、搜索页、收藏夹
 */
+ (void)trasactionAccountInfoWithProduct:(NSArray *)products
                                   order:(OrderDetailOrderModel *)order
                              screenName:(NSString *)screenName
{
#ifdef googleAnalyticsV3Enabled
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    tracker.allowIDFACollection = YES;
    
    // 自定义字段
    [[self class] fillTrackerWithCustomInfo:tracker];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce" action:@"Transaction" label:@"Transaction" value:nil];
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    for (OrderDetailGoodModel *cartItem in products) {
        GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
        [product setPrice:@([cartItem.goods_price floatValue])];
        [product setQuantity:[NSNumber numberWithUnsignedInteger:[cartItem.goods_number integerValue]]];
        
        [product setId:cartItem.goods_sn];
        if (cartItem.goods_name.length > 0) {
            [product setName:cartItem.goods_name];
        }
        [builder addProduct:product];
    }
    
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPAPurchase];
    [action setTransactionId:order.order_sn];
    [action setRevenue:@([order.hacker_point.order_real_pay_amount floatValue])];
    [action setTax:@0];
    [action setShipping:@([order.shipping_fee floatValue])];
    [action setCouponCode:order.coupon];
    
    [builder setProductAction:action];
    
    [tracker send:[builder build]];
    
#endif
}

#pragma mark - 购物车

/**
 *  添加购物车
 *
 *  @param sd_product 展示的产品，id和name必传一个，其他非必须
 *  @param isFromProduct 添加购物车方式，YES - 从产品列表页， NO - 从收藏夹
 */
+ (void)addToCartWithProduct:(GoodsDetailModel *)cartItem fromProduct:(BOOL)isFromProduct {
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
    [product setId:cartItem.goods_sn];
    [product setName:cartItem.goods_name];
    [product setPrice:@([cartItem.market_price floatValue])];
    [product setQuantity:@(cartItem.buyNumbers)];
    
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPAAdd];
    
    NSString *from = isFromProduct ? @"productlist" : @"favorite";
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce" action:@"AddToCart" label:from value:nil];
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    [builder setProductAction:action];
    [builder addProduct:product];
    
    [tracker send:[builder build]];
    
#endif
}

/**
 *  移除购物车
 *
 *  @param cartItem 要移除的项目
 */
+ (void)removeFromCartWithItem:(ZFCartGoodsModel *)cartItem {
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
    [product setId:cartItem.goods_sn];
    [product setName:cartItem.goods_name];
    [product setPrice:@([cartItem.market_price floatValue])];
    [product setQuantity:@(cartItem.goods_number)];
    
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPARemove];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce" action:@"RemoveFromCart" label:@"Remove" value:nil];
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    [builder setProductAction:action];
    [builder addProduct:product];
    
    [tracker send:[builder build]];
    
#endif
}

#pragma mark - 其他

/**
 *  EVENT事件
 *
 *  @param step 结账进行到哪一步
 *  @param option 结账类型、方式
 */
+ (void)event {
#ifdef googleAnalyticsV3Enabled
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce" action:@"add-to-cart" label:nil value:nil];
    
    [[self class] fillBuilderWithCustomInfo:builder];
    
    [tracker send:[builder build]];
    
#endif
}

/**
 *  社交分享
 *
 *  @param step 结账进行到哪一步
 *  @param option 结账类型、方式
 */
+ (void)shareSocialContact {
#ifdef googleAnalyticsV3Enabled
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    NSString *targetUrl = @"https://developers.google.com/analytics";
    
    [tracker send:[[GAIDictionaryBuilder createSocialWithNetwork:@"Twitter" action:@"Tweet" target:targetUrl] build]];
    
#endif
}

/**
 *  错误统计
 *
 *  @param exc
 */
+ (void)statisticException:(NSException *)exc {
#ifdef googleAnalyticsV3Enabled
    
    @try {
        YWLog(@"Google Analytics cathed exception:%@", exc.description);
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createExceptionWithDescription:exception.description withFatal:@NO];
        [tracker send:[builder build]];
    }
    
#endif
}

/**
 *  按钮点击事件统计
 *  @param vcName       界面名字
 *  @param actionName   按钮事件名字
 */
+ (void)clickButtonWithCategory:(NSString *)category
                     actionName:(NSString *)actionName
                          label:(NSString *)label
{
#ifdef googleAnalyticsV3Enabled
    
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:category
//                                                                           action:actionName
//                                                                            label:label
//                                                                            value:nil];
//    // 给自定义字段赋值
//    [[self class] fillBuilderWithCustomInfo:builder];
//
//    [tracker send:[builder build]];
    
#endif
}

+ (void)clickButtonV380WithCategory:(NSString *)category
                         actionName:(NSString *)actionName
                              label:(NSString *)label
{
#ifdef googleAnalyticsV3Enabled
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:category
                                                                           action:actionName
                                                                            label:label
                                                                            value:nil];
    // 给自定义字段赋值
    [[self class] fillBuilderWithCustomInfo:builder];

    [tracker send:[builder build]];
#endif
}

#ifdef googleAnalyticsV3Enabled
+(void)fillTrackerWithCustomInfo:(id<GAITracker>)tracker
{
    NSString *userStatus    = [AccountManager sharedManager].isSignIn ? @"Login" : @"NotLogin";
    
    [tracker set:[GAIFields customDimensionForIndex:1] value:USERID];
    [tracker set:[GAIFields customDimensionForIndex:2] value:[[UIDevice currentDevice] uniqueDeviceIdentifier]];
    [tracker set:[GAIFields customDimensionForIndex:3] value:userStatus];
}

+(void)fillBuilderWithCustomInfo:(GAIDictionaryBuilder *)builder
{
    NSString *userStatus    = [AccountManager sharedManager].isSignIn ? @"Login" : @"NotLogin";
    
    [builder set:USERID forKey:[GAIFields customDimensionForIndex:1]];
    [builder set:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:[GAIFields customDimensionForIndex:2]];
    [builder set:userStatus forKey:[GAIFields customDimensionForIndex:3]];
}
#endif

@end





@implementation ZFAnalyticsProduceImpression

+ (instancetype)initAnalyticsProducePosition:(int)position
                              impressionList:(NSString *)impressionList
                                  screenName:(NSString *)screenName
                                       event:(NSString *)event {
    
    ZFAnalyticsProduceImpression *analyProduce = [[ZFAnalyticsProduceImpression alloc] init];
    analyProduce.position = position;
    analyProduce.impressionList = ZFToString(impressionList);
    analyProduce.screenName = ZFToString(screenName);
    analyProduce.event = ZFToString(event);
    
    return analyProduce;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return [self yy_modelInitWithCoder:aDecoder];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    return [self yy_modelCopy];
}

@end
