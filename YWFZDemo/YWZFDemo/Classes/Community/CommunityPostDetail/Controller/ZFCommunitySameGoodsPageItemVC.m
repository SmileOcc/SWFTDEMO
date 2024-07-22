//
//  ZFCommunitySameGoodsPageItemVC.m
//  ZZZZZ
//
//  Created by YW on 2018/6/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunitySameGoodsPageItemVC.h"
#import "ZFCommunitySameGoodsCCell.h"
#import "ZFCommunityPostSameGoodsViewModel.h"
#import "ZFListGoodsNumberHeaderView.h"
#import "ZFGoodsDetailViewController.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "ZFGoodsModel.h"
#import "ZFPiecingOrderViewModel.h"
#import "ZFCommunityGoodsInfosModel.h"
#import "YWCFunctionTool.h"
#import "ZFCommunityGoodsOperateViewModel.h"
#import "ZFGrowingIOAnalytics.h"

#define kTheSameGoodsCellIdentifer   @"kTheSameGoodsCellIdentifer"

@interface ZFCommunitySameGoodsPageItemVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *theSameCollectionView;
@property (nonatomic, strong) ZFCommunityPostSameGoodsViewModel *viewModel;

///保存统计推荐商品的属性
@property (nonatomic, strong) NSArray *analyticsGoodsList;

@end

@implementation ZFCommunitySameGoodsPageItemVC

- (instancetype)initWithReviewID:(NSString *)reviewID {
    if (self = [super init]) {
        self.reviewID = reviewID;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = ZFLocalizedString(@"Community_post_all_Items", nil);
    self.viewModel = [[ZFCommunityPostSameGoodsViewModel alloc] init];
    [self.view addSubview:self.theSameCollectionView];
}

#pragma mark - 网络请求
- (void)requestSameGoodsData:(BOOL)isFirstpage {
    @weakify(self)
    [self.viewModel requestTheSameGoodsWithReviewID:self.reviewID
                                        isFirstPage:isFirstpage
                                              catId:self.catId
                                     finishedHandle:^(NSDictionary *pageInfo){
                                         @strongify(self)
                                         [self.theSameCollectionView reloadData];
                                         [self.theSameCollectionView showRequestTip:pageInfo];
                                         [self.viewModel showAnalysicsWithCateName:self.cateName];
                                         
                                         if (self.viewModel.goodsInfoArray.count > 0) {
                                             [self addSimilarkAnalytics];
                                         }
                                     }];
}

/**
 * 统计相似商品列表
 */
- (void)addSimilarkAnalytics {
    if (self.viewModel.goodsInfoArray.count <= 0) {
        return;
    }
    
    NSMutableString *goodsns = [[NSMutableString alloc] init];
    NSMutableArray <ZFGoodsModel *> *tempGoodsModelArray = [[NSMutableArray alloc] init];
    for (ZFCommunityGoodsInfosModel *model in self.viewModel.goodsInfoArray) {
        ZFGoodsModel *goodsModel = [self goodsInfoModelAdapterToGoodsModel:model];
        [tempGoodsModelArray addObject:goodsModel];
        [goodsns appendFormat:@"%@,", goodsModel.goods_sn];
    }
    
    //这里要通过商品id获取一波商品的具体详情，因为 社区接口不能获取到商品的多级分类属性
    @weakify(self)
    [ZFPiecingOrderViewModel requestHandpickGoodsList:goodsns completion:^(NSArray<ZFGoodsModel *> *goodsModelArray) {
        self.analyticsGoodsList = goodsModelArray;
        @strongify(self)
        [goodsModelArray enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.af_rank = idx + 1;
            [ZFGrowingIOAnalytics ZFGrowingIOProductShow:obj page:@"post_all_item"];
        }];
        
        [ZFAppsflyerAnalytics trackGoodsList:goodsModelArray inSourceType:ZFAppsflyerInSourceTypeZMeAllSimilarList sourceID:self.reviewID];
        
    }];
}

- (ZFGoodsModel *)goodsInfoModelAdapterToGoodsModel:(ZFCommunityGoodsInfosModel *)infoModel {
    ZFGoodsModel *goodsModel = [ZFGoodsModel new];
    goodsModel.goods_id      = infoModel.goodsId;
    goodsModel.goods_sn      = infoModel.goods_sn;
    goodsModel.goods_title   = infoModel.goodsTitle;
    return goodsModel;
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.viewModel dataCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunitySameGoodsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTheSameGoodsCellIdentifer forIndexPath:indexPath];
    [cell setGoodsTitle:[self.viewModel goodsTitleWithIndex:indexPath.item]];
    [cell setGoodsImageURL:[self.viewModel goodsImageWithIndex:indexPath.item]];
    [cell setGoodsPirce:[self.viewModel goodsPriceWithIndex:indexPath.item]];
    [cell setGoodsIsSame:[self.viewModel isTheSameWithIndex:indexPath.item]];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0, 12.0, 12.0, 12.0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel cellSizeWithIndex:indexPath.item];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ZFListGoodsNumberHeaderView *headView = [ZFListGoodsNumberHeaderView headWithCollectionView:collectionView Kind:kind IndexPath:indexPath];
    if ([kind isEqualToString: UICollectionElementKindSectionHeader] ) {
        NSInteger totalCount = [self.viewModel totalCount];
        if (self.viewModel && totalCount>0) {
            headView.item = [NSString stringWithFormat:ZFLocalizedString(@"list_item", nil), [NSString stringWithFormat:@"%zd", totalCount]];
        }
    }
    return headView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return  CGSizeMake(KScreenWidth, 36);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsDetailViewController *goodsDetailViewController = [[ZFGoodsDetailViewController alloc] init];
    goodsDetailViewController.goodsId = [self.viewModel goodsIDWithIndex:indexPath.item];
    //occ v3.7.0hacker 添加 ok
    goodsDetailViewController.analyticsProduceImpression = self.viewModel.analyticsProduceImpression;
    goodsDetailViewController.sourceType = ZFAppsflyerInSourceTypeZMeAllSimilarList;
    goodsDetailViewController.sourceID = ZFToString(self.catId);
    [self.navigationController pushViewController:goodsDetailViewController animated:YES];
    [self.viewModel clickAnalysicsWithCateName:self.cateName index:indexPath.row];
    
    // appflyer统计
    NSString *goods_sn = [self.viewModel goodsSNWithIndex:indexPath.item];
    NSString *spuSN = @"";
    if (goods_sn.length > 7) {  // sn的前7位为同款id
        spuSN = [goods_sn substringWithRange:NSMakeRange(0, 7)];
    }else{
        spuSN = goods_sn;
    }
    NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goods_sn),
                                      @"af_spu_id" : ZFToString(spuSN),
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"post_all_item",    // 当前页面名称
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
    
    // 请求统计商品点击
    [ZFCommunityGoodsOperateViewModel requestGoodsTap:@{@"reviewId":ZFToString(self.reviewID),
                                                        @"goods_sku":ZFToString(goods_sn)} completion:nil];
    
    ZFGoodsModel *goodsModel = [ZFGoodsModel new];
    goodsModel.goods_id = [self.viewModel goodsIDWithIndex:indexPath.item];
    goodsModel.goods_sn = goods_sn;
    goodsModel.goods_title = [self.viewModel goodsTitleWithIndex:indexPath.item];
    [ZFGrowingIOAnalytics ZFGrowingIOProductClick:goodsModel page:@"post_all_item" sourceParams:@{
        GIOGoodsTypeEvar : GIOGoodsTypeCommunity,
        GIOGoodsNameEvar : @"similar_products"
    }];
}

#pragma mark - getter/setter
- (UICollectionView *)theSameCollectionView {
    if (!_theSameCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 0.0;
        _theSameCollectionView    = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _theSameCollectionView.backgroundColor      = [UIColor whiteColor];
        _theSameCollectionView.delegate             = self;
        _theSameCollectionView.dataSource           = self;
        _theSameCollectionView.alwaysBounceVertical = YES;
        _theSameCollectionView.autoresizingMask     = UIViewAutoresizingFlexibleHeight;
        _theSameCollectionView.emptyDataImage = [UIImage imageNamed:@"blankPage_requestFail"];
        _theSameCollectionView.emptyDataTitle = ZFLocalizedString(@"Search_ResultViewModel_Tip",nil);
        
        [_theSameCollectionView registerClass:[ZFCommunitySameGoodsCCell class] forCellWithReuseIdentifier:kTheSameGoodsCellIdentifer];
        [_theSameCollectionView registerClass:[_theSameCollectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([_theSameCollectionView class])];
        
        if (@available(iOS 11.0, *)) {
            _theSameCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        @weakify(self)
        [_theSameCollectionView addHeaderRefreshBlock:^{
            @strongify(self)
            [self requestSameGoodsData:YES];
            
        } footerRefreshBlock:^{
            @strongify(self)
            [self requestSameGoodsData:NO];
            
        } startRefreshing:YES];
    }
    return _theSameCollectionView;
}

@end
