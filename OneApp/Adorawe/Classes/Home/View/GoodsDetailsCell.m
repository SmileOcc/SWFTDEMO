//
//  GoodsDetailsCell.m
//  Yoshop
//
//  Created by huangxieyue on 16/5/30.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "GoodsDetailsCell.h"

@implementation GoodsDetailsCell
+(GoodsDetailsCell*)goodsDetailsCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath {
    //注册cell
    [collectionView registerClass:[GoodsDetailsCell class] forCellWithReuseIdentifier:GOODS_DETAILS_INENTIFIER];
    return [collectionView dequeueReusableCellWithReuseIdentifier:GOODS_DETAILS_INENTIFIER forIndexPath:indexPath];
}

//+ (CGFloat)homeItemRowHeightForHomeGoodListModel:(HomeGoodListModel *)model {
//    return (SCREEN_WIDTH/2 - 5) / model.goodsImageWidth * model.goodsImageHeight + 30;
//}
@end
