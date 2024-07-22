//
//  ZFAnalytics.h
//  ZZZZZ
//
//  Created by YW on 2016/10/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "ZFBaseOrderModel.h"
#import <Branch/Branch.h>
#import "ZFCartBtsModel.h"
#import "ZFGAAnalyticsKeyDefiner.h"
#ifdef AppsFlyerAnalyticsEnabled
#import <AppsFlyerLib/AppsFlyerTracker.h>
#endif

#ifdef googleAnalyticsV3Enabled
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIEcommerceFields.h"
#import "GAIDictionaryBuilder.h"
#endif

@class MyOrdersModel,GoodsDetailModel,ZFGoodsModel,
GoodListModel,MyOrderGoodListModel,OrderDetailOrderModel,
ZFOrderCheckDoneDetailModel,CommendModel, ZFCartGoodsModel;

@interface ZFAnalytics : NSObject

#pragma -AppsFlyerAnalytics

/**
 *  事件统计量
 *
 *  @param
 */
+ (void)appsFlyerTrackEventWithContentType:(NSString *)contentType;

/**
 *  事件统计量
 *  @param
 */
+ (void)appsFlyerTrackEvent:(NSString *)eventName withValues:(NSDictionary *)values;

/**
 *  付款订单统计量--> (和安卓统一key一致)
 *  model可以为nil,不会nil时，传入的是后台下发的Bts实验model
 *  @param
 */
+ (void)appsFlyerTrackFinishGoodsIds:(NSString *)goodsIds
                         goodsPrices:(NSString *)goodsPrices
                           quantitys:(NSString *)quantitys
                             orderSn:(NSString *)orderSn
                        orderPayMent:(NSString *)orderPayment
                        orderRealPay:(NSString *)orderRealPay
                             payment:(NSString *)payment
                            btsModel:(ZFCartBtsModel *)model
                       bigDataParams:(NSArray<NSDictionary *> *)bigDataParams;

#pragma -googleAnalyticsV3Enabled
/**
 *  屏幕浏览量
 */
+ (void)screenViewQuantityWithScreenName:(NSString *)screenName;

/**
 *  站内广告展示
 */
+ (void)showAdvertisementWithBanners:(NSArray *)banners
                            position:(NSString *)position
                          screenName:(NSString *)screenName;

/**
 *  站内广告点击
 */
+ (void)clickAdvertisementWithId:(NSString *)pid
                            name:(NSString *)name
                        position:(NSString *)position;

/**
 *  产品展示
 */
+ (void)showProductsWithProducts:(NSArray *)products
                        position:(int)position
                  impressionList:(NSString *)impressionList
                      screenName:(NSString *)screenName
                           event:(NSString *)event;

/**
 *  产品展示--商品详情推荐商品
 */
+ (void)showDetailProductsWithProducts:(NSArray *)products
                              position:(int)position
                        impressionList:(NSString *)impressionList
                            screenName:(NSString *)screenName
                                 event:(NSString *)event;

/**
 *  产品展示--收藏商品列表
 */
+ (void)showCollectionProductsWithProducts:(NSArray *)products
                                  position:(int)position
                            impressionList:(NSString *)impressionList
                                screenName:(NSString *)screenName
                                     event:(NSString *)event;

/**
 *  产品点击
 */
+ (void)clickProductWithProduct:(ZFGoodsModel *)product
                       position:(int)position
                     actionList:(NSString *)actionList;

/**
 *  产品点击-收藏
 */
+ (void)clickCollectionProductWithProduct:(ZFGoodsModel *)product
                                 position:(int)position
                               actionList:(NSString *)actionList;

/**
 *  产品详情浏览
 */
+ (void)scanProductDetailWithProduct:(GoodsDetailModel *)product
                          screenName:(NSString *)screenName;

/**
 *  结账流程--订单详情
 */
+ (void)settleInfoProcedureWithProduct:(NSArray *)goodsList
                                  step:(int)step
                                option:(NSString *)option
                            screenName:(NSString *)screenName;

/**
 *  结账流程--帐号中心
 */
+ (void)settleAccountProcedureWithProduct:(NSArray *)goodsList
                                     step:(int)step
                                   option:(NSString *)option
                               screenName:(NSString *)screenName;

/**
 *  结账流程--订单详情-订单详情
 */
+ (void)settleAccountInfoProcedureWithProduct:(NSArray *)goodsList
                                         step:(int)step
                                       option:(NSString *)option
                                   screenName:(NSString *)screenName;
/**
 *  结账流程选项
 */
+ (void)optionAccountProcedureWithStep:(int)step option:(NSString *)option;

/**
 *  交易--详情
 */
+ (void)trasactionInfoWithProduct:(NSArray *)products
                            order:(ZFOrderCheckDoneDetailModel *)order
                       screenName:(NSString *)screenName;

/**
 *  交易--个人中心
 */
+ (void)trasactionAccountWithProduct:(MyOrdersModel *)order
                          screenName:(NSString *)screenName;

/**
 *  交易--个人中心--详情
 */
+ (void)trasactionAccountInfoWithProduct:(NSArray *)products
                                   order:(OrderDetailOrderModel *)order
                              screenName:(NSString *)screenName;

/**
 *  添加购物车
 */
+ (void)addToCartWithProduct:(GoodsDetailModel *)product fromProduct:(BOOL)isFromProduct;

/**
 *  移除购物车
 */
+ (void)removeFromCartWithItem:(ZFCartGoodsModel *)cartItem;

/**
 *  错误统计
 */
+ (void)statisticException:(NSException *)exc;

/**
 *  按钮点击事件统计
 *  @param vcName       界面名字
 *  @param actionName   按钮事件名字
 *  @param lab          标签名字
 */
+ (void)clickButtonWithCategory:(NSString *)category
                     actionName:(NSString *)actionName
                          label:(NSString*)label;

/**
 * 统计每个接口的请求时间
 */
+(void)logSpeedWithCategory:(NSString *)cateName
                  eventName:(NSString*)name
                   interval:(NSTimeInterval)interval
                      label:(NSString*)label;

/**
 *  新的按钮点击事件
 */
+ (void)clickButtonV380WithCategory:(NSString *)category
                     actionName:(NSString *)actionName
                          label:(NSString *)label;

+ (void)clickCategoryProductWithProduct:(ZFGoodsModel *)product
                               position:(int)position
                             actionList:(NSString *)actionList;

+ (void)showCategoryProductsWithProducts:(NSArray *)products
                                position:(int)position
                          impressionList:(NSString *)impressionList
                              screenName:(NSString *)screenName
                                   event:(NSString *)event;

+ (void)showSearchProductsWithProducts:(NSArray *)products
                              position:(int)position
                        impressionList:(NSString *)impressionList
                            screenName:(NSString *)screenName
                                 event:(NSString *)event;


@end




//*  @param products 展示的产品数组，其中的id和name必传一个，其他非必须
//*  @param position 产品所在位置
//*  @param impressionList 产品所在列表的名称
//*  @param screenName 产品所在页
//*  @param event 下拉加载更多名称，按event发送

@interface ZFAnalyticsProduceImpression : NSObject<NSCoding,NSCopying,NSMutableCopying>

@property (nonatomic, strong) NSArray          *products;
@property (nonatomic, assign) int              position;
@property (nonatomic, copy) NSString           *impressionList;
@property (nonatomic, copy) NSString           *screenName;
@property (nonatomic, copy) NSString           *event;

+ (instancetype)initAnalyticsProducePosition:(int)position
                              impressionList:(NSString *)impressionList
                                  screenName:(NSString *)screenName
                                       event:(NSString *)event;
@end
