//
//  ZFOrderCheckDoneModel.h
//  ZZZZZ
//
//  Created by YW on 24/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFOrderCheckDoneDetailModel.h"

//@class ZFOrderCheckDoneDetailModel;
@interface ZFOrderCheckDoneModel : NSObject
@property (nonatomic, strong) ZFOrderCheckDoneDetailModel         *order_info;
@property (nonatomic, assign) NSInteger                           node;                       // 1 cod方式， 2 online方式
@property (nonatomic, assign) BOOL                                isSuccess;                  // 是否支付成功
@property (nonatomic, assign) BOOL                                isBackToCart;               // 是否返回购物车
@end
