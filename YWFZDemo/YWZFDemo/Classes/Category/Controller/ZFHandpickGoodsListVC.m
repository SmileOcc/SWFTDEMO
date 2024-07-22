//
//  ZFHandpickGoodsListVC.m
//  ZZZZZ
//
//  Created by YW on 2018/9/17.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFHandpickGoodsListVC.h"
#import "ZFGoodsListItemCell.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFGoodsModel.h"
#import "ZFPiecingOrderViewModel.h"
#import "ZFCellHeightManager.h"
#import "ZFListGoodsNumberHeaderView.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import "UIButton+ZFButtonCategorySet.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "ZFGrowingIOAnalytics.h"

static NSString  *const kHandpickGoodsListCellIdentifer = @"kHandpickGoodsListCellIdentifer";

@interface ZFHandpickGoodsListVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray<ZFGoodsModel *> *goodsArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *shoppingCarBtn;
@end

@implementation ZFHandpickGoodsListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (ZFIsEmptyString(self.title)) {
        self.title = ZFLocalizedString(@"HandpickVC_title_Swinwear", nil);
    }
    self.view.backgroundColor = [UIColor whiteColor];
    [self configureNavgationItem];
    [self.view addSubview:self.collectionView];
    [self addTableHeaderRefresh];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //刷新购物车数量
    [self refreshShppingCarBag];
}

- (void)configureNavgationItem {
    self.shoppingCarBtn = [self showNavigationRightCarBtn:ZF_HandpickGoodsList_Cars_type];
}

/**
 * 统计跳转到精选商品列表
 */
- (void)addHandpickAnalytics {
    //从优惠券deeplink入口进来不要任何统计
    if (self.isCouponListDeeplink) return;
    
    //Push 落地页曝光
    NSDictionary *params = @{ @"af_content_type": @"view pushpage",
                              @"af_channel_name":@"" 
                              };
    [ZFAnalytics appsFlyerTrackEvent:@"af_view_pushpage" withValues:params];
    
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentType] = [NSString stringWithFormat:@"recommend_push_/%@", self.goodsIDs];
    [ZFAnalytics appsFlyerTrackEvent:@"af_view_list" withValues:valuesDic];
    
    AFparams *afParams = [[AFparams alloc] init];
    afParams.bucketid = ZFToString(self.ptsModel.bucketid);
    afParams.planid = ZFToString(self.ptsModel.planid);
    afParams.versionid = ZFToString(self.ptsModel.versionid);
    [ZFAppsflyerAnalytics trackGoodsList:self.goodsArray inSourceType:ZFAppsflyerInSourceTypeAIRecommend AFparams:afParams];
    for (ZFGoodsModel *goodsModel in self.goodsArray) {
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:goodsModel page:@"精选商品列表"];
    }
}

/**
 * 刷新购物车数量
 */
- (void)refreshShppingCarBag {
    NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
    [self.shoppingCarBtn showShoppingCarsBageValue:[badgeNum integerValue]];
}

- (void)addTableHeaderRefresh {
    @weakify(self)
    [self.collectionView addHeaderRefreshBlock:^{
        @strongify(self)
        [self requesPiecingOrderData];
    } footerRefreshBlock:nil startRefreshing:YES];
}

#pragma mark - 网络请求
- (void)requesPiecingOrderData {
    @weakify(self)
    [ZFPiecingOrderViewModel requestHandpickGoodsList:self.goodsIDs completion:^(NSArray<ZFGoodsModel *> *goodsModelArr){
        @strongify(self)
        [self.goodsArray removeAllObjects];
        [self.goodsArray addObjectsFromArray:goodsModelArr];
        [self.collectionView reloadData];
        [self.collectionView showRequestTip:@{}];
        
        // 统计跳转到精选商品列表
        if (self.goodsArray.count>0) {
            [self addHandpickAnalytics];
        }
    }];
}

/**
 * 计算并保存高度
 */
- (CGFloat)queryCellHeightWithModel:(NSInteger)index {
    CGFloat cellHeight = 0.0f;
    ZFGoodsModel *model = self.goodsArray[index];
    [ZFCellHeightManager shareManager].isRecomendCell = NO;
    // 获取缓存高度
    cellHeight = [[ZFCellHeightManager shareManager] queryHeightWithModelHash:model.goods_id.hash];
    
    if (cellHeight < 0) { // 没有缓存高度
        cellHeight = [[ZFCellHeightManager shareManager] calculateCellHeightWithTagsArrayModel:model];
    }
    return cellHeight;
}

#pragma mark - Getter
-(NSMutableArray *)goodsArray {
    if (!_goodsArray) {
        _goodsArray = [NSMutableArray array];
    }
    return _goodsArray;
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.goodsArray.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if (self.goodsArray.count == 0) return nil;
    ZFListGoodsNumberHeaderView *headView = [ZFListGoodsNumberHeaderView headWithCollectionView:collectionView Kind:kind IndexPath:indexPath];
    headView.item = ZFLocalizedString(@"Handpick_RecommendedBg_tip", nil);
    headView.imageUrl = @"handpick_recommended_bg";
    return headView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = (self.goodsArray.count == 0) ? 0 : 80;
    return CGSizeMake(KScreenWidth, headerHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsListItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHandpickGoodsListCellIdentifer forIndexPath:indexPath];
    if (indexPath.row <= self.goodsArray.count - 1) {
        ZFGoodsModel *model = self.goodsArray[indexPath.row];
        cell.goodsModel = model;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.goodsArray.count <= indexPath.item) {
        CGFloat width = (KScreenWidth - 36) * 0.5;
        return  CGSizeMake(width, (width / KImage_SCALE) + 58);// 默认size
    }
    static CGFloat cellHeight = 0.0f;
    if (indexPath.item % 2 == 0) {
        // 获取当前cell高度
        CGFloat currentCellHeight = [self queryCellHeightWithModel:indexPath.item];
        cellHeight = currentCellHeight;
        if (indexPath.item + 1 < self.goodsArray.count) {
            // 获取下一个cell高度
            CGFloat nextCellHeight = [self queryCellHeightWithModel:indexPath.item + 1];
            cellHeight = currentCellHeight > nextCellHeight ? currentCellHeight : nextCellHeight;
        }
    }
    return CGSizeMake((KScreenWidth - 36) * 0.5, cellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsModel *model = self.goodsArray[indexPath.row];
    ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
    detailVC.goodsId = model.goods_id;
    
    //从优惠券deeplink入口进来不要任何统计
    if (!self.isCouponListDeeplink) {
        detailVC.sourceID = model.cat_name;
        detailVC.sourceType = ZFAppsflyerInSourceTypeAIRecommend;
        AFparams *afParams = [[AFparams alloc] init];
        afParams.bucketid = ZFToString(self.ptsModel.bucketid);
        afParams.planid = ZFToString(self.ptsModel.planid);
        afParams.versionid = ZFToString(self.ptsModel.versionid);
        detailVC.afParams = afParams;
    }
    
    self.navigationController.delegate = nil;
    [self.navigationController pushViewController:detailVC animated:YES];
    
    // appflyer统计
    NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(model.goods_sn),
                                      @"af_spu_id" : ZFToString(model.goods_spu),
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"handpick_page",    // 当前页面名称
                                      @"af_first_entrance" : @"handpick"
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
    
    [ZFGrowingIOAnalytics ZFGrowingIOProductClick:model page:@"精选商品列表" sourceParams:@{
        GIOGoodsTypeEvar : GIOGoodsTypeRecommend,
        GIOGoodsNameEvar : @"recommend_push"
    }];
}

#pragma mark - getter/setter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 12;
        layout.sectionInset = UIEdgeInsetsMake(12, 12, 12, 12);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.autoresizingMask     = UIViewAutoresizingFlexibleHeight;
        [_collectionView registerClass:[ZFGoodsListItemCell class] forCellWithReuseIdentifier:kHandpickGoodsListCellIdentifer];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

@end
