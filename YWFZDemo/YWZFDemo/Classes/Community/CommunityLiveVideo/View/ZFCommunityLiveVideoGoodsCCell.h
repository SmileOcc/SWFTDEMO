//
//  ZFCommunityLiveVideoGoodsCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveVideoGoodsCCell : UICollectionViewCell

@property (nonatomic, copy) void (^cartBlock)(ZFGoodsModel *goodsModel);

@property (nonatomic, copy) void (^findSimilarBlock)(ZFGoodsModel *goodsModel);


@property (nonatomic, strong) ZFGoodsModel *goodsModel;

- (void)hideBottomLine:(BOOL)hide;

- (void)showLiveRecommendActivity:(BOOL)showMark;

@end

NS_ASSUME_NONNULL_END
