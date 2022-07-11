//
//  OSSAPPThemesMainView.h
// OSSAPPThemesMainView
//
//  Created by odd on 2021/3/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVAPPThemeHandleMangerView.h"
#import "OSSVCouponsAlertView.h"
#import "OSSVThemesViewModel.h"
#import "OSSVThemeAnalyseAP.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSAPPThemesMainView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                 firstChannel:(NSString *)firstChannel
                      channel:(NSString *)channel
                        title:(NSString *)title;

// 新的 加入了deeplinkid
- (instancetype)initWithFrame:(CGRect)frame
                 firstChannel:(NSString *)firstChannel
                      channel:(NSString *)channel
                     deeplink:(NSString *)deepLink
                        title:(NSString *)title;


@property (nonatomic, strong) OSSVThemesViewModel   *viewModel;

@property (nonatomic, strong) OSSVAPPThemeHandleMangerView *themeManagerView;
//@property (nonatomic, strong) NSMutableArray <id<CustomerLayoutSectionModuleProtocol>>*dataSourceList;

@property (nonatomic, copy) NSString *customId;
@property (nonatomic, copy) NSString *deepLinkId;
@property (nonatomic, copy) NSString *customName;
@property (nonatomic, copy) NSString                               *title;
@property (nonatomic, strong) OSSVCouponsAlertView         *couponAlertView;
@property (nonatomic, strong) STLActionSheet             *goodsAttributeSheet; // 属性选择弹窗

@property (nonatomic, strong) OSSVDetailsViewModel             *goodsViewModel;
@property (nonatomic, strong) OSSVDetailsBaseInfoModel   *detailModel;
@property (nonatomic, strong) OSSVNewUserPrGoodsModel            *tempNewsUserProductModel;


@property (nonatomic,strong) NSMutableArray <OSSVBasesRequests *>*operations;


@property (nonatomic, strong) OSSVThemeAnalyseAP      *themeAnalyticsAOP;


///是否有频道楼层
@property (nonatomic, assign) BOOL isChannel;

@property (nonatomic, weak) UIButton *rightButton;
// 滑动时是否显示右下角小浮窗
@property (nonatomic, copy) void (^showFloatBannerBlock)(BOOL show);

// 滑动时是否显示顶部搜索框视图
@property (nonatomic, copy) void (^showFloatInputBarBlock)(BOOL show, CGFloat ofsetY);

/** 有些操作必须在已添加到父类视图的时候*/
- (void)viewDidShow;

/** 更新历史浏览记录 */
- (void)updateCMSHistoryGoods;

/** 初始化下拉刷新控件 */
- (void)addListViewRefreshKit;

/***/
- (void)scrollToRecommendPosition;
@end

NS_ASSUME_NONNULL_END
