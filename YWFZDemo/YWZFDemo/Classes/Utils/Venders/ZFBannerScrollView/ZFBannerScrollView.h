//
//  ZFBannerScrollView.h
//  ZFBannerView
//
//  Created by YW on 22/11/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZFBannerScrollView;

typedef NS_OPTIONS(NSUInteger, ZFBannerType) {
    ZFBannerTypeNormal = 1 << 1, //正常滑动 default
    ZFBannerTypeParallax = 1 << 0, //视差 （凤凰）
    ZFBannerTypeUNParallax = 1 << 2 //无视差
};

@protocol ZFBannerScrollViewDelegate <NSObject>
/**
 点击Banner回调
 */
- (void)ZFBannerScrollView:(ZFBannerScrollView *)view didSelectItemAtIndex:(NSInteger)index;
@end

@interface ZFBannerScrollView : UIView

@property (nonatomic, assign) id<ZFBannerScrollViewDelegate> delegate;
/**
 网络图片 url string 数组
 */
@property (nonatomic, strong) NSArray *imageURLStringsGroup;
/**
 默认自动无限轮播 YES
 */
@property (nonatomic, assign) BOOL autoScroll;
/**
 图片占位图
 */
@property (nonatomic,strong) UIImage *placeHoldImage;
/**
 默认轮播间隔 3s
 */
@property (nonatomic,assign) NSTimeInterval  timerInterval;
/**
 默认图片轮播切换类型 ZFBannerType_normal
 */
@property (nonatomic, assign) ZFBannerType       bannerType;
/**
 当前分页控件小圆标颜色  默认白色
 */
@property (nonatomic, strong) UIColor *currentPageDotColor;
/**
 其他分页控件小圆标颜色  默认白色
 */
@property (nonatomic, strong) UIColor *pageDotColor;

/// 滚动到指定页
- (void)scrollToIndexBanner:(NSInteger)currentPage;

@end
NS_ASSUME_NONNULL_END
