//
//  DiscoveryHeaderView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

// iPhone 6 6p 84.0f* DSCREEN_WIDTH_SCALE

#define kDiscoverTopicHegiht                   ((SCREEN_WIDTH == 320.0) ? 92.0f : 84.0f)
#define kDiscoverHeaderTopViewHeight           160.0f* DSCREEN_WIDTH_SCALE    // 顶部 View 的高度 (Banner)
#define kDiscoverHeaderMiddleViewHeight        (kDiscoverTopicHegiht * DSCREEN_WIDTH_SCALE)  // 中部 View 的高度 (Topic)
#define kDiscoverHeaderBottomViewHeight        180.0f* DSCREEN_WIDTH_SCALE // 底部 View 的高度 (Three)
#define kDiscoverHeaderBottomToOtherSpace      7.0f                       // 底部View (Three)边距

@class OSSVHomeDiscoverHeaderModel;

@interface OSSVHomeDiscoveyHeadView : UIView

@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, strong) OSSVHomeDiscoverHeaderModel *model;

@end




