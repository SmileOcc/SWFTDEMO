//
//  ZFOrderDetailVatTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/3/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDetailOrderModel.h"

typedef void(^ZFOrderDetaiVatTipsCompletionHandler)(NSString *tips);

@interface ZFOrderDetailVatTableViewCell : UITableViewCell
@property (nonatomic, strong) OrderDetailOrderModel             *model;

@property (nonatomic, copy) ZFOrderDetaiVatTipsCompletionHandler            orderDetaiVatTipsCompletionHandler;
@end
