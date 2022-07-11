//
//  OSSVAccountHeadCellTypeModel.h
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVAccountHeadBaseCell.h"

typedef NS_ENUM(NSInteger, AccountHeaderCellType) {
    AccountHeaderCategoryItemCellType = 2020, ///订单,收藏夹,优惠券,积分入口Cell
    AccountHeaderBannerCellType,           ///广告Cell
    AccountHeaderHorizontalScrollCellType,    ///横向左右滚动Cell
};

typedef NS_ENUM(NSInteger, AccountTableAllCellActionType) {
    AccountCategoryCell_OrderType = 2020,
    AccountCategoryCell_WishListType, ///收藏夹
    AccountCategoryCell_CouponType,         ///优惠券
    AccountCategoryCell_ZPointType,         ///积分
    AccountBannerCell_ShowBanner,           ///点击banner
};

@interface OSSVAccountHeadCellTypeModel : NSObject

/** 列表Cell类型 */
@property (nonatomic, assign) AccountHeaderCellType cellType;

/** Section所对应的Item cell类型 */
@property (nonatomic) Class sectionRowCellClass;

/** Section所对应的Item个数 */
@property (nonatomic, assign) NSInteger sectionRowCount;

/** Section所对应的Item高度 */
@property (nonatomic, assign) CGFloat sectionRowHeight;

/** Section所对应的Item cell对应的Block */
@property (nonatomic, copy) void (^accountCellActionBlock)(AccountTableAllCellActionType , id obj);

/** 广告数据模型 */
@property (nonatomic, strong) NSArray <OSSVAdvsEventsModel *> *cmsBannersModelArray;


/**
 * 获取个人中心页面所有的Cell类型
 */
+ (NSArray *)fetchAllCellTypeArray;


@end

