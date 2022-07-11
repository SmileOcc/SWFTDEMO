//
//  OSSVSevenAdvBannerCCell.h
// OSSVSevenAdvBannerCCell
//
//  Created by odd on 2020/10/22.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"
#import "OSSVDiscoverBlocksModel.h"

NS_ASSUME_NONNULL_BEGIN

@class OSSVSevenAdvBannerCCell;

@protocol STLSevenBannerCCellDelegate <CollectionCellDelegate>

@optional
- (void)STL_HomeBannerCCell:(OSSVSevenAdvBannerCCell *)cell advEventModel:(OSSVAdvsEventsModel *)model index:(NSInteger )index;
- (void)STL_HomeBannerCCell:(OSSVSevenAdvBannerCCell *)cell advEventModel:(OSSVAdvsEventsModel *)model showCellIndex:(NSInteger)index;
@end

///功能注释：背景广告图片+一组广告
@interface OSSVSevenAdvBannerCCell : UICollectionViewCell <OSSVCollectCCellProtocol>
@property (nonatomic, weak) id<STLSevenBannerCCellDelegate>delegate;

@property (nonatomic, strong) OSSVDiscoverBlocksModel *blockModel;

@end



NS_ASSUME_NONNULL_END
