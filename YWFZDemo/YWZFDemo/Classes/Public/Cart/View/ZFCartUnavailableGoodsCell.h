//
//  ZFCartUnavailableGoodsCell.h
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZFCartGoodsModel;
typedef void(^CartUnavailableGoodsDeleteBlock)(ZFCartGoodsModel *model);

@interface ZFCartUnavailableGoodsCell : UITableViewCell

@property (nonatomic, copy) void(^tapSimilarGoodsHandle)(void);
@property (nonatomic, strong) ZFCartGoodsModel                *model;
@property (nonatomic, copy) CartUnavailableGoodsDeleteBlock   deleteGoodsBlock;
@end


NS_ASSUME_NONNULL_END
