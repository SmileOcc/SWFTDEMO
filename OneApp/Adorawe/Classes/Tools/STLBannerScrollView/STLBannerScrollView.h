//
//  STLBannerScrollView.h
// XStarlinkProject
//
//  Created by odd on 2021/6/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDetailBannerHeight       (420)
#define kBannerLineMagin          (APP_TYPE == 3 ? 0 : 8.0)
#define kBannerViewWidth          (316.0 + kBannerLineMagin)
#define kBannerViewHeight         (375.0)

@class STLBannerScrollView;

NS_ASSUME_NONNULL_BEGIN
@protocol STLBannerScrollViewDelegate <NSObject>

/**
 点击Banner回调
 */
- (void)bannerScrollView:(STLBannerScrollView *)view showImageViewArray:(NSArray *)showImageViewArray didSelectItemAtIndex:(NSInteger)index;

- (void)didShowScrollViewPageAtIndex:(NSInteger)index;

@end

@interface STLBannerScrollView : UIView

@property (nonatomic, assign) id<STLBannerScrollViewDelegate> delegate;

@property (nonatomic, assign) CGFloat configureImageWidth;
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

- (void)refreshImageUrl:(NSArray *)imageUrlArray scrollToFirstIndex:(BOOL)scrollToFirstIndex animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
