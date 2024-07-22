//
//  ZFCMSSliderBannerCell.h
//  ZZZZZ
//
//  Created by YW on 2018/12/10.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//
// 滑动普通banner

#import <UIKit/UIKit.h>
#import "ZFCMSSKUBannerAnalyticsAOP.h"

@class ZFCMSSectionModel, ZFCMSItemModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFCMSSliderNormalBannerSectionView : UICollectionViewCell

@property (nonatomic, strong) ZFCMSSKUBannerAnalyticsAOP   *analyticsAOP;
@property (nonatomic, strong) ZFCMSSectionModel             *sectionModel;

@property (nonatomic, copy) void(^normalBannerClick)(ZFCMSItemModel *sliderBannerModel);

+ (ZFCMSSliderNormalBannerSectionView *)reusableNormalBanner:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

///频道id
@property (nonatomic, copy) NSString *channel_id;
@property (nonatomic, copy) NSString *channel_name;

@end

NS_ASSUME_NONNULL_END
