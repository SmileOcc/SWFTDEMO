//
//  ZFOrderInfoViewController.h
//  ZZZZZ
//
//  Created by YW on 13/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFCartBtsModel.h"
#import "ZFOrderCheckInfoDetailModel.h"

@class ZFOrderManager;

@interface ZFOrderInfoViewController : ZFBaseViewController

@property (nonatomic, strong) ZFOrderManager                *manager;

@property (nonatomic, strong) ZFOrderCheckInfoDetailModel   *checkOutModel;

@property (nonatomic, assign) PayCodeType                   payCode;

@property (nonatomic, assign) BOOL                          isFastPay;

/**
 * 从商详一键(快速)购买过来时,需要带入相应参数到 cart/done, checkout_info 接口
 */
@property (nonatomic, strong) NSDictionary                  *detailFastBuyInfo;

- (void)refreshOrderAddress:(ZFAddressInfoModel *)model;

@end
