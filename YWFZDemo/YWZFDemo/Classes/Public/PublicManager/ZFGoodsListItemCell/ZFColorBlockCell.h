//
//  ZFColorBlockCell.h
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFGoodsModel;

@interface ZFColorBlockCell : UICollectionViewCell

@property (nonatomic, strong) ZFGoodsModel *model;

- (void)setModel:(ZFGoodsModel *)model indexPath:(NSIndexPath *)indexPath seletedIndex:(NSInteger)seletedIndex;

@end

