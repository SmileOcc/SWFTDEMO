//
//  OSSVOrdersReviewsScoreView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZStarView.h"

@class OrderReviewRatingItem;

@interface OSSVOrdersReviewsScoreView : UIView

@property (copy,nonatomic) NSString *orderId;

@property (nonatomic, strong) OrderReviewRatingItem    *transportView;
@property (nonatomic, strong) OrderReviewRatingItem    *goodsView;
@property (nonatomic, strong) OrderReviewRatingItem    *payView;
@property (nonatomic, strong) OrderReviewRatingItem    *serviceView;

@property (nonatomic, strong) UIButton                 *submitButton;

@property (nonatomic, copy) void (^reviewBlock)();

- (void)handleRating:(CGFloat)trans goods:(CGFloat)goods pay:(CGFloat)pay service:(CGFloat)service;

- (void)hideCommitButton;

@end



@interface OrderReviewRatingItem : UIView

@property (nonatomic, strong) UILabel             *titleLabel;
@property (nonatomic, strong) ZZStarView   *ratingControl;
@property (nonatomic, assign) CGFloat             rateCount;

///评分类型
@property (copy,nonatomic) NSString *type;
///商品名
@property (copy,nonatomic) NSString *prodName;

@end
