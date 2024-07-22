//
//  RecommendGoodsCell.h
//  ZZZZZ
//
//  Created by YW on 18/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"

@interface ZFHomeGoodsCell : UICollectionViewCell

+ (ZFHomeGoodsCell *)homeGoodsCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPathl;

@property (nonatomic, strong) UIImageView     *goodsImageView;
@property (nonatomic, strong) ZFGoodsModel    *goodsModel;
@property (nonatomic, strong) void(^collectClick)(BOOL isCollect);


@end
