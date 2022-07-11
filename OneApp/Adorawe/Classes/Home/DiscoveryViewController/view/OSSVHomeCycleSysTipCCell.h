//
//  OSSVHomeCycleSysTipCCell.h
// OSSVHomeCycleSysTipCCell
//
//  Created by odd on 2020/10/16.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"
#import "OSSVCycleSysCCellModel.h"
//#import "SDCycleScrollView.h"
#import "OSSVCycleMSGView.h"
NS_ASSUME_NONNULL_BEGIN

@class OSSVHomeCycleSysTipCCell;

@protocol STLCycleSystemTipCCellDelegate <CollectionCellDelegate>

@optional
- (void)STL_HomeBannerCCell:(OSSVHomeCycleSysTipCCell *)cell advEventModel:(OSSVAdvsEventsModel *)model index:(NSInteger )index;

- (void)STL_HomeBannerCCell:(OSSVHomeCycleSysTipCCell *)cell advEventModel:(OSSVAdvsEventsModel *)model showCellIndex:(NSInteger )index;
@end
///功能注释：首页顶部 跑马灯
@interface OSSVHomeCycleSysTipCCell : UICollectionViewCell
<
    OSSVCollectCCellProtocol
>
@property (nonatomic, weak) id<STLCycleSystemTipCCellDelegate>delegate;
//@property (nonatomic, strong) SDCycleScrollView    *cycleView;
@property (nonatomic, strong) OSSVCycleMSGView      *testCycle;
@end

NS_ASSUME_NONNULL_END
