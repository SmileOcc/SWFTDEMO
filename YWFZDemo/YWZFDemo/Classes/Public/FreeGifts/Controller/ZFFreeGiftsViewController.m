
//
//  ZFFreeGiftsViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/5/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFFreeGiftsViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFFreeGiftsViewModel.h"
#import "ZFCollectionViewModel.h"
#import "ZFFreeGiftListModel.h"
#import "ZFFreeGiftCollectionHeaderView.h"
#import "ZFFreeGiftCollectionViewCell.h"
#import "ZFEmtpySepareFooterView.h"
#import "ZFGoodsDetailViewController.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "ZFRequestModel.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFGrowingIOAnalytics.h"

static NSString *const kZFFreeGiftCollectionHeaderViewIdentifier = @"kZFFreeGiftCollectionHeaderViewIdentifier";
static NSString *const kZFFreeGiftCollectionViewCellIdentifier   = @"kZFFreeGiftCollectionViewCellIdentifier";
static NSString *const kZFEmtpySepareFooterViewIdentifier        = @"kZFEmtpySepareFooterViewIdentifier";

@interface ZFFreeGiftsViewController () <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionViewFlowLayout                *flowLayout;
@property (nonatomic, strong) UICollectionView                          *collectionView;
@property (nonatomic, strong) NSMutableArray<ZFFreeGiftListModel *>     *dataArray;
@property (nonatomic, strong) NSMutableArray *analyticsSet;

//统计
@property (nonatomic, strong) ZFAnalyticsProduceImpression    *analyticsProduceImpression;

@end

@implementation ZFFreeGiftsViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNavigationBar];
    [self zfInitView];
    [self zfAutoLayoutView];
    [self requestFreeGiftListInfo];
}

- (void)dealloc
{
    YWLog(@"ZFFreeGiftsViewController dealloc");
}

#pragma mark - action methods
/**
 * 弹框提示信息。
 */
- (void)freeGiftTipsAction:(UIButton *)sender {
    
    NSString *title = ZFLocalizedString(@"FreeGift",nil);
    NSString *message = ZFLocalizedString(@"FreeGift_Rule_Content",nil);
    NSString *cancelTitle = ZFLocalizedString(@"SettingViewModel_Version_Latest_Alert_OK",nil);
    ShowAlertSingleBtnView(title, message, cancelTitle);
}

#pragma mark - private methods
/*
 * 请求赠品列表信息
 */
- (void)requestFreeGiftListInfo {
    ShowLoadingToView(self.view);
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_freeGift);
    requestModel.parmaters = @{
                               ZFApiSessId  : ZFToString(SESSIONID)
                               };
    @weakify(self)
    [ZFFreeGiftsViewModel requestFreeGiftListNetwork:requestModel completion:^(NSMutableArray *dataArray) {
        @strongify(self)
        HideLoadingFromView(self.view);
        self.dataArray = dataArray;
        [self.collectionView reloadData];
        [self.collectionView showRequestTip:@{}];
        for (ZFFreeGiftListModel *model in self.dataArray) {
            [ZFAnalytics showProductsWithProducts:model.goods_list position:1 impressionList:ZFGAFreeGiftsList screenName:@"freeGifs" event:nil];
            //occ v3.7.0hacker 添加 ok
            self.analyticsProduceImpression = [ZFAnalyticsProduceImpression initAnalyticsProducePosition:1 impressionList:ZFGAFreeGiftsList screenName:@"freeGifs" event:@""];
        }
    } failure:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);
        [self.collectionView reloadData];
        [self.collectionView showRequestTip:nil];
    }];
}

/**
 * 添加/取消收藏商品
 * type = 0/1 0添加 1取消
 */
- (void)requestFreeGiftGoodsCollect:(BOOL)isCollect
                         goodsModel:(ZFFreeGiftGoodsModel *)goodsModel
                        atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"type"] = isCollect ? @"0" : @"1";
    dict[@"goods_id"] = ZFToString(goodsModel.goods_id);
    
    @weakify(self);
    [ZFCollectionViewModel requestCollectionGoodsNetwork:dict completion:^(BOOL isOK) {
        @strongify(self);
        if (isOK) {
            goodsModel.is_collect = [NSString stringWithFormat:@"%d", ![goodsModel.is_collect boolValue]];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        } else {
            ShowToastToViewWithText(self.view, ZFLocalizedString(@"Failed", nil));
        }
    } target:self];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray[section].goods_list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFFreeGiftCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFFreeGiftCollectionViewCellIdentifier forIndexPath:indexPath];
    ZFFreeGiftListModel *listModel = self.dataArray[indexPath.section];
    ZFFreeGiftGoodsModel *goodsModelel = listModel.goods_list[indexPath.row];
    goodsModelel.isShowCollectButton = YES;
    cell.model = goodsModelel;
    @weakify(self);
    cell.freeGiftCollectCompletionHandler = ^(BOOL isCollect) {
        @strongify(self);
        [self requestFreeGiftGoodsCollect:isCollect goodsModel:goodsModelel atIndexPath:indexPath];
    };
    // 统计
    if (![self.analyticsSet containsObject:ZFToString(goodsModelel.goods_id)]) {
        [self.analyticsSet addObject:ZFToString(goodsModelel.goods_id)];
        ZFGoodsModel *model = [ZFGoodsModel new];
        model.goods_id = goodsModelel.goods_id;
        model.goods_sn = goodsModelel.goods_sn;
        [ZFAppsflyerAnalytics trackGoodsList:@[model] inSourceType:ZFAppsflyerInSourceTypeFreeGift AFparams:nil];
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:model page:GIOSourceCartFreeGifts];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        ZFFreeGiftCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFFreeGiftCollectionHeaderViewIdentifier forIndexPath:indexPath];
        headerView.model = self.dataArray[indexPath.section];
        return headerView;
    } else if (kind == UICollectionElementKindSectionFooter) {
        ZFEmtpySepareFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kZFEmtpySepareFooterViewIdentifier forIndexPath:indexPath];
        return footerView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    //获取对应model 跳转ZFGoodsDetailViewController
    ZFFreeGiftGoodsModel *model = self.dataArray[indexPath.section].goods_list[indexPath.row];
    if (model.is_full) {
        ZFFreeGiftCollectionViewCell *cell = (ZFFreeGiftCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
        detailVC.freeGiftId = model.manzeng_id;
        detailVC.goodsId = model.goods_id;
        detailVC.transformSourceImageView = cell.goodsImageView;
        detailVC.sourceType = ZFAppsflyerInSourceTypeFreeGift;
        //occ v3.7.0hacker 添加 ok
        detailVC.analyticsProduceImpression = self.analyticsProduceImpression;
        self.navigationController.delegate = detailVC;
        [self.navigationController pushViewController:detailVC animated:YES];
        [ZFAnalytics clickProductWithProduct:model position:1 actionList:ZFGAFreeGiftsList];
        
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(model.goods_sn),
                                          @"af_spu_id" : ZFToString(model.goods_spu),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"freegifts_page",    // 当前页面名称
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
        
        [ZFGrowingIOAnalytics ZFGrowingIOProductClick:model page:GIOSourceCartFreeGifts sourceParams:@{
            GIOGoodsTypeEvar : GIOGoodsTypeOther,
            GIOGoodsNameEvar : @"gift_product"
        }];
    } else {
        ShowToastToViewWithText(self.view, self.dataArray[indexPath.section].sub_title);
    }
    
}

#pragma mark - <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(KScreenWidth, 80);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(KScreenWidth, section == self.dataArray.count - 1 ? 0 : 12);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (KScreenWidth - 36) * 0.5;
    CGFloat cellHeight = (width / KImage_SCALE)+ 75;
    NSInteger goodsListCount = self.dataArray[indexPath.section].goods_list.count;
    ZFFreeGiftGoodsModel *model = self.dataArray[indexPath.section].goods_list[indexPath.row];
    BOOL needTagsHeight = model.tagsArray.count > 0;
    NSInteger nextOrPrevIndex = indexPath.row % 2 ? -1 : indexPath.row + 1 < goodsListCount ? 1 : 0;
    needTagsHeight |= self.dataArray[indexPath.section].goods_list[indexPath.row + nextOrPrevIndex].tagsArray.count > 0;
    return CGSizeMake(width, cellHeight - !needTagsHeight * 24);
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

- (void)configNavigationBar {
    self.title = ZFLocalizedString(@"FreeGift", nil);
    self.view.backgroundColor = ZFCOLOR_WHITE;
    UIButton *tipsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tipsButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
    [tipsButton setImage:[UIImage imageNamed:@"community_AccountHelp"] forState:UIControlStateNormal];
    [tipsButton addTarget:self action:@selector(freeGiftTipsAction:) forControlEvents:UIControlEventTouchUpInside];
    tipsButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, -5.0);
    UIBarButtonItem *tipsButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tipsButton];
    self.navigationItem.rightBarButtonItem = tipsButtonItem;
}

#pragma mark - getter
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 12;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[ZFFreeGiftCollectionViewCell class] forCellWithReuseIdentifier:kZFFreeGiftCollectionViewCellIdentifier];
        [_collectionView registerClass:[ZFFreeGiftCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFFreeGiftCollectionHeaderViewIdentifier];
        [_collectionView registerClass:[ZFEmtpySepareFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kZFEmtpySepareFooterViewIdentifier];
        
        _collectionView.emptyDataImage = ZFImageWithName(@"blankPage_noCart");
        _collectionView.emptyDataTitle = ZFLocalizedString(@"FreeGiftsVC_HasNoDataTips", nil);
    }
    return _collectionView;
}

- (NSMutableArray<ZFFreeGiftListModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)analyticsSet {
    if (!_analyticsSet) {
        _analyticsSet = [NSMutableArray array];
    }
    return _analyticsSet;
}

@end

