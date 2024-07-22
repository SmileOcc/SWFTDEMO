//
//  ZFAccountHistoryViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/4/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAccountHistoryViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFGoodsListItemCell.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFGoodsModel.h"
#import "ZFCellHeightManager.h"
#import "ZFDBManger.h"
#import "ZFThemeManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "ZFAccountHistoryAOP.h"

static NSInteger const kMargin = 12;
static NSString *const kZFHistoryListInfoCollectionViewCellIdentifier = @"kZFHistoryListInfoCollectionViewCellIdentifier";

@interface ZFAccountHistoryViewController () <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    NSInteger _dataOffsetIndex;
}

@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UICollectionViewFlowLayout        *flowLayout;
@property (nonatomic, strong) UICollectionView                  *collectionView;
@property (nonatomic, strong) NSMutableArray<ZFGoodsModel*>     *historyList;
@property (nonatomic, strong) ZFAccountHistoryAOP               *accountHistoryAOP;
@end

@implementation ZFAccountHistoryViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"History_View_Title", nil);
    [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.accountHistoryAOP];
    _dataOffsetIndex = 30;
    [self configNavigationBarItems];
    [self zfInitView];
    [self zfAutoLayoutView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getHistoryListInfo];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
#pragma mark - private methods
/*
 * 获取本地浏览历史数组
 */
- (void)getHistoryListInfo {
    NSArray *goodsDBS = [ZFGoodsModel selectAllGoods];
    if (goodsDBS.count > self.historyList.count) {
        [self.collectionView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    }
    self.historyList = [NSMutableArray arrayWithArray:goodsDBS];
    [self.collectionView reloadData];
    if (self.historyList.count <= 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView showRequestTip:@{}];
            self.collectionView.alwaysBounceVertical = NO;
        });
    }
}

- (CGFloat)queryCellHeightWithModel:(NSInteger)index {
    CGFloat cellHeight = 0.0f;
    
    // 获取模型数据
    ZFGoodsModel *model = self.historyList[index];
    
    // 获取缓存高度
    cellHeight = [[ZFCellHeightManager shareManager] queryHeightWithModelHash:model.goods_id.hash];
    
    if (cellHeight < 0) { // 没有缓存高度
        // 计算并保存高度
        cellHeight = [[ZFCellHeightManager shareManager] calculateCellHeightWithTagsArrayModel:model];
    }
    return cellHeight;
}

#pragma mark - event response
- (void)clearHistory {
    [ZFGoodsModel deleteAllGoods];
    [self getHistoryListInfo];
    self.clearButton.enabled = [ZFGoodsModel selectAllGoods].count > 0;
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.historyList.count > _dataOffsetIndex ? _dataOffsetIndex : self.historyList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsListItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFHistoryListInfoCollectionViewCellIdentifier forIndexPath:indexPath];
    ZFGoodsModel *model = self.historyList[indexPath.item];
    cell.goodsModel = model;
    [self register3DTouchAlertWithDelegate:collectionView sourceView:cell goodsModel:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//    ZFGoodsListItemCell *cell = (ZFGoodsListItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    ZFGoodsModel *goodsModel = [self.historyList objectAtIndex:indexPath.item];
    ZFGoodsDetailViewController *goodsDetailViewController = [[ZFGoodsDetailViewController alloc] init];
    goodsDetailViewController.goodsId = goodsModel.goods_id;
    goodsDetailViewController.sourceType = ZFAppsflyerInSourceTypeAccountRecentviewedProduct;
//    goodsDetailViewController.transformSourceImageView = cell.goodsImageView;
//    self.navigationController.delegate = goodsDetailViewController;
    [self.navigationController pushViewController:goodsDetailViewController animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    static CGFloat cellHeight = 0.0f;
    if (indexPath.item % 2 == 0) {
        // 获取当前cell高度
        CGFloat currentCellHeight = [self queryCellHeightWithModel:indexPath.item];
        cellHeight = currentCellHeight;
        
        if (indexPath.item + 1 < self.historyList.count) {
            // 获取下一个cell高度
            CGFloat nextCellHeight = [self queryCellHeightWithModel:indexPath.item + 1];
            cellHeight = currentCellHeight > nextCellHeight ? currentCellHeight : nextCellHeight;
        }
    }
    return CGSizeMake((KScreenWidth - 3 * kMargin) / 2, cellHeight);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSIndexPath *lastVisibleIndexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(0.0 + kMargin * 2, scrollView.contentOffset.y + scrollView.height - kMargin * 2)];
    if (lastVisibleIndexPath.item >= (_dataOffsetIndex - 11)) {
        _dataOffsetIndex += 30;
        [self.collectionView reloadData];
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)configNavigationBarItems {
    UIButton *clearBtn                     = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBtn.frame                         = CGRectMake(0.0, 0.0, 44.0, 44.0);
    [clearBtn setImage:[UIImage imageNamed:@"account_history_delete"] forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearHistory) forControlEvents:UIControlEventTouchUpInside];
    clearBtn.imageEdgeInsets               = UIEdgeInsetsMake(0.0, 10.0, 0.0, -5.0);
    clearBtn.adjustsImageWhenHighlighted   = NO;
    UIBarButtonItem *clearItem             = [[UIBarButtonItem alloc] initWithCustomView:clearBtn];
    self.navigationItem.rightBarButtonItem = clearItem;
    self.clearButton                       = clearBtn;
    self.clearButton.enabled = [ZFGoodsModel selectAllGoods].count > 0;
}

#pragma mark - getter
- (NSMutableArray<ZFGoodsModel *> *)historyList {
    if (!_historyList) {
        _historyList = [NSMutableArray array];
    }
    return _historyList;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumInteritemSpacing = kMargin;
        _flowLayout.minimumLineSpacing      = 0.0;
        _flowLayout.sectionInset = UIEdgeInsetsMake(kMargin, kMargin, kMargin, kMargin);
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.emptyDataImage = [UIImage imageNamed:@"blankPage_noCart"];
        _collectionView.emptyDataTitle = ZFLocalizedString(@"MyHistory_NoData_tip", nil);
        [_collectionView registerClass:[ZFGoodsListItemCell class] forCellWithReuseIdentifier:kZFHistoryListInfoCollectionViewCellIdentifier];
    }
    return _collectionView;
}

-(ZFAccountHistoryAOP *)accountHistoryAOP {
    if (!_accountHistoryAOP) {
        _accountHistoryAOP = [[ZFAccountHistoryAOP alloc] init];
    }
    return _accountHistoryAOP;
}

@end
