//
//  ZFGoodsDetailSelectTypeView.h
//  ZZZZZ
//
//  Created by YW on 2017/11/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsAttributeBaseView.h"

typedef void(^GoodsDetailSelectTypeShowOrCloseBlock)(BOOL isOpen);
typedef void(^GoodsDetailSelectTypeBlock)(NSString *goodsId);
typedef void(^GoodsDetailSelectSizeGuideBlock)(NSString *);

@interface ZFGoodsDetailSelectTypeView : ZFGoodsAttributeBaseView

//是否显示购物车按钮，及背景色设置
- (instancetype)initSelectSizeView:(BOOL)showCart
                    bottomBtnTitle:(NSString *)bottomBtnTitle;


// 外部设置加购文案
@property (nonatomic, copy) NSString *addToBagTitle;

@property (nonatomic, copy) GoodsDetailSelectTypeShowOrCloseBlock   openOrCloseBlock;
@property (nonatomic, copy) GoodsDetailSelectTypeBlock              goodsDetailSelectTypeBlock;
@property (nonatomic, copy) GoodsDetailSelectSizeGuideBlock         goodsDetailSelectSizeGuideBlock;
@property (nonatomic, copy) void (^cartBlock)(void);
@property (nonatomic, copy) void (^addCartBlock)(NSString *goodsId, NSInteger count);

- (void)openSelectTypeView;

- (void)hideSelectTypeView;

- (void)changeCartNumberInfo;

- (void)bottomCartViewEnable:(BOOL)enable;

///开始一个加购动画 in self
- (void)startAddCartAnimation:(void(^)(void))endBlock;

/**
 *  开始一个加购动画 in superview
 *  endPoint 动画结束点
 *  endView 动画结束后需要动画的视图
 *  endblock 动画结束回调
 */
- (void)startAddCartAnimation:(UIView *)superView
                     endPoint:(CGPoint)endPoint
                      endView:(UIView *)endView
                     endBlock:(void(^)(void))endBlock;


@end
