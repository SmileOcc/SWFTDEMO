//
//  OSSVHomeAdvBannerCCell.h
// OSSVHomeAdvBannerCCell
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"
#import "OSSVHomeCCellBanneModel.h"

//首页banner
@class OSSVHomeAdvBannerCCell;

@protocol STLHomeBannerCCellDelegate<CollectionCellDelegate>

- (void)STL_HomeBannerCCell:(OSSVHomeAdvBannerCCell *)cell advEventModel:(OSSVAdvsEventsModel *)model index:(NSInteger )index;

- (void)STL_HomeBannerCCell:(OSSVHomeAdvBannerCCell *)cell advEventModel:(OSSVAdvsEventsModel *)model showCellIndex:(NSInteger )index;

@end

@interface OSSVHomeAdvBannerCCell : UICollectionViewCell<OSSVCollectCCellProtocol>

@property (nonatomic, weak) id<STLHomeBannerCCellDelegate>delegate;

-(void)setEventArr:(NSArray<OSSVAdvsEventsModel *> *)items;

@end
