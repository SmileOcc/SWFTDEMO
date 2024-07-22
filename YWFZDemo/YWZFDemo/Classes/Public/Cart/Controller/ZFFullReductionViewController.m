//
//  ZFFullReductionViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/9/20.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFFullReductionViewController.h"
#import "ZFFullReductionViewModel.h"
#import "ZFGoodsListItemCell.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFGoodsModel.h"
#import "ZFCellHeightManager.h"
#import "ZFListGoodsNumberHeaderView.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "ZFGrowingIOAnalytics.h"

static NSString  *const kFullReductionListCellIdentifer = @"kFullReductionListCellIdentifer";

@interface ZFFullReductionViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSArray *goodsArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *shoppingCarBtn;
@property (nonatomic, strong) ZFFullReductionViewModel *fullReducftionViewModel;
@property (nonatomic, strong) NSString *result_num;
@end

@implementation ZFFullReductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configureNavgationItem];
    [self.view addSubview:self.collectionView];
    [self addTableHeaderRefresh];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //刷新购物车数量
    NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
    [self.shoppingCarBtn showShoppingCarsBageValue:[badgeNum integerValue]];
}

- (void)configureNavgationItem {
    self.shoppingCarBtn = [self showNavigationRightCarBtn:ZF_HandpickGoodsList_Cars_type];
}

- (void)addTableHeaderRefresh {
    @weakify(self)
    [self.collectionView addHeaderRefreshBlock:^{
        @strongify(self)
        [self requesFullReductionList:YES];
    } footerRefreshBlock:^{
        @strongify(self)
        [self requesFullReductionList:NO];
    } startRefreshing:YES];
}

#pragma mark - 网络请求
- (void)requesFullReductionList:(BOOL)isFirstPage {
    @weakify(self)
    [self.fullReducftionViewModel requestFullReductionData:isFirstPage
                                                  reduc_id:self.reduc_id
                                             activity_type:self.activity_type
                                            finishedHandle:^(NSArray *goodsArray, NSDictionary *pageDict) {
        @strongify(self)
        self.title = ZFToString(pageDict[@"title"]);
        self.result_num = ZFToString(pageDict[@"result_num"]);
        self.goodsArray = goodsArray;
        [self.collectionView reloadData];
        [self.collectionView showRequestTip:pageDict];
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

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.goodsArray.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    ZFListGoodsNumberHeaderView *headView = [ZFListGoodsNumberHeaderView headWithCollectionView:collectionView Kind:kind IndexPath:indexPath];
    if (!ZFIsEmptyString(self.result_num) && self.goodsArray.count != 0) {
        headView.item = [NSString stringWithFormat:ZFLocalizedString(@"Public_items_Found", nil), ZFToString(self.result_num)];
        return headView;
    }
    return headView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (!ZFIsEmptyString(self.result_num) && self.goodsArray.count > 0) {
        return CGSizeMake(KScreenWidth, 40);
    } else {
        return CGSizeMake(KScreenWidth, 0.0);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsListItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFullReductionListCellIdentifer forIndexPath:indexPath];
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
    detailVC.sourceID = model.cat_name;
    detailVC.sourceType = ZFAppsflyerInSourceTypeFullReduction;
    self.navigationController.delegate = nil;
    [self.navigationController pushViewController:detailVC animated:YES];
    
    // appflyer统计
    NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(model.goods_sn),
                                      @"af_spu_id" : ZFToString(model.goods_spu),
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"fullreduction_page",    // 当前页面名称
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
    
    [ZFGrowingIOAnalytics ZFGrowingIOProductClick:model page:@"fullreduction_page" sourceParams:@{
        GIOGoodsTypeEvar : GIOGoodsTypeOther,
        GIOGoodsNameEvar : @"discount_product"
    }];
}

#pragma mark - Getter
- (ZFFullReductionViewModel *)fullReducftionViewModel {
    if(!_fullReducftionViewModel){
        _fullReducftionViewModel = [[ZFFullReductionViewModel alloc] init];
    }
    return _fullReducftionViewModel;
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
        [_collectionView registerClass:[ZFGoodsListItemCell class] forCellWithReuseIdentifier:kFullReductionListCellIdentifer];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

@end
