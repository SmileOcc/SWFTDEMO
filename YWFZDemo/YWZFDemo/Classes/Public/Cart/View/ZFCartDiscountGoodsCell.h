//
//  ZFCartDiscountGoodsCell.h
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZFCartGoodsModel;

typedef void(^CartDiscountCellChangeNumberBlock)(ZFCartGoodsModel *model, BOOL shouldDelete);
typedef void(^CartDiscountCellSelectedSizeBlock)(ZFCartGoodsModel *model);

@interface ZFCartDiscountGoodsCell : UITableViewCell
@property (nonatomic, strong) ZFCartGoodsModel *model;
@property (nonatomic, copy) CartDiscountCellChangeNumberBlock changeNumberBlock;
@property (nonatomic, copy) CartDiscountCellSelectedSizeBlock selectedSizeBlock;
@property (nonatomic, assign) BOOL showEditFlag;
@end

NS_ASSUME_NONNULL_END
