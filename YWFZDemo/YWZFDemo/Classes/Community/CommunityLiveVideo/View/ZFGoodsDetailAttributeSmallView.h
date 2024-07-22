//
//  ZFGoodsDetailAttributeSmallView.h
//  ZZZZZ
//
//  Created by YW on 2019/7/24.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsAttributeBaseView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ZFGoodsDetailAttributeSmallViewDelegate;

@interface ZFGoodsDetailAttributeSmallView : ZFGoodsAttributeBaseView

//是否显示购物车按钮，及背景色设置
- (instancetype)initWithFrame:(CGRect)frame showCart:(BOOL)show alpha:(CGFloat)alpha;

- (instancetype)initWithFrame:(CGRect)frame comeFromSelecteType:(BOOL)comeFromType;


@property (nonatomic, weak) id<ZFGoodsDetailAttributeSmallViewDelegate> delegate;

@property (nonatomic, assign) NSInteger                 chooseNumebr;

- (void)openSelectTypeView;
- (void)hideSelectTypeView;
- (void)changeCartNumberInfo;
- (void)bottomCartViewEnable:(BOOL)enable;

@end


@protocol ZFGoodsDetailAttributeSmallViewDelegate <NSObject>

- (void)goodsDetailAttribute:(ZFGoodsDetailAttributeSmallView *)attributeView showState:(BOOL)isShow;

- (void)goodsDetailAttribute:(ZFGoodsDetailAttributeSmallView *)attributeView selectGoodsId:(NSString *)goodsId;

- (void)goodsDetailAttribute:(ZFGoodsDetailAttributeSmallView *)attributeView tapCart:(BOOL)tapCart;

- (void)goodsDetailAttribute:(ZFGoodsDetailAttributeSmallView *)attributeView addCartGoodsId:(NSString *)goodsId count:(NSInteger)count;


@end
NS_ASSUME_NONNULL_END
