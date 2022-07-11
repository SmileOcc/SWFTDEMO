//
//  OSSVZeroCategorysSpecialsCCell.h
// XStarlinkProject
//
//  Created by odd on 2020/9/15.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVThemeZeroPrGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN


typedef void(^getFreeBlock)(OSSVThemeZeroPrGoodsModel *zeroModel);
@interface OSSVZeroCategorysSpecialsCCell : UICollectionViewCell

+ (OSSVZeroCategorysSpecialsCCell *)categorySpecialCCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) OSSVThemeZeroPrGoodsModel  *model;
@property (nonatomic, copy) getFreeBlock                getFreeblock;

@property (nonatomic, assign) NSInteger  cart_exits;

+ (CGFloat)categorySpecialCCellRowHeightForListModel:(OSSVThemeZeroPrGoodsModel *)model;

@end

NS_ASSUME_NONNULL_END
