//
//  OSSVScrollAdvBannerCCell.h
// OSSVScrollAdvBannerCCell
//
//  Created by odd on 2020/10/22.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"
#import "OSSVScrollAdverCCell.h"

NS_ASSUME_NONNULL_BEGIN
@class OSSVScrollAdvBannerCCell;
@protocol STLScrollerBannerCCellDelegate <CollectionCellDelegate>

@optional
- (void)STL_HomeBannerCCell:(OSSVScrollAdvBannerCCell *)cell advEventModel:(OSSVAdvsEventsModel *)model index:(NSInteger )index;

- (void)STL_HomeBannerCCell:(OSSVScrollAdvBannerCCell *)cell advEventModel:(OSSVAdvsEventsModel *)model showCellIndex:(NSInteger )index;
@end
///功能注释：滑动广告
@interface OSSVScrollAdvBannerCCell : UICollectionViewCell <OSSVCollectCCellProtocol>
@property (nonatomic, weak) id<STLScrollerBannerCCellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
