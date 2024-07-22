//
//  ZFHomeCMSView.h
//  ZZZZZ
//
//  Created by YW on 2019/6/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCMSViewModel.h"
#import "ZFBannerModel.h"

#import "ZFCMSHomeAnalyticsAOP.h"

#import "ZFCMSManagerView.h"

// 显示顶部输入框滑动高度
#define kFloatHomeBarHeight  (STATUSHEIGHT + NAVBARHEIGHT)


@class ZFCMSSectionModel, ZFBTSModel;

@interface ZFHomeCMSView : UIView

@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, copy) NSString *firstChannelId;//第一个频道ChannelId

@property (nonatomic, strong) ZFBTSModel *btsModel;

@property (nonatomic, strong) ZFBTSModel *homePageSearchBtsModel;

//第一个频道的列表数据
@property (nonatomic, strong) NSArray<ZFCMSSectionModel *> *homeSectionModelArr;

// 滑动时是否显示右下角小浮窗
@property (nonatomic, copy) void (^showFloatBannerBlock)(BOOL show);

// 滑动时是否显示顶部搜索框视图
@property (nonatomic, copy) void (^showFloatInputBarBlock)(BOOL show, CGFloat ofsetY);

@property (nonatomic, copy) NSString                               *title;

@property (nonatomic, copy)   NSString                             *channelId;
@property (nonatomic, strong) ZFCMSViewModel                       *cmsViewModel;
@property (nonatomic, strong) ZFCMSManagerView                     *cmsManagerView;

@property (nonatomic, strong) NSMutableArray<ZFGoodsModel *>       *recommendGoodsArr;
@property (nonatomic, strong) ZFCMSHomeAnalyticsAOP                *analyticsAOP;
@property (nonatomic, assign) BOOL                                 allowScrollToRecommend;
@property (nonatomic, assign) NSUInteger                           recommendSectionIndex;

- (instancetype)initWithFrame:(CGRect)frame
                 firstChannel:(NSString *)firstChannel
                      channel:(NSString *)channel
                        title:(NSString *)title;

/** 有些操作必须在已添加到父类视图的时候*/
- (void)zf_viewDidShow;

/** 更新历史浏览记录 */
- (void)updateCMSHistoryGoods;

/** 初始化下拉刷新控件 */
- (void)addListViewRefreshKit;

/***/
- (void)scrollToRecommendPosition;
@end
