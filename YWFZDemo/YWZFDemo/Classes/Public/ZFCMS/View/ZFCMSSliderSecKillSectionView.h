//
//  ZFCMSSliderSecKillSectionView.h
//  ZZZZZ
//
//  Created by YW on 2019/3/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCMSRecentlyAnalyticsAOP.h"

@class ZFCMSSectionModel, ZFCMSItemModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFCMSSliderSecKillSectionView : UICollectionViewCell

+ (ZFCMSSliderSecKillSectionView *)reusableSecKillView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) ZFCMSRecentlyAnalyticsAOP    *sliderSKUanalyticsAOP;
@property (nonatomic, strong) ZFCMSSectionModel             *sectionModel;

@property (nonatomic, copy) void(^sliderSkuClick)(ZFCMSItemModel *itemModel);

///用于Appsflyer统计的频道id，由初始化的时候传入
@property (nonatomic, copy) NSString *channel_id;
@property (nonatomic, copy) NSString *channel_name;
@end

NS_ASSUME_NONNULL_END
