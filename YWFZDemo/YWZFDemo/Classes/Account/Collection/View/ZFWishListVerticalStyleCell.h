//
//  ZFWishListVerticalStyleCell.h
//  ZZZZZ
//
//  Created by YW on 2019/7/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZFWishListVerticalStyleCellDelegate <NSObject>

- (void)ZFWishListVerticalStyleCellDidClickFindRelated:(ZFGoodsModel *)goodsModel;

- (void)ZFWishListVerticalStyleCellDidClickAddCartBag:(ZFGoodsModel *)goodsModel;

@end

@interface ZFWishListVerticalStyleCell : UITableViewCell

@property (nonatomic, weak) ZFGoodsModel *goodsModel;
@property (nonatomic, weak) id<ZFWishListVerticalStyleCellDelegate>delegate;

///商详穿搭关联商品公用此Cell时刷新部分UI
- (void)refreshUIStyleFromGoodsDetailOutfits;

@end

NS_ASSUME_NONNULL_END
