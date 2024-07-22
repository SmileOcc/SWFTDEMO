//
//  ZFGoodsDetailGoodsReviewCell.h
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailBaseCell.h"

@class GoodsDetailFirstReviewModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFGoodsDetailGoodsReviewCell : ZFGoodsDetailBaseCell

+ (CGFloat)fetchReviewCellHeight:(GoodsDetailFirstReviewModel *)reviewModel;

@end

NS_ASSUME_NONNULL_END
