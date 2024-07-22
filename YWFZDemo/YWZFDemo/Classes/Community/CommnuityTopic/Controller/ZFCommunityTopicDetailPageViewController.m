//
//  ZFCommunityTopicDetailPageViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/9/17.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityTopicDetailPageViewController.h"
#import "YNPageViewController.h"
#import "ZFCommunityTopicDetailItemVC.h"
#import "ZFCommunityOutfitPostVC.h"
#import "ZFCommunityPostListViewController.h"
#import "ZFWebViewViewController.h"

#import "ZFInitViewProtocol.h"
#import "ZFCommunityTopicNavbarView.h"
#import "ZFCommunityTopicDetailHeaderView.h"
#import "ZFCommunityZmPostView.h"
#import "ZFShareView.h"
#import "ZFShare.h"

#import "PostPhotosManager.h"
#import "ZFCommunityTopicDetailNewViewModel.h"
#import "UIViewController+YNPageExtend.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIView+YNPageExtend.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "ZFNavigationController.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "SystemConfigUtils.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFAnalytics.h"
#import "ZFAppsflyerAnalytics.h"
#import "NSStringUtils.h"

#import "ZFLocalizationString.h"
#import "ZFApiDefiner.h"
#import "ZFTimerManager.h"
#import "BannerManager.h"

@interface ZFCommunityTopicDetailPageViewController ()
<
YNPageViewControllerDataSource,
YNPageViewControllerDelegate,
ZFInitViewProtocol,
ZFShareViewDelegate
>

@property (nonatomic, strong) ZFCommunityTopicNavbarView            *navigaitonView;
@property (nonatomic, strong) ZFShareView                           *shareView;
@property (nonatomic, strong) YNPageViewController                  *pageVC;
@property (nonatomic, strong) ZFCommunityTopicDetailHeaderView      *headerView;

@property (nonatomic, strong) UIControl                             *postControl;
@property (nonatomic, strong) UIImageView                           *starImageView;
@property (nonatomic, strong) UILabel                               *postLabel;
@property (nonatomic, strong) ZFCommunityZmPostView                 *zmPostView;

@property (nonatomic, strong) ZFCommunityTopicDetailNewViewModel    *viewModel;
@property (nonatomic, copy) NSString                                *sort;
@end

@implementation ZFCommunityTopicDetailPageViewController

- (void)dealloc {
    if (_shareView) {
        [_shareView removeFromSuperview];
        _shareView.delegate = nil;
        _shareView = nil;
    }
    if (_headerView) {
        [_headerView stopTimer];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //导航栏按钮换肤
    [self.navigaitonView zfChangeSkinToShadowNavgationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_zmPostView) {
        [_zmPostView hiddenViewAnimation:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.fd_prefersNavigationBarHidden = YES;
    
    self.navigaitonView.title = [self.title length] > 0 ? self.title : ZFLocalizedString(@"Topic_VC_Title",nil);

    //v455调整：0放在最前面
    self.sort = [ZFCommunityTopicDetailModel sortToStringType:TopicDetailSortTypeRanking];
    
    //防止进来请求失败，没返回按钮
    [self.view addSubview:self.navigaitonView];
    
    @weakify(self);
    ShowLoadingToView(self.view);
    [self requestTopicDataCompletion:^{
        @strongify(self);
        [self configurePageVC];
    }];
    ///growingIO 统计话题ID转化变量
    [Growing setEvarWithKey:GIOTopicId_evar andStringValue:ZFgrowingToString(self.topicId)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
- (void)zfInitView {
    if (self.navigaitonView.superview) {
        [self.navigaitonView removeFromSuperview];
    }
    [self.pageVC.view addSubview:self.navigaitonView];
    [self.pageVC.view addSubview:self.postControl];
    [self.postControl addSubview:self.starImageView];
    [self.postControl addSubview:self.postLabel];
    
    [self postControlShowState];
}

- (void)zfAutoLayoutView {
    [self.navigaitonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.pageVC.view);
        make.height.mas_equalTo(kiphoneXTopOffsetY + 44.0);
    }];
    
    [self.postControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.pageVC.view.mas_bottom).offset(-kiphoneXHomeBarHeight-16);
        make.height.mas_equalTo(36);
        make.centerX.mas_equalTo(self.pageVC.view.mas_centerX);
    }];
    
    [self.starImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.postControl.mas_leading).offset(13);
        make.centerY.mas_equalTo(self.postControl.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.postLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.postControl.mas_trailing).offset(-13);
        make.leading.mas_equalTo(self.starImageView.mas_trailing).offset(3);
        make.centerY.mas_equalTo(self.postControl.mas_centerY);
    }];
}

- (void)configurePageVC {
    YNPageConfigration *configration      = [YNPageConfigration defaultConfig];
    configration.pageStyle                = YNPageStyleSuspensionCenter;
    configration.headerViewScaleMode      = YNPageHeaderViewScaleModeTop;
    configration.headerViewCouldScale     = YES;
    configration.scrollMenu               = NO;
    configration.bounces                  = NO;
    configration.aligmentModeCenter       = NO;
    configration.showBottomLine           = NO;
    configration.lineWidthEqualFontWidth  = true;
    configration.lineHeight               = 3;
    configration.bottomLineHeight         = 0.5;
    configration.normalItemColor          = ColorHex_Alpha(0x999999, 1.0);
    configration.selectedItemColor        = ColorHex_Alpha(0x2D2D2D, 1.0);
    configration.lineColor                = ColorHex_Alpha(0x2D2D2D, 1.0);
    configration.bottomLineBgColor        = ColorHex_Alpha(0xDDDDDD, 1.0);
    configration.selectedItemFont         = ZFFontBoldSize(15);
    configration.itemFont                 = ZFFontBoldSize(15);
    configration.showNavigation           = NO;
    configration.suspenOffsetY            = NAVBARHEIGHT + kiphoneXTopOffsetY;
    configration.headerViewCouldScrollPage = YES;
    configration.contentHeight = KScreenHeight - NAVBARHEIGHT - kiphoneXTopOffsetY - 44;
    
    NSArray *menuTitles = [self arQueryNavTitles];
    if (menuTitles.count > 2) {

        __block BOOL isScroll = NO;
        CGFloat maxWidth = KScreenWidth / 3.0 - configration.itemMargin;
        [menuTitles enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGSize size = [obj sizeWithAttributes:@{NSFontAttributeName: ZFFontBoldSize(15)}];
            YWLog(@"------menu 2 Width: %f, maxWidth : %f",size.width,maxWidth);
            if (size.width > maxWidth) {
                isScroll = YES;
                *stop = YES;
            }
        }];
        
        if (isScroll) {
            configration.scrollMenu           = YES;
        }
    }
    YNPageViewController *vc = [YNPageViewController pageViewControllerWithControllers:[self arQueryChildViewControllers]
                                                                                titles:menuTitles
                                                                                config:configration];

    self.pageVC = vc;
    self.pageVC.bgScrollView.pagingEnabled = YES;
    vc.dataSource = self;
    vc.delegate = self;
    

    if ([self.viewModel.topicDetailHeadModel.activity.time integerValue] > 0 && ![self.viewModel.topicDetailHeadModel.activity.status isEqualToString:@"0"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadActivityTime) name:kTimerManagerUpdate object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kTimerManagerUpdate object:nil];
    }
    
    self.headerView.topicDetailHeadModel = self.viewModel.topicDetailHeadModel;
    CGRect rect = CGRectZero;
    rect.size = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    self.headerView.frame = rect;
    vc.headerView = self.headerView;
    
    [vc addSelfToParentViewController:self];
    
    // 没用这个刷新
//    @weakify(self);
//    ZFRefreshHeader *header = [ZFRefreshHeader headerWithRefreshingBlock:^{
//        @strongify(self)
//        
//        [self  reloadPageVC];
//        [vc.bgScrollView.mj_header endRefreshing];
//    }];
//    
//    vc.bgScrollView.mj_header = header;
    
    
    [self zfInitView];
    [self zfAutoLayoutView];

    [self.navigaitonView setRightItemImage:[UIImage imageNamed:@"GoodsDetail_shareIcon"] isHidden:NO];

}


- (void)postControlShowState {
    // 若存在活动，活动结束后，不显示发帖按钮
    self.postControl.hidden = NO;
    if (!ZFIsEmptyString(self.viewModel.topicDetailHeadModel.activity.type)) {
        if ([self.viewModel.topicDetailHeadModel.activity.time integerValue] <= 0) {
            self.postControl.hidden = YES;
        }
    }
}
/**
 活动倒计时结束事件
 */
- (void)reloadActivityTime {
    int timeOut =  [self.viewModel.topicDetailHeadModel.activity.time doubleValue] - [[ZFTimerManager shareInstance] timeInterval:self.viewModel.topicDetailHeadModel.countDownTimerKey];
    
    int leftTimeOut = [[ZFTimerManager shareInstance] timeInterval:self.viewModel.topicDetailHeadModel.countDownTimerKey];


    if(timeOut <= 0 || leftTimeOut <= 0){ //倒计时结束，关闭
        self.viewModel.topicDetailHeadModel.activity.time = @"";
        self.headerView.topicDetailHeadModel = self.viewModel.topicDetailHeadModel;
        [self.headerView stopTimer];
        
        CGRect rect = CGRectZero;
        rect.size = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        self.headerView.frame = rect;
        
        self.pageVC.headerView.yn_height = rect.size.height;
        [self.pageVC reloadData];
        [self.pageVC.view bringSubviewToFront:self.postControl];
        
        [self postControlShowState];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kTimerManagerUpdate object:nil];
    }
}


/**
 更新头部视图高度
 */
- (void)updateHeaderView {
    
    // 这里暂时 这做高度变化处理，不赋值处理，因为有活动倒计时要 调整处理
//    self.headerView.topicDetailHeadModel = self.viewModel.topicDetailHeadModel;
    
    CGRect rect = CGRectZero;
    rect.size = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    self.headerView.frame = rect;
    
    self.pageVC.headerView.yn_height = rect.size.height;
    [self.pageVC reloadData];
    [self.pageVC.view bringSubviewToFront:self.postControl];
}


- (NSArray *)arQueryNavTitles {
    //精选
    NSString *tabName = self.viewModel.topicDetailHeadModel.tab_name;
    if (!ZFIsEmptyString(tabName)) {
        return @[[NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"TopicDetailView_Ranking",nil)] ,
          [NSStringUtils firstCharactersCapitalized:tabName],
          [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"TopicDetailView_Latest",nil)]];
    } else {
        return @[[NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"TopicDetailView_Ranking",nil)],
                 [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"TopicDetailView_Latest",nil)]];
    }
}

// 1:最新，0：ranking， 2: 精选， v455调整：0放在最前面
- (NSArray *)arQueryChildViewControllers {
    
    //// 注意一下取值赋值的顺序：若有 精选 在中间
    NSArray *arrChannels = [self arQueryNavTitles];
    ZFCommunityTopicDetailItemVC *rankVC = [[ZFCommunityTopicDetailItemVC alloc] init];
    rankVC.topicType = ZFToString(self.viewModel.topicDetailHeadModel.activity.type);
    rankVC.sort = [ZFCommunityTopicDetailModel sortToStringType:TopicDetailSortTypeRanking];
    rankVC.topicId = self.topicId;
    rankVC.viewModel = [self.viewModel yy_modelCopy];
    rankVC.channelName = ZFToString(arrChannels.firstObject);

    @weakify(self)
    rankVC.operateRefreshBlock = ^(BOOL isRefresh) {
        @strongify(self)
        self.headerView.viewAllBtn.enabled = !isRefresh;
    };
    
    ZFCommunityTopicDetailItemVC *latestVC = [[ZFCommunityTopicDetailItemVC alloc] init];
    latestVC.topicType = ZFToString(self.viewModel.topicDetailHeadModel.activity.type);
    latestVC.sort = [ZFCommunityTopicDetailModel sortToStringType:TopicDetailSortTypeLatest];
    latestVC.topicId = self.topicId;
    latestVC.channelName = ZFToString(arrChannels.lastObject);

    //注意：防止在刷新时，点击展示更多按钮
    latestVC.operateRefreshBlock = ^(BOOL isRefresh) {
        @strongify(self)
        self.headerView.viewAllBtn.enabled = !isRefresh;
    };

    //精选
    NSString *tabName = self.viewModel.topicDetailHeadModel.tab_name;
    if (!ZFIsEmptyString(tabName)) {
        ZFCommunityTopicDetailItemVC *pickVC = [[ZFCommunityTopicDetailItemVC alloc] init];
        pickVC.sort = [ZFCommunityTopicDetailModel sortToStringType:TopicDetailSortTypeFeatured];;
        pickVC.topicId = self.topicId;
        pickVC.topicType = ZFToString(self.viewModel.topicDetailHeadModel.activity.type);
        if (arrChannels.count > 1) {
            pickVC.channelName = ZFToString(arrChannels[1]);
        }
        pickVC.operateRefreshBlock = ^(BOOL isRefresh) {
            @strongify(self)
            self.headerView.viewAllBtn.enabled = !isRefresh;
        };
        
        return @[rankVC,pickVC,latestVC];
    }
    
    return @[rankVC,latestVC];
}

#pragma mark - Action

- (void)backItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navigationBarAlpha:(CGFloat )alpha {
    CGFloat navigationAlpha = alpha;
    navigationAlpha = MAX(navigationAlpha, 0.0);
    [self.navigaitonView setbackgroundAlpha:alpha];
}

#pragma mark -====== Button Action  ======

- (void)rightButtonAction {
    
    // firebase
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"click_share_topic_%@", self.topicId] itemName:@"Share" ContentType:@"explore_topic_detail" itemCategory:@"Button"];
    [self.shareView open];
}

- (void)postAction:(UIControl *)sender {
    
    @weakify(self)
    [self judgePresentLoginVCCompletion:^{
        @strongify(self)
        [self communityZShows];
    }];
}

- (void)communityZShows {
    
    // 若存在活动，活动结束后，不显示发帖按钮
    NSString *activityType = self.viewModel.topicDetailHeadModel.activity.type;
    
    // 状态:1普通帖,2穿搭帖,0综合帖
    if ([ZFToString(activityType) integerValue] == TopicDetailActivityTypeNormal) {

        [self.zmPostView pushShowPostController:ZFToString(self.viewModel.topicDetailHeadModel.topicLabel)];
        // firebase 按钮原先叫join
        [ZFFireBaseAnalytics selectContentWithItemId:@"click_join" itemName:@"join in" ContentType:@"explore_topic_detail" itemCategory:@"Button"];

    } else if ([ZFToString(activityType) integerValue] == TopicDetailActivityTypeOutfit) {
        [self.zmPostView pushOutfitPostController:ZFToString(self.viewModel.topicDetailHeadModel.topicLabel)];
    } else {
        [self.zmPostView show];
    }

}

///头部标签事件
- (void)topicDetailAction:(NSString *)labName {
    ZFCommunityPostListViewController *topic = [ZFCommunityPostListViewController new];
    topic.topicTitle = labName;
    [self.pageVC.navigationController pushViewController:topic animated:YES];
}

// outfit 规则
- (void)outfitRuleAction:(NSString *)rule {

    ZFWebViewViewController *web = [[ZFWebViewViewController alloc]init];
    web.title = ZFLocalizedString(@"Community_outfit_rules", nil);
    web.link_url = [NSString stringWithFormat:@"%@&is_app=1&lang=%@",ZFCommunityOutfitRuleUrl,[ZFLocalizationString shareLocalizable].nomarLocalizable];

//    web.link_url = [NSString stringWithFormat:@"%@?is_app=1&lang=%@",ZFCommunityOutfitRuleUrl,[ZFLocalizationString shareLocalizable].nomarLocalizable];
    [self.navigationController pushViewController:web animated:YES];
}

- (void)jumpDeeplinkUrlAction:(NSString *)deeplinkUrl {
    if (ZFIsEmptyString(deeplinkUrl)) {
        return;
    }
    
    NSString *strUrlString = ZFUnescapeString(deeplinkUrl);
    NSURL *banner_url = [NSURL URLWithString:strUrlString];
    
    NSString *scheme = [banner_url scheme];
    
    if ([scheme isEqualToString:kZZZZZScheme]) {
        NSMutableDictionary *deeplinkDic = [BannerManager parseDeeplinkParamDicWithURL:banner_url];
        [BannerManager jumpDeeplinkTarget:self deeplinkParam:deeplinkDic];
        return;
    }
    
    if ([strUrlString hasPrefix:@"http"]) {
        ZFWebViewViewController *webViewVC = [[ZFWebViewViewController alloc] init];
        webViewVC.link_url = strUrlString;
        [self.navigationController pushViewController:webViewVC animated:YES];
    }
    
    
}
#pragma mark - Request

- (void)requestTopicDataCompletion:(void (^)(void))completion {
    
    @weakify(self)
    if (self.viewModel.dataArray.count != 0) {
        [self.viewModel.dataArray removeAllObjects];
    }
    //同时发送两个请求
    [self.viewModel requestCommunityTopicPageData:self.topicId reviewId:self.review_id
                                         sortType:self.sort
                                      isFirstPage:YES
                                       completion:^(ZFCommunityTopicDetailHeadLabelModel *topicDetailHeadModel, NSDictionary *pageInfo) {
        
                                           @strongify(self)
                                           HideLoadingFromView(self.view);
                                           
                                           if (!topicDetailHeadModel) {
                                               [self showEmptyView];
                                               return;
                                           } else {
                                               [self hideEmptyView];
                                           }

                                           if (completion) {
                                               completion();
                                           }
    }];
}

- (void)asyncChangeToSync {
    
    @weakify(self)
    [self requestTopicDataCompletion:^{
        @strongify(self)
        [self configurePageVC];
    }];
}

/**
- (void)reloadPageVC {
    
    @weakify(self)
    if (self.viewModel.dataArray.count != 0) {
        [self.viewModel.dataArray removeAllObjects];
    }
    //同时发送两个请求
    [self.viewModel requestCommunityTopicPageData:self.topicId
                                         sortType:self.sort
                                      isFirstPage:YES
                                       completion:^(ZFCommunityTopicDetailHeadLabelModel *topicDetailHeadModel, NSDictionary *pageInfo)
    {
        @strongify(self)
        HideLoadingFromView(self.view);
        
        self.pageVC.titlesM = [self arQueryNavTitles].mutableCopy;
        self.pageVC.controllersM = [self arQueryChildViewControllers].mutableCopy;
        [self.pageVC reloadData];
        [self.navigaitonView setRightItemImage:[UIImage imageNamed:@"GoodsDetail_shareIcon"] isHidden:NO];
        [self.navigaitonView setbackgroundAlpha:0.0];
    }];

}
 */


#pragma mark - YNPageViewControllerDataSource
- (UIScrollView *)pageViewController:(YNPageViewController *)pageViewController pageForIndex:(NSInteger)index {
    ZFCommunityTopicDetailItemVC *vc = pageViewController.controllersM[index];
    if (index == 0) {
        vc.reviewId = self.review_id;
    }
    return [vc querySubScrollView];
}

//- (NSString *)pageViewController:(YNPageViewController *)pageViewController
//          customCacheKeyForIndex:(NSInteger )index {
//    return [NSString stringWithFormat:@"kkk%li",(long)index];
//}

- (void)pageViewController:(YNPageViewController *)pageViewController
            contentOffsetY:(CGFloat)contentOffset
                  progress:(CGFloat)progress {    
    [self navigationBarAlpha:progress];
}

- (void)pageViewController:(YNPageViewController *)pageViewController
        didEndDecelerating:(UIScrollView *)scrollView {
}

- (void)pageViewController:(YNPageViewController *)pageViewController
                 didScroll:(UIScrollView *)scrollView
                  progress:(CGFloat)progress
                 formIndex:(NSInteger)fromIndex
                   toIndex:(NSInteger)toIndex {
    [self.pageVC.view bringSubviewToFront:self.navigaitonView];
}

#pragma mark - 分享相关

- (ZFShareView *)shareView {
    if (!_shareView) {
        _shareView = [[ZFShareView alloc] init];
        _shareView.delegate = self;
        
        ZFShareTopView *shareTopView = [[ZFShareTopView alloc] init];
        [shareTopView updateImage:self.viewModel.topicDetailHeadModel.iosDetailpic
                            title:ZFLocalizedString(@"ZFShare_Community_topic", nil)
                          tipType:ZFShareDefaultTipTypeCommon];
        
        _shareView.topView = shareTopView;
        [ZFShareManager authenticatePinterest];
    }
    return _shareView;
}

- (void)zfShsreView:(ZFShareView *)shareView didSelectItemAtIndex:(NSUInteger)index {
    NativeShareModel *model = [[NativeShareModel alloc] init];
    NSString *appCommunityShareURL = [YWLocalHostManager appCommunityShareURL];
    model.share_url = [NSString stringWithFormat:@"%@?actiontype=6&url=3,%@&name=@""&source=sharelink&lang=%@",appCommunityShareURL,self.topicId,[ZFLocalizationString shareLocalizable].nomarLocalizable];
    model.share_imageURL = shareView.topView.imageName;
    model.share_description = shareView.topView.title;
    model.fromviewController = self;
    model.sharePageType = ZFSharePage_CommunityTopicsDetailType;
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
    //需求: 统计分享, 不管成功失败一点击就统计
    [self shareSuccessAppsFlyerEventByType:index];
}

/**
 * 统计分享facebook, Message事件
 */
- (void)shareSuccessAppsFlyerEventByType:(ZFShareType)shareType {
    NSString *share_channel = [ZFShareManager fetchShareTypePlatform:shareType];
    if (ZFIsEmptyString(share_channel)) return;
    
    share_channel = [NSString stringWithFormat:@"Shared on %@", share_channel];
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId] = ZFToString(@"unKnow");//@陈佳佳:说这里没有sn就传空
    valuesDic[AFEventParamContentType] = ZFToString(share_channel);
    valuesDic[@"af_country_code"] = ZFToString([AccountManager sharedManager].accountCountryModel.region_code);
    if (self.deeplinkSource) {
        if (self.deeplinkSource.length > 0) {
            valuesDic[@"af_inner_mediasource"] = self.deeplinkSource;
        } else {
            valuesDic[@"af_inner_mediasource"] = @"unknowmediasource";
        }
    } else {
        valuesDic[@"af_inner_mediasource"] = @"recommend_zme_topic_detail";
    }
    [ZFAnalytics appsFlyerTrackEvent:@"af_share" withValues:valuesDic];
}


#pragma mark - getter/setter

- (void)showEmptyView {
    
    self.emptyImage   = [UIImage imageNamed:@"blankPage_noCart"];
    self.emptyTitle   = ZFLocalizedString(@"EmptyCustomViewHasNoData_titleLabel",nil);
    @weakify(self)
    [self showEmptyViewHandler:^{
        @strongify(self)
        ShowLoadingToView(self.view);
        [self asyncChangeToSync];
    }];
    if (self.navigaitonView.superview == self.view) {
        [self.navigaitonView setbackgroundAlpha:1.0];
        [self.view bringSubviewToFront:self.navigaitonView];
    }
}

- (void)hideEmptyView {
    [self removeEmptyView];
    [self.navigaitonView setbackgroundAlpha:0.0];
}

- (void)setHotTopicModel:(ZFCommunityHotTopicModel *)hotTopicModel {
    _hotTopicModel = hotTopicModel;
}

- (ZFCommunityTopicDetailNewViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityTopicDetailNewViewModel alloc] init];
    }
    return _viewModel;
}

- (ZFCommunityTopicDetailHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[ZFCommunityTopicDetailHeaderView alloc] initWithFrame:CGRectZero];
        
        CGRect rect = CGRectZero;
        rect.size = [_headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        _headerView.frame = rect;

        
        @weakify(self)
        _headerView.refreshHeadViewBlock = ^(BOOL isShowAll) {
            @strongify(self)
            self.viewModel.topicDetailHeadModel.isShowAllContent = isShowAll;
            [self updateHeaderView];
        };
        
        _headerView.topicDetailBlock = ^(NSString *labName) {
            @strongify(self)
            [self topicDetailAction:labName];
        };
        
        _headerView.tapOutfiRuleBlock = ^(NSString *rule) {
            @strongify(self)
            [self outfitRuleAction:rule];
        };
        
        _headerView.deeplinkHandle = ^(NSString *deeplinkUrl) {
            @strongify(self)
            [self jumpDeeplinkUrlAction:deeplinkUrl];
            
        };
    }
    return _headerView;
}

- (UIControl *)postControl {
    if (!_postControl) {
        _postControl = [[UIControl alloc] initWithFrame:CGRectZero];
        _postControl.backgroundColor = ZFC0xFE5269();
        [_postControl addTarget:self action:@selector(postAction:) forControlEvents:UIControlEventTouchUpInside];
        _postControl.hidden = YES;
        
        _postControl.layer.shadowColor = ColorHex_Alpha(0x000000, 0.2).CGColor;
        _postControl.layer.shadowOffset = CGSizeMake(0,1);
        _postControl.layer.cornerRadius = 18;
        _postControl.layer.shadowOpacity = 1;
        _postControl.layer.shadowRadius = 8;
    }
    return _postControl;
}

- (UIImageView *)starImageView {
    if (!_starImageView) {
        _starImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _starImageView.image = [UIImage imageNamed:@"create"];
    }
    return _starImageView;
}

- (UILabel *)postLabel {
    if (!_postLabel) {
        _postLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _postLabel.textColor = ColorHex_Alpha(0xffffff, 1.0);
        _postLabel.font = ZFFontSystemSize(14);
        _postLabel.text = ZFLocalizedString(@"community_topicdetail_Create", nil);
    }
    return _postLabel;
}


- (ZFCommunityTopicNavbarView *)navigaitonView {
    if (!_navigaitonView) {
        _navigaitonView = [[ZFCommunityTopicNavbarView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kiphoneXTopOffsetY + 44.0)];

        [_navigaitonView setbackgroundAlpha:0.0];
        [_navigaitonView hideBottomLine];
        @weakify(self)
        _navigaitonView.backItemHandle = ^{
            @strongify(self)
            [self backItemAction];
        };
        
        _navigaitonView.rightItemHandle = ^{
            @strongify(self)
            [self rightButtonAction];
        };
    }
    return _navigaitonView;
}


- (ZFCommunityZmPostView *)zmPostView {
    if (!_zmPostView) {
        _zmPostView = [[ZFCommunityZmPostView alloc] init];
        _zmPostView.hotTopicModel = self.hotTopicModel;
        _zmPostView.showsBlock = ^{
            // firebase 按钮原先叫join
            [ZFFireBaseAnalytics selectContentWithItemId:@"click_join" itemName:@"join in" ContentType:@"explore_topic_detail" itemCategory:@"Button"];
        };
        _zmPostView.outfitsBlock = ^{
            
        };
    }
    return _zmPostView;
}

@end
