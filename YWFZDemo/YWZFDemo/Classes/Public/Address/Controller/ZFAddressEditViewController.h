//
//  ZFAddressEditViewController.h
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
@class ZFAddressInfoModel;

typedef NS_ENUM(NSInteger,AddressEditBottomType) {
    /**编辑、新增*/
    AddressEditBottomTypeSave,
    /**购物车下单进来*/
    AddressEditBottomTypeContinue,
};

typedef NS_ENUM(NSInteger,AddressEditStateType) {
    AddressEditStateFail = 0,
    AddressEditStateSuccess,
    /**未付款订单地址修改*/
    AddressEditStateNoPayOrderSuccess,
    /**已付款订单地址修改*/
    AddressEditStatePayOrderSuccess,
};

typedef void(^AddressEditSuccessCompletionHandler)(AddressEditStateType editStateType);

@interface ZFAddressEditViewController : ZFBaseViewController

/** 是否地址纠错调整*/
@property (nonatomic, assign) BOOL                                  isCheck;

//编辑地址带过来, 新增地址时为空
@property (nonatomic, strong) ZFAddressInfoModel                    *model;
/**来源购物车*/
@property (nonatomic, assign) BOOL                                  sourceCart;
@property (nonatomic, copy) AddressEditSuccessCompletionHandler     addressEditSuccessCompletionHandler;

/**订单修改地址:订单号*/
@property (nonatomic, copy) NSString                                *addressOrderSn;
@property (nonatomic, assign) BOOL                                  addressNoPayOrder;

/**地址相关清空*/
@property (nonatomic, strong) NSDictionary                          *checkPHAddress;

/**来源结算页调整地址*/
@property (nonatomic, assign) BOOL                                  isFromOrderCheckEdit;


/**订单地址修改及清除处理*/
- (void)editOrderAddress:(ZFAddressInfoModel *)model checkPHAddress:(NSDictionary *)checkPHAddress;
@end
