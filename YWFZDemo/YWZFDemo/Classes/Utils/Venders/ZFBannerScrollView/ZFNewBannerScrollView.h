//
//  ZFBannerScrollView_B.h
//  ZZZZZ
//
//  Created by YW on 2019/5/28.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDetailBannerHeight       (420)
#define kBannerLineMagin          4.0
#define kBannerViewWidth          (316.0 + kBannerLineMagin)
#define kBannerViewHeight         (420.0)

@class ZFNewBannerScrollView;

NS_ASSUME_NONNULL_BEGIN

@protocol ZFBannerScrollViewDelegate <NSObject>

/**
 点击Banner回调
 */
- (void)bannerScrollView:(ZFNewBannerScrollView *)view showImageViewArray:(NSArray *)showImageViewArray didSelectItemAtIndex:(NSInteger)index;

- (void)didShowScrollViewPageAtIndex:(NSInteger)index;

@end


@interface ZFNewBannerScrollView : UIView

@property (nonatomic, assign) id<ZFBannerScrollViewDelegate> delegate;

/**
 网络图片 url string 数组
 */
@property (nonatomic, strong) NSArray <NSString *> *imageUrlArray;

/**
 图片占位图
 */
@property (nonatomic,strong) UIImage *placeHoldImage;

/**
 当前分页控件小圆标颜色  默认白色
 */
@property (nonatomic, strong) UIColor *currentPageDotColor;

/**
 其他分页控件小圆标颜色  默认白色
 */
@property (nonatomic, strong) UIColor *pageDotColor;

/**
 是否隐藏分页标识
 */
@property (nonatomic, assign) BOOL showPageControl;

/**
 滚动到指定页
 */
- (void)scrollToIndexBanner:(NSInteger)currentPage animated:(BOOL)animated;

/**
 刷新图片时是否滚动到第一页
 */
- (void)refreshImageUrl:(NSArray *)imageUrlArray scrollToFirstIndex:(BOOL)scrollToFirstIndex;

@end

NS_ASSUME_NONNULL_END
