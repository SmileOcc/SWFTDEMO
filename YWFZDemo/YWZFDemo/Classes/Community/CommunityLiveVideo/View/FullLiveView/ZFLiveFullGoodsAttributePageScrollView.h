//
//  ZFPageScrollView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "SystemConfigUtils.h"

#import "ZFGoodsModel.h"

#import "ZFFullLiveGoodsAttributesItemView.h"

#define kLiveLineMagin          4.0
#define kLiveViewWidth          (316.0 + kLiveLineMagin)

typedef NS_ENUM(NSInteger,LiveGoodsAttributesOperateType) {
    LiveGoodsAttributesOperateTypeCart,
    LiveGoodsAttributesOperateTypeGuideSize,
    LiveGoodsAttributesOperateTypeComment
};
@class ZFLiveFullGoodsAttributePageScrollView;

NS_ASSUME_NONNULL_BEGIN

@protocol ZFLiveFullGoodsAttributePageScrollViewDelegate <NSObject>

/**
 点击Banner回调
 */
- (void)zfPageScrollView:(ZFLiveFullGoodsAttributePageScrollView *)view showArray:(NSArray *)showViewArray didSelectItemAtIndex:(NSInteger)index;

- (void)didShowScrollView:(ZFFullLiveGoodsAttributesItemView *)itemView pageAtIndex:(NSInteger)index;

- (void)willShowScrollView:(ZFFullLiveGoodsAttributesItemView *)itemView pageAtIndex:(NSInteger)index;

- (void)liveFullGoodsAttributePage:(ZFFullLiveGoodsAttributesItemView *)itemView eventType:(LiveGoodsAttributesOperateType )eventType;

- (void)liveFullGoodsAttributePage:(ZFFullLiveGoodsAttributesItemView *)itemView eventType:(LiveGoodsAttributesOperateType )eventType goodsDetailModel:(GoodsDetailModel *)goodsDetailModel;
@end

@interface ZFLiveFullGoodsAttributePageScrollView : UIView

@property (nonatomic, assign) id<ZFLiveFullGoodsAttributePageScrollViewDelegate> delegate;


@property (nonatomic, copy) NSString *liveVideoId;

@property (nonatomic, assign) CGFloat contentH;

/**
 网络图片 url string 数组
 */
@property (nonatomic, strong) NSArray <ZFGoodsModel *> *goodsArray;

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

- (void)refreshTopMarkIndex:(NSString *)recommendGoodsId;

@end

NS_ASSUME_NONNULL_END
