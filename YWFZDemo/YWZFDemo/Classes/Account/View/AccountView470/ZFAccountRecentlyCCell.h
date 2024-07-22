//
//  ZFAccountRecentlyCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/6/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCollectionCellProtocol.h"

@class ZFCMSItemModel;
@protocol ZFAccountRecentlyCellDelegate <ZFCollectionCellDelegate>

- (void)ZFAccountRecentlyCellDidClickProductItem:(ZFCMSItemModel *)itemModel;

- (void)ZFAccountRecentlyCellDidClickClearButton;

@end

@interface ZFAccountRecentlyCCell : UICollectionViewCell
<
    ZFCollectionCellProtocol
>

@property (nonatomic, weak) id<ZFAccountRecentlyCellDelegate>delegate;

@end

