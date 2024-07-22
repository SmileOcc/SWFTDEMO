//
//  ZFGoodsShowsRelatedView.m
//  ZZZZZ
//
//  Created by YW on 2019/3/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsShowsRelatedView.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "ZFFrameDefiner.h"
#import "ZFColorDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFGoodsShowsViewModel.h"
#import "ZFCommunityVideoListVC.h"
#import "ZFCommunityPostDetailPageVC.h"
#import "YWCFunctionTool.h"
#import "ZFGoodsShowsRelatedModel.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFCellHeightManager.h"
#import "ZFGoodsShowsRelatedVCell.h"
#import "ZFGoodsShowsFooterView.h"
#import "ZFLocalizationString.h"

static NSString *const kZFGoodsShowsRelatedCellIdentifier = @"kZFGoodsShowsRelatedCellIdentifier";

@interface ZFGoodsShowsRelatedView ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
CHTCollectionViewDelegateWaterfallLayout
>
@property (nonatomic, strong) CHTCollectionViewWaterfallLayout            *flowLayout;
@property (nonatomic, strong) UICollectionView                            *relatedCollectionView;
@property (nonatomic, strong) NSMutableArray <ZFGoodsShowsRelatedModel *> *datasArray;
@property (nonatomic, assign) BOOL                                        cellCanScroll;
@property (nonatomic, strong) ZFGoodsShowsViewModel                       *showsViewModel;
@property (nonatomic, copy) NSString                                      *goods_sn;
@end

@implementation ZFGoodsShowsRelatedView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addNotification];
        [self showRequestloadingView:YES];
    }
    return self;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSubCanScrollStatus:) name:kGoodsShowsDetailViewSubScrollStatus object:nil];
}

- (void)setSubCanScrollStatus:(NSNotification *)notice {
    NSDictionary *dic = notice.userInfo;
    NSNumber *status = dic[@"status"];
    self.cellCanScroll = [status boolValue];
    
    NSNumber *type = dic[@"type"];
    if ([type intValue] != 1) {
        self.relatedCollectionView.contentOffset = CGPointZero;
    }
}

- (BOOL)fetchScrollStatus {
    return self.relatedCollectionView.contentOffset.y > 0;
}

- (void)relatedDataWithGoods_sn:(NSString *)goods_sn {
    self.goods_sn = goods_sn;
    [self.relatedCollectionView.mj_header beginRefreshing];
}

- (void)setCollectionViewCanScroll:(BOOL)canScroll {
    self.relatedCollectionView.scrollEnabled = canScroll;
}

- (void)selectedGoodsItem:(NSString *)goods_id {
    ZFGoodsDetailViewController *detailViewControler = [[ZFGoodsDetailViewController alloc] init];
    detailViewControler.goodsId = goods_id;
    detailViewControler.sourceType = ZFAppsflyerInSourceTypeZMeRemommendItemsShow;
    self.navigationController.delegate = nil;
    [self.navigationController pushViewController:detailViewControler animated:YES];
}

#pragma mark - ===========请求数据===========

- (void)requestRelatedData:(BOOL)isFirstPage {
    [self showRequestloadingView:YES];
    @weakify(self)
    
    [self.showsViewModel requestRelatedGoods:self.goods_sn
                                 isFirstPage:isFirstPage
                                  completion:^(NSArray *relatedModelArr, NSDictionary *pageInfo) {
                                      @strongify(self)
                                      if (isFirstPage) {
                                          [self.datasArray removeAllObjects];
                                      }
                                      [self showRequestloadingView:NO];
                                      [self.datasArray addObjectsFromArray:relatedModelArr];
                                      [self.relatedCollectionView reloadData];
                                      [self.relatedCollectionView showRequestTip:pageInfo];
                                      
                                  } failure:^(id _Nonnull obj) {
                                      @strongify(self)
                                      [self showRequestloadingView:NO];
                                      [self.relatedCollectionView showRequestTip:@{}];
                                  }];
}

#pragma mark - <ZFInitViewProtocol>
-(void)zfInitView {
    [self addSubview:self.relatedCollectionView];
}

- (void)zfAutoLayoutView {
    [self.relatedCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datasArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsShowsRelatedVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFGoodsShowsRelatedCellIdentifier forIndexPath:indexPath];
    if (self.datasArray.count > indexPath.item) {
        ZFGoodsShowsRelatedModel *model = self.datasArray[indexPath.item];
        cell.relatedModel = model;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (self.datasArray.count > indexPath.item) {
        ZFGoodsShowsRelatedModel *model = self.datasArray[indexPath.item];
        [self selectedGoodsItem:model.goods_id];
        
        // appflyer统计
        NSString *spuSN = @"";
        if (model.goods_sn.length > 7) {  // sn的前7位为同款id
            spuSN = [model.goods_sn substringWithRange:NSMakeRange(0, 7)];
        }else{
            spuSN = model.goods_sn;
        }
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(model.goods_sn),
                                          @"af_spu_id" : ZFToString(spuSN),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"goods_shows",    // 当前页面名称
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
    }
}

#pragma mark - UICollectionDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (KScreenWidth - 12 * 3) * 0.5;
    return  CGSizeMake(width, (width / KImage_SCALE) + 40);// 默认size
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(12, 12, 12, 12);
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self setShowOrFavesScrollView:scrollView scrollEnabled:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self setShowOrFavesScrollView:scrollView scrollEnabled:NO];    
}

#pragma mark  在垂直滑动滚动的时候，禁止里面子类横屏滚动
- (void)setShowOrFavesScrollView:(UIScrollView *)scrollView scrollEnabled:(BOOL)enabled {
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        if ([self.superview isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)self.superview).scrollEnabled = enabled;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isEqual:self.relatedCollectionView]) return;
//    YWLog(@"子 表格滚动=2=====%.2f=====%d",scrollView.contentOffset.y, self.cellCanScroll);
    
    if (self.cellCanScroll) {
        if (scrollView.contentOffset.y <= 0) {
            self.relatedCollectionView.contentOffset = CGPointZero;
            [self sendSuperTabCanScroll:YES];
        } else {
            [self sendSuperTabCanScroll:NO];
        }
    } else {
        if (!scrollView.isDragging) {
            [self sendSuperTabCanScroll:YES];
        }
        self.relatedCollectionView.contentOffset = CGPointZero;
    }
}

- (void)sendSuperTabCanScroll:(BOOL)status {
    NSDictionary *dic = @{@"status":@(status) };
    [[NSNotificationCenter defaultCenter] postNotificationName:kGoodsShowsDetailViewSuperScrollStatus object:nil userInfo:dic];
}

#pragma mark - getter

- (NSMutableArray<ZFGoodsShowsRelatedModel *> *)datasArray {
    if (!_datasArray) {
        _datasArray = [[NSMutableArray alloc] init];
    }
    return _datasArray;
}

- (void)showRequestloadingView:(BOOL)show {
    if (show && self.datasArray.count == 0) {
        CGRect rect = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        UIView *backgroundView = [[UIView alloc] initWithFrame:rect];
        UIView *activity = [UIView zfLoadingView];
        activity.center = CGPointMake(KScreenWidth/2, 100);
        [backgroundView addSubview:activity];
        self.relatedCollectionView.backgroundView = backgroundView;
    } else {
        self.relatedCollectionView.backgroundView = nil;
    }
}

- (CHTCollectionViewWaterfallLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[CHTCollectionViewWaterfallLayout alloc] init];
        _flowLayout.minimumColumnSpacing = 13;
        _flowLayout.minimumInteritemSpacing = 12;
        _flowLayout.headerHeight = 0;
    }
    return _flowLayout;
}

- (UICollectionView *)relatedCollectionView {
    if (!_relatedCollectionView) {
        _relatedCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _relatedCollectionView.backgroundColor = ZFCOLOR_WHITE;
        _relatedCollectionView.showsVerticalScrollIndicator = NO;
        _relatedCollectionView.showsHorizontalScrollIndicator = NO;
        _relatedCollectionView.dataSource = self;
        _relatedCollectionView.delegate = self;
        _relatedCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 40.0, 0);

        NSString *tipTitle = ZFLocalizedString(@"EmptyCustomViewHasNoData_titleLabel",nil);
        UIImage *tipImage = [UIImage imageNamed:@"blankPage_noCart"];
        _relatedCollectionView.emptyDataTitle = tipTitle;
        _relatedCollectionView.emptyDataImage = tipImage;
        _relatedCollectionView.emptyDataBtnTitle = nil;
        
        _relatedCollectionView.requestFailTitle = tipTitle;
        _relatedCollectionView.requestFailImage = tipImage;
        _relatedCollectionView.requestFailBtnTitle = nil;
        
        [_relatedCollectionView registerClass:[ZFGoodsShowsRelatedVCell class] forCellWithReuseIdentifier:kZFGoodsShowsRelatedCellIdentifier];
        
        @weakify(self)
        [_relatedCollectionView addHeaderRefreshBlock:^{
            @strongify(self)
            [self requestRelatedData:YES];
            
        } footerRefreshBlock:^{
            @strongify(self)
            [self requestRelatedData:NO];
            
        } startRefreshing:NO];
    }
    return _relatedCollectionView;
}

- (ZFGoodsShowsViewModel *)showsViewModel {
    if (!_showsViewModel) {
        _showsViewModel = [[ZFGoodsShowsViewModel alloc] init];
    }
    return _showsViewModel;
}


@end
