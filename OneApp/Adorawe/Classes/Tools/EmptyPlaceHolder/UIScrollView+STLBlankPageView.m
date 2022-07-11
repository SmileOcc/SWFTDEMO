//
//  UIScrollView+STLBlankPageView.m
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "UIScrollView+STLBlankPageView.h"

#import "OSSVRefreshsHeaders.h"
#import "OSSVRefreshsFooter.h"
#import "STLBlankPageTipView.h"

/** 网络连接失败 */
//#define kNetworkConnectDefaultFailTips STLLocalizedString_(@"BlankPage_NetworkError_tipTitle",nil)
#define kNetworkConnectDefaultFailTips STLLocalizedString_(@"EmptyCustomViewManager_titleLabel",nil)
/** 刷新提示文案 */
#define kAgainRequestDefaultTipString  STLLocalizedString_(@"EmptyCustomViewManager_refreshButton",nil)
/** 请求失败默认提示文案 */
#define kReqFailDefaultTipText         STLLocalizedString_(@"EmptyCustomViewManager_titleLabel",nil)
/** 请求空数据默认提示文案 */
#define kEmptyDataDefaultTipText       STLLocalizedString_(@"EmptyCustomViewHasNoData_titleLabel",nil)
/* 弱引用 */
#define WEAKSELF                       typeof(self) __weak weakSelf = self;
/* 强引用 */
#define STRONGSELF                     typeof(weakSelf) __strong strongSelf = weakSelf;

static char const * const kAutomaticShowTipViewKey      = "kAutomaticShowTipViewKey";
static char const * const kBlankPageViewCenterKey       = "kBlankPageViewCenterKey";
static char const * const kBlankPageTipViewOffsetYKey   = "kBlankPageTipViewOffsetYKey";
static char const * const kblankPageImageViewTopDistanceKey   = "kblankPageImageViewTopDistanceKey";
static char const * const kblankPageTipViewTopDistanceKey   = "kblankPageTipViewTopDistanceKey";
static char const * const kBlankPageViewActionBlcokKey  = "kBlankPageViewActionBlcokKey";
static char const * const kisIgnoreHeaderOrFooter      = "kisIgnoreHeaderOrFooter";


static char const * const KEmptyDataTitleKey            = "KEmptyDataTitleKey";
static char const * const kEmptyDataSubTitleKey         = "kEmptyDataSubTitleKey";
static char const * const KEmptyDataImageKey            = "KEmptyDataImageKey";
static char const * const KEmptyDataBtnTitleKey         = "KEmptyDataBtnTitleKey";

static char const * const kRequestFailTitleKey          = "kRequestFailTitleKey";
static char const * const kRequestFailImageKey          = "kRequestFailImageKey";
static char const * const kRequestFailBtnTitleKey       = "kRequestFailBtnTitleKey";

static char const * const kNetworkErrorTitleKey         = "kNetworkErrorTitleKey";
static char const * const kNetworkErrorImageKey         = "kNetworkErrorImageKey";
static char const * const kNetworkErrorBtnTitleKey      = "kNetworkErrorBtnTitleKey";


@implementation UIScrollView (STLBlankPageView)

// ==================== 是否自动显示请求提示view ====================

- (void)setAutomaticShowTipView:(BOOL)automaticShowTipView
{
    objc_setAssociatedObject(self, kAutomaticShowTipViewKey, @(automaticShowTipView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)automaticShowTipView
{
    id value = objc_getAssociatedObject(self, kAutomaticShowTipViewKey);
    return [value boolValue];
}

// ==================== 请求空数据标题 ====================

- (void)setEmptyDataTitle:(NSString *)emptyDataTitle
{
    objc_setAssociatedObject(self, KEmptyDataTitleKey, emptyDataTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)emptyDataTitle
{
    NSString *emptyTip = objc_getAssociatedObject(self, KEmptyDataTitleKey);
    return emptyTip ? : kEmptyDataDefaultTipText;
}

// ==================== 请求空数据副标题 ====================

- (void)setEmptyDataSubTitle:(NSString *)emptyDataSubTitle
{
    objc_setAssociatedObject(self, kEmptyDataSubTitleKey, emptyDataSubTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)emptyDataSubTitle
{
    NSString *emptyTip = objc_getAssociatedObject(self, kEmptyDataSubTitleKey);
    return emptyTip;
}

// ==================== 请求空数据图片 ====================

- (void)setEmptyDataImage:(UIImage *)emptyDataImage
{
    objc_setAssociatedObject(self, KEmptyDataImageKey, emptyDataImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)emptyDataImage
{
    UIImage *image = objc_getAssociatedObject(self, KEmptyDataImageKey);
    if (!image) {
        image = [UIImage imageNamed:@"recently_data_bank"];
    }
    return image;
}

// ==================== 空数按钮点标题 ====================

- (void)setEmptyDataBtnTitle:(NSString *)emptyDataBtnTitle
{
    objc_setAssociatedObject(self, KEmptyDataBtnTitleKey, emptyDataBtnTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)emptyDataBtnTitle
{
    NSString *emptyBtnTitle = objc_getAssociatedObject(self, KEmptyDataBtnTitleKey);
    return emptyBtnTitle;
}

// ==================== 请求失败提示 ====================

- (void)setRequestFailTitle:(NSString *)requestFailTitle
{
    objc_setAssociatedObject(self, kRequestFailTitleKey, requestFailTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)requestFailTitle
{
    NSString *tipStr = objc_getAssociatedObject(self, kRequestFailTitleKey);
    return tipStr ? : kReqFailDefaultTipText;
}

// ==================== 请求失败图片 ====================

- (void)setRequestFailImage:(UIImage *)requestFailImage
{
    objc_setAssociatedObject(self, kRequestFailImageKey, requestFailImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)requestFailImage
{
    UIImage *image = objc_getAssociatedObject(self, kRequestFailImageKey);
    if (!image) {
        image = [UIImage imageNamed:@"load_fail_bank"];
    }
    return image;
}

// ==================== 请求失败按钮点标题 ====================

- (void)setRequestFailBtnTitle:(NSString *)requestFailBtnTitle
{
    objc_setAssociatedObject(self, kRequestFailBtnTitleKey, requestFailBtnTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)requestFailBtnTitle
{
    NSString *failBtnTitle = objc_getAssociatedObject(self, kRequestFailBtnTitleKey);
    return failBtnTitle;
}

// ==================== 网络错误提示 ====================

- (void)setNetworkErrorTitle:(NSString *)networkErrorTitle
{
    objc_setAssociatedObject(self, kNetworkErrorTitleKey, networkErrorTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)networkErrorTitle
{
    NSString *tipStr = objc_getAssociatedObject(self, kNetworkErrorTitleKey);
    return tipStr ? : kNetworkConnectDefaultFailTips;
}

// ==================== 网络错误图片 ====================

- (void)setNetworkErrorImage:(UIImage *)networkErrorImage
{
    objc_setAssociatedObject(self, kNetworkErrorImageKey, networkErrorImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)networkErrorImage
{
    UIImage *image = objc_getAssociatedObject(self, kNetworkErrorImageKey);
    if (!image) {
        image = [UIImage imageNamed:@"load_fail_bank"];
    }
    return image;
}

// ==================== 网络失败按钮点标题 ====================

- (void)setNetworkErrorBtnTitle:(NSString *)networkErrorBtnTitle
{
    objc_setAssociatedObject(self, kNetworkErrorBtnTitleKey, networkErrorBtnTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)networkErrorBtnTitle
{
    NSString *networkFailBtnTitle = objc_getAssociatedObject(self, kNetworkErrorBtnTitleKey);
    return networkFailBtnTitle;
}

// ==================== 网络连接按钮点击事件回调 ====================

- (void)setBlankPageViewActionBlcok:(void (^)(STLBlankPageViewStatus))blankPageViewActionBlcok
{
    objc_setAssociatedObject(self, kBlankPageViewActionBlcokKey, blankPageViewActionBlcok, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(STLBlankPageViewStatus))blankPageViewActionBlcok
{
    return objc_getAssociatedObject(self, kBlankPageViewActionBlcokKey);
}

// ==================== 提示View的中心位置 ====================

- (void)setBlankPageViewCenter:(CGPoint)blankPageViewCenter
{
    NSString *centerObj = NSStringFromCGPoint(blankPageViewCenter);
    objc_setAssociatedObject(self, kBlankPageViewCenterKey, centerObj, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    UIView *tipView = [self viewWithTag:kRequestTipViewTag];
    if (tipView) {
        tipView.center = blankPageViewCenter;
    }
}

- (CGPoint)blankPageViewCenter
{
    NSString *centerObj = objc_getAssociatedObject(self, kBlankPageViewCenterKey);
    return CGPointFromString(centerObj);
}

// ==================== 外部可控制内容提示tipView的距离顶部距离 ====================

- (void)setBlankPageImageViewTopDistance:(CGFloat)blankPageTipViewTopDistance
{
    objc_setAssociatedObject(self, kblankPageImageViewTopDistanceKey, @(blankPageTipViewTopDistance), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)blankPageImageViewTopDistance {
    id value = objc_getAssociatedObject(self, kblankPageImageViewTopDistanceKey);
    return [value floatValue];
}

- (void)setBlankPageTipViewTopDistance:(CGFloat)blankPageTipViewTopDistance {
    objc_setAssociatedObject(self, kblankPageTipViewTopDistanceKey, @(blankPageTipViewTopDistance), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)blankPageTipViewTopDistance {
    id value = objc_getAssociatedObject(self, kblankPageTipViewTopDistanceKey);
    return [value floatValue];
}


// ==================== 外部可控制内容提示tipView的中心上移距离 ====================

- (void)setBlankPageTipViewOffsetY:(CGFloat)blankPageTipViewOffsetY
{
    objc_setAssociatedObject(self, kBlankPageTipViewOffsetYKey, @(blankPageTipViewOffsetY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)blankPageTipViewOffsetY {
    id value = objc_getAssociatedObject(self, kBlankPageTipViewOffsetYKey);
    return [value floatValue];
}

- (void)setIsIgnoreHeaderOrFooter:(BOOL)isIgnoreHeaderOrFooter {
    objc_setAssociatedObject(self, kisIgnoreHeaderOrFooter, @(isIgnoreHeaderOrFooter), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (BOOL)isIgnoreHeaderOrFooter {
    return [objc_getAssociatedObject(self, kisIgnoreHeaderOrFooter) boolValue];
}

// ==================== 显示全屏下拉banner ====================

- (void)setShowDropBanner:(BOOL)showDropBanner{
    objc_setAssociatedObject(self, @selector(showDropBanner), @(showDropBanner), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)showDropBanner {
    return [objc_getAssociatedObject(self, @selector(showDropBanner)) boolValue];
}

/**
 * 开始监听网络
 */
+ (void)load
{
    //AFN需要提前监听网络
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

#pragma mark - 给表格添加上下拉刷新事件

/**
 社区页面初始化表格的上下拉刷新控件
 
 @param headerBlock 下拉刷新需要调用的函数
 @param footerBlock 上拉刷新需要调用的函数
 @param startRefreshing 是否需要立即刷新
 */
- (void)addCommunityHeaderRefreshBlock:(STLRefreshingBlock)headerBlock
           footerRefreshBlock:(STLRefreshingBlock)footerBlock
              startRefreshing:(BOOL)startRefreshing
{
    if (headerBlock) {
        @weakify(self)
        OSSVRefreshsHeaders *header = [OSSVRefreshsHeaders headerWithRefreshingBlock:^{
            @strongify(self)
            
            //1.先移除页面上已有的提示视图
            [self removeOldTipBgView];
            
            //2.每次下拉刷新时先结束上啦
            [self.mj_footer endRefreshing];
            
            headerBlock();
        }];
        self.mj_header = header;
        
        //是否需要立即刷新
        if (startRefreshing) {
            [self.mj_header beginRefreshing];
        }
    }
    
    if (footerBlock) {
        OSSVRefreshsFooter *footer = [OSSVRefreshsFooter footerWithRefreshingBlock:^{
            footerBlock();
        }];
        self.mj_footer = footer;
        //这里需要先隐藏,否则已进入页面没有数据也会显示上拉View
        self.mj_footer.hidden = YES;
    }
}

/**
 社区页面初始化表格的上下拉刷新控件
 
 @param headerBlock 下拉刷新需要调用的函数
 @param footerBlock 上拉刷新需要调用的函数
 param pullingShowBannerBlock 下拉到显示Banner的contentOffset的回调方法
 @param startRefreshing 是否需要立即刷新
 */
- (void)addCommunityHeaderRefreshBlock:(STLRefreshingBlock)headerBlock
                PullingShowBannerBlock:(PullingBannerBlock)pullingBannerBlock
                    footerRefreshBlock:(STLRefreshingBlock)footerBlock
                       startRefreshing:(BOOL)startRefreshing
{
    [self addCommunityHeaderRefreshBlock:headerBlock
                  PullingShowBannerBlock:pullingBannerBlock
                 refreshDropPullingBlock:nil
                      footerRefreshBlock:footerBlock
                         startRefreshing:startRefreshing];
}

- (void)addCommunityHeaderRefreshBlock:(STLRefreshingBlock)headerBlock
                PullingShowBannerBlock:(PullingBannerBlock)pullingBannerBlock
               refreshDropPullingBlock:(PullingDownBlock)pullingDownBlock
                    footerRefreshBlock:(STLRefreshingBlock)footerBlock
                       startRefreshing:(BOOL)startRefreshing
{
    if (headerBlock) {
        @weakify(self)
        OSSVRefreshsHeaders *header = [OSSVRefreshsHeaders headerWithRefreshingBlock:^{
            @strongify(self)
            
            //1.先移除页面上已有的提示视图
            [self removeOldTipBgView];
            
            //2.每次下拉刷新时先结束上啦
            [self.mj_footer endRefreshing];
            
            if (headerBlock) {
               headerBlock();
            }
        }];
        
        header.refreshDropBannerBlock = ^{
            //下拉到可以触发广告的block
            if (pullingBannerBlock) {
                pullingBannerBlock();
            }
        };
        
        header.refreshDropPullingBlock = ^{
            //正在下拉触发的block
            if (pullingDownBlock) {
                pullingDownBlock();
            }
        };
        
        header.isCommunityRefresh = YES;
        
        self.mj_header = header;
        
        //是否需要立即刷新
        if (startRefreshing) {
            [self.mj_header beginRefreshing];
        }
    }
    
    if (footerBlock) {
        OSSVRefreshsFooter *footer = [OSSVRefreshsFooter footerWithRefreshingBlock:^{
            footerBlock();
        }];
        self.mj_footer = footer;
        //这里需要先隐藏,否则已进入页面没有数据也会显示上拉View
        self.mj_footer.hidden = YES;
    }
}


/**
 初始化表格的上下拉刷新控件

 @param headerBlock 下拉刷新需要调用的函数
 @param footerBlock 上拉刷新需要调用的函数
 @param startRefreshing 是否需要立即刷新
 */
- (void)addHeaderRefreshBlock:(STLRefreshingBlock)headerBlock
           footerRefreshBlock:(STLRefreshingBlock)footerBlock
              startRefreshing:(BOOL)startRefreshing
{
    if (headerBlock) {
        WEAKSELF
        OSSVRefreshsHeaders *header = [OSSVRefreshsHeaders headerWithRefreshingBlock:^{
            STRONGSELF
            
            //1.先移除页面上已有的提示视图
            [strongSelf removeOldTipBgView];
            
            //2.每次下拉刷新时先结束上啦
            [strongSelf.mj_footer endRefreshing];
            
            headerBlock();
        }];
        self.mj_header = header;
        
        //是否需要立即刷新
        if (startRefreshing) {
            [self.mj_header beginRefreshing];
        }
    }

    if (footerBlock) {
        OSSVRefreshsFooter *footer = [OSSVRefreshsFooter footerWithRefreshingBlock:^{
            footerBlock();
        }];
        self.mj_footer = footer;
        //这里需要先隐藏,否则已进入页面没有数据也会显示上拉View
        self.mj_footer.hidden = YES;
    }
}

/**
 * 开始加载头部数据
 
 @param animation 加载时是否需要动画
 */
- (void)headerRefreshingByAnimation:(BOOL)animation {
    if (!self.mj_header) return;
    if (animation) {
        [self.mj_header beginRefreshing];
    } else {
        if ([self.mj_header respondsToSelector:@selector(executeRefreshingCallback)]) {
            [self.mj_header executeRefreshingCallback];
        }
    }
}

#pragma mark - 给表格添加上请求失败提示事件
/**
 * 处理空白页
 */
- (void)doBlankViewWithCurrentPage:(NSNumber *)currentPage totalPage:(NSNumber *)totalPage {
    NSMutableDictionary *pageDataDic = [NSMutableDictionary dictionary];
    if (currentPage) {
        pageDataDic[kCurrentPageKey] = currentPage;
    }
    if (totalPage) {
        pageDataDic[kTotalPageKey] = totalPage;
    }
    
    if (currentPage && totalPage) {
        [self showRequestTip:pageDataDic];
    } else {
        [self showRequestTip:nil];
    }
}

/**
 此方法作用: 会自动收起表格上下拉刷新控件, 判断分页逻辑, 添加数据空白页等操作
 调用条件：  必须要在UITableView/UICollectionView 实例的reloadData方法执行后调用才能生效
 
 @param totalPageCurrentPageCountDict 页面上表格分页数据 "pageCount"数 与 "curPage"数 包装的字典, 注意key不要写错
 */
- (void)showRequestTip:(NSDictionary *)totalPageCurrentPageCountDict
{
    //判断请求状态: totalPageCurrentPageCountDict为字典就是请求成功, 否则为请求失败
    BOOL requestSuccess = [totalPageCurrentPageCountDict isKindOfClass:[NSDictionary class]];
    CGFloat dalyTime = requestSuccess ? 0.0 : 0.5;
    
    if (self.mj_header) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dalyTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mj_header endRefreshing];
        });
    }

    if (self.mj_footer) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dalyTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (requestSuccess) {
                [self setPageFooterEendRefresStatus:totalPageCurrentPageCountDict];
            } else {
                [self.mj_footer endRefreshing];
            }
        });
    }

    if ([self contentViewIsEmptyData]) {//页面没有数据

        //根据状态,显示背景提示Viwe
        if (![AFNetworkReachabilityManager sharedManager].reachable) {
            //显示没有网络提示
            [self showTipWithStatus:RequesNoNetWorkStatus];

        } else {
            //成功:显示空数据提示, 失败:显示请求失败提示
            STLBlankPageViewStatus status = requestSuccess ? RequestEmptyDataStatus : RequestFailStatus;
            [self showTipWithStatus:status];
        }

    } else { //页面有数据

        //移除页面上已有的提示视图
        [self removeOldTipBgView];

        if (requestSuccess && self.mj_footer) {
            //控制刷新控件显示的分页逻辑
            [self setPageRefreshStatus:totalPageCurrentPageCountDict];
        }

        //分页时页面上有数据，但下拉失败时需要提示
        if (!requestSuccess && self.mj_header) {
            UIView *vcView = self.superview;
            if (!vcView || vcView.height < 600.0) {
                vcView = nil;
            }
            //ShowToastToViewWithText(vcView, LocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
        }
    }
}


- (void)showRequestTip:(NSDictionary *)totalPageCurrentPageCountDict isNeedNetWorkStatus:(BOOL)isNeedNetWorkStatus
{
    //判断请求状态: totalPageCurrentPageCountDict为字典就是请求成功, 否则为请求失败
    BOOL requestSuccess = [totalPageCurrentPageCountDict isKindOfClass:[NSDictionary class]];
    CGFloat dalyTime = requestSuccess ? 0.0 : 0.5;
    
    if (self.mj_header) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dalyTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mj_header endRefreshing];
        });
    }
    
    if (self.mj_footer) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dalyTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (requestSuccess) {
                [self setPageFooterEendRefresStatus:totalPageCurrentPageCountDict];
            } else {
                [self.mj_footer endRefreshing];
            }
        });
    }
    
    if ([self contentViewIsEmptyData]) {//页面没有数据
        
        //根据状态,显示背景提示Viwe
        if (![AFNetworkReachabilityManager sharedManager].reachable && isNeedNetWorkStatus) {
            //显示没有网络提示
            [self showTipWithStatus:RequesNoNetWorkStatus];
            
        } else {
            //成功:显示空数据提示, 失败:显示请求失败提示
            STLBlankPageViewStatus status = requestSuccess ? RequestEmptyDataStatus : RequestFailStatus;
            [self showTipWithStatus:status];
        }
        
    } else { //页面有数据
        
        //移除页面上已有的提示视图
        [self removeOldTipBgView];
        
        if (requestSuccess && self.mj_footer) {
            //控制刷新控件显示的分页逻辑
            [self setPageRefreshStatus:totalPageCurrentPageCountDict];
        }
        
        //分页时页面上有数据，但下拉失败时需要提示
        if (!requestSuccess && self.mj_header) {
            UIView *vcView = self.superview;
            if (!vcView || vcView.height < 600.0) {
                vcView = nil;
            }
            //ShowToastToViewWithText(vcView, LocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
        }
    }
}

#pragma mark - 如果请求失败,无网络则展示空白提示view

/**
 * 设置提示图片和文字
 */
- (void)showTipWithStatus:(STLBlankPageViewStatus)state
{
    //先移除页面上已有的提示视图
    [self removeOldTipBgView];

    WEAKSELF
    void (^removeTipViewAndRefreshHeadBlock)(void) = ^(){
        STRONGSELF
        if (strongSelf.mj_header && strongSelf.mj_header.state == MJRefreshStateIdle) {
            //1.先移除页面上已有的提示视图
            [strongSelf removeOldTipBgView];
            //2.开始走下拉请求
            [strongSelf.mj_header beginRefreshing];
        }
    };
    
    void (^blankPageViewBtnActionBlcok)(void) = ^(){
        STRONGSELF
        //如果额外设置了按钮事件
        if (strongSelf.blankPageViewActionBlcok) {
            //1. 先移除页面上已有的提示视图
            if (state != RequestEmptyDataStatus) {
                [strongSelf removeOldTipBgView];
            }
            
            //2. 回调按钮点击事件
            strongSelf.blankPageViewActionBlcok(state);
        }
    };

    NSString *tipString = nil;
    NSString *subTipString = nil;
    UIImage *tipImage = nil;
    NSString *actionBtnTitle = nil;
    void (^actionBtnBlock)(void) = nil;

    if (state == RequesNoNetWorkStatus) {//没有网络

        tipString = self.networkErrorTitle;
        tipImage = self.networkErrorImage;
        if (APP_TYPE == 3) {
            actionBtnTitle = self.networkErrorBtnTitle ? : kAgainRequestDefaultTipString;
        } else {
            actionBtnTitle = self.networkErrorBtnTitle ? : kAgainRequestDefaultTipString.uppercaseString;
        }
        if (self.blankPageViewActionBlcok) {
            actionBtnBlock = blankPageViewBtnActionBlcok;
            
        } else if (self.mj_header) {
            actionBtnBlock = removeTipViewAndRefreshHeadBlock;
        } else {
            actionBtnTitle = nil;
        }
    } else if (state == RequestEmptyDataStatus) {//空数据提示

        tipString = self.emptyDataTitle;
        tipImage = self.emptyDataImage;
        subTipString = self.emptyDataSubTitle;
        actionBtnTitle = self.emptyDataBtnTitle;
        if (self.blankPageViewActionBlcok) {
            actionBtnBlock = blankPageViewBtnActionBlcok;
        } else {
            actionBtnTitle = nil;
        }

    } else if (state == RequestFailStatus) { //请求失败提示

        tipString = self.requestFailTitle;
        tipImage = self.requestFailImage;
        if (APP_TYPE == 3) {
            actionBtnTitle = self.networkErrorBtnTitle ? : kAgainRequestDefaultTipString;
        } else {
            actionBtnTitle = self.networkErrorBtnTitle ? : kAgainRequestDefaultTipString.uppercaseString;
        }
        if (self.blankPageViewActionBlcok) {
            actionBtnBlock = blankPageViewBtnActionBlcok;
            
        } else if (self.mj_header) {
            actionBtnBlock = removeTipViewAndRefreshHeadBlock;
        } else {
            actionBtnTitle = nil;
        }
    } else {
        return;
    }
    
    //防止添加空提示view
    if (!tipString && !tipImage &&
        !subTipString && !actionBtnTitle) {
        return;
    }

    //需要显示的自定义提示view
    CGFloat contentInsetLeft = self.contentInset.left;
    CGFloat contentInsetRight = self.contentInset.right;
    
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width - contentInsetLeft - contentInsetRight, self.bounds.size.height);
    //只能上移
    CGFloat tipTopY = self.blankPageTipViewOffsetY > 0 ? self.blankPageTipViewOffsetY : 0;
    CGFloat topDistance = self.blankPageImageViewTopDistance > 0 ? self.blankPageImageViewTopDistance : 0;

    STLBlankPageTipView *tipBgView = [STLBlankPageTipView tipViewByFrame:rect
                                                             topDistance:topDistance
                                                           moveOffsetY:tipTopY
                                                              topImage:tipImage
                                                                 title:tipString
                                                              subTitle:subTipString
                                                           actionTitle:actionBtnTitle
                                                           actionBlock:actionBtnBlock];
    if (self.backgroundColor) {
        tipBgView.backgroundColor = self.backgroundColor;
    }
    [self addSubview:tipBgView];
    //外部可控制提示View的中心位置
    if (self.blankPageViewCenter.x != 0 && self.blankPageViewCenter.y != 0) {
        tipBgView.center = self.blankPageViewCenter;
    }
    if (self.blankPageTipViewTopDistance > 0) {
        CGRect frame = tipBgView.frame;
        frame.origin.y = self.blankPageTipViewTopDistance;
        tipBgView.frame = frame;
    }
}

/**
 * 控制刷新控件显示的分页逻辑
 */
- (void)setPageFooterEendRefresStatus:(NSDictionary *)responseData {
    
    id totalPage = responseData[kTotalPageKey];
    id currentPage = responseData[kCurrentPageKey];
//    NSArray *dataArr = responseData[kListKey];

    if (totalPage && currentPage) {

        if ([totalPage integerValue] > [currentPage integerValue]) {
            self.mj_footer.hidden = NO;

        } else {
            [self.mj_footer endRefreshingWithNoMoreData];
            self.mj_footer.hidden = NO;
        }

    }
//    else if([dataArr isKindOfClass:[NSArray class]]){
//        if (dataArr.count>0) {
//            self.mj_footer.hidden = NO;
//
//        } else {
//            [self.mj_footer endRefreshingWithNoMoreData];
//            //self.mj_footer.hidden = YES;
//        }
//
//    }
    else {
        [self.mj_footer endRefreshingWithNoMoreData];
        self.mj_footer.hidden = YES;
    }
}
/**
 * 控制刷新控件显示的分页逻辑
 */
- (void)setPageRefreshStatus:(NSDictionary *)responseData
{
    id totalPage = responseData[kTotalPageKey];
    id currentPage = responseData[kCurrentPageKey];
    NSArray *dataArr = responseData[kListKey];

    if (totalPage && currentPage) {

        if ([totalPage integerValue] > [currentPage integerValue]) {
            self.mj_footer.hidden = NO;

        } else {
            [self.mj_footer endRefreshingWithNoMoreData];
            //self.mj_footer.hidden = YES;
        }

    } else if([dataArr isKindOfClass:[NSArray class]]){
        if (dataArr.count>0) {
            self.mj_footer.hidden = NO;

        } else {
            [self.mj_footer endRefreshingWithNoMoreData];
            //self.mj_footer.hidden = YES;
        }

    } else {
        [self.mj_footer endRefreshingWithNoMoreData];
        //self.mj_footer.hidden = YES;
    }
}

/**
 先移除页面上已有的提示视图
 */
- (void)removeOldTipBgView
{
    for (UIView *tempView in self.subviews) {
        if ([tempView isKindOfClass:[STLBlankPageTipView class]] &&
            tempView.tag == kRequestTipViewTag) {
            [tempView removeFromSuperview];
            break;
        }
    }
}

/**
 * 判断ScrollView页面上是否有数据
 */
- (BOOL)contentViewIsEmptyData
{
    BOOL isEmptyCell = YES;
    NSInteger sections = 1;//默认系统都1个sections

    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        
        if (!self.isIgnoreHeaderOrFooter && (tableView.tableHeaderView.bounds.size.height > 10 ||
            tableView.tableFooterView.bounds.size.height > 10)) {
            return NO;
        }
        
        id<UITableViewDataSource> dataSource = tableView.dataSource;
        if ([dataSource respondsToSelector: @selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        
        for (int i = 0; i < sections; ++i) {
            NSInteger rows = [dataSource tableView:tableView numberOfRowsInSection:i];
            if (rows) {
                isEmptyCell = NO;
                break;
            }
        }
        
        // 如果每个Cell没有数据源, 则还需要判断Header和Footer高度是否为0
        if (isEmptyCell) {
            id<UITableViewDelegate> delegate = tableView.delegate;
            BOOL isEmptyHeader = YES;
            
            if ([delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
                for (int h = 0; h < sections; ++h) {
                    CGFloat headerHeight = [delegate tableView:tableView heightForHeaderInSection:h];
                    if (headerHeight > 1.0) {
                        isEmptyHeader = NO;
                        isEmptyCell = NO;
                        break;
                    }
                }
            }
            
            // 如果Header没有高度还要判断Footer是否有高度
            if (isEmptyHeader) {
                if ([delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
                    for (int k = 0; k < sections; ++k) {
                        CGFloat footerHeight = [delegate tableView:tableView heightForFooterInSection:k];
                        if (footerHeight > 1.0) {
                            isEmptyCell = NO;
                            break;
                        }
                    }
                }
            }
        }
        
    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        
        id<UICollectionViewDataSource> dataSource = collectionView.dataSource;
        if ([dataSource respondsToSelector: @selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        for (int i = 0; i < sections; ++i) {
            NSInteger rows = [dataSource collectionView:collectionView numberOfItemsInSection:i];
            if (rows) {
                isEmptyCell = NO;
            }
        }
        
        // 如果每个ItemCell没有数据源, 则还需要判断Header和Footer高度是否为0
        if (isEmptyCell) {
            BOOL isEmptyHeader = YES;
            id<UICollectionViewDelegateFlowLayout> delegateFlowLayout = collectionView.delegate;
            
            if ([delegateFlowLayout respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
                for (int h = 0; h < sections; ++h) {
                    CGSize size = [delegateFlowLayout collectionView:collectionView layout:collectionView.collectionViewLayout referenceSizeForHeaderInSection:h];
                    if (size.height > 1.0) {
                        isEmptyHeader = NO;
                        isEmptyCell = NO;
                        break;
                    }
                }
            }
            
            // 如果Header没有高度还要判断Footer是否有高度
            if (isEmptyHeader) {
                if ([delegateFlowLayout respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
                    
                    for (int k = 0; k < sections; ++k) {
                        CGSize size = [delegateFlowLayout collectionView:collectionView layout:collectionView.collectionViewLayout referenceSizeForFooterInSection:k];
                        if (size.height > 1.0) {
                            isEmptyCell = NO;
                            break;
                        }
                    }
                }
            }
        }
        
    } else {
        if (self.hidden || self.alpha == 0) {
            isEmptyCell = NO;
        } else {
            isEmptyCell = YES;
        }
    }
    return isEmptyCell;
}

#pragma mark -=========== 自动添加提示View入口 ===========

/**
 *  处理自动根据表格数据来显示提示view
 */
- (void)convertShowTipView
{
    //需要显示提示view
    if (self.automaticShowTipView) {

        /** 给表格添加请求失败提示事件
         * <警告：这里如果有MJRefresh下拉刷新控件, 一定要延迟，因为MJRefresh库也替换了reloadData方法，否则不能收起刷新控件>
         */
        CGFloat delay = 0.0;
        if (self.mj_header || self.mj_footer) {
            delay = 0.5;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showRequestTip:[NSDictionary new]];
        });
    }
}

@end


//@implementation NSObject (ScrollViewSwizze)
//
//+ (void)stl_exchangeInstanceMethod:(SEL)originSelector otherSelector:(SEL)otherSelector
//{
//    method_exchangeImplementations(class_getInstanceMethod(self, originSelector), class_getInstanceMethod(self, otherSelector));
//}
//@end
//
//#pragma mark -===========监听UITableView刷新方法===========
//
//@implementation UITableView (STLBlankPageView)
//
///**
// * 监听表格所有的刷新方法
// */
//+(void)load
//{
//    //交换刷新表格方法
//    [self stl_exchangeInstanceMethod:@selector(reloadData)
//                      otherSelector:@selector(stl_reloadData)];
//    //交换删除表格方法
//    [self stl_exchangeInstanceMethod:@selector(deleteRowsAtIndexPaths:withRowAnimation:)
//                      otherSelector:@selector(stl_deleteRowsAtIndexPaths:withRowAnimation:)];
//    //交换刷新表格Sections方法
//    [self stl_exchangeInstanceMethod:@selector(reloadSections:withRowAnimation:)
//                      otherSelector:@selector(stl_reloadSections:withRowAnimation:)];
//}
//
//- (void)stl_reloadData
//{
//    [self stl_reloadData];
//    [self convertShowTipView];
//}
//
//- (void)stl_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
//                 withRowAnimation:(UITableViewRowAnimation)animation
//{
//    [self stl_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
//    [self convertShowTipView];
//}
//
//- (void)stl_reloadSections:(NSIndexSet *)sections
//         withRowAnimation:(UITableViewRowAnimation)animation
//{
//    [self stl_reloadSections:sections withRowAnimation:animation];
//    [self convertShowTipView];
//}
//@end
//
//#pragma mark -===========监听UICollectionView刷新方法===========
//
//@implementation UICollectionView (STLBlankPageView)
//
///**
// * 监听CollectionView所有的刷新方法
// */
//+ (void)load
//{
//    [self stl_exchangeInstanceMethod:@selector(reloadData)
//                      otherSelector:@selector(stl_reloadData)];
//
//    [self stl_exchangeInstanceMethod:@selector(deleteSections:)
//                      otherSelector:@selector(stl_deleteSections:)];
//
//    [self stl_exchangeInstanceMethod:@selector(reloadSections:)
//                      otherSelector:@selector(stl_reloadSections:)];
//
//    [self stl_exchangeInstanceMethod:@selector(deleteItemsAtIndexPaths:)
//                      otherSelector:@selector(stl_deleteItemsAtIndexPaths:)];
//
//    [self stl_exchangeInstanceMethod:@selector(reloadItemsAtIndexPaths:)
//                      otherSelector:@selector(stl_reloadItemsAtIndexPaths:)];
//}
//
//- (void)stl_reloadData
//{
//    [self stl_reloadData];
//    [self convertShowTipView];
//}
//
//- (void)stl_deleteSections:(NSIndexSet *)sections
//{
//    [self stl_deleteSections:sections];
//    [self convertShowTipView];
//}
//
//- (void)stl_reloadSections:(NSIndexSet *)sections
//{
//    [self stl_reloadSections:sections];
//    [self convertShowTipView];
//}
//
//- (void)stl_deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
//{
//    [self stl_deleteItemsAtIndexPaths:indexPaths];
//    [self convertShowTipView];
//}
//
//- (void)stl_reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
//{
//    [self stl_reloadItemsAtIndexPaths:indexPaths];
//    [self convertShowTipView];
//}
//@end
