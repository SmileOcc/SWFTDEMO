//
//  OSSVCartPaymentModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVCartPaymentModel : NSObject
@property (nonatomic, copy) NSString *payVoucherNumberDesc;    //网红单剩余次数的文案
@property (nonatomic, copy) NSString *payVoucherDiscountDesc;  //网红单优惠金额文案
@property (nonatomic, copy) NSString *payVoucherDiscountAmount;  //网红单优惠金额

@property (nonatomic, copy) NSString *payid;
@property (nonatomic, copy) NSString *payCode;
@property (nonatomic, copy) NSString *payDesc;
@property (nonatomic, copy) NSString *payDiscount; //支付优惠折扣
@property (nonatomic, copy) NSString *payName;
@property (nonatomic, copy) NSString *payDiscountId; //支付优惠ID
@property (nonatomic, copy) NSString *payIconUrlStr; //支付方式图片URL
@property (nonatomic, assign) BOOL    isOptional; // Cod支付是否可选.非cod支付方式的话可选默认为yes.只有当支付方式为cod的时候后台需要判断 50$<订单金额<400$ 并返回结果.
@property (nonatomic, copy) NSString *poundage; // 手续费.非cod支付方式的话手续费默认为0.
@property (nonatomic, copy) NSString *payHelp;
@property (nonatomic, assign) BOOL    isSelectedPayMent;  //是否有选中的支付方式
/**fractions_type   取整模式：默认0不取整 1向上取整 2向下取整*/
@property (nonatomic, copy) NSString *fractions_type;

@property (nonatomic, copy) NSString *dialog_tip_text;
@property (nonatomic, copy) NSString *payment_discount_desc;

/*是否是COD支付方式，YES 是 NO 不是*/
-(BOOL)isCodPayment;

//是否是网红单（Influencer）支付
- (BOOL)isInfluencerPayment;
@end
