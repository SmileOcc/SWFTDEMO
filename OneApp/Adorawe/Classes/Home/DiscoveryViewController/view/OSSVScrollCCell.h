//
//  OSSVScrollCCell.h
// OSSVScrollCCell
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"
#import "OSSVSecondsKillsModel.h"
#import "OSSVPductGoodsCCell.h"
#import "OSSVHomeCThemeModel.h"
#import "OSSVScrollCCellModel.h"

@class OSSVScrollCCell;
@protocol STLScrollerCollectionViewCellDelegate <CollectionCellDelegate>

-(void)STL_ScrollerCollectionViewCell:(OSSVScrollCCell *)scorllerCell didClickProduct:(OSSVHomeGoodsListModel *)model advEventModel:(OSSVAdvsEventsModel *)OSSVAdvsEventsModel;

-(void)STL_ScrollerCollectionViewCell:(OSSVScrollCCell *)scorllerCell didClickMore:(OSSVAdvsEventsModel *)model;

/// 新
-(void)stl_scrollerCollectionViewCell:(OSSVScrollCCell *)scorllerCell itemCell:(UICollectionViewCell *)cell;


@end

@interface OSSVScrollCCell : UICollectionViewCell
<
    OSSVCollectCCellProtocol
>

@property (nonatomic, weak) id<STLScrollerCollectionViewCellDelegate>   delegate;
@property (nonatomic, strong) OSSVSecondsKillsModel                        *datasourceModel;

- (BOOL)isMoreEvent:(UICollectionViewCell *)cell;
-(BOOL)isMoreButton;


+ (CGSize)itemSize:(CGFloat)imageScale;

+ (CGSize)subItemSize:(CGFloat)imageScale;
@end
