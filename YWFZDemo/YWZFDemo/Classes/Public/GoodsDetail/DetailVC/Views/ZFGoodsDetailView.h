//
//  ZFGoodsDetailView.h
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsDetailProtocol.h"

@class GoodsDetailModel, ZFGoodsDetailCellTypeModel;

@interface ZFGoodsDetailView : UIView<GoodsDetailViewActionProtocol>

- (instancetype)initWithActionProtocol:(id<GoodsDetailVCActionProtocol>) actionProtocol;

@property (nonatomic, strong) GoodsDetailModel  *detailModel;

@property (nonatomic, copy) NSString *tmpShowOutfitsId;

/** 表格Cell数据源类型 */
@property (nonatomic, strong) NSArray<ZFGoodsDetailCellTypeModel *> *sectionTypeModelArr;

- (void)reloadDetailView:(BOOL)reloadAll sectionIndex:(NSInteger)sectionIndex;

- (void)showDetailEmptyView:(NSError *)error refreshBlock:(void(^)(void))refreshBlock;

- (void)showDetailFooterRefresh:(BOOL)showFooterRefresh
                   refreshBlock:(void(^)(void))refreshBlock;

/** 刷新/显示优惠券列表 */
- (void)showCouponPopView:(NSArray *)couponModelArr shouldRefresh:(BOOL)isRefresh;

/** 显示穿搭弹框列表 */
- (void)showOutfitsListPopView:(NSArray *)goodsModelArr;

- (void)showGroupBuyWithModel:(ZFGoodsDetailGroupBuyModel *)groupBuyModel;

- (void)showOutfitsAttributePopView:(ZFGoodsModel *)goodsModel;

- (void)showAddCartInfoPopView:(GoodsDetailModel *)detailModel;

- (void)hideAddCartInfoPopView;

- (void)cancelHideAddCartPopViewAction;

- (void)refreshProductDescHeight;

- (UIImage *)navigationGoodsImage;

/** 显示购物车加购动画 */
- (void)showAddCarAnimation;

/// 显示导航栏上的购物车加购动画
- (void)showNavgationAddCarAnimation:(void(^)(void))finishAnimation
                   scrollToRecommend:(BOOL)scrollToRecommend;

- (void)scrollToRecommendGoodsPostion;

/** 刷新购物车, 导航栏按钮换肤 */
- (void)refreshNavAndCartBage;

@end
