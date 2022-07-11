//
//  OSSVCategorysNewZeroListVC.m
// XStarlinkProject
//
//  Created by odd on 2020/9/15.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategorysNewZeroListVC.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "OSSVCategorysSpecalsListsViewModel.h"
#import "STLProductListSkeletonView.h"
@interface OSSVCategorysNewZeroListVC ()

@property (nonatomic, strong) UICollectionView                            *collectionView;
@property (nonatomic, strong) CHTCollectionViewWaterfallLayout            *waterFallLayout;
@property (nonatomic, strong) CHTCollectionViewWaterfallLayout            *waterZeroFallLayout;
@property (nonatomic, strong) OSSVCategorysSpecalsListsViewModel             *viewModel;
@property (nonatomic, strong) STLProductListSkeletonView                  *productSkeleton;

@end

@implementation OSSVCategorysNewZeroListVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_Currency object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = STLLocalizedString_(@"", nil);
    
    [self.viewModel baseViewChangePV:@{@"specialId":STLToString(self.specialId)} first:YES];
    [self stlInitView];
    [self requestDataWithProductSkeleton];
    [self requestData];
    // 汇率改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrency:) name:kNotif_Currency object:nil];
    
}


#pragma mark - MakeUI
- (void)stlInitView {
    [self.view addSubview:self.collectionView];
    [self.collectionView addSubview:self.productSkeleton];
    
    if ([self.type integerValue]== 12 || [self.type integerValue]== 19) {
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(8, 12, 8, 12));
        }];
    }else{
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
    
    [self.productSkeleton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.mas_equalTo(self.collectionView);
        make.width.equalTo(SCREEN_WIDTH);
    }];

}
// 骨架图
- (STLProductListSkeletonView *)productSkeleton {
    if (!_productSkeleton) {
        _productSkeleton = [[STLProductListSkeletonView alloc] init];
        _productSkeleton.hidden = YES;
    }
    return _productSkeleton;
}

#pragma mark - Request
- (void)requestDataWithProductSkeleton {
    self.productSkeleton.hidden = NO;
    @weakify(self)
    [self.viewModel requestNetwork:@{@"specialId":STLToString(self.specialId),@"refreshOrLoadmore":STLRefresh,@"type":self.type ?: @"12"} completion:^(id obj) {
        @strongify(self)
//            self.title = STLToString(self.viewModel.name);
        self.title = self.titleName;
        self.productSkeleton.hidden = YES;
        [self.collectionView reloadData];
        [self reloadMoreData];
    } failure:^(id obj) {
        @strongify(self)
        [self.collectionView reloadData];
        self.productSkeleton.hidden = YES;

    }];
}
- (void)requestData {

    @weakify(self)
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        [self.viewModel requestNetwork:@{@"specialId":STLToString(self.specialId),@"refreshOrLoadmore":STLRefresh,@"type":self.type ?: @"12"} completion:^(id obj) {
            @strongify(self)
//            self.title = STLToString(self.viewModel.name);
            self.title = self.titleName;

            [self.collectionView reloadData];
            [self.collectionView.mj_header endRefreshing];
            [self reloadMoreData];
        } failure:^(id obj) {
            @strongify(self)
            [self.collectionView reloadData];
            [self.collectionView.mj_header endRefreshing];
        }];
    }];
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.collectionView.mj_header = header;
    
//    [self.collectionView.mj_header beginRefreshing];

}
#pragma mark ---加载更多
- (void)reloadMoreData {
    @weakify(self)
    self.collectionView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        [self.viewModel requestNetwork:@{@"specialId":STLToString(self.specialId),@"refreshOrLoadmore":STLLoadMore,@"type":self.type ?: @"12"} completion:^(id obj) {
            @strongify(self)
            [self.collectionView reloadData];
            [self.collectionView.mj_footer endRefreshing];
            if (self.viewModel.themeModel.currentPage == self.viewModel.themeModel.totalPage) {
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }

        } failure:^(id obj) {
            [self.collectionView reloadData];
            [self.collectionView.mj_footer endRefreshing];

        }];
    }];
    
    [self.collectionView.mj_footer beginRefreshing];
}
#pragma mark - Notification
//货币改变通知
- (void)changeCurrency:(NSNotification *)notify {
    [self.collectionView reloadData];
}

- (void)refreshCollectionview{
    [self.collectionView reloadData];
}

#pragma mark - LazyLoad
- (OSSVCategorysSpecalsListsViewModel *)viewModel {
    
    if (_viewModel == nil) {
        _viewModel = [OSSVCategorysSpecalsListsViewModel new];
        _viewModel.controller = self;
        _viewModel.analyticDic = @{kAnalyticsAOPSourceID: STLToString(self.specialId)}.mutableCopy;
        _viewModel.isFromZeroYuan = self.isFromZeroYuan;
        @weakify(self)
        _viewModel.emptyOperationBlock = ^{
            @strongify(self)
            [self.collectionView.mj_header beginRefreshing];
        };
        
        _viewModel.freeBtnblock = ^(OSSVThemeZeroPrGoodsModel * _Nonnull zerModel) {
            @strongify(self)
            [self.viewModel requesData:zerModel.goods_id wid:zerModel.wid withSpecialId:zerModel.specialId];
        };
    }
    return _viewModel;
}

- (CHTCollectionViewWaterfallLayout *)waterFallLayout {
    if (!_waterFallLayout) {
        _waterFallLayout = [[CHTCollectionViewWaterfallLayout alloc] init];
        _waterFallLayout.columnCount = 2;
        _waterFallLayout.minimumColumnSpacing = 12;
        _waterFallLayout.minimumInteritemSpacing = 12;
        _waterFallLayout.headerHeight = 0;
        _waterFallLayout.sectionInset = UIEdgeInsetsMake(12, 12, 0, 12);
        
    }
    return _waterFallLayout;
}

- (CHTCollectionViewWaterfallLayout *)waterZeroFallLayout{
    if (!_waterZeroFallLayout) {
        _waterZeroFallLayout = [[CHTCollectionViewWaterfallLayout alloc] init];
        _waterZeroFallLayout.columnCount = 1;
        _waterZeroFallLayout.minimumColumnSpacing = 0;
        _waterZeroFallLayout.minimumInteritemSpacing = 0;
        _waterZeroFallLayout.headerHeight = 0;
        _waterZeroFallLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _waterZeroFallLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        self.type = self.type ?: @"12";
        if ([self.type integerValue] == 12 || [self.type integerValue] == 19) {
            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.waterZeroFallLayout];
        }else{
            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.waterFallLayout];
        }
        
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.dataSource = self.viewModel;
        _collectionView.delegate = self.viewModel;
        _collectionView.emptyDataSetDelegate = self.viewModel;
        _collectionView.emptyDataSetSource = self.viewModel;
        if (APP_TYPE == 3) {
            _collectionView.backgroundColor = OSSVThemesColors.stlWhiteColor;
        } else {
            _collectionView.backgroundColor = OSSVThemesColors.col_F6F6F6;
        }
        _collectionView.layer.cornerRadius = 6;
        _collectionView.layer.masksToBounds = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}


@end
