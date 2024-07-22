//
//  ZFOrderDetailOrderInfoTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFOrderDeatailListModel.h"

@interface ZFOrderDetailOrderInfoTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *orderSortNum;//第几个订单

@property (nonatomic, strong) ZFOrderDetailChildModel *childModel;

///是否显示帮助按钮
@property (nonatomic, strong) OrderDetailOrderModel *mainOrder;


@end
