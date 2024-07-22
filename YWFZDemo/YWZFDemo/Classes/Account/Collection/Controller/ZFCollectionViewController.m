//
//  ZFCollectionViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/8/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCollectionViewController.h"
#import "ZFInitViewProtocol.h"
//#import "ZFGoodsListItemCell.h"
#import "ZFGoodsModel.h"
//#import "ZFCollectionListModel.h"
//#import "ZFCollectionViewModel.h"
#import "ZFWebViewViewController.h"
#import "ZFCartViewController.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFUnlineSimilarViewController.h"
#import "ZFThemeManager.h"
#import "UIButton+ZFButtonCategorySet.h"
//#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "ZFStatistics.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFPopDownAnimation.h"
#import "ZFBTSManager.h"
#import "ZFProgressHUD.h"
#import <YYModel/YYModel.h>

#import "ZFCollectionTitleView.h"
#import "ZFCollectionGoodsView.h"
#import "ZFCollectionPostsContainerView.h"
#import "ZFWishListVerticalStyleView.h"

@interface ZFCollectionViewController () <ZFInitViewProtocol, ZFWishListVerticalStyleViewDelegate, ZFCollectionGoodsViewDelegate>

@property (nonatomic, strong) ZFCollectionViewModel                 *viewModel;
//@property (nonatomic, strong) ZFCollectionListModel                *listModel;
@property (nonatomic, strong) UIButton                              *shoppingCarBtn;
@property (nonatomic, strong) ZFCollectionTitleView                 *titleView;
@property (nonatomic, strong) ZFCollectionGoodsView                 *goodsView;
@property (nonatomic, strong) ZFCollectionPostsContainerView        *postsView;
@property (nonatomic, strong) ZFWishListVerticalStyleView           *wishVerticalStyleView;
//@property (nonatomic, copy) NSString                               *btsPolicyValue;
@end

@implementation ZFCollectionViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNavigationBar];
    [self zfInitView];
    [self zfAutoLayoutView];
    [self requestWishGoodsList];
    [self addObserver];
    [self addAnalysics];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //购物车数量
    [self refreshCarBage];
}

- (void)refreshCarBage {
    NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
    [self.shoppingCarBtn showShoppingCarsBageValue:[badgeNum integerValue]];
}

- (void)addAnalysics {
    NSMutableArray *screenNames = [NSMutableArray array];
    NSMutableDictionary *banner = [NSMutableDictionary dictionary];
    banner[@"name"] = @"impression_account_wishlist";
    banner[@"position"] = @"1";
    [screenNames addObject:banner];
    [ZFAnalytics showAdvertisementWithBanners:screenNames position:@"1" screenName:@"collection_result"];
    
    // 谷歌统计
    NSString *GABannerId   = @"collection";
    NSString *GABannerName = @"impression_account_wishlist";
    NSString *position     = @"1";
    [ZFAnalytics clickAdvertisementWithId:GABannerId name:GABannerName position:position];
}

#pragma mark - network

- (void)requestWishGoodsList
{
    @weakify(self)
    ShowLoadingToView(self.view);
    [self.viewModel requestCollectGoodsPageData:YES completion:^(ZFCollectionListModel *listModel, NSArray *currentPageArray, NSDictionary *pageInfo) {
        @strongify(self)
        HideLoadingFromView(self.view);
        if ([listModel.data count]) {
            [self showWishListVerticalView:listModel];
        } else {
            [self showCollectionGoodsView:listModel];
        }
    }];
}

#pragma mark - private methods
- (void)configNavigationBar {
    self.navigationItem.title = ZFLocalizedString(@"Tabbar_Wishlist",nil);
    UIButton *shoppingCarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shoppingCarBtn setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
    [shoppingCarBtn setImage:ZFImageWithName(@"public_bag") forState:UIControlStateNormal];
    [shoppingCarBtn addTarget:self action:@selector(showCartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    shoppingCarBtn.adjustsImageWhenHighlighted = NO;
    
    UIBarButtonItem *shoppingCarItem = [[UIBarButtonItem alloc]initWithCustomView:shoppingCarBtn];
    self.shoppingCarBtn = shoppingCarBtn;
    self.navigationItem.rightBarButtonItems = @[shoppingCarItem];
    
    CGSize size = [self.titleView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    size.height = 44;
    self.titleView.intrinsicContentSize = size;
    //因为某些版本太低了，需要重新赋值
    CGRect frame = self.titleView.frame;
    frame.size = size;
    self.titleView.frame = frame;
    self.navigationItem.titleView = self.titleView;
}

- (void)addObserver {
    // 购物车
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCarBageByCartNotify) name:kCartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPostRedDot) name:kPostFirstCollectRedDotNotification object:nil];
    // 商详页收藏通知
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshCollectionInfo) name:kCollectionGoodsNotification object:nil];
}

- (void)refreshCarBageByCartNotify {
    [self refreshCarBage];
    [ZFPopDownAnimation popDownRotationAnimation:self.shoppingCarBtn];
}

- (void)showPostRedDot {
    [self.titleView showReadDot:YES];
}

- (void)addWishListVerticalView
{
    self.goodsView.hidden = YES;
    if (![self.view.subviews containsObject:self.wishVerticalStyleView]) {
        [self.view addSubview:self.wishVerticalStyleView];
        [self.wishVerticalStyleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-0);//-kiphoneXHomeBarHeight
        }];
    }
    self.wishVerticalStyleView.hidden = NO;
}

- (void)addCollectionGoodsView
{
    self.wishVerticalStyleView.hidden = YES;
    if (![self.view.subviews containsObject:self.goodsView]) {
        [self.view addSubview:self.goodsView];
        [self.goodsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-0);//-kiphoneXHomeBarHeight
        }];
    }
    self.goodsView.hidden = NO;
}

- (void)showWishListVerticalView:(ZFCollectionListModel *)listModel
{
    [self addWishListVerticalView];
    self.wishVerticalStyleView.listModel = listModel;
}

- (void)showCollectionGoodsView:(ZFCollectionListModel *)listModel
{
    [self addCollectionGoodsView];
    self.goodsView.listModel = listModel;
}

#pragma mark - action methods
- (void)showCartButtonAction:(UIButton *)sender {
    //防止从购物车页面循环跳转购物车
    [self pushOrPopToViewController:NSStringFromClass(ZFCartViewController.class) withObject:nil aSelector:nil animated:YES];
    
    //统计购物车按钮事件
    [ZFStatistics eventType:ZF_Favorites_Cars_type];
}

#pragma mark - ZFWishListVerticalStyleViewDelegate

- (void)ZFWishListVerticalStyleViewAddCartCompetion
{
    [self refreshCarBage];
}

- (void)ZFWishListVerticalStyleViewNoData
{
    [self requestWishGoodsList];
}

#pragma mark - ZFCollectionGoodsViewDelegate

- (BOOL)ZFCollectionGoodsViewRefreshData:(ZFCollectionListModel *)listModel
{
//    BOOL status = NO;
//    if (!self.btsPolicyValue || [self.btsPolicyValue isEqualToString:kZFBts_B]) {
    self.goodsView.hidden = YES;
//        status = YES;
//    }
    [self requestWishGoodsList];
    return YES;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.view.backgroundColor = ZFCOLOR_WHITE;
//    [self.view addSubview:self.goodsView];
    [self.view addSubview:self.postsView];
}

- (void)zfAutoLayoutView {
//    [self.goodsView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.top.trailing.mas_equalTo(self.view);
//        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-kiphoneXHomeBarHeight);
//    }];
    
    [self.postsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-kiphoneXHomeBarHeight);
    }];
}

#pragma mark - getter

- (ZFCollectionTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[ZFCollectionTitleView alloc] init];
        @weakify(self)
        _titleView.indexBlock = ^(NSInteger index) {
            @strongify(self)
            if (index == 0) {
                self.goodsView.hidden = NO;
                self.wishVerticalStyleView.hidden = NO;
                self.postsView.hidden = YES;
            } else {
                self.goodsView.hidden = YES;
                self.wishVerticalStyleView.hidden = YES;
                self.postsView.hidden = NO;
                [self.postsView viewWillShow];
            }
        };
    }
    return _titleView;
}

- (ZFCollectionGoodsView *)goodsView {
    if (!_goodsView) {
        _goodsView = [[ZFCollectionGoodsView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, CGRectGetHeight(self.view.bounds) -kiphoneXHomeBarHeight)];
        _goodsView.controller = self;
        _goodsView.delegate = self;
    }
    return _goodsView;
}

- (ZFCollectionPostsContainerView *)postsView {
    if (!_postsView) {
        _postsView = [[ZFCollectionPostsContainerView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, CGRectGetHeight(self.view.bounds) -kiphoneXHomeBarHeight)];
        _postsView.hidden = YES;
    }
    return _postsView;
}

- (ZFWishListVerticalStyleView *)wishVerticalStyleView
{
    if (!_wishVerticalStyleView) {
        _wishVerticalStyleView = [[ZFWishListVerticalStyleView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, CGRectGetHeight(self.view.bounds) -kiphoneXHomeBarHeight) style:UITableViewStylePlain];
        _wishVerticalStyleView.styleViewdelegate = self;
        _wishVerticalStyleView.contentInset = UIEdgeInsetsMake(0, 0, kiphoneXHomeBarHeight, 0);
    }
    return _wishVerticalStyleView;
}

- (ZFCollectionViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[ZFCollectionViewModel alloc] init];
    }
    return _viewModel;
}

@end
