//
//  HomeItemCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OSSVHomeGoodsListModel;
@class CommendModel;

@interface OSSVHomeItemssCell : UICollectionViewCell

typedef void(^cateListCollectBlock)(OSSVHomeGoodsListModel *goodListModel);

@property (nonatomic, strong) YYAnimatedImageView         *contentImageView; // 内容图片

@property (nonatomic, strong) OSSVHomeGoodsListModel *model;

@property (nonatomic, strong) CommendModel *commendModel;

@property (nonatomic, copy) cateListCollectBlock collectBlock;

+ (OSSVHomeItemssCell *)homeItemCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath;

+ (CGFloat)homeItemRowHeightForHomeGoodListModel:(OSSVHomeGoodsListModel *)model;
+ (CGFloat)homeItemRowHeightOneModel:(OSSVHomeGoodsListModel *)model twoModel:(OSSVHomeGoodsListModel *)twoModel;

@property (nonatomic, strong) UIButton                    *collecBtn; // 收藏按钮

@end
