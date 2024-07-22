//
//  ZFCommunityOutiftConfigurateGoodsItemView.m
//  ZZZZZ
//
//  Created by YW on 2019/3/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityOutiftConfigurateGoodsItemView.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "Masonry.h"

#import "ZFOutfitBuilderSingleton.h"

#import "ZFOutfitSelectItemCollectionViewCell.h"

#import "ZFCommunityOutfitSelectItemViewModel.h"

@interface ZFCommunityOutiftConfigurateGoodsItemView()<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) ZFCommunityOutfitSelectItemViewModel    *viewModel;

/**筛选字段*/
@property (nonatomic, copy) NSString                                  *selected_attr_list;

@property (nonatomic, assign) BOOL hadRequest;

@end

@implementation ZFCommunityOutiftConfigurateGoodsItemView

- (void)dealloc {
    YWLog(@"%@->>>>已经释放了",NSStringFromClass(self.class));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame goodsCate:(ZFCommunityOutfitGoodsCateModel *)cateModel {
    self = [super initWithFrame:frame];
    if (self) {
        self.cateModel = cateModel;
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outfitItemCountChangeNotice:) name:kOutfitItemCountChange object:nil];
    }
    return self;
}

- (void)outfitItemCountChangeNotice:(NSNotification *)notif {
    [self.collectionView reloadData];
}


#pragma mark - Public Method

- (void)zfViewWillAppear {
    YWLog(@"------  zfViewWillAppear: %@",self.cateModel.cateID);
    if (!self.hadRequest) {
        [self.collectionView.mj_header beginRefreshing];
    }
    
    if (!_refineModel) {
        [self loadRefineData:self.cateModel.cateID];
    }
}

- (void)refineSelectAttr:(NSString *)attr_list {
    self.selected_attr_list = attr_list;
    [self loadCateGoods:Refresh];
}

- (void)loadRefineData:(NSString *)catID {

    NSDictionary *paramsDic = @{@"attr_version":@"0",
                                @"cat_id":ZFToString(catID)};
    
    @weakify(self)
    [self.viewModel requestRefineDataWithCatID:paramsDic completion:^(CategoryRefineSectionModel *refineModel) {
        @strongify(self)
        self.refineModel = refineModel;
        
    } failure:^(id obj) {
        
    }];
}

- (void)loadCateGoods:(NSString*)isRefresh {
    self.hadRequest = YES;
    @weakify(self);
    NSDictionary *parmaters = @{
                                @"page"      : ZFToString(isRefresh),
                                @"cat_id"    : ZFToString(self.cateModel.cateID),
                                @"order_by"  : @"",
                                @"price_min" : @"",
                                @"price_max" : @"",
                                @"selected_attr_list" : ZFToString(self.selected_attr_list),
                                kLoadingView : self,
                                @"keyword": @""
                                };
    
    [self.viewModel requestSelectCategoryListData:parmaters completion:^(CategoryListPageModel *loadingModel, id pageData, BOOL requestState) {
        @strongify(self);
        [self.collectionView reloadData];
        
        //为了防止获取数据过滤后只有几个png数据，多加载几个数据
        if (requestState && pageData) {
            NSString *cur_page = ZFToString(pageData[kCurrentPageKey]);
            NSString *total_page = ZFToString(pageData[kTotalPageKey]);
            
            if (self.viewModel.goodsList.count < 10 && [cur_page integerValue] < [total_page integerValue]) {
                [self loadCateGoods:LoadMore];
            }
            [self.collectionView showRequestTip:pageData];
        } else {
            NSDictionary *pageData = @{ kTotalPageKey  :@"0",
                                        kCurrentPageKey:@"1" };
            [self.collectionView showRequestTip:pageData isNeedNetWorkStatus:NO];
        }
    }];
}


#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource/UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.goodsList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFOutfitSelectItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFOutfitSelectItemCollectionViewCell" forIndexPath:indexPath];
    
    if (self.viewModel.goodsList.count > indexPath.item) {
        
        ZFGoodsModel *goodsModel = self.viewModel.goodsList[indexPath.item];
        goodsModel.cateMenuId = self.cateModel.cateID;
        BOOL isSelected    = [[ZFOutfitBuilderSingleton shareInstance] isContainGoods:goodsModel];
        
        NSString *pureImageName = goodsModel.pureImageName ? goodsModel.pureImageName : ZFToString(goodsModel.wp_image);

        [cell configDataWithImageURL:ZFToString(pureImageName) isSelected:isSelected];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![[ZFOutfitBuilderSingleton shareInstance] isCanAdd]) {
        YWLog(@"----occ:已添加到最大个数");
        ShowToastToViewWithText(self, ZFLocalizedString(@"community_outfistpost_counttost", nil));
        return;
    }
    
    if (self.viewModel.goodsList.count > indexPath.item) {
        ZFGoodsModel *goodsModel = self.viewModel.goodsList[indexPath.item];
        
        ZFOutfitSelectItemCollectionViewCell *cell = (ZFOutfitSelectItemCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell selectedAnimation];
        
        NSString *pureImageName = goodsModel.pureImageName ? goodsModel.pureImageName : ZFToString(goodsModel.wp_image);
        
        ZFOutfitItemModel *itemModel = [ZFOutfitItemModel new];
        itemModel.imageURL           = ZFToString(pureImageName);
        itemModel.cateID             = ZFToString(self.cateModel.cateID);
        itemModel.goodModel          = goodsModel;
        [[ZFOutfitBuilderSingleton shareInstance] addOutfitItem:itemModel];

        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddOutfitItem object:itemModel];

        if (self.selectBlock) {
            self.selectBlock(goodsModel);
        }
    }
}

#pragma mark - Property Method

- (ZFCommunityOutfitSelectItemViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityOutfitSelectItemViewModel alloc] init];
    }
    return _viewModel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat kItemSpace = 9;
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        CGFloat itemWidth = (KScreenWidth - kItemSpace * 4) / 3;
        layout.itemSize   = CGSizeMake(itemWidth, itemWidth * 145.0 / 109.0);
        layout.minimumLineSpacing      = kItemSpace;
        layout.minimumInteritemSpacing = kItemSpace;
        layout.scrollDirection         = UICollectionViewScrollDirectionVertical;
        layout.sectionInset            = UIEdgeInsetsMake(kItemSpace, kItemSpace, kItemSpace, kItemSpace);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask     = UIViewAutoresizingFlexibleHeight;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.delegate             = self;
        _collectionView.dataSource           = self;
        _collectionView.backgroundColor      = [UIColor clearColor];
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        @weakify(self)
        [_collectionView addCommunityHeaderRefreshBlock:^{
            @strongify(self)
            [self loadCateGoods:Refresh];
        } footerRefreshBlock:^{
            @strongify(self)
            [self loadCateGoods:LoadMore];
        } startRefreshing:NO];
        
        [_collectionView registerClass:[ZFOutfitSelectItemCollectionViewCell class] forCellWithReuseIdentifier:@"ZFOutfitSelectItemCollectionViewCell"];
        
        _collectionView.blankPageViewCenter = CGPointMake(KScreenWidth / 2.0, 110);
    }
    return _collectionView;
}

@end
