//
//  STLAccountHistoryListView.m
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVAccountsGoodsListsView.h"
#import "OSSVRecomendGoodViewModel.h"
#import "OSSVHomesHistrysViewModel.h"

#import "OSSVHomeItemssCell.h"

#import "OSSVAccountsGoodsAnalyseAP.h"
#import "OSSVAccountsFastsAddItemsCell.h"
#import "OSSVDetailsViewModel.h"
#import "STLActionSheet.h"
#import "OSSVDetailsVC.h"
#import "STLProductListSkeletonView.h"
@interface OSSVAccountsGoodsListsView () <
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    CHTCollectionViewDelegateWaterfallLayout,
    STLAccountFastAddItemDelegate
>
@property (nonatomic, strong) NSMutableArray                 *tableDataArray;
@property (nonatomic, assign) AccountGoodsListType           dataType;
@property (nonatomic, assign) BOOL                          cellCanScroll;

@property (nonatomic, strong) CHTCollectionViewWaterfallLayout *waterFallLayout;

@property (nonatomic, strong) OSSVRecomendGoodViewModel       *recommendModel;
@property (nonatomic, strong) OSSVHomesHistrysViewModel             *historyViewModel;
@property (nonatomic, assign) BOOL                             hasRequest;
@property (nonatomic, strong) OSSVAccountsGoodsAnalyseAP      *accountAnalyticsManager;

@property (nonatomic,strong) OSSVDetailsViewModel *baseInfoModel;
@property (nonatomic,strong) STLActionSheet *detailSheet;
@property (nonatomic, strong) STLProductListSkeletonView          *productSkeletonView; //骨架图

@end

@implementation OSSVAccountsGoodsListsView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame dataType:(AccountGoodsListType)dataType {
    self = [super initWithFrame:frame];
    if (self) {
        self.dataType = dataType;
        [[OSSVAnalyticInjectsManager shareInstance] analyticsInject:self injectObject:self.accountAnalyticsManager];

        [self stlInitView];
        
        if (self.dataType == AccountGoodsListTypeRecommend) {
            [self requestAccountRecommendData:YES];
            
        } else if (self.dataType == AccountGoodsListTypeHistory) {
            [self refreshRecentlyData];
        }
        
        [self addNotification];
    }
    return self;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSubCanScrollStatus:) name:kNotif_AccountGoodsSubScrollStatus object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveChangeCurrency) name:kNotif_Currency object:nil];
}

- (void)receiveChangeCurrency {
    [self.collectionView reloadData];
}

- (void)startFirstRequest {
    if (self.dataType == AccountGoodsListTypeRecommend) {
        if (!self.hasRequest) {
            [self requestAccountRecommendData:YES];
        }
    }
    
}

- (BOOL)collectionViewScrollsTopState {
    return self.collectionView.scrollsToTop;
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataType == AccountGoodsListTypeRecommend) {
        return self.recommendModel.dataArrays.count;
    }
    return self.tableDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OSSVAccountsFastsAddItemsCell *cell = [OSSVAccountsFastsAddItemsCell fastAddItemCellWithCollectionView:collectionView andIndexPath:indexPath];
    cell.addToCartDelegate = self;
    if (self.dataType == AccountGoodsListTypeRecommend) {
        if (self.recommendModel.dataArrays.count > indexPath.row) {
            cell.model = self.recommendModel.dataArrays[indexPath.row];
            return cell;
        }
    } else {
        if (self.tableDataArray.count > indexPath.row) {
            cell.commendModel = self.tableDataArray[indexPath.row];
            return cell;
        }
    }
    
    UICollectionViewCell *cc = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    return cc;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat height = 0.01;
    if (self.dataType == AccountGoodsListTypeHistory) {
//        height = [HomeItemCell homeItemRowHeightForHomeGoodListModel:nil];
        height = [OSSVHomeItemssCell homeItemRowHeightOneModel:nil twoModel:nil];
    } else if(self.recommendModel.dataArrays.count > indexPath.row) {
        
        //满减活动
        OSSVHomeGoodsListModel *oneModel = self.recommendModel.dataArrays[indexPath.row];
        OSSVHomeGoodsListModel *twoModel = nil;
        NSInteger count = indexPath.row % 2;
        if (count == 0) {
            if (self.recommendModel.dataArrays.count > indexPath.row+1) {
                twoModel = self.recommendModel.dataArrays[indexPath.row+1];
            }
        } else {
            if (indexPath.row > 0) {
                twoModel = self.recommendModel.dataArrays[indexPath.row-1];
            }
        }
        
        height = [OSSVHomeItemssCell homeItemRowHeightOneModel:oneModel twoModel:twoModel];

    }
    CGFloat tempW = kGoodsWidth;
    return CGSizeMake(tempW, height);
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, kMarginSpace12, 0, kMarginSpace12);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    if (self.dataType == AccountGoodsListTypeRecommend) {
        if (self.recommendModel.dataArrays.count > indexPath.row && self.selectedGoodsBlock) {
            if (self.selectedGoodsBlock) {
                self.selectedGoodsBlock(self.recommendModel.dataArrays[indexPath.row], AccountGoodsListTypeRecommend,indexPath.row, STLToString(self.accountAnalyticsManager.sourecDic[kAnalyticsRequestId]));
            }
        }
    } else if(self.dataType == AccountGoodsListTypeHistory) {
        
        if (self.tableDataArray.count > indexPath.row && self.selectedGoodsBlock) {
            if (self.selectedGoodsBlock) {
                self.selectedGoodsBlock(self.tableDataArray[indexPath.row], AccountGoodsListTypeHistory,indexPath.row,STLToString(self.accountAnalyticsManager.sourecDic[kAnalyticsRequestId]));
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"显示出：%@", @"ddd");

}


#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isEqual:self.collectionView]) return;
//    STLLog(@"子 表格滚动=2=====%.2f=====%d",scrollView.contentOffset.y, self.cellCanScroll);
    
    if (self.cellCanScroll) {
        if (scrollView.contentOffset.y <= 0) {
            self.collectionView.contentOffset = CGPointZero;
            [self sendSuperTabCanScroll:YES];
        } else {
            [self sendSuperTabCanScroll:NO];
        }
    } else {
        if (!scrollView.isDragging) {
            [self sendSuperTabCanScroll:YES];
        }
        self.collectionView.contentOffset = CGPointZero;
    }
}

- (void)sendSuperTabCanScroll:(BOOL)status {
    NSDictionary *dic = @{@"status":@(status) };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_AccountGoodsSupScrollStatus object:nil userInfo:dic];
    /// 设置点击状态栏滚到顶部
    self.collectionView.scrollsToTop = !status;
    

    // 如果父类设置为可以滚动时，子类都不滚动
    if (status) {        
        NSDictionary *dic = @{@"status":@(NO),
        @"type":@(self.dataType)};

        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_AccountGoodsSubScrollStatus object:nil userInfo:dic];
    }
}

- (void)setSubCanScrollStatus:(NSNotification *)notice {
    NSDictionary *dic = notice.userInfo;
    NSNumber *status = dic[@"status"];
    self.cellCanScroll = [status boolValue];

    // 把非当前选中的页面全部置顶
    NSNumber *type = dic[@"type"];
    if ([type intValue] != self.dataType && ![status boolValue]) {
        self.collectionView.contentOffset = CGPointZero;
    }
    
    
}

- (void)resetPageIndexToFirst {
    //self.viewModel.pageIndex = 1;
    [self requestAccountRecommendData:YES];
}


- (void)stlInitView {
    self.backgroundColor = [OSSVThemesColors col_F5F5F5];
    [self addSubview:self.collectionView];
    [self.collectionView addSubview:self.productSkeletonView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    self.productSkeletonView.frame = self.collectionView.frame;
}

- (NSMutableArray *)tableDataArray {
    if (!_tableDataArray) {
        _tableDataArray = [NSMutableArray array];
    }
    return _tableDataArray;
}

/// 个人中心显示推荐商品 -> (分页)
- (void)requestAccountRecommendData:(BOOL)isFirstPage {
    if (isFirstPage && self.recommendModel.dataArrays <= 0) {
        self.productSkeletonView.hidden = NO;
    }
    @weakify(self)
    [self.recommendModel recommendRequest:nil completion:^(id obj,NSString *requestId) {
        @strongify(self)
        self.hasRequest = YES;
        if (isFirstPage) {
            [self.recommendModel.dataArrays removeAllObjects];
        }

        if (STLJudgeNSArray(obj)) {
            [self.recommendModel.dataArrays addObjectsFromArray:obj];
        }
        [self.collectionView reloadData];
        
        self.collectionView.backgroundView = nil;

        [self.collectionView showRequestTip:@{}];
        self.productSkeletonView.hidden = YES;
        
        self.accountAnalyticsManager.sourecDic = [@{kAnalyticsRequestId:STLToString(requestId)} mutableCopy];
        ///test recommend
//        self.accountAnalyticsManager.sourecDic = [@{kAnalyticsRequestId:STLToString(@"request_id_from_usercenter")} mutableCopy];
        
    } failure:^(id obj) {
        @strongify(self)

        [self.collectionView reloadData];
        [self.collectionView showRequestTip:nil];
        self.productSkeletonView.hidden =  YES;

    }];
}

/// 个人中心显示浏览历史记录
- (void)refreshRecentlyData {
    self.productSkeletonView.hidden = NO;
    @weakify(self)
    [self.historyViewModel requestNetwork:@[STLToString(@""),STLRefresh] completion:^(id obj) {
        @strongify(self)
        self.hasRequest = YES;
        self.tableDataArray = [NSMutableArray arrayWithArray:self.historyViewModel.dataArray];
        [self.collectionView reloadData];
        self.collectionView.backgroundView = nil;
        //没有加载更多
        [self.collectionView showRequestTip:@{}];
        self.productSkeletonView.hidden = YES;
        
    } failure:^(id obj) {
        @strongify(self)
        [self.collectionView reloadData];
        self.productSkeletonView.hidden = YES;
    }];
}

#pragma mark - <STLInitUI>

- (CHTCollectionViewWaterfallLayout *)waterFallLayout {
    if (!_waterFallLayout) {
        _waterFallLayout = [[CHTCollectionViewWaterfallLayout alloc] init];
        _waterFallLayout.columnCount = 2;
        _waterFallLayout.minimumColumnSpacing = 12;
        _waterFallLayout.minimumInteritemSpacing = 12;
        _waterFallLayout.headerHeight = 12;
        _waterFallLayout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);

    }
    return _waterFallLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.waterFallLayout];
        _collectionView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        if (APP_TYPE == 3) {
            _collectionView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        }
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = NO;
        
        UIView *view = [[UIView alloc] init];
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loadingView.hidesWhenStopped = YES;
        loadingView.color = [UIColor grayColor];
        [loadingView startAnimating];
        UIView *loading = loadingView;
        
        loading.center = CGPointMake(self.center.x, self.center.y - 150);
        [view addSubview:loading];
        _collectionView.backgroundView = view;
        _collectionView.blankPageTipViewOffsetY = 100;
        
        if (self.dataType == AccountGoodsListTypeRecommend) {
            @weakify(self)
            _collectionView.mj_footer = [OSSVRefreshsFooter footerWithRefreshingBlock:^{
                @strongify(self)
                [self requestAccountRecommendData:NO];
            }];
            _collectionView.mj_footer.hidden = YES;
        }
        
        _collectionView.blankPageImageViewTopDistance = 40;
       
        
        if (self.dataType == AccountGoodsListTypeRecommend) {
            
            _collectionView.emptyDataBtnTitle = APP_TYPE == 3 ? STLLocalizedString_(@"retry", nil) : [STLLocalizedString_(@"retry", nil) uppercaseString];
            _collectionView.emptyDataTitle    = STLLocalizedString_(@"EmptyCustomViewHasNoData_titleLabel",nil);

            @weakify(self)
            _collectionView.blankPageViewActionBlcok = ^(STLBlankPageViewStatus status) {
                @strongify(self)
//                [HUDManager showLoadingOnTarget:self];
                [self requestAccountRecommendData:YES];
            };
        } else {
           
            _collectionView.emptyDataImage    = [UIImage imageNamed:@"recently_data_bank"];
            _collectionView.emptyDataTitle = STLLocalizedString_(@"AccountRecently_NoData_titleLabel", nil);
            _collectionView.networkErrorImage = [UIImage imageNamed:@"recently_data_bank"];
            _collectionView.networkErrorTitle = STLLocalizedString_(@"AccountRecently_NoData_titleLabel",nil);
        }
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    }
    return _collectionView;
}

// 骨架图
- (STLProductListSkeletonView *)productSkeletonView {
    if (!_productSkeletonView) {
        _productSkeletonView = [[STLProductListSkeletonView alloc] init];
        _productSkeletonView.hidden = YES;
    }
    return _productSkeletonView;
}

- (OSSVRecomendGoodViewModel *)recommendModel {
    if (!_recommendModel) {
        _recommendModel = [[OSSVRecomendGoodViewModel alloc] init];
    }
    return _recommendModel;
}

- (OSSVHomesHistrysViewModel *)historyViewModel {
    if (!_historyViewModel) {
        _historyViewModel = [OSSVHomesHistrysViewModel new];
    }
    return _historyViewModel;
}

- (OSSVAccountsGoodsAnalyseAP *)accountAnalyticsManager {
    if (!_accountAnalyticsManager) {
        _accountAnalyticsManager = [[OSSVAccountsGoodsAnalyseAP alloc] init];
        _accountAnalyticsManager.source = self.dataType == AccountGoodsListTypeHistory ?  STLAppsflyerGoodsSourceHistory : STLAppsflyerGoodsSourceAccountRecommend;
    }
    return _accountAnalyticsManager;
}

-(void)fastAddItemCell:(OSSVAccountsFastsAddItemsCell *)cell addToCart:(NSDictionary *)item {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    self.detailSheet.analyticsDic = @{
        kAnalyticsPositionNumber:@(indexPath.row+1),
        kAnalyticsRequestId:STLToString(self.accountAnalyticsManager.sourecDic[kAnalyticsRequestId]),
    }.mutableCopy;
    ///1.3.8 展示快速加购
    [self requesData:item[@"goodsId"] wid:item[@"wid"]];
    self.detailSheet.screenGroup = @"Me_Pop-ups_";
    self.detailSheet.position    = @"Me_Pop-ups";
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"item_pop_ups" parameters:@{@"screen_group" : @"Me",
                                                                        @"position"     : @"Me",
                                                                        @"content"      : STLToString(item[@"goodsTitle"])
    }];

}


- (OSSVDetailsViewModel *)baseInfoModel {
    if (!_baseInfoModel) {
        _baseInfoModel = [[OSSVDetailsViewModel alloc] init];
    }
    return _baseInfoModel;
}

- (void)requesData:(NSString*)goodsId wid:(NSString*)wid {
    self.superview.superview.superview.userInteractionEnabled = NO;
    @weakify(self)
    NSDictionary *dic = dic = @{@"goods_id":STLToString(goodsId),
                                @"loadState":STLRefresh,
                                @"wid":STLToString(wid),
                                @"specialId":STLToString(@"")};
    [self.baseInfoModel requestGoodsListBaseInfo:dic completion:^(OSSVDetailsBaseInfoModel *obj) {
        self.superview.superview.superview.userInteractionEnabled = YES;
        @strongify(self)
        if (obj && [obj isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
            OSSVDetailsBaseInfoModel *baseInfoModel = (OSSVDetailsBaseInfoModel *)obj;
            NSArray <OSSVSpecsModel *> *goods_specs = baseInfoModel.GoodsSpecs;
            for (OSSVSpecsModel *specModel in goods_specs) {
                specModel.isSelectSize = YES;
            }
            self.detailSheet.baseInfoModel = baseInfoModel;
            self.detailSheet.hadManualSelectSize = YES;
//            if (STLIsEmptyString(baseInfoModel.specialId) && baseInfoModel.flash_sale && !STLIsEmptyString(baseInfoModel.flash_sale.active_discount) && [baseInfoModel.flash_sale.active_discount floatValue] > 0) {
//                _detailSheet.hasFirtFlash = YES;
//            }else{
//                _detailSheet.hasFirtFlash = NO;
//            }
            
            [self.detailSheet addCartAnimationTop:0 moveLocation:CGRectZero showAnimation:NO];
            [self.viewController.tabBarController.view addSubview:self.detailSheet];
            [UIView animateWithDuration: 0.25 animations: ^{
                [self.detailSheet shouAttribute];
                self.detailSheet.sourceType = STLAppsflyerGoodsSourceFlashList;
                self.detailSheet.type = GoodsDetailEnumTypeAdd;
            } completion: nil];
            
        }
    } failure:^(id obj) {
        self.superview.superview.superview.userInteractionEnabled = YES;
    }];
}

- (void)requesData:(NSString*)goodsId wid:(NSString*)wid specialId:(NSString *)specialId{
    self.superview.superview.superview.userInteractionEnabled = NO;
    @weakify(self)
    NSDictionary *dic = dic = @{@"goods_id":STLToString(goodsId),
                                @"loadState":STLRefresh,
                                @"wid":STLToString(wid),
                                @"specialId":STLToString(specialId)};
    [self.baseInfoModel requestGoodsListBaseInfo:dic completion:^(OSSVDetailsBaseInfoModel *obj) {
        self.superview.superview.superview.userInteractionEnabled = YES;
        @strongify(self)
        if (obj && [obj isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
            OSSVDetailsBaseInfoModel *baseInfoModel = (OSSVDetailsBaseInfoModel *)obj;
            NSArray <OSSVSpecsModel *> *goods_specs = baseInfoModel.GoodsSpecs;
            for (OSSVSpecsModel *specModel in goods_specs) {
                specModel.isSelectSize = YES;
            }
            self.detailSheet.baseInfoModel = baseInfoModel;
            self.detailSheet.hadManualSelectSize = YES;
            
            [self.detailSheet addCartAnimationTop:0 moveLocation:CGRectZero showAnimation:NO];
            [self.viewController.tabBarController.view addSubview:self.detailSheet];
            [UIView animateWithDuration: 0.25 animations: ^{
                [self.detailSheet shouAttribute];
                self.detailSheet.sourceType = STLAppsflyerGoodsSourceFlashList;
                self.detailSheet.type = GoodsDetailEnumTypeAdd;
            } completion: nil];
            
        }
    } failure:^(id obj) {
        self.superview.superview.superview.userInteractionEnabled = YES;
    }];
}

- (STLActionSheet *)detailSheet {
    if (!_detailSheet) {
        CGFloat detailSheetY = kIS_IPHONEX? 88.f : 64.f;
        _detailSheet = [[STLActionSheet alloc] initWithFrame:CGRectMake(0, -detailSheetY, SCREEN_WIDTH, SCREEN_HEIGHT+detailSheetY)];
        _detailSheet.type = GoodsDetailEnumTypeAdd;
//        _detailSheet.hasFirtFlash = YES;
        _detailSheet.isListSheet = YES;
        _detailSheet.addCartType = 1;
        _detailSheet.showCollectButton = YES;
        _detailSheet.screenGroup = @"Me_Pop-ups_";
        _detailSheet.position    = @"Me_Pop-ups";
        @weakify(self)
        _detailSheet.cancelViewBlock = ^{   // cancel block
            
//            [self restoreTransform];
        };
        _detailSheet.attributeBlock = ^(NSString *goodsId,NSString *wid) {
            @strongify(self)
            [self requesData:goodsId wid:wid];
        };
        _detailSheet.attributeNewBlock = ^(NSString *goodsId, NSString *wid, NSString *specialId) {
            @strongify(self)
            [self requesData:goodsId wid:wid specialId:specialId];
        };
        
        _detailSheet.addCartEventBlock = ^(BOOL flag) {
            
        };
        
        _detailSheet.attributeHadManualSelectSizeBlock = ^{
            @strongify(self)
//            self.baseInfoModel.hadManualSelectSize = YES;
        };
        

        _detailSheet.goNewToDetailBlock = ^(NSString *goodsId, NSString *wid, NSString *specialId, NSString *goodsImageUrl) {
            @strongify(self)
            OSSVDetailsVC *detailVC = [[OSSVDetailsVC alloc] init];
            detailVC.goodsId = goodsId;
            detailVC.wid = wid;
            detailVC.specialId = specialId;
            
            if (self.dataType == AccountGoodsListTypeRecommend) {
                detailVC.sourceType = STLAppsflyerGoodsSourceAccountRecommend;

            } else if (self.dataType == AccountGoodsListTypeHistory) {
                detailVC.sourceType = STLAppsflyerGoodsSourceAccountHistory;
            }
            
            detailVC.coverImageUrl = STLToString(goodsImageUrl);
            [self.viewController.navigationController pushViewController:detailVC animated:YES];
            
            [self.detailSheet dismiss];
        };
    }
    return _detailSheet;
}
@end
