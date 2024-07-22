//
//  ZFOrderInformationViewController.h
//  ZZZZZ
//
//  Created by YW on 2018/11/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFCartBtsModel.h"
#import "ZFOrderCheckInfoModel.h"

@interface ZFOrderContentViewController : ZFBaseViewController

@property (nonatomic, assign) PaymentProcessType    paymentProcessType;

@property (nonatomic, assign) PayCodeType           payCode;

@property (nonatomic, strong) ZFOrderCheckInfoDetailModel   *checkoutModel;

@property (nonatomic, strong) NSArray<ZFOrderCheckInfoModel *>   *pages;

//v451 2019年01月23日15:41:02 by 陈渣渣，去掉BTS游客登录
//v4.2.0, 从购物车页面传过来，v4.2.0以后可能要删除，为了统计游客登录带来的销量, 可能为nil
//@property (nonatomic, strong) ZFCartBtsModel    *cartBtsModel;


/**
 *  V5.0.0 从商详一键(快速)购买过来时,需要带入相应参数到 cart/done, checkout_info接口
 */
@property (nonatomic, strong) NSDictionary          *detailFastBuyInfo;

@end
