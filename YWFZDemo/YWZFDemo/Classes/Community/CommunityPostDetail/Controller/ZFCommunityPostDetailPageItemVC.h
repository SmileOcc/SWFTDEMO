//
//  ZFCommunityPostDetailPageItemVC.h
//  ZZZZZ
//
//  Created by YW on 2019/1/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFCommunityPostDetailViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityPostDetailPageItemVC : ZFBaseViewController

/** 帖子id */
@property (nonatomic, copy) NSString                                        *reviewID;
/** 统计来源 */
@property (nonatomic, assign) ZFAppsflyerInSourceType                       sourceType;
/** 是否是穿搭类型 */
@property (nonatomic, assign) BOOL                                          isOutfits;

@property (nonatomic, strong, readonly) ZFCommunityPostDetailViewModel     *viewModel;
@property (nonatomic, assign, readonly) BOOL                                isMyTopic;
@property (nonatomic, assign, readonly) CGFloat                             currentOffsetY;

/** offsetY:当前垂直滚动偏移量*/
@property (nonatomic, copy) void (^contentOffsetBlock)(CGFloat offsetY);

/** flag:是否可以滚动*/
@property (nonatomic, copy) void (^canScrollBlock)(BOOL flag);

/**
 创建类
 
 @param reviewID 帖子id
 @param titleString 帖子标题
 @return
 */
- (instancetype)initWithReviewID:(NSString *)reviewID  title:(NSString *)titleString;
- (instancetype)initWithReviewID:(NSString *)reviewID;


/**
 初始请求数据

 @param viewModel 数据源
 */
- (void)laodDefaultViewModel:(ZFCommunityPostDetailViewModel *)viewModel;


/**
 分享帖子
 */
- (void)sharePostAction;

/**
 删除帖子
 */
- (void)deletePostAction;


/**
 进入购物车
 */
- (void)jumpToCartAction;


/**
 隐藏底部视图
 */
- (void)hideBottomView;


/**
 显示底部视图

 @param time 动画时间：设置负数默认0.25
 */
- (void)showBottomViewTime:(CGFloat )time;

@end

NS_ASSUME_NONNULL_END
