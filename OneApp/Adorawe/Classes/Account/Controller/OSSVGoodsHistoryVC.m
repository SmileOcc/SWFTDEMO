//
//  OSSVGoodsHistoryVC.m
// XStarlinkProject
//
//  Created by odd on 2020/8/4.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVGoodsHistoryVC.h"
#import "OSSVHomesHistrysViewModel.h"
#import "CHTCollectionViewWaterfallLayout.h"

@interface OSSVGoodsHistoryVC ()

@property (nonatomic, strong) UICollectionView                 *collectionView;
@property (nonatomic, strong) CHTCollectionViewWaterfallLayout *waterFallLayout;
@property (nonatomic, strong) OSSVHomesHistrysViewModel             *viewModel;

@end

@implementation OSSVGoodsHistoryVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_Currency object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = STLLocalizedString_(@"Viewed", nil);
    
    [self stlInitView];
    [self requestData];
    // 汇率改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrency:) name:kNotif_Currency object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSArray *localLikeArrays = [[OSSVCartsOperateManager sharedManager] commendList];
    if (self.viewModel.dataArray.count != localLikeArrays.count) {
        [self requestData];
    }
}

#pragma mark - MakeUI
- (void)stlInitView {
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

#pragma mark - Request
- (void)requestData {

    @weakify(self)
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        [self.viewModel requestNetwork:@[STLToString(@""),STLRefresh] completion:^(id obj) {
            @strongify(self)

            [self.collectionView reloadData];
            [self.collectionView.mj_header endRefreshing];
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
    
    [self.collectionView.mj_header beginRefreshing];

}

#pragma mark - Notification
//货币改变通知
- (void)changeCurrency:(NSNotification *)notify {
    [self.collectionView reloadData];
}

#pragma mark - LazyLoad
- (OSSVHomesHistrysViewModel *)viewModel {
    
    if (_viewModel == nil) {
        _viewModel = [OSSVHomesHistrysViewModel new];
        _viewModel.controller = self;
        @weakify(self)
        _viewModel.emptyOperationBlock = ^{
            @strongify(self)
            [self.collectionView.mj_header beginRefreshing];
        };
        
        _viewModel.updateHeaderHeightBlock = ^(CGFloat height) {
            @strongify(self)
            self.waterFallLayout.headerHeight = height;
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

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.waterFallLayout];
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.dataSource = self.viewModel;
        _collectionView.delegate = self.viewModel;
        _collectionView.emptyDataSetDelegate = self.viewModel;
        _collectionView.emptyDataSetSource = self.viewModel;
        _collectionView.backgroundColor = OSSVThemesColors.col_F6F6F6;
    }
    return _collectionView;
}

@end
