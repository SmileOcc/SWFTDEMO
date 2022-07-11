//
//  STLSecondKillBannerView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  首页秒杀视图 / 滚动视图

#import <UIKit/UIKit.h>
#import "OSSVPductGoodsCCell.h"
#import "ZJJTimeCountDown.h"
#import "OSSVSecondsKillsModel.h"

#define HeaderPadding 0

#define HeaderHeight 65*DSCREEN_WIDTH_SCALE
#define CountDownHeight 55
#define ProductCollectionHeight (ProductImageHeight + LabelTopBottomPadding + PriceLabelHeight + LabelPadding + MarketPriceLabelHeight + LabelTopBottomPadding + 5)

///(105/750是设计给的比例)
#define ScrollHeaderHeight  SCREEN_WIDTH*(105.0/750.0)

///两者的区别是，秒杀视图中间要多一个秒杀倒计时
typedef NS_ENUM(NSInteger) {
    SecondKill_Type,                ///秒杀视图
    Scroll_Type                     ///滚动视图
}SecondKillViewType;

@protocol STLDiscoverySecondKillBannerViewDelegate <NSObject>

///<点击头部视图
-(void)STLDiscoverySecondKillDidClickHeader:(OSSVAdvsEventsModel *)model;

///<点击子视图
-(void)STLDiscoverySecondKillDidChildView:(OSSVHomeGoodsListModel *)model jumpMode:(OSSVAdvsEventsModel *)OSSVAdvsEventsModel type:(SecondKillViewType)type;

///<点击viewMore
-(void)STLDiscoverySecondKillDidClickViewMore:(OSSVAdvsEventsModel *)model;

@end

@interface OSSVDiscoveySecondsKillAdvsView : UIView

@property (nonatomic, weak) id<STLDiscoverySecondKillBannerViewDelegate>delegate;

@property (nonatomic, strong) OSSVSecondsKillsModel *model;

-(instancetype)initWithType:(SecondKillViewType)type;

-(CGFloat)viewHeight;

-(void)reloadSecond:(ZJJTimeCountDown *)countDown;

@end
