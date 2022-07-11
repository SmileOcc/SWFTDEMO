//
//  OSSVCategorysVirtualListVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailsVC.h"
#import "STLCategoryVirtualListViewModel.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "STLCategoryVirtualListCollectionView.h"
#import "OSSVCategorysVirtualListVC.h"

@interface OSSVCategorysVirtualListVC ()<STLCategoryVirtualListCollectionViewDelegate>

@property (nonatomic, strong) STLCategoryVirtualListViewModel *viewModel;
@property (nonatomic, strong) STLCategoryVirtualListCollectionView *collectionView;
@property (nonatomic, strong) UIButton *backToTopButton;

@end

@implementation OSSVCategorysVirtualListVC

#pragma mark - life cycle


- (void)dealloc
{
    if (_collectionView) {
        [self.collectionView removeObserver:self forKeyPath:kColletionContentOffsetName];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_Currency object:nil];
    [self.viewModel freesource];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.firstEnter)
    {// 谷歌统计
        self.firstEnter = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.childDetailTitle;
    
    [self setupView];
    [self requestData];
    
    // 汇率改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrency:) name:kNotif_Currency object:nil];
    // 添加观察
    [self.collectionView addObserver:self forKeyPath:kColletionContentOffsetName options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - private methods


- (void)setupView
{
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.backToTopButton];
    [self.view bringSubviewToFront:self.backToTopButton];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.mas_equalTo(self.view);
    }];
    
    [self.backToTopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(50));
        make.trailing.equalTo(@(-10));
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}


- (void)requestData
{
    @weakify(self)
    self.collectionView.mj_footer = [STLRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        NSDictionary *parmaters = @{@"cat_name":STLToString(self.childName),
                                    @"relatedId":STLToString(self.relatedID),
                                    @"type":STLToString(self.vitrualTypes),
                                    @"order_by" :@(0),
                                    @"loadState":STLLoadMore};
        
        [self.viewModel requestNetwork:parmaters
                            completion:^(id obj) {
                                @strongify(self)
                                if([obj isEqual: STLNoMoreToLoad])
                                {
                                    // 无法加载更多的时候
                                    [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                                    self.collectionView.mj_footer.hidden = YES;
                                }
                                else
                                {
                                    self.collectionView.dataArray = self.viewModel.dataArray;
                                    [self.collectionView updateData];
                                    [self.collectionView.mj_footer endRefreshing];
                                }
                                
                            }
                               failure:^(id obj) {
                                   @strongify(self)
                                   self.collectionView.dataArray = self.viewModel.dataArray;
                                   [self.collectionView updateData];
                                   [self.collectionView.mj_footer endRefreshing];
                               }];
    }];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        
        NSDictionary *parmaters = @{@"cat_name":STLToString(self.childName),
                                    @"relatedId":STLToString(self.relatedID),
                                    @"type":STLToString(self.vitrualTypes),
                                    @"order_by":@(0),
                                    @"loadState":STLRefresh};
        [self.collectionView refreshStart];
        [self.viewModel requestNetwork:parmaters
                            completion:^(id obj) {
                                @strongify(self)
                                if (self.collectionView.mj_footer.state == MJRefreshStateNoMoreData)
                                {
                                    // 此处是对应 mj_footer.state == 不能加载更多后的重置
                                    [self.collectionView.mj_footer resetNoMoreData];
                                    self.collectionView.mj_footer.hidden = NO;
                                }
                                self.collectionView.dataArray = self.viewModel.dataArray;
                                [self.collectionView updateData];
                                [self.collectionView.mj_header endRefreshing];
                            }
                               failure:^(id obj) {
                                   @strongify(self)
                                   self.collectionView.dataArray = self.viewModel.dataArray;
                                   [self.collectionView updateData];
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

#pragma mark - KVO set


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kColletionContentOffsetName])
    {
        CGFloat offset = self.collectionView.contentOffset.y;
        if (offset > STL_COLLECTION_MOVECONTENT_HEIGHT)
        {
            [UIView animateWithDuration: 0.8
                                  delay: 0.4
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations: ^{
                                 [self.backToTopButton mas_updateConstraints:^(MASConstraintMaker *make) {
                                     if (kIS_IPHONEX)
                                     {
                                         make.bottom.equalTo(@(-10-STL_TABBAR_IPHONEX_H));
                                     }
                                     else
                                     {
                                         make.bottom.equalTo(@(-10));
                                     }
                                 }];
                             }
                             completion: ^(BOOL finished) {
                                 [UIView animateWithDuration: 0.4 animations: ^{
                                     self.backToTopButton.alpha = 1.0;
                                 }];
                             }];
        }
        else
        {
            [UIView animateWithDuration: 0.8
                                  delay: 0.4
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations: ^{
                                 [self.backToTopButton mas_updateConstraints:^(MASConstraintMaker *make) {
                                     make.bottom.equalTo(@(50));
                                 }];
                             }
                             completion: ^(BOOL finished) {
                                 [UIView animateWithDuration: 0.4 animations: ^{
                                     self.backToTopButton.alpha = 0;
                                 }];
                             }];
        }
    }
}

#pragma mark - user Action


- (void)clickBackToTopButtonAction
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                          atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

#pragma mark - STLCategoryVirtualListCollectionViewDelegate

- (void)didDeselectVirtualGoodListModel:(STLCategoriyDetailGoodListModel *)model
{
    OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
    goodsDetailsVC.goodsId = model.goodsId;
    goodsDetailsVC.wid = model.wid;
    goodsDetailsVC.coverImageUrl = model.goodsImageUrl;
    goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceCategoryList;
    goodsDetailsVC.reviewsId = self.childDetailTitle;
    [self.navigationController pushViewController:goodsDetailsVC animated:YES];
}

#pragma mark - notification 货币改变通知


- (void)changeCurrency:(NSNotification *)notify
{
    [self.collectionView reloadData];
}


#pragma mark - LazyLoad setters and getters

- (STLCategoryVirtualListViewModel *)viewModel
{
    if (!_viewModel)
    {
        _viewModel = [STLCategoryVirtualListViewModel new];
        _viewModel.childDetailTitle = _childDetailTitle;
    }
    return _viewModel;
}


- (STLCategoryVirtualListCollectionView *)collectionView
{
    if (!_collectionView)
    {
        CHTCollectionViewWaterfallLayout *waterFallLayout = [[CHTCollectionViewWaterfallLayout alloc] init];
        waterFallLayout.columnCount = 2;
        waterFallLayout.minimumColumnSpacing = 12;
        waterFallLayout.minimumInteritemSpacing = 12;
        waterFallLayout.sectionInset = UIEdgeInsetsMake(12, 12, 0, 12);

        _collectionView = [[STLCategoryVirtualListCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:waterFallLayout];
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.backgroundColor = STLThemeColor.col_F6F6F6;
        _collectionView.myDelegate = self;
        @weakify(self)
        _collectionView.emptyOperationBlock = ^{
            @strongify(self)
            [self.collectionView.mj_header beginRefreshing];
        };
    }
    return _collectionView;
}

- (UIButton *)backToTopButton
{
    if (!_backToTopButton)
    {
        _backToTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backToTopButton setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
        [_backToTopButton addTarget:self action:@selector(clickBackToTopButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _backToTopButton.alpha = 0;
    }
    return _backToTopButton;
}

@end
