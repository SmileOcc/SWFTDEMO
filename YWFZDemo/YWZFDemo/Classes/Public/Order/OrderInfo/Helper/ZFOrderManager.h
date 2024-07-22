//
//  ZFOrderManager.h
//  ZZZZZ
//
//  Created by YW on 27/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFOrderCheckInfoDetailModel.h"
#import "ZFOrderCheckDoneDetailModel.h"

// 当前支付方式
typedef NS_ENUM(NSUInteger, CurrentPaymentType){
    // cod 支付
    CurrentPaymentTypeCOD      = 1,
    // online 支付
    CurrentPaymentTypeOnline   = 2,
    //
    CurrentPaymentTypeUnSelect   = 3
};


@interface ZFOrderManager : NSObject

@property (nonatomic, copy) NSString *couponCode; // 优惠码

@property (nonatomic, copy) NSString *addressId;// 地址id

@property (nonatomic, copy) NSString *shippingId; // 物流id

@property (nonatomic, copy) NSString *need_traking_number;

@property (nonatomic, copy) NSString *insurance; // 物流保险费

@property (nonatomic, copy) NSString *currentPoint; // 目前使用积分

@property (nonatomic, copy) NSString *pointSavePrice; //point优惠

@property (nonatomic, copy) NSString *paymentCode; // 支付编码

@property (nonatomic, copy) NSString *verifyCode; // 手机验证码

@property (nonatomic, copy) NSString *isCod;// 是否是货到付款（给后台验证的）

@property (nonatomic, copy) NSString *node; // 1 cod方式， 2 online方式

@property (nonatomic, copy) NSString *orderID; // 订单号

@property (nonatomic, copy) NSString   *autoCoupon; // 是否自动使用coupon

@property (nonatomic, copy) NSString *taxString;    //用户输入的税号

///是否使用积分, 控制AB版本里面，1，2版本中，point的选项卡
@property (nonatomic, assign) BOOL   isUsePoint;

///用户输入的身份证号
@property (nonatomic, copy) NSString *pccNum;

/*************** 上面的参数是接口上传需要用的  *********************/

@property (nonatomic, copy) NSString   *currentInputPoint; // 当前输入的积分

////支付明细 cell class list  调用queryAmountDetailArray方法后赋值
//@property (nonatomic, strong) NSMutableArray <Class> *detailCellList;

///主要用于统计代码
@property (nonatomic, strong) NSMutableArray   *shippingListArray;

@property (nonatomic, copy) NSString *shippingPrice; // 物流运费

@property (nonatomic, copy) NSString *couponAmount; // coupon优惠

@property (nonatomic, copy) NSString *goods_price; // 商品价格

@property (nonatomic, copy) NSString *codFreight; // 货到付款收取的运费

@property (nonatomic, copy) NSString *countryID;

@property (nonatomic, copy) NSString *bizhong;

@property (nonatomic, copy) NSString *activities_amount; // 满减优惠的价格

@property (nonatomic, copy) NSString *student_discount_amount;  //学生卡优惠价格

@property (nonatomic, copy) NSString *addressCode;

@property (nonatomic, copy) NSString *supplierNumber;

@property (nonatomic, copy) NSString *tel;

@property (nonatomic, assign) CurrentPaymentType   currentPaymentType; // 用来判断当前支付方式,并切换货币符号

//@property (nonatomic, assign) BOOL   isShowVAT; // 判断是否需要显示税费
@property (nonatomic, copy) NSString   *vat; // 税收

///用于growingIO统计代码，别的地方取，用gainBuyProductTotalNumbers
@property (nonatomic, copy) NSString *totalNumbers;
@property (nonatomic, copy) NSString *couponName;

//COD 替换占位符 默认 $cod_fee
@property (nonatomic, copy) NSString *codReplaceHold;

/************************下面参数用于快速支付***************************/
@property (nonatomic,copy) NSString *payertoken;
@property (nonatomic,copy) NSString *payerId;


/************************  用于A/B测试  ***************************/
@property (nonatomic, assign) BOOL   isSelectCoupon; // 是否选中优惠券
@property (nonatomic, assign) BOOL   isSelectInsurance; // 是否选中保险费
///已经取消ABTest isShowShippingInfo
@property (nonatomic, assign) BOOL   isShowShippingInfo; // 是否显示物流说明


- (void)adapterManagerWithModel:(ZFOrderCheckInfoDetailModel *)checkOutModel;
/**
 * 获取价格明细对应的model
 */
//- (NSMutableArray *)queryAmountDetailArray;
- (void)queryAmountDetailArray:(void(^)(NSArray *amountDetailModelArray, NSArray *detailCellList))complation;

- (NSString *)queryAmountNumber;

/**
 * 获取商品原价格
 */
- (NSString *)querySubtotal;
/**
 * 获取订单运费
 */
- (NSString *)queryShippingCost;
/**
 * 获取保险费
 */
- (NSString *)queryShippingInsurance;
/**
 * 获取cod手续费
 */
- (NSString *)queryCodCost;
/**
 * 参与营销满减活动商品，对应分摊享受的优惠金额
 */
- (NSString *)queryEventDiscount;
/**
 * 订单优惠券使用金额
 */
- (NSString *)queryCoupon;
/**
 * 积分优惠金额
 */
- (NSString *)queryZPointsSaving;
/**
 * 首次汇总金额
 */
- (NSString *)queryGrandTotal;
/**
 * 获取cod取整后价格
 */
- (NSString *)queryCodDiscount;
/**
 * 最终需要用户支付金额
 */
- (NSString *)queryTotalPayable;

/**
 * 判断cod商品是否超过规定金额限制 如果商品总额小于50 或 大于400 要做提示
 */
- (BOOL)isShowCODGoodsAmountLimit:(NSString *)payCode checkoutModel:(ZFOrderCheckInfoDetailModel *)checkoutModel;

/**
 * 获取cod 弹框显示的金额
 */
- (NSString *)queryCashOnDelivery;

/**
 * 获取当前订单显示的货币
 */
- (void)queryCurrentOrderCurrency;

/**
 * 拼接订单商品的订单号
 */
- (NSString *)appendGoodsSN:(ZFOrderCheckInfoDetailModel *)model;

/**
 * 拼接订单商品的价格
 */
- (NSString *)appendGoodsPrice:(ZFOrderCheckInfoDetailModel *)model;

/**
 * 拼接订单商品的数量
 */
- (NSString *)appendGoodsQuantity:(ZFOrderCheckInfoDetailModel *)model;

/**
 * 支付方式统计
 */
- (void)analyticsClickButton:(NSString *)payMethod state:(NSInteger)state;

/**
 * 获取对应支付方式名称 (用于谷歌统计)
 */
- (NSString *)orderTypeNameWithPayCode:(NSInteger)payCode;

/**
 * 配置 A/B 测试所需变量
 */
- (void)configureABTest;

/**
 *  商品总数量
 */
- (NSString *)gainBuyProductTotalNumbers;

@end
