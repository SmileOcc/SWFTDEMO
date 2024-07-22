//
//  ZFGoodsDetailCartInfoPopView.h
//  ZZZZZ
//
//  Created by YW on 2018/11/9.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//
// 商详页面导购物车按钮弹框箭头

#import <UIKit/UIKit.h>
@class GoodsDetailModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFGoodsDetailCartInfoPopView : UIView

@property (nonatomic, strong) GoodsDetailModel *detailModel;

@property (nonatomic, copy) void (^addToCartBlcok)(GoodsDetailModel *detailModel);

@end

NS_ASSUME_NONNULL_END
