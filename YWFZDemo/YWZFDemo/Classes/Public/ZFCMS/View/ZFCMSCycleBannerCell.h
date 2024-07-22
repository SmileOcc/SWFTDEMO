//
//  ZFCMSCycleBannerCell.h
//  ZZZZZ
//
//  Created by YW on 2018/12/10.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCMSCycleBannerAnalyticsAOP.h"

@class ZFCMSItemModel;
@class ZFCMSSectionModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFCMSCycleBannerCell : UICollectionViewCell

+ (ZFCMSCycleBannerCell *)cycleBannerCellWith:(UICollectionView *)collectionView
                                 forIndexPath:(NSIndexPath *)indexPath;

- (void)updateCycleBanner:(ZFCMSSectionModel *)adBannerArray
                indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) ZFCMSCycleBannerAnalyticsAOP   *analyticsAop;

@property (nonatomic, copy) void(^cycleBannerClick)(ZFCMSItemModel *cycleBannerModel);

///用于Appsflyer统计的频道id，由初始化的时候传入
@property (nonatomic, copy) NSString *channel_id;
@property (nonatomic, copy) NSString *channel_name;

@end

NS_ASSUME_NONNULL_END
