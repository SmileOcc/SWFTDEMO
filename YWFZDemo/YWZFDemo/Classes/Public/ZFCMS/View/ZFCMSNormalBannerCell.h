//
//  ZFCMSNormalBannerCell.h
//  ZZZZZ
//
//  Created by YW on 2018/12/10.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFCMSItemModel, ZFCMSAttributesModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFCMSNormalBannerCell : UICollectionViewCell

+ (ZFCMSNormalBannerCell *)reusableNormalBannerCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) ZFCMSItemModel *itemModel;

@property (nonatomic, strong) UIColor *cellBackgroundColor;

// 用到倒计时才需要赋值该模型
- (void)updateCmsAttributes:(ZFCMSAttributesModel *)cmsAttributes cellHeight:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
