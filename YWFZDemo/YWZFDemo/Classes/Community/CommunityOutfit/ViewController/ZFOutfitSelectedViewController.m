//
//  ZFOutfitSelectedViewController.m
//  Zaful
//
//  Created by QianHan on 2018/5/23.
//  Copyright © 2018年 Y001. All rights reserved.
//

#import "ZFCommunityOutfitSelectedItemVC.h"
#import "ZFOutfitSelectItemViewModel.h"
#import "ZFOutfitSelectItemCollectionViewCell.h"
#import "ZFOutfitBuilderSingleton.h"
#import "ZFOutfitItemModel.h"

static CGFloat const kItemSpace = 9.0f;

#define kSelectItemCellIdentifer   @"kSelectItemCellIdentifer"
@interface ZFCommunityOutfitSelectedItemVC () <UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy) NSString                         *cateID;
/**筛选字段*/
@property (nonatomic, copy) NSString                         *selected_attr_list;
@property (nonatomic, strong) ZFOutfitSelectItemViewModel    *viewModel;
@property (nonatomic, strong) NSIndexPath                    *selectIndxPath;

@property (nonatomic, strong) UIView                         *separeteView;
@property (nonatomic, strong) UICollectionView               *selectItemCollectionView;

@end

@implementation ZFCommunityOutfitSelectedItemVC

- (instancetype)initWithCateID:(NSString *)cateID {
    if (self = [super init]) {
        self.cateID    = cateID;
        self.viewModel = [ZFOutfitSelectItemViewModel new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.selectItemCollectionView];
    [self.view addSubview:self.separeteView];
    [self.view bringSubviewToFront:self.separeteView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.selectItemCollectionView reloadData];
    if (!self.refineModel) {
        [self loadRefineData:self.cateID];
    }

}

#pragma mark - 网络请求

- (void)refineSelectAttrData:(NSString *)attr_list {
    self.selected_attr_list = attr_list;
    [self loadCateGoods:Refresh];
}

- (void)loadRefineData:(NSString *)catID {
    @weakify(self)
    [self.viewModel requestRefineDataWithCatID:ZFToString(catID) completion:^(CategoryRefineSectionModel *refineModel) {
        @strongify(self)
        self.refineModel = refineModel;
        
    } failure:^(id obj) {
        
    }];
}

- (void)loadCateGoods:(NSString*)isRefresh {
    @weakify(self);

    NSDictionary *parmaters = @{
                                @"page"      : ZFToString(isRefresh),
                                @"cat_id"    : ZFToString(self.cateID),
                                @"order_by"  : @"",
                                @"price_min" : @"",
                                @"price_max" : @"",
                                @"selected_attr_list" : ZFToString(self.selected_attr_list),
                                kLoadingView : self.view,
                                @"keyword": @""
                                };
    
    [self.viewModel requestSelectCategoryListData:parmaters completion:^(CategoryListPageModel *loadingModel, id pageData, BOOL requestState) {
        @strongify(self);
        [self.selectItemCollectionView reloadData];
        
        //为了防止获取数据过滤后只有几个png数据，多加载几个数据
        if (requestState && pageData) {
            NSString *cur_page = ZFToString(pageData[kCurrentPageKey]);
            NSString *total_page = ZFToString(pageData[kTotalPageKey]);

            if (self.viewModel.goodsList.count < 10 && [cur_page integerValue] < [total_page integerValue]) {
                [self loadCateGoods:LoadMore];
            }
        }
        [self.selectItemCollectionView showRequestTip:pageData];
        
        if (self.viewModel.goodsList.count <= 0) {
            [self showAgainRequestView];
        } else {
            [self removeEmptyView];
        }
        HideLoadingFromView(self.view);
    }];
}

#pragma mark - privete method
- (void)showAgainRequestView {
    @weakify(self)
    self.emptyImage = [UIImage imageNamed:@"blankPage_requestFail"];
    self.emptyTitle = ZFLocalizedString(@"Search_ResultViewModel_Tip",nil);
    self.edgeInsetTop = -TabBarHeight;
    [self showEmptyViewHandler:^{
        @strongify(self)
        ShowLoadingToView(self.view);
        [self loadCateGoods:Refresh];
    }];
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource/UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.goodsList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFOutfitSelectItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSelectItemCellIdentifer forIndexPath:indexPath];
    if (self.viewModel.goodsList.count > indexPath.item) {
        ZFGoodsModel *goodsModel = self.viewModel.goodsList[indexPath.item];
        BOOL isSelected    = [[ZFOutfitBuilderSingleton shareInstance] isContainGoods:goodsModel];
        NSString *pureImageName = goodsModel.pureImageName ? goodsModel.pureImageName : ZFToString(goodsModel.wp_image);
        
        [cell configDataWithImageURL:ZFToString(pureImageName) isSelected:isSelected];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![[ZFOutfitBuilderSingleton shareInstance] isCanAdd]) {
        return;
    }
    if (self.viewModel.goodsList.count > indexPath.item) {
        ZFGoodsModel *goodsModel = self.viewModel.goodsList[indexPath.item];
        
        ZFOutfitSelectItemCollectionViewCell *cell = (ZFOutfitSelectItemCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell selectedAnimation];
        
        NSString *pureImageName = goodsModel.pureImageName ? goodsModel.pureImageName : ZFToString(goodsModel.wp_image);
        
        
        ZFOutfitItemModel *itemModel = [ZFOutfitItemModel new];
        itemModel.imageURL           = ZFToString(pureImageName);
        itemModel.cateID             = ZFToString(self.cateID);
        itemModel.goodModel          = goodsModel;

        [[ZFOutfitBuilderSingleton shareInstance] addOutfitItem:itemModel];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddOutfitItem object:itemModel];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        });
    }
    
}

#pragma mark - getter/setter
- (UICollectionView *)selectItemCollectionView {
    if (!_selectItemCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        CGFloat itemWidth = (self.view.width - kItemSpace * 4) / 3;
        layout.itemSize   = CGSizeMake(itemWidth, itemWidth * 145.0 / 109.0);
        layout.minimumLineSpacing      = kItemSpace;
        layout.minimumInteritemSpacing = kItemSpace;
        layout.scrollDirection         = UICollectionViewScrollDirectionVertical;
        layout.sectionInset            = UIEdgeInsetsMake(kItemSpace, kItemSpace, kItemSpace, kItemSpace);
        
        _selectItemCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _selectItemCollectionView.autoresizingMask     = UIViewAutoresizingFlexibleHeight;
        _selectItemCollectionView.alwaysBounceVertical = YES;
        _selectItemCollectionView.delegate             = self;
        _selectItemCollectionView.dataSource           = self;
        _selectItemCollectionView.backgroundColor      = [UIColor clearColor];
    
        if (@available(iOS 11.0, *)) {
            _selectItemCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        @weakify(self)
        [_selectItemCollectionView addCommunityHeaderRefreshBlock:^{
            @strongify(self)
            [self loadCateGoods:Refresh];
        } footerRefreshBlock:^{
            @strongify(self)
            [self loadCateGoods:LoadMore];
        } startRefreshing:YES];
        
        [_selectItemCollectionView registerClass:[ZFOutfitSelectItemCollectionViewCell class] forCellWithReuseIdentifier:kSelectItemCellIdentifer];
    }
    return _selectItemCollectionView;
}

- (UIView *)separeteView {
    if (!_separeteView) {
        _separeteView = [[UIView alloc] init];
        _separeteView.frame = CGRectMake(0.0, 0.0, self.view.width, 1.0);
        _separeteView.backgroundColor = [UIColor colorWithHex:0xDDDDDD];
    }
    return _separeteView;
}

@end
