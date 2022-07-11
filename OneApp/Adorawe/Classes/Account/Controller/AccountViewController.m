//
//  OOSVAccountVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OOSVAccountVC.h"
#import "EditProfileViewController.h"
#import "STLActivityWWebCtrl.h"
#import "WMCouponViewController.h"
#import "WishListViewController.h"
#import "STLGoodsHistoryCtrl.h"
#import "STLMyGoodsReviewCtrl.h"
#import "HelpViewController.h"
#import "FeedbackViewController.h"
#import "AddressBookViewController.h"
#import "OSSVDetailsVC.h"
#import "STLAccountOrderPageController.h"
#import "STLBindCellNumViewController.h"
#import "AppDelegate.h"

#import "STLAlertControllerView.h"
#import "AccountFooterView.h"

#import "AccountViewModel.h"
#import "AddressBookModel.h"
#import "OSSVHomesViewModel.h"
#import "RateModel.h"
#import "STLMessageListModel.h"
#import "CommendModel.h"
#import "OSSVHomeGoodsListModel.h"

#import "AccountManager.h"
#import "STLConfigureDomainManager.h"
#import "STLTabbarManager.h"
#import "STLCommonRequestManager.h"

#import "UINavigationController+FDFullscreenPopGesture.h"
#import "OSSVAccountsMainsView.h"

#import "STLMySizeViewController.h"
#import "STLStrongFellCtrl.h"
#import "STLWapBannerAPI.h"
//@import LiveChat;

#import "Adorawe-Swift.h"

@interface OOSVAccountVC ()<OSSVAccountsVCProtocol>

@property (nonatomic, strong) OSSVAccountsMainsView    *accountMainView;
@property (nonatomic, strong) UIView                *topSpaceView;
@property (nonatomic, strong) AccountViewModel      *viewModel;
@property (nonatomic, strong) STLSocialListViewModel *socialViewModel;
@property (nonatomic, strong) NSArray               *cellTypeModelArr;

@property (nonatomic, assign) BOOL                  isShowTop;

@property (nonatomic, assign) BOOL                   hasPlatformsRequest;


@end

@implementation OOSVAccountVC

#pragma mark - Life Cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 谷歌统计
    [self refreshOnLine];

    [self loadMessageData];
    
    //刷新历史浏览记录
    [self.accountMainView refreshHistoryData];
    
    if (!self.hasPlatformsRequest) {
        [self requestSocilaPlatforms];
    }

    [self refreshUserInfor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 显示导航栏分隔线
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//   
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"accountTitle", nil);
    
    self.firstEnter = YES;
    self.fd_prefersNavigationBarHidden = YES;
    
    [self initSubViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logStateNotif:) name:kNotif_Logout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logStateNotif:) name:kNotif_Login object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeValue:) name:kNotif_ChangeUserInfo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserInfor) name:kNotif_RefrshUserInfo object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadOnlineRequest) name:kNotif_OnlineAddressUpdate object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOrHiddenMessageDot) name:kNotif_ChangeMessageCountDot object:nil]; // 消息未读
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeValue:) name:kNotif_ChangeAccountRedDot object:nil]; // 刷新个人中心

    
    [self requestBanner];
    
}

#pragma mark - Notification

- (void)reloadOnlineRequest {

}

- (void)requestSocilaPlatforms {
    
    @weakify(self)
    [self.socialViewModel requestNetwork:@{} completion:^(id obj) {
        @strongify(self)
        self.hasPlatformsRequest = YES;
        if (STLJudgeNSArray(obj)) {
            [AccountManager sharedManager].socialPlatforms = obj;
            [self.accountMainView.tableHeaderView updateFollowingDatas];
            if (APP_TYPE == 3) {
                [self.accountMainView reloadAccountTableView];
            }
        }
        
    } failure:^(id obj) {
        [AccountManager sharedManager].socialPlatforms = @[];
        [self.accountMainView.tableHeaderView updateFollowingDatas];
    }];
}
#pragma mark --更新用户信息
- (void)refreshUserInfor {
    if (USERID) {
        //内容发送通知
        [STLCommonRequestManager checkUpdateUserInfo:^(BOOL success) {
        }];
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self reInitaccountMainView];
//        });
//
       
        
    }
}

- (void)logStateNotif:(NSNotification *)notifi {
    [self.accountMainView reloadAccountTableView];
}


- (void)changeValue:(NSNotification *)notice {
    [self.accountMainView reloadAccountTableView];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.isShowTop ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;

}

#pragma mark - MakeUI
- (void)initSubViews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [STLThemeColor stlWhiteColor];
    
    [self.view addSubview:self.accountMainView];
    
    [self.accountMainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.view addSubview:self.topSpaceView];
    [self.topSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(kSCREEN_BAR_HEIGHT);
    }];
}

#pragma mark - Action
- (void)loadMessageData {
    
    if ([AccountManager sharedManager].isSignIn) {
        
        @weakify(self)
        [self.viewModel messageRequest:nil completion:^(STLMessageListModel *obj) {
            @strongify(self)
            [self updateMessageWithModel:obj];
        } failure:^(id obj) {
            
        }];
    }
}

- (void)updateMessageWithModel:(STLMessageListModel *)model {
    [AccountManager sharedManager].appUnreadMessageNum = [model.total_count integerValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_ChangeMessageCountDot object:nil];
    [self.accountMainView.tableHeaderView showOrHiddenMessageDot];
}

- (void)showOrHiddenMessageDot {
    [self.accountMainView.tableHeaderView showOrHiddenMessageDot];
}

-(void)requestBanner{
    ///1.3.8请求banner数据
    STLWapBannerAPI *requestAPI = [[STLWapBannerAPI alloc] init];
    [requestAPI startWithBlockSuccess:^(__kindof STLBaseRequest *request) {
        id requestJSON = [NSStringTool desEncrypt:request];
        if ([requestJSON isKindOfClass:[NSDictionary class]]) {
            if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
                NSDictionary *dict = requestJSON[kResult];
                NSString *rotationImgUrl = dict[@"wap_rotation"][@"banner_url"];
                NSString *inviteImgUrl = dict[@"wap_invite"][@"banner_url"];
                
                NSURL *rotationURL = nil;
                NSURL *inviteURL = nil;
                if (rotationImgUrl.length > 0) {
                    rotationURL = [NSURL URLWithString:rotationImgUrl];
                }
                if (inviteImgUrl.length >0) {
                    inviteURL = [NSURL URLWithString:inviteImgUrl];
                }
                if (inviteURL || rotationURL) {
                    //成功发通知更新UI
                    [NSNotificationCenter.defaultCenter postNotificationName:kAccountBannerNotiName object:nil userInfo:dict];
                }else{
                    //失败发通知更新UI
                    [NSNotificationCenter.defaultCenter postNotificationName:kAccountBannerNotiName object:nil userInfo:nil];
                }
                
            }
        }
    } failure:^(__kindof STLBaseRequest *request, NSError *error) {
        //失败发通知更新UI
        [NSNotificationCenter.defaultCenter postNotificationName:kAccountBannerNotiName object:nil userInfo:nil];
    }];
}


#pragma mark - Header Event

- (void)accountMainHeaderEvent:(AccountEventOperate)event {
    
    if (event == AccountEventLogin || event == AccountEventEditUserInfo) {
        if ([AccountManager sharedManager].isSignIn) {
            
            [STLAnalytics analyticsGAEventWithName:@"personal_action" parameters:@{
                @"screen_group":@"Me",
                @"action":@"Edit_profile"}];
            
            EditProfileViewController *editProVC = [[EditProfileViewController alloc] init];
            [self.navigationController pushViewController:editProVC animated:YES];
            
        } else {
            
            [STLAnalytics analyticsGAEventWithName:@"personal_action" parameters:@{
                @"screen_group":@"Me",
                @"action":@"Login"}];
            
            SignViewController *signVC = [SignViewController new];
            signVC.modalPresentationStyle = UIModalPresentationFullScreen;
            @weakify(self)
            signVC.modalBlock = ^{
                @strongify(self)
                
                STLTabBarController *tabbar = (STLTabBarController *)self.tabBarController;
                [tabbar setModel:STLMainMoudleAccount];
                STLNavigationController *nav = [tabbar navigationControllerWithMoudle:STLMainMoudleAccount];
                if (nav) {
                    if (nav.viewControllers.count>1) {
                        [nav popToRootViewControllerAnimated:NO];
                    }
                }
            };
            [self presentViewController:signVC animated:YES completion:nil];
        }
    } else if(event == AccountEventSetting) {
        STLSettingsViewController *settingVC = [[STLSettingsViewController alloc] init];
        [self.navigationController pushViewController:settingVC animated:YES];
        
        [STLAnalytics analyticsGAEventWithName:@"top_function" parameters:@{
               @"screen_group":@"Me",
               @"button_name":@"Setting"}];
        
    } else if(event == AccountEventMessage) {
        
        if ([AccountManager sharedManager].isSignIn) {
            STLMessageCtrl *messageVC = [[STLMessageCtrl alloc] init];
                [self.navigationController pushViewController:messageVC animated:YES];
            
        } else {
            
            SignViewController *signVC = [SignViewController new];
            signVC.modalPresentationStyle = UIModalPresentationFullScreen;
            @weakify(self)
            signVC.modalBlock = ^{
                @strongify(self)
                
                STLMessageCtrl *messageVC = [[STLMessageCtrl alloc] init];
                [self.navigationController pushViewController:messageVC animated:YES];
            };
            [self presentViewController:signVC animated:YES completion:nil];
        }
        
        [STLAnalytics analyticsGAEventWithName:@"top_function" parameters:@{
               @"screen_group":@"Me",
               @"button_name":@"Message"}];
    }
}

/// help、address、language...
- (void)accountMainHeaderService:(AccountServicesOperate )service title:(NSString *)title{

    [STLAnalytics analyticsGAEventWithName:@"personal_action" parameters:@{
        @"screen_group":@"Me",
        @"action":[NSString stringWithFormat:@"Service_%@",STLToString(title)]}];
    
    if(service == AccountServicesCurrency) {
       STLCurrencyViewController *currencyVC = [[STLCurrencyViewController alloc] init];
       [self.navigationController pushViewController:currencyVC animated:YES];
       
   } else if(service == AccountServicesLanguage) {
       STLLanguageViewController *languageVC = [[STLLanguageViewController alloc] init];
       [self.navigationController pushViewController:languageVC animated:YES];
       
   } else if(service == AccountServicesHelp) {
       HelpViewController *helpVC = [[HelpViewController alloc] init];
       [self.navigationController pushViewController:helpVC animated:YES];
       
       [STLAnalytics analyticsGAEventWithName:@"top_function" parameters:@{
              @"screen_group":@"Me",
              @"button_name":@"Help"}];
       
   } else if (![AccountManager sharedManager].isSignIn) {
       
       SignViewController *signVC = [SignViewController new];
       signVC.modalPresentationStyle = UIModalPresentationFullScreen;
       @weakify(self)
       signVC.modalBlock = ^{
           @strongify(self)
           [self actionServiceLogin:service];
       };
       [self presentViewController:signVC animated:YES completion:nil];
       
   } else {
       [self actionServiceLogin:service];
   }
}

- (void)actionServiceLogin:(AccountServicesOperate )service {
    
    if(service == AccountServicesAddress) {
        AddressBookViewController *addressVC = [[AddressBookViewController alloc] init];
        [self.navigationController pushViewController:addressVC animated:YES];
    } else if(service == AccountServicesMySize) {
        STLMySizeViewController *sizeVC = [[STLMySizeViewController alloc] init];
        [self.navigationController pushViewController:sizeVC animated:YES];
    }
}



///电话号码绑定
- (void)accountMainHeaderBindPhone:(AccountBindPhoneOperate)event{
    if (event == AccountBindPhoneClose) {
        [self.accountMainView reloadAccountTableView];
        
        
    }else if (event == AccountBindPhoneEnterIn){
        
        [STLAnalytics analyticsGAEventWithName:@"personal_action" parameters:@{
            @"screen_group":@"Me",
            @"action":@"Bind_Number"}];
        
        
        STLBindCellNumViewController *bindViewController = [[STLBindCellNumViewController alloc] init];
        bindViewController.closeBlock = ^{
            
        };
        bindViewController.tapSkipBlock = ^{
            [STLAnalytics analyticsGAEventWithName:@"personal_action" parameters:@{
                @"screen_group":@"Me",
                @"action":@"Bind_Number_Skip"}];
        };
        
        bindViewController.tapConfimBlock = ^{
            [STLAnalytics analyticsGAEventWithName:@"personal_action" parameters:@{
                @"screen_group":@"Me",
                @"action":@"Bind_Number_Confirm"}];
        };
//        bindViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        bindViewController.isModalPresent = YES;
        [self presentViewController:bindViewController animated:YES completion:^{
           
        }];
        
    }
}

//根据订单类型跳转到订单列表
- (void)accountMainHeaderOrder:(AccountOrderOperate)order title:(NSString *)title{
    if (![AccountManager sharedManager].isSignIn) {
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        signVC.modalBlock = ^{
            @strongify(self)
            [self actionOrderLogin:order title:title];
        };
        [self presentViewController:signVC animated:YES completion:nil];
    } else {
        [self actionOrderLogin:order title:title];
    }
}

- (void)actionOrderLogin:(AccountOrderOperate )type title:(NSString *)title {
    STLAccountOrderPageController *ctrl = [[STLAccountOrderPageController alloc] init];
    if(type == AccountOrderRewiewed) {
        
        //OrderStateTypeDelivered
        //数据GA 暂时给个4吧
        [STLAnalytics analyticsGAEventWithName:@"personal_action" parameters:@{
            @"screen_group":@"Me",
            @"action":[NSString stringWithFormat:@"Order_%@",@"4"]}];
        STLMyGoodsReviewCtrl *reviewVC = [[STLMyGoodsReviewCtrl alloc] init];
        [self.navigationController pushViewController:reviewVC animated:YES];
        return;
        
    } else if(type == AccountOrderUnpaid || type == AccountOrderProcessing || type == AccountOrderShipped) {
        
        //status参数:默认为0)[0-未付款，1-已支付，2-备货，3-已完全发货，4-已取消]
        NSString *status = @"0";
        if (type == AccountOrderUnpaid) {
            status = @"1";
        } else if (type == AccountOrderProcessing) {
            status = @"2";
        } else if (type == AccountOrderShipped) {
            status = @"3";
        }
        ctrl.choiceIndex = status;
        
        [STLAnalytics analyticsGAEventWithName:@"personal_action" parameters:@{
            @"screen_group":@"Me",
            @"action":[NSString stringWithFormat:@"Order_%@",status]}];
    }
    [self.navigationController pushViewController:ctrl animated:YES];

}

///优惠券、收藏、会员、金币
- (void)accountMainHeaderType:(AccountTypeOperate )type title:(NSString *)title {
    
    [STLAnalytics analyticsGAEventWithName:@"personal_action" parameters:@{
        @"screen_group":@"Me",
        @"action":[NSString stringWithFormat:@"Benefits_%@",STLToString(title)]}];
    
    if (![AccountManager sharedManager].isSignIn) {
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        signVC.modalBlock = ^{
            @strongify(self)
            [self actionHeaderOperate:type];
        };
        [self presentViewController:signVC animated:YES completion:nil];
    } else {
        [self actionHeaderOperate:type];
    }
}

- (void)actionHeaderOperate:(AccountTypeOperate )type {
    if (type == AccountTypeCoupon) {
        
        WMCouponViewController *couponVC = [[WMCouponViewController alloc] init];
        [self.navigationController pushViewController:couponVC animated:YES];
        
    } else if(type == AccountTypeWishlist) {
        
        NSString *pageName = [UIViewController currentTopViewControllerPageName];
        NSDictionary *sensorsDicClick = @{@"page_name":STLToString(pageName),
                                          @"attr_node_1":@"home_tab",
                                          @"attr_node_2":@"home_customer",
                                          @"attr_node_3":@"home_customer_wishlist",
                                          @"position_number":@(0),
                                          @"venue_position":@(0),
                                          @"action_type":@(0),
                                          @"url":@"",
        };
        [STLAnalytics analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDicClick];
        
        WishListViewController *wishListVC = [[WishListViewController alloc] init];
        [self.navigationController pushViewController:wishListVC animated:YES];
        
    }
    else if(type == AccountTypeMember) {
        if (!STLIsEmptyString(AccountManager.sharedManager.account.vip_url)) {
            STLActivityWWebCtrl *webVc = [[STLActivityWWebCtrl alloc] init];
            webVc.strUrl =  [STLToString(AccountManager.sharedManager.account.vip_url) stringByAppendingFormat:@"?currency=USD"];
            [self.navigationController pushViewController:webVc animated:YES];
        }
        
    }
    else if (type == AccountTypeCoins){//金币中心----签到页的URL
        if (!STLIsEmptyString([AccountManager sharedManager].account.coinCenterUrlStr)) {        
            
            NSString *urlString = STLToString([AccountManager sharedManager].account.coinCenterUrlStr);
            
            NSLog(@"接收到的url：%@", urlString);
            STLActivityWWebCtrl *webViewVC = [[STLActivityWWebCtrl alloc] init];
            NSString *lang = [STLLocalizationString shareLocalizable].nomarLocalizable; //语言
            RateModel *rate = [ExchangeManager localCurrency]; //当前货币
            NSString  *versionStr = kAppVersion; //APP版本号
            NSString *device_id = [AccountManager sharedManager].device_id;
            NSString *platform = @"ios";
            NSString *urlStr = [NSString stringWithFormat:@"%@&token=%@&lang=%@&currency=%@&version=%@&platform=%@&device_id=%@",urlString,STLToString(USER_TOKEN),lang,rate.code,versionStr,platform,device_id];
            webViewVC.strUrl = urlStr;
            [self.navigationController pushViewController:webViewVC animated:YES];
        }
        
    }
}


#pragma mark - OSSVAccountsVCProtocol

- (void)refreshNavgationBackgroundColorAlpha:(CGFloat)colorAlpha {
    
//    BOOL flag = NO;
//    if (colorAlpha > 0) {
//        self.topSpaceView.alpha = colorAlpha;
//        self.topSpaceView.hidden = NO;
//        flag = YES;
//    } else {
//        self.topSpaceView.alpha = 0;
//        self.topSpaceView.hidden = YES;
//    }
//    if (self.isShowTop != flag) {
//        self.isShowTop = flag;
//        [self setNeedsStatusBarAppearanceUpdate];
//    }
}

- (void)scrollContentOffsetY:(CGFloat)offsetY {
    
    BOOL flag = NO;
    if (offsetY >= [STLAccountHeaderView topBlackBgHeight] - [self fetchNavgationMaxY]) {
        self.topSpaceView.backgroundColor = [STLThemeColor stlWhiteColor];
        flag = YES;
    } else {
        self.topSpaceView.backgroundColor = [STLThemeColor col_0D0D0D];
    }
    
    if (self.isShowTop != flag) {
        self.isShowTop = flag;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}
- (void)requestAccountPageAllData {
    [self.accountMainView endRefreshingData];
    [self requestBanner];
}

- (CGFloat)fetchNavgationMaxY {
    return self.cellTypeModelArr.count > 0 ? kSCREEN_BAR_HEIGHT : 0;
}

- (CGFloat)fetchTabberHeight {
    return kTabBarHeight;
}

#pragma mark ----  商品点击
- (void)stl_selectedGoods:(id)goodsModel dataType:(AccountGoodsListType)dataType index:(NSInteger)index requestId:(nonnull NSString *)requestId{
    
    if (dataType == AccountGoodsListTypeRecommend && [goodsModel isKindOfClass:[OSSVHomeGoodsListModel class]]) {
        
        OSSVHomeGoodsListModel *model = (OSSVHomeGoodsListModel *)goodsModel;
        OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
        goodsDetailsVC.goodsId = model.goodsId;
        goodsDetailsVC.wid = model.wid;
        goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceAccountRecommend;
        goodsDetailsVC.coverImageUrl = STLToString(model.goodsImageUrl);
        NSDictionary *dic = @{kAnalyticsAction:[STLAnalytics sensorsSourceStringWithType:STLAppsflyerGoodsSourceAccountRecommend sourceID:@""],
                              kAnalyticsUrl:@"",
                              kAnalyticsPositionNumber:@(index+1),
                              kAnalyticsRequestId:STLToString(requestId),
        };
        [goodsDetailsVC.transmitMutDic addEntriesFromDictionary:dic];
        [self.navigationController pushViewController:goodsDetailsVC animated:YES];
        
    } else if(dataType == AccountGoodsListTypeHistory && [goodsModel isKindOfClass:[CommendModel class]]) {
        
        CommendModel *model = (CommendModel *)goodsModel;
        OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
        goodsDetailsVC.goodsId = model.goodsId;
        goodsDetailsVC.wid = model.wid;
        goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceAccountHistory;
        goodsDetailsVC.coverImageUrl = STLToString(model.goodsBigImg);
        NSDictionary *dic = @{kAnalyticsAction:[STLAnalytics sensorsSourceStringWithType:STLAppsflyerGoodsSourceAccountHistory sourceID:@""],
                              kAnalyticsUrl:@"",
                              kAnalyticsPositionNumber:@(index+1)
        };
        [goodsDetailsVC.transmitMutDic addEntriesFromDictionary:dic];
        [self.navigationController pushViewController:goodsDetailsVC animated:YES];

    }
}

#pragma mark - LazyLoad

- (NSArray *)cellTypeModelArr {
    if (!_cellTypeModelArr) {
        
        OSSVAccountHeadCellTypeModel *cellTypeModel = [[OSSVAccountHeadCellTypeModel alloc] init];
        cellTypeModel.cellType = AccountHeaderHorizontalScrollCellType;
        cellTypeModel.sectionRowCellClass = [UITableViewCell class];
        _cellTypeModelArr = [[NSArray alloc] initWithObjects:cellTypeModel, nil];
    }
    return _cellTypeModelArr;
}

- (AccountViewModel *)viewModel {
    
    if (!_viewModel) {
        _viewModel = [[AccountViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (STLSocialListViewModel *)socialViewModel {
    if (!_socialViewModel) {
        _socialViewModel = [[STLSocialListViewModel alloc] init];
    }
    return _socialViewModel;
}
#pragma mark -------头部View点击的Block回调
- (OSSVAccountsMainsView *)accountMainView {
    if (!_accountMainView) {
        _accountMainView = [[OSSVAccountsMainsView alloc] initWithVCProtocol:self];
        _accountMainView.sectionTypeModelArr = self.cellTypeModelArr;
        _accountMainView.backgroundColor = [STLThemeColor col_F5F5F5];
        
        @weakify(self)
        _accountMainView.accountHeaderServicesBlock = ^(AccountServicesOperate service, NSString * _Nonnull title) {
            @strongify(self)
            [self accountMainHeaderService:service title:title];
        };
        
        _accountMainView.accountHeaderBindPhoeBlock = ^(AccountBindPhoneOperate event) {
            @strongify(self)
            [self accountMainHeaderBindPhone:event];
        };
        
        _accountMainView.accountHeadeOrderBlock = ^(AccountOrderOperate type, NSString * _Nonnull title) {
            @strongify(self)
            [self accountMainHeaderOrder:type title:title];
        };
        
        _accountMainView.accountHeaderTypeBlock = ^(AccountTypeOperate type, NSString * _Nonnull title) {
            @strongify(self)
            [self accountMainHeaderType:type title:title];
        };
        
        _accountMainView.accountHeaderEventBlock = ^(AccountEventOperate event) {
            @strongify(self)
            [self accountMainHeaderEvent:event];

        };
    }
    return _accountMainView;
}

- (UIView *)topSpaceView {
    if (!_topSpaceView) {
        _topSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kSCREEN_BAR_HEIGHT)];
        _topSpaceView.backgroundColor = [STLThemeColor col_0D0D0D];
    }
    return _topSpaceView;
}


- (void)refreshOnLine {
    [STLCommonRequestManager refreshAppOnLineDomain];
}

@end
