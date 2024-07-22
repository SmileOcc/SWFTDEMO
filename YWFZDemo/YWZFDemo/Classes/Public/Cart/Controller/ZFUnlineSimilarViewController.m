//
//  ZFUnlineSimilarViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/7/24.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFUnlineSimilarViewController.h"
#import "ZFGoodsModel.h"
#import "ZFGoodsListItemCell.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFCellHeightManager.h"
#import "ZFUnlineSimilarViewModel.h"
#import "ZFListGoodsNumberHeaderView.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFBTSManager.h"
#import "ZFTimerManager.h"
#import "ZFUnlineSimilarAnalyticsAOP.h"
#import "AnalyticsInjectManager.h"
#import "ZFCommonRequestManager.h"
#import "ZFBTSManager.h"

static NSString * const kGoodsCellIdentifer = @"kGoodsCellIdentifer";
@interface ZFUnlineSimilarViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView              *similarCollectionView;
@property (nonatomic, copy) NSString                        *sourceImageURL;
@property (nonatomic, copy) NSString                        *goods_sn;
@property (nonatomic, copy) NSString                        *findsimilarPolicy;
@property (nonatomic, strong) ZFUnlineSimilarViewModel      *viewModel;

@property (nonatomic, strong) ZFUnlineSimilarAnalyticsAOP   *unlineSimilarAnalyticsManager;

@end

@implementation ZFUnlineSimilarViewController

- (void)dealloc {
    for (ZFGoodsModel *obj in self.viewModel.resultGoodsArray) {
        // 倒计时关闭，根据商品属性判断
        if ([obj.countDownTime integerValue] > 0) {
            [[ZFTimerManager shareInstance] stopTimer:[NSString stringWithFormat:@"GoodsList_%@", obj.goods_id]];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithImageURL:(NSString *)url sku:(NSString *)sku {
    if (self = [super init]) {
        
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.unlineSimilarAnalyticsManager];
        
        self.sourceImageURL = url;
        self.goods_sn = sku;
        self.viewModel = [[ZFUnlineSimilarViewModel alloc] init];
        self.sourceType = ZFAppsflyerInSourceTypeSearchImageitems;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"unline_similargoods_title", nil);
    
    self.unlineSimilarAnalyticsManager.sourceType = self.sourceType;

    [self setupView];
    [self layout];
    [ZFCommonRequestManager requestProductPhotoBts:^(ZFBTSModel *btsModel) {
        [self requestSimilarGoodsOfBts];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //谷歌统计
    [ZFAnalytics screenViewQuantityWithScreenName:@"Similar Products"];
}

- (void)setupView {
    [self.view addSubview:self.similarCollectionView];
}

- (void)layout {
    [self.similarCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.mas_equalTo(self.view);
    }];
}

#pragma mark - request

/// V4.6.0 当前页面上的bts必须放放到页面上来请求
- (void)requestSimilarGoodsOfBts {    
    self.findsimilarPolicy = kZFBts_B;
    [self requestSimilarGoods];
}

- (void)requestSimilarGoods {
    if (ZFIsEmptyString(self.findsimilarPolicy)) {
        self.findsimilarPolicy = kZFBts_B; //默认B版本
    }
    ShowLoadingToView(self.view);
    @weakify(self)
    [self.viewModel requestAISimilarMetalDataWithImageURL:self.sourceImageURL
                                                  goodsSn:self.goods_sn
                                              findsPolicy:self.findsimilarPolicy
                                           completeHandle:^{
        @strongify(self)
        [self requestGoodsList];
    }];
}

- (void)requestGoodsList {
    @weakify(self)
    [self.viewModel requestGoodsListcompleteHandle:^{
        @strongify(self)
        HideLoadingFromView(self.view);
        [self.similarCollectionView reloadData];
        
        // 加载完最后一页的时候,变为没有更多数据的状态
        if ([self.viewModel isLastPage]) {
            if ([self.viewModel rowCount] == 0) {
                [self.similarCollectionView showRequestTip:@{}];
            } else {
                [self.similarCollectionView.mj_footer endRefreshingWithNoMoreData];
                return;
            }
        } else {
            [self.similarCollectionView showRequestTip:@{kTotalPageKey  : @(100),
                                                         kCurrentPageKey: @(1)}];
        }
    }];
}

#pragma mark - UICollectionDelegate/UICollectionDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.viewModel rowCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsListItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kGoodsCellIdentifer forIndexPath:indexPath];
    ZFGoodsModel *goodsModel  = [self.viewModel goodsModelWithIndex:indexPath.item];
    cell.goodsModel           = goodsModel;
    [self register3DTouchAlertWithDelegate:collectionView sourceView:cell goodsModel:goodsModel];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ZFListGoodsNumberHeaderView *headView = [ZFListGoodsNumberHeaderView headWithCollectionView:collectionView Kind:kind IndexPath:indexPath];
    if ([kind isEqualToString: UICollectionElementKindSectionHeader] ) {
        NSInteger totalCount = [self.viewModel totalCount];
        if (self.viewModel && totalCount>0) {
            headView.item = [NSString stringWithFormat:ZFLocalizedString(@"list_item", nil), [NSString stringWithFormat:@"%zd", totalCount]];
        }
    }
    return headView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if ([self.viewModel rowCount] > 0) {
        return CGSizeMake(KScreenWidth, 40.0f);
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.viewModel rowCount] <= indexPath.section || [self.viewModel rowCount] <= indexPath.item) {
        YWLog(@"error:数组越界; selector:%@", NSStringFromSelector(_cmd));
        CGFloat width = (KScreenWidth - 36) * 0.5;
        return  CGSizeMake(width, (width / KImage_SCALE) + 58);// 默认size
    }
    
    static CGFloat cellHeight = 0.0f;
    
    if (indexPath.item % 2 == 0) {
        // 获取当前cell高度
        CGFloat currentCellHeight = [self queryCellHeightWithModel:indexPath.item];
        cellHeight = currentCellHeight;
        
        if (indexPath.item + 1 < [self.viewModel rowCount]) {
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
    ZFGoodsModel *model = [self.viewModel goodsModelWithIndex:index];
    [ZFCellHeightManager shareManager].isRecomendCell = NO;
    // 获取缓存高度
    cellHeight = [[ZFCellHeightManager shareManager] queryHeightWithModelHash:model.goods_id.hash];
    
    if (cellHeight < 0) { // 没有缓存高度
        // 计算并保存高度
        cellHeight = [[ZFCellHeightManager shareManager] calculateCellHeightWithTagsArrayModel:model];
    }
    return cellHeight;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsModel *goodModel             = [self.viewModel goodsModelWithIndex:indexPath.item];
    ZFGoodsDetailViewController * goods = [[ZFGoodsDetailViewController alloc]init];
    goods.goodsId                       = goodModel.goods_id;
    goods.sourceType                    = self.sourceType;
    goods.isNeedProductPhotoBts         = YES;
    [self.navigationController pushViewController:goods animated:YES];
}

#pragma mark - getter/setter
- (UICollectionView *)similarCollectionView {
    if (!_similarCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 12.0;
        layout.sectionInset = UIEdgeInsetsMake(0.0, 12.0, 0.0, 12.0);
        
        _similarCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _similarCollectionView.backgroundColor = [UIColor whiteColor];
        _similarCollectionView.showsVerticalScrollIndicator = YES;
        _similarCollectionView.showsHorizontalScrollIndicator = NO;
        _similarCollectionView.alwaysBounceVertical = YES;
        _similarCollectionView.dataSource = self;
        _similarCollectionView.delegate = self;
        [_similarCollectionView registerClass:[ZFGoodsListItemCell class] forCellWithReuseIdentifier:kGoodsCellIdentifer];
        if (@available(iOS 11.0, *)) {
            _similarCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        // 处理空白页,分页逻辑
//        _similarCollectionView.emptyDataTitle    = ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil);
        
        _similarCollectionView.emptyDataImage    = ZFImageWithName(@"blankPage_nssoCart");
        
        @weakify(self)
        _similarCollectionView.blankPageViewActionBlcok = ^(ZFBlankPageViewStatus status) {
            @strongify(self)
            [self requestSimilarGoodsOfBts];
        };
        
        [_similarCollectionView addHeaderRefreshBlock:nil footerRefreshBlock:^{
            @strongify(self)
            [self requestGoodsList];
            
        } startRefreshing:NO];
        
        // 设置没有更多数据了文案
        if ([_similarCollectionView.mj_footer isKindOfClass:[ZFRefreshFooter class]]) {
            ((ZFRefreshFooter *)_similarCollectionView.mj_footer).zfNoMoreDataTipText = ZFLocalizedString(@"Global_Network_No_MoreData",nil);
        }
    }
    return _similarCollectionView;
}


-(ZFUnlineSimilarAnalyticsAOP *)unlineSimilarAnalyticsManager
{
    if (!_unlineSimilarAnalyticsManager) {
        _unlineSimilarAnalyticsManager = ({
            ///注入代码
            ZFUnlineSimilarAnalyticsAOP *searchAnalytics = [[ZFUnlineSimilarAnalyticsAOP alloc] init];
            searchAnalytics.page = @"unline_similar_page";
            searchAnalytics;
        });
    }
    return _unlineSimilarAnalyticsManager;
}

@end
