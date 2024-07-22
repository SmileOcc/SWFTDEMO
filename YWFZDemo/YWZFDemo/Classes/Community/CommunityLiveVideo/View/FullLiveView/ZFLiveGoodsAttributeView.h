//
//  ZFLiveGoodsAttributeView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZFInitViewProtocol.h"
#import "ZFSelectSizeColorHeader.h"
#import "ZFSelectSizeSizeHeader.h"
#import "ZFSizeSelectSizeTipsView.h"
#import "ZFSelectSizeStockTipsHeader.h"
#import "ZFSelectSizeImageListView.h"
#import "ZFSelectSizePriceHeader.h"
#import "ZFSelectLiveCommentHeader.h"
#import "ZFSelectSizeSizeCell.h"
#import "ZFSelectSizeColorCell.h"
#import "ZFSizeSelectSectionModel.h"

#import "UIView+ZFBadge.h"
#import "ZFPopDownAnimation.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "NSStringUtils.h"
#import "NSString+Extended.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "SystemConfigUtils.h"
#import "ExchangeManager.h"
#import "BigClickAreaButton.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "ZFRRPLabel.h"

#import "GoodsDetailModel.h"
#import "ZFGoodsDetailViewModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^LiveGoodsAttributeTypeBlock)(NSString *goodsId);
typedef void(^LiveGoodsAttributeSizeGuideBlock)(NSString *);

@interface ZFLiveGoodsAttributeView : UIView

- (instancetype)initSelectSizeView:(BOOL)showCart
                    bottomBtnTitle:(NSString *)bottomBtnTitle;

// 首次初始
@property (nonatomic, copy) NSString                 *firstGoodsId;

@property (nonatomic, strong) UICollectionView      *collectionView;
@property (nonatomic, strong) UIButton              *refreshButton;

// 外部刷新数据源
@property (nonatomic, strong) GoodsDetailModel *model;
// 外部设置加购文案
@property (nonatomic, copy) NSString *addToBagTitle;

@property (nonatomic, copy) NSString *recommendGoodsId;

@property (nonatomic, assign) NSInteger reviewAllCounts;


@property (nonatomic, copy) LiveGoodsAttributeTypeBlock              liveGoodsAttributeTypeBlock;
@property (nonatomic, copy) LiveGoodsAttributeSizeGuideBlock         liveGoodsAttributeSizeGuideBlock;

@property (nonatomic, copy) void (^cartBlock)(void);
@property (nonatomic, copy) void (^addCartBlock)(NSString *goodsId, NSInteger count);
@property (nonatomic, copy) void (^commentBlock)(GoodsDetailModel *model);

@property (nonatomic, copy) void (^refreshBlock)(void);


- (void)firstRequestData;

- (void)openSelectTypeView;

- (void)hideSelectTypeView;

- (void)changeCartNumberInfo;

- (void)bottomCartViewEnable:(BOOL)enable;

- (void)showRefreshButton:(BOOL)isShow;

- (void)showLoadActivityView:(BOOL)isShow;

///开始一个加购动画 in self
- (void)startAddCartAnimation:(void(^)(void))endBlock;

/**
 *  开始一个加购动画 in superview
 *  endPoint 动画结束点
 *  endView 动画结束后需要动画的视图
 *  endblock 动画结束回调
 */
- (void)startAddCartAnimation:(UIView *)superView
                     endPoint:(CGPoint)endPoint
                      endView:(UIView *)endView
                     endBlock:(void(^)(void))endBlock;


@end

NS_ASSUME_NONNULL_END
