//
//  ZFNativeGoodsViewController.m
//  ZZZZZ
//
//  Created by YW on 23/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFNativeGoodsViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFNativeCollectionView.h"
#import "ZFGoodsListItemCell.h"
#import "ZFListGoodsNumberHeaderView.h"
#import "ZFNativeNavgationGoodsModel.h"
#import "ZFGoodsModel.h"
#import "ZFNativeBannerViewModel.h"
#import "ZFCellHeightManager.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFNativeBannerGoodsAOP.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFNativeGoodsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ZFInitViewProtocol>
@property (nonatomic, strong) ZFNativeCollectionView                *collectionView;
@property (nonatomic, strong) ZFNativeBannerViewModel               *viewModel;
@property (nonatomic, strong) NSMutableArray                        *dataArray;
@property (nonatomic, copy)   NSString                              *resultNum;
@property (nonatomic, strong) ZFNativeBannerGoodsAOP                *analyticsAop;
@end

@implementation ZFNativeGoodsViewController
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zfInitView];
    [self zfAutoLayoutView];
    
    [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAop];

    [self requestPageData:[Refresh boolValue]];
}

#pragma mark - Request
- (void)requestPageData:(BOOL)firstPage {
    @weakify(self)
    [self.viewModel requestBannerGoodsListData:firstPage
                                         navId:self.plateID
                                     specialId:self.specialId
                                    completion:^(ZFNativeNavgationGoodsModel *model, NSArray *currentPageArray, NSDictionary *pageInfo)
    {
        @strongify(self)
        self.resultNum = [NSString stringWithFormat:@"%ld",(long)model.resultNum];
        [self.dataArray addObjectsFromArray:currentPageArray];
        self.analyticsAop.dataList = self.dataArray;
        NSInteger pageCount = currentPageArray.count;
        if (!model || pageCount >= 0) {
            if (firstPage) {
                [self showLoadingIndicatorView:NO];
                [self.collectionView reloadData];
            } else {
                NSInteger startIndex = model.goodsList.count - currentPageArray.count;
                NSMutableArray *newAddArray = [NSMutableArray array];
                for (int i = 0 ; i < currentPageArray.count; i++) {
                    [newAddArray addObject:[NSIndexPath indexPathForItem:(startIndex+i) inSection:0]];
                }
                
                if (newAddArray.count > 0) {
                    [self.collectionView performBatchUpdates:^{
                        [self.collectionView insertItemsAtIndexPaths:newAddArray];
                    } completion:nil];
                }
            }
        }
        [self.collectionView showRequestTip:pageInfo];
        if (!firstPage && pageCount > 0) {
            CGFloat oldOffset_Y = self.collectionView.contentOffset.y;
            [self.collectionView setContentOffset:CGPointMake(0, oldOffset_Y + self.collectionView.mj_footer.height) animated:YES];
        }
    }];
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {    
    ZFGoodsListItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCollectionMultipleColumnCellIdentifier forIndexPath:indexPath];
    ZFGoodsModel *goodsModel = self.dataArray[indexPath.row];
    cell.goodsModel = goodsModel;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count > indexPath.item) {
        ZFGoodsModel *goodsModel = self.dataArray[indexPath.row];
        ZFGoodsDetailViewController *detailVC = [ZFGoodsDetailViewController new];
        detailVC.goodsId    = goodsModel.goods_id;
        detailVC.sourceID   = self.specialTitle;
        detailVC.sourceType = ZFAppsflyerInSourceTypePromotion;
        //occ v3.7.0hacker 添加 ok
        detailVC.analyticsProduceImpression = self.viewModel.analyticsProduceImpressionGoodsList;
        [self.navigationController pushViewController:detailVC animated:YES];
        
//        NSString *impression = [NSString stringWithFormat:@"%@_%@",ZFGANativeList, self.specialTitle];
//        [ZFAnalytics clickProductWithProduct:goodsModel position:1 actionList:impression];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count <= indexPath.section || self.dataArray.count <= indexPath.item) {
        YWLog(@"error:数组越界; selector:%@", NSStringFromSelector(_cmd));
        CGFloat width = (KScreenWidth - 36) / 2;
        return CGSizeMake(width, (width / KImage_SCALE) + 79); // 默认size
    }
    
    static CGFloat cellHeight = 0.0f;
    
    if (indexPath.item % 2 == 0) {
        // 获取当前cell高度
        CGFloat currentCellHeight = [self queryCellHeightWithModel:indexPath.item];
        cellHeight = currentCellHeight;
        
        if (indexPath.item + 1 < self.dataArray.count) {
            // 获取下一个cell高度
            CGFloat nextCellHeight = [self queryCellHeightWithModel:indexPath.item + 1];
            cellHeight = currentCellHeight > nextCellHeight ? currentCellHeight : nextCellHeight;
        }
    }
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
- (CGFloat)queryCellHeightWithModel:(NSInteger)index {
    CGFloat cellHeight = 0.0f;
    
    // 获取模型数据
    ZFGoodsModel *model = self.dataArray[index];
    [ZFCellHeightManager shareManager].isRecomendCell = NO;
    // 获取缓存高度
    cellHeight = [[ZFCellHeightManager shareManager] queryHeightWithModelHash:model.goods_id.hash];
    
    if (cellHeight < 0) { // 没有缓存高度
        // 计算并保存高度
        cellHeight = [[ZFCellHeightManager shareManager] calculateCellHeightWithTagsArrayModel:model];
    }
    return cellHeight;
}

- (void)addRefreshFooter {
    @weakify(self)
    ZFRefreshFooter *footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self requestPageData:[LoadMore boolValue]];
    }];
    [self.collectionView setMj_footer:footer];
    self.collectionView.mj_footer.hidden = YES;
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
        [_collectionView registerClass:[ZFGoodsListItemCell class] forCellWithReuseIdentifier:kZFCollectionMultipleColumnCellIdentifier];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self showLoadingIndicatorView:YES];
        [self addRefreshFooter];
    }
    return _collectionView;
}

- (ZFNativeBannerViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFNativeBannerViewModel alloc] init];
    }
    return _viewModel;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (ZFNativeBannerGoodsAOP *)analyticsAop
{
    if (!_analyticsAop) {
        _analyticsAop = [[ZFNativeBannerGoodsAOP alloc] init];
        _analyticsAop.specialTitle = self.specialTitle;
    }
    return _analyticsAop;
}

@end
