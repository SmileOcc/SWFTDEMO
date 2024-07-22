//
//  ZFCollocationBuySubViewController.h
//  ZZZZZ
//
//  Created by YW on 2019/8/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"

@class ZFCollocationGoodsModel;

@interface ZFCollocationBuySubViewController : ZFBaseViewController

@property (nonatomic, strong) NSString *channel_id; //价格区间列表id

@property (nonatomic, assign) CGFloat contentViewHeight;

@property (nonatomic, strong) NSArray<ZFCollocationGoodsModel *> *goodsModelArray;

@end

