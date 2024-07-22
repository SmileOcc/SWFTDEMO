//
//  ZFHandpickGoodsListVC.h
//  ZZZZZ
//
//  Created by YW on 2018/9/17.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//
/**
 * 精选商品列表, 目前的入口只能从Deeplink进来
 * V4.3.0 增加从优惠券deeplink进来入口
 */

#import "ZFBaseViewController.h"
#import "JumpModel.h"

@interface ZFHandpickGoodsListVC : ZFBaseViewController

@property (nonatomic, strong) NSString *goodsIDs; //id以逗号隔开

//是否从优惠券的deeplink进来 (因为V4.3.0此页面与优惠券deeplink页面通用同一个页面)
@property (nonatomic, assign) BOOL isCouponListDeeplink;

//智能推荐 实验id集合
@property (nonatomic, strong) ZFPushPtsModel *ptsModel;

@end
