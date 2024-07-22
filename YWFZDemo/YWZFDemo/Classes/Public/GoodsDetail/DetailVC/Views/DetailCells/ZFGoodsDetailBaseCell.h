//
//  ZFGoodsDetailBaseCell.h
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailCellTypeModel.h"

@class ZFGoodsDetailCellTypeModel;

@interface ZFGoodsDetailBaseCell : UICollectionViewCell

/** Section所对应的Cell数据源 */
@property (nonatomic, strong) ZFGoodsDetailCellTypeModel *cellTypeModel;

/** Section所对应的NSindexPath */
@property (nonatomic, strong) NSIndexPath *indexPath;

@end
