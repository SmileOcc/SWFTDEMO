//
//  ZFGoodsDetailCellTypeModel.h
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GoodsDetailModel, ZFGoodsDetailCouponModel, GoodsDetailFirstReviewModel, ReviewsSizeOverModel, ZFGoodsDetailGroupBuyModel, GoodsDetailsProductDescModel;


typedef NS_ENUM(NSInteger, ZFGoodsDetailCellType) {
    ZFGoodsDetailCellTypeScrollBanner = 2019,
    ZFGoodsDetailCellTypeActivity,
    ZFGoodsDetailCellTypeCoupon,
    ZFGoodsDetailCellTypeSelectStandard, //V4.5.3-内嵌选择尺码规格
    ZFGoodsDetailCellTypeProductModelDesc, //V5.5.0-商详针对产品描述和模特信息做BTS实验
    ZFGoodsDetailCellTypeGoodsInfo,
    ZFGoodsDetailCellTypeQualified,
    ZFGoodsDetailCellTypeShippingTips,
    ZFGoodsDetailCellTypeDescription,
    ZFGoodsDetailCellTypeModelStats,
    ZFGoodsDetailCellTypeShow,
    ZFGoodsDetailCellTypeReviewStar,
    ZFGoodsDetailCellTypeReview,
    ZFGoodsDetailCellTypeReviewViewAll,
    ZFGoodsDetailCellTypeCollocationBuy,    //V5.0.0-搭配购Cell
    ZFGoodsDetailCellTypeOutfits,           //V5.2.0-关联穿搭商品
    ZFGoodsDetailCellTTypeRecommendHeader,
    ZFGoodsDetailCellTTypeRecommend,
};


@interface ZFGoodsDetailCellTypeModel : NSObject


/** 列表Cell类型 */
@property (nonatomic, assign) ZFGoodsDetailCellType cellType;

/** Section所对应的Item个数 */
@property (nonatomic, assign) NSInteger sectionItemCount;

/** Section所对应的Item大小 */
@property (nonatomic, assign) CGSize sectionItemSize;

/** Section所对应的Item cell类型 */
@property (nonatomic, assign) Class sectionItemCellClass;

/** Section所对应的Item cell对应的Block */
@property (nonatomic, copy) void (^detailCellActionBlock)(GoodsDetailModel *, id, id );

/** 滑动到推荐Section所对应的Block */
@property (nonatomic, copy) void (^willShowRecommendCellBock)(GoodsDetailModel *);

/** 滑动到评论Section所对应的Block */
@property (nonatomic, copy) void (^willShowReviewCellBock)(GoodsDetailModel *);

/** 滑动到搭配购Section所对应的Block */
@property (nonatomic, copy) void (^willShowCollocationBuyCellBock)(GoodsDetailModel *);

/** 点击评论Cell中的事件所对应的Block */
@property (nonatomic, copy) void (^reviewCellActionBock)(GoodsDetailModel *, id, id);

/** Section所对应的Cell数据源 */
@property (nonatomic, strong) GoodsDetailModel *detailModel;

/** banner数据源Cell所对应的占位图 */
@property (nonatomic, strong) UIImage *placeHoldImage;

/**
 * ================ 以下数据模型跟着CellTypeModel走, 页面切换规格后不重新请求 ===================
 */

/** 优惠券数据 */
@property (nonatomic, strong) NSArray<ZFGoodsDetailCouponModel *> *couponListModelArr;
/** 评论星级 */
@property (nonatomic, strong) ReviewsSizeOverModel *reviewsRankingModel;
/** 评论数据单独接口获取 */
@property (nonatomic, strong) NSArray<GoodsDetailFirstReviewModel *> *reviewModelArray;
/** 评论数据高度 */
@property (nonatomic, strong) NSArray *reviewCellSizeArray;

/**
 * 获取商详页面所有的Cell类型
 */
+ (NSArray *)fetchDetailAllCellTypeArray;

@end
