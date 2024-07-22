//
//  ZFCommunityAccountViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/7/26.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityAccountViewController.h"
#import "ZFCommunityFollowersViewController.h"
#import "ZFCommunityFollowingViewController.h"
#import "ZFCommunityPostListViewController.h"
#import "ZFUserInfoViewController.h"
#import "ZFWebViewViewController.h"
#import "ZFCommunityPostDetailPageVC.h"
#import "UINavigationItem+ZFChangeSkin.h"

#import "ZFInitViewProtocol.h"
#import "ZFShare.h"
#import "ZFCommunityAccountInfoView.h"
#import "ZFCommunityAccountSelectView.h"
#import "ZFCommunityAccountShowView.h"
#import "ZFCommunityAccountFavesView.h"
#import "ZFCommuntityContainerTableView.h"
#import "ZFSystemPhototHelper.h"
#import "ZFCommunityMenuView.h"

#import "ZFCommunityFavesItemModel.h"
#import "ZFCommunityAccountInfoModel.h"
#import "ZFCommunityAccountViewModel.h"
#import "ZFCommunityAccountShowsModel.h"
#import "ZFCommunityAccountLikesModel.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "MF_Base64Additions.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "ZFRequestModel.h"
#import "Constants.h"

#import "ZFCommunityAccountAOP.h"

typedef NS_ENUM(NSInteger, ZFCommunityAccountViewType) {
    ZFCommunityAccountViewTypeShow = 0,
    ZFCommunityAccountViewTypeFaves,
};

NSString *const kZFCommunityEditOlderVersion  = @"kZFCommunityEditOlderVersion";

@interface ZFCommunityAccountViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
ZFShareViewDelegate,
ZFInitViewProtocol,
ZFCommunityAccountShowViewProtocol,
ZFCommunityAccountFavesViewProtocol
>

@property (nonatomic, strong) ZFCommunityAccountInfoView            *headerView;
@property (nonatomic, strong) ZFCommunityAccountSelectView          *selectView;
@property (nonatomic, strong) ZFCommunityAccountViewModel           *viewModel;
@property (nonatomic, strong) ZFShareView                           *shareView;
@property (nonatomic, strong) ZFCommunityAccountShowsModel          *shareShowModel;
@property (nonatomic, strong) ZFCommunityAccountLikesModel          *shareLikeModel;
@property (nonatomic, assign) BOOL                                  isLike;
@property (nonatomic, strong) ZFCommuntityContainerTableView        *containerTableView;
@property (nonatomic, strong) ZFCommunityMenuView                   *menuView;

@property (nonatomic, strong) ZFCommunityAccountAOP                 *analyticsAOP;

@end

@implementation ZFCommunityAccountViewController

#pragma mark - Life Cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_shareView) {
        [self.shareView removeFromSuperview];
        self.shareView.delegate = nil;
        self.shareView = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.headerView isShowBirthdayGift];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.menuView hideView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];

    
    [self zfInitView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStatusChangeValue:) name:kFollowStatusChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUserInfo:) name:kChangeUserInfoNotification object:nil];
    
    //添加一个透明视图让事件传递到顶层,使其能够侧滑返回
    [self shouldShowLeftHoledSliderView:self.view.height];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = !ZFIsEmptyString(self.userName) ? self.userName : ZFLocalizedString(@"Tabbar_Z-Me", nil);
    self.view.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
    [self.view addSubview:self.containerTableView];
}

- (void)zfAutoLayoutView {
    
}

//// ===== 不能用，H5用的 ===== /////
/**
- (void)jionCommissionPlan {
    @weakify(self)
    [self.viewModel requestJionCommissionNetwork:nil completion:^(id obj) {
        @strongify(self)
        if (ZFJudgeNSDictionary(obj)) {
            NSDictionary *dic = (NSDictionary *)obj;
            if ([dic[@"is_affiliate"] integerValue] > 0) {
                //加入成功
            }
        }
    } failure:^(id obj) {
        
    }];
=======
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
>>>>>>> developer_xl_390
}

- (void)checkCommissionPlan {
    @weakify(self)
    [self.viewModel requestCheckCommissionNetwork:nil completion:^(id obj) {
        @strongify(self)
        if (ZFJudgeNSDictionary(obj)) {
            NSDictionary *dic = (NSDictionary *)obj;
            if ([dic[@"is_affiliate"] integerValue] > 0) {
                //加入成功
                ZFCommunityAccountInfoModel *model = self.headerView.model;
                model.affiliate_id = [dic[@"is_affiliate"] integerValue];
                self.headerView.model = model;
            }
        }
    } failure:^(id obj) {
        
    }];
}
*/

#pragma mark - notification methods

- (void)followStatusChangeValue:(NSNotification *)noti {
    NSDictionary *dict = noti.object;
    BOOL isFollow = [dict[@"isFollow"] boolValue];
    NSString *followedUserId = dict[@"userId"];
    [self changeInfoViewFollowInfoWithFollow:isFollow andFollowId:followedUserId];
}

- (void)changeInfoViewFollowInfoWithFollow:(BOOL)isFollow
                               andFollowId:(NSString *)followedUserId
{
    ZFCommunityAccountInfoModel *userInfoModel = self.headerView.model;
    if ([USERID isEqualToString: self.userId]) { // mystyle  只改变Following
        if (isFollow) {
            userInfoModel.followingCount += 1;
        } else{
            userInfoModel.followingCount -= 1;
        }
        
    } else { // UserStyle  只改变Followers
        if ([self.userId isEqualToString:followedUserId]) {
            if (isFollow) {
                userInfoModel.followersCount += 1;
            }else{
                userInfoModel.followersCount -= 1;
            }
            userInfoModel.isFollow = isFollow;
        }
    }
    self.headerView.model = userInfoModel;
    
    // 这里因为社区的数据可能和后台不同步,因此需要取后台的个人标题
    if ([userInfoModel.userId isEqualToString:USERID]) {
        AccountModel *account = [AccountManager sharedManager].account;
        self.navigationItem.title = ZFToString(account.nickname);
    } else {
        self.navigationItem.title = ZFToString(userInfoModel.nickName);
    }
    
    //显示导航按钮
    [self convertNavgationButton];
}

/**
 * userInfo更新通知
 */
- (void)changeUserInfo:(NSNotification *)noti {
    if (self.headerView.model) {
        AccountModel *account = [AccountManager sharedManager].account;
        ZFCommunityAccountInfoModel *userInfoModel = self.headerView.model;
        userInfoModel.nickName = account.nickname;
        userInfoModel.avatar = account.avatar;
        self.headerView.model = userInfoModel;
        self.navigationItem.title = ZFToString(userInfoModel.nickName);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger curreentPage = scrollView.contentOffset.x / KScreenWidth;
    
    //occ阿语修改
    self.selectView.currentType = [ZFCommunityAccountSelectView arCurrentType:curreentPage];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self setShowOrFavesScrollView:scrollView scrollEnabled:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self setShowOrFavesScrollView:scrollView scrollEnabled:NO];
}

#pragma mark  在横屏滚动的时候，禁止里面子类垂直滑动
- (void)setShowOrFavesScrollView:(UIScrollView *)scrollView scrollEnabled:(BOOL)enabled {
    
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)scrollView;
        NSInteger numberSection = [collectionView numberOfSections];
        
        for (int i = 0; i < numberSection; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            
            if ([cell isKindOfClass:[ZFCommunityAccountShowView class]]) {
                ZFCommunityAccountShowView *showView = (ZFCommunityAccountShowView *)cell;
                showView.collectionView.scrollEnabled = enabled;
            } else if([cell isKindOfClass:[ZFCommunityAccountFavesView class]]) {
                ZFCommunityAccountFavesView *favesView = (ZFCommunityAccountFavesView *)cell;
                favesView.favesListView.scrollEnabled = enabled;
            }
        }
    }
}


#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ZFCommunityAccountViewTypeShow) {
        ZFCommunityAccountShowView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCommunityAccountShowViewIdentifier forIndexPath:indexPath];
        cell.userId = self.userId;
        cell.controller = self;
        cell.delegate = self;
        
        @weakify(self);
        cell.communityAccountShowDetailCompletionHandler = ^(NSString *userId, NSString *reviewsId) {
            @strongify(self);
            [self jumpToCommunityDetailWithUserId:userId reviewsId:reviewsId andTitle:@""];
        };
        
        return cell;
        
    } else if (indexPath.section == ZFCommunityAccountViewTypeFaves) {
        
        ZFCommunityAccountFavesView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCommunityAccountFavesViewIdentifier forIndexPath:indexPath];
        cell.userId = self.userId;
        cell.controller = self;
        cell.delegate = self;
        
        @weakify(self);
        cell.communityFavesListDetailCompletionHandler = ^(NSString *userId, NSString *reviewId, NSInteger type) {
            @strongify(self);
            //跳转到详情页面
            [self jumpToCommunityDetailWithUserId:userId reviewsId:reviewId andTitle:@""];
        };
        
        cell.communityFavesAddMoreFriendsCompletionHandler = ^{
            @strongify(self);
            //跳转到搜索朋友页面
            [self pushToViewController:@"ZFCommunitySearchFriendsViewController"
                           propertyDic:nil];
        };
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(KScreenWidth, collectionView.height);
}

#pragma mark - ZFCommunityAccountShowViewProtocol

- (void)zf_accountShowView:(ZFCommunityAccountShowView *)showsView collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)zf_accountShowView:(ZFCommunityAccountShowView *)showsView collectionView:(UICollectionView *)collectionView didSelectItemCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)zf_accountShowView:(ZFCommunityAccountShowView *)showsView requestAccountShowListData:(BOOL)isFirstPage {
}

#pragma mark - ZFCommunityAccountFavesViewProtocol

- (void)zf_accountFavesView:(ZFCommunityAccountFavesView *)favesView collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)zf_accountFavesView:(ZFCommunityAccountFavesView *)favesView collectionView:(UICollectionView *)collectionView didSelectItemCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)zf_accountFavesView:(ZFCommunityAccountFavesView *)favesView requestAccountFavesListData:(BOOL)isFirstPage {
}
    
#pragma mark - Action

- (void)shareAccountAction {
    YWLog(@"分享个人---");
    [self.menuView hideView];
    self.shareView.viewType = ZFShareViewTypeCommunityAccount;
    self.shareView.topView = [self configureZFShareTopCenterView];
    [self.shareView open];
}

- (void)showAccountMenuAction {
    [self.menuView showView:self.view startPoint:CGPointMake(KScreenWidth - 160 - 8, 0)];
}

- (void)followAccountAction {
    
    if (![AccountManager sharedManager].isSignIn) {
        [self.navigationController judgePresentLoginVCCompletion:nil];
        return ;
    }
    if (self.headerView.model) {
        
        //请求参数
        NSDictionary *dict = @{kLoadingView : self.view,
                               kRequestModelKey : self.headerView.model};
        if (self.headerView.model.isFollow) {
            NSString *message = ZFLocalizedString(@"MyStylePage_Unfollow_Tip",nil);
            NSString *otherTitle = ZFLocalizedString(@"MyStylePage_Unfollow",nil);
            NSString *cancelTitle = ZFLocalizedString(@"Cancel",nil);
            
            ShowAlertView(nil, message, @[otherTitle], ^(NSInteger buttonIndex, id buttonTitle) {
                [self.viewModel requestFollowNetwork:dict completion:nil failure:nil];
            }, cancelTitle, nil);
        } else {
            // 关注/取消关注
            [self.viewModel requestFollowNetwork:dict completion:nil failure:nil];
        }
    }
}

/**
 跳转到社区搜索页面
 */
- (void)jumpToMessageViewController {
    [self pushToViewController:@"ZFCommunitySearchFriendsViewController"
                   propertyDic:nil];
}

//提示
- (void)jumpToTipsWebViewController {
    ZFWebViewViewController *webViewVC = [[ZFWebViewViewController alloc] init];
    NSString *appCommunityIntroURL = [YWLocalHostManager appCommunityIntroURL];
    webViewVC.link_url = [NSString stringWithFormat:@"%@?lang=%@",appCommunityIntroURL, [ZFLocalizationString shareLocalizable].nomarLocalizable];
    [self.navigationController pushViewController:webViewVC animated:YES];
}

//获取博主分佣
- (void)jumpJoinJoinWebViewController {

    ZFWebViewViewController *webViewVC = [[ZFWebViewViewController alloc] init];
    NSString *appCommunityIntroURL = [YWLocalHostManager appH5BaseURL];
    webViewVC.link_url = [NSString stringWithFormat:@"%@%@?is_app=1&lang=%@",appCommunityIntroURL,ZFCommunityAccountJoinJoin, [ZFLocalizationString shareLocalizable].nomarLocalizable];
    [self.navigationController pushViewController:webViewVC animated:YES];
}

//关注
- (void)jumpToFollowingViewController {
    ZFCommunityFollowingViewController *followingVC = [[ZFCommunityFollowingViewController alloc] init];
    followingVC.userId = self.userId;
    [self.navigationController pushViewController:followingVC animated:YES];
}


//礼物/拼团
- (void)jumpToGiftWebViewController {
    
    ZFWebViewViewController *webViewVC = [[ZFWebViewViewController alloc] init];
    NSString *appCommunityIntroURL = [YWLocalHostManager appH5BaseURL];
    webViewVC.link_url = [NSString stringWithFormat:@"%@%@?is_app=1&is_on_gtm=1&uid=%@&blogId=%@&lang=%@",appCommunityIntroURL,ZFCommunityAccountGroupBuying,USERID.base64String,ZFToString(self.userId).base64String, [ZFLocalizationString shareLocalizable].nomarLocalizable];
    [self.navigationController pushViewController:webViewVC animated:YES];
}

//抽奖
- (void)jumpToDrawWebViewController {
    
    ZFWebViewViewController *webViewVC = [[ZFWebViewViewController alloc] init];
    //NSString *appCommunityIntroURL = [YWLocalHostManager appH5ELFBaseURL];

    if ([YWLocalHostManager isDevelopStatus]) {
        webViewVC.link_url = [NSString stringWithFormat:@"%@?is_app=1&uid=%@&blogId=%@&lang=%@",ZFCommunityAccountDebugLotteries,USERID.base64String,ZFToString(self.userId).base64String, [ZFLocalizationString shareLocalizable].nomarLocalizable];
    } else {
        webViewVC.link_url = [NSString stringWithFormat:@"%@?is_app=1&uid=%@&blogId=%@&lang=%@",ZFCommunityAccountReleaseLotteries,USERID.base64String,ZFToString(self.userId).base64String, [ZFLocalizationString shareLocalizable].nomarLocalizable];
    }
    [self.navigationController pushViewController:webViewVC animated:YES];
}

//V字等级说明
- (void)jumpToUserRankIntroduceWebViewController {
    
    ZFWebViewViewController *webViewVC = [[ZFWebViewViewController alloc] init];
    webViewVC.link_url = [NSString stringWithFormat:@"%@&is_app=1&lang=%@",ZFCommunityAccountUserRank, [ZFLocalizationString shareLocalizable].nomarLocalizable];
    [self.navigationController pushViewController:webViewVC animated:YES];
}

- (void)jumpToFollowerViewController {
    ZFCommunityFollowersViewController *follwerVC = [[ZFCommunityFollowersViewController alloc] init];
    follwerVC.userId = self.userId;
    [self.navigationController pushViewController:follwerVC animated:YES];
}

- (void)jumpToProfileViewController {
    [self pushToViewController:@"ZFUserInfoViewController" propertyDic:nil];
}

- (void)jumpChoosePhotoController {
    [ZFSystemPhototHelper showActionSheetChoosePhoto:self callBlcok:^(UIImage *uploadImage) {
        YWLog(@"uploadImage====%@",uploadImage);
        [self changeUserInfo:nil];
    }];
}

- (void)jumpToCommunityDetailWithUserId:(NSString *)userId reviewsId:(NSString *)reviewsId andTitle:(NSString *)title {

    ZFCommunityPostDetailPageVC *topicDetailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:reviewsId title:@""];
    [self.navigationController pushViewController:topicDetailViewController animated:YES];
}


#pragma mark - 添加导航按钮

/**
 * 是否显示导航按钮
 */
- (void)convertNavgationButton
{
    if ([self.headerView.model.userId isEqualToString:USERID]) {
        //添加导航按
        UIButton *shartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shartButton setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
        [shartButton setImage:ZFImageWithName(@"GoodsDetail_shareIcon") forState:UIControlStateNormal];
        [shartButton setImage:ZFImageWithName(@"GoodsDetail_shareIcon") forState:UIControlStateSelected];

        shartButton.adjustsImageWhenHighlighted = NO;
        [shartButton addTarget:self action:@selector(shareAccountAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
        [moreButton setImage:ZFImageWithName(@"community_topicdetail_delete") forState:UIControlStateNormal];
        [moreButton setImage:ZFImageWithName(@"community_topicdetail_delete") forState:UIControlStateSelected];
        
        moreButton.adjustsImageWhenHighlighted = NO;
        [moreButton addTarget:self action:@selector(showAccountMenuAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc]initWithCustomView:shartButton];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];

        UIBarButtonItem *tipsItem = [[UIBarButtonItem alloc]initWithCustomView:moreButton];
        
        self.navigationItem.rightBarButtonItems = @[tipsItem, shareItem, negativeSpacer];
    } else {
        
        UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [followButton setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];

        followButton.adjustsImageWhenHighlighted = NO;
        [followButton addTarget:self action:@selector(followAccountAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *followItem = [[UIBarButtonItem alloc]initWithCustomView:followButton];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        
        //添加导航按
        UIButton *shartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shartButton setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
        
        [shartButton setImage:ZFImageWithName(@"GoodsDetail_shareIcon") forState:UIControlStateNormal];
        [shartButton setImage:ZFImageWithName(@"GoodsDetail_shareIcon") forState:UIControlStateSelected];
        
        shartButton.adjustsImageWhenHighlighted = NO;
        [shartButton addTarget:self action:@selector(shareAccountAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc]initWithCustomView:shartButton];
        
        if (self.headerView.model.affiliate_id) {
            self.navigationItem.rightBarButtonItems = @[shareItem,followItem,negativeSpacer];
        } else {
            self.navigationItem.rightBarButtonItems = @[shareItem];
        }
        
        //这个需要放到添加后面
        if (self.headerView.model.affiliate_id > 0 && self.headerView.model.isFollow) {
            [followButton setImage:ZFImageWithName(@"community_follow_gray") forState:UIControlStateNormal];
            [followButton setImage:ZFImageWithName(@"community_follow_gray") forState:UIControlStateSelected];
        } else {
            [followButton setImage:ZFImageWithName(@"community_follow") forState:UIControlStateNormal];
            [followButton setImage:ZFImageWithName(@"community_follow") forState:UIControlStateSelected];
            [followButton zfChangeButtonSkin];

        }
    }
}

#pragma mark  导航菜单
- (NSArray *)createMenuDatas {
    ZFMenuItem *menu1 = [[ZFMenuItem alloc] init];
    menu1.img = ZFImageWithName(@"community_accountAdd");
    menu1.index = 0;
    menu1.name = ZFLocalizedString(@"community_account_find_friends", nil);
    
    ZFMenuItem *menu2 = [[ZFMenuItem alloc] init];
    menu2.img = ZFImageWithName(@"community_AccountHelp");
    menu2.index = 1;
    menu2.name = ZFLocalizedString(@"community_account_help", nil);
    
    return @[menu1,menu2];
}

#pragma mark - ZFShareViewDelegate
- (void)zfShsreView:(ZFShareView *)shareView didSelectItemAtIndex:(NSUInteger)index
{
    if (shareView.viewType == ZFShareViewTypeCommunityAccount) {//分享个人中心
        
        [ZFShareManager shareManager].model = [self adjustCommunityAccountShareModel];
        [ZFShareManager shareManager].model.share_imageURL = shareView.topView.imageName;
        [ZFShareManager shareManager].model.share_description = shareView.topView.title;
        [ZFShareManager shareManager].model.sharePageType = ZFSharePage_CommunityStyleCenterType;
        [ZFShareManager shareManager].currentShareType = index;
    } else {

        [ZFShareManager shareManager].model = [self adjustNativeShareModel];
        [ZFShareManager shareManager].model.share_imageURL = shareView.topView.imageName;
        [ZFShareManager shareManager].model.share_description = shareView.topView.title;
        [ZFShareManager shareManager].model.sharePageType = ZFSharePage_CommunityStyleCenterType;
        [ZFShareManager shareManager].currentShareType = index;
        
    }
    
    switch (index) {
        case ZFShareTypeWhatsApp: {
            [[ZFShareManager shareManager] shareToWhatsApp];
        }
            break;
        case ZFShareTypeFacebook: {
            [[ZFShareManager shareManager] shareToFacebook];
        }
            break;
        case ZFShareTypeMessenger: {
            [[ZFShareManager shareManager] shareToMessenger];
        }
            break;
        case ZFShareTypePinterest: {
            [[ZFShareManager shareManager] shareToPinterest];
        }
            break;
        case ZFShareTypeCopy: {
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
}

//普通商品
- (ZFShareTopView *)configureZFShareTopViewWithModel:(id )model {
    ZFShareTopView *shareTopView = [[ZFShareTopView alloc] init];
    ZFCommunityPictureModel *imageModel = nil;
    NSString *title = @"";
    
    if (self.isLike) {
        
        ZFCommunityAccountShowsModel *showModel = [ZFCommunityAccountShowsModel yy_modelWithJSON:model];
        imageModel = (ZFCommunityPictureModel *)showModel.reviewPic.firstObject;
        title = showModel.content;
    } else {
        ZFCommunityFavesItemModel *faveModel = (ZFCommunityFavesItemModel *)model;
        ZFCommunityFavesItemModel *tempModel = [faveModel mutableCopy];
        imageModel = (ZFCommunityPictureModel *)tempModel.reviewPic.firstObject;
        title = tempModel.content;
    }
    [shareTopView updateImage:imageModel.bigPic
                        title:title
                      tipType:ZFShareDefaultTipTypeCommon];
    return shareTopView;
}

//佣金
- (ZFShareTopView *)configureZFShareTopCenterView {
    // 这里因为社区的数据可能和后台不同步,因此需要取后台的个人标题
    NSString *titleName = ZFToString(self.headerView.model.nickName);
    if ([self.headerView.model.userId isEqualToString:USERID]) {
        AccountModel *account = [AccountManager sharedManager].account;
        titleName = ZFToString(account.nickname);
    }
    
    if (self.headerView.model.affiliate_id > 0) {
        titleName = [NSString stringWithFormat:ZFLocalizedString(@"community_xx'sFashion_Shop", nil),titleName];
    }
    
    ZFShareTopView *shareTopView = [[ZFShareTopView alloc] init];
    [shareTopView updateImage:@""
                        title:titleName
                      tipType:ZFShareDefaultTipTypeCommunityAccount];
    
    return shareTopView;
}

//普通帖子
- (NativeShareModel *)adjustNativeShareModel {
    NativeShareModel *model = [[NativeShareModel alloc] init];
    NSString *nicknameStr;
    NSString *reviewID;
    NSString *userID;
    if (self.isLike) {
        nicknameStr = [NSString stringWithFormat:@"%@",self.shareLikeModel.nickName];
        reviewID = self.shareLikeModel.reviewId;
        userID = self.shareLikeModel.userId;
    } else {
        nicknameStr = [NSString stringWithFormat:@"%@",self.shareShowModel.nickName];
        reviewID = self.shareShowModel.reviewId;
        userID = self.shareShowModel.userId;
    }
    NSRange range = [nicknameStr rangeOfString:@" "];
    if (range.location != NSNotFound) {
        nicknameStr = [nicknameStr stringByReplacingOccurrencesOfString:@" " withString:@"_"]; //有空格
    }
    NSString *appCommunityShareURL = [YWLocalHostManager appCommunityShareURL];
    model.share_url =  [NSString stringWithFormat:@"%@?actiontype=6&url=2,%@,%@&name=%@&source=sharelink&lang=%@",appCommunityShareURL,reviewID,userID,nicknameStr,[ZFLocalizationString shareLocalizable].nomarLocalizable];
    model.fromviewController = self;
    return model;
}

//个人中心分享地址
- (NativeShareModel *)adjustCommunityAccountShareModel {
    NativeShareModel *model = [[NativeShareModel alloc] init];

    NSString *appCommunityShareURL = [YWLocalHostManager appH5BaseURL];
    model.share_url =  [NSString stringWithFormat:@"%@%@?uid=%@&lang=%@",appCommunityShareURL,ZFCommunityAccountJoinMe,ZFToString(self.userId).base64String,[ZFLocalizationString shareLocalizable].nomarLocalizable];
    model.fromviewController = self;
    return model;
}
#pragma mark - setter/getter

- (void)setUserId:(NSString *)userId {
    _userId = userId;
    
    if ([_userId isEqualToString:USERID] && !ZFIsEmptyString(_userId)) {
        [self.headerView defaultUserIsEditState];
    }
    NSDictionary *dic = @{kRequestUserIdKey : ZFToString(_userId),
                          kLoadingView : self.view};
    @weakify(self);
    [self.viewModel requestNetwork:dic completion:^(ZFCommunityAccountInfoModel *obj) {
        @strongify(self);

        self.headerView.model = obj;
        CGRect rect = CGRectZero;
        rect.size = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        self.headerView.frame = rect;
        self.containerTableView.tableHeaderView = self.headerView;
        
        NSString *appOlderVersion = GetUserDefault(kZFCommunityEditOlderVersion);
        if (![appOlderVersion isEqualToString:ZFSYSTEM_VERSION]) {
            [self.headerView setUserProfileTag];
        }
        
        // 这里因为社区的数据可能和后台不同步,因此需要取后台的个人标题
        if ([self.headerView.model.userId isEqualToString:USERID]) {
            AccountModel *account = [AccountManager sharedManager].account;
            self.navigationItem.title = ZFToString(account.nickname);
        } else {
            self.navigationItem.title = ZFToString(self.headerView.model.nickName);
        }
        
        //添加导航按
        [self convertNavgationButton];
    } failure:nil];
}


- (ZFCommunityAccountViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityAccountViewModel alloc] init];
    }
    return _viewModel;
}

- (ZFCommunityAccountInfoView *)headerView {
    if (!_headerView) {
        
        _headerView = [[ZFCommunityAccountInfoView alloc] initWithFrame:CGRectZero];
        _headerView.userInteractionEnabled = NO;
        
        CGRect rect = CGRectZero;
        rect.size = [_headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        _headerView.frame = rect;
        
        @weakify(self);
        [_headerView setInfoBtnActionBlcok:^(CommunityAccountInfoActionType actionType, ZFCommunityAccountInfoModel *model) {
            @strongify(self);
            if (actionType == FollowingButtonActionType) {
                [self jumpToFollowingViewController];
                
            } else if (actionType == FollowerButtonActionType) {
                [self jumpToFollowerViewController];
                
            } else if (actionType == FollowButtonActionType) {
                [self followAccountAction];
            }
            else if (actionType == EditProfileButtonActionType) {
                [self jumpToProfileViewController];
                [self.headerView clearUserProfileTag];
                SaveUserDefault(kZFCommunityEditOlderVersion, ZFSYSTEM_VERSION);
                
            } else if (actionType == UploadAvatarButtonActionType) {
                [self jumpChoosePhotoController];
                
            } else if (actionType == HelpButonActionType) {
                [self jumpJoinJoinWebViewController];
                
            } else if (actionType == GiftButtonAction) {//礼物
                [self jumpToGiftWebViewController];
                
            } else if (actionType == DrawButtonAction) {//抽奖
                [self jumpToDrawWebViewController];
            } else if (actionType == UserRankInforActionType) { //用户等级说明
                [self jumpToUserRankIntroduceWebViewController];
            }
        }];
    }
    return _headerView;
}

- (ZFCommunityAccountSelectView *)selectView {
    if (!_selectView) {
        CGRect rect = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), KScreenWidth, kSelectViewHeight);
        _selectView = [[ZFCommunityAccountSelectView alloc] initWithFrame:rect];
        @weakify(self);
        _selectView.communityAccountSelectCompletionHandler = ^(ZFCommunityAccountSelectType type) {
            @strongify(self);
            //occ阿语修改
            CGFloat arX = [ZFCommunityAccountSelectView arCurrentType:type];
            [self.containerTableView.collectionView scrollRectToVisible:CGRectMake(arX * KScreenWidth , 0, KScreenWidth, KScreenHeight - 208) animated:NO];

        };
    }
    return _selectView;
}

/**
 * 初始化容器表格
 */
- (ZFCommuntityContainerTableView *)containerTableView
{
    if(!_containerTableView){
        CGRect rect = CGRectMake(0, 0, KScreenWidth, KScreenHeight-(NAVBARHEIGHT + STATUSHEIGHT));
        _containerTableView = [[ZFCommuntityContainerTableView alloc] initWithFrame:rect style:UITableViewStylePlain containerDelagate:self sectionHeaderView:self.selectView];
        _containerTableView.delegate = _containerTableView;
        _containerTableView.dataSource = _containerTableView;
        _containerTableView.tableHeaderView = self.headerView;
        _containerTableView.tableFooterView = [UIView new];
        _containerTableView.rowHeight = rect.size.height;
        _containerTableView.bounces = NO;
        _containerTableView.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
        _containerTableView.showsVerticalScrollIndicator = NO;
        _containerTableView.showsHorizontalScrollIndicator = NO;
        _containerTableView.estimatedRowHeight = 0;
        _containerTableView.estimatedSectionFooterHeight = 0;
        _containerTableView.estimatedSectionHeaderHeight = 0;
        if (@available(iOS 11.0, *)) {
            _containerTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _containerTableView;
}

- (ZFShareView *)shareView {
    if (!_shareView) {
        _shareView = [[ZFShareView alloc] init];
        _shareView.delegate = self;
        [ZFShareManager authenticatePinterest];
    }
    return _shareView;
}

- (ZFCommunityMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[ZFCommunityMenuView alloc] initWithFrame:self.view.bounds menus:[self createMenuDatas]];
        @weakify(self)
        _menuView.menuSelectBlock = ^(ZFMenuItem *menuItem) {
            @strongify(self)
            if (menuItem.index == 0) {
                [self jumpToMessageViewController];
            } else {
                [self jumpToTipsWebViewController];
            }
        };
    }
    return _menuView;
}

- (ZFCommunityAccountAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFCommunityAccountAOP alloc] init];
    }
    return _analyticsAOP;
}

@end
