//
//  ZFGoodsDetailReviewInfoTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2017/11/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsDetailFirstReviewModel.h"

typedef void(^GoodsDetailReviewImageCheckCompletionHandler)(NSInteger index, NSArray *imageViewArr);

@interface ZFGoodsDetailReviewInfoTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL                              isTimeStamp;
@property (nonatomic, strong) GoodsDetailFirstReviewModel       *model;

@property (nonatomic, copy) GoodsDetailReviewImageCheckCompletionHandler            goodsDetailReviewImageCheckCompletionHandler;

@property (nonatomic, copy) void (^reviewTranslateBlcok)(GoodsDetailFirstReviewModel *reviewModel);

///是否显示Size视图，商品详情页的评论是不需要显示的，在setModel前赋值
@property (nonatomic, assign) BOOL isShowSizeView;

/// 是否能点击图片看大图
@property (nonatomic, assign) BOOL canShowBigImage;

@end
