//
//  ZFOrderSuccessPageVC.h
//  ZZZZZ
//
//  Created by YW on 2019/9/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  订单成功页控制器

#import "ZFBaseViewController.h"
#import "ZFFiveThModel.h"
#import "ZFBaseOrderModel.h"
#import "ZFOrderPayResultHandler.h"

typedef void(^OrderFinishBlock)(BOOL isAccount);

@interface ZFOrderSuccessPageVC : ZFBaseViewController

@property (nonatomic, copy) OrderFinishBlock     toAccountOrHomeblock;
/**只有结算页进来的，才会显示*/
@property (nonatomic, assign) BOOL               isShowNotictionView;

///是否COD支付
@property (nonatomic, assign) BOOL               isCodPay;

@property (nonatomic, assign) ZFOrderPayResultSource fromType;

///线下支付查看token link
@property (nonatomic, copy) NSString *offlineLink;

///五周年纪念日送积分优惠券字段
@property (nonatomic, strong) ZFFiveThModel *fiveThModel;

///各种下单场景中的商品模型列表，用于统计数据
@property (nonatomic, strong) ZFBaseOrderModel *baseOrderModel;

@end


