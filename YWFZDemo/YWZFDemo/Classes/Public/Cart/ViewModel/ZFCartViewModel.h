//
//  ZFCartViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"
@class ZFCartGoodsModel, ZFCartListResultModel, GoodsDetailModel;

// 注册页网页跳转类型
typedef NS_ENUM(NSUInteger, FastPaypalCheckType){
    //未登录&未注册
    //返回：1.用户信息  2.PP地址信息
    FastPaypalCheckTypeNoLoginAndNoRegiste = 1,
    //2.未登录 & PP用户注册过 & 无地址信息
    //返回：1.用户信息  2.PP地址信息
    FastPaypalCheckTypeNoLoginAndRegistedAndNoAddress = 2,
    //3.未登录 & PP用户注册过 & 有地址信息
    //返回：1.用户信息  2.checkout信息
    FastPaypalCheckTypeNoLoginAndRegistedAndHasAddress = 3,
    //4.登录 & 无地址信息
    //返回：1.PP地址信息
    FastPaypalCheckTypeLoginAndNoAddress = 4,
    //5.登录 & 有地址信息
    //返回：1.checkout信息
    FastPaypalCheckTypeLoginAndHasAddress = 5
};

@interface ZFCartViewModel : BaseViewModel

/**
 * 请求购物车列表数据
 */
- (void)requestCartListWithGiftFlag:(NSString *)addGiftFlag
                         completion:(void (^)(ZFCartListResultModel *cartListModel))completion
                            failure:(void (^)(NSError *))failure;

/**
 * 购物车切换商品规格
 */
+ (void)requestCartSizeColorData:(NSString *)goods_id
                      completion:(void (^)(GoodsDetailModel *goodsModel))completion
                         failure:(void (^)(NSError *))failure;

/**
 * 生成订单
 */
- (void)requestCartCheckOutNetwork:(NSDictionary *)couponDict
                        completion:(void (^)(id obj))completion
                           failure:(void (^)(NSError *error))failure;

/**
 * 快捷支付
 */
- (void)requestCartFastPayNetwork:(NSDictionary *)parmaters
                       completion:(void (^)(BOOL hasAddress, id obj))completion
                          failure:(void (^)(id obj))failure;


/**
 * 选择支付流程
 */
- (void)requestPaymentProcessCompletion:(void (^)(NSInteger state, NSString *msg))completion
                                failure:(void (^)(NSError *error))failure;

/**
 * 新增获取SOA快捷支付链接
 */
- (void)requestPayPaylProcessCompletion:(void (^)(NSInteger state, NSString *msg, NSString *url))completion
                                failure:(void (^)(id obj))failure;

@end

