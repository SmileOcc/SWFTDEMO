//
//  ZFCollectionGoodsView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCollectionGoodsView.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFUnlineSimilarViewController.h"

#import "ZFPubilcKeyDefiner.h"
#import "ZFNotificationDefiner.h"
#import "ZFLocalizationString.h"

#import "Masonry.h"

#import "UIViewController+ZFViewControllerCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "Constants.h"
#import "ZFColorDefiner.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFStatistics.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"

#import "ZFPopDownAnimation.h"
#import "ZFGoodsListItemCell.h"
#import "ZFCMSRecommendGoodsCCell.h"
#import "ZFEmptyCCell.h"

#import "ZFCMSRecommendViewModel.h"
#import "ZFCollectionGoodsAnalyticsAOP.h"
#import "ZFCellHeightManager.h"

@interface ZFCollectionGoodsView()< UICollectionViewDelegate, UICollectionViewDataSource,ZFInitViewProtocol>

@property (nonatomic, strong) UICollectionViewFlowLayout            *flowLayout;
@property (nonatomic, strong) UICollectionView                      *collectionView;

@property (nonatomic, strong) ZFCollectionViewModel                 *viewModel;
@property (nonatomic, strong) ZFCMSRecommendViewModel               *cmsRecommendViewModel;

@property (nonatomic, strong) NSMutableArray<ZFGoodsModel*>         *recommendGoodsArr;

@property (nonatomic, strong) UIView                                *goodsMsgHeaderView;
@property (nonatomic, strong) UILabel                               *goodsMsgLabel;
@property (nonatomic, strong) UIView                                *recommendMsgHeaderView;
@property (nonatomic, strong) UILabel                               *recommendMsgLabel;

@property (nonatomic, assign) BOOL                                  isRecommender;

@property (nonatomic, strong) ZFCollectionGoodsAnalyticsAOP         *analyticsAOP;

@end

@implementation ZFCollectionGoodsView
@synthesize listModel = _listModel;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addObserver];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    [self.goodsMsgHeaderView addSubview:self.goodsMsgLabel];
    [self.recommendMsgHeaderView addSubview:self.recommendMsgLabel];
    [self addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).with.insets(UIEdgeInsetsZero);
    }];
    
    [self.goodsMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.goodsMsgHeaderView);
    }];
    
    [self.recommendMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.recommendMsgHeaderView);
    }];
    
}

- (void)addObserver {
    // 汇率改变的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeCurrency) name:kCurrencyNotification object:nil];
    // 登录刷新通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginChangeCollectionRefresh) name:kLoginNotification object:nil];
    // 登出刷新通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginChangeCollectionRefresh) name:kLogoutNotification object:nil];
}

#pragma mark - notification methods
- (void)changeCurrency {
    [self.collectionView reloadData];
}

- (void)refreshCollectionInfo:(NSNotification *)info {
    // 本页面不刷新
    NSDictionary *dictionary = info.userInfo;
    if ([dictionary[kLoadingView] isEqual:self]) {
        return;
    }
    [self requestPageData:YES];
}

- (void)loginChangeCollectionRefresh {
    self.listModel = nil;
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
    }];
    [self.collectionView.mj_header beginRefreshing];
}


- (void)showEmptyView {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.listModel.data.count>0) {
        dic[kTotalPageKey]   = @(self.listModel.total_page);
        dic[kCurrentPageKey] = @(self.listModel.page);
    }
    [self.collectionView showRequestTip:dic];
}

- (void)refreshRequest:(BOOL)isFirstPage {
    [self requestPageData:isFirstPage];
}

- (void)requestPageData:(BOOL)firstPage {
    
    @weakify(self)
    [self.viewModel requestCollectGoodsPageData:firstPage completion:^(ZFCollectionListModel *listModel, NSArray *currentPageArray, NSDictionary *pageInfo) {
        @strongify(self)
        
        if ((firstPage && listModel.data.count <= 0)) {
            [self requestCMSCommenderData:firstPage];
            
        } else {
            BOOL hiddenSelf = NO;
            if (firstPage) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(ZFCollectionGoodsViewRefreshData:)]) {
                    hiddenSelf = [self.delegate ZFCollectionGoodsViewRefreshData:listModel];
                }
            }
            if (hiddenSelf) {
                self.goodsMsgLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"list_item", nil),ZFToString(listModel.total)];
                [self.collectionView.mj_header endRefreshing];
                return;
            }
            
            [self.recommendGoodsArr removeAllObjects];
            self.goodsMsgLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"list_item", nil),ZFToString(listModel.total)];
            self.listModel = listModel;
            self.isRecommender = NO;
            [self.collectionView reloadData];
            [self.collectionView showRequestTip:pageInfo];
            
            if (self.listModel.is_show_popup) {
                //需要弹框，引导用户评论app store.
                [self.viewController showAppStoreCommentWithContactUs:self.listModel.contact_us];
            }
        }
    }];
}

/**
 * CMS列表 底部推荐商品数据
 */
- (void)requestCMSCommenderData:(BOOL)firstPage {
    @weakify(self)
    [self.cmsRecommendViewModel requestCmsRecommendData:firstPage parmaters:@{@"channel_id":@""} completion:^(NSArray<ZFGoodsModel *> * _Nonnull array, NSDictionary * _Nonnull pageInfo) {
        @strongify(self)
        
        if (ZFJudgeNSArray(array)) {
            if (firstPage) {
                [self.recommendGoodsArr removeAllObjects];
            }
            [self.recommendGoodsArr addObjectsFromArray:array];
        }
        self.isRecommender = YES;
        if (self.recommendGoodsArr.count <= 0) {
            self.collectionView.backgroundColor = ZFC0xF7F7F7();
        } else {
            self.collectionView.backgroundColor = ZFC0xFFFFFF();
        }
        [self.collectionView reloadData];
        [self.collectionView showRequestTip:pageInfo];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

/*** 暂时不需要取消收藏功能
 - (void)deleteCollectionOptionWithModel:(ZFGoodsModel *)model andIndexPath:(NSIndexPath *)indexPath{
 @weakify(self);
 [ZFCollectionViewModel cancleCollect:model.goods_id completion:^(id obj) {
 @strongify(self);
 
 self.listModel.total = [NSString stringWithFormat:@"%ld",self.listModel.total.integerValue - 1];
 [self.listModel.data removeObjectAtIndex:indexPath.row];
 self.navigationItem.title = [NSString stringWithFormat:@"%@(%ld)",ZFLocalizedString(@"Tabbar_Wishlist",nil),(long)self.listModel.total.integerValue];
 
 //bugly⚠️⚠️⚠️: 这里记得在移除到数据源为0时,只能reloadData刷新,不能用performBatchUpdates
 [self.collectionView performBatchUpdates:^{
 [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
 
 } completion:^(BOOL finished) {
 [self.collectionView reloadData];
 [self showEmptyView];
 
 //判断total是否大于分页数量，并且当前数据小于一页，就去请求第一页，否则不请求。
 if (self.listModel.total.integerValue >= 10 && self.listModel.data.count < 10) {
 [self requestPageData:YES];
 }
 }];
 
 NSDictionary *dict = @{
 @"goods_id" : model.goods_id,
 kLoadingView : self.view,
 @"is_collect"  : @"0"
 };
 [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionGoodsNotification object:nil userInfo:dict];
 }];
 }
 */

#pragma mark - action methods

- (void)reloadOutfitsData:(UIButton *)sender {
    [self.collectionView.mj_header beginRefreshing];
}


#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.isRecommender) {
        return 2;
    }
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.isRecommender) {
        if (section == 0) {
            return 1;
        }
        return self.recommendGoodsArr.count;
    }
    return self.listModel.data.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isRecommender) {
        if (indexPath.section == 0) {
            ZFEmptyCCell *emptyCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFEmptyCCell class]) forIndexPath:indexPath];
            emptyCell.msg = ZFLocalizedString(@"CollectionViewModel_NoData_Tip", nil);
            emptyCell.msgImage = [UIImage imageNamed:@"blankPage_favorites"];
            emptyCell.backgroundColor = ZFC0xF7F7F7();
            return emptyCell;
        }
        
        ZFCMSRecommendGoodsCCell *recommendCell = [ZFCMSRecommendGoodsCCell reusableRecommendGoodsCell:collectionView forIndexPath:indexPath];
        if (self.recommendGoodsArr.count > indexPath.item) {
            ZFGoodsModel *goodsModel = self.recommendGoodsArr[indexPath.item];
            recommendCell.isNotNeedMoreOperate = YES;
            recommendCell.goodsModel = goodsModel;
        }
        return recommendCell;
    }
    
    ZFGoodsListItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFGoodsListItemCell class]) forIndexPath:indexPath];
    ZFGoodsModel *model = self.listModel.data[indexPath.row];
    model.hiddenTag = YES;
    model.is_collect = @"1";//3DTouch需要这个字段
    cell.goodsModel = model;
    [self.viewController register3DTouchAlertWithDelegate:collectionView sourceView:cell goodsModel:model];
    
    /*** 取消收藏
     model.isShowCollectButton = YES;
     model.is_collect = @"1";
     cell.cancleCollectHandler = ^(ZFGoodsModel *model) {
     @strongify(self);
     [self deleteCollectionOptionWithModel:model andIndexPath:indexPath];
     };
     */
    
    @weakify(self);
    cell.tapSimilarGoodsHandle = ^{
        @strongify(self)
        ZFUnlineSimilarViewController *unlineSimilarViewController = [[ZFUnlineSimilarViewController alloc] initWithImageURL:model.wp_image sku:model.goods_sn];
        unlineSimilarViewController.sourceType = ZFAppsflyerInSourceTypeSearchImageitems;
        [self.navigationController pushViewController:unlineSimilarViewController animated:YES];
    };
    return cell;
}

// 设置区头尺寸高度
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    CGSize size = CGSizeZero;
    if (self.isRecommender) {
        if (section == 1) {
            size = self.recommendMsgHeaderView.frame.size;
        }
        return size;
    }
    
    if (section == 0) {
        size = self.goodsMsgHeaderView.frame.size;
    }
    return size;
}



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *reusableView = nil;
    if (self.isRecommender) {
        if (indexPath.section == 1) {
            if (self.goodsMsgHeaderView.superview) {
                [self.goodsMsgHeaderView removeFromSuperview];
            }
            UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ZFCollectionGoodsHeaderReusableView" forIndexPath:indexPath];
            self.recommendMsgHeaderView.hidden = self.recommendGoodsArr.count > 0 ? NO : YES;
            [headerView addSubview:self.recommendMsgHeaderView];
            reusableView = headerView;

        }
    } else {
        if (indexPath.section == 0) {
            if (self.recommendMsgHeaderView.superview) {
                [self.recommendMsgHeaderView removeFromSuperview];
            }
            UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ZFCollectionGoodsHeaderReusableView" forIndexPath:indexPath];
            [headerView addSubview:self.goodsMsgHeaderView];
            reusableView = headerView;
        }
    }
    
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isRecommender) {
        if (self.recommendGoodsArr.count > indexPath.item) {
            ZFGoodsModel *model = self.recommendGoodsArr[indexPath.item];
            ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
            detailVC.goodsId = model.goods_id;
            detailVC.sourceType = ZFAppsflyerInSourceTypeWishListRecommend;
            self.navigationController.delegate = nil;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        return;
    }
    
    if (self.listModel.data.count > indexPath.item) {
        ZFGoodsModel *model = self.listModel.data[indexPath.item];
        ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
        detailVC.goodsId = model.goods_id;
        detailVC.sourceType = ZFAppsflyerInSourceTypeWishListSourceMedia;
        self.navigationController.delegate = nil;
        [self.navigationController pushViewController:detailVC animated:YES];
        // 谷歌统计
        [ZFAnalytics clickCollectionProductWithProduct:model position:(int)self.listModel.page actionList:@"Wishlist"];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = (KScreenWidth - 3*12) * 0.5;
    CGFloat height = (width / KImage_SCALE) + 58;
    if (self.isRecommender) {
        if (indexPath.section == 0) {
            width = KScreenWidth;
            height = KScreenWidth * 286.0 / 375.0;
        } else {
            width = (KScreenWidth - 4*12) / 3.0;
            height = (width / KImage_SCALE) + 58;
        }
    } else {
        static CGFloat cellHeight = 0.0f;
        
        if (indexPath.item % 2 == 0) {
            // 获取当前cell高度
            CGFloat currentCellHeight = [self queryCellHeightWithModel:indexPath.item];
            cellHeight = currentCellHeight;
            if (indexPath.item + 1 < self.listModel.data.count) {
                // 获取下一个cell高度
                CGFloat nextCellHeight = [self queryCellHeightWithModel:indexPath.item + 1];
                cellHeight = currentCellHeight > nextCellHeight ? currentCellHeight : nextCellHeight;
            }
        }
        height = cellHeight;
    }
    return CGSizeMake(width, height);
}

// 两行之间的上下间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

// 两个cell之间的左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 12;
}

#pragma mark - private method

- (CGFloat)queryCellHeightWithModel:(NSInteger)index {
    CGFloat cellHeight = 0.0f;
    
    // 获取模型数据˛¸
    ZFGoodsModel *model = self.listModel.data[index];
    
    [ZFCellHeightManager shareManager].isRecomendCell = NO;
    // 获取缓存高度
    cellHeight = [[ZFCellHeightManager shareManager] queryHeightWithModelHash:model.goods_id.hash];
    
    if (cellHeight < 0) { // 没有缓存高度
        // 计算并保存高度
        cellHeight = [[ZFCellHeightManager shareManager] calculateCellHeightWithTagsArrayModel:model];
    }
    
    return cellHeight;
}

#pragma mark - Property Method

- (void)setListModel:(ZFCollectionListModel *)listModel
{
    _listModel = listModel;
    
    if ([_listModel.data count]) {
        [self.collectionView reloadData];
        if (_listModel.total_page > 1) {
            self.collectionView.mj_footer.hidden = NO;
            self.collectionView.mj_footer.state = MJRefreshStateIdle;
            self.goodsMsgLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"list_item", nil),ZFToString(listModel.total)];
        }
    } else {
        self.goodsMsgLabel.text = nil;
        [self.collectionView.mj_header beginRefreshing];
        [self requestCMSCommenderData:YES];
    }
}

- (NSMutableArray<ZFGoodsModel *> *)recommendGoodsArr {
    if (!_recommendGoodsArr) {
        _recommendGoodsArr = [[NSMutableArray alloc] init];
    }
    return _recommendGoodsArr;
}


- (ZFCollectionViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCollectionViewModel alloc] init];
        _viewModel.controller = self.controller;
        _viewModel.listModel = self.listModel;
    }
    return _viewModel;
}

- (ZFCollectionListModel *)listModel {
    if (!_listModel) {
        _listModel = [[ZFCollectionListModel alloc] init];
    }
    return _listModel;
}

- (ZFCMSRecommendViewModel *)cmsRecommendViewModel {
    if (!_cmsRecommendViewModel) {
        _cmsRecommendViewModel = [[ZFCMSRecommendViewModel alloc] init];
        _cmsRecommendViewModel.controller = self.controller;
    }
    return _cmsRecommendViewModel;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = ZFC0xFFFFFF();
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, kiphoneXHomeBarHeight, 0);
        
        [_collectionView registerClass:[ZFGoodsListItemCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFGoodsListItemCell class])];
        [_collectionView registerClass:[ZFCMSRecommendGoodsCCell class]  forCellWithReuseIdentifier:NSStringFromClass([ZFCMSRecommendGoodsCCell class])];
        [_collectionView registerClass:[ZFEmptyCCell class]  forCellWithReuseIdentifier:NSStringFromClass([ZFEmptyCCell class])];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ZFCollectionGoodsHeaderReusableView"];
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        //处理数据空白页
        _collectionView.emptyDataImage = [UIImage imageNamed:@"blankPage_favorites"];
        _collectionView.emptyDataTitle = ZFLocalizedString(@"CollectionViewModel_NoData_Tip",nil);
        
        @weakify(self);
        [_collectionView addHeaderRefreshBlock:^{
            @strongify(self);
            [self requestPageData:YES];
        } footerRefreshBlock:^{
            @strongify(self);
            if (self.isRecommender) {
                [self requestCMSCommenderData:NO];
            } else {
                [self requestPageData:NO];
            }
            
        } startRefreshing:NO];
    }
    return _collectionView;
}

- (UIView *)goodsMsgHeaderView {
    if (!_goodsMsgHeaderView) {
        _goodsMsgHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 37)];
    }
    return _goodsMsgHeaderView;
}

- (UILabel *)goodsMsgLabel {
    if (!_goodsMsgLabel) {
        _goodsMsgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _goodsMsgLabel.textColor = ZFC0x999999();
        _goodsMsgLabel.font = [UIFont systemFontOfSize:12];
        _goodsMsgLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _goodsMsgLabel;
}

- (UIView *)recommendMsgHeaderView {
    if (!_recommendMsgHeaderView) {
        _recommendMsgHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
    }
    return _recommendMsgHeaderView;
}

- (UILabel *)recommendMsgLabel {
    if (!_recommendMsgLabel) {
        _recommendMsgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _recommendMsgLabel.textColor = ZFC0x2D2D2D();
        _recommendMsgLabel.font = [UIFont boldSystemFontOfSize:14];
        _recommendMsgLabel.textAlignment = NSTextAlignmentCenter;
        _recommendMsgLabel.text = ZFLocalizedString(@"Account_RecomTitle", nil);
    }
    return _recommendMsgLabel;
}

- (ZFCollectionGoodsAnalyticsAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFCollectionGoodsAnalyticsAOP alloc] init];
    }
    return _analyticsAOP;
}
@end
