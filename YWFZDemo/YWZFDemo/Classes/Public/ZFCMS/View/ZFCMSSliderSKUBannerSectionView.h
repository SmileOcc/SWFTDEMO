//
//  ZFCMSSliderSKUBannerCell.h
//  ZZZZZ
//
//  Created by YW on 2018/12/10.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//
// 滑动 SKU Banner

#import <UIKit/UIKit.h>
#import "ZFCMSRecentlyAnalyticsAOP.h"

@class ZFCMSSectionModel, ZFCMSItemModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFCMSSliderSKUBannerSectionView : UICollectionViewCell

+ (ZFCMSSliderSKUBannerSectionView *)reusableSkuBanner:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) ZFCMSRecentlyAnalyticsAOP    *sliderSKUanalyticsAOP;
// 滑动商品banner 与 滑动商品历史浏览记录 共用一个Cell
@property (nonatomic, strong) ZFCMSSectionModel *sectionModel;

@property (nonatomic, copy) void(^clickSliderSkuBlock)(ZFCMSItemModel *itemModel);

@property (nonatomic, copy) void(^clickClearHistSkuBlock)(void);

///用于Appsflyer统计的频道id，由初始化的时候传入
@property (nonatomic, copy) NSString *channel_id;
@property (nonatomic, copy) NSString *channel_name;

@end

NS_ASSUME_NONNULL_END
