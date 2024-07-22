//
//  ZFFireBaseAnalytics.h
//  ZZZZZ
//
//  Created by YW on 2017/11/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GoodsDetailModel, ZFOrderCheckDoneDetailModel, ZFOrderCheckInfoDetailModel, ZFBaseOrderModel;

/**
 FireBase 统计
 */
@interface ZFFireBaseAnalytics : NSObject

// 记录屏幕流量数
+ (void)screenRecordWithName:(nonnull NSString *)screenName screenClass:(nullable NSString *)screenClass;

// 记录 App 打开
+ (void)appOpen;

// 添加结算信息到服务器
+ (void)addPaymentInfo;

// 商品浏览记录
+ (void)scanGoodsWithGoodsModel:(nonnull GoodsDetailModel *)goodsModel;

// 商品列表浏览记录
+ (void)scanGoodsListWithCategory:(nonnull NSString *)categaory;

// 搜索结果
+ (void)searchResultWithTerm:(nonnull NSString *)term;

// 添加购物车
+ (void)addToCartWithGoodsModel:(nonnull GoodsDetailModel *)goodsModel;

// 添加收藏
+ (void)addCollectionWithGoodsModel:(nonnull GoodsDetailModel *)goodsModel;

// 开始结算
+ (void)beginCheckOutWithGoodsInfo:(nullable ZFOrderCheckInfoDetailModel *)goodsInfo;

// 创建订单成功
+ (void)createOrderWithOrderModel:(nullable ZFOrderCheckDoneDetailModel *)orderModel;

// 商品购买完成
+ (void)finishedPurchaseWithOrderModel:(nonnull ZFBaseOrderModel *)orderModel;

// 注册记录
+ (void)signUpWithType:(nonnull NSString *)typeName;

// 登录方式
+ (void)signInWithTypeName:(nonnull NSString*)typeName;

// 选择内容时触发
+ (void)selectContentWithItemId:(nonnull NSString *)itemId
                       itemName:(nullable NSString *)itemName
                    ContentType:(nonnull NSString *)contentType
                   itemCategory:(nullable NSString *)category;

// 订单进度
+ (void)checkoutProgressWithStep:(NSInteger)step checkInfoModel:(ZFOrderCheckInfoDetailModel *_Nullable)checkInfoModel;

@end
