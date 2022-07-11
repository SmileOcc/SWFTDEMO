//
//  OSSVDetailsCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVGoodsListModel.h"

@protocol GoodsDetailsCellDelegate <NSObject>

@optional
- (void)userCollectAction:(OSSVGoodsListModel *)model buttonSelected:(UIButton *)sender;

@end

@interface OSSVDetailsCell : UICollectionViewCell

+(OSSVDetailsCell *)goodsDetailsCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath;
+ (CGFloat)recommendItemRowHeightForGoodsDetailsRecommendArrayModel:(OSSVGoodsListModel *)model; // 返回Cell高度
@property (nonatomic, strong) OSSVGoodsListModel *model;

@property (nonatomic, weak) id <GoodsDetailsCellDelegate> delegate;

@end
