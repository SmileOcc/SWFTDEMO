//
//  ZFOrderShippingListCell.h
//  ZZZZZ
//
//  Created by YW on 19/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//  现使用于SelectShippingViewController中

#import <UIKit/UIKit.h>

@class ShippingListModel;
@interface ZFOrderShippingListCell : UITableViewCell
+ (NSString *)queryReuseIdentifier;
@property (nonatomic, strong) ShippingListModel *shippingListModel;
@property (nonatomic, assign) BOOL              isChoose;
@property (nonatomic, assign) BOOL              isCod;
@end
