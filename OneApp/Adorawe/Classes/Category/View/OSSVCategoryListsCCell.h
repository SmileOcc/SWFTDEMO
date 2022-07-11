//
//  OSSVCategoryListsCCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/15.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSSVCategoriyDetailsGoodListsModel;

typedef void(^cateListCollectBlock)(OSSVCategoriyDetailsGoodListsModel *goodListModel);

static NSString *identifier = @"OSSVCategoryListsCCell";

@interface OSSVCategoryListsCCell : UICollectionViewCell

@property (nonatomic, strong) OSSVCategoriyDetailsGoodListsModel *model;

@property (nonatomic, copy) cateListCollectBlock collectBlock;


+ (OSSVCategoryListsCCell *)categoriesCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath;

+ (CGFloat)categoryListCCellRowHeightForListModel:(OSSVCategoriyDetailsGoodListsModel *)model;

+ (CGFloat)categoryListCCellRowHeightOneModel:(OSSVCategoriyDetailsGoodListsModel *)model twoModel:(OSSVCategoriyDetailsGoodListsModel *)twoModel;
@end
