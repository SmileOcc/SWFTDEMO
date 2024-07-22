//
//  ZFCommunityLiveRecommendGoodsView.h
//  ZZZZZ
//
//  Created by YW on 2019/7/23.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveRecommendGoodsView : UIView

- (void)updateGoodsData:(NSArray *)goods;

@property (nonatomic, copy) void (^recommendGoodsBlock)(ZFGoodsModel *goodsModel);

@property (nonatomic, copy) void (^jumpCartBlock)(BOOL flag);

@property (nonatomic, copy) void (^closeBlock)(BOOL flag);

@property (nonatomic, copy) void (^addCartBlock)(ZFGoodsModel *goodsModel);

@property (nonatomic, copy) void (^similarGoodsBlock)(ZFGoodsModel *goodsModel);


@end

NS_ASSUME_NONNULL_END
