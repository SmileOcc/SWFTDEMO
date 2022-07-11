//
//  DiscoveryHeaderReusableView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVDiscoveySecondsKillAdvsView.h"
#import "OSSVDiscoveyEightsModuleView.h"

// 中部 View 的高度 (Topic)
#define kDiscoveryTopicTempHegiht        ((SCREEN_WIDTH == 320.0) ? 92.0f : 84.0f) // 为了适配不同屏幕，对此处高度做特殊处理
#define kDiscoveryTopicRealyHeight       (kDiscoveryTopicTempHegiht * DSCREEN_WIDTH_SCALE)
#define kDiscoveryViewToOtherSpace       10.0f // Header SubView 的下边距

#define kDiscoveryBannerViewHeight       (160.0f* DSCREEN_WIDTH_SCALE) // Banner View  高度
#define kDiscoveryOneBannerViewHeight    (45.0f * DSCREEN_WIDTH_SCALE  + kDiscoveryViewToOtherSpace)  // One Banner 高度
#define kDiscoveryThreeViewHeight        (180.0f* DSCREEN_WIDTH_SCALE  + kDiscoveryViewToOtherSpace)  // Three View 高度
#define kDiscoveryOneModuleHeight        (167.0f* DSCREEN_WIDTH_SCALE  + kDiscoveryViewToOtherSpace)  // OneModule 高度
#define kDiscoveryTwoModuleHeight        (211.0f* DSCREEN_WIDTH_SCALE  + kDiscoveryViewToOtherSpace)  // TwoModule 高度
#define kDiscoveryThreeModuleHeight      (173.0f* DSCREEN_WIDTH_SCALE  + kDiscoveryViewToOtherSpace)  // ThreeModule 高度
#define kDiscoveryFourModuleHeight       (220.0f* DSCREEN_WIDTH_SCALE  + kDiscoveryViewToOtherSpace)  // FourModule 高度
#define kDiscoveryFiveModuleHeight       (220.0f* DSCREEN_WIDTH_SCALE  + kDiscoveryViewToOtherSpace)  // FiveModule 高度
#define kDiscoveryJustForYouHeight       43.0f  // just for you 高度

// 秒杀高度
#define kDiscoverySecondKillHeight       (190)

typedef NS_ENUM(NSInteger, DiscoveryHeaderModuleType){
    DiscoveryOneModuleType = 2, // 至少为2，有一个More 的分馆
    DiscoveryTwoModuleType = 3,
    DiscoveryThreeModuleType = 4,
    DiscoveryFourModuleType = 5,
    DiscoveryFiveModuleType = 6,
    DiscoveryEightModuleType = 9,
    DiscoverySixteenModuleType = 18
};

@class OSSVHomeDiscoveryModel;

typedef void (^UpdateRealyHeight)(CGFloat height);

@interface OSSVDiscovryHeadrReusablView : UICollectionReusableView

@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, strong) OSSVHomeDiscoveryModel *model;
@property (nonatomic, copy) UpdateRealyHeight updateRealyHeight;
@property (nonatomic, weak) ZJJTimeCountDown *countDown;

+ (OSSVDiscovryHeadrReusablView*)goodsDetailsHeaderWithCollectionView:(UICollectionView *)collectionView Kind:(NSString*)kind IndexPath:(NSIndexPath *)indexPath;

@end
