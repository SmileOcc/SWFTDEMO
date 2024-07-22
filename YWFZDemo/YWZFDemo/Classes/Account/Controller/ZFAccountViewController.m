//
//  ZFAccountViewController470.m
//  ZZZZZ
//
//  Created by YW on 2019/6/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountViewController.h"

#import "Constants.h"
#import "ZFStatistics.h"
#import "ZFProgressHUD.h"
#import "ZFFrameDefiner.h"
#import "ZFColorDefiner.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFGrowingIOAnalytics.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFSystemPhototHelper.h"
#import "ZFRefreshFooter.h"
#import "ZFRefreshHeader.h"
#import "YSAlertView.h"
#import "ZFAccount470AnalyticsAop.h"

#import "ZFAccountNavigationView.h"
#import "ZFAccountHeaderCReusableView.h"
#import "ZFAccountCategoryCCell.h"
#import "ZFAccountRecentlyCCell.h"
#import "ZFAccountDetailTextCCell.h"
#import "ZFProductCCell.h"

#import "ZFAccountCategorySectionModel.h"
#import "ZFPorductSectionModule.h"

#import "ZFBannerModel.h"

#import "ZFCustomizeCollectionLayout.h"

#import "ZFAccountViewModel.h"
#import "ZFCMSViewModel.h"
#import "AccountManager.h"
#import "BannerManager.h"

#import "ZFHelpViewController.h"
#import "ZFCartViewController.h"
#import "ZFAddressViewController.h"
#import "ZFAccountHistoryViewController.h"
#import "ZFContactUsViewController.h"
#import "ZFSurveyViewController.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFMyOrderListViewController.h"
#import "ZFCollectionViewController.h"
#import "CouponViewController.h"
#import "MyPointsViewController.h"
#import "EditProfileViewController.h"
#import "ZFCommunityAccountViewController.h"

#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIScrollView+ZFBlankPageView.h"
#import <YYWebImage/YYWebImage.h>
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>

#import "ZZZZZ-Swift.h"

static NSString *kAccountHeaderIdentifier = @"kAccountHeaderIdentifier";

@interface ZFAccountViewController ()
<
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    ZFCustomerLayoutDatasource,
    ZFAccountRecentlyCellDelegate,
    ZFAccountHeaderCReusableViewDelegate
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ZFAccountNavigationView *navigationView;
@property (nonatomic, strong) NSMutableArray <id<ZFCollectionSectionProtocol>> *dataSource;
@property (nonatomic, strong) ZFCustomizeCollectionLayout *accountCollectionLayout;
@property (nonatomic, strong) ZFAccountViewModel *viewModel;
@property (nonatomic, strong) ZFCMSViewModel *cmsViewModel;  ///获取历史浏览记录

@property (nonatomic, strong) NSMutableArray *bannerDataSource;  ///广告数据源
@property (nonatomic, strong) NSMutableArray *productDataSource; ///推荐商品数据源
@property (nonatomic, strong) ZFAccountCategorySectionModel *historySectionModel; ///历史浏览记录数据源
@property (nonatomic, strong) ZFAccount470AnalyticsAop *accountAop;
@end

@implementation ZFAccountViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    YWLog(@"ZFAccountViewController dealloc");
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
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.navigationView];
    [self zflayoutSubViews];
    [self requestAccountAllData];
    [self addNotifycation];
}

- (void)addNotifycation {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCartNumberInfo) name:kCartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestAccountAllData) name:kLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAppAccountSkin) name:kChangeSkinNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAccountCollectionView) name:kCurrencyNotification object:nil];
}

- (void)zflayoutSubViews {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.view);
        make.height.mas_offset(NAVBARHEIGHT + STATUSHEIGHT);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //刷新用户信息
    [self reloadUserLoginStatus];
    // 自定义导航和头部换肤
    [self changeAppAccountSkin];
    //刷新订单，优惠券信息
    [self reloadOrderCounponBadgeNum];
    //刷新历史浏览记录
    [self handlerHistory];
    //刷新购物车数量
    [self.navigationView refreshCartNumberInfo];
    //游客弹窗
    if ([AccountManager sharedManager].isSignIn
        && [AccountManager sharedManager].account.is_guest == 2) {
        [self alertGameGuestTipsMessage];
    }
}

#pragma mark - collectionView datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.dataSource count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource[section].sectionDataSource count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:CustomerLayoutHeader]) {
        ZFAccountHeaderCReusableView *headerResusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kAccountHeaderIdentifier forIndexPath:indexPath];
        headerResusableView.showType = ![AccountManager sharedManager].isSignIn;
        headerResusableView.delegate = self;
        return headerResusableView;
    }
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<ZFCollectionSectionProtocol>sectionProtocol = self.dataSource[indexPath.section];
    id<ZFCollectionCellDatasourceProtocol>dataSourceProtocol = sectionProtocol.sectionDataSource[indexPath.row];
    
    NSString *key = [dataSourceProtocol CollectionDatasourceCell:indexPath identifier:self];
    if (![sectionProtocol.registerKeys containsObject:key]) { //按需注册
        [collectionView registerClass:[dataSourceProtocol registerClass] forCellWithReuseIdentifier:key];
        [sectionProtocol.registerKeys addObject:key]; 
    }
    id<ZFCollectionCellProtocol>cell = [collectionView dequeueReusableCellWithReuseIdentifier:key forIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(ZFCollectionCellProtocol)]) {
        cell.model = dataSourceProtocol;
        cell.delegate = self;
    }
    YWLog(@"个人中心Cell类型===%@", NSStringFromClass([cell class]));
    return (UICollectionViewCell *)cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id<ZFCollectionSectionProtocol>sectionProtocol = self.dataSource[indexPath.section];
    id<ZFCollectionCellDatasourceProtocol>dataSourceProtocol = sectionProtocol.sectionDataSource[indexPath.row];
    if ([dataSourceProtocol isKindOfClass:[ZFAccountDetailTextModel class]]) {
        //点击了个人中心选项
        ZFAccountDetailTextModel *detailModel = dataSourceProtocol;
        [self performSelectorOnMainThread:detailModel.selector withObject:nil waitUntilDone:YES];
    }
    if ([dataSourceProtocol isKindOfClass:[ZFBannerModel class]]) {
        //点击了广告
        [self dealwithBannerAction:(ZFBannerModel *)dataSourceProtocol indexPatch:indexPath];
    }
    if ([dataSourceProtocol isKindOfClass:[ZFGoodsModel class]]) {
        //点击了推荐商品
        [self judgePushGoodsDetail:(ZFGoodsModel *)dataSourceProtocol soureType:ZFAppsflyerInSourceTypeSerachRecommendPersonal];
    }
    if ([dataSourceProtocol isKindOfClass:[ZFAccountCategoryModel class]]) {
        //点击了订单列表，优惠券，积分，心愿单
        ZFAccountCategoryModel *categoryModel = dataSourceProtocol;
        [self performSelectorOnMainThread:categoryModel.selector withObject:nil waitUntilDone:YES];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = 95;
    //通过滑动控制导航栏alpha渐变，以及文本显示隐藏。
    CGPoint offset = scrollView.contentOffset;
    if (offset.y < -height) {
        offset.y = -height;
        [scrollView setContentOffset:offset];
        return;
    }
    // 滚动时需要加上顶部有88的偏移量
    CGFloat alpha = (offset.y + self.collectionView.contentInset.top) / height;
    [self.navigationView refreshBackgroundColorAlpha:alpha];
    self.collectionView.showsVerticalScrollIndicator = (alpha > 1.4);
}

#pragma mark - layout dataSource

- (NSInteger)customerLayoutNumsSection:(UICollectionView *)collectionView {
    return [self.dataSource count];
}

-(id<ZFCollectionSectionProtocol>)customerLayoutDatasource:(UICollectionView *)collectionView sectionNum:(NSInteger)section {
    return self.dataSource[section];
}

- (CGFloat)customerLayoutSectionHeightHeight:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout indexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 116 + NAVBARHEIGHT + STATUSHEIGHT;
    }
    return 0;
}

- (CustomerBackgroundAttributes *)customerLayoutSectionAttributes:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout indexPath:(NSIndexPath *)indexPath {
    id<ZFCollectionSectionProtocol>protocol = self.dataSource[indexPath.section];
    if ([protocol isKindOfClass:[ZFPorductSectionModule class]]) {
        ZFPorductSectionModule *module = protocol;
        return [module gainCustomeSetionBackgroundAttributes:indexPath];
    }
    return nil;
}

#pragma mark - notification method

- (void)refreshCartNumberInfo {
    [self.navigationView refreshCartNumberInfo];
}

- (void)refreshAccountCollectionView {
    [self.collectionView reloadData];
}

#pragma mark - private method

- (void)handlerCMSBanner:(NSArray<ZFNewBannerModel *> *)cmsBannerArray {
    __block NSInteger bannerIndex = 1;   //CMS广告位置默认是在个人中心分类下面
    if ([self.dataSource count] < bannerIndex) {
        bannerIndex = 0;
    }
    if ([self.bannerDataSource count]) {
        [self.bannerDataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                bannerIndex = [self.dataSource indexOfObject:obj];
            }
            [self.dataSource removeObject:obj];
        }];
        [self.bannerDataSource removeAllObjects];
    }
    
    NSInteger count = cmsBannerArray.count;
    for (int i = 0; i < count; i++) {
        ZFNewBannerModel *newBannerModel = cmsBannerArray[i];
        ZFAccountCategorySectionModel *bannerSectionModel = [[ZFAccountCategorySectionModel alloc] init];
        bannerSectionModel.isEnableRightToLeft = NO;
        if (i == 0) {
            bannerSectionModel.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0);
        }
        [bannerSectionModel.sectionDataSource addObjectsFromArray:newBannerModel.banners];
        [self.bannerDataSource addObject:bannerSectionModel];
    }
    
    [self.bannerDataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.dataSource insertObject:obj atIndex:bannerIndex + idx];
    }];
    
    [self.collectionView reloadData];
}

- (void)handlerCMSProduct:(NSArray *)productList {
    BOOL haveProduct = NO;
    id<ZFCollectionSectionProtocol>protocol = [self.dataSource lastObject];
    if ([protocol isKindOfClass:[ZFPorductSectionModule class]]) {
        haveProduct = YES;
    }
    if (haveProduct) {
        [protocol.sectionDataSource addObjectsFromArray:productList];
    } else {
        //推荐商品头部
        ZFAccountCategorySectionModel *titleSectionModel = [[ZFAccountCategorySectionModel alloc] init];
        titleSectionModel.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0);
        ZFProductTitleCCellModel *model = [ZFProductTitleCCellModel new];
        model.title = ZFLocalizedString(@"Account_RecomTitle", nil);
        model.registerClass = [ZFProductTitleCCell class];
        [titleSectionModel.sectionDataSource addObject:model];
        [self.dataSource addObject:titleSectionModel];
        
        //推荐商品
        ZFPorductSectionModule *productSectionModel = [[ZFPorductSectionModule alloc] init];
        productSectionModel.minimumInteritemSpacing = 12;
        productSectionModel.minimumLineSpacing = 12;
        productSectionModel.lineRows = 3;
        productSectionModel.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
        [productSectionModel.sectionDataSource addObjectsFromArray:productList];
        [self.dataSource addObject:productSectionModel];
    }
    NSInteger index = 0;
    if (self.dataSource.count > 2) {
        index = self.dataSource.count - 2;
    }
//    [self.collectionView reloadData];
    [self.accountCollectionLayout reloadSection:index];
}

- (void)handlerHistory {
    if ([self.dataSource containsObject:self.historySectionModel]) {
        //获取历史浏览记录
        @weakify(self)
        [self.cmsViewModel fetchRecentlyGoods:^(NSArray<ZFCMSItemModel *> * _Nonnull historyList) {
            @strongify(self)
            id<ZFCollectionCellDatasourceProtocol>protocol = self.historySectionModel.sectionDataSource.firstObject;
            if ([historyList count]) {
                self.historySectionModel.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0);
            } else {
                self.historySectionModel.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
            }
            if ([protocol isKindOfClass:[ZFAccountRecentlyViewModel class]]) {
                ZFAccountRecentlyViewModel *recentlyModel = (ZFAccountRecentlyViewModel *)protocol;
                recentlyModel.dataList = [historyList mutableCopy];
            }
        }];
        [self.collectionView reloadData];
    } else {
        //获取历史浏览记录
        @weakify(self)
        [self.cmsViewModel fetchRecentlyGoods:^(NSArray<ZFCMSItemModel *> * _Nonnull historyList) {
            @strongify(self)
            id<ZFCollectionCellDatasourceProtocol>protocol = self.historySectionModel.sectionDataSource.firstObject;
            if ([historyList count]) {
                self.historySectionModel.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0);
            } else {
                self.historySectionModel.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
            }
            if ([protocol isKindOfClass:[ZFAccountRecentlyViewModel class]]) {
                ZFAccountRecentlyViewModel *recentlyModel = (ZFAccountRecentlyViewModel *)protocol;
                recentlyModel.dataList = [historyList mutableCopy];
            }
            if ([historyList count]) {
                NSInteger index = 1;
                NSInteger count = [self.bannerDataSource count];
                if (count) {
                    index += count;
                }
                [self.dataSource insertObject:self.historySectionModel atIndex:index];
                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:index]];
            }
        }];
    }
}

- (void)handleDataSource {
    //分类分区
    ZFAccountCategorySectionModel *catSectionModel = [[ZFAccountCategorySectionModel alloc] init];
    NSArray *sectionModelList = [self categorySectionModel];
    [catSectionModel.sectionDataSource addObjectsFromArray:sectionModelList];
    [_dataSource addObject:catSectionModel];

    //历史浏览记录分区
    [_dataSource addObject:self.historySectionModel];
}

- (NSArray<id<ZFCollectionCellDatasourceProtocol>> *)categorySectionModel
{
    NSArray *titles = @[ZFLocalizedString(@"Account_Cell_Orders", nil),
                        ZFLocalizedString(@"Account_Cell_Wishlist", nil),
                        ZFLocalizedString(@"Account_Cell_Coupon", nil),
                        ZFLocalizedString(@"Account_Cell_Points", nil)];
    NSArray *iconImageNames = @[@"account_home_order",
                                @"account_home_wishlist_new",
                                @"account_home_coupon_new",
                                @"account_home_z-points"];
    NSArray *menuList = @[@"orders",
                          @"wishlist",
                          @"coupons",
                          @"z_points"];
    NSArray *selectorList = @[
        NSStringFromSelector(@selector(accountDidSelectOrderList)),
        NSStringFromSelector(@selector(accountDidSelectWishList)),
        NSStringFromSelector(@selector(accountDidSelectCouponList)),
        NSStringFromSelector(@selector(accountDidSelectPoints))
    ];
    NSMutableArray *modelList = [[NSMutableArray alloc] init];
    for (int i = 0; i < titles.count; i++) {
        ZFAccountCategoryModel *model = [[ZFAccountCategoryModel alloc] init];
        model.title = titles[i];
        model.imageName = iconImageNames[i];
        if (i == 0) {//未使用订单数量
            model.badgeNum = [AccountManager sharedManager].account.not_paying_order;
        }
        if (i == 2) {//未使用优惠券数量
            model.badgeNum = [AccountManager sharedManager].account.has_new_coupon;
        }
        model.selector = NSSelectorFromString(selectorList[i]);
        model.analyticsMenuName = menuList[i];
        model.registerClass = [ZFAccountCategoryCCell class];
        [modelList addObject:model];
    }
    return modelList.copy;
}

/**
 * 处理Banner跳转
 */
- (void)dealwithBannerAction:(ZFBannerModel *)model indexPatch:(NSIndexPath *)indexPath {
    [BannerManager doBannerActionTarget:self withBannerModel:model]; 
}

- (void)judgePushGoodsDetail:(ZFGoodsModel *)goodsModel soureType:(ZFAppsflyerInSourceType)soureType {
    ZFGoodsDetailViewController *goodsDetail = [[ZFGoodsDetailViewController alloc] init];
    goodsDetail.goodsId = goodsModel.goods_id;
    goodsDetail.sourceType = soureType;
    [self.navigationController pushViewController:goodsDetail animated:YES];
}

- (void)reloadOrderCounponBadgeNum {
    if (self.dataSource.firstObject && [self.collectionView numberOfSections]) {
        id<ZFCollectionSectionProtocol>sectionProtocol = self.dataSource.firstObject;
        if ([sectionProtocol.sectionDataSource.firstObject isKindOfClass:[ZFAccountCategoryModel class]]) {
            //刷新订单数量
            ZFAccountCategoryModel *orderModel = sectionProtocol.sectionDataSource.firstObject;
            orderModel.badgeNum = [AccountManager sharedManager].account.not_paying_order;
            id<ZFCollectionCellProtocol>orderCell = (ZFAccountCategoryCCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            orderCell.model = orderModel;
            
            if ([sectionProtocol.sectionDataSource count] > 2) {
                //刷新优惠券数量
                ZFAccountCategoryModel *couponModel = sectionProtocol.sectionDataSource[2];
                couponModel.badgeNum = [AccountManager sharedManager].account.has_new_coupon;
                id<ZFCollectionCellProtocol>couponCell = (id<ZFCollectionCellProtocol>)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                couponCell.model = couponModel;
            }
        }
    }
}

- (BOOL)judgeActionNeedUserToBeSignIn {
    if (![AccountManager sharedManager].isSignIn) {
        //弹出登录页面
        [self presentLoginViewController];
    }
    return ![AccountManager sharedManager].isSignIn;
}

- (void)presentLoginViewController {
    //弹出登录页面
    [self judgePresentLoginVCChooseType:YWLoginEnterTypeLogin comeFromType:YWLoginViewControllerEnterTypeAccountPage Completion:^{
        
    }];
}

///刷新用户登录状态
- (void)reloadUserLoginStatus {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.collectionView numberOfSections]) {
            ZFAccountHeaderCReusableView *headerResusableView = (ZFAccountHeaderCReusableView *)[self.collectionView supplementaryViewForElementKind:CustomerLayoutHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            headerResusableView.showType = ZFNewAccountInfoStatusNeedReload;
        }
    });
}

/** 处理换肤*/
- (void)changeAppAccountSkin {
    // 导航栏背景色
    [self.navigationView changeAccountNavigationNavSkin];
    ///UICollection的渲染机制导致，viewWillAppear会先于collection dadasource先调用，要加一个获取主线程过程，视图才不会错乱
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.collectionView numberOfSections]) {
            ZFAccountHeaderCReusableView *headerResusableView = (ZFAccountHeaderCReusableView *)[self.collectionView supplementaryViewForElementKind:CustomerLayoutHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [headerResusableView changeAccountHeadInfoViewSkin];
        }
    });
}

//弹出游客转正后的提示弹窗
- (void)alertGameGuestTipsMessage {
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

#pragma mark - target method

//跳转购物车界面
- (void)jumpToCartViewController {
    [ZFStatistics eventType:ZF_Account_Cars_type];
    ZFCartViewController *cartVC = [[ZFCartViewController alloc] init];
    [self.navigationController pushViewController:cartVC animated:YES];
}

//跳转个人中心设置页面
- (void)jumpToSettingInfoViewController {
    ZFSettingViewController *settingVC = [[ZFSettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

#pragma mark - cell delegate

//选择历史浏览记录商品
- (void)ZFAccountRecentlyCellDidClickProductItem:(ZFCMSItemModel *)itemModel {
    [self judgePushGoodsDetail:itemModel.goodsModel
                     soureType:ZFAppsflyerInSourceTypeAccountRecentviewedProduct];
}

//清除历史浏览记录
- (void)ZFAccountRecentlyCellDidClickClearButton {
    id<ZFCollectionCellDatasourceProtocol>protocol = self.historySectionModel.sectionDataSource.firstObject;
    self.historySectionModel.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([protocol isKindOfClass:[ZFAccountRecentlyViewModel class]]) {
        ZFAccountRecentlyViewModel *recentlyModel = (ZFAccountRecentlyViewModel *)protocol;
        [recentlyModel.dataList removeAllObjects];
    }
    [ZFGoodsModel deleteAllGoods];
    [self.cmsViewModel clearCMSHistoryAction];
    NSInteger section = [self.dataSource indexOfObject:self.historySectionModel];
    [self.dataSource removeObjectAtIndex:section];
    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:section]];
}

#pragma mark - Collection HeaderView delegate

- (void)ZFAccountHeaderCReusableViewDidClickLogin {
    [self presentLoginViewController];
}

- (void)ZFAccountHeaderCReusableViewDidClickZ_ME {
    ZFCommunityAccountViewController *zmeVC = [[ZFCommunityAccountViewController alloc] init];
    zmeVC.userId = [AccountManager sharedManager].userId;
    [self.navigationController pushViewController:zmeVC animated:YES];
}

- (void)ZFAccountHeaderCReusableViewDidClickEditProfile {
    EditProfileViewController *editVC = [[EditProfileViewController alloc] init];
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)ZFAccountHeaderCReusableViewDidClickChangeHeadPhoto {
    @weakify(self)
    [ZFSystemPhototHelper showActionSheetChoosePhoto:self callBlcok:^(UIImage *uploadImage) {
        @strongify(self)
        if ([self.collectionView numberOfSections]) {
            ZFAccountHeaderCReusableView *headerResusableView = (ZFAccountHeaderCReusableView *)[self.collectionView supplementaryViewForElementKind:CustomerLayoutHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            headerResusableView.avatorView.image = uploadImage;
        }
    }];
}

#pragma mark - selector method

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

//选择help
- (void)accountDidSelectHelp
{
    ZFHelpViewController *helpVC = [[ZFHelpViewController alloc] init];
    [self.navigationController pushViewController:helpVC animated:YES];
}

#pragma mark - network request

//登陆操作
- (void)requestAccountAllData {
    if ([AccountManager sharedManager].isSignIn) {
        // 获取个人中心显示信息
        [self requestAccountInformation];
    }
    //获取个人中心banner接口
    [self requestUserCoreBanner];
    //从bts开关 获取个人中心推荐商品接口
    [self requestAccountRecommendProduct];
}

/*
 * 获取个人中心显示信息， 包含未付款订单数，积分，优惠券显示等。
 */
- (void)requestAccountInformation {
    @weakify(self)
    [self.viewModel requestUserInfoData:^(AccountModel *model) {
        @strongify(self)
        [self reloadUserLoginStatus];
        // 刷新优惠券，订单列表未付款 数量
        [self reloadOrderCounponBadgeNum];
        [self.collectionView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        @strongify(self)
        [self.collectionView.mj_header endRefreshing];
    }];
}

/**
 * 获取个人中心显示的Banner CMS广告
 */
- (void)requestUserCoreBanner {
    @weakify(self)
    [self.viewModel requestUserCoreCMSBanner:^(NSArray<ZFNewBannerModel *> *cmsBannerArray) {
        @strongify(self)
        if (ZFJudgeNSArray(cmsBannerArray)) {
            [self handlerCMSBanner:cmsBannerArray];
            //统计banner显示
            [self.viewModel analyticsGABanner:cmsBannerArray];
        }
    }];
}

/**
 * 获取个人中心推荐商品
 */
- (void)requestAccountRecommendProduct {
    //获取数据
    @weakify(self)
    [self.viewModel requestAccountRecommendProduct:^(id object, NSError *error) {
        if (error) { //数据出错，或者网络出错
            NSDictionary *pageInfo = @{kTotalPageKey  : @(1),
                                       kCurrentPageKey: @(1) };
            [self.collectionView showRequestTip:pageInfo];
            return ;
        }
        @strongify(self)
        NSDictionary *resultParams = object;
        NSArray *productList = resultParams[@"goods_list"];
        NSInteger curPage = [object[@"pageInfo"][kCurrentPageKey] integerValue];
        id<ZFCollectionSectionProtocol>protocol = [self.dataSource lastObject];
        if (curPage == 1 && [protocol isKindOfClass:[ZFPorductSectionModule class]]) {
            [protocol.sectionDataSource removeAllObjects];
        }
        if (ZFJudgeNSArray(productList) && productList.count) {
            if (!self.collectionView.mj_footer) {
                @weakify(self)
                ZFRefreshFooter *footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
                    @strongify(self)
                    [self requestAccountRecommendProduct];
                }];
                self.collectionView.mj_footer = footer;
            }
            [self handlerCMSProduct:productList];
            [self.collectionView showRequestTip:object[@"pageInfo"]];
        } else {
            if (curPage == 1) {
                if ([protocol isKindOfClass:[ZFPorductSectionModule class]]) {
                    [self.dataSource removeLastObject];
                    [self.dataSource removeLastObject];
                }
            }
            [self.collectionView reloadData];
            [self.collectionView showRequestTip:object[@"pageInfo"]];
        }
    }];
}

#pragma mark - Property Method

-(UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = ({
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.accountCollectionLayout];
            collectionView.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
            collectionView.delegate = self;
            collectionView.dataSource = self;
            collectionView.alwaysBounceVertical = YES;
            collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(20, 0, 0, 0);
            
            [collectionView registerClass:[ZFAccountHeaderCReusableView class] forSupplementaryViewOfKind:CustomerLayoutHeader withReuseIdentifier:kAccountHeaderIdentifier];
            
            @weakify(self)
            ZFRefreshHeader *refreshHeader = [ZFRefreshHeader headerWithRefreshingBlock:^{
                @strongify(self);
                [self.viewModel requestFirstPageRecommendProduct];
                [self requestAccountAllData];
            }];
            refreshHeader.ignoredScrollViewContentInsetTop = -kiphoneXTopOffsetY;
            collectionView.mj_header = refreshHeader;
            
            if (@available(iOS 11.0, *)) {
                collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
            
            collectionView;
        });
    }
    return _collectionView;
}

- (ZFCustomizeCollectionLayout *)accountCollectionLayout {
    if (!_accountCollectionLayout) {
        _accountCollectionLayout = [[ZFCustomizeCollectionLayout alloc] init];
        _accountCollectionLayout.dataSource = self;
    }
    return _accountCollectionLayout;
}

- (ZFAccountNavigationView *)navigationView {
    if (!_navigationView) {
        _navigationView = [[ZFAccountNavigationView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        [_navigationView setJumpToCartVCBlock:^{
            @strongify(self)
            [self jumpToCartViewController];
        }];
        
        [_navigationView setJumpToSettingVCBlock:^{
            @strongify(self)
            [self jumpToSettingInfoViewController];
        }];
        
        [_navigationView setJumpToHelpVCBlock:^{
            @strongify(self)
            [self accountDidSelectHelp];
        }];
    }
    return _navigationView;
}

-(NSMutableArray<id<ZFCollectionSectionProtocol>> *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
        [self handleDataSource];
    }
    return _dataSource;
}

- (NSMutableArray *)bannerDataSource {
    if (!_bannerDataSource) {
        _bannerDataSource = [[NSMutableArray alloc] init];
    }
    return _bannerDataSource;
}

- (ZFAccountCategorySectionModel *)historySectionModel {
    if (!_historySectionModel) {
        _historySectionModel = [[ZFAccountCategorySectionModel alloc] init];
        ZFAccountRecentlyViewModel *recentlyViewModel = [[ZFAccountRecentlyViewModel alloc] init];
        recentlyViewModel.registerClass = [ZFAccountRecentlyCCell class];
        [_historySectionModel.sectionDataSource addObject:recentlyViewModel];
    }
    return _historySectionModel;
}

-(ZFAccountViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFAccountViewModel alloc] init];
    }
    return _viewModel;
}

-(ZFCMSViewModel *)cmsViewModel {
    if (!_cmsViewModel) {
        _cmsViewModel = [[ZFCMSViewModel alloc] init];
        _cmsViewModel.controller = self;
    }
    return _cmsViewModel;
}

- (ZFAccount470AnalyticsAop *)accountAop {
    if (!_accountAop) {
        _accountAop = [[ZFAccount470AnalyticsAop alloc] init];
    }
    return _accountAop;
}

@end
