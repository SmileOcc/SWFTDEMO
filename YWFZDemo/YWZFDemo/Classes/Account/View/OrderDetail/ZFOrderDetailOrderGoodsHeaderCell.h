//
//  ZFOrderDetailOrderGoodsHeaderCell.h
//  ZZZZZ
//
//  Created by YW on 2018/9/20.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  订单详情，商品header

#import <UIKit/UIKit.h>
#import "ZFOrderDeatailListModel.h"

typedef NS_ENUM(NSInteger) {
    ButtonType_OpenOfflineToken,
    ButtonType_BuyAgain,
}ButtonType;

typedef void(^ZFOrderDetailOrderBackToCartCompletion)(ButtonType type);

@interface ZFOrderDetailOrderGoodsHeaderCell : UITableViewCell

@property (nonatomic, strong) ZFOrderDeatailListModel          *model;
@property (nonatomic, copy) ZFOrderDetailOrderBackToCartCompletion          orderDetailOrderBackToCartCompletionHandler;

@end
