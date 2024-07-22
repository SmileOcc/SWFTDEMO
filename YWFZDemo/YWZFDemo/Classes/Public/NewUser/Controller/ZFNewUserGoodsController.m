//
//  ZFNativeGoodsViewController.m
//  ZZZZZ
//
//  Created by YW on 23/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFNewUserGoodsController.h"
#import "ZFInitViewProtocol.h"
#import "ZFNativeCollectionView.h"
#import "ZFNewUserGoodsCCell.h"
#import "ZFListGoodsNumberHeaderView.h"
#import "ZFNativeNavgationGoodsModel.h"
#import "ZFNativeBannerViewModel.h"
#import "ZFCellHeightManager.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFNativeBannerGoodsAOP.h"
#import "ZFNewUserExclusiveModel.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFFrameDefiner.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "ZFColorDefiner.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIView+LayoutMethods.h"
#import "YWCFunctionTool.h"
#import "ZFGrowingIOAnalytics.h"

@interface ZFNewUserGoodsController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ZFInitViewProtocol>
@property (nonatomic, strong) ZFNativeCollectionView                *collectionView;
@property (nonatomic, strong) ZFNativeBannerViewModel               *viewModel;
@property (nonatomic, copy)   NSString                              *resultNum;
@property (nonatomic, strong) NSMutableArray *analyticsSet;
@end

@implementation ZFNewUserGoodsController
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zfInitView];
    [self zfAutoLayoutView];
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {    
    ZFNewUserGoodsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCollectionMultipleColumnCellIdentifier forIndexPath:indexPath];
    ZFNewUserExclusiveGoodsListModel *goodsModel = self.dataArray[indexPath.row];
    cell.goodsModel = goodsModel;
    // 统计
    if (![self.analyticsSet containsObject:ZFToString(goodsModel.goodsId)]) {
        [self.analyticsSet addObject:ZFToString(goodsModel.goodsId)];
        ZFGoodsModel *model = [ZFGoodsModel new];
        model.goods_id = goodsModel.goodsId;
        model.goods_sn = goodsModel.goodsSn;
        [ZFAppsflyerAnalytics trackGoodsList:@[model] inSourceType:ZFAppsflyerInSourceTypeNewUserGoods AFparams:nil];
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:model page:@"新人专享"];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count > indexPath.item) {
        ZFNewUserExclusiveGoodsListModel *goodsModel = self.dataArray[indexPath.row];
        ZFGoodsDetailViewController *detailVC = [ZFGoodsDetailViewController new];
        detailVC.goodsId    = goodsModel.goodsId;
        detailVC.sourceType = ZFAppsflyerInSourceTypeNewUserGoods;
        detailVC.analyticsProduceImpression = self.viewModel.analyticsProduceImpressionGoodsList;
        UIViewController *vc = [UIViewController currentTopViewController];
        [vc.navigationController pushViewController:detailVC animated:YES];
        // appflyer统计
        NSString *spuSN = @"";
        if (goodsModel.goodsSn.length > 7) {  // sn的前7位为同款id
            spuSN = [goodsModel.goodsSn substringWithRange:NSMakeRange(0, 7)];
        }else{
            spuSN = goodsModel.goodsSn;
        }
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsModel.goodsSn),
                                          @"af_spu_id" : ZFToString(spuSN),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"newuser_page",    // 当前页面名称
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
        
        ZFGoodsModel *model = [ZFGoodsModel new];
        model.goods_id = goodsModel.goodsId;
        model.goods_sn = goodsModel.goodsSn;
        model.goods_title = goodsModel.goodsTitle;
        [ZFGrowingIOAnalytics ZFGrowingIOProductClick:model page:@"新人专享" sourceParams:@{
            GIOGoodsTypeEvar : GIOGoodsTypeOther,
            GIOGoodsNameEvar : @"newusers_exclusive"
        }];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count <= indexPath.section || self.dataArray.count <= indexPath.item) {
        YWLog(@"error:数组越界; selector:%@", NSStringFromSelector(_cmd));
        CGFloat width = (KScreenWidth - 36) / 2;
        return CGSizeMake(width, (width / KImage_SCALE) + 79); // 默认size
    }
    
    static CGFloat cellHeight = 330.0f;
    return CGSizeMake((KScreenWidth - 36) / 2, cellHeight);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ZFListGoodsNumberHeaderView *headView = [ZFListGoodsNumberHeaderView headWithCollectionView:collectionView Kind:kind IndexPath:indexPath];
    if ([kind isEqualToString: UICollectionElementKindSectionHeader] ) {
        headView.item = [NSString stringWithFormat:ZFLocalizedString(@"list_item", nil),self.resultNum];
    }
    return headView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return ZFIsEmptyString(self.resultNum) || [self.resultNum isEqualToString:@"0"] ? CGSizeZero : CGSizeMake(KScreenWidth, 36);
}

#pragma mark - Private method
#pragma mark - Public method
- (YNPageCollectionView *)querySubScrollView {
    return self.collectionView;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

//防止在下拉请求数据时一片空白
- (void)showLoadingIndicatorView:(BOOL)showIndicatorView {
    if (showIndicatorView) {
        UIView *indicatorView = [UIView zfLoadingView];
        if ([indicatorView isKindOfClass:[UIView class]]) {
            indicatorView.centerX = self.view.centerX;
            indicatorView.y = 50;
            UIView *tmpBgView = [[UIView alloc] init];
            [tmpBgView addSubview:indicatorView];
            _collectionView.backgroundView = tmpBgView;
        }
    } else {
        _collectionView.backgroundView = nil;
    }
}

#pragma mark - Getter
- (ZFNativeCollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0.0f;
        layout.minimumInteritemSpacing = 12.0f;
        layout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[ZFNativeCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[ZFNewUserGoodsCCell class] forCellWithReuseIdentifier:kZFCollectionMultipleColumnCellIdentifier];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self showLoadingIndicatorView:NO];
    }
    return _collectionView;
}

- (ZFNativeBannerViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFNativeBannerViewModel alloc] init];
    }
    return _viewModel;
}

- (NSMutableArray *)analyticsSet {
    if (!_analyticsSet) {
        _analyticsSet = [NSMutableArray array];
    }
    return _analyticsSet;
}

@end
