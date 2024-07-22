//
//  ZFGoodsShowsItemsView.m
//  ZZZZZ
//
//  Created by YW on 2019/3/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsShowsItemsView.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "ZFFrameDefiner.h"
#import "ZFColorDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFGoodsShowsViewModel.h"
#import "ZFCommunityVideoListVC.h"
#import "ZFCommunityPostDetailPageVC.h"
#import "YWCFunctionTool.h"

#import "UIScrollView+ZFBlankPageView.h"
#import "ZFCommunityCategoryPostListCell.h"
#import "GoodsDetailModel.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"

static NSString *const kZFGoodsShowsCellIdentifier = @"kZFGoodsShowsCellIdentifier";

@interface ZFGoodsShowsItemsView ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
CHTCollectionViewDelegateWaterfallLayout
>
@property (nonatomic, strong) CHTCollectionViewWaterfallLayout            *flowLayout;
@property (nonatomic, strong) UICollectionView                            *showCollectionView;
@property (nonatomic, strong) NSMutableArray <GoodsShowExploreModel *>    *datasArray;
@property (nonatomic, assign) BOOL                                        cellCanScroll;
@property (nonatomic, strong) ZFGoodsShowsViewModel                       *showsViewModel;
@property (nonatomic, copy) NSString                                      *goods_sn;
@end

@implementation ZFGoodsShowsItemsView

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
    if ([type intValue] != 0) {
        self.showCollectionView.contentOffset = CGPointZero;
    }
}

- (BOOL)fetchScrollStatus {
    return self.showCollectionView.contentOffset.y > 0;
}

- (void)showDataWithGoods_sn:(NSString *)goods_sn {
    self.goods_sn = goods_sn;
    [self.showCollectionView.mj_header beginRefreshing];
}

- (void)setCollectionViewCanScroll:(BOOL)canScroll {
    self.showCollectionView.scrollEnabled = canScroll;
}

/**
 * 点击了show打开关联帖子
 */
- (void)selectedShowExploreWithModel:(GoodsShowExploreModel *)showExploreModel {
    if (showExploreModel.type == 1) { //视频
        ZFCommunityVideoListVC *videoVC = [[ZFCommunityVideoListVC alloc] init];
        videoVC.videoId = showExploreModel.reviewsId;
        [self.viewController.navigationController pushViewController:videoVC animated:YES];
        
    } else { //帖子
        // 从show详情进入帖子详情需要带入所有相关联的帖子id
        BOOL hasStartIndex = NO;
        NSMutableArray *reviewIDArray = [NSMutableArray array];
        
        for (NSInteger i=0; i<self.datasArray.count; i++) {
            GoodsShowExploreModel *showsModel = self.datasArray[i];
            if (showExploreModel.type == 1) continue;// 不需要视频
            if (hasStartIndex) {
                [reviewIDArray addObject:ZFToString(showsModel.reviewsId)];
                
            } else if ([showExploreModel.reviewsId isEqualToString:showsModel.reviewsId]) {
                hasStartIndex = YES;
                [reviewIDArray addObject:ZFToString(showsModel.reviewsId)];
            }
        }
        ZFCommunityPostDetailPageVC *topicDetailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:ZFToString(showExploreModel.reviewsId) title:ZFLocalizedString(@"Community_Videos_DetailTitle",nil)];
        topicDetailViewController.reviewIDArray = reviewIDArray;
        [self.viewController.navigationController pushViewController:topicDetailViewController animated:YES];
    }
}

#pragma mark - ===========请求数据===========

- (void)requestShowsData:(BOOL)isFirstPage {
    [self showRequestloadingView:YES];
    
    @weakify(self)
    [self.showsViewModel requestGoodsShowsData:self.goods_sn
                                  isFirstPage:isFirstPage
                                   completion:^(NSArray *showModelArr, NSDictionary *pageInfo) {
                                       @strongify(self)
        if (isFirstPage) {
           [self.datasArray removeAllObjects];
        }
        [self showRequestloadingView:NO];
        [self.datasArray addObjectsFromArray:showModelArr];
        [self.showCollectionView reloadData];
        [self.showCollectionView showRequestTip:pageInfo];
                                       
    } failure:^(id _Nonnull obj) {
        @strongify(self)
        [self showRequestloadingView:NO];
        [self.showCollectionView showRequestTip:@{}];
    }];
}

#pragma mark - <ZFInitViewProtocol>
-(void)zfInitView {
    [self addSubview:self.showCollectionView];
}

- (void)zfAutoLayoutView {
    [self.showCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datasArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityCategoryPostListCell *postCell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFGoodsShowsCellIdentifier forIndexPath:indexPath];
    if (self.datasArray.count > indexPath.item) {
        GoodsShowExploreModel *showsModel = self.datasArray[indexPath.item];
        postCell.showsModel = showsModel;
    }
    return postCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (self.datasArray.count > indexPath.item) {
        GoodsShowExploreModel *showsModel = self.datasArray[indexPath.item];
        [self selectedShowExploreWithModel:showsModel];
    }
}

#pragma mark - UICollectionDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.datasArray.count > indexPath.row) {
        GoodsShowExploreModel *postModel = self.datasArray[indexPath.row];
        CGFloat item_w = (KScreenWidth - 2 * 12 - 13) / 2.0;
        CGFloat item_h = 0;
        if ([postModel.bigPicWidth floatValue] > 0) {
            item_h = item_w * [postModel.bigPicHeight floatValue] / [postModel.bigPicWidth floatValue];
        }
        return CGSizeMake(item_w, item_h);
    }
    return CGSizeZero;
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
    if (![scrollView isEqual:self.showCollectionView]) return;
//    YWLog(@"子 表格滚动=2=====%.2f=====%d",scrollView.contentOffset.y, self.cellCanScroll);
    
    if (self.cellCanScroll) {
        if (scrollView.contentOffset.y <= 0) {
            self.showCollectionView.contentOffset = CGPointZero;
            [self sendSuperTabCanScroll:YES];
        } else {
            [self sendSuperTabCanScroll:NO];
        }
    } else {
        if (!scrollView.isDragging) {
            [self sendSuperTabCanScroll:YES];
        }
        self.showCollectionView.contentOffset = CGPointZero;
    }
}
- (void)sendSuperTabCanScroll:(BOOL)status {
    NSDictionary *dic = @{@"status":@(status) };
    [[NSNotificationCenter defaultCenter] postNotificationName:kGoodsShowsDetailViewSuperScrollStatus object:nil userInfo:dic];
}

#pragma mark - getter

- (NSMutableArray<GoodsShowExploreModel *> *)datasArray {
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
        self.showCollectionView.backgroundView = backgroundView;
    } else {
        self.showCollectionView.backgroundView = nil;
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

- (UICollectionView *)showCollectionView {
    if (!_showCollectionView) {
        _showCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _showCollectionView.backgroundColor = ZFCOLOR_WHITE;
        _showCollectionView.showsVerticalScrollIndicator = NO;
        _showCollectionView.showsHorizontalScrollIndicator = NO;
        _showCollectionView.dataSource = self;
        _showCollectionView.delegate = self;
        _showCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 40.0, 0);
        
        NSString *tipTitle = ZFLocalizedString(@"EmptyCustomViewHasNoData_titleLabel",nil);
        UIImage *tipImage = [UIImage imageNamed:@"blankPage_noCart"];
        _showCollectionView.emptyDataTitle = tipTitle;
        _showCollectionView.emptyDataImage = tipImage;
        _showCollectionView.emptyDataBtnTitle = nil;
        
        _showCollectionView.requestFailTitle = tipTitle;
        _showCollectionView.requestFailImage = tipImage;
        _showCollectionView.requestFailBtnTitle = nil;
        
        [_showCollectionView registerClass:[ZFCommunityCategoryPostListCell class] forCellWithReuseIdentifier:kZFGoodsShowsCellIdentifier];
        
        @weakify(self)
        [_showCollectionView addHeaderRefreshBlock:^{
            @strongify(self)
            [self requestShowsData:YES];
            
        } footerRefreshBlock:^{
            @strongify(self)
            [self requestShowsData:NO];
            
        } startRefreshing:NO];
    }
    return _showCollectionView;
}

- (ZFGoodsShowsViewModel *)showsViewModel {
    if (!_showsViewModel) {
        _showsViewModel = [[ZFGoodsShowsViewModel alloc] init];
    }
    return _showsViewModel;
}


@end
