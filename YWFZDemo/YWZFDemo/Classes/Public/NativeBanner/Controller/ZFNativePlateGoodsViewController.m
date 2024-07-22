//
//  ZFNativePlateGoodsViewController.m
//  ZZZZZ
//
//  Created by YW on 4/1/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFNativePlateGoodsViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFNativeCollectionView.h"
#import "ZFGoodsListItemCell.h"
#import "ZFNativeCollectionHeaderView.h"
#import "ZFNativeBannerResultModel.h"
#import "ZFNativePlateGoodsModel.h"
#import "ZFGoodsModel.h"
#import "ZFNativeBannerViewModel.h"
#import "ZFCellHeightManager.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFNativeBannerGoodsAOP.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFNativePlateGoodsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ZFInitViewProtocol>
@property (nonatomic, strong) ZFNativeCollectionView                *collectionView;
@property (nonatomic, strong) ZFNativeBannerViewModel               *viewModel;
@property (nonatomic, strong) ZFNativeBannerGoodsAOP                *analyticsAop;
@end

@implementation ZFNativePlateGoodsViewController
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self zfInitView];
    [self zfAutoLayoutView];
    
    [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAop];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
     return self.model.plateGoodsArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    ZFNativePlateGoodsModel *model = self.model.plateGoodsArray[section];
    return model.goodsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsListItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCollectionMultipleColumnCellIdentifier forIndexPath:indexPath];
    ZFNativePlateGoodsModel *model = self.model.plateGoodsArray[indexPath.section];
    ZFGoodsModel *goodsModel =  model.goodsArray[indexPath.row];
    cell.goodsModel = goodsModel;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFNativePlateGoodsModel *model = self.model.plateGoodsArray[indexPath.section];
    if (model.goodsArray.count > indexPath.item) {
        ZFGoodsModel *goodsModel =  model.goodsArray[indexPath.row];
        ZFGoodsDetailViewController *detailVC = [ZFGoodsDetailViewController new];
        detailVC.goodsId = goodsModel.goods_id;
        detailVC.sourceID = self.specialTitle;
        detailVC.sourceType = ZFAppsflyerInSourceTypePromotion;
        //occ v3.7.0hacker 添加 ok
        detailVC.analyticsProduceImpression = self.analyticsProduceImpression;
        
        [self.navigationController pushViewController:detailVC animated:YES];
        
//        NSString *impression = [NSString stringWithFormat:@"%@_%@",ZFGANativeList, self.specialTitle];
//        [ZFAnalytics clickProductWithProduct:goodsModel position:1 actionList:impression];
//        NSString *pageName = [NSString stringWithFormat:@"GIO_NativeList_%@", self.specialTitle];
//        [ZFGrowingIOAnalytics ZFGrowingIOProductClick:goodsModel page:pageName];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ZFNativePlateGoodsModel *model = self.model.plateGoodsArray[indexPath.section];
    ZFNativeCollectionHeaderView *headerView = [ZFNativeCollectionHeaderView headWithCollectionView:collectionView Kind:kind IndexPath:indexPath];
    headerView.title = model.plate_title;
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFNativePlateGoodsModel *plateModel = self.model.plateGoodsArray[indexPath.section];
    static CGFloat cellHeight = 0.0f;
    if (indexPath.item % 2 == 0) {
        // 获取当前cell高度
        CGFloat currentCellHeight = [self queryCellHeightWithModel:indexPath.section row:indexPath.row];
        cellHeight = currentCellHeight;
        if (indexPath.item + 1 < plateModel.goodsArray.count) {
            // 获取下一个cell高度
            // occ v3.8.0 这里不应该+1
            //CGFloat nextCellHeight = [self queryCellHeightWithModel:indexPath.section + 1 row:indexPath.row + 1];

            CGFloat nextCellHeight = [self queryCellHeightWithModel:indexPath.section row:indexPath.row + 1];
            cellHeight = currentCellHeight > nextCellHeight ? currentCellHeight : nextCellHeight;
        }
    }

    return CGSizeMake((KScreenWidth - 36) / 2, cellHeight);
}

#pragma mark - Private method
- (CGFloat)queryCellHeightWithModel:(NSInteger)section row:(NSInteger)row {
    CGFloat cellHeight = 0.0f;
    
    if (self.model.plateGoodsArray.count > section) {
        
        ZFNativePlateGoodsModel *plateModel = self.model.plateGoodsArray[section];
        if (plateModel.goodsArray.count > row) {
            
            // 获取模型数据
            ZFGoodsModel *model = plateModel.goodsArray[row];
            [ZFCellHeightManager shareManager].isRecomendCell = NO;
            // 获取缓存高度
            cellHeight = [[ZFCellHeightManager shareManager] queryHeightWithModelHash:model.goods_id.hash];
            
            if (cellHeight < 0) { // 没有缓存高度
                // 计算并保存高度
                cellHeight = [[ZFCellHeightManager shareManager] calculateCellHeightWithTagsArrayModel:model];
            }
        }
    }
    return cellHeight;
}

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
        make.top.leading.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(KScreenWidth, KScreenHeight - 64));
    }];
}

#pragma mark - Getter
- (ZFNativeCollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0.0f;
        layout.minimumInteritemSpacing = 12.0f;
        layout.sectionInset = UIEdgeInsetsMake(10, 12, 0, 12);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.headerReferenceSize = CGSizeMake(KScreenWidth, 48);
        layout.sectionHeadersPinToVisibleBounds = YES;
        _collectionView = [[ZFNativeCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[ZFGoodsListItemCell class] forCellWithReuseIdentifier:kZFCollectionMultipleColumnCellIdentifier];
        _collectionView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

- (ZFNativeBannerViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFNativeBannerViewModel alloc] init];
    }
    return _viewModel;
}

- (ZFNativeBannerGoodsAOP *)analyticsAop
{
    if (!_analyticsAop) {
        _analyticsAop = [[ZFNativeBannerGoodsAOP alloc] init];
        _analyticsAop.specialTitle = self.specialTitle;
        _analyticsAop.dataList = self.model.plateGoodsArray;
    }
    return _analyticsAop;
}

@end
