//
//  ZFGoodsDetailCollectionView.m
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailCollectionView.h"
#import "ZFGoodsDetailColectionViewImportFiles.h"

@interface ZFGoodsDetailCollectionView ()
<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView  *collectionView;
@property (nonatomic, weak)   UIViewController  *goodsTouchVC;
@end

@implementation ZFGoodsDetailCollectionView

- (void)dealloc {
    YWLog(@"ZFGoodsDetailCollectionView dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - Public Method

- (void)collectionViewScrollsToTop {
    [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - SetMethod

- (void)setSectionTypeModelArr:(NSArray<ZFGoodsDetailCellTypeModel *> *)sectionTypeModelArr {
    if (ZFJudgeNSArray(sectionTypeModelArr)) {
        _sectionTypeModelArr = sectionTypeModelArr;
    }
    [self.collectionView reloadData];
}

- (void)showFooterRefresh:(BOOL)showFooterRefresh refreshBlock:(void(^)(void))refreshBlock  {
    if (showFooterRefresh && !self.collectionView.mj_footer) {
        [self.collectionView addHeaderRefreshBlock:nil footerRefreshBlock:refreshBlock startRefreshing:NO];
    }
    if (self.collectionView.mj_footer) {
        [self.collectionView.mj_footer endRefreshing];
        self.collectionView.mj_footer.hidden = !showFooterRefresh;
    }
}

- (void)reloadCollectionView:(BOOL)reloadAll sectionIndex:(NSInteger)sectionIndex {
    YWLog(@"reloadDetailCollectionView: %ld", sectionIndex);
    [self.collectionView reloadData];
}

- (void)convertProductDescCellHeight {
    for (NSInteger i=0; i<self.sectionTypeModelArr.count; i++) {
        ZFGoodsDetailCellTypeModel *sectionModel = self.sectionTypeModelArr[i];
        if (sectionModel.cellType == ZFGoodsDetailCellTypeProductModelDesc) {
            CGFloat height = sectionModel.detailModel.goods_model_data.cellHeight;
            sectionModel.sectionItemSize = CGSizeMake(KScreenWidth, MAX(49, height));
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            return;
        }
    }
}

- (void)scrollToRecommendGoodsSection {
    //if (self.collectionView.isDragging) return;
    
    for (NSInteger i=0; i<self.sectionTypeModelArr.count; i++) {
        ZFGoodsDetailCellTypeModel *sectionModel = self.sectionTypeModelArr[i];
        
        if (sectionModel.cellType == ZFGoodsDetailCellTypeCollocationBuy
            && sectionModel.sectionItemCount == 1) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            ZFGoodsDetailBaseCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
            if (cell) {
                CGFloat offsetY = CGRectGetMinY(cell.frame) - STATUSHEIGHT - 44;
                if (self.collectionView.contentOffset.y >= offsetY) return;
                CGFloat maxScrollHeight = self.collectionView.contentSize.height - (KScreenHeight);
                offsetY = MIN(maxScrollHeight, offsetY);
                [self.collectionView setContentOffset:CGPointMake(0, offsetY) animated:YES];
                return;
            }
        }
        
        if (sectionModel.cellType == ZFGoodsDetailCellTTypeRecommendHeader) {
            CGFloat maxScrollHeight = self.collectionView.contentSize.height - (KScreenHeight);
            if (sectionModel.detailModel.recommendModelArray.count == 0) {
                [self.collectionView setContentOffset:CGPointMake(0, maxScrollHeight) animated:YES];
                return;
            }
            if ([self collectionView:self.collectionView numberOfItemsInSection:i] == 0) return;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            ZFGoodsDetailBaseCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
            
            if (!cell) return;
            CGFloat offsetY = CGRectGetMinY(cell.frame) - STATUSHEIGHT - 44;
            if (self.collectionView.contentOffset.y >= offsetY) return;
            offsetY = MIN(maxScrollHeight, offsetY);
            [self.collectionView setContentOffset:CGPointMake(0, offsetY) animated:YES];
            break;
        }
    }
}

- (void)confiugEmptyView:(NSError *)error refreshBlock:(void(^)(void))refreshBlock {
    UIImage *failImage = ZFImageWithName(@"blankPage_noCart");
    NSString *failTitle = ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil);
    NSString *failBtnTitle = ZFLocalizedString(@"EmptyCustomViewManager_refreshButton",nil);
    
    if (error && (error.code == 444 || [error.domain containsString:@"not exist"])) {
        failTitle =  ZFLocalizedString(@"Search_ResultViewModel_Tip",nil);
        failBtnTitle = ZFLocalizedString(@"CartViewModel_NoData_TitleButton",nil);
    }
    self.collectionView.requestFailImage = failImage;
    self.collectionView.requestFailTitle = failTitle;
    self.collectionView.requestFailBtnTitle = failBtnTitle;
    
    self.collectionView.blankPageViewActionBlcok = ^(ZFBlankPageViewStatus status){
        if ([failTitle isEqualToString:ZFLocalizedString(@"Search_ResultViewModel_Tip",nil)]) {
            [APPDELEGATE.tabBarVC setZFTabBarIndex:TabBarIndexHome];
        } else if (refreshBlock) {
            refreshBlock();
        }
    };
    [self.collectionView showRequestTip:nil];
}

/**
 * 关联3DTouch数据
 */
- (void)add3DTouchDataInfo:(ZFGoodsDetailGoodsRecommendCell *)cell {
    if (![cell isKindOfClass:[ZFGoodsDetailGoodsRecommendCell class]] || !cell.goodsModel) return;
    
    ZFGoodsModel *goodsModel = [[ZFGoodsModel alloc] init];
    goodsModel.goods_id = cell.goodsModel.goods_id;
    goodsModel.is_collect = cell.goodsModel.is_collect;
    goodsModel.goods_number = [NSString stringWithFormat:@"%ld",cell.goodsModel.goods_number];
    goodsModel.is_on_sale = cell.goodsModel.is_on_sale;
    goodsModel.wp_image = cell.goodsModel.wp_image;
    //关联3DTouch数据
    [self.goodsTouchVC register3DTouchAlertWithDelegate:self.collectionView
                                             sourceView:cell
                                             goodsModel:goodsModel];
}

- (UIViewController *)goodsTouchVC {
    if (!_goodsTouchVC) {
        _goodsTouchVC = [UIViewController currentTopViewController];
    }
    return _goodsTouchVC;
}

#pragma mark - UICollectionDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sectionTypeModelArr.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.sectionTypeModelArr[section].sectionItemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sectionTypeModelArr.count <= indexPath.section)  {
        return [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    }
    ZFGoodsDetailCellTypeModel *sectionModel = self.sectionTypeModelArr[indexPath.section];
    ZFGoodsDetailBaseCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(sectionModel.sectionItemCellClass) forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.cellTypeModel = sectionModel;
    
    // 关联3DTouch数据
    if(sectionModel.cellType == ZFGoodsDetailCellTTypeRecommend) {
        [self add3DTouchDataInfo:(ZFGoodsDetailGoodsRecommendCell *)cell];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
        didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (self.sectionTypeModelArr.count <= indexPath.section) return;
    ZFGoodsDetailCellTypeModel *sectionModel = self.sectionTypeModelArr[indexPath.section];
    
    //标记是从3DTouch进来不传动画视图进入商详
    UIImageView *sourceView = nil;
    if(sectionModel.cellType == ZFGoodsDetailCellTTypeRecommend) {
        NSNumber *from3DTouchFlag = objc_getAssociatedObject(indexPath, k3DTouchRelationCellComeFrom);
        if (![from3DTouchFlag boolValue]) {
            ZFGoodsDetailGoodsRecommendCell *cell = (ZFGoodsDetailGoodsRecommendCell *)[collectionView cellForItemAtIndexPath:indexPath];
            sourceView = cell.iconImageView;
        }
    }
    if (sectionModel.cellType == ZFGoodsDetailCellTypeReviewViewAll ||
        sectionModel.cellType == ZFGoodsDetailCellTypeReview ||
        sectionModel.cellType == ZFGoodsDetailCellTTypeRecommend) {
        if (sectionModel.detailCellActionBlock) {
            sectionModel.detailCellActionBlock(sectionModel.detailModel, indexPath, sourceView);
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sectionTypeModelArr.count <= indexPath.section) return;
    ZFGoodsDetailCellTypeModel *sectionModel = self.sectionTypeModelArr[indexPath.section];
    
    // 将要显示推荐栏时请求推荐数据
    if (sectionModel.cellType == ZFGoodsDetailCellTTypeRecommendHeader) {
        if (sectionModel.willShowRecommendCellBock) {
            sectionModel.willShowRecommendCellBock(sectionModel.detailModel);
        }
    } else if (sectionModel.cellType == ZFGoodsDetailCellTypeReview) {
        if (sectionModel.willShowReviewCellBock) {
            sectionModel.willShowReviewCellBock(sectionModel.detailModel);
        }
    } else if (sectionModel.cellType == ZFGoodsDetailCellTypeCollocationBuy) {
        if (sectionModel.willShowCollocationBuyCellBock) {
            sectionModel.willShowCollocationBuyCellBock(sectionModel.detailModel);
        }
    }
}

#pragma mark - UICollectionDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sectionTypeModelArr.count <= indexPath.section) return CGSizeZero;
    ZFGoodsDetailCellTypeModel *sectionModel = self.sectionTypeModelArr[indexPath.section];
    
    if (sectionModel.cellType == ZFGoodsDetailCellTypeReview) {
        if (sectionModel.reviewCellSizeArray.count > indexPath.item) {
            NSString *sizeString = sectionModel.reviewCellSizeArray[indexPath.item];
            if (!ZFIsEmptyString(sizeString)) {
                return CGSizeFromString(sizeString);
            }
        }
        return CGSizeMake(KScreenWidth, 150);
    } else {
        return sectionModel.sectionItemSize;
    }
}

/// 两行之间的上下间距
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
                   minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (self.sectionTypeModelArr.count <= section) return 0;
    ZFGoodsDetailCellTypeModel *sectionModel = self.sectionTypeModelArr[section];
    return (sectionModel.cellType == ZFGoodsDetailCellTTypeRecommend) ? 12 : 0;
}

/// 两个cell之间的左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (self.sectionTypeModelArr.count <= section) return 0;
    ZFGoodsDetailCellTypeModel *sectionModel = self.sectionTypeModelArr[section];
    return (sectionModel.cellType == ZFGoodsDetailCellTTypeRecommend) ? 12 : 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    if (self.sectionTypeModelArr.count <= section) return UIEdgeInsetsZero;
    ZFGoodsDetailCellTypeModel *sectionModel = self.sectionTypeModelArr[section];
    if (sectionModel.cellType == ZFGoodsDetailCellTTypeRecommend) {
        return UIEdgeInsetsMake(0, 12, 12, 12);
    } else {
        return UIEdgeInsetsZero;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    ZFGoodsDetailView *detailView = (ZFGoodsDetailView *)self.superview;
    if ([detailView isKindOfClass:[ZFGoodsDetailView class]]
        && [detailView respondsToSelector:@selector(collectionViewDidScroll:)]) {
        [detailView collectionViewDidScroll:scrollView];
    }
}

#pragma mark - <get lazy Load>

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGRect rect = CGRectMake(0, 0, KScreenWidth, KScreenHeight - 45);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        /** 注册商详页面用到的所有Cell类型*/
        NSArray *cellTypeInfoArr = [ZFGoodsDetailCellTypeModel fetchDetailAllCellTypeArray];
        for (NSDictionary *cellTypeDict in cellTypeInfoArr) {
            
            Class sectionCellClass = cellTypeDict.allValues.firstObject;
            if (![sectionCellClass class]) continue;
            [_collectionView registerClass:[sectionCellClass class]  forCellWithReuseIdentifier:NSStringFromClass([sectionCellClass class])];
        }
        // 默认Cell
        [_collectionView registerClass:[UICollectionViewCell class]  forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    }
    return _collectionView;
}


@end
