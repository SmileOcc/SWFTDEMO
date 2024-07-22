//
//  ZFCommunityPostDetailPageVC.m
//  ZZZZZ
//
//  Created by YW on 2019/1/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "UINavigationController+FDFullscreenPopGesture.h"

#import "ZFCommunityPostDetailPageVC.h"
#import "ZFCommunityPostDetailPageItemVC.h"

#import "ZFInitViewProtocol.h"
#import "ZFCommunityPostDetailNavigationView.h"
#import "ZFCommunityPostDetailBottomView.h"
#import "ZFTitleArrowTipView.h"
#import "ZFCommunityPostDetailGuideView.h"
#import "ZFMessageTipView.h"

#import "ZFCommunityPostDetailViewModel.h"
#import "YWCFunctionTool.h"
#import "ZFLocalizationString.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import <Masonry/Masonry.h>
#import "ZFFrameDefiner.h"
#import "ZFProgressHUD.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "SystemConfigUtils.h"
#import "ZFThemeManager.h"
#import "ZFGrowingIOAnalytics.h"

#import "ZFCommunityLikeGuideView.h"

static CGFloat const kZFCommunityPostDetailPageNavigationAnimationHeight = 320.0;

NSString * const kZFCommunityPostDetailPageViewShareTip  = @"kZFCommunityPostDetailPageViewShareTip";
NSString * const kZFCommunityPostDetailPageAddCartTip  = @"kZFCommunityPostDetailPageAddCartTip";


@interface ZFCommunityPostDetailPageVC ()<ZFInitViewProtocol>

@property (nonatomic, strong) ZFCommunityPostDetailNavigationView   *navigaitonView;
@property (nonatomic, strong) ZFCommunityPostDetailBottomView       *bottomView;
@property (nonatomic, strong) ZFTitleArrowTipView                   *addCartTipView;
@property (nonatomic, strong) ZFCommunityPostDetailGuideView        *swipeGuideView;
@property (nonatomic, strong) ZFMessageTipView                      *noMoreMessageTipView;
@property (nonatomic, strong) ZFCommunityLikeGuideView              *likeGuideView;


/** 添加一个透明视图让事件传递到顶层,使其能够侧滑返回 */
@property (nonatomic, strong) UIView                                *leftHoledSliderView;

@property (nonatomic, strong) ZFCommunityPostDetailViewModel       *viewModel;

/** 当前是否属于我的帖子*/
@property (nonatomic, assign) BOOL                                  isMyTopic;
@property (nonatomic, assign) CGFloat                               currentOffsetY;
@property (nonatomic, strong) ZFCommunityPostDetailPageItemVC       *currentPostCtrl;


@property (nonatomic, copy) NSString                                *userID;
@property (nonatomic,strong) NSMutableArray                         *sourceReviewIDsArray;


@end

@implementation ZFCommunityPostDetailPageVC

#pragma mark - Life Cycle

- (instancetype)initWithReviewID:(NSString *)reviewID title:(NSString *)titleString {
    if (self = [super init]) {
        self.reviewID = reviewID;
        self.currentOffsetY = 0;
        if (!ZFIsEmptyString(titleString)) {
            self.title    = titleString;
        }
    }
    return self;
}



#pragma mark - Life Cycle

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fd_prefersNavigationBarHidden = YES;
    self.preloadPolicy = WMPageControllerPreloadPolicyNeighbour;
    
    self.navigaitonView.title = [self.title length] > 0 ? self.title : ZFLocalizedString(@"Community_Videos_DetailTitle",nil);

    [self zfInitView];
    [self zfAutoLayoutView];
    
    [self requestDatas];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self navigationBarAlpha:self.currentOffsetY];
    [self changeCartNumAction];
    [self.navigaitonView zfChangeSkinToShadowNavgationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_swipeGuideView) {
        [_swipeGuideView hideView];
    }
    if (_likeGuideView) {
        [_likeGuideView hiddenView];
    }
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    
    [self.view addSubview:self.navigaitonView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.noMoreMessageTipView];
    [self.view addSubview:self.leftHoledSliderView];
}

- (void)zfAutoLayoutView {
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo([ZFCommunityPostDetailBottomView defaultHeight]);
    }];
    
    [self.navigaitonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.view);
        make.height.mas_equalTo(kiphoneXTopOffsetY + 44.0);
    }];
    
    [self.noMoreMessageTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(-30);
        make.width.mas_lessThanOrEqualTo(KScreenWidth - 60);
    }];
}
#pragma mark - Action

- (void)backItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 分享帖子
 */
- (void)sharePostAction {
    if (self.currentPostCtrl) {
        [self.currentPostCtrl sharePostAction];
    }
}

/**
 删除帖子
 */
- (void)deletePostAction {
    if (self.currentPostCtrl) {
        [self.currentPostCtrl deletePostAction];
    }
}

/**
 进入购物车
 */
- (void)jumpToCartAction {
    if (self.currentPostCtrl) {
        [self.currentPostCtrl jumpToCartAction];
    }
}

#pragma mark - Private Method

- (void)changeCartNumAction {
    [self.navigaitonView setCartBagValues];
}

- (void)requestDatas {
    ShowLoadingToView(self.view);
    
    BOOL relateFalg = YES;
    if (ZFJudgeNSArray(self.reviewIDArray)) {
        relateFalg = NO;
    }
    @weakify(self)
    [self.viewModel requestTopicDetailWithReviewID:self.reviewID relateFlag:relateFalg complateHandle:^{
        @strongify(self)
        HideLoadingFromView(self.view);
        [self handleTopicDetailResult];
    }];
}

- (void)handleTopicDetailResult {
    
    if ([self.viewModel sectionCount] > 0
        || [self.viewModel isRequestSuccess]) {

        self.isMyTopic = [self.viewModel isMyTopic];        
        if (ZFJudgeNSArray(self.reviewIDArray)) {
            [self.sourceReviewIDsArray addObjectsFromArray:self.reviewIDArray];
        } else {
            [self.sourceReviewIDsArray addObject:ZFToString(self.reviewID)];
            [self.sourceReviewIDsArray addObjectsFromArray:[self.viewModel nextReviewIdsArray]];
        }

        [self reloadData];
        [self.view bringSubviewToFront:self.leftHoledSliderView];
        [self.view bringSubviewToFront:self.navigaitonView];
        
        [self removeEmptyView];
        
        if (![ZFCommunityPostDetailGuideView hasShowGuideView]) {
            @weakify(self)
            [self.swipeGuideView showView:^{
                @strongify(self)
                [self showCartTipView];
            }];
        }
        
        //有相关帖子的时候，滑动设置
        if (self.sourceReviewIDsArray.count > 1) {
            self.scrollView.bounces = YES;
            [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        }
        
        // occ阿语适配
        if ([SystemConfigUtils isRightToLeftShow]) {
            self.scrollView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }

    } else {
        [self showEmptyView];
    }
}

- (void)showEmptyView {
    
    self.edgeInsetTop = kiphoneXTopOffsetY + 44;
    self.emptyImage = [UIImage imageNamed:@"blankPage_networkError"];
    self.emptyTitle = ZFLocalizedString(@"EmptyCustomViewManager_refreshButton",nil);
    @weakify(self)
    [self showEmptyViewHandler:^{
        @strongify(self)
        ShowLoadingToView(self.view);
        [self requestDatas];
    }];
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context {
    if (object == self.scrollView) {
        CGPoint point=[((NSValue *)[self.scrollView valueForKey:@"contentOffset"]) CGPointValue];
        
        // 列：有3帖子的时候，scrollview 大小是4个， 添加一个滑动最小值触发
        if (point.x >= (self.scrollView.contentSize.width - KScreenWidth + 30) && self.noMoreMessageTipView.isHidden) {
            [self.view bringSubviewToFront:self.noMoreMessageTipView];
            [self.noMoreMessageTipView showTime:2 completion:^{
                
            }];
        }
    }
}

#pragma mark - WMPageControllerDelegate / WMPageControllerDatasource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.sourceReviewIDsArray.count;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    
    NSString *reviewID = self.sourceReviewIDsArray[index];
    NSString *title = index == 0 ? self.title : @"";
    ZFCommunityPostDetailPageItemVC *pageItemVC = [[ZFCommunityPostDetailPageItemVC alloc] initWithReviewID:reviewID title:title];
    pageItemVC.sourceType = self.sourceType;
    if (index == 0 && _viewModel) {
        [pageItemVC laodDefaultViewModel:_viewModel];
    }
    
    //获取垂直滚动偏移量
    @weakify(self)
    pageItemVC.contentOffsetBlock = ^(CGFloat offsetY) {
        @strongify(self)
        [self navigationBarAlpha:offsetY];
    };
    //是否可以横向滚动
    pageItemVC.canScrollBlock = ^(BOOL flag) {
        @strongify(self)
        self.scrollEnable = flag;
    };
    
    return pageItemVC;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    return CGRectMake(0, 0, KScreenWidth, KScreenHeight);
}

- (void)pageController:(WMPageController *)pageController willEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
}

- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    
    if (self.currentPostCtrl && self.currentPostCtrl != viewController) {
        [self.currentPostCtrl hideBottomView];
    }
    
    if (self.currentPostCtrl != viewController) {
        
        BOOL isStartFirstCtrl = self.currentPostCtrl ? NO : YES;
        
        self.currentPostCtrl = (ZFCommunityPostDetailPageItemVC *)viewController;
        ZFCommunityPostDetailViewModel *viewModel = self.currentPostCtrl.viewModel;
        
        //判断是否自己的帖子
        if (self.isMyTopic != viewModel.isMyTopic) {
            self.isMyTopic = viewModel.isMyTopic;
        }
        
        //重置导航栏状
        [self navigationBarAlpha:self.currentPostCtrl.currentOffsetY];
        [self changeCartNumAction];
        
        //处理初始的第一个控制器动画显示不太好
        if (isStartFirstCtrl) {
            [self.currentPostCtrl showBottomViewTime:0];
        } else {
            [self.currentPostCtrl showBottomViewTime:0.25];
            if (![ZFCommunityLikeGuideView isShowGuideView]) {
                [ZFCommunityLikeGuideView saveGuideView];
                [self.likeGuideView firstShowLikeGuideView:WINDOW];
            }
        }
    }
    
}

- (void)navigationBarAlpha:(CGFloat)offsetY {
    
    self.currentOffsetY = offsetY;
    
    CGFloat contentOffsetY  = offsetY;
    CGFloat navigationAlpha = 0.0;
    navigationAlpha = contentOffsetY > kZFCommunityPostDetailPageNavigationAnimationHeight ? 1.0 : contentOffsetY / kZFCommunityPostDetailPageNavigationAnimationHeight;
    navigationAlpha = MAX(navigationAlpha, 0.0);
    [self.navigaitonView setbackgroundAlpha:navigationAlpha];
}


#pragma mark <CartTip>

- (void)showCartTipView {

    BOOL isShowAddCartTip = [GetUserDefault(kZFCommunityPostDetailPageAddCartTip) boolValue];
    if (!_addCartTipView && !isShowAddCartTip) {
        
        SaveUserDefault(kZFCommunityPostDetailPageAddCartTip, @(YES));
        [self.view addSubview:self.addCartTipView];
        
        CGRect sourceFrame = [ZFTitleArrowTipView sourceViewFrameToWindow:self.bottomView.relationButton];
        CGFloat space = 14;
        [self.addCartTipView updateTipArrowOffset:CGRectGetWidth(sourceFrame) / 2.0 - space
                                           direct:[SystemConfigUtils isRightToLeftShow] ? ZFTitleArrowTipDirectDownLeft : ZFTitleArrowTipDirectDownRight
                                           cotent:nil];
        
        [self.addCartTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.view.mas_trailing).offset(-space);
            make.bottom.mas_equalTo(self.bottomView.relationButton.mas_top);
            make.width.mas_lessThanOrEqualTo(KScreenWidth - 24);
        }];
        [self.addCartTipView hideViewWithTime:4.5 complectBlock:nil];
    }
}

#pragma mark - Public Method



#pragma mark - Property Method

- (ZFCommunityPostDetailViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityPostDetailViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (NSMutableArray *)sourceReviewIDsArray {
    if (!_sourceReviewIDsArray) {
        _sourceReviewIDsArray = [[NSMutableArray alloc] init];
    }
    return _sourceReviewIDsArray;
}

- (ZFCommunityPostDetailNavigationView *)navigaitonView {
    if (!_navigaitonView) {
        _navigaitonView = [[ZFCommunityPostDetailNavigationView alloc] init];
        [_navigaitonView setbackgroundAlpha:0.0];
        @weakify(self)
        _navigaitonView.backItemHandle = ^{
            @strongify(self)
            [self backItemAction];
        };
    }
    return _navigaitonView;
}

- (void)setIsMyTopic:(BOOL)isMyTopic {
    _isMyTopic = isMyTopic;
    
    UIButton *cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cartButton setImage:[UIImage imageNamed:@"account_home_cart"] forState:UIControlStateNormal];
    [cartButton setImage:[UIImage imageNamed:@"account_home_cart"] forState:UIControlStateSelected];
    [cartButton addTarget:self action:@selector(jumpToCartAction) forControlEvents:UIControlEventTouchUpInside];
    cartButton.layer.cornerRadius = 18.0;
    cartButton.backgroundColor = ZFC0xFFFFFF_A(0.5);
    
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    [itemsArray addObject:cartButton];
    
    if (!isMyTopic) {
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton setImage:[UIImage imageNamed:@"GoodsDetail_shareIcon"] forState:UIControlStateNormal];
        [shareButton setImage:[UIImage imageNamed:@"GoodsDetail_shareIcon"] forState:UIControlStateSelected];
        [shareButton addTarget:self action:@selector(sharePostAction) forControlEvents:UIControlEventTouchUpInside];
        shareButton.layer.cornerRadius = 18.0;
        shareButton.backgroundColor = ZFC0xFFFFFF_A(0.5);
        
        [itemsArray addObject:shareButton];
        
    } else {
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton setImage:[UIImage imageNamed:@"GoodsDetail_shareIcon"] forState:UIControlStateNormal];
        [shareButton setImage:[UIImage imageNamed:@"GoodsDetail_shareIcon"] forState:UIControlStateSelected];
        [shareButton addTarget:self action:@selector(sharePostAction) forControlEvents:UIControlEventTouchUpInside];
        shareButton.layer.cornerRadius = 18.0;
        shareButton.backgroundColor = ZFC0xFFFFFF_A(0.5);
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setImage:[UIImage imageNamed:@"community_topicdetail_delete"] forState:UIControlStateNormal];
        [deleteButton setImage:[UIImage imageNamed:@"community_topicdetail_delete"] forState:UIControlStateSelected];
        [deleteButton addTarget:self action:@selector(deletePostAction) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.layer.cornerRadius = 18.0;
        deleteButton.backgroundColor = ZFC0xFFFFFF_A(0.5);
        
        [itemsArray addObject:shareButton];
        [itemsArray addObject:deleteButton];
    }
    [self.navigaitonView setRightItemButton:itemsArray cart:cartButton];
    [self changeCartNumAction];
}


- (ZFCommunityPostDetailBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[ZFCommunityPostDetailBottomView alloc] init];
        _bottomView.hidden = YES;
    }
    return _bottomView;
}


- (ZFTitleArrowTipView *)addCartTipView {
    if (!_addCartTipView) {
        _addCartTipView = [[ZFTitleArrowTipView alloc] initTipArrowOffset:-1 direct:-1 content:ZFLocalizedString(@"community_PostDetail_Buy_Guide", nil)];
    }
    return _addCartTipView;
}

- (ZFCommunityPostDetailGuideView *)swipeGuideView {
    if (!_swipeGuideView) {
        _swipeGuideView = [[ZFCommunityPostDetailGuideView alloc] initWithFrame:CGRectZero];
    }
    return _swipeGuideView;
}


- (ZFMessageTipView *)noMoreMessageTipView {
    if (!_noMoreMessageTipView) {
        _noMoreMessageTipView = [[ZFMessageTipView alloc] initMessage:ZFLocalizedString(@"community_post_detail_no_more_outfits", nil)
                                                                 font:ZFFontSystemSize(14)
                                                            textColor:ZFC0xFFFFFF()
                                                      backgroundColor:ZFC0x000000_05()
                                                               corner:0];
        _noMoreMessageTipView.hidden = YES;
    }
    return _noMoreMessageTipView;
}

- (UIView *)leftHoledSliderView {
    if (!_leftHoledSliderView) {
        _leftHoledSliderView = [[UIView alloc] init];
        _leftHoledSliderView.frame = CGRectMake(0, 0, 20, KScreenHeight - kiphoneXTopOffsetY - 44);
        _leftHoledSliderView.backgroundColor = [UIColor clearColor];
    }
    return _leftHoledSliderView;
}

- (ZFCommunityLikeGuideView *)likeGuideView {
    if (!_likeGuideView) {
        _likeGuideView = [[ZFCommunityLikeGuideView alloc] init];
    }
    return _likeGuideView;
}
@end
