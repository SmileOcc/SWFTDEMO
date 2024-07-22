//
//  ZFGoodsDetailReviewsHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2017/11/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsDetailModel.h"

@class ReviewsSizeOverModel;

@interface ZFGoodsDetailReviewsHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) GoodsDetailModel          *model;

@property (nonatomic, strong) ReviewsSizeOverModel      *reviewsRankingModel;

@end
