//
//  ZFCarPiecingOrderSubVC.h
//  ZZZZZ
//
//  Created by YW on 2018/9/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//
// 购物车凑单页面 子控制器

#import "ZFBaseViewController.h"

@class ZFGoodsModel;

@interface ZFCarPiecingOrderSubVC : ZFBaseViewController

@property (nonatomic, strong) NSString *priceSectionID; //价格区间列表id

@property (nonatomic, strong) NSArray<ZFGoodsModel *> *goodDataList;

@end
