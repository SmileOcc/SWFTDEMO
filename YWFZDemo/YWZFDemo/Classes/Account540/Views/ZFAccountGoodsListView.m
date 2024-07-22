//
//  ZFAccountGoodsListView.m
//  ZZZZZ
//
//  Created by YW on 2019/10/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountGoodsListView.h"
#import "AccountManager.h"
#import "ZFColorDefiner.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "UIColor+ExTypeChange.h"
#import "Masonry.h"
#import "Constants.h"
#import "ExchangeManager.h"
#import "ZFAccountHeaderBaseCell.h"
#import "ZFAccountHeaderCReusableView.h"
#import "ZFGoodsModel.h"
#import "ZFRefreshFooter.h"
#import "ZFAccountViewModel.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFGoodsDetailViewController.h"
#import "YWCFunctionTool.h"
#import "ZFAccountGoodsListViewAop.h"
#import "ZFAccountProductCCell.h"

//=============================================================================================

@interface ZFAccountGoodsListView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSMutableArray                *tableDataArray;
@property (nonatomic, strong) ZFAccountViewModel            *viewModel;
@property (nonatomic, assign) ZFAccountRecommendSelectType  dataType;
@property (nonatomic, assign) BOOL                          cellCanScroll;
@property (nonatomic, strong) ZFAccountGoodsListViewAop *analyticsAop;
@end

@implementation ZFAccountGoodsListView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame dataType:(ZFAccountRecommendSelectType)dataType {
    self = [super initWithFrame:frame];
    if (self) {
        self.dataType = dataType;
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAop];
        
        [self zfInitView];
        
        if (self.dataType == ZFAccountSelect_RecommendType) {
            [self requestAccountRecommendData:YES];
            
        } else if (self.dataType == ZFAccountSelect_HistoryType) {
            [self refreshRecentlyData];
        }
        
        [self addNotification];
    }
    return self;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSubCanScrollStatus:) name:kGoodsShowsDetailViewSubScrollStatus object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveChangeCurrency) name:kCurrencyNotification object:nil];
}

- (void)receiveChangeCurrency {
    [self.collectionView reloadData];
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tableDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableDataArray.count > indexPath.row) {
        ZFAccountProductCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFAccountProductCCell class]) forIndexPath:indexPath];
        cell.goodsModel = self.tableDataArray[indexPath.row];
        return cell;
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (KScreenWidth - kMarginSpace12 * 4) / 3 ;
    CGFloat showH = width / kGoodsImageRatio;
    return CGSizeMake(width, (showH + 40));
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kMarginSpace12, kMarginSpace12, kMarginSpace12, kMarginSpace12);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    if (self.tableDataArray.count > indexPath.row && self.selectedGoodsBlock) {
        ZFGoodsModel *goodsModel = self.tableDataArray[indexPath.row];
        self.selectedGoodsBlock(goodsModel, self.dataType);
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isEqual:self.collectionView]) return;
//    YWLog(@"子 表格滚动=2=====%.2f=====%d",scrollView.contentOffset.y, self.cellCanScroll);
    
    if (self.cellCanScroll) {
        if (scrollView.contentOffset.y <= 0) {
            self.collectionView.contentOffset = CGPointZero;
            [self sendSuperTabCanScroll:YES];
        } else {
            [self sendSuperTabCanScroll:NO];
        }
    } else {
        if (!scrollView.isDragging) {
            [self sendSuperTabCanScroll:YES];
        }
        self.collectionView.contentOffset = CGPointZero;
    }
}

- (void)sendSuperTabCanScroll:(BOOL)status {
    NSDictionary *dic = @{@"status":@(status) };
    [[NSNotificationCenter defaultCenter] postNotificationName:kGoodsShowsDetailViewSuperScrollStatus object:nil userInfo:dic];
    /// 设置点击状态栏滚到顶部
    self.collectionView.scrollsToTop = !status;
    
    // 如果父类设置为可以滚动时，子类都不滚动
    if (status) {
        NSDictionary *dic = @{@"status":@(NO),
        @"type":@(self.dataType)};

        [[NSNotificationCenter defaultCenter] postNotificationName:kGoodsShowsDetailViewSubScrollStatus object:nil userInfo:dic];
    }
}

- (void)setSubCanScrollStatus:(NSNotification *)notice {
    NSDictionary *dic = notice.userInfo;
    NSNumber *status = dic[@"status"];
    self.cellCanScroll = [status boolValue];
    
    // 把非当前选中的页面全部置顶
    NSNumber *type = dic[@"type"];
    if ([type intValue] != self.dataType && ![status boolValue]) {
        self.collectionView.contentOffset = CGPointZero;
    }
}

- (void)resetPageIndexToFirst {
    self.viewModel.pageIndex = 1;
    [self requestAccountRecommendData:YES];
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}

- (NSMutableArray *)tableDataArray {
    if (!_tableDataArray) {
        _tableDataArray = [NSMutableArray array];
    }
    return _tableDataArray;
}

/// 个人中心显示推荐商品 -> (分页)
- (void)requestAccountRecommendData:(BOOL)isFirstPage {
    @weakify(self)
    [self.viewModel requestAccountRecommend:isFirstPage completion:^(NSDictionary *resultParams, NSError *error) {
        @strongify(self)
        if (!ZFJudgeNSDictionary(resultParams) || error) return;
        NSArray *productList = resultParams[@"goods_list"];
        
        if (self.viewModel.pageIndex == 1) {
            [self.tableDataArray removeAllObjects];
        }
        [self.tableDataArray addObjectsFromArray:productList];
        [self.collectionView reloadData];
        self.collectionView.backgroundView = nil;
        [self.collectionView showRequestTip:resultParams[@"pageInfo"]];
    }];
}

/// 个人中心显示浏览历史记录
- (void)refreshRecentlyData {
    [ZFGoodsModel selectAllGoods:^(NSArray<ZFGoodsModel *> *recentlyGoodsArray) {
        self.tableDataArray = [NSMutableArray arrayWithArray:recentlyGoodsArray];
        [self.collectionView reloadData];
        self.collectionView.backgroundView = nil;
        [self.collectionView showRequestTip:@{}];
    }];
}

#pragma mark - <ZFInitUI>

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = NO;
        
        UIView *view = [[UIView alloc] init];
        UIView *loading = [UIView zfLoadingView];
        loading.center = CGPointMake(self.center.x, self.center.y - 150);
        [view addSubview:loading];
        _collectionView.backgroundView = view;
        _collectionView.blankPageTipViewOffsetY = 100;
        
        if (self.dataType == ZFAccountSelect_RecommendType) {
            @weakify(self)
            _collectionView.mj_footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
                @strongify(self)
                [self requestAccountRecommendData:NO];
            }];
            _collectionView.mj_footer.hidden = YES;
        }
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:[ZFAccountProductCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFAccountProductCCell class])];
    }
    return _collectionView;
}

-(ZFAccountViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFAccountViewModel alloc] init];
    }
    return _viewModel;
}

- (ZFAccountGoodsListViewAop *)analyticsAop {
    if (!_analyticsAop) {
        ZFAppsflyerInSourceType sourceType = ZFAppsflyerInSourceTypeDefault;
        if (self.dataType == ZFAccountSelect_RecommendType) {
            sourceType = ZFAppsflyerInSourceTypeSerachRecommendPersonal;
            
        } else if (self.dataType == ZFAccountSelect_HistoryType) {
            sourceType = ZFAppsflyerInSourceTypeAccountRecentviewedProduct;
        }
        _analyticsAop = [[ZFAccountGoodsListViewAop alloc] initAopWithSourceType:(sourceType)];
    }
    return _analyticsAop;
}

@end
