//
//  OSSVDetailRecommendCell.h
// XStarlinkProject
//
//  Created by odd on 2021/4/13.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailBaseCell.h"
#import "OSSVGoodsListModel.h"
#import "OSSVRecommendArrayModel.h"
@class OSSVDetailRecommendCell;

@protocol OSSVDetailRecommendCellDelegate <NSObject>

@optional
- (void)goodsDetailRecommendCell:(OSSVDetailRecommendCell *)cell goodsModel:(OSSVGoodsListModel *)model buttonSelected:(UIButton *)sender;

@end



@interface OSSVDetailRecommendCell : OSSVDetailBaseCell

+(OSSVDetailRecommendCell *)goodsDetailsCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath;
+ (CGFloat)recommendItemRowHeightForGoodsDetailsOneModel:(OSSVGoodsListModel *)model twoModel:(OSSVGoodsListModel *)twoModel; // 返回Cell高度
@property (nonatomic, strong) OSSVGoodsListModel *model;

@property (nonatomic, strong) YYAnimatedImageView   *contentImageView; // 商品图片

@property (nonatomic, weak) id <OSSVDetailRecommendCellDelegate> delegate;

@end

