//
//  ZFPaymentGoodsInfoView.h
//  ZZZZZ
//
//  Created by YW on 2018/11/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CheckOutGoodListModel;

@interface ZFPaymentGoodsInfoView : UIView
@property (nonatomic, strong) NSArray<CheckOutGoodListModel *>            *dataArray;
@end
