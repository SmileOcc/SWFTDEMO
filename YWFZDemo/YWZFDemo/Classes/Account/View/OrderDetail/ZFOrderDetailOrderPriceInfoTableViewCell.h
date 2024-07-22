//
//  ZFOrderDetailOrderPriceInfoTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFOrderDetailPriceModel.h"
#import "ZFOrderDeatailListModel.h"

@interface ZFOrderDetailOrderPriceInfoTableViewCell : UITableViewCell

@property (nonatomic, strong) ZFOrderDetailPriceModel           *priceModel;
@property (nonatomic, strong) ZFOrderDeatailListModel             *model;

@end
