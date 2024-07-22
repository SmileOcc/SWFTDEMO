//
//  ZFAccountViewController540.m
//  ZZZZZ
//
//  Created by YW on 2019/10/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountViewController540.h"
#import "ZFAccountVCImportFiles.h"

@interface ZFAccountViewController540 () < ZFAccountVCProtocol,ZFAccountHeaderCReusableViewDelegate >
@property (nonatomic, strong) NSArray                       *cellTypeModelArr;
@property (nonatomic, strong) ZFAccountNavigationView       *navigationView;
@property (nonatomic, strong) ZFAccountTableDataView        *tableDataView;
@property (nonatomic, strong) ZFAccountViewModel            *viewModel;
@property (nonatomic, strong) ZFAccountVCAnalyticsAop       *accountAop;
@end

@implementation ZFAccountViewController540

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    YWLog(@"ZFAccountViewController540 dealloc");
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.accountAop];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    
    [self zfInitView];
    [self zfLayoutSubViews];
    
    [self configuAccountViewCellType:0 refreshObj:nil shouldReload:YES];
    
    [self requestAccountPageAllData];
    [self addNotifycation];
}

- (void)addNotifycation {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCartNumberInfo) name:kCartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestAccountPageAllData) name:kLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestAccountPageAllData) name:kLogoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAppAccountSkin) name:kChangeSkinNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAccountCollectionView) name:kCurrencyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unpaidCountDownStopNotify) name:kAccountUnpaidCountDownStopNotify object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //刷新用户信息
    [self.tableDataView reloadUserLoginStatus];
    [self.navigationView configNavgationUserInfo];
    
    //刷新历史浏览记录
    [self.tableDataView refreshHistoryData];
    
     //自定义导航和头部换肤
    [self changeAppAccountSkin];
    
    //刷新购物车数量
    [self.navigationView refreshCartNumberInfo];
    
    //游客弹窗
    [self alertGameGuestTipsMessage];
    
    if (!self.alreadyEnter) {
        [self requestAccountInformation:NO];
    }
}

#pragma mark - 网络请求

///获取个人中心所有接口数据
- (void)requestAccountPageAllData {
    //获取个人中心显示信息
    [self requestAccountInformation:YES];
    
    //获取个人中心banner CMS接口
    [self requestUserCoreBanner];
    
    //获取未支付订单接口
    [self requestUnpaidOrderInfo];
}

/*
 * 获取个人中心显示信息: 包含未付款订单数，积分，优惠券显示等。
 */
- (void)requestAccountInformation:(BOOL)reloadTab {
    self.alreadyEnter = YES;
    if (![AccountManager sharedManager].isSignIn) return;
    @weakify(self)
    [self.viewModel requestUserInfoData:^(AccountModel *model) {
        @strongify(self)
        if (reloadTab) {
            [self.tableDataView reloadUserLoginStatus];
            [self.tableDataView reloadAccountTableView];
        } else {
            [self.tableDataView refreCategoryItemCell];
        }
        [self.tableDataView endRefreshingData];
    } failure:^(NSError *error) {
        @strongify(self)
        [self.tableDataView endRefreshingData];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.alreadyEnter = NO;
    });
}

/**
 * 获取个人中心显示的Banner CMS广告
 */
- (void)requestUserCoreBanner {
    @weakify(self)
    [self.viewModel requestUserCoreCMSBanner:^(NSArray<ZFNewBannerModel *> *cmsBannerArray) {
        @strongify(self)
        if (ZFJudgeNSArray(cmsBannerArray)) {//统计banner显示
            [self.viewModel analyticsGABanner:cmsBannerArray];
        }
        [self configuAccountViewCellType:(AccountHeaderCMSBannerCellType)
                             refreshObj:cmsBannerArray
                           shouldReload:YES];
         [self.tableDataView endRefreshingData];
    }];
}

/// 未支付订单倒计时完成刷新成不显示
- (void)unpaidCountDownStopNotify {
    [self refreshUnpaidOrderCell:nil];
}

/**
 * 请求展示未支付订单view
 */
- (void)requestUnpaidOrderInfo {
    if (![AccountManager sharedManager].isSignIn) {
        [self refreshUnpaidOrderCell:nil];
    } else {
        [ZFCommonRequestManager requestHasNoPayOrderTodo:^(MyOrdersModel *orderModel) {
            if ([orderModel isKindOfClass:[MyOrdersModel class]]) {
                [self refreshUnpaidOrderCell:orderModel];
            } else {
                [self refreshUnpaidOrderCell:nil];
            }
        } failBlcok:nil target:nil];
    }
}

- (void)refreshUnpaidOrderCell:(MyOrdersModel *)orderModel {
    if (![AccountManager sharedManager].isSignIn
        || ![orderModel isKindOfClass:[MyOrdersModel class]]) {
        orderModel = nil;
    }
    [self configuAccountViewCellType:(AccountHeaderUnpaidOrderCellType)
                         refreshObj:orderModel
                       shouldReload:YES];
}

///弹出游客转正后的提示弹窗
- (void)alertGameGuestTipsMessage {
    if ([AccountManager sharedManager].isSignIn
        && [AccountManager sharedManager].account.is_guest == 2) {
        
        NSString *key = [NSString stringWithFormat:@"ZFUserEmailGuestKey%@", ZFToString([AccountManager sharedManager].account.user_id)];
        NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (!email) {
            NSString *userEmail = [AccountManager sharedManager].account.email;
            [[NSUserDefaults standardUserDefaults] setObject:userEmail forKey:key];
            NSString *title = ZFLocalizedString(@"GameLogin_GuestOrderDetailTip", nil);
            NSString *content = ZFLocalizedString(@"GameLogin_GuestOrderDetailContent", nil);
            NSString *seeDetail = ZFLocalizedString(@"GameLogin_GuestOrderDetailSee", nil);
            NSString *OKTitle = ZFLocalizedString(@"OK", nil);
            @weakify(self)
            ShowAlertView(title, content, @[OKTitle], ^(NSInteger buttonIndex, id buttonTitle) {}, seeDetail, ^(id cancelTitle) {
                ///查看订单列表
                @strongify(self)
                [self accountDidSelectOrderList];
            });
        }
    }
}

#pragma mark - 配置页面Cell数据类型

/// 获取页面所有的Cell类型
- (void)configuAccountViewCellType:(ZFAccountHeaderCellType)refreshType
                       refreshObj:(id)refreshObj
                     shouldReload:(BOOL)shouldReloadData
{
    if (self.cellTypeModelArr) {
        for (ZFAccountHeaderCellTypeModel *cellTypeModel in self.cellTypeModelArr) {
            // 刷新配置匹配的Cell
            [self refreshSectionModel:cellTypeModel refreshType:refreshType refreshObj:refreshObj];
        }
        if (shouldReloadData) {
            YWLog(@"刷新页面对应Section==%ld", refreshType);
            self.tableDataView.sectionTypeModelArr = self.cellTypeModelArr;
        }
    } else {
        NSArray *cellTypeArr = [ZFAccountHeaderCellTypeModel fetchAllCellTypeArray];
        NSMutableArray *cellTypeModelArr = [NSMutableArray array];
        
        for (NSDictionary *cellTypeDict in cellTypeArr) {
            ZFAccountHeaderCellTypeModel *cellTypeModel = [[ZFAccountHeaderCellTypeModel alloc] init];
            cellTypeModel.cellType = [cellTypeDict.allKeys.firstObject integerValue];
            cellTypeModel.sectionRowCellClass = cellTypeDict.allValues.firstObject;
            
            [self refreshSectionModel:cellTypeModel refreshType:refreshType refreshObj:refreshObj];
            [cellTypeModelArr addObject:cellTypeModel];
        }
        self.cellTypeModelArr = cellTypeModelArr;
        self.tableDataView.sectionTypeModelArr = self.cellTypeModelArr;
    }
}

- (void)refreshSectionModel:(ZFAccountHeaderCellTypeModel *)cellTypeModel
                refreshType:(ZFAccountHeaderCellType)refreshType
                 refreshObj:(id)refreshObj
{
    switch (cellTypeModel.cellType) {
        case AccountHeaderCategoryItemCellType:     // 一定显示: 订单,收藏夹,优惠券,积分入口Cell
        {
            cellTypeModel.sectionRowHeight = 60;//75;
            cellTypeModel.sectionRowCount = 1;
            @weakify(self)
            cellTypeModel.accountCellActionBlock = ^(ZFAccountTableAllCellActionType actionType, id obj) {
                @strongify(self)
                [self jumpActionFromCategoryItemCell:actionType];
            };
        }
            break;
        case AccountHeaderUnpaidOrderCellType:      // 不一定显示: 未支付订单Cell
        {
            if (refreshType != AccountHeaderUnpaidOrderCellType) break;
            cellTypeModel.unpaidOrderModel = refreshObj;
            cellTypeModel.sectionRowHeight = 108;
            cellTypeModel.sectionRowCount = [refreshObj isKindOfClass:[MyOrdersModel class]] ? 1 : 0;
            @weakify(self)
            cellTypeModel.accountCellActionBlock = ^(ZFAccountTableAllCellActionType actionType, MyOrdersModel *orderModel) {
                @strongify(self)
                [self dealWithUnpaidAction:actionType orderModel:orderModel];
            };
        }
            break;
        case AccountHeaderCMSBannerCellType:        // 不一定显示: CMS广告Cell
        {
            if (refreshType != AccountHeaderCMSBannerCellType) break;
            cellTypeModel.cmsBannersModelArray = ZFJudgeNSArray(refreshObj) ? refreshObj : nil;
            NSArray *bannerArray = cellTypeModel.cmsBannersModelArray;
            
            CGFloat totalHeight = 0;
            for (ZFNewBannerModel *newBannerModel in bannerArray) {
                if (![newBannerModel isKindOfClass:[ZFNewBannerModel class]]) continue;
                NSInteger modelCount = newBannerModel.banners.count;
                if (modelCount == 0) continue;
                ZFBannerModel *bannerModel = newBannerModel.banners.firstObject;
                if (![bannerModel isKindOfClass:[ZFBannerModel class]]) continue;

                CGFloat onceWidth = KScreenWidth / modelCount;
                CGFloat onceHeigth = onceWidth * [bannerModel.banner_height floatValue] / [bannerModel.banner_width floatValue];
                totalHeight += onceHeigth;
            }
            cellTypeModel.sectionRowHeight = totalHeight;
            cellTypeModel.sectionRowCount = (bannerArray.count > 0) ? 1: 0;
            @weakify(self)
            cellTypeModel.accountCellActionBlock = ^(ZFAccountTableAllCellActionType actionType, ZFBannerModel *model) {
                @strongify(self)
                [self didSelectedAccountCmsBanner:model allBannerArray:bannerArray];
            };
        }
            break;
        case AccountHeaderHorizontalScrollCellType:   ///横向左右滚动Cell
        {
            cellTypeModel.sectionRowHeight = KScreenHeight - (NAVBARHEIGHT + STATUSHEIGHT + TabBarHeight);
            cellTypeModel.sectionRowCount = 0; //只需要头部所以不要Cell
        }
            break;
    }
}

- (void)didSelectedAccountCmsBanner:(ZFBannerModel *)bannerModel allBannerArray:(NSArray *)bannerArray {
    if ([bannerModel isKindOfClass:[ZFBannerModel class]]) {
        [BannerManager doBannerActionTarget:self withBannerModel:bannerModel];
    }
}

#pragma mark - 刷新头部信息

///刷新购物车数量
- (void)refreshCartNumberInfo {
    [self.navigationView refreshCartNumberInfo];
}

///切换汇率刷新页面
- (void)refreshAccountCollectionView {
    [self.tableDataView reloadAccountTableView];
}

/** 处理换肤*/
- (void)changeAppAccountSkin {
    // 导航栏背景色
    [self.navigationView changeAccountNavigationNavSkin];
    
    // 个人中心头部换肤
    [self.tableDataView refreshHeadViewSkin];
}

#pragma mark - cell delegate

- (void)ZFAccountHeaderCReusableViewDidClickLogin {
    [self presentLoginViewController];
}

- (void)ZFAccountHeaderCReusableViewDidClickChangeHeadPhoto {
    @weakify(self)
    [ZFSystemPhototHelper showActionSheetChoosePhoto:self callBlcok:^(UIImage *uploadImage) {
        @strongify(self)
        [self.tableDataView refreshHeadUserImage:uploadImage];
    }];
}

- (void)refreshNavgationBackgroundColorAlpha:(CGFloat)colorAlpha {
    [self.navigationView refreshBackgroundColorAlpha:colorAlpha];
}

- (CGFloat)fetchNavgationMaxY {
    return STATUSHEIGHT + NAVBARHEIGHT;
}

- (CGFloat)fetchTabberHeight {
    return TabBarHeight;
}

#pragma mark - 页面跳转
///弹出登录页面
- (BOOL)judgeActionNeedUserToBeSignIn {
    if (![AccountManager sharedManager].isSignIn) {
        [self presentLoginViewController];
    }
    return ![AccountManager sharedManager].isSignIn;
}

///弹出登录页面
- (void)presentLoginViewController {    
//    [self judgePresentLoginVCCompletion:^{
//    }];
    [self judgePresentLoginVCChooseType:YWLoginEnterTypeLogin comeFromType:YWLoginViewControllerEnterTypeAccountPage Completion:^{
        
    }];
}

- (void)jumpActionFromCategoryItemCell:(ZFAccountTableAllCellActionType)actionType {
    if (actionType == ZFAccountCategoryCell_OrderType) {
        [self accountDidSelectOrderList];
        
    } else if (actionType == ZFAccountCategoryCell_WishListType) {
        [self accountDidSelectWishList];
        
    } else if (actionType == ZFAccountCategoryCell_CouponType) {
        [self accountDidSelectCouponList];
        
    } else if (actionType == ZFAccountCategoryCell_ZPointType) {
        [self accountDidSelectPoints];
    }
}

- (void)dealWithUnpaidAction:(ZFAccountTableAllCellActionType)actionType
                  orderModel:(MyOrdersModel *)orderModel
{
    if (![orderModel isKindOfClass:[MyOrdersModel class]])return;
    
    if (actionType == ZFAccountUnpaidCell_DetailAction) {
        [ZFCommonRequestManager gotoOrderDetail:orderModel orderReloadBlock:^{
            [self requestUnpaidOrderInfo];//刷新订单
        }];
    } else if (actionType == ZFAccountUnpaidCell_GoPayAction) {
        [ZFCommonRequestManager dealWithGotoPayWithOrderModel:orderModel];
    }
}

//选择订单列表
- (void)accountDidSelectOrderList {
    if (![self judgeActionNeedUserToBeSignIn]) {
        ZFMyOrderListViewController *orderList = [[ZFMyOrderListViewController alloc] init];
        [self.navigationController pushViewController:orderList animated:YES];
    }
}

//选择心愿列表
- (void)accountDidSelectWishList {
    ZFCollectionViewController *wishList = [[ZFCollectionViewController alloc] init];
    [self.navigationController pushViewController:wishList animated:YES];
}

//选择优惠券列表
- (void)accountDidSelectCouponList {
    if (![self judgeActionNeedUserToBeSignIn]) {
        CouponViewController *couponList = [[CouponViewController alloc] init];
        [self.navigationController pushViewController:couponList animated:YES];
    }
}

//选择积分列表
- (void)accountDidSelectPoints {
    if (![self judgeActionNeedUserToBeSignIn]) {
        MyPointsViewController *myPoint = [[MyPointsViewController alloc] init];
        [self.navigationController pushViewController:myPoint animated:YES];
    }
}

///跳转购物车界面
- (void)jumpToCartViewController {
    [ZFStatistics eventType:ZF_Account_Cars_type];
    ZFCartViewController *cartVC = [[ZFCartViewController alloc] init];
    [self.navigationController pushViewController:cartVC animated:YES];
}

///跳转个人中心设置页面
- (void)jumpToSettingInfoViewController {
    ZFSettingViewController *settingVC = [[ZFSettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

///跳转帮助中心页面
- (void)jumpToHelpViewController {
    ZFHelpViewController *helpVC = [[ZFHelpViewController alloc] init];
    [self.navigationController pushViewController:helpVC animated:YES];
}

///跳转商详页面
- (void)judgePushGoodsDetail:(ZFGoodsModel *)goodsModel soureType:(ZFAppsflyerInSourceType)soureType {
    ZFGoodsDetailViewController *goodsDetail = [[ZFGoodsDetailViewController alloc] init];
    goodsDetail.goodsId = goodsModel.goods_id;
    goodsDetail.sourceType = soureType;
    [self.navigationController pushViewController:goodsDetail animated:YES];
}

///跳转社区个人中心
- (void)ZFAccountHeaderCReusableViewDidClickZ_ME {
    BOOL showReviewBtn = [AccountManager sharedManager].account.user_review_sku;
    if (showReviewBtn) {
        ZFCommentListViewController *commentVC = [[ZFCommentListViewController alloc] init];
        [self.navigationController pushViewController:commentVC animated:YES];
        
    } else {
        ZFCommunityAccountViewController *zmeVC = [[ZFCommunityAccountViewController alloc] init];
        zmeVC.userId = [AccountManager sharedManager].userId;
        [self.navigationController pushViewController:zmeVC animated:YES];
    }
}

///编辑个人资料
- (void)ZFAccountHeaderCReusableViewDidClickEditProfile {
    ZFUserInfoViewController *userVC = [[ZFUserInfoViewController alloc] init];
    [self.navigationController pushViewController:userVC animated:YES];
}

- (void)selectedGoods:(ZFGoodsModel *)goodsModel dataType:(ZFAccountRecommendSelectType)dataType {
    ZFAppsflyerInSourceType type = 0;
    if (dataType == ZFAccountSelect_RecommendType) {
        type = ZFAppsflyerInSourceTypeSerachRecommendPersonal;
    } else {
        type = ZFAppsflyerInSourceTypeAccountRecentviewedProduct;
    }
    [self judgePushGoodsDetail:goodsModel soureType:type];
}

/**
 * 监听: 重复单击当前控制器的TabbarItem
 * 点击Tabbar滚动到页面顶部
 */
- (void)repeatTapTabBarCurrentController {
    [self.tableDataView setTableViewScrollToTop];
}

- (void)handleNavigationAction:(ZFAccountNavigationActionType)actionType {
    if (actionType == ZFAccountNavigationAction_UserImageType) {
        [self ZFAccountHeaderCReusableViewDidClickChangeHeadPhoto];
        
    } else if (actionType == ZFAccountNavigationAction_UserNameType) {
        [self ZFAccountHeaderCReusableViewDidClickEditProfile];
        
    } else if (actionType == ZFAccountNavigationAction_CartType) {
        [self jumpToCartViewController];
        
    } else if (actionType == ZFAccountNavigationAction_HelpType) {
        [self jumpToHelpViewController];
        
    } else if (actionType == ZFAccountNavigationAction_SettingType) {
        [self jumpToSettingInfoViewController];
    }
}

#pragma mark - LayoutSubViews

- (void)zfInitView {
    [self.view addSubview:self.tableDataView];
    [self.view addSubview:self.navigationView];
}

- (void)zfLayoutSubViews {
    [self.tableDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.view);
        make.height.mas_offset(NAVBARHEIGHT + STATUSHEIGHT);
    }];
}

#pragma mark - Property Method

- (ZFAccountNavigationView *)navigationView {
    if (!_navigationView) {
        _navigationView = [[ZFAccountNavigationView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _navigationView.actionTypeBlock = ^(ZFAccountNavigationActionType actionType) {
            @strongify(self)
            [self handleNavigationAction:actionType];
        };
    }
    return _navigationView;
}

- (ZFAccountTableDataView *)tableDataView {
    if (!_tableDataView) {
        _tableDataView = [[ZFAccountTableDataView alloc] initWithVCProtocol:self];
    }
    return _tableDataView;
}

-(ZFAccountViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFAccountViewModel alloc] init];
    }
    return _viewModel;
}

- (ZFAccountVCAnalyticsAop *)accountAop {
    if (!_accountAop) {
        _accountAop = [[ZFAccountVCAnalyticsAop alloc] init];
    }
    return _accountAop;
}

@end
