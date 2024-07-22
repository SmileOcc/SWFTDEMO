//
//  ZFGeshopCollectionView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopCollectionView.h"
#import "ZFGeshopThematicImportFiles.h"

@interface ZFGeshopCollectionView ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>
@property (nonatomic, strong) NSMutableArray<ZFGeshopSectionModel *> *sectionModelArr;
@property (nonatomic, weak) id<ZFGeshopThematicProtocol> actionProtocol;
@property (nonatomic, strong) ZFGeshopViewModel         *viewModel;
@property (nonatomic, strong) ZFGeshopFlowLayout        *geshopFlowLayout;
@property (nonatomic, strong) UICollectionView          *collectionView;
@property (nonatomic, assign) CGFloat                   horizNavHeight;
@property (nonatomic, assign) CGFloat                   siftBarCellHeight;
@property (nonatomic, assign) CGFloat                   beforeRequestSiftY;
@property (nonatomic, assign) NSInteger                 showNavigationFlag;
@property (nonatomic, strong) NSMutableArray            *sectionBgColorViewArr;
@end

@implementation ZFGeshopCollectionView

- (instancetype)initWithGeshopProtocol:(id<ZFGeshopThematicProtocol>)actionProtocol {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.actionProtocol = actionProtocol;
        self.siftBarCellHeight = 44;
        self.showNavigationFlag = -1;
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addRefreshMoreDataKit];
    }
    return self;
}

- (void)addRefreshMoreDataKit {
    if (self.collectionView.mj_header) return;
    @weakify(self)
    [self.collectionView addHeaderRefreshBlock:^{
        @strongify(self)
        if ([self.actionProtocol respondsToSelector:@selector(requestGeshopListData)]) {
            [self.actionProtocol requestGeshopListData];
        }
    } footerRefreshBlock:^{
        @strongify(self)
        if ([self.actionProtocol respondsToSelector:@selector(requestGeshopMorePageData)]) {
            [self.actionProtocol requestGeshopMorePageData];
        }
    } startRefreshing:NO];
}

- (void)dealWithListData:(NSArray<ZFGeshopSectionModel *> *)modelArray
                pageDict:(NSDictionary *)pageDict
{
    self.beforeRequestSiftY = 0;
    [self convertSectionBgColorView:NO];
    [self.sectionModelArr removeAllObjects];
    [self.sectionModelArr addObjectsFromArray:modelArray];
    [self.collectionView reloadData];
    [self.collectionView showRequestTip:pageDict];
    [self configuNavgationScrollItemY];
}

- (void)dealWithMorePageData:(NSArray<ZFGeshopSectionListModel *> *)goodsModelArray
                    pageDict:(NSDictionary *)pageDict
                  isFromSift:(BOOL)fromSift
{
    [self convertSectionBgColorView:NO];
    ZFGeshopSectionModel *goodsSectionModel = nil;
    for (ZFGeshopSectionModel *sectionModel in self.sectionModelArr) {
        if (sectionModel.component_type == ZFGeshopGridGoodsCellType) {
            goodsSectionModel = sectionModel;
        }
    }
    [goodsSectionModel.component_data.list addObjectsFromArray:goodsModelArray];
    goodsSectionModel.sectionItemCount = goodsSectionModel.component_data.list.count;
    [self.collectionView reloadData];
    [self.collectionView showRequestTip:pageDict];
    [self scrollToNavTopAfterSift:fromSift];
}

- (void)dealWithAsyncReloadData:(NSArray<ZFGeshopSectionModel *> *)modelArray
                       pageDict:(NSDictionary *)pageDict
                       isFromSift:(BOOL)fromSift
{
    [self convertSectionBgColorView:NO];
    [self.collectionView reloadData];
    [self.collectionView showRequestTip:pageDict];
    [self scrollToNavTopAfterSift:fromSift];
}

#pragma mark - <配置点击Cell回调>

- (NSArray *)configAllClickCellBlockArray {
    return @[
        @{@(ZFGeshopCycleBannerCellType) : self.clickCycleBannerBlock},// 轮播组件
        @{@(ZFGeshopNavigationCellType) : self.clickNavigationItemBlock}, // 水平导航组件
        @{@(ZFGeshopSiftGoodsCellType) : self.clickSiftItemBlock},// 筛选组件
    ];
}

///轮播组件点击回调
- (GeshopClickCycleBannerBlock)clickCycleBannerBlock {
    @weakify(self);
    return ^(ZFGeshopSectionListModel *bannerModel){
        @strongify(self);
        if ([self.actionProtocol respondsToSelector:@selector(jumpDeeplinkAction:)]) {
            NSString *jump_link = bannerModel.jump_link; //垃圾代码字段, Geshop恶心至极
            if (ZFIsEmptyString(jump_link)) {
                jump_link = bannerModel.link_app;
            }
            [self.actionProtocol jumpDeeplinkAction:jump_link];
        }
    };
}

///水平导航组件点击回调
- (GeshopClickNavigationItemBlock)clickNavigationItemBlock {
    @weakify(self);
    return ^(ZFGeshopSectionListModel *targetListModel, CGFloat cellHeight){
        @strongify(self);
        [self scrollToTagrtPositionCell:targetListModel
                       navigationHeight:cellHeight];
    };
}

///筛选商品组件点击回调
- (GeshopClickSiftItemBlock)clickSiftItemBlock {
    @weakify(self);
    return ^(ZFGeshopSectionModel *model, CGFloat siftBarCellMinY, NSInteger dataType, BOOL openList){
        @strongify(self);
        [self scrollToSiftPositionCell:model
                    beforeRequestSiftY:siftBarCellMinY
                              dataType:dataType
                              openList:openList];
    };
}

/// 计算水平导航组件中每个滑块标签滚动的区域
- (void)configuNavgationScrollItemY {
    ZFGeshopSectionModel *navigationModel = nil;
    
    for (NSInteger i=0; i<self.sectionModelArr.count; i++) {
        ZFGeshopSectionModel *sectionModel = self.sectionModelArr[i];
        
        if (sectionModel.component_type == ZFGeshopNavigationCellType) {
            navigationModel = sectionModel;
            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:i];
            UICollectionViewCell *cell = [self fetchCellWithIndexPath:path];
            if (!cell) continue;
            self.horizNavHeight = CGRectGetHeight(cell.frame);
            break;
        }
    }
    if (!navigationModel) return;
    for (NSInteger i=0; i<self.sectionModelArr.count; i++) {
        ZFGeshopSectionModel *sectionModel = self.sectionModelArr[i];
        
        NSInteger navListCount = navigationModel.component_data.list.count;
        for (NSInteger j=0; j<navListCount; j++) {
            ZFGeshopSectionListModel *listModel = navigationModel.component_data.list[j];
            
            if (![listModel.component_id isEqualToString:sectionModel.component_id]) continue;
            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:i];
            UICollectionViewCell *cell = [self fetchCellWithIndexPath:path];
            if (!cell) continue;
            
            CGFloat cellY = CGRectGetMinY(cell.frame);
            if (j > 0) {
                ZFGeshopSectionListModel *listModel = navigationModel.component_data.list[j-1];
                NSRange range = listModel.selectedRange;
                if ((cellY - range.location) > 0) {
                    range.length = cellY - range.location;
                    listModel.selectedRange = range;
                    if (j == 1) { //记录第一个滚动区域
                        navigationModel.firstSelectedRange = range;
                    }
                }
            }
            //最后一个不好计算,临时处理为KScreenHeight
            if (j == (navListCount - 1)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGFloat lastHeight = self.collectionView.contentSize.height - KScreenHeight;
                    lastHeight = MAX(lastHeight, KScreenHeight);
                    listModel.selectedRange = NSMakeRange(cellY, lastHeight);
                    if (navListCount == 1) { //记录第一个滚动区域
                        navigationModel.firstSelectedRange = listModel.selectedRange;
                    }
                });
            } else {
                listModel.selectedRange = NSMakeRange(cellY, cellY);
            }
            break;
        }
    }
}

- (void)scrollToNavTopAfterSift:(BOOL)fromSift {
    if (fromSift && self.beforeRequestSiftY > 0) {
        self.showNavigationFlag = 0;
        [self.collectionView setContentOffset:CGPointMake(0, self.beforeRequestSiftY) animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.showNavigationFlag = 1;
        });
    }
}

/// 刷新表格中的筛选栏Cell筛选标题
- (void)dealwithSiftCategoryModel:(ZFGeshopSiftItemModel *)siftModel
                 categoryDataType:(ZFCategoryColumnDataType)categoryDataType
                  siftModelHandle:(void(^)(ZFGeshopComponentDataModel *))siftModelHandle
                  loadNewDataHandle:(void(^)(void))loadNewDataHandle
{
    NSInteger siftSection = -1;
    for (NSInteger i=0; i<self.sectionModelArr.count; i++) {
        ZFGeshopSectionModel *sectionModel = self.sectionModelArr[i];
        if (sectionModel.component_type == ZFGeshopSiftGoodsCellType) {
            siftSection = i;
            if (categoryDataType == ZFCategoryColumn_CategoryType) {
                sectionModel.checkedCategorySiftModel = siftModel;

            } else if (categoryDataType == ZFCategoryColumn_SortType) {
                sectionModel.checkedSortSiftModel = siftModel;
            }
            if (siftModelHandle) {
                siftModelHandle(sectionModel.component_data);
            }
            break;
        }
    }
    if (siftSection != -1) {
//        [self.collectionView performBatchUpdates:^{
//            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:siftSection]];
//        } completion:^(BOOL finished) {
            if (loadNewDataHandle) {
                loadNewDataHandle();
            }
//        }];
    }
}

- (ZFGeshopSectionModel *)fetchSectionModel:(NSInteger)section {
    if (self.sectionModelArr.count > section) {
        return self.sectionModelArr[section];
    }
    return nil;
}

- (NSInteger)fetchItemsCountInSection:(NSInteger)section {
    return [self collectionView:self.collectionView numberOfItemsInSection:section];
}

- (UICollectionViewCell *)fetchCellWithIndexPath:(NSIndexPath *)indexPath {
    if (![indexPath isKindOfClass:[NSIndexPath class]]) return nil;
    return [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - <UICollectionDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sectionModelArr.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self fetchSectionModel:section].sectionItemCount;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
                  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self fetchSectionModel:indexPath.section].sectionItemSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFGeshopSectionModel *sectionModel = [self fetchSectionModel:indexPath.section];
    BOOL isSectionMode = [sectionModel isKindOfClass:[ZFGeshopSectionModel class]];
    NSString *identifier = NSStringFromClass([UICollectionViewCell class]);
    
    if (isSectionMode && sectionModel.sectionItemCellClass) {
        identifier = NSStringFromClass(sectionModel.sectionItemCellClass);
    }
    ZFGeshopBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[ZFGeshopBaseCell class]]) {
        cell.indexPath = indexPath;
        cell.sectionModel = sectionModel;
    }
    ///设置商品Section背景色
    if (isSectionMode && sectionModel.component_type == ZFGeshopGridGoodsCellType) {
        [self showSectionBgColor:indexPath
                    sectionModel:sectionModel
                        sectionY:CGRectGetMinY(cell.frame)];
        
    } else if (sectionModel.component_type == ZFGeshopSiftGoodsCellType) {
        if (self.beforeRequestSiftY == 0) {
            self.beforeRequestSiftY = CGRectGetMinY(cell.frame);
        }
    }
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (self.sectionModelArr.count <= indexPath.section) return;
    ZFGeshopSectionModel *sectionModel = [self fetchSectionModel:indexPath.section];
    
    if (sectionModel.component_type == ZFGeshopNavigationCellType ||
        sectionModel.component_type == ZFGeshopCycleBannerCellType) return;
    
    if ([self.actionProtocol respondsToSelector:@selector(clickListItemWithSectionModel:indexPath:)]) {
        [self.actionProtocol clickListItemWithSectionModel:sectionModel indexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFGeshopSectionModel *sectionModel = [self fetchSectionModel:indexPath.section];
    if (sectionModel.component_type == ZFGeshopSiftGoodsCellType) {
        self.siftBarCellHeight = CGRectGetHeight(cell.frame);
        
    } else if (sectionModel.component_type == ZFGeshopNavigationCellType) {
        self.showNavigationFlag = 1;
    }
    
    CGFloat offsetY = collectionView.contentOffset.y;
    if (self.showNavigationFlag == 1 && offsetY > 0) {
        ZFPostNotification(kCheckScrollItemIsShow, nil);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.geshopFlowLayout.enableStickyLayout = (offsetY > 0);
    
    if (self.showNavigationFlag == 1 && offsetY > 0) {
        CGFloat startY = offsetY + self.horizNavHeight + 1;
        ZFPostNotification(kRefreshNativeThemeNavigationItem, @(startY));
    }
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

/// 两行之间的上下间距
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
                   minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return [self fetchSectionModel:section].sectionMinimumLineSpacing;
}

/// 两个cell之间的左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return [self fetchSectionModel:section].sectionMinimumInteritemSpacing;
}

/// 每组Section的位置偏移
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return [self fetchSectionModel:section].sectionInsetForSection;
}

#pragma mark - 点击悬浮操作栏

/// 滚动到水平导航栏Cell位置
- (void)scrollToTagrtPositionCell:(ZFGeshopSectionListModel *)listModel
                 navigationHeight:(CGFloat)navigationHeight
{
    for (NSInteger i=0; i<self.sectionModelArr.count; i++) {
        ZFGeshopSectionModel *sectionModel = self.sectionModelArr[i];
        
        ///能遍历到相同组件id, 才滚动到组件位置
        if ([sectionModel.component_id isEqualToString:listModel.component_id]) {
            if ([self fetchItemsCountInSection:i] == 0) return;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            UICollectionViewCell *cell = [self fetchCellWithIndexPath:indexPath];
            if (!cell) return;

            CGFloat maxScrollHeight = MAX(0, self.collectionView.contentSize.height - self.collectionView.frame.size.height);
            CGFloat offsetY = CGRectGetMinY(cell.frame) - navigationHeight;
            
            self.showNavigationFlag = 0;
            [self.collectionView setContentOffset:CGPointMake(0, MIN(maxScrollHeight, offsetY)) animated:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.showNavigationFlag = 1;
            });
            break;
        }
    }
}

/// 滚动到筛选组件Cell位置
- (void)scrollToSiftPositionCell:(ZFGeshopSectionModel *)siftSectionModel
              beforeRequestSiftY:(CGFloat)beforeRequestSiftY
                        dataType:(NSInteger)dataType
                        openList:(BOOL)openListFlag
{
    self.showNavigationFlag = 0;
    if (beforeRequestSiftY <= self.beforeRequestSiftY) { //还没有悬浮时就滚动到筛选栏位置
        [self.collectionView setContentOffset:CGPointMake(0, self.beforeRequestSiftY) animated:YES];
    }
    
    BOOL isRefineType = (dataType == ZFCategoryColumn_RefineType);
    CGFloat delayDuration = isRefineType ? 0 : 0.3;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.showNavigationFlag = 1;
        
        if ([self.actionProtocol respondsToSelector:@selector(handleSiftGoodsAction:dataType:openList:)]) {
            [self.actionProtocol handleSiftGoodsAction:siftSectionModel
                                              dataType:dataType
                                              openList:openListFlag];
        }
        if (isRefineType) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setListViewCanScrollsToTop:NO];
            });
        }
    });
}

- (void)setListViewCanScrollsToTop:(BOOL)canToTop {
    [self.collectionView setScrollsToTop:canToTop];
}

#pragma mark - <Scroll Scetion Component>

/// 需求: 给平铺模式Section添加一个背景视图来 设置背景颜色
- (void)showSectionBgColor:(NSIndexPath *)indexPath
              sectionModel:(ZFGeshopSectionModel *)sectionModel
                  sectionY:(CGFloat)sectionY
{
    if ([self.sectionBgColorViewArr containsObject:sectionModel]) return;
    [self.sectionBgColorViewArr addObject:sectionModel];
    
    CGFloat topMagin = sectionModel.sectionInsetForSection.top;
    CGFloat bottomMagin = sectionModel.sectionInsetForSection.bottom;
    
    CGFloat padding_top = sectionModel.component_style.padding_top;
    CGFloat padding_bottom = sectionModel.component_style.padding_bottom;
    
    CGFloat minimumLineSpacing = sectionModel.sectionMinimumLineSpacing;
    CGFloat rowCount = sectionModel.sectionItemCount / 2;
    CGFloat remainder = sectionModel.sectionItemCount % 2;
    if (remainder > 0) {
        rowCount += 1;
    }
    unsigned long long bgColorHeight = topMagin + sectionModel.sectionItemSize.height * ceil(rowCount) + minimumLineSpacing * (ceil(rowCount) - 1) + bottomMagin - (padding_bottom + padding_top);
    
    UIView *sectionBgColorView = [[UIView alloc] init];
    sectionBgColorView.frame = CGRectMake(0, sectionY-topMagin + padding_top, KScreenWidth, ceil(bgColorHeight)+1);
    
    //是否显示整体样式，1显示整体样式，0显示单个样式
    if (sectionModel.component_style.box_is_whole == 1) {
        UIView *whitewBorderView = [[UIView alloc] init];
        whitewBorderView.frame = CGRectMake(12, 12, KScreenWidth-12*2, ceil(bgColorHeight)-(12*2));
        whitewBorderView.backgroundColor = ZFCOLOR_WHITE;
        whitewBorderView.layer.cornerRadius = sectionModel.component_style.bg_radius;
        whitewBorderView.layer.masksToBounds = YES;
        [sectionBgColorView addSubview:whitewBorderView];
    }
    [self.collectionView insertSubview:sectionBgColorView atIndex:0];
    NSString *hexColor = sectionModel.component_style.bg_color;
    sectionBgColorView.backgroundColor = [UIColor colorWithAlphaHexColor:hexColor defaultColor:ZFCOLOR_WHITE];
    [self.sectionBgColorViewArr addObject:sectionBgColorView];
    
    //YWLog(@"平铺模式添加背景色====%@", self.sectionBgColorViewArr);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self convertSectionBgColorView:YES];
    });
}

- (void)convertSectionBgColorView:(BOOL)show {
    for (UIView *bgColorView in self.sectionBgColorViewArr) {
        if ([bgColorView isKindOfClass:[UIView class]]) {
            if (show) {
                [self.collectionView insertSubview:bgColorView atIndex:0];
            } else {
                [bgColorView removeFromSuperview];
            }
        }
    }
    if (!show) {
        [self.sectionBgColorViewArr removeAllObjects];
    }
}

#pragma mark - <ZFInitViewProtocol>

- (NSMutableArray<ZFGeshopSectionModel *> *)sectionModelArr {
    if (!_sectionModelArr) {
        _sectionModelArr = [NSMutableArray array];
    }
    return _sectionModelArr;
}

- (NSMutableArray *)sectionBgColorViewArr {
    if (!_sectionBgColorViewArr) {
        _sectionBgColorViewArr = [NSMutableArray array];
    }
    return _sectionBgColorViewArr;
}

- (void)zfInitView {
    [self addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (ZFGeshopFlowLayout *)geshopFlowLayout {
    if (!_geshopFlowLayout) {
        _geshopFlowLayout = [[ZFGeshopFlowLayout alloc] init];
        NSArray *classArray = @[
            [ZFGeshopNavigationCell class],[ZFGeshopSiftGoodsCell class]
        ];
        _geshopFlowLayout.stickyCellClassArray = classArray;////需要悬浮的Cell类型
    }
    return _geshopFlowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.geshopFlowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.alwaysBounceVertical = YES;
        //_collectionView.contentInset = UIEdgeInsetsMake(0, 0, kiphoneXHomeBarHeight, 0);
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self registerCollectionView:_collectionView];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

/** 注册页面用到的所有/Cell/类型 */
- (void)registerCollectionView:(UICollectionView *)collectionView {
    for (NSDictionary *cellDict in [ZFGeshopSectionModel fetchGeshopAllCellTypeArray]) {
        Class cellClass = cellDict.allValues.firstObject;
        if (![cellClass class]) continue;
        [collectionView registerClass:[cellClass class]  forCellWithReuseIdentifier:NSStringFromClass([cellClass class])];
    }
}

@end

