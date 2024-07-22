//
//  ZFGoodsDetailShowExploreCell.h
//  ZZZZZ
//
//  Created by YW on 2018/6/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsDetailShowExploreAOP.h"

@class GoodsShowExploreModel;

typedef void(^SelectedShowExploreBlock)(GoodsShowExploreModel *showExploreModel);

@interface ZFGoodsDetailShowExploreCell : UITableViewCell


@property (nonatomic, strong) ZFGoodsDetailShowExploreAOP       *analyticsAOP;

@property (nonatomic, strong) NSArray<GoodsShowExploreModel *> *showExploreModelArray;

@property (nonatomic, assign) BOOL   isShowLikeNumber;

@property (nonatomic, copy) SelectedShowExploreBlock selectedShowExploreBlock;

@end
