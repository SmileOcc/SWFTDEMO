//
//  ZFReviewDetailHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2017/11/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsDetailsReviewsModel.h"

@interface ZFReviewDetailHeaderView : UITableViewHeaderFooterView

@property (nonatomic, copy) NSString        *points;
@property (nonatomic, assign) NSInteger     reviewsCount;
@property (nonatomic, strong) ReviewsSizeOverModel *rankingModel;

@end
