//
//  ZFGoodsListColorBlockView.h
//  ZZZZZ
//
//  Created by YW on 2019/5/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFGoodsModel;
typedef void(^ColorBlockClickBlock)(NSInteger index);

@interface ZFGoodsListColorBlockView : UIView

@property (nonatomic, copy) ColorBlockClickBlock colorBlockClick;

@property (nonatomic, strong) ZFGoodsModel *goodsModel;

@property (nonatomic, strong) UICollectionView *colorBlockCollectionView;

@end

