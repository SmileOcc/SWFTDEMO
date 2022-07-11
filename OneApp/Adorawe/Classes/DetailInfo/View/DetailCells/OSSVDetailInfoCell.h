//
//  OSSVDetailInfoCell.h
// XStarlinkProject
//
//  Created by odd on 2021/6/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailBaseCell.h"
#import "OSSVDetailsHeaderInforView.h"
#import "OSSVDetaailheaderColorSizeView.h"
#import "OSSVDetailsListModel.h"

@class ColorSizePickView;

NS_ASSUME_NONNULL_BEGIN

@interface OSSVDetailInfoCell : OSSVDetailBaseCell

/** 商品信息*/
@property (nonatomic, weak) OSSVDetailsBaseInfoModel       *model;

@property (nonatomic, strong) UIView                              *activityView;
@property (nonatomic, strong) UIView                              *flashActivityView;
@property (nonatomic, strong) UIView                              *normalActivityView;
@property (nonatomic, strong) UIView                              *newPersonView;// 新人礼banner
//活动水印、闪购背景
@property (nonatomic, strong) YYAnimatedImageView                 *activityBgImgView;
//活动价格
@property (nonatomic, strong) UILabel                             *activityWaterMarkPriceL;

@property (nonatomic, strong) STLCLineLabel                       *flashMarketPriceLabel;
@property (nonatomic, strong) UILabel                             *flashShopPriceLabel;
@property (nonatomic, strong) UILabel                             *flashStateLabel;
@property (nonatomic, strong) UILabel                             *flashBuyTipLabel;
@property (nonatomic, strong) UILabel                             *timeLabel;   //时间显示
@property (nonatomic, strong) UILabel                             *millisecond; //毫秒
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView *flastScitviytStateView;
@property (nonatomic, strong) UIImageView                         *flashImageArrow;
@property(nonatomic, assign) double                               timeInterval;//未来某个日期的时间戳
@property(nonatomic, strong) NSTimer                              *timer ; //定时器
@property (nonatomic, copy)   NSString                            *labelStr;

//闪购商品所属频道的ID
@property (nonatomic, copy) NSString                              *channelId;

@property (nonatomic, strong) OSSVDetaailheaderColorSizeView     *colorSizeView;

@property (nonatomic, strong) OSSVDetailsHeaderInforView    *goodsInforView;
@property (nonatomic, strong) OSSVReviewsModel            *headerReviewModel;
@property (nonatomic, assign) BOOL                                hasRecommend;
// 新人页

@property (nonatomic, strong) YYAnimatedImageView                 *personleftImage;
@property (nonatomic, strong) YYAnimatedImageView                 *personBackgroundImage;
@property (nonatomic, strong) UILabel                             *personLab;
@property (nonatomic, strong) YYAnimatedImageView                 *personRightImage;
@property (nonatomic, strong) UIButton                            *personTapBtn;

+ (CGFloat)fetchSizeCellHeight:(OSSVDetailsListModel *)detailModel reviewModel:(OSSVReviewsModel *)reviewModel;
- (void)updateDetailInfoModel:(OSSVDetailsListModel *)model recommend:(BOOL)hasRecommend;
@end

NS_ASSUME_NONNULL_END
