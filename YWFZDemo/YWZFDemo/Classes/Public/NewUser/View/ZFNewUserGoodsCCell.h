//
//  ZFNewUserGoodsCCell.h
//  ZZZZZ
//
//  Created by mac on 2019/1/9.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZFNewUserExclusiveGoodsListModel, ZFGoodsModel;

typedef void(^CancleCollectHandler)(ZFGoodsModel *model);

@interface ZFNewUserGoodsCCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView                           *goodsImageView;
@property (nonatomic, strong) ZFNewUserExclusiveGoodsListModel         *goodsModel;
// V4.4.0 是否是新ab测试界面
//@property (nonatomic, assign) BOOL  isNewABText;

@property (nonatomic, copy) CancleCollectHandler                    cancleCollectHandler;
@property (nonatomic, copy) void(^tapSimilarGoodsHandle)(void);

@end

NS_ASSUME_NONNULL_END
