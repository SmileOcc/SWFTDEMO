//
//  ZFOrderDetailAddressTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDetailOrderModel.h"

@protocol ZFOrderDetailAddressTableViewCellDelegate <NSObject>

- (void)ZFOrderDetailAddressTableViewCellDidClickConfirmButton:(OrderDetailOrderModel *)model;

- (void)ZFOrderDetailAddressTableViewCellDidClickChangeAddressButton:(OrderDetailOrderModel *)model;

@end

@interface ZFOrderDetailAddressTableViewCell : UITableViewCell
@property (nonatomic, strong) OrderDetailOrderModel             *model;

@property (nonatomic, weak) id<ZFOrderDetailAddressTableViewCellDelegate>delegate;

@end
