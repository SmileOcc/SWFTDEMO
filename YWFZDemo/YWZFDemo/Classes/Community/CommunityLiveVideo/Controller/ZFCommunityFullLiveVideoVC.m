//
//  ZFCommunityFullLiveVideoVC.m
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityFullLiveVideoVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "IQKeyboardManager.h"
#import <Lottie/Lottie.h>

#import "Masonry.h"
#import "Constants.h"
#import "ZFInitViewProtocol.h"
#import "ZFFrameDefiner.h"
#import "YWCFunctionTool.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ZFNetworkManager.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIView+YYAdd.h"
#import "UIView+ZFViewCategorySet.h"

#import "ZFWebViewViewController.h"
#import "ZFCartViewController.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFUnlineSimilarViewController.h"
#import "ZFCommunityLiveVideoVC.h"
#import "ZFGoodsDetailReviewViewController.h"

#import "ZFCommunityLiveVideoContentView.h"
#import "ZFGoodsDetailSelectTypeView.h"
#import "ZFZegoPlayerView.h"
#import "ZFCommunityLiveWaitView.h"
#import "YSAlertView.h"

#import "ZFCommunityLiveViewModel.h"
#import "ZFCommunityGoodsInfosModel.h"
#import "ZFGoodsDetailViewModel.h"
#import "ZFCommunityLiveVideoGoodsModel.h"
#import "ZFBannerModel.h"
#import "BannerManager.h"
#import "ZFTimerManager.h"
#import "ZFThemeManager.h"
#import "ZFBranchAnalytics.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFGrowingIOAnalytics.h"

#import "UIImage+ZFExtended.h"
#import <YYWebImage/YYWebImage.h>


#import "ZFFullLiveNavBarView.h"
#import "ZFFullLiveLiveVideoChatView.h"
#import "ZFFullLiveSendMessageView.h"
#import "ZFZegoPlayerLiveVideoView.h"
#import "ZFFullLiveStateCoverView.h"
#import "ZFFullLiveErrorView.h"
#import "ZFFullLiveGoodsContentView.h"
#import "ZFFullLiveAnchorInfoView.h"
#import "ZFFullLiveCouponListView.h"
#import "ZFLiveVideoCommentListView.h"
#import "ZFLiveVideoPlayOperateView.h"
#import "ZFLiveVideoPlayView.h"
#import "ZFGoodsDetailAttributeSmallView.h"
#import "ZFFullLiveSwipeTipView.h"
#import "ZFVideoLiveGoodsAlertView.h"
#import "ZFVideoLiveCouponAlertView.h"

static CGFloat kZegoPlaySmallViewScale = 0.5625;

static CGFloat kTopBarViewHeight = 60;

@interface ZFCommunityFullLiveVideoVC ()<ZFInitViewProtocol,UIGestureRecognizerDelegate,ZFzegoPlayerLiveVideoDelegate,ZFGoodsDetailAttributeSmallViewDelegate>


@property (nonatomic, strong) ZFCommunityLiveViewModel         *liveViewModel;
@property (nonatomic, strong) ZFGoodsDetailViewModel           *goodsDetailViewModel;
/// 当前添加购物车的商品
@property (nonatomic, strong) ZFGoodsModel                     *currentAddCartGoodsModel;
/// 推荐弹窗商品
@property (nonatomic, strong) ZFCommunityVideoLiveGoodsModel   *alertLiveGoodsModel;
/// 推荐弹窗优惠券
@property (nonatomic, strong) ZFGoodsDetailCouponModel         *alertCouponModel;


/// 背景模糊图
@property (nonatomic, strong) UIImageView                      *blurryImageView;
/// 操作图层
@property (nonatomic, strong) UIView                           *operateView;
/// 顶部视图
@property (nonatomic, strong) ZFFullLiveNavBarView             *navBarView;
/// 关闭按钮
@property (nonatomic, strong) UIButton                         *closeButton;
/// 右上角商品按钮
@property (nonatomic, strong) UIButton                         *rightTopGoodsButton;
@property (nonatomic, strong) UIButton                         *playButton;

@property (nonatomic, strong) ZFLiveVideoPlayOperateView       *videoPlayOperateView;


/// 评论视图
@property (nonatomic, strong) ZFFullLiveLiveVideoChatView      *videoChatView;
/// 底部按钮视图
@property (nonatomic, strong) ZFFullLiveSendMessageView        *bottomOperateView;
/// 全屏按钮
@property (nonatomic, strong) UIButton                         *liveFullScreenButton;
/// 状态图层: 倒计时、离开、结束等
@property (nonatomic, strong) ZFFullLiveStateCoverView         *stateCoverView;
/// 播放错误图层：刷新、切换路线
@property (nonatomic, strong) ZFFullLiveErrorView              *errorView;

/// 推荐商品视图
@property (nonatomic, strong) ZFFullLiveGoodsContentView       *goodsCotentView;
/// 博主信息视图
@property (nonatomic, strong) ZFFullLiveAnchorInfoView         *anchorInfoView;
/// 优惠券视图
@property (nonatomic, strong) ZFFullLiveCouponListView         *couponListView;
/// 评论视图
@property (nonatomic, strong) ZFLiveVideoCommentListView       *commentListView;

/// 横屏时推荐商品列表
@property (nonatomic, strong) ZFCommunityLiveRecommendGoodsView *goodsLandscapeListView;
/// 横屏时商品属性加购视图
@property (nonatomic, strong) ZFGoodsDetailAttributeSmallView   *landscapeAttributeView;
/// 竖屏时商品属性加购视图
@property (nonatomic, strong) ZFGoodsDetailSelectTypeView       *attributeView;
/// 当前的显示的x属性视图
@property (nonatomic, strong) ZFGoodsAttributeBaseView          *currentAttribute;

/// 推荐商品弹窗
@property (nonatomic, strong) ZFVideoLiveGoodsAlertView         *goodsAlertView;
/// 推荐优惠券弹窗
@property (nonatomic, strong) ZFVideoLiveCouponAlertView        *couponAlertView;

@property (nonatomic,strong) LOTAnimationView                   *loadingAnimView;
@property (nonatomic, strong) UIActivityIndicatorView           *activityView;


/// 视频播放容器视图
@property (nonatomic, strong) UIView                           *videoContainerView;
/// 视频播放视图
@property (nonatomic, strong) ZFLiveVideoPlayView              *videoPlayView;
/// 视频播放截图
@property (nonatomic, strong) UIImageView                      *snapshotVideoImageView;
/// ZEGO直播载体视图
@property (nonatomic, strong) ZFZegoPlayerLiveVideoView        *zegoLiveVideoView;

/** 弹出输入视图*/
@property (nonatomic, strong) GZFInputTextView                 *inputTextView;

@property (nonatomic, strong) UIPanGestureRecognizer           *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer           *tapGesture;

/// 开始移动位置
@property (nonatomic, assign) CGFloat                          startPanX;
@property (nonatomic, assign) CGRect                           startMoveOperateFrame;

@property (nonatomic, assign) BOOL                             isCurrentVC;

/// 是否横屏
@property (nonatomic, assign) BOOL                             isLandscapeScreen;

/// 是否隐藏操作图层
@property (nonatomic, assign) BOOL                             isHideMoveOperateView;

/** 是否有历史评论数据*/
@property (nonatomic, assign) BOOL                             isZegoHistoryComment;
/// 是否显示到下一个界面
@property (nonatomic, assign) BOOL                             isNeedShowWindow;

@property (nonatomic, assign) BOOL                             isPlaying;


/// 测试消息推送
@property (nonatomic, assign) NSInteger testCount;



@end

@implementation ZFCommunityFullLiveVideoVC
@synthesize isStatusBarHidden = _isStatusBarHidden;

- (void)dealloc {
  
    if (_zegoLiveVideoView) {
        [_zegoLiveVideoView stopVideo];
        [_zegoLiveVideoView clearAllStream];
    }
    
    if (_stateCoverView) {
        [_stateCoverView stopTimer];
    }
    [[ZFVideoLiveCommentUtils sharedInstance] removeAllMessages];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)clearPlay {
    
    if (_zegoLiveVideoView) {
        [_zegoLiveVideoView stopVideo];
        [_zegoLiveVideoView clearAllStream];
    }
    
    if (_stateCoverView) {
        [_stateCoverView stopTimer];
    }
    [[ZFVideoLiveCommentUtils sharedInstance] removeAllMessages];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.fd_interactivePopDisabled = NO;
    
    self.isCurrentVC = YES;
    self.isStatusBarHidden = YES;
    self.isNeedShowWindow = NO;
    [self.videoPlayView dissmissFromWindow:YES];
    self.videoPlayView.backgroundColor = ZFCClearColor();
    
    if (!self.snapshotVideoImageView.isHidden) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.snapshotVideoImageView.hidden = YES;
        });
    }
    if (!ZFIsEmptyString(self.zegoLiveVideoView.roomID)) {
        [self startPlay];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_activityView && !self.activityView.isHidden) {
        self.attributeView.hidden = YES;
    }
    self.isStatusBarHidden = NO;
    self.isCurrentVC = NO;
    [self handleCurrentInterfaceOrientationPortrait];
    
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
    if (self.isNeedShowWindow && self.isPlaying && self.stateCoverView.isHidden) {
        self.snapshotVideoImageView.hidden = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.isNeedShowWindow && self.isPlaying && self.stateCoverView.isHidden) {
        [self showZegoPlayToWindow];
        self.videoPlayView.backgroundColor = ZFC0x000000();
    }
    self.isNeedShowWindow = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.isCurrentVC = YES;
    self.isStatusBarHidden = YES;
    
    [self zfInitView];
    [self addGestureRecognizer];
    [self addNotification];
    [self zfAutoLayoutView];
    
    // 与安卓统一，都获取
    if (self.videoModel) {
        self.liveID = ZFToString(self.videoModel.idx);
    }

    [self deletePreviousVCFromNavgation:[ZFCommunityFullLiveVideoVC class]];
    [self requestLiveDetailInfo:self.liveID];
    [self showSwipView];
    
}

#pragma mark - 隐藏时间栏
- (void)setIsStatusBarHidden:(BOOL)isStatusBarHidden {
    _isStatusBarHidden = isStatusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(BOOL)prefersStatusBarHidden {
    return self.isStatusBarHidden;
}

#pragma mark - 通知

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLikeNumsNotif:) name:kVideoLiveLikeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kChangeUserInfoNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liveOnlineCountChangeValue:) name:kVideoLiveOnlineCountNotification object:nil];

}

#pragma mark 手势

- (void)addGestureRecognizer {
    
    UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionPan:)];
    panGest.delegate = self;
    self.panGesture = panGest;
    [self.view addGestureRecognizer:panGest];
    
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
    tapGest.delegate = self;
    self.tapGesture = tapGest;
    [self.view addGestureRecognizer:tapGest];
}

- (void)zfInitView {
    
     UIColor *gradColor = [UIView bm_colorGradientChangeWithSize:self.view.size direction:IHGradientChangeDirectionVertical startColor:ColorHex_Alpha(0x524A5F, 1.0) endColor:ColorHex_Alpha(0x2E2B3F, 1.0)];
    self.view.backgroundColor = gradColor;
    
    [self.view addSubview:self.blurryImageView];
    [self.view addSubview:self.videoContainerView];
    [self.videoContainerView addSubview:self.videoPlayView];
    [self.videoContainerView addSubview:self.snapshotVideoImageView];
    [self.view addSubview:self.operateView];
    [self.view addSubview:self.videoPlayOperateView];
    [self.view addSubview:self.stateCoverView];
    [self.view addSubview:self.liveFullScreenButton];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.rightTopGoodsButton];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.goodsLandscapeListView];
    [self.view addSubview:self.goodsCotentView];
    [self.view addSubview:self.anchorInfoView];
    [self.view addSubview:self.couponListView];
    [self.view addSubview:self.commentListView];
    [self.view addSubview:self.attributeView];
    [self.view addSubview:self.landscapeAttributeView];
    
    [self.operateView addSubview:self.navBarView];
    [self.operateView addSubview:self.bottomOperateView];
    [self.operateView addSubview:self.videoChatView];
}

- (void)zfAutoLayoutView {
    [self.blurryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.videoContainerView);
    }];
    
    CGFloat minW = KScreenHeight > KScreenWidth ? KScreenWidth : KScreenHeight;
    [self.operateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(self.view);
        make.width.mas_equalTo(minW);
        make.bottom.mas_equalTo(self.view);
    }];
    
    [self.navBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.operateView);
        make.top.mas_equalTo(self.operateView.mas_top).offset(IPHONE_X_5_15 ? 20 : 0);
        make.height.mas_equalTo(kTopBarViewHeight);
    }];
    
    [self.bottomOperateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.operateView);
        make.bottom.mas_equalTo(self.operateView.mas_bottom).offset(-kiphoneXHomeBarHeight);
        make.height.mas_equalTo(60);
    }];
    
    [self.videoChatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.operateView.mas_leading).offset(12);
        make.width.mas_equalTo(KScreenWidth);
        make.height.mas_equalTo([self commentHeight]);
        make.bottom.mas_equalTo(self.bottomOperateView.mas_top);
    }];
    
    //zego：视频比例是16：9
    CGFloat zegoH = KScreenWidth * kZegoPlaySmallViewScale;
    if (self.videoModel && self.videoModel.isFull) {
        zegoH = MAX(KScreenWidth, KScreenHeight);
    }
    [self.videoContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.operateView.mas_top).offset([self videoTopSpace]);
        make.height.mas_equalTo(zegoH);
    }];
    
    [self.videoPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.videoContainerView);
    }];
    
    [self.snapshotVideoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.videoContainerView);
    }];
    
    [self.videoPlayOperateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.videoContainerView);
        make.bottom.mas_equalTo(self.videoContainerView.mas_bottom).offset(45);
        make.height.mas_equalTo(44);
    }];
    CGFloat navbSpace = (kTopBarViewHeight - 36) / 2.0;
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-16);
        make.top.mas_equalTo(self.operateView.mas_top).offset(IPHONE_X_5_15 ? (20 + navbSpace) : navbSpace);
    }];
    
    [self.rightTopGoodsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.operateView.mas_top).offset(IPHONE_X_5_15 ? (20 + navbSpace) : navbSpace);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-16);
    }];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.videoContainerView.mas_centerY);
        make.centerX.mas_equalTo(self.videoContainerView.mas_centerX);
    }];
    
    [self.goodsLandscapeListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.videoContainerView.mas_trailing);
        make.top.bottom.mas_equalTo(self.videoContainerView);
        make.width.mas_equalTo(300);
    }];
    
    [self.liveFullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.videoContainerView.mas_trailing).offset(-12);
        make.bottom.mas_equalTo(self.videoContainerView.mas_bottom).offset(-12);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
    
    [self.stateCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(15);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_lessThanOrEqualTo(230);
        make.height.mas_lessThanOrEqualTo(200);
    }];
    
    [self.goodsCotentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.anchorInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.couponListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.commentListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.landscapeAttributeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.videoContainerView.mas_trailing);
        make.top.bottom.mas_equalTo(self.videoContainerView);
        make.width.mas_equalTo(300);
    }];
    
    [self.attributeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - Request、直播提醒

- (void)showAgainRequestView {
    self.emptyImage = [UIImage imageNamed:@"blankPage_networkError"];
    self.emptyTitle = ZFLocalizedString(@"BlankPage_NetworkError_tipTitle",nil);
    self.edgeInsetTop = -TabBarHeight;
    @weakify(self)
    [self showEmptyViewHandler:^{
        @strongify(self)
        [self requestLiveDetailInfo:self.liveID];
    }];
    [self showTempBackButtonToFront:YES btnImage:[UIImage imageNamed:@"nav_arrow_left"]];
}

- (void)requestLiveDetailInfo:(NSString *)liveID {
        
    if (!self.loadingAnimView) {
        self.loadingAnimView = [LOTAnimationView animationNamed:@"ZZZZZ_loading_uploading"];
        self.loadingAnimView.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:self.loadingAnimView];
        
        [self.loadingAnimView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44, 44));
            make.centerX.mas_equalTo(self.view);
            make.centerY.mas_equalTo(self.view);
        }];
    }
    
    self.loadingAnimView.hidden = NO;
    [self.view bringSubviewToFront:self.loadingAnimView];
    
    [self.loadingAnimView stop];
    self.loadingAnimView.loopAnimation = YES;
    [self.loadingAnimView play];
    
    self.operateView.userInteractionEnabled = NO;
    
    @weakify(self);
    [self.liveViewModel requestCommunityLiveDetailLiveID:ZFToString(self.liveID) completion:^(ZFCommunityLiveListModel * _Nonnull liveModel) {
        @strongify(self);
        
        [self.loadingAnimView stop];
        self.loadingAnimView.hidden = YES;
        
        self.operateView.userInteractionEnabled = YES;
        HideLoadingFromView(self.view);
        if (liveModel) {
            self.videoModel = liveModel;
            [self loadVideoModel:self.videoModel];
            [self removeEmptyView];
            [self showTempBackButtonToFront:NO btnImage:nil];

        } else {
            [self showAgainRequestView];
        }
    }];
}

/// 设置提醒
- (void)requestLiveRemind {
    
    ShowLoadingToView(self.view);
    @weakify(self)
    self.stateCoverView.userInteractionEnabled = NO;
    [self.liveViewModel requestLiveRemind:@{@"liveID":ZFToString(self.liveID)} completion:^(BOOL success, NSString * _Nonnull msg) {
        @strongify(self);
        HideLoadingFromView(self.view);
        
        self.stateCoverView.userInteractionEnabled = YES;
        if (success) {
            self.stateCoverView.isRemind = success;
        }
        
        if (success) {
            ShowToastToViewWithText(nil, ZFLocalizedString(@"Live_5minutes_receive_push", nil));
        } else if(!ZFIsEmptyString(msg)) {
            ShowToastToViewWithText(nil, msg);
        }
    }];
    
}

/// 提醒状态
- (void)requestLiveRemindState {
    
    @weakify(self)
    [self.liveViewModel requestLiveRemindState:@{@"liveID":ZFToString(self.liveID)} completion:^(BOOL success, NSInteger status, NSString * _Nonnull msg) {
        @strongify(self);
        
        if (status == 1) {
            self.stateCoverView.isRemind = YES;
        } else {
            self.stateCoverView.isRemind = NO;
        }
    }];
}
#pragma mark 获取商品详情
/**
 获取商品详情
 */
- (void)requestGoodsDetailInfo:(NSString *)goodsId successBlock:(void(^)(GoodsDetailModel *goodsDetailInfo))successBlock{
    if (ZFIsEmptyString(goodsId)) {
        return;
    }
    NSDictionary *dict = @{@"manzeng_id"  : @"",
                           @"goods_id"    : ZFToString(goodsId)};
    
    ShowLoadingToView(self.view);
    if(!self.goodsDetailViewModel) {
        self.goodsDetailViewModel = [[ZFGoodsDetailViewModel alloc] init];
    }
    @weakify(self);
    [self.goodsDetailViewModel requestGoodsDetailData:dict completion:^(GoodsDetailModel *detaidlModel) {
        @strongify(self);
        HideLoadingFromView(self.view);
        
        if (detaidlModel.detailMainPortSuccess && [detaidlModel isKindOfClass:[GoodsDetailModel class]]) {
            if (successBlock) {
                successBlock(detaidlModel);
            }
        }
    } failure:^(NSError *error) {
        @strongify(self)
        HideLoadingFromView(self.view);
    }];
}

#pragma mark - 直播数据处理
- (void)loadVideoModel:(ZFCommunityLiveListModel *)videoModel {
    self.title = ZFToString(videoModel.title);

    
    if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
        self.stateCoverView.isThirdStream = YES;
    }
    
    [self requestLiveRemindState];

    // v5.6.0 不支持自动旋转
    [self configurateDeveiceLandscape];
    
    if (videoModel.isFull) {
        
        [self.videoContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.view);
            make.top.mas_equalTo(self.operateView.mas_top).offset([self videoTopSpace]);
            make.height.mas_equalTo(KScreenHeight);
        }];
        
        [self.videoChatView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([self commentHeight]);
        }];
        
    } else {
        //zego：视频比例是16：9
        CGFloat zegoH = KScreenWidth * kZegoPlaySmallViewScale;
        [self.videoContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.view);
            make.top.mas_equalTo(self.operateView.mas_top).offset([self videoTopSpace]);
            make.height.mas_equalTo(zegoH);
        }];
        
         [self.stateCoverView mas_remakeConstraints:^(MASConstraintMaker *make) {
             make.centerY.mas_equalTo(self.videoContainerView.mas_centerY);
             make.centerX.mas_equalTo(self.videoContainerView.mas_centerX);
             make.width.mas_lessThanOrEqualTo(230);
             make.height.mas_lessThanOrEqualTo(200);
        }];
        
        [self.videoChatView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([self commentHeight]);
        }];
    }

    self.goodsCotentView.videoModel = videoModel;
    [self.goodsCotentView cateName:@"" cateID:ZFToString(videoModel.live_code) skus:ZFToString(videoModel.skus)];
    self.couponListView.live_code = ZFToString(videoModel.live_code);
    
    [ZFVideoLiveCommentUtils sharedInstance].roomId = videoModel.room_id;
    [ZFVideoLiveCommentUtils sharedInstance].liveDetailID = videoModel.idx;
    [ZFVideoLiveCommentUtils sharedInstance].likeNums = [videoModel.like_num integerValue];
    [ZFVideoLiveCommentUtils sharedInstance].liveType = videoModel.type;
    [self updateLikeNums];
    
    if ([videoModel.type integerValue] == ZFCommunityLiveStateEnd) {//已结束
        self.stateCoverView.hidden = YES;
        [self platformPlay:videoModel];
        
    } else if ([videoModel.type integerValue] ==ZFCommunityLiveStateLiving) {//开始
        self.stateCoverView.hidden = YES;
        [self platformPlay:videoModel];
        
    } else if ([videoModel.type integerValue] == ZFCommunityLiveStateReady) {//待播

        if (![self isVideoPlay]) {
            
            self.stateCoverView.hidden = NO;
            ZFCommunityLiveWaitInfor *waitInforModel = [[ZFCommunityLiveWaitInfor alloc] init];
            waitInforModel.startTimerKey = [NSString stringWithFormat:@"%@_%@",@"liveVideo",videoModel.idx];
            waitInforModel.time = videoModel.time;
            waitInforModel.content = ZFLocalizedString(@"Community_LivesVideo_Host_No_Arrived_Msg", nil);
            self.stateCoverView.inforModel = waitInforModel;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadActivityTime) name:kTimerManagerUpdate object:nil];
        }
        
        if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {//
            
            if (![ZFNetworkManager isReachableViaWiFi] && ![AccountManager sharedManager].isNoWiFiPlay) { // WiFi自动播放,流量暂停
                
                NSString *message = ZFLocalizedString(@"Community_LivesVideo_No_Wifi_Play_Msg",nil);
                NSString *noTitle = ZFLocalizedString(@"Community_LivesVideo_No_Wifi_Play_Cancel",nil);
                NSString *yesTitle = ZFLocalizedString(@"Community_LivesVideo_No_Wifi_Play_OK",nil);
                
                ShowAlertView(nil, message, @[yesTitle], ^(NSInteger buttonIndex, id buttonTitle) {
                    [self firstStartPlayZegoPlayer:videoModel];
                    [AccountManager sharedManager].isNoWiFiPlay = YES;
                }, noTitle, ^(id cancelTitle) {
                });

            } else {
                [self firstStartPlayZegoPlayer:videoModel];
            }
        }
    }
    
    
    self.navBarView.userImageUrl = ZFToString(videoModel.anchor_headimg);
    self.navBarView.userName = ZFToString(videoModel.anchor_nickname);
    self.navBarView.eyeNums = [ZFToString(videoModel.view_num) integerValue] + [ZFToString(videoModel.virtual_view_num) integerValue];
    
    // 播主信息
    self.navBarView.isLiving = [videoModel.type integerValue] ==ZFCommunityLiveStateLiving ? YES : NO;
    if (ZFJudgeNSArray(self.videoModel.ios_hot) && self.videoModel.ios_hot.count > 0) {
        self.navBarView.isHotBanner = YES;
    } else {
        self.navBarView.isHotBanner = NO;
    }

    if ([videoModel.type integerValue] == ZFCommunityLiveStateReady) {
        self.navBarView.isHideUserInfo = YES;
    }
    
    //播放点击
    [self requestPlayStatistics];
    
    NSDictionary *params = @{ @"af_content_type": @"zmelive",
                              @"af_content_id" : ZFToString(videoModel.idx),
                              };
    [ZFAnalytics appsFlyerTrackEvent:@"af_view_zmelive" withValues:params];
}

- (void)firstStartPlayZegoPlayer:(ZFCommunityLiveListModel *)videoModel {

    self.zegoLiveVideoView.hidden = NO;
    self.zegoLiveVideoView.videoConterView = self.videoPlayView.playView;
    self.videoPlayView.sourceView = self.videoContainerView;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    self.videoModel.format_view_num = [formatter stringFromNumber:[NSNumber numberWithInteger:[self.videoModel.view_num integerValue]]];
    
    self.zegoLiveVideoView.lookNums = ZFToString(self.videoModel.format_view_num);
    [ZFVideoLiveCommentUtils sharedInstance].liveType = videoModel.type;
    self.zegoLiveVideoView.sourceVideoAddress = ZFToString(videoModel.live_replay_url);
    self.zegoLiveVideoView.videoDetailID = self.liveID;
    self.zegoLiveVideoView.roomID = ZFToString(self.videoModel.room_id);
    self.zegoLiveVideoView.thirdStreamID = ZFToString(self.videoModel.live_address);
    
    if ([self isVideoPlay]) {// 录播
        
        [self.zegoLiveVideoView configurationLiveType:ZegoBasePlayerTypeVideo firstStart:YES isFull:self.videoModel.isFull];
        [self baseVidoeHandle];
        
    } else {//直播
        
        if ([videoModel.type isEqualToString:@"1"]) {
            ZFCommunityLiveWaitInfor *waitInforModel = [[ZFCommunityLiveWaitInfor alloc] init];
            waitInforModel.startTimerKey = [NSString stringWithFormat:@"%@_%@",@"liveVideo",videoModel.idx];
            waitInforModel.time = videoModel.time;
            waitInforModel.content = ZFLocalizedString(@"Community_LivesVideo_Host_No_Arrived_Msg", nil);
            self.stateCoverView.inforModel = waitInforModel;
        }
        
        self.zegoLiveVideoView.roomID = ZFToString(self.videoModel.room_id);
        BOOL isLiveStart = [videoModel.type isEqualToString:@"1"] ? NO : YES;
        
        ZegoBasePlayerType playerType = ZegoBasePlayerTypeLiving;
        if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
            self.zegoLiveVideoView.streamID = @"";
            playerType = ZegoBasePlayerTypeThirdStream;
        }
        
        [self.zegoLiveVideoView configurationLiveType:playerType firstStart:isLiveStart isFull:self.videoModel.isFull];
        
        [self.bottomOperateView showCommentView:NO];
    }
}

- (void)platformPlay:(ZFCommunityLiveListModel *)videoModel {
    
    if (!self.activityView.superview) {
        [self.view addSubview:self.activityView];
        
        [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.videoContainerView.mas_centerX);
            make.centerY.mas_equalTo(self.videoContainerView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    }
    
    if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
        
        if (![ZFNetworkManager isReachableViaWiFi] && ![AccountManager sharedManager].isNoWiFiPlay) { // WiFi自动播放,流量暂停
            
            NSString *message = ZFLocalizedString(@"Community_LivesVideo_No_Wifi_Play_Msg",nil);
            NSString *noTitle = ZFLocalizedString(@"Community_LivesVideo_No_Wifi_Play_Cancel",nil);
            NSString *yesTitle = ZFLocalizedString(@"Community_LivesVideo_No_Wifi_Play_OK",nil);
            
            ShowAlertView(nil, message, @[yesTitle], ^(NSInteger buttonIndex, id buttonTitle) {
                [self firstStartPlayZegoPlayer:videoModel];
                [AccountManager sharedManager].isNoWiFiPlay = YES;
            }, noTitle, ^(id cancelTitle) {
            });

        } else {
            [self firstStartPlayZegoPlayer:videoModel];
        }
    }
}

- (void)startPlay {
    if (self.videoModel) {
        if(self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
            [self.zegoLiveVideoView startVideo];
        }
    }
}

- (void)pausePlay {
    if (self.videoModel) {
        if(self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
            [self.zegoLiveVideoView pauseVideo];
        }
    }
}
#pragma mark - 状态提示

- (void)handCoverState:(LiveZegoCoverState)coverState {
    
    YWLog(@"=========直播状态: %li",(long)coverState);
    
    // zego直播，不是第三方直播，可以显示切换线路
    if (coverState == LiveZegoCoverStateReConnectRoomFail) {
        self.stateCoverView.hidden = YES;
        [self showErrorView:YES];
        [self.errorView updateLiveCoverState:coverState];
        
    } else if(coverState == LiveZegoCoverStateUpdateStreamFail && self.videoModel.currentLivePlatform != ZFCommunityLivePlatformThirdStream) {
        
        self.stateCoverView.hidden = YES;
        [self showErrorView:YES];
        [self.errorView updateLiveCoverState:coverState];
    } else {
        if (_errorView) {
            [self showErrorView:NO];
        }
        [self.stateCoverView updateLiveCoverState:coverState];
        
        // 录播情况下
        if ([self isVideoPlay] && coverState != LiveZegoCoverStateEnd && coverState != LiveZegoCoverStateWillStart) {
            self.stateCoverView.hidden = YES;
        }
    }
    
    BOOL isLiving = NO;
    if (coverState == LiveZegoCoverStateWillStart) {
//        self.playButton.hidden = YES;
//        self.playButton.selected = YES;
        [self hideActivity];

    } else if (coverState == LiveZegoCoverStateLiving) {
//        self.playButton.hidden = YES;
//        self.playButton.selected = YES;
        isLiving = YES;
        
    } else if(coverState == LiveZegoCoverStatePlay) {
//        self.playButton.hidden = YES;
//        self.playButton.selected = YES;

    } else if(coverState == LiveZegoCoverStateJustLive) {
        [self hideActivity];

    } else if(coverState == LiveZegoCoverStateEnd) {
        
        [self hideActivity];

//        self.playButton.hidden = YES;
//        self.playButton.selected = YES;
        
    } else if(coverState == LiveZegoCoverStateEndRefresh) {
        self.stateCoverView.hidden = YES;
//        self.playButton.hidden = YES;
//        self.playButton.selected = YES;
        [self hideActivity];
    }
    
    if (coverState != LiveZegoCoverStateWillStart && self.navBarView.isHideUserInfo) {
        self.navBarView.isHideUserInfo = NO;
    }
    self.navBarView.isLiving = isLiving;
}

- (void)hideActivity{
    if (_activityView && !_activityView.isHidden) {
        self.activityView.hidden = YES;
    }
}

#pragma mark - ZFzegoPlayerLiveVideoDelegate

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView isPlaying:(BOOL)isPlaying {
    self.isPlaying = isPlaying;
    if (self.isPlaying) {
        [self.videoPlayView hidePreviewView];
    } else {
        [self.videoPlayView hidePreviewView];
    }
    
    if ([self isVideoPlay]) {
        if (!isPlaying) {
            [self hideActivity];
        }
    } else {
        if (_activityView && !self.activityView.isHidden) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self hideActivity];
            });
        }
    }

    if (_errorView && !_errorView.isHidden) {
        [self.errorView endLoading:isPlaying];
    }
}
- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView updateLiveCoverState:(LiveZegoCoverState)coverState {
    [self handCoverState:coverState];
}

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView startPlayingStream:(BOOL)state {
    
    if (_errorView && !_errorView.isHidden) {
        [self.errorView endLoading:state];
    }
}

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)operateView showCouponAlertView:(ZFGoodsDetailCouponModel *)couponModel {
    [self showCouponAlertView:couponModel];
}

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)operateView showRecommendGoods:(ZFCommunityVideoLiveGoodsModel *)goodsModel {
    self.goodsCotentView.currentRecommendGoodsId = goodsModel.goods_id;
    [self showGoodsAlertView:goodsModel];
}

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView videoProgress:(NSString *)current max:(NSString *)max isEnd:(BOOL)isEnd {
    
    [self.videoPlayOperateView startTime:current endTime:max isEnd:isEnd];
    
    if (self.videoPlayOperateView.isHidden && self.videoPlayView.videoPorgressLineView.isHidden) {
        [self.videoPlayView showProgressLine:YES];
    } else if(!self.videoPlayOperateView.isHidden && !self.videoPlayView.videoPorgressLineView.isHidden) {
        [self.videoPlayView showProgressLine:NO];
    }
    
    CGFloat maxf = [max floatValue];
    CGFloat currentf = [current floatValue];
    if (maxf > 0) {
        [self.videoPlayView updateProgress:currentf / maxf];
        
        if (_activityView && !self.activityView.isHidden && currentf > 0) {
            [self.activityView stopAnimating];
        }
    }
}

#pragma mark - Action

/// 真正的关闭，事件处理
- (void)currrentGoBackAction {
    if (!self.snapshotVideoImageView.isHidden) {
        self.snapshotVideoImageView.hidden = YES;
    }
    self.blurryImageView.hidden = YES;
    [self clearPlay];
    [self goBackAction];
}

- (void)actionClose:(UIButton *)sender {
    [self currrentGoBackAction];
}

- (void)actionPlay:(UIButton *)sender {

    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self startPlay];
    } else {
        [self pausePlay];
    }
}

- (void)actionFullScreen:(UIButton *)sender {
    if (self.isLandscapeScreen) {
        [self handleCurrentInterfaceOrientationPortrait];
    } else {
        [self handleCurrentInterfaceOrientationLandscape];
    }
}

- (void)actionLandscapeGoods:(UIButton *)sender {
    sender.enabled = NO;
    if (self.goodsLandscapeListView.isHidden) {
        [self showLandscapeGoodsView:YES];
    } else {
        [self showLandscapeGoodsView:NO];
    }
}

- (void)sendCommentMsg:(NSString *)contentMsg {
    if (!ZFIsEmptyString(contentMsg)) {
        [self.view endEditing:YES];
                
        ShowLoadingToView(self);
        
        NSString *phase = [ZFVideoLiveCommentUtils sharedInstance].isLoginRoom ? @"1" : @"0";
        NSString *nickName = [ZFVideoLiveCommentUtils sharedInstance].nickName;

        
        @weakify(self)
        [self.liveViewModel requestCommunityLiveCommentLiveID:[ZFVideoLiveCommentUtils sharedInstance].liveDetailID liveType:[ZFVideoLiveCommentUtils sharedInstance].isLoginRoom ? @"1" : @"0" content:contentMsg nickname:ZFToString(nickName) phase:phase completion:^(BOOL success, NSString *msg) {
            @strongify(self)
            HideLoadingFromView(self);

            if (success) {
                YWLog(@"---- 直播评论成功");

                /// 未登录时，自己添加
                if (![ZFVideoLiveCommentUtils sharedInstance].isLoginRoom) {
                    ZFZegoMessageInfo *message = [[ZFZegoMessageInfo alloc] init];
                    message.type = @"4";
                    message.nickname = ZFToString([AccountManager sharedManager].account.nickname);
                    message.content = ZFToString(contentMsg);
                    [[ZFVideoLiveCommentUtils sharedInstance] addMessage:message];
                    
                }
                
                [ZFVideoLiveCommentUtils sharedInstance].inputText = @"";
                [self.bottomOperateView updateCommentContnet:@""];
                ShowToastToViewWithText(self, ZFLocalizedString(@"Success", nil));

            } else {
                ShowToastToViewWithText(self, msg);
            }
            
        }];
    }
}

- (void)updateCommentContnet:(NSString *)text {
    [self.bottomOperateView updateCommentContnet:text];
}


- (void)actionLike:(UIButton *)sender {
    [self.view endEditing:YES];
    
    [sender.imageView.layer addAnimation:[sender.imageView zfAnimationFavouriteScaleMax:1.1] forKey:@"Liked"];
    
    @weakify(self)
    [self checkDeviceIsLandscape:^{
        @strongify(self)
        [self liveLikeEvent];
    }];
}

- (void)liveLikeEvent {
    
    //没有登录，自己加动画，登录情况下，点赞成，直播会收到点赞消息，然后显示动画
    if (![ZFVideoLiveCommentUtils sharedInstance].isLoginRoom) {
        //点赞
        [self.videoChatView.likeView doLikeAnimation];
        self.bottomOperateView.likeNums++;
        
    }
    
    NSString *phase = [[ZFVideoLiveCommentUtils sharedInstance].liveType isEqualToString:@"2"] ? @"1" : @"0";
    NSString *nickName = [ZFVideoLiveCommentUtils sharedInstance].nickName;
    //写死为1 不然测试没及时数据
    phase = @"1";
    
    [self.liveViewModel requestCommunityLiveLikeLiveID:[ZFVideoLiveCommentUtils sharedInstance].liveDetailID liveType:[ZFVideoLiveCommentUtils sharedInstance].isLoginRoom ? @"1" : @"0" nickname:ZFToString(nickName) phase:phase completion:^(ZFCommunityLiveZegoLikeModel *likeModel) {
        
        if (![ZFVideoLiveCommentUtils sharedInstance].isLoginRoom) {
            if ([likeModel.like_num integerValue] > 0) {
                [ZFVideoLiveCommentUtils sharedInstance].likeNums = [likeModel.like_num integerValue];
                [[ZFVideoLiveCommentUtils sharedInstance] refreshLikeNumsAnimate:NO];
            }
        }
    }];
}

#pragma mark - Property Method

- (void)setIsZegoHistoryComment:(BOOL)isZegoHistoryComment {
    _isZegoHistoryComment = isZegoHistoryComment;
    
    if (isZegoHistoryComment) {
        [self.videoChatView addHeaderRefreshKit:YES];
    } else {
        [self.videoChatView addHeaderRefreshKit:NO];
    }
}

- (void)setIsNeedShowWindow:(BOOL)isNeedShowWindow {
    _isNeedShowWindow = isNeedShowWindow;
    if (isNeedShowWindow && self.isPlaying && self.stateCoverView.isHidden) {
        [self updateTempImage];
    }
}
- (ZFCommunityLiveViewModel *)liveViewModel {
    if (!_liveViewModel) {
        _liveViewModel = [[ZFCommunityLiveViewModel alloc] init];
    }
    return _liveViewModel;
}

- (void)setCoverImage:(UIImage *)coverImage {
    _coverImage = [UIImage zf_blurryImage:coverImage withBlurLevel:30];
    if (_coverImage) {
        self.blurryImageView.image = _coverImage;
    }
}
- (UIImageView *)blurryImageView {
    if (!_blurryImageView) {
        _blurryImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _blurryImageView.contentMode = UIViewContentModeScaleAspectFill;
        _blurryImageView.layer.masksToBounds = YES;
    }
    return _blurryImageView;
}

- (ZFFullLiveNavBarView *)navBarView {
    if (!_navBarView) {
        _navBarView = [[ZFFullLiveNavBarView alloc] initWithFrame:CGRectZero];
        _navBarView.eyeNums = 0;
        @weakify(self)
        _navBarView.actionBlock = ^{
           @strongify(self)
            if (self.isLandscapeScreen) {
                [self handleCurrentInterfaceOrientationPortrait];
            } else {
                [self currrentGoBackAction];
            }
        };
        
        _navBarView.actionUserBlock = ^{
            @strongify(self)
            [self showAnchorInfoView:YES];
        };
        
        _navBarView.actionGoodsBlock = ^{
            @strongify(self)
        };
    }
    return _navBarView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:[UIImage imageNamed:@"live_close"] forState:UIControlStateNormal];
    }
    return _closeButton;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton addTarget:self action:@selector(actionPlay:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setImage:[UIImage imageNamed:@"live_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"live_stop"] forState:UIControlStateSelected];
        _playButton.hidden = YES;
    }
    return _playButton;
}

- (UIButton *)rightTopGoodsButton {
    if (!_rightTopGoodsButton) {
        _rightTopGoodsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightTopGoodsButton setImage:[UIImage imageNamed:@"double_arrow"] forState:UIControlStateNormal];
        [_rightTopGoodsButton setTitle:ZFLocalizedString(@"Community_Lives_Live_Goods", nil) forState:UIControlStateNormal];
        [_rightTopGoodsButton zfLayoutStyle:ZFButtonEdgeInsetsStyleLeft imageTitleSpace:2];
        [_rightTopGoodsButton addTarget:self action:@selector(actionLandscapeGoods:) forControlEvents:UIControlEventTouchUpInside];
        [_rightTopGoodsButton convertUIWithARLanguage];
        _rightTopGoodsButton.hidden = YES;
    }
    return _rightTopGoodsButton;
}

- (UIView *)operateView {
    if (!_operateView) {
        _operateView = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    return _operateView;
}

- (ZFFullLiveLiveVideoChatView *)videoChatView {
    if (!_videoChatView) {
        _videoChatView = [[ZFFullLiveLiveVideoChatView alloc] initWithFrame:CGRectZero];
    }
    return _videoChatView;
}

- (UIView *)videoContainerView {
    if (!_videoContainerView) {
        _videoContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _videoContainerView;
}

- (ZFLiveVideoPlayView *)videoPlayView {
    if (!_videoPlayView) {
        _videoPlayView = [[ZFLiveVideoPlayView alloc] initWithFrame:CGRectZero];
        
        @weakify(self)
        _videoPlayView.dismissWindowBlock = ^{
            
        };
        
        _videoPlayView.showWindowBlock = ^{
            
        };
        
        _videoPlayView.stopPlayBlock = ^{
          @strongify(self)
            [self pausePlay];
        };
        
        _videoPlayView.tapBlock = ^{
            @strongify(self)
            [self handTapEvent];
        };
    }
    return _videoPlayView;
}

- (UIButton *)liveFullScreenButton {
    if (!_liveFullScreenButton) {
        _liveFullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _liveFullScreenButton.backgroundColor = ZFC0x000000_A(0.2);
//        _liveFullScreenButton.layer.cornerRadius = 18.0;
//        _liveFullScreenButton.layer.masksToBounds = YES;
        [_liveFullScreenButton setImage:[UIImage imageNamed:@"live_full_expand"] forState:UIControlStateNormal];
        [_liveFullScreenButton addTarget:self action:@selector(actionFullScreen:) forControlEvents:UIControlEventTouchUpInside];
        _liveFullScreenButton.hidden = YES;
    }
    return _liveFullScreenButton;
}

- (ZFFullLiveSendMessageView *)bottomOperateView {
    if (!_bottomOperateView) {
        _bottomOperateView = [[ZFFullLiveSendMessageView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _bottomOperateView.goodsBlock = ^{
            @strongify(self)
            [self showGoodsContentView:YES];
        };
        
        _bottomOperateView.couponBlock = ^{
            @strongify(self)
            [self showCouponList:YES];
        };
        
        _bottomOperateView.commentBlock = ^{
            @strongify(self)
            [self showCommentList:YES];
        };
        
        _bottomOperateView.likeBlock = ^{
            @strongify(self)
            
            [self.view endEditing:YES];
            
             @weakify(self)
            [self checkDeviceIsLandscape:^{
                 @strongify(self)
                [self liveLikeEvent];
            }];
        };
        
        _bottomOperateView.textBlock = ^{
            @strongify(self)
            
            @weakify(self)
            [self checkDeviceIsLandscape:^{
                 @strongify(self)
                self.inputTextView.textView.text = ZFToString([ZFVideoLiveCommentUtils sharedInstance].inputText);
                [self.inputTextView showTextView];
                self.panGesture.enabled = NO;
            }];
        };
        
        _bottomOperateView.expandBlock = ^(BOOL isShow) {
            @strongify(self)
            self.videoChatView.hidden = !isShow;
        };
    }
    return _bottomOperateView;
}

- (ZFZegoPlayerLiveVideoView *)zegoLiveVideoView {
    if (!_zegoLiveVideoView) {
        _zegoLiveVideoView = [[ZFZegoPlayerLiveVideoView alloc] initWithFrame:CGRectZero];
        _zegoLiveVideoView.backgroundColor = ZFRandomColor();
        _zegoLiveVideoView.delegate = self;
        
        @weakify(self)
        _zegoLiveVideoView.livePlayingBlock = ^(BOOL playing) {
            @strongify(self)
            self.isZegoHistoryComment = NO;
        };
    }
    return _zegoLiveVideoView;
}


- (ZFLiveVideoPlayOperateView *)videoPlayOperateView {
    if (!_videoPlayOperateView) {
        _videoPlayOperateView = [[ZFLiveVideoPlayOperateView alloc] initWithFrame:CGRectZero];
        _videoPlayOperateView.hidden = YES;
        
        @weakify(self)
        _videoPlayOperateView.playStateBlock = ^(BOOL isPlay) {
           @strongify(self)
            if (isPlay) {
                [self startPlay];
            } else {
                [self pausePlay];
            }
        };
        
        _videoPlayOperateView.fullPlayBlock = ^(BOOL isFull) {
            @strongify(self)
            if (isFull) {
                [self handleCurrentInterfaceOrientationLandscape];
            } else {
                [self handleCurrentInterfaceOrientationPortrait];
            }
        };
        
        _videoPlayOperateView.sliderValueBlock = ^(CGFloat value) {
            @strongify(self)
            [self.zegoLiveVideoView baseSeekToSecondsPlayVideo:value];
        };
        
        _videoPlayOperateView.autoHideBlock = ^{
            @strongify(self)
            [self.videoPlayView showProgressLine:YES];
        };
    }
    return _videoPlayOperateView;
}

- (GZFInputTextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[GZFInputTextView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _inputTextView.texeEditBlock = ^(NSString *text) {
            @strongify(self)
            [self updateCommentContnet:text];
        };
        
        _inputTextView.sendTextBlock = ^(NSString * _Nonnull text) {
            @strongify(self)
            [self sendCommentMsg:text];
        };
        
        _inputTextView.textEndBlock = ^{
            @strongify(self)
            self.panGesture.enabled = YES;
        };
    }
    return _inputTextView;
}

#pragma mark - 弹出视图

- (UIImageView *)snapshotVideoImageView {
    if (!_snapshotVideoImageView) {
        _snapshotVideoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _snapshotVideoImageView;
}

- (ZFFullLiveStateCoverView *)stateCoverView {
    if (!_stateCoverView) {
        _stateCoverView = [[ZFFullLiveStateCoverView alloc] initWithFrame:CGRectZero];
        _stateCoverView.hidden = YES;
        _stateCoverView.commentView = self.videoChatView.messageListView;
        
        @weakify(self)
        _stateCoverView.backBlock = ^{
            @strongify(self)
            [self currrentGoBackAction];
        };
        
        _stateCoverView.remindBlock = ^{
            @strongify(self)
            [self requestLiveRemind];
        };
        
        _stateCoverView.waitTimeBlock = ^(BOOL waiting) {
            @strongify(self)
            
            if (waiting) {
                
                CGFloat max = KScreenHeight > KScreenWidth ? KScreenHeight : KScreenWidth;
            
                CGFloat bottomH = CGRectGetHeight(self.bottomOperateView.frame);
                CGFloat coverMaxY = CGRectGetMaxY(self.stateCoverView.frame);
                max = max - coverMaxY - bottomH;
                
                if (self.isLandscapeScreen) {
                    max = [self commentHeight];
                }
                CGFloat h = CGRectGetHeight(self.videoChatView.frame);
                if (h != max) {
                    
                    [self.videoChatView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(max);
                    }];
                }
                
            } else {
                
                CGFloat commentH = [self commentHeight];
                CGFloat h = CGRectGetHeight(self.videoChatView.frame);
                
                if (h != commentH) {
                    [self.videoChatView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo([self commentHeight]);
                    }];
                }
            }
            [self.view layoutIfNeeded];
            
        };
    }
    return _stateCoverView;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        activityView.color = [UIColor whiteColor];
        [activityView hidesWhenStopped];
        [activityView startAnimating];
        _activityView = activityView;
    }
    return _activityView;
}

- (ZFGoodsDetailAttributeSmallView *)landscapeAttributeView {
    if (!_landscapeAttributeView) {
        _landscapeAttributeView = [[ZFGoodsDetailAttributeSmallView alloc] initWithFrame:CGRectZero showCart:YES alpha:0.1];
        _landscapeAttributeView.delegate = self;
        _landscapeAttributeView.hidden = YES;
        _landscapeAttributeView.chooseNumebr = 1;
    }
    return _landscapeAttributeView;
}

- (ZFFullLiveErrorView *)errorView {
    if (!_errorView) {
        _errorView = [[ZFFullLiveErrorView alloc] initWithFrame:CGRectZero];
        
        @weakify(self)
        _errorView.closeBlock = ^{
            @strongify(self)
            [self currrentGoBackAction];
        };
        
        _errorView.refreshBlock = ^{
            @strongify(self)
            [self startPlay];
        };
        
        _errorView.changeRoteBlock = ^(ZFCommunityLiveRouteModel * _Nonnull roteModel) {
            @strongify(self)
            [self changeLiveLineRoute:roteModel];
        };
    }
    return _errorView;
}

- (ZFFullLiveGoodsContentView *)goodsCotentView {
    if (!_goodsCotentView) {
        _goodsCotentView = [[ZFFullLiveGoodsContentView alloc] initWithFrame:CGRectZero];
        _goodsCotentView.hidden = YES;
        @weakify(self)
        _goodsCotentView.closeBlock = ^{
            @strongify(self)
            [self showGoodsContentView:NO];
        };
        
        _goodsCotentView.selectBlock = ^(ZFGoodsModel * _Nonnull goodModel) {
            @strongify(self)
            [self jumpToGoodsDetail:goodModel];
        };
        
        _goodsCotentView.cartGoodsBlock = ^(ZFGoodsModel * _Nonnull goodModel) {
            @strongify(self)
            [self addCartGoods:goodModel attributeView:self.attributeView];
        };
        
        _goodsCotentView.similarGoodsBlock = ^(ZFGoodsModel * _Nonnull goodModel) {
           @strongify(self)
            [self jumpToSimilar:goodModel];
        };
        
        _goodsCotentView.cartBlock = ^{
            @strongify(self)
            [self jumpToCartAction];
        };
        
        _goodsCotentView.commentListBlock = ^(GoodsDetailModel * _Nonnull goodDetailModel) {
  
            @strongify(self)
            [self jumpReviewListDetail:goodDetailModel];
        };
        
        _goodsCotentView.goodsGuideSizeBlock = ^(NSString * _Nonnull sizeUrl) {
            @strongify(self)
            [self openWebInfoWithUrl:self.attributeView.model.size_url title:ZFLocalizedString(@"Detail_Product_SizeGuides",nil)];
        };
    }
    return _goodsCotentView;
}

- (ZFFullLiveAnchorInfoView *)anchorInfoView {
    if (!_anchorInfoView) {
        _anchorInfoView = [[ZFFullLiveAnchorInfoView alloc] initWithFrame:CGRectZero];
        _anchorInfoView.hidden = YES;
        
        @weakify(self)
        _anchorInfoView.closeBlock = ^{
            @strongify(self)
            [self showAnchorInfoView:NO];
        };
        
        _anchorInfoView.liveVideoBlock = ^(NSString * _Nonnull deeplink) {
            @strongify(self)
            [self openWebInfoWithUrl:deeplink title:@""];
        };
    }
    return _anchorInfoView;
}

- (ZFFullLiveCouponListView *)couponListView {
    if (!_couponListView) {
        _couponListView = [[ZFFullLiveCouponListView alloc] initWithFrame:CGRectZero];
        _couponListView.hidden = YES;
        @weakify(self)
        _couponListView.closeBlock = ^{
          @strongify(self)
            [self showCouponList:NO];
        };
        
        _couponListView.selectCouponBlock = ^(ZFGoodsDetailCouponModel * _Nonnull couponModel) {
            @strongify(self)
            
            /// 直播中、开始以后，可以领取
            if (self.isPlaying || [self.videoModel.type integerValue] != 1) {
                @weakify(self)
                [self receiveCoupon:couponModel completion:^(ZFGoodsDetailCouponModel *model) {
                    @strongify(self)
                    [self.couponListView updateDatas:model];
                }];
            } else {
                ShowToastToViewWithText(self.view, ZFLocalizedString(@"Live_claim_time_after_to_get", nil));
            }
            
        };
    }
    return _couponListView;
}

- (ZFLiveVideoCommentListView *)commentListView {
    if (!_commentListView) {
        _commentListView = [[ZFLiveVideoCommentListView alloc] initWithFrame:CGRectZero];
        _commentListView.hidden = YES;
        
        @weakify(self)
        _commentListView.closeBlock = ^{
            @strongify(self)
            [self showCommentList:NO];
        };
    }
    return _commentListView;
}

- (ZFCommunityLiveRecommendGoodsView *)goodsLandscapeListView {
    if (!_goodsLandscapeListView) {
        _goodsLandscapeListView = [[ZFCommunityLiveRecommendGoodsView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _goodsLandscapeListView.recommendGoodsBlock = ^(ZFGoodsModel * _Nonnull goodsModel) {
            @strongify(self)
            [self jumpToGoodsDetail:goodsModel];
        };
        
        _goodsLandscapeListView.addCartBlock = ^(ZFGoodsModel * _Nonnull goodsModel) {
            @strongify(self)
            [self addCartGoods:goodsModel attributeView:self.landscapeAttributeView];
        };
        
        _goodsLandscapeListView.similarGoodsBlock = ^(ZFGoodsModel * _Nonnull goodsModel) {
            @strongify(self)
            [self jumpToSimilar:goodsModel];
        };
        
        _goodsLandscapeListView.closeBlock = ^(BOOL flag) {
            @strongify(self)
            [self showLandscapeGoodsView:NO];
        };
        _goodsLandscapeListView.hidden = YES;
    }
    return _goodsLandscapeListView;
}

- (ZFGoodsDetailSelectTypeView *)attributeView {
    if (!_attributeView) {
        NSString *bagTitle = ZFLocalizedString(@"Detail_Product_AddToBag", nil);
        _attributeView = [[ZFGoodsDetailSelectTypeView alloc] initSelectSizeView:YES bottomBtnTitle:bagTitle];
        _attributeView.hidden = YES;
        @weakify(self);
        _attributeView.openOrCloseBlock = ^(BOOL isOpen) {
            @strongify(self);
            [self.attributeView bottomCartViewEnable:YES];
        };
        
        _attributeView.goodsDetailSelectTypeBlock = ^(NSString *goodsId) {
            @strongify(self);
            [self changeGoodsAttribute:goodsId];
        };
        
        _attributeView.goodsDetailSelectSizeGuideBlock = ^(NSString *url){
            @strongify(self);
            [self openWebInfoWithUrl:self.attributeView.model.size_url title:ZFLocalizedString(@"Detail_Product_SizeGuides",nil)];
        };
        
        _attributeView.addCartBlock = ^(NSString *goodsId, NSInteger count) {
            @strongify(self);
            [self.attributeView bottomCartViewEnable:NO];
            [self addGoodsToCartOption:ZFToString(goodsId) goodsCount:count];
        };
        
        _attributeView.cartBlock = ^{
            @strongify(self)
            [self jumpToCartAction];
            
        };
    }
    return _attributeView;
}



#pragma mark - 跳转

/// 进入购物车
- (void)jumpToCartAction {
    self.isNeedShowWindow = YES;
    ZFCartViewController *cartVC = [[ZFCartViewController alloc] init];
    [self.navigationController pushViewController:cartVC animated:YES];
}

/// 找相似
- (void)jumpToSimilar:(ZFGoodsModel *)goodsModel {
    self.isNeedShowWindow = YES;
    ZFUnlineSimilarViewController *unlineSimilarViewController = [[ZFUnlineSimilarViewController alloc] initWithImageURL:goodsModel.wp_image sku:goodsModel.goods_sn];
    unlineSimilarViewController.sourceType = ZFAppsflyerInSourceTypeSearchImageitems;
    [self.navigationController pushViewController:unlineSimilarViewController animated:YES];
}

/// 商品详情
- (void)jumpToGoodsDetail:(ZFGoodsModel *)goodsModel {
    
    self.isStatusBarHidden = NO;
    self.isNeedShowWindow = YES;
    ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
    detailVC.goodsId    = goodsModel.goods_id;
    detailVC.sourceType = ZFAppsflyerInSourceTypeZMeLiveDetail;
    detailVC.sourceID = ZFToString(self.liveID);
    [self.navigationController pushViewController:detailVC animated:YES];
    
    // appflyer统计
    NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsModel.goods_sn),
                                      @"af_spu_id" : ZFToString(goodsModel.goods_spu),
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"community_live",    // 当前页面名称
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
    
    [ZFGrowingIOAnalytics ZFGrowingIOProductClick:goodsModel page:@"社区直播" sourceParams:@{
        GIOGoodsTypeEvar : GIOGoodsTypeOther,
        GIOGoodsNameEvar : [NSString stringWithFormat:@"zme_live_%@", self.liveID]
    }];
}

/// 评论列表
- (void)jumpReviewListDetail:(GoodsDetailModel *)model {
    
    self.isNeedShowWindow = YES;
    ZFGoodsDetailReviewViewController *reviewVC = [[ZFGoodsDetailReviewViewController alloc] init];
    reviewVC.goodsId = ZFToString(model.goods_id);
    reviewVC.goodsSn = ZFToString(model.goods_sn);
    [self.navigationController pushViewController:reviewVC animated:YES];
}

/// 切换路线
- (void)changeLiveLineRoute:(ZFCommunityLiveRouteModel *)routeModel {
    
    [self clearPlay];
    
    if ([routeModel.live_platform isEqualToString:@"1"] || [routeModel.live_platform isEqualToString:@"2"]) {
        //跳转到视频直播播放
        ZFCommunityLiveVideoVC *liveVideoVC = [[ZFCommunityLiveVideoVC alloc] init];
        liveVideoVC.liveID = ZFToString(routeModel.idx);
        [self.navigationController pushViewController:liveVideoVC animated:NO];
        
    } else if([routeModel.live_platform isEqualToString:@"3"] || [routeModel.live_platform isEqualToString:@"4"]) {
                   
        ZFCommunityFullLiveVideoVC *fullLiveVC = [[ZFCommunityFullLiveVideoVC alloc] init];
        fullLiveVC.liveID = ZFToString(routeModel.idx);
        [self.navigationController pushViewController:fullLiveVC animated:NO];
    }
}

- (void)openWebInfoWithUrl:(NSString *)url title:(NSString *)title {
    self.isNeedShowWindow = YES;
    if ([url hasPrefix:@"ZZZZZ:"]) {
        ZFBannerModel *model = [[ZFBannerModel alloc] init];
        model.deeplink_uri = url;
        [BannerManager doBannerActionTarget:self withBannerModel:model];
    }else{
        ZFWebViewViewController *webVC = [[ZFWebViewViewController alloc] init];
        webVC.link_url = url;
        webVC.title = title;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

// 加购商品按钮触发
- (void)addCartGoods:(ZFGoodsModel *)goodsModel attributeView:(ZFGoodsAttributeBaseView *)attributeView{
    
    self.currentAttribute = attributeView;
    
    if (attributeView) {
        if (attributeView.superview) {
            [attributeView.superview bringSubviewToFront:attributeView];
        }
        
        self.currentAddCartGoodsModel = goodsModel;
        //获取商品详情接口
        @weakify(self)
        NSString *goosID = ZFToString(goodsModel.goods_id);
        [self requestGoodsDetailInfo:goosID successBlock:^(GoodsDetailModel *goodsDetailInfo) {
            @strongify(self)
            self.currentAttribute.model = goodsDetailInfo;
            [attributeView openSelectTypeView];
            [self addToBagBeforeViewProduct:goodsDetailInfo];
        }];
    }
}

// 切换属性
- (void)changeGoodsAttribute:(NSString *)goodsId{
    if (self.currentAttribute) {
        if (self.currentAddCartGoodsModel) {
            self.currentAddCartGoodsModel.selectSkuCount += 1;
        }
        //获取商品详情接口
        @weakify(self)
        [self requestGoodsDetailInfo:ZFToString(goodsId) successBlock:^(GoodsDetailModel *goodsDetailInfo) {
            @strongify(self)
            self.currentAttribute.model = goodsDetailInfo;
            [self addToBagBeforeViewProduct:goodsDetailInfo];
        }];
    }
}

//添加购物车
- (void)addGoodsToCartOption:(NSString *)goodsId goodsCount:(NSInteger)goodsCount {
    
    if (!self.currentAttribute || !self.currentAttribute.model) {
        return;
    }
    @weakify(self);
    [self.goodsDetailViewModel requestAddToCart:ZFToString(goodsId) loadingView:self.view goodsNum:goodsCount completion:^(BOOL isSuccess) {
        @strongify(self);
        
        if (isSuccess) {
            // 重新设置加购按钮可以点击
            [self startAddCartSuccessAnimation];
            [self changeCartNumAction];
            
            //添加商品至购物车事件统计
            self.currentAttribute.model.buyNumbers = goodsCount;
            NSString *goodsSN = self.currentAttribute.model.goods_sn;
            NSString *spuSN = @"";
            if (goodsSN.length > 7) {  // sn的前7位为同款id
                spuSN = [goodsSN substringWithRange:NSMakeRange(0, 7)];
            }else{
                spuSN = goodsSN;
            }
            
            NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
            valuesDic[AFEventParamContentId] = ZFToString(goodsSN);
            valuesDic[@"af_spu_id"] = ZFToString(spuSN);
            valuesDic[AFEventParamPrice] = ZFToString(self.currentAttribute.model.shop_price);
            valuesDic[AFEventParamQuantity] = [NSString stringWithFormat:@"%zd",goodsCount];
            valuesDic[AFEventParamContentType] = @"product";
            valuesDic[@"af_content_category"] = ZFToString(self.currentAttribute.model.long_cat_name);
            valuesDic[AFEventParamCurrency] = @"USD";
            valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeZMeLiveDetail sourceID:ZFToString(self.videoModel.idx)];
            
            valuesDic[@"af_changed_size_or_color"] = (self.currentAddCartGoodsModel.selectSkuCount > 0) ? @"1" : @"0";
            if (self.currentAttribute.model) {
                valuesDic[BigDataParams]           = @[[self.currentAttribute.model gainAnalyticsParams]];
            }
            valuesDic[@"af_purchase_way"]      = @"1";//V5.0.0增加, 判断是否为一键购买(0)还是正常加购(1)
            [ZFAnalytics appsFlyerTrackEvent:@"af_add_to_bag" withValues:valuesDic];
            //Branch
            if (self.currentAttribute.model) {
                [[ZFBranchAnalytics sharedManager] branchAddToCartWithProduct:self.currentAttribute.model number:goodsCount];
                [ZFFireBaseAnalytics addToCartWithGoodsModel:self.currentAttribute.model];
                [ZFGrowingIOAnalytics ZFGrowingIOAddCart:self.currentAttribute.model];
            }
            
        } else {
            [self.currentAttribute bottomCartViewEnable:YES];
            [self changeCartNumAction];
        }
    }];
}

- (void)addToBagBeforeViewProduct:(GoodsDetailModel *)detailModel {
    
    //用户点击查看商品
    NSMutableDictionary *valuesDic     = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId]   = ZFToString(detailModel.goods_sn);
    valuesDic[AFEventParamContentType] = @"product";
    valuesDic[AFEventParamPrice]       = ZFToString(detailModel.shop_price);
    valuesDic[AFEventParamCurrency]    = @"USD";
    valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeZMeLiveDetail sourceID:ZFToString(self.liveID)];
    valuesDic[@"af_changed_size_or_color"] = @"1";
    valuesDic[BigDataParams]           = [detailModel gainAnalyticsParams];
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_view_product" withValues:valuesDic];
    [ZFGrowingIOAnalytics ZFGrowingIOProductDetailShow:detailModel];
}

- (void)changeCartNumAction {
    [self.currentAttribute changeCartNumberInfo];
}


- (void)startAddCartSuccessAnimation {
    
    if (self.currentAttribute == self.attributeView) {
        
        // attributeView 在触发收起弹窗时，重新设置可以点击
        @weakify(self)
        [self.attributeView startAddCartAnimation:^{
            @strongify(self)
            [self.attributeView hideSelectTypeView];
        }];
    } else {
        [self.currentAttribute bottomCartViewEnable:YES];
    }
    
}

#pragma mark - 显示各类弹出视图

- (void)showErrorView:(BOOL)show {
    if (!_errorView) {
        [self.view addSubview:self.errorView];
        [self.errorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    if (self.videoModel && self.errorView.rotes.count <= 0 && ZFJudgeNSArray(self.videoModel.spare_channel_id)) {
        if (self.videoModel.spare_channel_id.count > 0) {
            [self.errorView configurateRotes:self.videoModel.spare_channel_id];
        }
    }

    [self.errorView showError:show];
    [self.view bringSubviewToFront:self.errorView];
    self.errorView.hidden = !show;
}

- (void)showGoodsContentView:(BOOL)show {
    [self.view bringSubviewToFront:self.goodsCotentView];
    [self.goodsCotentView showGoodsView:show];
}

- (void)showAnchorInfoView:(BOOL)show {
    
    if (ZFJudgeNSArray(self.videoModel.ios_hot) && self.videoModel.ios_hot.count > 0) {
        [self.view bringSubviewToFront:self.anchorInfoView];
        if (!ZFJudgeNSArray(self.anchorInfoView.liveActivityViewModel.datasArray)) {
            [self.anchorInfoView updateHotActivity:self.videoModel.ios_hot];
        }
        [self.anchorInfoView showAnchorView:show];
    }
}

- (void)showCouponList:(BOOL)show {
    
    [self.view bringSubviewToFront:self.couponListView];
    
    if (ZFIsEmptyString(self.couponListView.live_code)) {
        self.couponListView.live_code = ZFToString(self.videoModel.live_code);
    }
    if (show) {
        [self.couponListView zfViewWillAppear];
    }
    
    if (self.isPlaying || [self.videoModel.type integerValue] != 1) {
        self.couponListView.isCanReceive = YES;
    } else {
        self.couponListView.isCanReceive = NO;
    }
    [self.couponListView showCouponListView:show];
}

- (void)showCommentList:(BOOL)show {
    [self.view bringSubviewToFront:self.commentListView];
    [self.commentListView showCommentListView:show];
}

- (void)showVideoOperateView:(BOOL)show {
    self.videoPlayOperateView.hidden = !show;
    [self.videoPlayOperateView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.videoContainerView.mas_bottom).offset(show ? 0 : 45);
    }];
}

/**
 显示推荐商品模块动画
 
 @param isShow
 */
- (void)showLandscapeGoodsView:(BOOL)isShow {
    
    // 不是横屏情况下
    if (!self.isLandscapeScreen) {
        self.rightTopGoodsButton.enabled = YES;
        if (!self.goodsLandscapeListView.isHidden) {
            self.goodsLandscapeListView.hidden = YES;
        }
        return;
    }

    //弹出商品时，需要隐藏，收起时对应的显示
    if (self.bottomOperateView.isShowExpandUtils) {
        [self.bottomOperateView hideEventView];
    }
    self.bottomOperateView.userInteractionEnabled = NO;

    CGFloat leadingX = 0;
    if (isShow) {
        leadingX = -300;
        self.goodsLandscapeListView.hidden = NO;
    }
    
    if (isShow) {
        [self.goodsLandscapeListView updateGoodsData:self.goodsCotentView.currentGoodsArray];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.goodsLandscapeListView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.videoContainerView.mas_trailing).offset(leadingX);
        }];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.rightTopGoodsButton.enabled = YES;
        if (!isShow) {
            self.goodsLandscapeListView.hidden = YES;
            self.bottomOperateView.userInteractionEnabled = YES;
        }
    }];
}

- (void)showSwipView {
    
    BOOL isShowSwipTip = [GetUserDefault(kZFFullLiveSwipeTipViewTip) boolValue];
    if (!isShowSwipTip) {
        SaveUserDefault(kZFFullLiveSwipeTipViewTip, @(YES));

        ZFFullLiveSwipeTipView *swipeTipView = [[ZFFullLiveSwipeTipView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:swipeTipView];

        [swipeTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
}

- (void)showZegoPlayToWindow {
    
    if ([self.videoModel.type integerValue] != ZFCommunityLiveStateReady) {
        
        CGFloat w = CGRectGetWidth(self.videoContainerView.frame) / 2.5;
        CGFloat h = CGRectGetHeight(self.videoContainerView.frame) / 2.5;
        if(self.videoModel.isFull) {
            w = 0.6 * w;
            h = 0.6 * h;
        }
        [self.videoPlayView showToWindow:CGSizeMake(w, h)];
    } else {
        [self pausePlay];
    }
}
#pragma mark - 推荐商品相关、推荐优惠券相关
- (void)showGoodsAlertView:(ZFCommunityVideoLiveGoodsModel *)goodsModel {
    
    if (!ZFIsEmptyString(goodsModel.goods_sn)) {
        [self.goodsCotentView.currentGoodsArray enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // 消息推荐商品，优先匹配推荐商品列表里的价格
            if ([obj.goods_sn isEqualToString:goodsModel.goods_sn]) {
                goodsModel.shop_price = ZFToString(obj.shop_price);
                goodsModel.price = ZFToString(obj.market_price);
                *stop = YES;
            }
        }];
        
        self.alertLiveGoodsModel = goodsModel;
        [self dissmissGoodsAlertView];
        
        CGRect alertFrame = self.isLandscapeScreen ? CGRectMake(0, 0, 230, 116) : CGRectMake(0, 0, 180, 76);
        CGSize alertCloseSize = self.isLandscapeScreen ? CGSizeMake(28, 28) : CGSizeMake(21, 21);
        ZFVideoLiveGoodsAlertItemView *alertView = [[ZFVideoLiveGoodsAlertItemView alloc] initFrame:alertFrame goodsModel:goodsModel tryOn:YES];
        [alertView updateCloseSize:alertCloseSize];
        
        @weakify(self)
        alertView.addCartBlock = ^(ZFCommunityVideoLiveGoodsModel * _Nonnull goodsModel) {
            @strongify(self)
            ZFGoodsModel *model = [[ZFGoodsModel alloc] init];
            model.goods_id = ZFToString(goodsModel.goods_id);
            model.goods_sn = ZFToString(goodsModel.goods_sn);
            
            if (self.isLandscapeScreen) {
                [self addCartGoods:model attributeView:self.landscapeAttributeView];
            } else {
                [self addCartGoods:model attributeView:self.attributeView];
            }
        };
        
        alertView.closeBlock = ^(BOOL flag) {
            @strongify(self)
            self.bottomOperateView.stopGoodsAnimate = NO;
            [self dissmissGoodsAlertView];
        };
        
        self.bottomOperateView.stopGoodsAnimate = YES;
        if (self.isLandscapeScreen) {
            self.goodsAlertView = [[ZFVideoLiveGoodsAlertView alloc] initTipArrowOffset:30 leadingSpace:0 trailingSpace:0 direct:[SystemConfigUtils isRightToLeftShow] ? ZFTitleArrowTipDirectUpLeft : ZFTitleArrowTipDirectUpRight contentView:alertView];
            [self.goodsAlertView hideViewWithTime:3600 complectBlock:^{
                @strongify(self)
                self.bottomOperateView.stopGoodsAnimate = NO;
            }];

            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alertGoodsTap:)];
            [self.goodsAlertView addGestureRecognizer:tap];

            if (self.couponAlertView) {
                [self.operateView insertSubview:self.goodsAlertView aboveSubview:self.couponAlertView];
            } else {
                [self.operateView insertSubview:self.goodsAlertView belowSubview:self.rightTopGoodsButton];
            }

            [self.goodsAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.operateView.mas_trailing).offset(-16);
                make.top.mas_equalTo(self.rightTopGoodsButton.mas_bottom).offset(2);
                make.width.mas_lessThanOrEqualTo(KScreenWidth - 24);
            }];
        } else {
            self.goodsAlertView = [[ZFVideoLiveGoodsAlertView alloc] initTipArrowOffset:18 leadingSpace:0 trailingSpace:0 direct:[SystemConfigUtils isRightToLeftShow] ? ZFTitleArrowTipDirectDownRight : ZFTitleArrowTipDirectDownLeft contentView:alertView];
            [self.goodsAlertView hideViewWithTime:3600 complectBlock:^{
                self.bottomOperateView.stopGoodsAnimate = NO;
            }];

            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alertGoodsTap:)];
            [self.goodsAlertView addGestureRecognizer:tap];

            if (self.couponAlertView) {
                [self.operateView insertSubview:self.goodsAlertView aboveSubview:self.couponAlertView];
            } else {
                [self.operateView insertSubview:self.goodsAlertView belowSubview:self.goodsCotentView];
            }

            [self.goodsAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.operateView.mas_leading).offset(12);
                make.bottom.mas_equalTo(self.bottomOperateView.mas_top).offset(4);
                make.width.mas_lessThanOrEqualTo(KScreenWidth - 24);
            }];
        }
    }
}

///点击弹窗商品
- (void)alertGoodsTap:(UITapGestureRecognizer *)tap {
    if (self.alertLiveGoodsModel) {
        ZFGoodsModel *goodsModel = [[ZFGoodsModel alloc] init];
        goodsModel.goods_id = ZFToString(self.alertLiveGoodsModel.goods_id);
        goodsModel.goods_sn = ZFToString(self.alertLiveGoodsModel.goods_sn);
        [self jumpToGoodsDetail:goodsModel];
    }
}


- (void)showCouponAlertView:(ZFGoodsDetailCouponModel *)couponModel {
    if (!ZFIsEmptyString(couponModel.couponId)) {
        
        self.alertCouponModel = couponModel;
        [self dissmissCouponAlertView];
        
        CGFloat alertW = self.isLandscapeScreen ? MAX(KScreenHeight, KScreenWidth) : MIN(KScreenHeight, KScreenWidth);
        CGFloat alertY = self.isLandscapeScreen ? -200 : MAX(KScreenHeight, KScreenWidth) + 10;
        
        CGRect alertFrame = self.isLandscapeScreen ? CGRectMake(alertW - 230 - 16, alertY, 230, 116) : CGRectMake(12, alertY, 180, 76);
        self.couponAlertView = [[ZFVideoLiveCouponAlertView alloc] initWithFrame:alertFrame couponModel:couponModel isNew:YES];
        self.couponAlertView.backgroundColor = ZFCClearColor();
        self.bottomOperateView.stopCouponAnimate = YES;
        @weakify(self)
        [self.couponAlertView hideViewWithTime:3600 complectBlock:^{
            @strongify(self)
            self.bottomOperateView.stopCouponAnimate = NO;
        }];
        
        if (self.goodsAlertView) {
            [self.operateView insertSubview:self.couponAlertView aboveSubview:self.goodsAlertView];
        } else {
            [self.operateView insertSubview:self.couponAlertView belowSubview:self.goodsCotentView];
        }

        self.couponAlertView.closeBlock = ^{
            @strongify(self)
            self.bottomOperateView.stopCouponAnimate = NO;
        };
        
        self.couponAlertView.receiveCouponBlock = ^(ZFGoodsDetailCouponModel *couponModel) {
            @strongify(self)
            
            @weakify(self)
            [self receiveCoupon:couponModel completion:^(ZFGoodsDetailCouponModel *model) {
                @strongify(self)
                if (self.couponAlertView) {
                    self.couponAlertView.couponModel = model;
                }
            }];
        };


        if (self.isLandscapeScreen) {
            [self.couponAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.operateView.mas_trailing).offset(-12);
                make.top.mas_equalTo(self.rightTopGoodsButton.mas_bottom).offset(-200);
            }];

            self.view.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.25 animations:^{
                [self.couponAlertView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.rightTopGoodsButton.mas_bottom).offset(2);
                }];
                self.view.userInteractionEnabled = YES;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {

            }];

        } else {
            [self.couponAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.operateView.mas_leading).offset(12);
                make.bottom.mas_equalTo(self.bottomOperateView.mas_top).offset(200);
            }];

            self.view.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.25 animations:^{
                [self.couponAlertView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(self.bottomOperateView.mas_top).offset(-2);
                }];
                self.view.userInteractionEnabled = YES;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {

            }];
        }
    }
}


- (void)dissmissGoodsAlertView {
    if (self.goodsAlertView) {
        self.goodsAlertView.hidden = YES;
        [self.goodsAlertView removeFromSuperview];
        self.goodsAlertView = nil;
    }
}

- (void)dissmissCouponAlertView {
    if (self.couponAlertView) {
        self.couponAlertView.hidden = YES;
        [self.couponAlertView removeFromSuperview];
        self.couponAlertView = nil;
    }
}


- (void)receiveCoupon:(ZFGoodsDetailCouponModel *)couponModel completion:(void (^)(ZFGoodsDetailCouponModel *model))completion {
    
    @weakify(self)

    [self checkDeviceIsLandscape:^{
        @strongify(self)

        // 领取优惠券
        ShowLoadingToView(self.view);
        
        // 1. 调取领劵接口
        @weakify(self)
        [ZFCommunityLiveVideoGoodsModel requestGetGoodsCoupon:couponModel.couponId completion:^(BOOL success, NSInteger couponStatus) {
            @strongify(self)
            
            // 1:领劵成功;2:领券Coupon不存在;3:已领券;4:没到领取时间;5:已过期;6:coupon已领取完;7:赠送coupon失败
            // 默认提示已领完
            NSString *tiptext = ZFLocalizedString(@"Detail_ReceiveCouponFail", nil);
            
            // 注意界面显示状态 // coupon状态；1:可领取;2:已领取;3:已领取完
            if (success) {
                if (couponStatus == 1) {
                    tiptext = ZFLocalizedString(@"Detail_ReceiveCouponSuccess", nil);
                    couponModel.couponStats = 2;
                } else if (couponStatus == 6) {
                    tiptext = ZFLocalizedString(@"Detail_ReceiveCouponUsedUp", nil);
                    couponModel.couponStats = 3;
                } else {
                    couponModel.couponStats = couponStatus;
                }
                
                ShowToastToViewWithText(self.view, tiptext);
            } else {
                ShowToastToViewWithText(self.view, tiptext);
            }
            if (completion) {
                completion(couponModel);
            }
        }];
    }];
}


#pragma mark - ZFGoodsDetailAttributeSmallViewDelegate

- (void)goodsDetailAttribute:(ZFGoodsDetailAttributeSmallView *)attributeView showState:(BOOL)isShow {
    [attributeView bottomCartViewEnable:YES];
}

- (void)goodsDetailAttribute:(ZFGoodsDetailAttributeSmallView *)attributeView tapCart:(BOOL)tapCart {
    [self jumpToCartAction];
}

- (void)goodsDetailAttribute:(ZFGoodsDetailAttributeSmallView *)attributeView selectGoodsId:(NSString *)goodsId {
    [self changeGoodsAttribute:goodsId];
}

- (void)goodsDetailAttribute:(ZFGoodsDetailAttributeSmallView *)attributeView addCartGoodsId:(NSString *)goodsId count:(NSInteger)count {
    
    [attributeView bottomCartViewEnable:NO];
    [self addGoodsToCartOption:goodsId goodsCount:count];
}

#pragma mark - 倒计时

/**
 活动倒计时结束事件
 */
- (void)reloadActivityTime {
    int timeOut =  [self.stateCoverView.inforModel.time doubleValue] - [[ZFTimerManager shareInstance] timeInterval:self.stateCoverView.inforModel.startTimerKey];
    
    int leftTimeOut = [[ZFTimerManager shareInstance] timeInterval:self.stateCoverView.inforModel.startTimerKey];
    
    YWLog(@"----------- 视频活动倒计时 : %i -- left: %i",timeOut,leftTimeOut);
    
    if(timeOut <= 0 || leftTimeOut <= 0){ //倒计时结束，关闭
        
        self.stateCoverView.inforModel.time = @"";
        [self.stateCoverView stopTimer];
        self.stateCoverView.hidden = YES;
        
        [self.stateCoverView updateLiveCoverState:LiveZegoCoverStateLiving];
        self.videoModel.type = @"2";
        
        // 如果是zego直播时，已经初始了，只要判断是否需要重新登录
        if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
            if (!self.zegoLiveVideoView.loginRoomSuccess) {
                [self.zegoLiveVideoView reLoginRoom];
            } else {
                
                // 即购已经登录成功了，并提示将要开始，如果已经有流id，就不处理
                if (ZFIsEmptyString(self.zegoLiveVideoView.streamID)) {
                    [self.stateCoverView updateLiveCoverState:LiveZegoCoverStateJustLive];
                }
            }
        }

        [[NSNotificationCenter defaultCenter] removeObserver:self name:kTimerManagerUpdate object:nil];
        
        if (self.playStatusBlock) {
            self.playStatusBlock(self.videoModel);
        }
    } else {
        [self.stateCoverView updateLiveCoverState:LiveZegoCoverStateWillStart];
    }
}

#pragma mark - 通知

///登录通知
- (void)loginChangeValue:(NSNotification *)nofi {
    self.navBarView.userName = [AccountManager sharedManager].account.nickname;
}

- (void)liveOnlineCountChangeValue:(NSNotification *)nofi {
    int count = [nofi.object intValue];
    count = [ZFVideoLiveCommentUtils sharedInstance].onlineNums;
    if (count >= 0) {
        self.navBarView.eyeNums = [ZFToString(self.videoModel.virtual_view_num) integerValue] + count;
    }
}

- (void)addLikeNumsNotif:(NSNotification *)notif {
    [self updateLikeNums];
}

/// 点赞处理
- (void)updateLikeNums {
    NSInteger likeNums = [ZFVideoLiveCommentUtils sharedInstance].likeNums;
    self.bottomOperateView.likeNums = likeNums;
}

#pragma mark - 横竖屏

/// 配置是否支持全屏方向
- (void)configurateDeveiceLandscape {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // v5.6.0 不支持自动旋转
//        if (self.videoModel && !self.videoModel.isFull) {
//            [self forceOrientation:AppForceOrientationALL];
            
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(deviceOrientationDidChange:)
                                                         name:UIDeviceOrientationDidChangeNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
//        }
        
    });
}

///强制设置旋转
- (void)actionForceOrientationLandscape{
    [self forceOrientation:AppForceOrientationJustOnceLandscape];
    [self orientationLandscape];
    
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        [self orientationPortraitOrLandscape:[UIDevice currentDevice]];
    }
}

/// 为什么要这样两个监听，设备是横着进来的时候，设备方向不会触发改变通知，所以要在监听导航栏的方向
- (void)statusBarOrientationDidChange:(NSNotification *)notification {
    
    if (!self.isCurrentVC) {
        YWLog(@"-----------状态栏监听 不在当前");
        return;
    }
    
    if ([self.navigationController isKindOfClass:[ZFNavigationController class]]) {
        ZFNavigationController *navCtrl = (ZFNavigationController *)self.navigationController;
        UIInterfaceOrientation currentInterfaceOrientation = navCtrl.interfaceOrientation;
        
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        NSString *msg = [NSString stringWithFormat:@"状态栏方向----current:%li    监听的：%li",(long)currentInterfaceOrientation,(long)interfaceOrientation];
        YWLog(msg);

//        //FIXME: occ Bug 1101 这个判断其实还可要调整一下
//        if (currentInterfaceOrientation == interfaceOrientation) {
//            return;
//        }
        
        // v5.6.0 不支持自动旋转
//        if (interfaceOrientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationPortrait == UIInterfaceOrientationMaskAllButUpsideDown) {
//            [self handleCurrentInterfaceOrientationPortrait];
//        } else if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//            [self handleCurrentInterfaceOrientationLandscape];
//        }
        switch (interfaceOrientation) {
            case UIInterfaceOrientationUnknown:
                YWLog(@"状态栏方向----未知方向");
                break;
            case UIInterfaceOrientationPortrait:
                YWLog(@"状态栏方向----界面直立");
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                YWLog(@"状态栏方向----界面直立，上下颠倒");
                break;
            case UIInterfaceOrientationLandscapeLeft:
                YWLog(@"状态栏方向----界面朝左");
                break;
            case UIInterfaceOrientationLandscapeRight:
                YWLog(@"状态栏方向----界面朝右");
                break;
            default:
                break;
        }
    }
}

-(void)deviceOrientationDidChange:(NSObject*)sender{
    
    UIDevice *device = [sender valueForKey:@"object"];

    YWLog(@"----------------------------    deviceOrientationDidChange:   %li",(long)device.orientation);
    if (!self.isCurrentVC) {
        YWLog(@"-----------设备监听 不在当前");
        return;
    }

    // v5.6.0 不支持自动旋转
//    [self orientationPortraitOrLandscape:device];
    
}

- (void)orientationPortraitOrLandscape:(UIDevice *)device {
    
    if (device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight) {
        [self handleCurrentInterfaceOrientationLandscape];
    } else if (device.orientation == UIDeviceOrientationPortrait){//垂直向下有问题
        [self handleCurrentInterfaceOrientationPortrait];
    }
}


- (void)handleCurrentInterfaceOrientationLandscape {
    
    [self forceOrientation:AppForceOrientationLandscape];
    self.view.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self orientationLandscape];
        self.view.userInteractionEnabled = YES;
    });

//    [self orientationLandscape];
}

- (void)orientationLandscape {
    YWLog(@"------------------- 横屏 -----------------");

    self.isLandscapeScreen = YES;
    self.fd_interactivePopDisabled = YES;

    CGFloat coverH = KScreenHeight > KScreenWidth ? KScreenWidth : KScreenHeight;
    CGFloat maxW = KScreenHeight > KScreenWidth ? KScreenHeight : KScreenWidth;

    [self.view setNeedsUpdateConstraints];
    if (self.isHideMoveOperateView) {
        [self.operateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.view.mas_leading).offset(maxW);
            make.width.mas_equalTo(maxW);
        }];
        
        self.liveFullScreenButton.hidden = NO;
        [self.liveFullScreenButton setImage:[UIImage imageNamed:@"live_full_small"] forState:UIControlStateNormal];
        
    } else {
        [self.operateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.view.mas_leading);
            make.width.mas_equalTo(maxW);
        }];
        self.liveFullScreenButton.hidden = YES;
    }
    
    
    self.navBarView.hidden = YES;
    self.closeButton.hidden = YES;
    self.rightTopGoodsButton.hidden = YES;
    
    // 横屏时，有推荐商品显示
    if (self.goodsCotentView.currentGoodsArray.count > 0) {
        self.rightTopGoodsButton.hidden = NO;
    }
    // 是否显示评论视图
    self.videoChatView.hidden = !self.bottomOperateView.isShowExpandUtils;
    [self.bottomOperateView showLandscapeView:YES];
    if (self.currentAttribute) {
        [self.currentAttribute hideSelectTypeView];
    }
    
    if ([self isVideoPlay]) {
        self.liveFullScreenButton.hidden = YES;
        self.operateView.hidden = YES;
        self.bottomOperateView.hidden = YES;
        self.videoPlayOperateView.isFull = YES;
    }
    
    [self.videoContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.operateView.mas_top).offset([self videoTopSpace]);
        make.height.mas_equalTo(coverH);
    }];
    
    [self.videoChatView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([self commentHeight]);
        make.width.mas_equalTo(maxW);
    }];
    
    [self.bottomOperateView mas_updateConstraints:^(MASConstraintMaker *make) {    make.bottom.mas_equalTo(self.operateView.mas_bottom);
    }];
    [self.view layoutIfNeeded];
}

- (void)handleCurrentInterfaceOrientationPortrait {
    [self forceOrientation:AppForceOrientationPortrait];
    [self orientationPortrait];
}

- (void)orientationPortrait {
    YWLog(@"------------------- 竖屏 -----------------");
    self.isLandscapeScreen = NO;
    self.fd_interactivePopDisabled = NO;
    
    CGFloat minW = KScreenHeight > KScreenWidth ? KScreenWidth : KScreenHeight;
    
    [self.view setNeedsUpdateConstraints];
    if (self.isHideMoveOperateView) {
        [self.operateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.view.mas_leading).offset(minW);
            make.width.mas_equalTo(minW);
        }];
    } else {
        [self.operateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.view.mas_leading);
            make.width.mas_equalTo(minW);
        }];
    }
    
    if (!self.videoModel.isFull) {
        self.liveFullScreenButton.hidden = NO;
        [self.liveFullScreenButton setImage:[UIImage imageNamed:@"live_full_expand"] forState:UIControlStateNormal];
    } else {
        self.liveFullScreenButton.hidden = YES;
    }
    
    
    self.operateView.hidden = NO;
    self.closeButton.hidden = NO;
    self.rightTopGoodsButton.hidden = YES;
    self.navBarView.hidden = NO;
    self.videoChatView.hidden = NO;
    [self.bottomOperateView showLandscapeView:NO];
    self.bottomOperateView.userInteractionEnabled = YES;
    [self showLandscapeGoodsView:NO];
    
    if (self.currentAttribute) {
        [self.currentAttribute hideSelectTypeView];
    }
    self.goodsLandscapeListView.hidden = YES;
    
    if ([self isVideoPlay]) {
        self.liveFullScreenButton.hidden = YES;
        if (self.videoModel.isFull) {
            self.bottomOperateView.hidden = !self.videoPlayOperateView.isHidden;
        } else {
            self.bottomOperateView.hidden = NO;
        }
        [self.bottomOperateView showCommentView:YES];
        [self.videoPlayView showProgressLine:!self.videoPlayOperateView.isHidden];
        self.videoPlayOperateView.isFull = NO;
    }
    //zego：视频比例是16：9
    CGFloat zegoH = KScreenWidth * kZegoPlaySmallViewScale;
    if (self.videoModel.isFull) {
        zegoH = KScreenHeight > KScreenWidth ? KScreenHeight : KScreenWidth;
    }
    [self.videoContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.operateView.mas_top).offset([self videoTopSpace]);
        make.height.mas_equalTo(zegoH);
    }];
    
    [self.videoChatView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([self commentHeight]);
        make.width.mas_equalTo(minW);
    }];

    [self.bottomOperateView mas_updateConstraints:^(MASConstraintMaker *make) {
    make.bottom.mas_equalTo(self.operateView.mas_bottom).offset(-kiphoneXHomeBarHeight);
    }];
    [self.view layoutIfNeeded];
}

#pragma mark - 手势

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    for (Class aClass in [NSSet setWithObjects:[UIControl class],[UINavigationBar class], nil]) {
        if ([[touch view] isKindOfClass:aClass]) {
            return NO;//点击的是一些操作控件，则不处理 『点击外部消失手势』
        }
    }
    
    for (UIView *view = touch.view; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UICollectionViewCell class]]) {
            return NO;
        }
    }
    
    if ([self.goodsCotentView pointInside:[touch locationInView:self.goodsCotentView] withEvent:nil] && !self.goodsCotentView.isHidden) {
        return NO;
    }
    
    if ([self.couponListView pointInside:[touch locationInView:self.couponListView] withEvent:nil] && !self.couponListView.isHidden) {
        return NO;
    }
    
    if ([self.commentListView pointInside:[touch locationInView:self.commentListView] withEvent:nil] && !self.commentListView.isHidden) {
        return NO;
    }
    
//    if ([self.videoChatView.messageListView pointInside:[touch locationInView:self.videoChatView.messageListView] withEvent:nil] && !self.videoChatView.messageListView.isHidden) {
//        return NO;
//    }
    
    if (_attributeView &&[_attributeView pointInside:[touch locationInView:_attributeView] withEvent:nil] && !_attributeView.isHidden) {
        return NO;
    }
    
    if (_landscapeAttributeView && [_landscapeAttributeView pointInside:[touch locationInView:_landscapeAttributeView] withEvent:nil] && !_landscapeAttributeView.isHidden) {
        return NO;
    }
    
    if (_goodsAlertView && [_goodsAlertView pointInside:[touch locationInView:_goodsAlertView] withEvent:nil] && !_goodsAlertView.isHidden) {
        return NO;
    }
    
    if (_couponAlertView && [_couponAlertView pointInside:[touch locationInView:_couponAlertView] withEvent:nil] && !_couponAlertView.isHidden) {
        return NO;
    }
    
    if ([self.goodsLandscapeListView pointInside:[touch locationInView:self.goodsLandscapeListView] withEvent:nil] && !self.goodsLandscapeListView.isHidden) {
        return NO;
    }
 
    
    return YES;
}


- (void)handTapEvent {
    if (self.isLandscapeScreen) {
        if (self.operateView.isHidden) {
            self.operateView.hidden = NO;
            self.liveFullScreenButton.hidden = YES;
        } else {
            self.operateView.hidden = YES;
            self.liveFullScreenButton.hidden = NO;
            [self.liveFullScreenButton setImage:[UIImage imageNamed:@"live_full_small"] forState:UIControlStateNormal];
        }
        
    } else if(self.videoModel && !self.videoModel.isFull){
        self.liveFullScreenButton.hidden = !self.liveFullScreenButton.isHidden;
        [self.liveFullScreenButton setImage:[UIImage imageNamed:@"live_full_expand"] forState:UIControlStateNormal];
        
    }
    
//    self.playButton.hidden = !self.playButton.hidden;
    
    if ([self isVideoPlay]) {
        [self showVideoOperateView:self.videoPlayOperateView.isHidden];
        self.liveFullScreenButton.hidden = YES;
        if (self.isLandscapeScreen) {
            self.operateView.hidden = YES;
        }
//        self.playButton.hidden = YES;
        
        // 全屏播放时，显示播放操作视图是，隐藏底部评论视图
        if(self.videoModel && self.videoModel.isFull) {
            self.bottomOperateView.hidden = !self.videoPlayOperateView.isHidden;
        }
    }
    
    // 倒计时时，不显示播放按钮
    if (self.stateCoverView.coverState == LiveZegoCoverStateWillStart) {
//        self.playButton.hidden = YES;
    }
}

- (void)actionTap:(UITapGestureRecognizer *)tapGest {
    
    if (!self.goodsCotentView.isHidden || !self.couponListView.isHidden || !self.anchorInfoView.isHidden || !self.commentListView.isHidden || (_errorView && !_errorView.isHidden)) {
        return;
    }
    [self handTapEvent];
}



- (void)actionPan:(UIPanGestureRecognizer *)panGest {
    
    if (!self.goodsCotentView.isHidden
        || !self.anchorInfoView.isHidden
        || !self.commentListView.isHidden
        || !self.couponListView.isHidden) {
        return;
    }

    if (self.operateView.isHidden) {
        return;
    }
    CGPoint point = [panGest translationInView:self.view];
    switch (panGest.state) {
        case UIGestureRecognizerStateBegan: {
            self.startPanX = point.x;
            self.startMoveOperateFrame = self.operateView.frame;
            break;
        }
        case UIGestureRecognizerStateChanged: {

            if (self.isLandscapeScreen) {
                self.liveFullScreenButton.hidden = YES;
            }
            if (!self.isLandscapeScreen) {
                self.closeButton.hidden = YES;
            }
            [self commitTranslation:point];
            break;
        }
        case UIGestureRecognizerStateEnded: {
                        
            if (point.x > 0) {
                
                CGRect operateFrame = self.operateView.frame;
                if (operateFrame.origin.x > 60 ) {
                    [self updateOperateAnimate:KScreenWidth];
                    
                } else if(operateFrame.origin.x > 0) {
                    [self updateOperateAnimate:0];
                } else if(operateFrame.origin.x <= 0 && operateFrame.origin.x > (60-KScreenWidth)) {
                    [self updateOperateAnimate:0];
                } else {
                    [self updateOperateAnimate:-KScreenWidth];
                }
                
            } else {
                CGRect operateFrame = self.operateView.frame;
                if (operateFrame.origin.x <= -60) {
                    [self updateOperateAnimate:-KScreenWidth];
                } else if (operateFrame.origin.x < (KScreenWidth - 60)) {
                    [self updateOperateAnimate:0];
                } else if(operateFrame.origin.x < KScreenWidth) {
                    [self updateOperateAnimate:KScreenWidth];
                }
            }
            
            if (self.isLandscapeScreen) {
                self.liveFullScreenButton.hidden = !self.isHideMoveOperateView;
            } else {
                
                if (self.videoModel.isFull) {
                    self.liveFullScreenButton.hidden = self.videoModel.isFull;
                }
                self.closeButton.hidden = NO;
                self.closeButton.alpha = 0;
                [UIView animateWithDuration:0.5 animations:^{
                    self.closeButton.alpha = 1;
                }];
            }
            if ([self isVideoPlay]) {
                self.liveFullScreenButton.hidden = YES;
            }
            break;
        }
        default:
            break;
    }
}

/// 更新滑动动画
- (void)updateOperateAnimate:(CGFloat )originX {
    
    self.panGesture.enabled = NO;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.18 animations:^{
        self.panGesture.enabled = YES;
        [self.operateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.view.mas_leading).offset(originX);
        }];
        if (originX == 0) {
            self.isHideMoveOperateView = NO;
        } else {
            self.isHideMoveOperateView = YES;
        }
        [self.view layoutIfNeeded];
    }];
}

/**
 *   判断手势方向
 *
 *  @param translation translation description
 */
- (void)commitTranslation:(CGPoint)translation
{

    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);

//    YWLog(@"------ %f",translation.x);
    // 设置滑动有效距离
//    if (MAX(absX, absY) < 40) {
//        return;
//    }

    if (absX > absY ) {
     
    CGRect operateFrame = self.startMoveOperateFrame;
    
        CGFloat distanceX  = absX - self.startPanX;
        
        YWLog(@"------ %f",distanceX);
        
        if (translation.x<0) {
            //向左滑动
            operateFrame.origin.x -= distanceX;
            
            if (operateFrame.origin.x <= 0) {
//                operateFrame.origin.x = 0;
//                self.isHideMoveOperateView = NO;
            }
//            self.operateView.frame = operateFrame;
            [self.operateView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.view.mas_leading).offset(operateFrame.origin.x);
            }];
            
        }else{
            //向右滑动
            operateFrame.origin.x += distanceX;
            if (operateFrame.origin.x >= KScreenWidth) {
//                operateFrame.origin.x = KScreenWidth;
//                self.isHideMoveOperateView = YES;
            }
//            self.operateView.frame = operateFrame;
            [self.operateView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.view.mas_leading).offset(operateFrame.origin.x);
            }];
        }
    
    }
//        else if (absY > absX) {
//        if (translation.y<0) {
//            //向上滑动
//        }else{
//            //向下滑动
//        }
//    }


}


#pragma mark - 基础配置

- (BOOL)isVideoPlay {
    if (self.videoModel) {
        if ([self.videoModel.type isEqualToString:@"3"]
        || (!ZFIsEmptyString(self.videoModel.live_replay_url) && self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream)) {
            return YES;
        }
    }
    return NO;
}

- (CGFloat)commentHeight {
    
    if (self.videoModel && self.videoModel.isFull) {
        CGFloat max = KScreenHeight > KScreenWidth ? KScreenHeight : KScreenWidth;
        return max * 1.0 / 5.0;
    } else {
        if (self.isLandscapeScreen) {
            CGFloat deviceW = KScreenWidth;
            CGFloat deviceH = KScreenHeight;
            CGFloat commentH = MIN(deviceW, deviceH) / 2.0  + 20;
            return commentH;
            
        } else {
            
            CGFloat deviceW = KScreenWidth;
            CGFloat deviceH = KScreenHeight;
            CGFloat min = MIN(deviceW, deviceH);
            CGFloat max = MAX(deviceW, deviceH);
            CGFloat topSpace = [self videoTopSpace];
            CGFloat bottomH = CGRectGetHeight(self.bottomOperateView.frame);
            CGFloat bottomSpace = kiphoneXHomeBarHeight;
            if (bottomH <= 0) {
                bottomH = 60;
            }
            max = max - kZegoPlaySmallViewScale * min - topSpace - 24 - bottomH - bottomSpace;
            return max;
        }
    }
}

- (CGFloat)videoTopSpace {
    if (self.videoModel && self.videoModel.isFull) {
        return 0;
    } else {
        if (self.isLandscapeScreen) {
            return 0;
        } else {
            CGFloat topY = IPHONE_X_5_15 ? 75 : kTopBarViewHeight;
            return topY;
        }
    }
}

- (void)baseVidoeHandle {
    
    self.navBarView.isVideo = YES;
    self.isZegoHistoryComment = YES;
    self.stateCoverView.hidden = YES;
    [self.bottomOperateView showCommentView:YES];
    
    if (self.videoModel.isFull) {
        [self.videoPlayOperateView showFullButton:NO];
    } else {
        [self.videoPlayOperateView showFullButton:YES];
    }
    
}

#pragma mark 登录处理
- (void)checkDeviceIsLandscape:(void (^)(void))completion {
    
    BOOL isLandscape = NO;
    ZFNavigationController *nav = (ZFNavigationController *)self.navigationController;
    if (nav.interfaceOrientation == UIInterfaceOrientationLandscapeRight || nav.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.isLandscapeScreen) {
        isLandscape = YES;
    }
    @weakify(self)
    if (isLandscape) {
        
        if (![AccountManager sharedManager].isSignIn) {
            [self forceOrientation:AppForceOrientationPortrait];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.isStatusBarHidden = NO;
            [self judgePresentLoginVCCompletion:^{
                @strongify(self)
                self.isStatusBarHidden = YES;
                if (completion) {
                    completion();
                }
            }];
        });
        
    } else {
        self.isStatusBarHidden = NO;
        [self judgePresentLoginVCCompletion:^{
            @strongify(self)
            self.isStatusBarHidden = YES;
            if (completion) {
                completion();
            }
        }];
    }
    
}
#pragma mark  视频截图

- (void)updateTempImage {
    self.snapshotVideoImageView.image = [self.videoPlayView snapshotVideoImage];
}

#pragma mark  点击播放统计
/**
 点击播放统计
 */
- (void)requestPlayStatistics {
    if ([self.videoModel.state isEqualToString:@"1"]) {
        return;
    }
    @weakify(self);
    [self.liveViewModel requestCommunityLivePlayStatisticsLiveID:ZFToString(self.videoModel.idx) completion:^(NSString * _Nonnull status) {
        @strongify(self);
        if ([status isEqualToString:@"1"]) {
            self.videoModel.view_num = [NSString stringWithFormat:@"%li",([self.videoModel.view_num integerValue] + 1)];
            
            //111,222,333,444
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;

            self.videoModel.format_view_num = [formatter stringFromNumber:[NSNumber numberWithInteger:[self.videoModel.view_num integerValue]]];
            
            if(self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
                self.zegoLiveVideoView.lookNums = self.videoModel.format_view_num;
            }
            
            if (self.playNeedStatisticsBlock) {
                self.playNeedStatisticsBlock(self.videoModel);
            }
        }
    }];
}



#pragma mark  测试
// 测试订单消息推送
- (void)testPushOrder {
    
    if (self.testCount > 10) {
        return;
    }
    self.testCount++;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ZFZegoMessageInfo *message = [[ZFZegoMessageInfo alloc] init];
        message.type = @"5";
        message.nickname = @"occc";
        message.content = arc4random() % 2 ? @"dfoajfoajfdj jfajfdiosajfdsafidiajfd afidasjfi jfdaijfia" : @"dosajfd----xx";
        [[ZFVideoLiveCommentUtils sharedInstance].topShowMessageList addObject:message];
        [[ZFVideoLiveCommentUtils sharedInstance] refreshOrderPayCartNotif:message];
        
        [self testPushOrder];
    });
}

@end
