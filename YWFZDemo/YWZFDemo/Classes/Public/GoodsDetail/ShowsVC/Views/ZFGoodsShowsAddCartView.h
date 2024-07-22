//
//  ZFGoodsShowsAddCartView.h
//  ZZZZZ
//
//  Created by YW on 2019/3/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GoodsDetailModel;

typedef NS_ENUM(NSInteger, GoodsShowsAddCartActionType) {
    GoodsShowsAddCart_pushCarType,  // 查看购物车
    GoodsShowsAddCart_addCartType,  // 添加到购物车
};

typedef void(^GoodsShowsBottomViewBlock)(GoodsShowsAddCartActionType actionType);

NS_ASSUME_NONNULL_BEGIN

@interface ZFGoodsShowsAddCartView : UIView

@property (nonatomic, strong) GoodsDetailModel                  *model;

@property (nonatomic, copy) GoodsShowsBottomViewBlock showBottomViewBlock;

- (void)refreshCartCountWithAnimation;

@end

NS_ASSUME_NONNULL_END
