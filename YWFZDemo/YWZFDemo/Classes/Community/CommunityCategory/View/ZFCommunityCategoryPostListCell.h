//
//  ZFCategoryPostListCell.h
//  ZZZZZ
//
//  Created by YW on 2018/8/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityCategoryPostItemModel.h"
#import "GoodsDetailModel.h"

@interface ZFCommunityCategoryPostListCell : UICollectionViewCell

@property (nonatomic, strong) ZFCommunityCategoryPostItemModel *model;

@property (nonatomic, strong) GoodsShowExploreModel     *showsModel;

@end
