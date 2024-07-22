//
//  ZFGoodsDetailProtocol.h
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#ifndef ZFGoodsDetailProtocol_h
#define ZFGoodsDetailProtocol_h

#import "ZFGoodsDetailAddCartView.h"
#import "ZFGoodsDetailEnumDefiner.h"

@class ZFGoodsDetailCouponModel, GoodsDetailModel, ZFOrderCheckInfoModel;

/*!
 *  @brief 用于布局
 */
@protocol GoodsDetailVCActionProtocol <NSObject>

@required

// =================ZFGoodsDetailNavigationView所有点击事件=======================

- (void)handleNavgationAction:(ZFDetailNavButtonActionType)actionType;


// =================ZFGoodsdetailCouponListView所有点击事件=======================
- (void (^)(ZFGoodsDetailCouponModel *couponModel, NSIndexPath *indexPath))getCouponBlock;


// =================ZFGoodsDetailOutfitsListView所有点击事件=======================
- (void (^)(ZFGoodsModel *goodsModel, NSUInteger actionType))outfitsActionBlock;


// =================ZFGoodsDetailAddCartView所有点击事件=======================
- (void(^)(GoodsDetailBottomViewActionType_A actionType))goodsDetailBottomViewBlock;



// =================ZFGoodsDetailCollectionView 所有Cell点击事件=======================
- (ZFGoodsDetailActionBlock)activityCellActionBlock;

- (ZFGoodsDetailActionBlock)normalArrowsActionBlock;

- (void)openWebInfoWithUrl:(NSString *)url title:(NSString *)title;

- (void)showNavCartInfoPopView:(GoodsDetailModel *)detailModel;

/**
 * 点击评论列表回调
 * ZFGoodsDetailGoodsReviewCell
 */
- (ZFGoodsDetailActionBlock)reviewCellActionBlock;

/**
 * 点击推荐商品回调
 * ZFGoodsDetailGoodsRecommendCell
 */
- (ZFGoodsDetailActionBlock)recommendCellActionBlock;

/**
 * 商详页面"滚动活动"点击事件类型
 * ZFGoodsDetailGoodsQualifiedCell
 */
- (ZFGoodsDetailActionBlock)qualifiedCellActionBlock;

/**
 * 商详页面"Show"点击事件类型
 * ZFGoodsDetailGoodsShowCell
 */
- (ZFGoodsDetailActionBlock)showCellActionBlock;

/**
 * "Outfits"点击事件类型
 * ZFGoodsDetailOutfitsCell
 */
- (ZFGoodsDetailActionBlock)outfitsCellActionBlock;

/**
 * 是否显示商详顶部请求大占位图
 * ZFGoodsDetailTransformView
 */
- (void)showTransformView:(BOOL)show;

/**
 * "搭配购"按钮点击事件
 * ZFGoodsDetailCollocationBuyCell
 */
- (ZFGoodsDetailActionBlock)collocationBuyActionBlock;

/**
 * 快速购买下单
 */
- (void)fastBuyActionPush:(ZFOrderCheckInfoModel *)checkInfoModel
                extraInfo:(NSDictionary *)extraInfo
             refreshBlock:(void(^)(NSInteger))refreshBlock;

@end



@protocol GoodsDetailViewActionProtocol <NSObject>

@optional

/** 表格滚动回调 */
- (void)collectionViewDidScroll:(UIScrollView *)scrollView;

/** 表点击导航上的图片回调 */
- (void (^)(void))tapNavigationGoodsImageBlcok;

@end

#endif /* ZFGoodsDetailProtocol_h */
