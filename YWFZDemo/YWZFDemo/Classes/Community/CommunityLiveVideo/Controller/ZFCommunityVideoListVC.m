//
//  VideoViewController.m
//  ZZZZZ
//
//  Created by YW on 16/11/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityVideoListVC.h"
#import "ZFCommunityVideoViewModel.h"
#import "ZFCommunityVideoCommentsCell.h"
#import "InputTextView.h"
#import "ZFCommunityVideoDetailModel.h"
#import "ZFCommunityVideoListHeaderView.h"
#import "ZFCommunityVideoRecommendCell.h"
#import "ZFCommunityAccountViewController.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFCommunityPostDetailReviewsModel.h"
#import "ZFCommunityPostDetailReviewsListMode.h"
#import "ZFCommunityPostDetailViewModel.h"
#import "ZFCommunityVideoDetailInfoModel.h"//视频详情页头部数据model
#import "NSString+Extended.h"
#import "ZFShare.h"
#import "ZFGoodsModel.h"
#import "ZFAppsflyerAnalytics.h"
#import "YouTuBePlayerView.h"
#import "YWLocalHostManager.h"
#import "CommunityEnumComm.h"
#import "ZFThemeManager.h"
#import "IQKeyboardManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "SystemConfigUtils.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFNetworkManager.h"
#import "ZFRequestModel.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFBranchAnalytics.h"

#import "YSAlertView.h"

#define kInputViewHeight  (49)
#define kInputViewStartY  KScreenHeight - (NAVBARHEIGHT + STATUSHEIGHT + kiphoneXHomeBarHeight + kInputViewHeight)

@interface ZFCommunityVideoListVC ()<UITableViewDataSource, UITableViewDelegate,ZFShareViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZFCommunityVideoViewModel *viewModel;
@property (nonatomic, strong) InputTextView *inputTextView;
@property (nonatomic, strong) ZFCommunityVideoDetailModel *infoModel;
@property (nonatomic, strong) ZFCommunityPostDetailReviewsModel *reviewsModel;
@property (nonatomic, strong) NSMutableArray *goodArray;
@property (nonatomic, strong) NSMutableArray *reviewArray;
@property (nonatomic, strong) NSMutableDictionary *replyDict;/*提交回复评论的参数*/
@property (nonatomic, strong) ZFCommunityVideoListHeaderView *headerView;
@property (nonatomic, strong) ZFShareView      *shareView;
@property (nonatomic, strong) YouTuBePlayerView  *playerVideo;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
//统计
@property (nonatomic, strong) ZFAnalyticsProduceImpression    *analyticsProduceImpression;

@property (nonatomic, strong) UIButton                          *playButton;
@property (nonatomic, assign) BOOL                              isFirstShow;

@end

@implementation ZFCommunityVideoListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
    [self LayoutZFSubViews];
    
    /*上拉加载数据*/
    [self setTableViewFooterLoadRequset];
    [self requestData];
    
    //growingIO 帖子详情浏览
    [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOFistEvar : GIOSourceCommunityPost,
                                               GIOSndIdEvar : ZFToString(self.videoId),
                                               GIOSndNameEvar : ZFToString(self.videoId)
    }];
    [ZFGrowingIOAnalytics ZFGrowingIOPostTopicShow:self.videoId postType:@"videos"];
    [[ZFBranchAnalytics sharedManager] branchAnalyticsPostViewWithPostId:self.videoId postType:@"video"];
    
    [self addNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    self.navigationController.navigationBarHidden = NO;
}

- (void)addNotification {
    //监听UIWindow隐藏
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];
}

/**
 * 在部分机器上发现全屏播放完视频后会出现状态栏显示的bug
 */
- (void)endFullScreen {
    showSystemStatusBar();
}

/**
 * 请求数据
 */
- (void)requestData {
    NSDictionary *dcit = @{kLoadingView : self.view,
                           @"video_id"  : self.videoId};
    @weakify(self)
    /*请求视频详情页头部数据*/
    [self.viewModel requestNetwork:dcit completion:^(NSArray *objs) {
        @strongify(self)
        [self configureRightBarItem];
        
        ZFCommunityVideoDetailModel *infoModel = objs[0];
        ZFCommunityPostDetailReviewsModel *reviewsModel = objs[1];
        /*请求评论列表数据*/
        
        if (!self.title) {
            self.title = ZFToString(infoModel.videoInfo.videoDescription);
        }
        
        /*显示输入框*/
        self.inputTextView.hidden = NO;
        self.tableView.hidden = NO;
        
        /*取出头部数据外部赋值*/
        self.infoModel = infoModel;
        
        //刷新头部
        [self refreshHeaderView:infoModel.videoInfo];
        
        [self.goodArray addObjectsFromArray:infoModel.goodsList];
        /*赋值外部变量->评论列表数据*/
        self.reviewsModel = reviewsModel;
        
        /*先清空之前的数据->这样不会导致数据重复*/
        [self.reviewArray removeAllObjects];
        [self.reviewArray addObjectsFromArray:reviewsModel.list];
        //刷新列表
        [self.tableView reloadData];
        
        [self goodsAdGA];
    } failure:^(id obj) {
        
        @strongify(self)
        self.tableView.hidden = NO;
        self.tableView.requestFailBtnTitle = ZFLocalizedString(@"EmptyCustomViewManager_refreshButton",nil);
        @weakify(self)
        self.tableView.blankPageViewActionBlcok = ^(ZFBlankPageViewStatus status) {
            @strongify(self)
            [self requestData];
        };
        [self.tableView showRequestTip:nil];
    }];
}

// 商品 GA 内推广告统计
- (void)goodsAdGA {
    NSMutableArray <ZFGoodsModel *> *goodsGoodsArray = [NSMutableArray new];
    for (NSDictionary *goodsDict in self.goodArray) {
        ZFGoodsModel *goodsModel = [self goodsDictAdapterToGoodsModel:goodsDict];
        [goodsGoodsArray addObject:goodsModel];
        
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:goodsModel page:@"社区视频"];
    }
    
    //GA 帖子详情浏览，点击一起统计 (v4.1.0 需求 by 陈秀详), 同时取消了列表页的曝光和点击
    NSString *GAImpressName = [NSString stringWithFormat:@"%@_%@_%@", ZFGATopicDetailInternalPromotion,
                               @"video",
                               ZFToString(self.videoId)];
    [ZFAnalytics showAdvertisementWithBanners:@[@{@"name" : GAImpressName}] position:nil screenName:@"视频详情"];
    [ZFAnalytics clickAdvertisementWithId:ZFToString(self.videoId) name:GAImpressName position:nil];
    
    if (goodsGoodsArray.count > 0) {
        [ZFAnalytics showProductsWithProducts:goodsGoodsArray position:1 impressionList:ZFGATopicGoodsList screenName:@"video_detail" event:nil];
        
        //occ v3.7.0hacker 添加 ok
        self.analyticsProduceImpression = [ZFAnalyticsProduceImpression initAnalyticsProducePosition:1
                                                                                      impressionList:ZFGATopicGoodsList
                                                                                          screenName:@"video_detail"
                                                                                               event:nil];
    }
    
    [ZFAppsflyerAnalytics trackGoodsList:goodsGoodsArray inSourceType:ZFAppsflyerInSourceTypeZMeVideoDetailRecommend sourceID:self.videoId];
}

- (ZFGoodsModel *)goodsDictAdapterToGoodsModel:(NSDictionary *)goodsDict {
    ZFGoodsModel *goodsModel = [ZFGoodsModel new];
    goodsModel.goods_id = goodsDict[@"goods_id"];
    goodsModel.goods_sn = goodsDict[@"goods_sn"];
    goodsModel.cat_level_column = goodsDict[@"cat_level_column"];
    return goodsModel;
}

- (void)configureRightBarItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(64, 2, NavBarButtonSize, NavBarButtonSize)];
    [btn setImage:[UIImage imageNamed:@"GoodsDetail_shareIcon"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(shareHandle) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *accountItme = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = accountItme;
}

- (void)shareHandle {
    [self.view endEditing:YES];
    [self.shareView open];
}

#pragma mark - ZFShareViewDelegate
- (void)zfShsreView:(ZFShareView *)shareView didSelectItemAtIndex:(NSUInteger)index {
    NativeShareModel *model = [[NativeShareModel alloc] init];
    NSString *appCommunityShareURL = [YWLocalHostManager appCommunityShareURL];
    model.share_url = [NSString stringWithFormat:@"%@?actiontype=6&url=4,%@&name=@""&source=sharelink&lang=%@",appCommunityShareURL,self.videoId,[ZFLocalizationString shareLocalizable].nomarLocalizable];
    model.share_imageURL = shareView.topView.imageName;
    model.share_description = shareView.topView.title;
    model.fromviewController = self;
    model.sharePageType = ZFSharePage_Live_DetailType;
    [ZFShareManager shareManager].model = model;
    [ZFShareManager shareManager].currentShareType = index;
    switch (index) {
        case ZFShareTypeWhatsApp: {
            [[ZFShareManager shareManager] shareToWhatsApp];
        }
            break;
        case ZFShareTypeFacebook:
        {
            [[ZFShareManager shareManager] shareToFacebook];
        }
            break;
        case ZFShareTypeMessenger:
        {
            [[ZFShareManager shareManager] shareToMessenger];
        }
            break;
        case ZFShareTypePinterest: {
            [[ZFShareManager shareManager] shareToPinterest];
        }
            break;
        case ZFShareTypeCopy:
        {
            [[ZFShareManager shareManager] copyLinkURL];
        }
            break;
        case ZFShareTypeMore: {
            [[ZFShareManager shareManager] shareToMore];
        }
            break;
        case ZFShareTypeVKontakte: {
            [[ZFShareManager shareManager] shareVKontakte];
        }
            break;
    }
    
    NSString *type = [ZFShareManager fetchShareTypePlatform:index];
    [[ZFBranchAnalytics sharedManager] branchAnalyticsPostShareWithPostId:self.videoId postType:@"video" shareType:type];
}

#pragma mark -===========点赞操作===========

/**
 * 执行点赞操作
 */
- (void)setUpLikeBlockAction {
    NSDictionary *dict = @{kLoadingView : self.view,
                           @"video_id"  : self.infoModel.videoInfo.videoId};
    @weakify(self);
    [self judgePresentLoginVCCompletion:^{
        @strongify(self)
        
        @weakify(self);
        [self.viewModel requestLikeNetwork:dict completion:^(ZFCommunityVideoDetailInfoModel *obj) {
            @strongify(self)
            self.headerView.infoModel = obj;
            // branch统计
            [[ZFBranchAnalytics sharedManager] branchAnalyticsPostLikeWithPostId:self.videoId postType:@"video" isLike:[@(obj.isLike) boolValue]];
        } failure:nil];
    }];
}

/**
 * 刷新头部
 */
- (void)refreshHeaderView:(ZFCommunityVideoDetailInfoModel *)infoModel {
    @weakify(self)
    self.headerView.refreshHeadViewBlock = ^(CGFloat headerHeight){
        @strongify(self)
        CGRect rect = CGRectZero;
        rect.size = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        self.headerView.frame = rect;
        self.tableView.tableHeaderView = self.headerView;        
    };
    
    // 播放视频
    if (infoModel.videoUrl) {

        if (![ZFNetworkManager isReachableViaWiFi] && ![AccountManager sharedManager].isNoWiFiPlay) { // WiFi自动播放,流量暂停
            self.playButton.hidden = NO;
            
            NSString *message = ZFLocalizedString(@"Community_LivesVideo_No_Wifi_Play_Msg",nil);
            NSString *noTitle = ZFLocalizedString(@"Community_LivesVideo_No_Wifi_Play_Cancel",nil);
            NSString *yesTitle = ZFLocalizedString(@"Community_LivesVideo_No_Wifi_Play_OK",nil);
            
            ShowAlertView(nil, message, @[yesTitle], ^(NSInteger buttonIndex, id buttonTitle) {
                self.playButton.hidden = YES;
                self.isFirstShow = YES;
                [self.playerVideo basePlayVideoWithVideoID:ZFToString(infoModel.videoUrl)];
                [AccountManager sharedManager].isNoWiFiPlay = YES;
            }, noTitle, ^(id cancelTitle) {
            });

            @weakify(self)
            self.playerVideo.videoPlayStatusChange = ^(PlayerState playerState) {
                @strongify(self)
                if (!self.playButton.isHidden && playerState == PlayerStatePlaying && self.isFirstShow) {
                    self.playButton.hidden = YES;
                }
            };
        } else {
            [self.playerVideo basePlayVideoWithVideoID:ZFToString(infoModel.videoUrl)];
        }
        
        // 防止视频播放之前有一段黑色间隔
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.activityView stopAnimating];
        });
    }
    
    /*视频详情页头部数据*/
    self.headerView.infoModel = infoModel;
    self.tableView.tableHeaderView = self.headerView;
}

- (void)actionPlay:(UIButton *)sender {
    self.playButton.hidden = YES;
    if (self.playButton.superview) {
        [self.playButton removeFromSuperview];
    }
    if (!self.playerVideo.isHidden) {
        [self.playerVideo basePlayVideoWithVideoID:ZFToString(self.infoModel.videoInfo.videoUrl)];
    }
}

#pragma mark -===========输入框事件===========

/**
 * 输入框回调事件
 */
- (void)inputTextViewBlockAction:(NSString *)input
{
    /*判断是否登录*/
    if ([AccountManager sharedManager].isSignIn) {
        //发送评论
        [self requestReply:input];
        
    } else {
        /*未登录情况下先登录操作*/
        @weakify(self)
        [self.navigationController judgePresentLoginVCCompletion:^{
            @strongify(self)
            [self requestReplyAfterLogin:input];
        }];
    }
}

/**
 * 登陆完发送发送评论
 */
- (void)requestReplyAfterLogin:(NSString *)input
{
    /*********************将数据装成字典进行请求*******************/
    self.replyDict[@"replyId"] = self.replyDict[@"replyId"] ? self.replyDict[@"replyId"] : @"0";
    self.replyDict[@"reviewId"] = self.videoId;
    self.replyDict[@"replyUserId"] = self.replyDict[@"replyUserId"] ? self.replyDict[@"replyUserId"] : @"0";
    self.replyDict[@"content"] = input;
    self.replyDict[@"isSecondFloorReply"] = self.replyDict[@"isSecondFloorReply"] ? self.replyDict[@"isSecondFloorReply"] : @"0";
    self.replyDict[kLoadingView] = self.view;
    
    /********************************************************************/
    @weakify(self)
    [self.viewModel requestReplyNetwork:self.replyDict completion:^(id obj) {
        
        @strongify(self)
        /*指定刷新组*/
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        
        /*评论完成将PlaceholderText设置回*/
        [self.inputTextView setPlaceholderText:ZFLocalizedString(@"Video_VC_TextView_Placeholder",nil)];
        /*回复完成后清空数据->不清空的话会导致评论下个人的时候还是上一次的数据*/
        [self.replyDict removeAllObjects];
        
        // branch统计
        [[ZFBranchAnalytics sharedManager] branchAnalyticsPostReviewWithPostId:self.videoId postType:@"video"];
        
    } failure:nil];
}

/**
 * 发送评论
 */
- (void)requestReply:(NSString *)input
{
    /*********************将数据装成字典进行请求*******************/
    
    /*为0的情况下是给自己的帖子评论,非0得情况是给他人回复评论*/
    self.replyDict[@"replyId"] = self.replyDict[@"replyId"] ? self.replyDict[@"replyId"] : @"0"; // 晒图回复的id,如果当前回复是对评论的回复则这个值传0
    self.replyDict[@"reviewId"] = self.videoId; // 当前晒图的id
    self.replyDict[@"replyUserId"] = self.replyDict[@"replyUserId"] ? self.replyDict[@"replyUserId"] : @"0"; // 晒图回复人的用户id,如果当前回复是对评论的回复则这个值传0
    self.replyDict[@"content"] = input; // 评论内容
    self.replyDict[@"isSecondFloorReply"] = self.replyDict[@"isSecondFloorReply"] ? self.replyDict[@"isSecondFloorReply"] : @"0"; // 1表示这条回复是对回复的回复，0表是这条回复是对晒图的回复
    self.replyDict[kLoadingView] = self.view;
    
    /******************************发送评论请求**********************************/
    @weakify(self)
    [self.viewModel requestReplyNetwork:self.replyDict completion:^(id obj) {
        
        [self.viewModel requestReviewsListNetwork:@[Refresh, self.videoId] completion:^(ZFCommunityPostDetailReviewsModel *reviewsModel) {
            @strongify(self)
            
            /*赋值外部变量->评论列表数据*/
            self.reviewsModel = reviewsModel;
            
            /*先清空之前的数据->这样不会导致数据重复*/
            [self.reviewArray removeAllObjects];
            [self.reviewArray addObjectsFromArray:reviewsModel.list];
            
            //刷新列表
            NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            
            /*回复完成后清空数据->不清空的话会导致评论下个人的时候还是上一次的数据*/
            [self.replyDict removeAllObjects];
            
            // branch统计
            [[ZFBranchAnalytics sharedManager] branchAnalyticsPostReviewWithPostId:self.videoId postType:@"video"];
            
        } failure:nil];
    } failure:nil];
}

#pragma mark - 上拉加载更多
- (void)setTableViewFooterLoadRequset {
    @weakify(self)
    ZFRefreshFooter *footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        [self.viewModel requestReviewsListNetwork:@[@(self.reviewsModel.curPage + 1), self.videoId] completion:^(ZFCommunityPostDetailReviewsModel *obj) {
            @strongify(self)
            [self.tableView.mj_footer endRefreshing];
            if (obj) {
                self.reviewsModel = obj;
                [self.reviewArray addObjectsFromArray:obj.list];
                [self.tableView reloadData];
                if (self.reviewsModel.curPage >= self.reviewsModel.pageCount) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    [UIView animateWithDuration:0.3 animations:^{
                        self.tableView.mj_footer.hidden = YES;
                    }];
                    return;
                }
            }else {
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.tableView.mj_footer.hidden = YES;
                }];
            }
        } failure:^(id obj) {
            @strongify(self)
            [self.tableView.mj_footer endRefreshing];            
            ShowToastToViewWithText(self.view, ZFLocalizedString(@"Failed", nil));
        }];
    }];
    [self.tableView setMj_footer:footer];
}

#pragma mark -===========初始化UI===========

- (void)initSubViews {
    self.view.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
    [self.view addSubview:self.playerVideo];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.activityView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.inputTextView];
}

- (void)LayoutZFSubViews {
    CGFloat videoHeight = 210 * ScreenWidth_SCALE;
    [self.playerVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(videoHeight);
    }];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.playerVideo.mas_centerX);
        make.centerY.mas_equalTo(self.playerVideo.mas_centerY);
    }];
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.view.mas_top).offset(videoHeight/2-10);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    CGFloat botttomSpace = kiphoneXHomeBarHeight + kInputViewHeight;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.playerVideo.mas_bottom);
        make.bottom.mas_equalTo(self.view).offset(-botttomSpace);
    }];
}

- (YouTuBePlayerView *)playerVideo {
    if(!_playerVideo){
        _playerVideo = [[YouTuBePlayerView alloc] init];
        [_playerVideo cancelSettingOperateView];
        _playerVideo.backgroundColor = [UIColor blackColor];
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        activityView.color = [UIColor whiteColor];
        [activityView hidesWhenStopped];
        [activityView startAnimating];
        self.activityView = activityView;
    }
    return _playerVideo;
}

- (ZFCommunityVideoListHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[ZFCommunityVideoListHeaderView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _headerView.likeBlock = ^{
            @strongify(self)
            //执行点赞操作
            [self setUpLikeBlockAction];
            
            // firebase
            [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"click_like_%@", self.videoId] itemName:@"video" ContentType:@"" itemCategory:@""];
        };
    }
    return _headerView;
}

- (UITableView *)tableView {
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = ZFCOLOR(221, 221, 221, 1.0);
        _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
        _tableView.tableHeaderView = self.headerView;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [_tableView registerClass:[ZFCommunityVideoCommentsCell class] forCellReuseIdentifier:VIDEO_COMMENTS_CELL_INENTIFIER];
        [self.view addSubview:_tableView];
        _tableView.hidden = YES;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}

- (InputTextView *)inputTextView {
    if(!_inputTextView){
        _inputTextView = [[InputTextView alloc] init];
        _inputTextView.frame = CGRectMake(0, kInputViewStartY, KScreenWidth, kInputViewHeight);
        _inputTextView.backgroundColor = [UIColor colorWithWhite:255 alpha:0];
        _inputTextView.hidden = YES;
        [_inputTextView setPlaceholderText:ZFLocalizedString(@"Video_VC_TextView_Placeholder",nil)];
        @weakify(self)
        _inputTextView.InputTextViewBlock = ^(NSString *input){
            @strongify(self)
            [self inputTextViewBlockAction:input];
        };
    }
    return _inputTextView;
}

- (ZFCommunityVideoViewModel*)viewModel {
    if (!_viewModel) {
        _viewModel = [ZFCommunityVideoViewModel new];
        _viewModel.controller = self;
        @weakify(self)
        _viewModel.emptyOperationBlock = ^{
            @strongify(self)
            [self.tableView.mj_header beginRefreshing];
        };
    }
    return _viewModel;
}

- (NSMutableDictionary *)replyDict {
    if (!_replyDict) {
        _replyDict = [NSMutableDictionary dictionary];
    }
    return _replyDict;
}

- (NSMutableArray *)reviewArray {
    if (!_reviewArray) {
        _reviewArray = [NSMutableArray array];
    }
    return _reviewArray;
}

- (NSMutableArray *)goodArray {
    if (!_goodArray) {
        _goodArray = [NSMutableArray array];
    }
    return _goodArray;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.goodArray.count;
    }else {
        if (self.reviewArray.count < 15) {
            tableView.mj_footer.hidden = YES;
        } else {
            tableView.mj_footer.hidden = NO;
        }
        return self.reviewArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:
        {
            ZFCommunityVideoRecommendCell *recommendCell = [ZFCommunityVideoRecommendCell recommendCellWithTableView:tableView IndexPath:indexPath];
            recommendCell.selectionStyle = UITableViewCellSelectionStyleNone;
            recommendCell.data = self.goodArray[indexPath.row];
            
            @weakify(self)
            recommendCell.jumpBlock = ^{
                @strongify(self)
                NSDictionary *dict = self.goodArray[indexPath.row];
                
                ZFGoodsDetailViewController *detail = [ZFGoodsDetailViewController new];
                detail.goodsId = dict[@"goods_id"];
                detail.sourceID = ZFToString(self.videoId);
                detail.sourceType = ZFAppsflyerInSourceTypeZMeVideoDetailRecommend;
                //occ v3.7.0hacker 添加 ok
                detail.analyticsProduceImpression = self.analyticsProduceImpression;
                [self.navigationController pushViewController:detail animated:YES];
                
                // firebase
                [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"click_goods_%@", detail.goodsId] itemName:@"Goods" ContentType:@"video_detail" itemCategory:@"Goods"];
                
                //occ v3.7.0hacker 添加 ok
                //数据中没有title name
                // GA 电子商务统计
                ZFGoodsModel *goodsModel = [self goodsDictAdapterToGoodsModel:dict];
                [ZFAnalytics clickProductWithProduct:goodsModel position:1 actionList:ZFGATopicGoodsList];
                
                [ZFGrowingIOAnalytics ZFGrowingIOProductClick:goodsModel page:@"社区视频" sourceParams:@{
                    GIOGoodsTypeEvar : GIOGoodsTypeCommunity,
                    GIOGoodsNameEvar : [NSString stringWithFormat:@"recommend_zme_videoid_%@", self.videoId]
                }];
                
                // appflyer统计
                NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsModel.goods_sn),
                                                  @"af_spu_id" : ZFToString(goodsModel.goods_spu),
                                                  @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                                  @"af_page_name" : @"post_video",    // 当前页面名称
                                                  };
                [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
            };
            
            cell = recommendCell;
        }
            break;
        case 1:
        {
            ZFCommunityVideoCommentsCell *commentsCell = [ZFCommunityVideoCommentsCell commentsCellWithTableView:tableView IndexPath:indexPath];
            commentsCell.selectionStyle = UITableViewCellSelectionStyleNone;
            ZFCommunityPostDetailReviewsListMode *model = self.reviewArray[indexPath.row];
            commentsCell.reviesModel = model;
            
            //第一个与最后一个cell不显示分割线
            [commentsCell hideBottomLine:(indexPath.row == self.reviewArray.count-1)];
            
            @weakify(self)
            commentsCell.jumpBlock = ^(NSString *userId){
                @strongify(self)
                ZFCommunityAccountViewController *mystyleVC = [ZFCommunityAccountViewController new];
                mystyleVC.userId = userId;
                [self.navigationController pushViewController:mystyleVC animated:YES];
            };
            
            commentsCell.replyBlock = ^{
                
                @strongify(self)
                if (![NSStringUtils isEmptyString:USERID] ) {
                    if ([model.userId isEqualToString: USERID]) {
                        /*如果点击的是自己则提示不能回复自己的评论*/
                        ShowToastToViewWithText(self.view, ZFLocalizedString(@"Video_VC_CannotPost_Message",nil));
                    }else {
                        /*第一响应者*/
                        [self.inputTextView.textView becomeFirstResponder];
                        
                        /*点击回复他人评论时截取的数据*/
                        [self.inputTextView setPlaceholderText:[NSString stringWithFormat:@"Re %@",model.nickname]];
                        self.replyDict[@"replyId"] = model.replyId;
                        self.replyDict[@"reviewId"] = model.reviewId;
                        self.replyDict[@"replyUserId"] = model.userId;
                        self.replyDict[@"isSecondFloorReply"] = @"1";
                        /**************************************/
                    }
                }else {
                    @weakify(self)
                    [self.navigationController judgePresentLoginVCCompletion:^{
                        @strongify(self)
                        if ([model.userId isEqualToString: USERID]) {
                            ShowToastToViewWithText(self.view, ZFLocalizedString(@"Video_VC_CannotPost_Message",nil));
                        }else {
                            [self.inputTextView.textView becomeFirstResponder];
                            
                            /*点击回复他人评论时截取的数据*/
                            [self.inputTextView setPlaceholderText:[NSString stringWithFormat:@"Re %@",model.nickname]];
                            self.replyDict[@"replyId"] = model.replyId;
                            self.replyDict[@"reviewId"] = model.reviewId;
                            self.replyDict[@"replyUserId"] = model.userId;
                            self.replyDict[@"isSecondFloorReply"] = @"1";
                            /**************************************/
                        }
                    }];
                }
                
            };
            cell = commentsCell;
        }
            break;
        default:
            break;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 50;
    }
    return 60;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
        titleView.backgroundColor = ZFCOLOR_WHITE;
        titleView.clipsToBounds = NO;
        
        UILabel *productLable  = [[UILabel alloc] init];
        productLable.frame = CGRectMake(12, 0, KScreenWidth-12, 50);
        productLable.font      = [UIFont systemFontOfSize:16.0];
        productLable.textColor = ZFCOLOR(51, 51, 51, 1.0);
        productLable.text      = ZFLocalizedString(@"community_post_simalar_produce", nil);
        [titleView addSubview:productLable];
        return titleView;

    } else if (section == 1) {
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 60)];
        titleView.backgroundColor = ZFCOLOR_WHITE;
        titleView.clipsToBounds = NO;
        
        UIView *line = [UIView new];
        line.frame = CGRectMake(0, -1, KScreenWidth, 10);
        line.backgroundColor = ZFCOLOR(247,247,247, 1.0);
        [titleView addSubview:line];
        
        UILabel *titleLab = [UILabel new];
        titleLab.frame = CGRectMake(12, 10, KScreenWidth-12, 50);
        titleLab.font = [UIFont systemFontOfSize:16];
        titleLab.textColor = ZFCOLOR(51, 51, 51, 1.0);
        [titleView addSubview:titleLab];
        
        NSInteger num = self.reviewArray.count > 0 ? self.reviewArray.count : 0;
        if ([SystemConfigUtils isRightToLeftShow]) {
            titleLab.text = [NSString stringWithFormat:@"(%ld)%@",(long)num,ZFLocalizedString(@"VideoView_HeaderView_Title",nil)];
        } else {
            titleLab.text = [NSString stringWithFormat:@"%@(%ld)",ZFLocalizedString(@"VideoView_HeaderView_Title",nil),(long)num];
        }
        return titleView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 114;
    }
    return [tableView fd_heightForCellWithIdentifier:VIDEO_COMMENTS_CELL_INENTIFIER cacheByIndexPath:indexPath configuration:^(ZFCommunityVideoCommentsCell *cell) {
        cell.reviesModel = self.reviewArray[indexPath.row];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Getter
- (ZFShareView *)shareView {
    if (!_shareView) {
        _shareView = [[ZFShareView alloc] init];
        _shareView.delegate = self;
        [ZFShareManager authenticatePinterest];
        
        NSString *imageName = [NSString stringWithFormat:ZFCommunityVideoImageUrl,self.infoModel.videoInfo.videoUrl];
        ZFShareTopView *shareTopView = [[ZFShareTopView alloc] init];
        [shareTopView updateImage:imageName
                            title:self.headerView.infoModel.videoDescription
                          tipType:ZFShareDefaultTipTypeCommon];
        _shareView.topView = shareTopView;
    }
    return _shareView;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton addTarget:self action:@selector(actionPlay:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setImage:[UIImage imageNamed:@"community_home_play_big"] forState:UIControlStateNormal];
        _playButton.hidden = YES;
    }
    return _playButton;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_shareView) {
        [self.shareView removeFromSuperview];
        self.shareView.delegate = nil;
        self.shareView = nil;
    }
}

@end
