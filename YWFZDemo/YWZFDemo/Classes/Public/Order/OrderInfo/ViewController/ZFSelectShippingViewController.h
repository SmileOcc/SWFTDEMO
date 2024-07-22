//
//  ZFSelectShippingViewController.h
//  ZZZZZ
//
//  Created by YW on 2018/9/11.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  选择物流cell

#import "ZFBaseViewController.h"
#import "ZFOrderShippingListCell.h"

typedef void(^selectShippingBlock)(ShippingListModel *model);
///填写完DNI number回调，只有秘鲁少数国家需要填写这个税号，选填项
typedef void(^didEndEditDniBlock)(NSString *dniString);

@interface ZFSelectShippingViewController : ZFBaseViewController

@property (nonatomic, strong) ShippingListModel *selectShippingModel;
@property (nonatomic, strong) NSArray *shippingList;
@property (nonatomic, assign) BOOL isCod;
///是否显示税号
@property (nonatomic, assign) BOOL isShowTax;
@property (nonatomic, copy) NSString *oldTaxString;


@property (nonatomic, copy) selectShippingBlock selectShippingComplation;
@property (nonatomic, copy) didEndEditDniBlock  didEndEditDniBlock;

@end
