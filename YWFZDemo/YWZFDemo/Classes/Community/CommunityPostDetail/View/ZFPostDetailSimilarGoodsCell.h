//
//  ZFPostDetailSimilarGoodsCell.h
//  ZZZZZ
//
//  Created by YW on 2018/7/11.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityGoodsInfosModel.h"

@interface ZFPostDetailSimilarGoodsCell : UICollectionViewCell

@property (nonatomic, copy) void (^addCartBlock)(ZFCommunityGoodsInfosModel *goodsModel);
@property (nonatomic, strong) ZFCommunityGoodsInfosModel  *model;

- (void)setGoodsImageURL:(NSString *)url;
- (void)setGoodsPrice:(NSString *)price;
- (void)setGoodsIsSimilar:(BOOL)isSimilar;
- (void)setShopCartShow:(BOOL)showCart;

@end

//更多cell
@interface ZFTopicDetailSimilarGoodsMoreCell : UICollectionViewCell

+ (ZFTopicDetailSimilarGoodsMoreCell *)viewAllCellWith:(UICollectionView *)collectionView
                                             indexPath:(NSIndexPath *)indexPath;

- (void)setMsgTip:(NSString *)msgTip;

@end

