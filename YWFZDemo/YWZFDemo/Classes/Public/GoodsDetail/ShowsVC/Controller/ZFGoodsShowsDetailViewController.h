//
//  ZFGoodsShowsDetailViewController.h
//  ZZZZZ
//
//  Created by YW on 2019/3/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "GoodsDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFGoodsShowsDetailViewController : ZFBaseViewController

@property (nonatomic, strong) UIImage *placeholderImage;

/// 满赠 赠品ID , 如果传入了赠品ID，作为参数传给后台获取赠品赠品信息
@property (nonatomic, copy) NSString *freeGiftId;

@property (nonatomic, strong) GoodsDetailModel *detailModel;

@end

NS_ASSUME_NONNULL_END
