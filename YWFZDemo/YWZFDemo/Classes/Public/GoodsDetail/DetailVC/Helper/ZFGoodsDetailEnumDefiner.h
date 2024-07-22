//
//  ZFGoodsDetailEnumDefiner.h
//  ZZZZZ
//
//  Created by YW on 2019/7/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#ifndef ZFGoodsDetailEnumDefiner_h
#define ZFGoodsDetailEnumDefiner_h

#import "GoodsDetailModel.h"

typedef void(^ZFGoodsDetailActionBlock)(GoodsDetailModel *model, id obj, id obj2);

/**
 * 商详页面"活动Cell"点击事件类型
 * ZFGoodsDetailActivityCell
 */
typedef NS_ENUM(NSUInteger, ZFActivityCellActionType){
    ActivityCountDownCompleteActionType = 2019,
    ActivityTapImageViewActionType,
};

/**
 * 商详页面"选择尺寸属性Cell"点击事件类型
 * ZFGoodsDetailGoodsSelectSizeCell
 */
typedef NS_ENUM(NSUInteger, ZFSelectStandardCellActionType){
    ZFSelectStandard_SizeGuideType = 2019,
    ZFSelectStandard_ChangeNumberType,
    ZFSelectStandard_ChangeGoodsIdType,       // 改变GoodsId
    ZFSelectStandard_ChangeGoodsIdBySizeType, // 来自选择尺寸时的改变GoodsId
};

/**
 * 商详页面"滚动活动"点击事件类型
 * ZFGoodsDetailGoodsQualifiedCell
 */
typedef NS_ENUM(NSUInteger, ZFQualifiedCellCellActionType){
    ZFQualified_ReductionType = 2019, // Deeplink跳转
    ZFQualified_MangJianType, // 满减活动跳转
};

/**
 * 商详页面"Show"点击事件类型
 * ZFGoodsDetailGoodsShowCell
 */
typedef NS_ENUM(NSUInteger, ZFShowCellCellActionType){
    ZFShow_ArrowAcAtionType = 2019, // 点击Show
    ZFShow_TouchImageAcAtionType, // 点击show中的图片
};

/**
 * 商详页面"Outfits"点击事件类型
 * ZFGoodsDetailOutfitsCell
 */
typedef NS_ENUM(NSUInteger, ZFOutfitsCellCellActionType){
    ZFOutfits_TouchImageActionType = 2019, // 点击sOutfitshow中的图片
    ZFOutfits_ItemButtonActionType,        // 点击ItemButton
};


/**
 * 商详"Outfits"Cell点击事件类型
 * ZFGoodsDetailOutfitsListView
 */
typedef NS_ENUM(NSUInteger, ZFOutfitsListViewActionType){
    ZFOutfitsList_FindRelatedActionType = 2019, // 找相似
    ZFOutfitsList_AddCartBagActionType,         // 加购
    ZFOutfitsList_ShowDetailActionType,         // 看详情
};


/**
* 商详"自定义导航栏"按钮点击事件类型
* ZFGoodsDetailNavigationView
*/
typedef NS_ENUM(NSInteger, ZFDetailNavButtonActionType) {
    ZFDetailNavButtonAction_BackType = 2019,
    ZFDetailNavButtonAction_TapImageType,
    ZFDetailNavButtonAction_CartType,
    ZFDetailNavButtonAction_CustomerType,
    ZFDetailNavButtonAction_ShareType,
};

#endif /* ZFGoodsDetailEnumDefiner_h */
