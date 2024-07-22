//
//  ZFAccountHeaderCellTypeModel.h
//  ZZZZZ
//
//  Created by YW on 2019/10/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ZFCMSItemModel, ZFNewBannerModel, MyOrdersModel;

typedef NS_ENUM(NSInteger, ZFAccountHeaderCellType) {
    AccountHeaderCategoryItemCellType = 2019, ///订单,收藏夹,优惠券,积分入口Cell
    AccountHeaderUnpaidOrderCellType,         ///未支付订单Cell
    AccountHeaderCMSBannerCellType,           ///CMS广告Cell
    AccountHeaderHorizontalScrollCellType,    ///横向左右滚动Cell
};

typedef NS_ENUM(NSInteger, ZFAccountTableAllCellActionType) {
    ZFAccountCategoryCell_OrderType = 2019,   ///订单
    ZFAccountCategoryCell_WishListType,       ///收藏夹
    ZFAccountCategoryCell_CouponType,         ///优惠券
    ZFAccountCategoryCell_ZPointType,         ///积分
    ZFAccountBannerCell_ShowBanner,           ///点击banner
    ZFAccountUnpaidCell_DetailAction,         ///查看订单详情事件
    ZFAccountUnpaidCell_GoPayAction,           ///去支付订单事件
};

@interface ZFAccountHeaderCellTypeModel : NSObject


/** 列表Cell类型 */
@property (nonatomic, assign) ZFAccountHeaderCellType cellType;

/** Section所对应的Item cell类型 */
@property (nonatomic) Class sectionRowCellClass;

/** Section所对应的Item个数 */
@property (nonatomic, assign) NSInteger sectionRowCount;

/** Section所对应的Item高度 */
@property (nonatomic, assign) CGFloat sectionRowHeight;

/** Section所对应的Item cell对应的Block */
@property (nonatomic, copy) void (^accountCellActionBlock)(ZFAccountTableAllCellActionType , id obj);

/** CMS广告数据模型 */
@property (nonatomic, strong) NSArray <ZFNewBannerModel *> *cmsBannersModelArray;

/** 未支付订单模型 */
@property (nonatomic, strong) MyOrdersModel *unpaidOrderModel;

/**
 * 获取个人中心页面所有的Cell类型
 */
+ (NSArray *)fetchAllCellTypeArray;

@end
