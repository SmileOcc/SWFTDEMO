//
//  ZFAccountCategoryCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/6/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  个人中心各分类模块cell

#import <UIKit/UIKit.h>
#import "ZFCollectionCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFAccountCategoryCCell : UICollectionViewCell
<
    ZFCollectionCellProtocol
>

@property (nonatomic, weak) id<ZFCollectionCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
