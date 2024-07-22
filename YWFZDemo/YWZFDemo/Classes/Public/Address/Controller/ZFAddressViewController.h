//
//  ZFAddressViewController.h
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
@class ZFAddressInfoModel;

typedef NS_ENUM(NSInteger, AddressInfoShowType) {
    /**个人中心*/
    AddressInfoShowTypeAccount = 0,
    /**订单结算页*/
    AddressInfoShowTypeCheckOrderInfo,
    /**购物车*/
    AddressInfoShowTypeCart,
};

typedef void(^AddressChooseCompletionHandler)(ZFAddressInfoModel *model);

@interface ZFAddressViewController : ZFBaseViewController

@property (nonatomic, copy) AddressChooseCompletionHandler      addressChooseCompletionHandler;

@property (nonatomic, assign) AddressInfoShowType               addressShowType;

- (void)backUpperVC:(ZFAddressInfoModel *)model;
@end
