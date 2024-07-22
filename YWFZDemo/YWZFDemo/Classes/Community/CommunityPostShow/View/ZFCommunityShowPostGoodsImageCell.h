//
//  ZFCommunityShowPostGoodsImageCell.h
//  ZZZZZ
//
//  Created by YW on 16/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityPostShowSelectGoodsModel.h"

typedef void(^DeleteGoodsBlock)(ZFCommunityPostShowSelectGoodsModel *model);

@interface ZFCommunityShowPostGoodsImageCell : UICollectionViewCell

@property (nonatomic, copy) DeleteGoodsBlock deleteGoodBlock;

@property (nonatomic, strong) ZFCommunityPostShowSelectGoodsModel *model;

@property (nonatomic,assign) BOOL isNeedHiddenAddView;

+ (ZFCommunityShowPostGoodsImageCell *)goodsImageCellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

- (void)setAddImage:(UIImage *)image;
@end
