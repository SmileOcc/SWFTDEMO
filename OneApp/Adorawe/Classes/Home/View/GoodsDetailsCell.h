//
//  GoodsDetailsCell.h
//  Yoshop
//
//  Created by huangxieyue on 16/5/30.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsDetailsRecommendArrayModel.h"

@interface GoodsDetailsCell : UICollectionViewCell
+(GoodsDetailsCell*)goodsDetailsCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath;
+ (CGFloat)recommendItemRowHeightForGoodsDetailsRecommendArrayModel:(GoodsDetailsRecommendArrayModel *)model;
@end
