//
//  OSSVCategorysSpecialssCCell.h
// XStarlinkProject
//
//  Created by odd on 2020/9/15.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVThemeZeroPrGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVCategorysSpecialssCCell : UICollectionViewCell

+ (OSSVCategorysSpecialssCCell *)categorySpecialCCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) OSSVThemeZeroPrGoodsModel  *model;

+ (CGFloat)categorySpecialCCellRowHeightOneModel:(OSSVThemeZeroPrGoodsModel *)model twoModel:(OSSVThemeZeroPrGoodsModel *)twoModel;

@end

NS_ASSUME_NONNULL_END
