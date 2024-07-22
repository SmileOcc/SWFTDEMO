//
//  ZFSearchMapResultViewController.m
//  ZZZZZ
//
//  Created by YW on 8/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchMapResultViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFGoodsModel.h"
#import "ZFSearchMapViewModel.h"
#import "ZFSearchImageModel.h"
#import "ZFHomeGoodsCell.h"
#import "ZFCellHeightManager.h"
#import "ZFCollectionViewModel.h"
#import "ZFGoodsDetailViewModel.h"
#import "ZFGoodsDetailViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFSearchMapResultAnalyticsAOP.h"
#import "AnalyticsInjectManager.h"
#import "ZFThemeManager.h"
#import "NSArray+SafeAccess.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZF3DTouchHeader.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshHeader.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFTimerManager.h"
#import "ZFCommonRequestManager.h"
#import "ZFBTSManager.h"

@interface ZFSearchMapResultViewController ()<ZFInitViewProtocol,UICollectionViewDelegate, UICollectionViewDataSource, ZFSearchMapResultAnalyticsDatasource>
@property (nonatomic, strong) UICollectionViewFlowLayout            *flowLayout;
@property (nonatomic, strong) UICollectionView                      *collectionView;
@property (nonatomic, strong) NSMutableArray<ZFGoodsModel *>        *goodsListArray;
@property (nonatomic, assign) NSInteger                             currentPage;
@property (nonatomic, strong) ZFSearchMapViewModel                  *viewModel;
@property (nonatomic, strong) ZFAnalyticsProduceImpression          *analyticsProduceImpression;//统计
//统计代码AOP，跟该页面相关的统计代码移到这个类
@property (nonatomic, strong) ZFSearchMapResultAnalyticsAOP            *searchMapAnalyticsAOP;
@end

@implementation ZFSearchMapResultViewController
#pragma mark - Life cycle

- (void)dealloc {
    for (ZFGoodsModel *goodsModel in self.goodsListArray) {
        if ([goodsModel.countDownTime integerValue] > 0) {
            [[ZFTimerManager shareInstance] stopTimer:[NSString stringWithFormat:@"GoodsList_%@", goodsModel.goods_id]];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.searchMapAnalyticsAOP];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.searchMapAnalyticsAOP.sourceType = self.sourceType;
    [self zfInitView];
    [self zfAutoLayoutView];
    [ZFCommonRequestManager requestProductPhotoBts:^(ZFBTSModel *btsModel) {
        [self requestPageArray:YES];
    }];
}

#pragma mark - Request
- (void)requestPageArray:(BOOL)firstPage {
    if (firstPage) {
        self.currentPage = 0;
    } else {
        self.currentPage += 1;
    }
    NSArray *firstPageArray = [self.pageArrays objectWithIndex:self.currentPage];
    NSString *goodsStr = [firstPageArray componentsJoinedByString:@","];
    
    @weakify(self)
    [self.viewModel requestSearchResultData:goodsStr completion:^(NSArray *currentPageArray) {
        @strongify(self)
        HideLoadingFromView(self.view);
        if (firstPage) {
            [self.goodsListArray removeAllObjects];
        }
        if (ZFJudgeNSArray(currentPageArray)) {
            [self.goodsListArray addObjectsFromArray:currentPageArray];
        } else {
            self.currentPage -= 1;
        }
        [self.collectionView reloadData];
        [self.collectionView showRequestTip:@{ kTotalPageKey  :@(self.pageArrays.count),
                                               kCurrentPageKey:@(self.currentPage) }];
        // 发现每次第一页都少于5个
        if (firstPage && ZFJudgeNSArray(currentPageArray) && self.goodsListArray.count < 5) {
            [self requestPageArray:NO];
        }
        
        for (ZFGoodsModel *goodsModel in currentPageArray) {
            if ([goodsModel.countDownTime integerValue] > 0) {
                [[ZFTimerManager shareInstance] startTimer:[NSString stringWithFormat:@"GoodsList_%@", goodsModel.goods_id]];
            }
        }
    }];
}

// 统计
- (void)addAnalysicsWithGoodsArray:(NSArray <ZFGoodsModel *>*)goodsArray {
    if (goodsArray.count <= 0) return;
    //occ v3.7.0hacker 添加 ok
    self.analyticsProduceImpression = [ZFAnalyticsProduceImpression initAnalyticsProducePosition:1
                                                                                  impressionList:ZFGASearchResultList
                                                                                      screenName:@"pic_search"
                                                                                           event:@"load"];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.view.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    [self.view addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.goodsListArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFHomeGoodsCell *goodsCell = [ZFHomeGoodsCell homeGoodsCellWith:collectionView forIndexPath:indexPath];
    ZFGoodsModel *goodsModel = self.goodsListArray[indexPath.row];
    goodsCell.goodsModel = goodsModel;
    [self register3DTouchAlertWithDelegate:collectionView sourceView:goodsCell goodsModel:goodsModel];
    return goodsCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.goodsListArray.count > indexPath.item) {
        ZFGoodsModel *model = self.goodsListArray[indexPath.row];
        ZFHomeGoodsCell *cell = (ZFHomeGoodsCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
        detailVC.goodsId = model.goods_id;
        //occ v3.7.0hacker 添加 ok
        detailVC.analyticsProduceImpression = self.analyticsProduceImpression;
        detailVC.isNeedProductPhotoBts = YES;
        detailVC.sourceType = self.sourceType;
//        detailVC.af_rank = model.af_rank;
        NSNumber *from3DTouchFlag = objc_getAssociatedObject(indexPath, k3DTouchRelationCellComeFrom);
        //标记是从3DTouch进来不传动画视图进入商详
        if ([from3DTouchFlag boolValue]) {
            self.navigationController.delegate = nil;
        } else {
            detailVC.transformSourceImageView = cell.goodsImageView;
            self.navigationController.delegate = detailVC;
        }
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.goodsListArray.count <= indexPath.section || self.goodsListArray.count <= indexPath.item) {
        YWLog(@"error:数组越界; selector:%@", NSStringFromSelector(_cmd));
        CGFloat width = (KScreenWidth - 36) * 0.5;
        return  CGSizeMake(width, (width / KImage_SCALE) + 58);// 默认size
    }
    
    static CGFloat cellHeight = 0.0f;

    if (indexPath.item % 2 == 0) {
        // 获取当前cell高度
        CGFloat currentCellHeight = [self queryCellHeightWithModel:indexPath.item];
        cellHeight = currentCellHeight;
        if (indexPath.item + 1 < self.goodsListArray.count) {
            // 获取下一个cell高度
            CGFloat nextCellHeight = [self queryCellHeightWithModel:indexPath.item + 1];
            cellHeight = currentCellHeight > nextCellHeight ? currentCellHeight : nextCellHeight;
        }
    }
    return CGSizeMake((KScreenWidth - 36) * 0.5, cellHeight);
}

- (CGFloat)queryCellHeightWithModel:(NSInteger)index {
    CGFloat cellHeight = 0.0f;

    // 获取模型数据
    ZFGoodsModel *model = self.goodsListArray[index];
    [ZFCellHeightManager shareManager].isRecomendCell = NO;
    // 获取缓存高度
    cellHeight = [[ZFCellHeightManager shareManager] queryHeightWithModelHash:model.goods_id.hash];

    if (cellHeight < 0) { // 没有缓存高度
        // 计算并保存高度
        cellHeight = [[ZFCellHeightManager shareManager] calculateCellHeightWithTagsArrayModel:model];
    }
    return cellHeight;
}

-(NSArray *)ZFSearchMapResultAnalyticsDataList {
    return [self.goodsListArray copy];
}

-(NSString *)ZFSearchMapResultAnalyticsSearchKey {
    return self.pageTitle;
}

#pragma mark - Getter
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 12;
        _flowLayout.sectionInset = UIEdgeInsetsMake(12, 12, 0, 12);
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:[ZFHomeGoodsCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFHomeGoodsCell class])];
        
        @weakify(self);
        [_collectionView addHeaderRefreshBlock:nil footerRefreshBlock:^{
            @strongify(self);
            [self requestPageArray:NO];
        } startRefreshing:NO];
    }
    return _collectionView;
}

- (NSMutableArray<ZFGoodsModel *> *)goodsListArray {
    if (!_goodsListArray) {
        _goodsListArray = [NSMutableArray array];
    }
    return _goodsListArray;
}

- (ZFSearchMapViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFSearchMapViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

-(ZFSearchMapResultAnalyticsAOP *)searchMapAnalyticsAOP
{
    if (!_searchMapAnalyticsAOP) {
        _searchMapAnalyticsAOP = ({
            ///注入代码
            ZFSearchMapResultAnalyticsAOP *searchAnalytics = [[ZFSearchMapResultAnalyticsAOP alloc] init];
            searchAnalytics.datasource = self;
            searchAnalytics.page = @"picResultPage";
            searchAnalytics.searchType = @"picSearchResult";
            searchAnalytics;
        });
    }
    return _searchMapAnalyticsAOP;
}

- (void)setTotalCount:(NSInteger)totalCount
{
    _totalCount = totalCount;
    self.searchMapAnalyticsAOP.totalCount = _totalCount;
}

@end
