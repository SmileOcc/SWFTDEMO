//
//  OSSVDetailsHeaderInforView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STLCLineLabel.h"
#import "OSSVDetailsBaseInfoModel.h"
#import "OSSVReviewsModel.h"
#import "OSSVReviewsModel.h"
#import "ZZStarView.h"
#import "OSSVReviewsModel.h"
#import "OSSVDetailHeaderCoinView.h"
#import "YYLabel.h"
#import "YYText.h"

@class OSSVDetailsHeaderInforView;
@protocol OSSVDetailsHeaderInforViewDelegate<NSObject>

@optional
- (void)detailsHeaderInforView:(OSSVDetailsHeaderInforView *)goodsInforView collect:(BOOL)flag;
- (void)detailsHeaderInforView:(OSSVDetailsHeaderInforView *)goodsInforView review:(BOOL)flag;
- (void)detailsHeaderInforView:(OSSVDetailsHeaderInforView *)goodsInforView showMoreTitle:(BOOL)flag;
- (void)detailsHeaderInforView:(OSSVDetailsHeaderInforView *)goodsInforView cointTip:(BOOL)flag;

@end


@interface OSSVDetailsHeaderInforView : UIView


@property (nonatomic, weak) id<OSSVDetailsHeaderInforViewDelegate>  delegate;

@property (nonatomic, strong) UIView                        *ratingtView;
@property (nonatomic, strong) ZZStarView                    *startRatingView;  //评论数量
@property (nonatomic, strong) UILabel                       *ratingLabel;
@property (nonatomic, strong) UIImageView                   *arrowImageView;
@property (nonatomic, strong) UIButton                      *ratingButton;
@property (nonatomic, strong) UILabel                       *reviewCountLabel;
@property (nonatomic, strong) UIView                        *reviewBottomLineView;



/** 价格*/
@property (nonatomic, strong) UILabel                       *shopPrice;
/** 原价*/
@property (nonatomic, strong) STLCLineLabel                 *marketPrice;

@property (nonatomic, strong) YYLabel                       *titleLabel; // 商品名

@property (nonatomic, strong) UIButton                      *moreButton;

@property (nonatomic, strong) OSSVDetailHeaderCoinView     *coinView; // 金币视图

@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView *flastScitviytStateView;

@property (nonatomic, strong) UIView                        *lineView;

- (void)updateHeaderGoodsInfor:(OSSVDetailsBaseInfoModel *)goodsInforModel reviewInfo:(OSSVReviewsModel *)reviewModel;

+ (CGFloat)heightGoodsInforView:(OSSVDetailsBaseInfoModel *)goodsInforModel reviewInfo:(OSSVReviewsModel *)reviewModel;

-(void)updateReviewInfo:(OSSVReviewsModel *)reviewInfo;

@end
