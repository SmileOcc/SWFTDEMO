//
//  ZFCommunityLiveVideoVC.m
//  ZZZZZ
//
//  Created by YW on 2019/4/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveVideoVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "IQKeyboardManager.h"

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

#import "ZFCommunityLiveVideoContentView.h"
#import "ZFGoodsDetailSelectTypeView.h"
#import "FacebookPlayView.h"
#import "YouTuBePlayerView.h"
#import "ZFZegoPlayerView.h"
#import "ZFCommunityLiveWaitView.h"
#import "YSAlertView.h"

#import "ZFCommunityLiveViewModel.h"
#import "ZFCommunityGoodsInfosModel.h"
#import "ZFGoodsDetailViewModel.h"
#import "ZFBannerModel.h"
#import "BannerManager.h"
#import "ZFTimerManager.h"
#import "ZFThemeManager.h"
#import "ZFBranchAnalytics.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFGrowingIOAnalytics.h"


static CGFloat kFacebookPlayViewHeight = 220.0f;
static CGFloat kZegoPlayViewScale = 0.5625;

@interface ZFCommunityLiveVideoVC ()<ZFInitViewProtocol,ZFLiveBaseViewDelegate,ZFZegoBasePlayerViewDelegate>

@property (nonatomic, strong) UIButton                          *shoppingCarBtn;
@property (nonatomic, strong) UIView                            *videoContainerView;
@property (nonatomic, strong) UIView                            *videoContentView;
@property (nonatomic, strong) UILabel                           *videoContentLabel;

@property (nonatomic, strong) FacebookPlayView                  *faceBookPlayView;
@property (nonatomic, strong) YouTuBePlayerView                 *youTuBePlayView;
@property (nonatomic, strong) ZFZegoPlayerView                  *zegoPlayerView;

@property (nonatomic, strong) ZFCommunityLiveWaitView           *coverView;
@property (nonatomic, strong) UIImageView                       *videoTempImageView;

@property (nonatomic, strong) ZFCommunityLiveVideoContentView   *mainView;
@property (nonatomic, strong) ZFGoodsDetailSelectTypeView       *attributeView;
@property (nonatomic, strong) UIActivityIndicatorView           *activityView;

@property (nonatomic, strong) ZFCommunityLiveViewModel          *liveViewModel;
@property (nonatomic, strong) ZFGoodsDetailViewModel            *goodsDetailViewModel;
@property (nonatomic, strong) ZFGoodsModel                      *currentSelectSimilarGoodsModel;
@property (nonatomic, strong) ZFCommunityVideoLiveGoodsModel    *liveGoodsModel;
@property (nonatomic, strong) ZFGoodsDetailCouponModel          *alertCouponModel;


@property (nonatomic, strong) NSTimer                           *alertGoodsTimer;
@property (nonatomic,assign) NSTimeInterval                     timerInterval;

@property (nonatomic, assign) CGFloat                           videoHeight;

//处理那个轮询查询
@property (nonatomic, assign) BOOL                              isNeedRepetRequest;

@property (nonatomic, assign) BOOL                              isCurrentVC;

@property (nonatomic, assign) BOOL                              isFirstEnter;
@end

@implementation ZFCommunityLiveVideoVC
@synthesize isStatusBarHidden = _isStatusBarHidden;

#pragma mark - Life Cycle

- (void)dealloc {
    
    if (self.playStatusBlock) {
        self.videoModel.like_num = [NSString stringWithFormat:@"%li",(long)[ZFVideoLiveCommentUtils sharedInstance].likeNums];
        self.playStatusBlock(self.videoModel);
    }
    
    if (_coverView) {
        [_coverView stopTimer];
    }
    
    [self invalidateTimer];
    if (_faceBookPlayView) {
        [self.faceBookPlayView removeAllJavaScriptMethod];
    }
    if (_mainView) {
        [self.mainView clearAllSeting];
    }

    if (_videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook) {
        
        if (_faceBookPlayView) {
            [_faceBookPlayView.operateView clearAllSeting];
            [_faceBookPlayView pauseVideo];
            [_faceBookPlayView removeAllSubviews];
            _faceBookPlayView = nil;
        }
        
    } else if(_videoModel.currentLivePlatform == ZFCommunityLivePlatformYouTube) {
        if (_youTuBePlayView) {
            [_youTuBePlayView.operateView clearAllSeting];
        }
    } else if(_videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {

        if (_zegoPlayerView) {
            [_zegoPlayerView stopVideo];
            [_zegoPlayerView clearAllStream];
            [_zegoPlayerView.operateView clearAllSeting];
        }
    }
    
    [[ZFVideoLiveCommentUtils sharedInstance] removeAllMessages];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshShppingCarBag];
    
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.fd_interactivePopDisabled = NO;

    [self resetTimer];
    self.isStatusBarHidden = YES;
    
    self.isCurrentVC = YES;

    // 处理第一次进来时，正在旋转中
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self forceOrientation:AppForceOrientationALL];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    });

    self.videoTempImageView.hidden = YES;
    [self startPlay];
    
    self.isNeedRepetRequest = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isCurrentVC = NO;
    [self forceOrientation:AppForceOrientationPortrait];
    self.isStatusBarHidden = NO;
    
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isNeedRepetRequest = NO;
    self.isFirstEnter = NO;
    [self invalidateTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.isCurrentVC = YES;
    self.isStatusBarHidden = YES;
    
    self.view.backgroundColor = ZFC0xF2F2F2();
    self.isFirstEnter = YES;
    [self zfInitView];
    [self zfAutoLayoutView];
    [self addNotification];
    
    if (self.videoModel) {
        self.liveID = ZFToString(self.videoModel.idx);
        [self loadVideoModel:self.videoModel];
        
    } else {
        [self requestLiveDetailInfo:self.liveID];
    }
    
    [self deletePreviousVCFromNavgation:[ZFCommunityFullLiveVideoVC class]];
}


- (void)setIsStatusBarHidden:(BOOL)isStatusBarHidden {
    _isStatusBarHidden = isStatusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(BOOL)prefersStatusBarHidden {
    return self.isStatusBarHidden;
}

- (void)addNotification {
    //监听UIWindow显示
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beginFullScreen:) name:UIWindowDidBecomeVisibleNotification object:nil];
    //监听UIWindow隐藏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshShppingCarBag) name:kCartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kLoginNotification object:nil];

}


- (void)zfInitView {
    
    self.videoHeight = KScreenWidth * 200 / 375.0;
    [self.view addSubview:self.videoContainerView];
    [self.videoContainerView addSubview:self.faceBookPlayView];
    [self.videoContainerView addSubview:self.youTuBePlayView];
    [self.videoContainerView addSubview:self.zegoPlayerView];
    [self.videoContainerView addSubview:self.videoTempImageView];
    
    [self.view addSubview:self.videoContentView];
    [self.videoContentView addSubview:self.videoContentLabel];
    [self.view addSubview:self.coverView];
    [self.view addSubview:self.mainView];
    [self.view addSubview:self.attributeView];
    
    [self.view bringSubviewToFront:self.videoContainerView];
    [self.view bringSubviewToFront:self.coverView];
}

- (void)zfAutoLayoutView {
    
    [self.videoContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(self.videoHeight);
    }];
    
    [self.videoTempImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.videoContainerView);
    }];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(self.videoHeight);
    }];
    
    [self.videoContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.videoContainerView.mas_bottom);
    }];
    
    [self.videoContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.videoContentView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.videoContentView.mas_trailing).offset(-16);
        make.top.mas_equalTo(self.videoContentView.mas_top).offset(10);
        make.bottom.mas_equalTo(self.videoContentView.mas_bottom).offset(-10);
    }];
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.videoContentView.mas_bottom).offset(12);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-kiphoneXHomeBarHeight);
    }];
    
    [self.attributeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
    
    
    [self.videoContainerView setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisVertical];
    [self.videoContainerView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];

}

#pragma mark - Request

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
    
    ShowLoadingToView(self.view);
    @weakify(self);
    [self.liveViewModel requestCommunityLiveDetailLiveID:ZFToString(self.liveID) completion:^(ZFCommunityLiveListModel * _Nonnull liveModel) {
        @strongify(self);
        
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


// 直播过程中，才获取数据
- (void)requestLiveGoodsInfo {
    
    if ([self.videoModel.type integerValue] != ZFCommunityLiveStateLiving) {
        return;
    }
    
    if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
        return;
    }
    
    
    // 添加random防止缓存
    NSString *file = [NSString stringWithFormat:@"%@?random=%d",ZFToString(self.videoModel.file),arc4random() % 10000];
    [self.liveViewModel requestCommunityLiveDetailLiveGoods:file completion:^(ZFCommunityVideoLiveGoodsModel * _Nonnull liveGoodsModel) {
        
        if (liveGoodsModel) {
            if (!ZFIsEmptyString(liveGoodsModel.goods_sn)) {
                if (!ZFIsEmptyString(liveGoodsModel.time)) {
                    if (![liveGoodsModel.time isEqualToString:ZFToString(self.liveGoodsModel.time)]) {
                        self.liveGoodsModel = liveGoodsModel;
                        
                        //显示弹窗视图
                        if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook) {
                            [self.faceBookPlayView showGoodsAlertView:self.liveGoodsModel];
                        } else if(self.videoModel.currentLivePlatform == ZFCommunityLivePlatformYouTube) {
                            [self.youTuBePlayView showGoodsAlertView:self.liveGoodsModel];
                        }
                    }
                }
            }
            
            if (self.liveGoodsModel) { // 默认设置10s
                self.liveGoodsModel.timerInterval = liveGoodsModel.timerInterval > 0 ? liveGoodsModel.timerInterval : 10;

            }
        }
        
        self.timerInterval = self.liveGoodsModel ? self.liveGoodsModel.timerInterval : 10;
        [self repeateRequestLiveGoodsInfo];
    }];
    
}

- (void)repeateRequestLiveGoodsInfo {
    
    YWLog(@"--------  开始重复查询 ------");
    if ([self.videoModel.type integerValue] != ZFCommunityLiveStateLiving) {
        return;
    }
    
    if (self.isNeedRepetRequest) {
        if (self.timerInterval > 0) {
            if (!_alertGoodsTimer) {
                [self resetTimer];
            } else {
                if (self.timerInterval != self.liveGoodsModel.timerInterval) {
                    [self resetTimer];
                }
            }
        }
    }
}

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
            
            if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook) {
                self.faceBookPlayView.lookNums = self.videoModel.format_view_num;
                
            } else if(self.videoModel.currentLivePlatform == ZFCommunityLivePlatformYouTube) {
                self.youTuBePlayView.lookNums = self.videoModel.format_view_num;
                
            } else if(self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
                self.zegoPlayerView.lookNums = self.videoModel.format_view_num;
            }
            
            if (self.playNeedStatisticsBlock) {
                self.playNeedStatisticsBlock(self.videoModel);
            }
        }
    }];
}


#pragma mark - Action

- (void)startPlay {
    
    if (self.videoModel) {
        if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook) {
            if (!self.isFirstEnter) {
                [self.faceBookPlayView startVideo];
            }
        } else if(self.videoModel.currentLivePlatform == ZFCommunityLivePlatformYouTube) {
            [self.youTuBePlayView startVideo];
        } else if(self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
            [self.zegoPlayerView startVideo];
        }
    }
}

- (void)pausePlay {
    if (self.videoModel) {
        if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook) {
            [self.faceBookPlayView pauseVideo];
        } else if(self.videoModel.currentLivePlatform == ZFCommunityLivePlatformYouTube) {
            [self.youTuBePlayView pauseVideo];
        } else if(self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
            [self.zegoPlayerView pauseVideo];
        }
    }
}


/// 刷新购物车数量
- (void)refreshShppingCarBag {
//    NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
//    [self.shoppingCarBtn showShoppingCarsBageValue:[badgeNum integerValue]];
}

- (void)loadVideoModel:(ZFCommunityLiveListModel *)videoModel {
    
    self.title = ZFToString(self.videoModel.title);
    self.videoContentLabel.text = ZFToString(videoModel.content);
    
    if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook) {
        CGFloat facebookH = KScreenWidth * kFacebookPlayViewHeight / 375.0;
        if (self.videoHeight != facebookH) {
            self.videoHeight = facebookH;
            [self.videoContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.videoHeight);
            }];
            
            [self.coverView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.videoHeight);
            }];
        }
    } else if(self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {//zego：视频比例是16：9
        CGFloat zegoH = KScreenWidth * kZegoPlayViewScale;
        if (self.videoHeight != zegoH) {
            self.videoHeight = zegoH;
            [self.videoContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.videoHeight);
            }];
            
            [self.coverView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.videoHeight);
            }];
        }
    }
    
    if ([videoModel.type integerValue] == ZFCommunityLiveStateEnd) {//已结束
        self.coverView.hidden = YES;
        [self platformPlay:videoModel];
        
    } else if ([videoModel.type integerValue] ==ZFCommunityLiveStateLiving) {//开始
       
        self.coverView.hidden = YES;
        [self platformPlay:videoModel];
        
        /// 直播平台 1Facebook 2YouTube
        if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformYouTube) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self requestLiveGoodsInfo];
            });
        }
        
    } else if ([videoModel.type integerValue] == ZFCommunityLiveStateReady) {//待播

        
        
        // 如果是zego直播的，进来就开始登录，且zego中有倒计时处理
        if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {//
            [self firstStartPlayZegoPlayer:videoModel];
            
        } else {
            
            self.coverView.hidden = NO;
            ZFCommunityLiveWaitInfor *waitInforModel = [[ZFCommunityLiveWaitInfor alloc] init];
            waitInforModel.startTimerKey = [NSString stringWithFormat:@"%@_%@",@"liveVideo",videoModel.idx];
            waitInforModel.time = videoModel.time;
            waitInforModel.content = ZFLocalizedString(@"Community_LivesVideo_Host_No_Arrived_Msg", nil);
            self.coverView.inforModel = waitInforModel;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadActivityTime) name:kTimerManagerUpdate object:nil];
        }
        
    }
    
    
    ZFCommunityLiveVideoMenuCateModel *goodsCateModel = [[ZFCommunityLiveVideoMenuCateModel alloc] init];
    goodsCateModel.cateName = ZFLocalizedString(@"Community_Lives_Live_Goods", nil);
    goodsCateModel.cateId = ZFToString(videoModel.live_code);
    goodsCateModel.skus = ZFToString(videoModel.skus); 

    
    ZFCommunityLiveVideoMenuCateModel *chatCateModel = [[ZFCommunityLiveVideoMenuCateModel alloc] init];
    chatCateModel.cateName = [videoModel.type isEqualToString:@"3"] ? ZFLocalizedString(@"Live_Comment", nil) : ZFLocalizedString(@"Live_Chat", nil);
    chatCateModel.cateId = ZFToString(videoModel.live_code);
    chatCateModel.skus = ZFToString(videoModel.skus);
    chatCateModel.isChat = YES;
    
    ZFCommunityLiveVideoMenuCateModel *releateCateModel = [[ZFCommunityLiveVideoMenuCateModel alloc] init];
    releateCateModel.cateName = ZFLocalizedString(@"Community_LivesVideo_Host", nil);
    releateCateModel.cateId = @"releatesid";

    
    if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
        
        [_mainView updateMenuViewDatas:@[goodsCateModel,chatCateModel,releateCateModel] liveModel:videoModel];
        [_mainView updateMenuModel:chatCateModel index:1];
        [ZFVideoLiveCommentUtils sharedInstance].roomId = videoModel.room_id;
        [ZFVideoLiveCommentUtils sharedInstance].liveDetailID = videoModel.idx;
        [ZFVideoLiveCommentUtils sharedInstance].likeNums = [videoModel.like_num integerValue];
        [ZFVideoLiveCommentUtils sharedInstance].liveType = videoModel.type;
        
        //直播未开始时，可以获取历史数据,如果开始时，又要隐藏
        if (![videoModel.type isEqualToString:@"2"]) {
            self.mainView.isZegoHistoryComment = YES;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[ZFVideoLiveCommentUtils sharedInstance] refreshLikeNumsAnimate:NO];

        });

    } else {
        [_mainView updateMenuViewDatas:@[goodsCateModel,releateCateModel] liveModel:videoModel];
    }
    
    //播放点击
    [self requestPlayStatistics];
    
    NSDictionary *params = @{ @"af_content_type": @"zmelive",
                              @"af_content_id" : ZFToString(videoModel.idx),
                              };
    [ZFAnalytics appsFlyerTrackEvent:@"af_view_zmelive" withValues:params];
}


- (void)platformPlay:(ZFCommunityLiveListModel *)videoModel {
    
    if (!self.activityView.superview) {
        [self.view addSubview:self.activityView];
        [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(self.view.mas_top).offset(self.videoHeight/2-10);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
            [self.activityView stopAnimating];
            self.activityView.hidden = YES;
        }
    }
    if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook) {
        
        self.faceBookPlayView.sourceView = self.videoContainerView;
        self.faceBookPlayView.sourceVideoAddress = ZFToString(videoModel.live_address);
        self.faceBookPlayView.videoDetailID = self.liveID;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        self.videoModel.format_view_num = [formatter stringFromNumber:[NSNumber numberWithInteger:[self.videoModel.view_num integerValue]]];
        self.faceBookPlayView.lookNums = ZFToString(self.videoModel.format_view_num);
        [self.faceBookPlayView basePlayVideoWithVideoID:ZFToString(videoModel.live_address)];

        self.youTuBePlayView.hidden = YES;
        self.zegoPlayerView.hidden = YES;
        self.faceBookPlayView.hidden = NO;
        
        if (![ZFNetworkManager isReachableViaWiFi]) { // WiFi自动播放,流量暂停
            [self.faceBookPlayView pauseVideo];
        }
    } else  if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformYouTube) {
        
        self.youTuBePlayView.hidden = NO;
        self.faceBookPlayView.hidden = YES;
        self.zegoPlayerView.hidden = YES;
        self.youTuBePlayView.sourceView = self.videoContainerView;

        NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        self.videoModel.format_view_num = [formatter stringFromNumber:[NSNumber numberWithInteger:[self.videoModel.view_num integerValue]]];
        
        self.youTuBePlayView.lookNums = ZFToString(self.videoModel.format_view_num);
        self.youTuBePlayView.sourceVideoAddress = ZFToString(videoModel.live_address);
        self.youTuBePlayView.videoDetailID = self.liveID;

        if (![ZFNetworkManager isReachableViaWiFi] && ![AccountManager sharedManager].isNoWiFiPlay) { // WiFi自动播放,流量暂停
            
            NSString *message = ZFLocalizedString(@"Community_LivesVideo_No_Wifi_Play_Msg",nil);
            NSString *noTitle = ZFLocalizedString(@"Community_LivesVideo_No_Wifi_Play_Cancel",nil);
            NSString *yesTitle = ZFLocalizedString(@"Community_LivesVideo_No_Wifi_Play_OK",nil);
            
            ShowAlertView(nil, message, @[yesTitle], ^(NSInteger buttonIndex, id buttonTitle) {
                [self.youTuBePlayView basePlayVideoWithVideoID:ZFToString(videoModel.live_address)];
                [AccountManager sharedManager].isNoWiFiPlay = YES;
            }, noTitle, ^(id cancelTitle) {
            });

        } else {
            [self.youTuBePlayView basePlayVideoWithVideoID:ZFToString(videoModel.live_address)];
        }
    } else  if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {// zego直播
        [self firstStartPlayZegoPlayer:videoModel];
    }
    
    
    // 防止视频播放之前有一段黑色间隔
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.activityView stopAnimating];
    });
    
}

- (void)firstStartPlayZegoPlayer:(ZFCommunityLiveListModel *)videoModel {
    
    self.youTuBePlayView.hidden = YES;
    self.faceBookPlayView.hidden = YES;
    self.zegoPlayerView.hidden = NO;
    self.zegoPlayerView.sourceView = self.videoContainerView;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    self.videoModel.format_view_num = [formatter stringFromNumber:[NSNumber numberWithInteger:[self.videoModel.view_num integerValue]]];
    
    self.zegoPlayerView.lookNums = ZFToString(self.videoModel.format_view_num);
    [ZFVideoLiveCommentUtils sharedInstance].liveType = videoModel.type;
    self.zegoPlayerView.sourceVideoAddress = ZFToString(videoModel.live_replay_url);
    self.zegoPlayerView.liveVideoID = ZFToString(videoModel.live_replay_url);
    self.zegoPlayerView.videoDetailID = self.liveID;
    self.zegoPlayerView.roomID = ZFToString(self.videoModel.room_id);
    //self.zegoPlayerView.streamID = ZFToString(self.videoModel.stream_id);
    self.zegoPlayerView.thirdStreamID = ZFToString(self.videoModel.live_address);
    
    if ([videoModel.type isEqualToString:@"3"]) {// 录播
        [self.zegoPlayerView configurationLiveType:ZegoBasePlayerTypeVideo firstStart:YES];
        
    } else {//直播
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zegoLiveDownTimeEnd) name:kLiveZegoCoverStateTimerEnd object:nil];

        if ([videoModel.type isEqualToString:@"1"]) {
            ZFVideoLiveZegoCoverWaitInfor *waitInforModel = [[ZFVideoLiveZegoCoverWaitInfor alloc] init];
            waitInforModel.startTimerKey = [NSString stringWithFormat:@"%@_%@",@"liveVideo",videoModel.idx];
            waitInforModel.time = videoModel.time;
            waitInforModel.content = ZFLocalizedString(@"Community_LivesVideo_Host_No_Arrived_Msg", nil);
            self.zegoPlayerView.inforModel = waitInforModel;
        }
        
        self.zegoPlayerView.roomID = ZFToString(self.videoModel.room_id);
        BOOL isLiveStart = [videoModel.type isEqualToString:@"1"] ? NO : YES;
        
        ZegoBasePlayerType playerType = ZegoBasePlayerTypeLiving;
        if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
            self.zegoPlayerView.streamID = @"";
            playerType = ZegoBasePlayerTypeThirdStream;
        }
        
        [self.zegoPlayerView configurationLiveType:playerType firstStart:isLiveStart];
    }
}

/**
 活动倒计时结束事件
 */
- (void)reloadActivityTime {
    int timeOut =  [self.coverView.inforModel.time doubleValue] - [[ZFTimerManager shareInstance] timeInterval:self.coverView.inforModel.startTimerKey];
    
    int leftTimeOut = [[ZFTimerManager shareInstance] timeInterval:self.coverView.inforModel.startTimerKey];
    
    YWLog(@"----------- 视频活动倒计时 : %i -- left: %i",timeOut,leftTimeOut);
    
    if(timeOut <= 0 || leftTimeOut <= 0){ //倒计时结束，关闭
        self.coverView.inforModel.time = @"";
        [self.coverView stopTimer];
        self.coverView.hidden = YES;
        self.videoModel.type = @"2";
        
        // 如果是zego直播时，已经初始了，只要判断是否需要重新登录
        if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
            if (!self.zegoPlayerView.loginRoomSuccess) {
                [self.zegoPlayerView reLoginRoom];
            }
        } else {
            [self platformPlay:self.videoModel];
        }
        
        /// 直播平台 1Facebook 2YouTube
        if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformYouTube) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self requestLiveGoodsInfo];
            });
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kTimerManagerUpdate object:nil];
        
        if (self.playStatusBlock) {
            self.playStatusBlock(self.videoModel);
        }
    }
}

// Zego直播倒计时结束触发
- (void)zegoLiveDownTimeEnd {
    
    self.videoModel.type = @"2";
    // 如果是zego直播时，已经初始了，只要判断是否需要重新登录
    if (!self.zegoPlayerView.loginRoomSuccess) {
        [self.zegoPlayerView reLoginRoom];
    }
    
    if (self.playStatusBlock) {
        self.playStatusBlock(self.videoModel);
    }
}


#pragma mark - ZFLiveBaseViewDelegate

- (void)zfLiveBasePlayer:(ZFLiveBaseView *)playerView tapBlack:(BOOL)tap {
    if (playerView.isFullScreen) {
        [self forceOrientation:AppForceOrientationPortrait];
    } else {
        [self goBackAction];
    }
}

- (void)zfLiveBasePlayer:(ZFLiveBaseView *)playerView tapScreenFull:(BOOL)isFullScreen {
    if (isFullScreen) {
        [self actionForceOrientationLandscape];
    } else {
        [self forceOrientation:AppForceOrientationPortrait];
    }
}

- (void)zfLiveBasePlayer:(ZFLiveBaseView *)playerView tapGoods:(ZFGoodsModel *)tapGoods {
    
    [self forceOrientation:AppForceOrientationPortrait];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self jumpToGoodsDetail:tapGoods];
    });
}

- (void)zfLiveBasePlayer:(ZFLiveBaseView *)playerView similarGoods:(ZFGoodsModel *)tapGoods {
 
    // 不然调整动画不好
    [self forceOrientation:AppForceOrientationPortrait];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self jumpToSimilar:tapGoods];
    });
}

- (void)zfLiveBasePlayer:(ZFLiveBaseView *)playerView tapCart:(BOOL)tap {
    // 不然调整动画不好
    [self forceOrientation:AppForceOrientationPortrait];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self jumpToCartAction];
    });
}

- (void)zfLiveBasePlayer:(ZFLiveBaseView *)playerView tapAlertCart:(ZFGoodsModel *)goodsModel {
    [self addCartGoods:goodsModel];
}

#pragma mark - ZFZegoBasePlayerViewDelegate

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)playerView tapBlack:(BOOL)tap {
    if (playerView.isFullScreen) {
        [self forceOrientation:AppForceOrientationPortrait];
    } else {
        [self goBackAction];
    }
}

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)playerView liveCoverStateBlack:(LiveZegoCoverState )state {
    
    if (state == LiveZegoCoverStateNetworkNrror) {
        [self.zegoPlayerView reLoginRoom];
    } else if(state == LiveZegoCoverStateJustLive || state == LiveZegoCoverStateEnd) {
        
        if (playerView.isFullScreen) {
            [self forceOrientation:AppForceOrientationPortrait];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self goBackAction];
            });
        } else {
            [self goBackAction];
        }
    }
}

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)playerView tapScreenFull:(BOOL)isFullScreen {
    if (isFullScreen) {
        [self actionForceOrientationLandscape];
    } else {
        [self forceOrientation:AppForceOrientationPortrait];
    }
}

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)playerView tapGoods:(ZFGoodsModel *)tapGoods {
    
    [self forceOrientation:AppForceOrientationPortrait];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self jumpToGoodsDetail:tapGoods];
    });
}

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)playerView similarGoods:(ZFGoodsModel *)tapGoods {
    
    // 不然调整动画不好
    [self forceOrientation:AppForceOrientationPortrait];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self jumpToSimilar:tapGoods];
    });
}

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)playerView tapCart:(BOOL)tap {
    // 不然调整动画不好
    [self forceOrientation:AppForceOrientationPortrait];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self jumpToCartAction];
    });
}

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)playerView tapAlertCart:(ZFGoodsModel *)goodsModel {
    [self addCartGoods:goodsModel];
}


#pragma mark - Private Method

/// 进入购物车
- (void)jumpToCartAction {
    [self pausePlay];
    ZFCartViewController *cartVC = [[ZFCartViewController alloc] init];
    [self.navigationController pushViewController:cartVC animated:YES];
}

/// 找相似
- (void)jumpToSimilar:(ZFGoodsModel *)goodsModel {
    [self pausePlay];
    ZFUnlineSimilarViewController *unlineSimilarViewController = [[ZFUnlineSimilarViewController alloc] initWithImageURL:goodsModel.wp_image sku:goodsModel.goods_sn];
    unlineSimilarViewController.sourceType = ZFAppsflyerInSourceTypeSearchImageitems;
    [self.navigationController pushViewController:unlineSimilarViewController animated:YES];
}

/// 商品详情
- (void)jumpToGoodsDetail:(ZFGoodsModel *)goodsModel {
    
    self.isStatusBarHidden = NO;

    
    ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
    detailVC.goodsId    = goodsModel.goods_id;
    detailVC.sourceType = ZFAppsflyerInSourceTypeZMeLiveDetail;
    detailVC.sourceID = ZFToString(self.liveID);
    //FIXME: occ Bug 1101 最好是播放中的
    if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook) {
        detailVC.playerView = self.faceBookPlayView;
    } else if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformYouTube) {
        detailVC.playerView = self.youTuBePlayView;
    } else if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
        detailVC.playerView = self.zegoPlayerView;
    }
    
    if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformYouTube) {
        
        ZFLiveBaseView *basePlayeView = detailVC.playerView;
        //视频截图
        UIGraphicsBeginImageContextWithOptions(basePlayeView.webView.bounds.size, YES,[UIScreen mainScreen].scale);
        [basePlayeView.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
        [basePlayeView.webView drawViewHierarchyInRect:basePlayeView.webView.bounds afterScreenUpdates:YES];
        UIImage *currentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.videoTempImageView.image = currentImage;
        self.videoTempImageView.hidden = NO;
        
    } else if(self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
        
        ZFZegoBasePlayerView *zegoBasePlayrView = (ZFZegoBasePlayerView *)detailVC.playerView;
        //视频截图
        UIGraphicsBeginImageContextWithOptions(zegoBasePlayrView.videoConterView.bounds.size, YES,[UIScreen mainScreen].scale);
        [zegoBasePlayrView.videoConterView.layer renderInContext:UIGraphicsGetCurrentContext()];
        [zegoBasePlayrView.videoConterView drawViewHierarchyInRect:zegoBasePlayrView.videoConterView.bounds afterScreenUpdates:YES];
        UIImage *currentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.videoTempImageView.image = currentImage;
        self.videoTempImageView.hidden = NO;
    }
    
    @weakify(self)
    detailVC.goodsDetailSuccessBlock = ^(BOOL flag) {
        @strongify(self)
        if ([self.videoModel.type integerValue] != ZFCommunityLiveStateReady) {
            
            if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook) {
                CGFloat w = CGRectGetWidth(self.faceBookPlayView.frame) / 2.5;
                CGFloat h = CGRectGetHeight(self.faceBookPlayView.frame) / 2.5;
                [self.faceBookPlayView showToWindow:CGSizeMake(w, h)];
                
            } else if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformYouTube) {
                CGFloat w = CGRectGetWidth(self.youTuBePlayView.frame) / 2.5;
                CGFloat h = CGRectGetHeight(self.youTuBePlayView.frame) / 2.5;
                [self.youTuBePlayView showToWindow:CGSizeMake(w, h)];
                
            } else if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
                CGFloat w = CGRectGetWidth(self.youTuBePlayView.frame) / 2.5;
                CGFloat h = CGRectGetHeight(self.youTuBePlayView.frame) / 2.5;
                [self.zegoPlayerView showToWindow:CGSizeMake(w, h)];
            }
        }
    };
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

- (void)openWebInfoWithUrl:(NSString *)url title:(NSString *)title {
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
- (void)addCartGoods:(ZFGoodsModel *)goodsModel {
    
    [self.view bringSubviewToFront:self.attributeView];
    self.currentSelectSimilarGoodsModel = goodsModel;
    //获取商品详情接口
    @weakify(self)
    NSString *goosID = ZFToString(goodsModel.goods_id);
    [self requestGoodsDetailInfo:goosID successBlock:^(GoodsDetailModel *goodsDetailInfo) {
        @strongify(self)
        self.attributeView.model = goodsDetailInfo;
        [self.attributeView openSelectTypeView];
        [self addToBagBeforeViewProduct:goodsDetailInfo];
    }];
}

// 切换属性
- (void)changeGoodsAttribute:(NSString *)goodsId {
    if (self.currentSelectSimilarGoodsModel) {
        self.currentSelectSimilarGoodsModel.selectSkuCount += 1;
    }
    //获取商品详情接口
    @weakify(self)
    [self requestGoodsDetailInfo:ZFToString(goodsId) successBlock:^(GoodsDetailModel *goodsDetailInfo) {
        @strongify(self)
        self.attributeView.model = goodsDetailInfo;
        [self addToBagBeforeViewProduct:goodsDetailInfo];
    }];
}

//添加购物车
- (void)addGoodsToCartOption:(NSString *)goodsId goodsCount:(NSInteger)goodsCount {
    
    @weakify(self);
    [self.goodsDetailViewModel requestAddToCart:ZFToString(goodsId) loadingView:self.view goodsNum:goodsCount completion:^(BOOL isSuccess) {
        @strongify(self);
        
        if (isSuccess) {
            [self startAddCartSuccessAnimation];
            [self changeCartNumAction];
            
            //添加商品至购物车事件统计
            self.attributeView.model.buyNumbers = goodsCount;
            NSString *goodsSN = self.attributeView.model.goods_sn;
            NSString *spuSN = @"";
            if (goodsSN.length > 7) {  // sn的前7位为同款id
                spuSN = [goodsSN substringWithRange:NSMakeRange(0, 7)];
            }else{
                spuSN = goodsSN;
            }
            
            NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
            valuesDic[AFEventParamContentId] = ZFToString(goodsSN);
            valuesDic[@"af_spu_id"] = ZFToString(spuSN);
            valuesDic[AFEventParamPrice] = ZFToString(self.attributeView.model.shop_price);
            valuesDic[AFEventParamQuantity] = [NSString stringWithFormat:@"%zd",goodsCount];
            valuesDic[AFEventParamContentType] = @"product";
            valuesDic[@"af_content_category"] = ZFToString(self.attributeView.model.long_cat_name);
            valuesDic[AFEventParamCurrency] = @"USD";
            valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeZMeLiveDetail sourceID:ZFToString(self.videoModel.idx)];
            
            valuesDic[@"af_changed_size_or_color"] = (self.currentSelectSimilarGoodsModel.selectSkuCount > 0) ? @"1" : @"0";
            valuesDic[BigDataParams]           = @[[self.attributeView.model gainAnalyticsParams]];
            valuesDic[@"af_purchase_way"]      = @"1";//V5.0.0增加, 判断是否为一键购买(0)还是正常加购(1)
            [ZFAnalytics appsFlyerTrackEvent:@"af_add_to_bag" withValues:valuesDic];
            //Branch
            [[ZFBranchAnalytics sharedManager] branchAddToCartWithProduct:self.attributeView.model number:goodsCount];
            [ZFFireBaseAnalytics addToCartWithGoodsModel:self.attributeView.model];
            [ZFGrowingIOAnalytics ZFGrowingIOAddCart:self.attributeView.model];
            
        } else {
            [self.attributeView bottomCartViewEnable:YES];
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
    valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeZMeLiveDetail sourceID:nil];
    valuesDic[@"af_changed_size_or_color"] = @"1";
    valuesDic[BigDataParams]           = [detailModel gainAnalyticsParams];
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_view_product" withValues:valuesDic];
    [ZFGrowingIOAnalytics ZFGrowingIOProductDetailShow:detailModel];
}

- (void)changeCartNumAction {
    [self.attributeView changeCartNumberInfo];
}


- (void)startAddCartSuccessAnimation {
    @weakify(self)
    [self.attributeView startAddCartAnimation:^{
        @strongify(self)
        [self.attributeView hideSelectTypeView];
    }];
}

/// Zego直播中时显示
- (void)updateZegoLivingChatMenu {
    
    if (_mainView.menuView.datasArray.count >= 3) {
        ZFCommunityLiveVideoMenuCateModel *chatCateModel = _mainView.menuView.datasArray[1];
        if ([chatCateModel isKindOfClass:[ZFCommunityLiveVideoMenuCateModel class]]) {
            if (![chatCateModel.cateName isEqualToString:ZFLocalizedString(@"Live_Chat", nil)]) {
                chatCateModel.cateName = ZFLocalizedString(@"Live_Chat", nil);
                [_mainView updateMenuModel:chatCateModel index:1];
            }
        }
    }
}


#pragma mark - Timer

- (void)invalidateTimer {
    if (_alertGoodsTimer) {
        self.alertGoodsTimer.fireDate = [NSDate distantFuture];
        [_alertGoodsTimer invalidate];
        _alertGoodsTimer = nil;
    }
}

- (void)pauseTimer {
    if (_alertGoodsTimer) {
        self.alertGoodsTimer.fireDate = [NSDate distantFuture];
    }
}

- (void)resumeTimer {
    if (_alertGoodsTimer) {
        self.alertGoodsTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.timerInterval];
    }
}

- (void)resetTimer {
    [self invalidateTimer];
    if (self.timerInterval <= 0) {
        self.timerInterval = 10;
    }
    
    //zego直播不需要轮询
    if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
        return;
    }
    _alertGoodsTimer = [NSTimer timerWithTimeInterval:self.timerInterval target:self selector:@selector(requestLiveGoodsInfo) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.alertGoodsTimer forMode:NSRunLoopCommonModes];
}

#pragma mark - Property Method

- (ZFCommunityLiveViewModel *)liveViewModel {
    if (!_liveViewModel) {
        _liveViewModel = [[ZFCommunityLiveViewModel alloc] init];
    }
    return _liveViewModel;
}

- (FacebookPlayView *)faceBookPlayView {
    if (!_faceBookPlayView) {
        CGFloat facebookH = KScreenWidth * kFacebookPlayViewHeight / 375.0;

        _faceBookPlayView = [[FacebookPlayView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, facebookH)];
        _faceBookPlayView.backgroundColor = [UIColor blackColor];
        _faceBookPlayView.hidden = YES;
        _faceBookPlayView.delegate = self;
    }
    return _faceBookPlayView;
}

- (YouTuBePlayerView *)youTuBePlayView {
    if (!_youTuBePlayView) {
        _youTuBePlayView = [[YouTuBePlayerView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, self.videoHeight)];
        _youTuBePlayView.backgroundColor = [UIColor blackColor];
        _youTuBePlayView.hidden = YES;
        _youTuBePlayView.delegate = self;
    }
    return _youTuBePlayView;
}

- (ZFZegoPlayerView *)zegoPlayerView {
    if (!_zegoPlayerView) {
        _zegoPlayerView = [[ZFZegoPlayerView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenWidth * kZegoPlayViewScale)];
        _zegoPlayerView.backgroundColor = [UIColor blackColor];
        _zegoPlayerView.hidden = YES;
        
        @weakify(self)
        _zegoPlayerView.livePlayingBlock = ^(BOOL playing) {
            @strongify(self)
            if (!self.coverView.isHidden) {
                self.coverView.hidden = YES;
                [self.coverView stopTimer];
            }
            [self updateZegoLivingChatMenu];
            self.mainView.isZegoHistoryComment = NO;

        };
        _zegoPlayerView.delegate = self;
    }
    return _zegoPlayerView;
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

- (ZFCommunityLiveWaitView *)coverView {
    if (!_coverView) {
        _coverView = [[ZFCommunityLiveWaitView alloc] initWithFrame:CGRectZero];
        _coverView.backgroundColor = ZFC0x666666();
        _coverView.hidden = YES;
        @weakify(self)
        _coverView.gobackBlock = ^(BOOL flag) {
            @strongify(self)
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        _coverView.cartBlock = ^(BOOL flag) {
            @strongify(self)
            [self forceOrientation:AppForceOrientationPortrait];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self jumpToCartAction];
            });
        };
    }
    return _coverView;
}

- (ZFCommunityLiveVideoContentView *)mainView {
    if (!_mainView) {
        CGFloat height = KScreenHeight - kiphoneXTopOffsetY - kiphoneXHomeBarHeight - 44 - self.videoHeight;
        _mainView = [[ZFCommunityLiveVideoContentView alloc] initWithFrame:CGRectMake(0, self.videoHeight, KScreenWidth, height)];
        _mainView.backgroundColor = ZFC0xFFFFFF();
        _mainView.layer.masksToBounds = YES;
        
        @weakify(self)
        _mainView.videoAddCartBlock = ^(ZFGoodsModel * _Nonnull goodsModel) {
            @strongify(self)
            [self addCartGoods:goodsModel];
        };
        
        _mainView.videoSelectGoodsBlock = ^(ZFGoodsModel * _Nonnull goodsModel) {
            @strongify(self)
            [self jumpToGoodsDetail:goodsModel];
        };
        
        _mainView.videoActivityBllock = ^(NSString * _Nonnull deeplink) {
            @strongify(self)
            [self openWebInfoWithUrl:deeplink title:@""];
        };
        
        _mainView.videoSimilarGoodsBlock = ^(ZFGoodsModel * _Nonnull goodsModel) {
            @strongify(self)
            [self jumpToSimilar:goodsModel];
        };
        
        _mainView.goodsArrayBlock = ^(NSMutableArray<ZFGoodsModel *> *goodsArray) {
            @strongify(self)
            if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook) {
                self.faceBookPlayView.recommendGoods = goodsArray;
                
            } else if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformYouTube) {
                self.youTuBePlayView.recommendGoods = goodsArray;
                
            } else if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
                self.zegoPlayerView.recommendGoods = goodsArray;
            }
        };
        
    }
    return _mainView;
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


- (UIView *)videoContainerView {
    if (!_videoContainerView) {
        _videoContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, self.videoHeight)];
        _videoContainerView.backgroundColor = [UIColor blackColor];
    }
    return _videoContainerView;
}

- (UIView *)videoContentView {
    if (!_videoContentView) {
        _videoContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _videoContentView.backgroundColor = ZFC0xFFFFFF();
    }
    return _videoContentView;
}

- (UILabel *)videoContentLabel {
    if (!_videoContentLabel) {
        _videoContentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _videoContentLabel.textColor = ZFC0x2D2D2D();
        _videoContentLabel.font = [UIFont systemFontOfSize:14];
        _videoContentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _videoContentLabel.numberOfLines = 2;
    }
    return _videoContentLabel;
}

- (UIImageView *)videoTempImageView {
    if (!_videoTempImageView) {
        _videoTempImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _videoTempImageView.hidden = YES;
    }
    return _videoTempImageView;
}


#pragma mark - 横竖屏

///强制设置旋转
- (void)actionForceOrientationLandscape{
    [self forceOrientation:AppForceOrientationJustOnceLandscape];
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
        
        if (interfaceOrientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationPortrait == UIInterfaceOrientationMaskAllButUpsideDown) {
            [self handleCurrentInterfaceOrientationPortrait];
        } else if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            [self handleCurrentInterfaceOrientationLandscape];
        }
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

    [self orientationPortraitOrLandscape:device];
    
}

- (void)orientationPortraitOrLandscape:(UIDevice *)device {
    
    if (device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight) {
        [self handleCurrentInterfaceOrientationLandscape];
    } else if (device.orientation == UIDeviceOrientationPortrait){//垂直向下有问题
        [self handleCurrentInterfaceOrientationPortrait];
    }
}


- (void)handleCurrentInterfaceOrientationLandscape {
    
    self.fd_interactivePopDisabled = YES;
    [self.mainView fullScreen:YES];

    [self forceOrientation:AppForceOrientationLandscape];
    YWLog(@"------------------- 横屏 -----------------");
    
    CGFloat coverH = KScreenHeight > KScreenWidth ? KScreenWidth : KScreenHeight;

    [self.videoContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(coverH);
    }];
    
    if (!self.coverView.isHidden) {
        [self.coverView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(coverH);
        }];
    }
    
    [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(1000);
    }];
    [self.view layoutIfNeeded];
    
    if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook) {
        [self.faceBookPlayView fullScreen:YES];
        
    } else if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformYouTube){
        [self.youTuBePlayView fullScreen:YES];
        
    } else if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
        [self.zegoPlayerView fullScreen:YES];
    }
    
    if (_attributeView) {
        [self.attributeView hideSelectTypeView];
    }
}

- (void)handleCurrentInterfaceOrientationPortrait {
    
    self.fd_interactivePopDisabled = NO;
    [self.mainView fullScreen:NO];

    [self forceOrientation:AppForceOrientationPortrait];
    
    YWLog(@"------------------- 竖屏 -----------------");
    
    [self.videoContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.videoHeight);
    }];
    
    if (!self.coverView.isHidden) {
        [self.coverView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.videoHeight);
        }];
    }
    
    [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-kiphoneXHomeBarHeight);
    }];
    [self.view layoutIfNeeded];
    
    if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformFacebook) {
        [self.faceBookPlayView fullScreen:NO];
        
    }  else if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformYouTube){
        [self.youTuBePlayView fullScreen:NO];
        
    } else if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
        [self.zegoPlayerView fullScreen:NO];
    }
}

/**
 * 在部分机器上发现全屏播放完视频后会出现状态栏显示的bug
 */
- (void)endFullScreen {
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;

}

- (void)beginFullScreen:(NSNotification *)notif {
    
    // FB网页播放，第一次点击，感觉没反应，其实在加载数据
    if (!self.faceBookPlayView.isHidden) {
        YWLog(@"-----");
        if (self.activityView.isAnimating) {
            [self.activityView stopAnimating];
            YWLog(@"----- stopAnimating");
        } else  {
            [self.activityView startAnimating];
            YWLog(@"----- startAnimating");
        }
    }
}


- (void)loginChangeValue:(NSNotification *)notif {
    if (self.videoModel.currentLivePlatform == ZFCommunityLivePlatformZego || self.videoModel.currentLivePlatform == ZFCommunityLivePlatformThirdStream) {
        if (_zegoPlayerView) {
            [_zegoPlayerView reLoginRoom];
        }
    }
}
@end
