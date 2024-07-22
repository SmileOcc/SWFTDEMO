//
//  ZFNewUserRushGoodsCCell.h
//  ZZZZZ
//
//  Created by mac on 2019/1/10.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFNewUserSecckillGoodsListModel;
@class ZFNewUserBoardGoodsGoodsList;

NS_ASSUME_NONNULL_BEGIN

@interface ZFNewUserRushGoodsCCell : UICollectionViewCell

/** 模型 */
@property (nonatomic, strong) ZFNewUserSecckillGoodsListModel *goodsModel;
/** 首页快抢 */
@property (nonatomic, strong) ZFNewUserBoardGoodsGoodsList    *boardGoodsList;
/** 活动是否开始 */
@property (nonatomic, assign) BOOL isNotStart;

@end

NS_ASSUME_NONNULL_END
