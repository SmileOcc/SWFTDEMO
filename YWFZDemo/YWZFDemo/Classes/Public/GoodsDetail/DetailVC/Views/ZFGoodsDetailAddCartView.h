//
//  ZFGoodsDetailAddCartView.h
//  ZZZZZ
//
//  Created by YW on 2017/11/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsDetailModel.h"

typedef NS_ENUM(NSInteger, GoodsDetailBottomViewActionType_A) {
    GoodsDetailActionA_pushCarType,  // 查看购物车
    GoodsDetailActionA_addCartType,  // 添加到购物车
    GoodsDetailActionA_similarType,  //下架售罄商品找相似
};

typedef void(^GoodsDetailBottomViewBlock)(GoodsDetailBottomViewActionType_A actionType);

@interface ZFGoodsDetailAddCartView : UIView

@property (nonatomic, strong) UIButton                          *cartButton;
@property (nonatomic, strong) GoodsDetailModel                  *model;
@property (nonatomic, copy)   GoodsDetailBottomViewBlock        goodsDetailBottomViewBlock;

- (void)changeCartNumberInfo;

@end
