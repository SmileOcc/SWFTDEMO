//
//  ZFOrderShippingV390Cell.h
//  ZZZZZ
//
//  Created by YW on 2018/9/11.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  V390版本以后使用在提交订单页面的物流cell

#import <UIKit/UIKit.h>
#import "ShippingListModel.h"
#import "ZFOrderCheckInfoDetailModel.h"

@interface ZFOrderShippingV390Cell : UITableViewCell
+ (NSString *)queryReuseIdentifier;
@property (nonatomic, strong) ShippingListModel *model;
@property (nonatomic, assign) BOOL isCod;
@property (nonatomic, assign) BOOL isShowTax;
//提交订单模型
@property (nonatomic, weak) ZFOrderCheckInfoDetailModel *checkOutModel;
@end
