//
//  ZFCarPiecingOrderSubVC.m
//  ZZZZZ
//
//  Created by YW on 2018/9/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCarPiecingOrderSubVC.h"
#import "ZFGoodsListItemCell.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFGoodsModel.h"
#import "ZFPiecingOrderViewModel.h"
#import "ZFCellHeightManager.h"
#import "ZFCarPiecingAnalyticsAOP.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

#define kCarPiecingOrderCellIdentifer   @"kCarPiecingOrderCellIdentifer"

@interface ZFCarPiecingOrderSubVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray<ZFGoodsModel *> *goodsArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ZFCarPiecingAnalyticsAOP *carPiecingAnalyticsAop;

@property (nonatomic, assign) BOOL hasRequest;

@end

@implementation ZFCarPiecingOrderSubVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];

    [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.carPiecingAnalyticsAop];
    
    [self addTableHeaderRefresh];
    // 如果外部有传数据进来则显示
    [self showGoodsListWithOutData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    /// 因为当进入的不是第一个控制器的时候，第一个控制器不触发自动刷新方法
    if (self.goodsArray.count <= 0 && self.goodDataList.count <= 0 && !self.hasRequest) {
        [self.collectionView.mj_header beginRefreshing];
    }
}

- (void)showGoodsListWithOutData {
    if (self.goodDataList.count <= 0) return;
    [self.goodsArray removeAllObjects];
    [self.goodsArray addObjectsFromArray:self.goodDataList];
    [self.collectionView reloadData];
    [self.collectionView showRequestTip:@{}];
    self.goodDataList = nil;
}

- (void)addTableHeaderRefresh {
    @weakify(self)
    [self.collectionView addHeaderRefreshBlock:^{
        @strongify(self)
        [self requesPiecingOrderData];
    } footerRefreshBlock:nil startRefreshing:NO];
}

#pragma mark - 网络请求
- (void)requesPiecingOrderData {
    self.hasRequest = YES;
    
    @weakify(self)
    [ZFPiecingOrderViewModel requestPiecingOrderData:self.priceSectionID finishedHandle:^(NSDictionary *resultDict){
        @strongify(self)
        NSArray *goodList = [resultDict ds_arrayForKey:@"goods_list"];
        [self.goodsArray removeAllObjects];
        if (goodList.count>0) {
            NSArray *goodModelList = [NSArray yy_modelArrayWithClass:[ZFGoodsModel class] json:goodList];
            [self.goodsArray addObjectsFromArray:goodModelList];
        }
        [self.collectionView reloadData];
        [self.collectionView showRequestTip:@{}];
    }];
}

/**
 * 计算并保存高度
 */
- (CGFloat)queryCellHeightWithModel:(NSInteger)index {
    CGFloat cellHeight = 0.0f;
    
    // 获取模型数据
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
     ZFGoodsListItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCarPiecingOrderCellIdentifer forIndexPath:indexPath];
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
    detailVC.sourceType = ZFAppsflyerInSourceTypeCartPiecing;
    detailVC.goodsId = model.goods_id;
    self.navigationController.delegate = nil;
    [self.navigationController pushViewController:detailVC animated:YES];
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
        [_collectionView registerClass:[ZFGoodsListItemCell class] forCellWithReuseIdentifier:kCarPiecingOrderCellIdentifer];
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

-(ZFCarPiecingAnalyticsAOP *)carPiecingAnalyticsAop
{
    if (!_carPiecingAnalyticsAop) {
        _carPiecingAnalyticsAop = [[ZFCarPiecingAnalyticsAOP alloc] init];
        _carPiecingAnalyticsAop.title = self.priceSectionID;
    }
    return _carPiecingAnalyticsAop;
}

@end
