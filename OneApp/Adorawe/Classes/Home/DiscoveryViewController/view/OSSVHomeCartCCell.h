//
//  STLCartCCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"
#import "OSSVSecondsKillsModel.h"
#import "OSSVPductGoodsCCell.h"
#import "OSSVHomeCThemeModel.h"


@class OSSVHomeCartCCell;
@protocol STLCartCollectionViewCellDelegate <CollectionCellDelegate>

-(void)STL_CartCollectionViewCell:(OSSVHomeCartCCell *)scorllerCell didClickProduct:(OSSVCartGoodsModel *)model advEventModel:(OSSVAdvsEventsModel *)OSSVAdvsEventsModel;

-(void)STL_CartCollectionViewCell:(OSSVHomeCartCCell *)scorllerCell didClickMore:(OSSVAdvsEventsModel *)model;

@end

@interface OSSVHomeCartCCell : UICollectionViewCell
<
    OSSVCollectCCellProtocol
>

@property (nonatomic, weak) id<STLCartCollectionViewCellDelegate>delegate;

@end
