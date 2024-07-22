//
//  ZFOrderDetailOrderGoodsTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDetailGoodModel.h"
@class ZFWaitCommentModel, OrderDetailOrderModel;

@interface ZFOrderDetailOrderGoodsTableViewCell : UITableViewCell
@property (nonatomic, strong) OrderDetailGoodModel  *model;
@property (nonatomic, strong) OrderDetailOrderModel *orderDetailModel;
@property (nonatomic, strong) UIImageView           *goodsImageView;
@property (nonatomic, copy) void (^touchReviewBlock) (ZFWaitCommentModel *model);

- (void)showReviewButtonState:(NSInteger)orderStatus
                        isCod:(BOOL)isCod
                     isReview:(NSUInteger)isReview;

- (void)configCellDataWithGoodsModel:(OrderDetailGoodModel *)goodsModel orderDetailModel:(OrderDetailOrderModel *)orderDetailModel;

@end
