//
//  ZFGoodsDetailViewController.m
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailViewController.h"
#import "ZFGoodsDetailVCImportFiles.h"

@interface ZFGoodsDetailViewController ()<GoodsDetailVCActionProtocol, UINavigationControllerDelegate>
@property (nonatomic, strong) ZFGoodsDetailView         *goodsDetailView;
@property (nonatomic, strong) ZFGoodsDetailViewModel    *viewModel;
@end

@implementation ZFGoodsDetailViewController

- (void)dealloc {
    [_viewModel cancelAllDataTask];    
    /// 统计退出商详页面
    [ZFGoodsDetailAnalytics af_analyticsExitProduct:_viewModel.detailModel.goods_sn];
    
    ///取消延迟显示弹框时间
    [_goodsDetailView cancelHideAddCartPopViewAction];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.goodsDetailView refreshNavAndCartBage];
    
    if (self.transformSourceImageView) {
        self.navigationController.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //警告:从商详页面进入其他商详时应该清除动画图
    self.transformSourceImageView = nil;
    //[self.goodsDetailView hideAddCartInfoPopView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.playerView) {
        [self.playerView dissmissFromWindow];
    }
}

- (void)loadView {
    self.view = self.goodsDetailView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    showSystemStatusBar();
    self.fd_prefersNavigationBarHidden = YES;
    
    [self.view bringSubviewToFront:self.transformView];
    // 根据bts显示不同商详布局
    [self.viewModel requestGoodsDetailAllBts:self.detailArgument];
}

#pragma mark -================= <GoodsDetailVCActionProtocol> =================

/**
 * 导航栏点击事件回调
 * ZFGoodsDetailNavigationView
 */
- (void)handleNavgationAction:(ZFDetailNavButtonActionType)actionType {
    if (actionType == ZFDetailNavButtonAction_BackType) {
        [self goBackAction];
        
    } else if (actionType == ZFDetailNavButtonAction_CustomerType) {
        NSString *goodsInfo = [NSString stringWithFormat:@"%@-%@%@-%@",
                               self.viewModel.detailModel.goods_sn,
                               self.viewModel.detailModel.shop_price,
                               [ExchangeManager localCurrencyName],
                               self.viewModel.detailModel.goods_name];
        [[ZFCustomerManager shareInstance] presentLiveChatWithGoodsInfo:goodsInfo];
        
    }else if (actionType == ZFDetailNavButtonAction_CartType) {
        [self jumpToCartViewController];
    }
}

/**
 * 活动Cell点击事件回调
 * ZFGoodsDetailActivityCell
 */
- (ZFGoodsDetailActionBlock)activityCellActionBlock {
    @weakify(self);
    return ^(GoodsDetailModel *model, id obj, id obj2){
        @strongify(self);
        if ([obj integerValue] == ActivityTapImageViewActionType) {
            // 点击活动背景图走Deeplink
            [self openWebInfoWithUrl:model.activityIconModel.deeplinkUri title:@""];
            
        } else if ([obj integerValue] == ActivityCountDownCompleteActionType) {
            // 活动倒计时完成时重新请求商详信息
            [self.viewModel requestGoodsDetailPort:self.detailArgument];
        }
    };
}

/**
 * 点击优惠券Cell事件回调
 * ZFGoodsDetailNormalArrowsCell
 */
- (ZFGoodsDetailActionBlock)normalArrowsActionBlock {
    @weakify(self);
    return ^(GoodsDetailModel *model, ZFGoodsDetailCellTypeModel *cellTypeModel, NSString *title) {
        @strongify(self);
        switch (cellTypeModel.cellType) {
            case ZFGoodsDetailCellTypeShippingTips: {
                [self openWebInfoWithUrl:model.shipping_tips title:title];
            }
                break;
            case ZFGoodsDetailCellTypeDescription: {
                [self openWebInfoWithUrl:model.desc_url title:title];
            }
                break;
            case ZFGoodsDetailCellTypeModelStats: {
                [self openWebInfoWithUrl:model.model_url title:title];
            }
                break;
            case ZFGoodsDetailCellTypeCoupon: {
                [self.goodsDetailView showCouponPopView:cellTypeModel.couponListModelArr shouldRefresh:NO];
            }
                break;
            default:
                break;
        }
    };
}

/**
 * 点击优惠券领劵事件回调
 * ZFGoodsdetailCouponListView
 */
- (void (^)(ZFGoodsDetailCouponModel *couponModel, NSIndexPath *indexPath))getCouponBlock {
    @weakify(self);
    return ^(ZFGoodsDetailCouponModel *couponModel, NSIndexPath *indexPath) {
        @strongify(self);
//        [self judgePresentLoginVCCompletion:^{
//            @strongify(self)
//            [self.viewModel requestGetCouponPort:couponModel indexPath:indexPath];
//        }];
        @weakify(self)
        [self judgePresentLoginVCChooseType:YWLoginEnterTypeLogin comeFromType:YWLoginViewControllerEnterTypeGoodsDetailPage Completion:^{
            @strongify(self)
            [self.viewModel requestGetCouponPort:couponModel indexPath:indexPath];
        }];
    };
}

/**
 * 点击商详底部视图回调
 * ZFGoodsDetailAddCartView
 */
- (void(^)(GoodsDetailBottomViewActionType_A actionType))goodsDetailBottomViewBlock {
    @weakify(self);
    return ^(GoodsDetailBottomViewActionType_A actionType) {
        @strongify(self);
        if (actionType == GoodsDetailActionA_pushCarType) { // 查看购物车
            [self jumpToCartViewController];
            
        } else if (actionType == GoodsDetailActionA_addCartType) { // 添加到购物车
            [self.viewModel requestAddGoodsToCartPort:NO];
            
        } else if (actionType == GoodsDetailActionA_similarType){ //下架售罄商品找相似
            NSString *wp_image = self.viewModel.detailModel.wp_image;
            NSString *sku = self.viewModel.detailModel.goods_sn;
            [self pushToSimilarGoodsVC:wp_image
                              goodsSku:sku
                            sourceType:(ZFAppsflyerInSourceTypeSearchImageitems)];
        }
    };
}

/**
 * 点击评论列表回调
 * ZFGoodsDetailGoodsReviewCell
 */
- (ZFGoodsDetailActionBlock)reviewCellActionBlock {
    @weakify(self);
    return ^(GoodsDetailModel *model, NSIndexPath *indexPath, UIImageView *imageView){
        @strongify(self);
        ZFGoodsDetailReviewViewController *reviewVC = [[ZFGoodsDetailReviewViewController alloc] init];
        reviewVC.goodsId = model.goods_id;
        reviewVC.goodsSn = model.goods_sn;
        [self.navigationController pushViewController:reviewVC animated:YES];
        [ZFGoodsDetailAnalytics af_analyticsReviewClick:model.goods_sn];
    };
}

/**
 * 点击推荐商品回调
 * ZFGoodsDetailGoodsRecommendCell
 */
- (ZFGoodsDetailActionBlock)recommendCellActionBlock {
    @weakify(self);
    return ^(GoodsDetailModel *model, NSIndexPath *indexPath, UIImageView *imageView){
        @strongify(self);
        [self pushToRecommendDetail:model indexPath:indexPath imageView:imageView];
    };
}

/**
 * cell"滚动活动"点击事件类型
 * ZFGoodsDetailGoodsQualifiedCell
 */
- (ZFGoodsDetailActionBlock)qualifiedCellActionBlock {
    @weakify(self);
    return ^(GoodsDetailModel *model, id actionType, id obj){
        @strongify(self);
        if ([actionType integerValue] == ZFQualified_ReductionType) { // Deeplink跳转
            [self openWebInfoWithUrl:model.reductionModel.url title:@""];
            
        } else if ([actionType integerValue] == ZFQualified_MangJianType) { // 满减活动跳转
            [self pushToFullReductionVC:model.reductionModel];
        }
    };
}

/**
 * "Show"点击事件类型
 * ZFGoodsDetailGoodsShowCell
 */
- (ZFGoodsDetailActionBlock)showCellActionBlock {
    @weakify(self);
    return ^(GoodsDetailModel *model, id actionType, NSIndexPath *indexPath){
        @strongify(self);
        if ([actionType integerValue] == ZFShow_TouchImageAcAtionType) { // 点击show中的图片
            [self selectedShowExploreWithModel:model indexPath:indexPath];
        }
    };
}

/**
 * 点击穿搭Cell事件回调
 * ZFGoodsDetailOutfitsListView
 */
- (void (^)(ZFGoodsModel *goodsModel, NSUInteger actionType))outfitsActionBlock {
    @weakify(self);
    return ^(ZFGoodsModel *goodsModel, NSUInteger actionType) {
        @strongify(self);
        if (actionType == ZFOutfitsList_AddCartBagActionType) { // 加购
            [self.goodsDetailView showOutfitsAttributePopView:goodsModel];
            
        } else if (actionType == ZFOutfitsList_FindRelatedActionType) { // 找相似
            [self pushToSimilarGoodsVC:goodsModel.wp_image
                              goodsSku:goodsModel.goods_sn
                            sourceType:(ZFAppsflyerInSourceTypeDefault)];
            
        } else if (actionType == ZFOutfitsList_ShowDetailActionType) { // 看详情
            [self pushToOutfitsDetail:goodsModel];
        }
    };
}

/**
 * "Outfits"点击事件类型
 * ZFGoodsDetailOutfitsCell
 */
- (ZFGoodsDetailActionBlock)outfitsCellActionBlock {
    @weakify(self);
    return ^(GoodsDetailModel *model, id actionType, NSIndexPath *indexPath){
        @strongify(self);
        if ([actionType integerValue] == ZFOutfits_TouchImageActionType) { // 点击Outfits中的图片
            [self pushToCommunityPostDetailPageVC:model indexPath:indexPath];
            
        } else if ([actionType integerValue] == ZFOutfits_ItemButtonActionType) { // 点击Items
            if (model.outfitsModelArray.count <= indexPath.item) return;
            
            ZFGoodsDetailOutfitsModel *outfitsModel = model.outfitsModelArray[indexPath.item];
            if (outfitsModel.goodsModelArray.count == 0) {
                @weakify(self)
                [self.viewModel requestOutfitsSkuPortOutfits:outfitsModel.outfitsId goods_sn:model.goods_sn completion:^(NSArray<ZFGoodsModel *> *goodsModelArr) {
                    @strongify(self);
                    outfitsModel.goodsModelArray = goodsModelArr;
                    [self.goodsDetailView showOutfitsListPopView:goodsModelArr];
                    [ZFGoodsDetailAnalytics outfitsShowGoods:outfitsModel];
                    self.goodsDetailView.tmpShowOutfitsId = outfitsModel.outfitsId;
                }];
            } else {
                [self.goodsDetailView showOutfitsListPopView:outfitsModel.goodsModelArray];
                [ZFGoodsDetailAnalytics outfitsShowGoods:outfitsModel];
                self.goodsDetailView.tmpShowOutfitsId = outfitsModel.outfitsId;
            }
        }
    };
}

/**
 * "搭配购"按钮点击事件
 * ZFGoodsDetailCollocationBuyCell
 */
- (ZFGoodsDetailActionBlock)collocationBuyActionBlock {
    @weakify(self);
    return ^(GoodsDetailModel *model, ZFCollocationBuyModel *collocationBuyModel, NSIndexPath *indexPath){
        @strongify(self);
        ZFCollocationBuyViewController *vc = [[ZFCollocationBuyViewController alloc] init];
        vc.goods_sn = model.goods_sn;
        [self.navigationController pushViewController:vc animated:YES];
    };
}

/**
 * 快速购买下单
 */
- (void)fastBuyActionPush:(ZFOrderCheckInfoModel *)checkInfoModel
                extraInfo:(NSDictionary *)extraInfo
             refreshBlock:(void(^)(NSInteger))refreshBlock
{
    ZFOrderCheckInfoDetailModel *model = checkInfoModel.order_info;
    if (ZFIsEmptyString(model.address_info.address_id)) {
        ZFAddressEditViewController *addressVC = [[ZFAddressEditViewController alloc] init];
        addressVC.sourceCart = YES;
        addressVC.addressEditSuccessCompletionHandler = refreshBlock;
        [self.navigationController pushViewController:addressVC animated:YES];
    } else {
        ZFOrderContentViewController *contentVC = [[ZFOrderContentViewController alloc] init];
        contentVC.paymentProcessType = PaymentProcessTypeOld;
        contentVC.payCode = PayCodeTypeOld; // 代表老流程
        contentVC.checkoutModel = model;
        contentVC.detailFastBuyInfo = extraInfo;
        [self.navigationController pushViewController:contentVC animated:YES];
        // 快速购买下单统计
        [ZFGoodsDetailAnalytics fastBugAnalytics:model];
    }
}

#pragma mark -================= 所有跳转事件 =================

- (void)jumpToCartViewController {
    ZFCartViewController *cartVC = [[ZFCartViewController alloc] init];
    [self.navigationController pushViewController:cartVC animated:YES];
    [ZFGoodsDetailAnalytics af_analyticsShowCartBag];
}

- (void)pushToRecommendDetail:(GoodsDetailModel *)detailModel
                    indexPath:(NSIndexPath *)indexPath
                    imageView:(UIImageView *)imageView
{
    if (detailModel.recommendModelArray.count <= indexPath.item) return;
    GoodsDetailSameModel *recommendModel = detailModel.recommendModelArray[indexPath.item];
    
    if (ZFIsEmptyString(recommendModel.goods_id)) return;
    ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
    detailVC.goodsId = recommendModel.goods_id;
    detailVC.sourceType = ZFAppsflyerInSourceTypeGoodsDetail;
    detailVC.analyticsProduceImpression = [self.viewModel.recommendAnalyticsImpression mutableCopy];
    detailVC.afParams = detailModel.af_recommend_params;
    detailVC.transformSourceImageView = imageView;
    self.navigationController.delegate = imageView ? detailVC : nil;
    [self.navigationController pushViewController:detailVC animated:YES];
    
    // 统计推荐商品点击
    [ZFGoodsDetailAnalytics af_fireBaseShowDetail:recommendModel.goods_id];
    [ZFGoodsDetailAnalytics af_analysicsClickRecommend:recommendModel
                                         detailGoodsId:recommendModel.goods_id];
}

- (void)pushToOutfitsDetail:(ZFGoodsModel *)goodsModel {
    if (ZFIsEmptyString(goodsModel.goods_id)) return;
    ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
    detailVC.goodsId = goodsModel.goods_id;
    detailVC.sourceType = ZFAppsflyerInSourceTypeDetailOutfits;
    detailVC.transformSourceImageView = nil;
    self.navigationController.delegate = nil;
    [self.navigationController pushViewController:detailVC animated:YES];
}

/**
 * 点击了show打开关联帖子
 */
- (void)selectedShowExploreWithModel:(GoodsDetailModel *)model indexPath:(NSIndexPath *)indexPath {
    if (model.showExploreModelArray.count <= indexPath.item) return;
    GoodsShowExploreModel *showExploreModel = model.showExploreModelArray[indexPath.item];
    
    if (showExploreModel.type == 1) { //视频
        ZFCommunityVideoListVC *videoVC = [[ZFCommunityVideoListVC alloc] init];
        videoVC.videoId = showExploreModel.reviewsId;
        [self.navigationController pushViewController:videoVC animated:YES];
    } else {
        NSMutableArray *reviewIDArray = [NSMutableArray array];
        BOOL hasStartIndex = NO;
        for (NSInteger i=0; i<model.showExploreModelArray.count; i++) {
            GoodsShowExploreModel *showsModel = model.showExploreModelArray[i];
            if (showExploreModel.type == 1) continue;// 不需要视频
            if (hasStartIndex) {
                [reviewIDArray addObject:ZFToString(showsModel.reviewsId)];
            } else if ([showExploreModel.reviewsId isEqualToString:showsModel.reviewsId]) {
                hasStartIndex = YES;
                [reviewIDArray addObject:ZFToString(showsModel.reviewsId)];
            }
        }
        ZFCommunityPostDetailPageVC *topicDetailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:ZFToString(showExploreModel.reviewsId) title:@""];
        topicDetailViewController.sourceType = ZFAppsflyerInSourceTypeZMeExploreid;
        topicDetailViewController.reviewIDArray = reviewIDArray;
        [self.navigationController pushViewController:topicDetailViewController animated:YES];
    }
}

- (void)pushToCommunityPostDetailPageVC:(GoodsDetailModel *)detailModel indexPath:(NSIndexPath *)indexPath {

    if (detailModel.outfitsModelArray.count <= indexPath.item) return;
    NSMutableArray *reviewIDArray = [NSMutableArray array];
    BOOL hasStartIndex = NO;
    
    ZFGoodsDetailOutfitsModel *touchModel = detailModel.outfitsModelArray[indexPath.item];
    
    for (ZFGoodsDetailOutfitsModel *outfitsModel in detailModel.outfitsModelArray) {
        if (hasStartIndex) {
            [reviewIDArray addObject:ZFToString(outfitsModel.outfitsId)];
        } else if ([touchModel.outfitsId isEqualToString:outfitsModel.outfitsId]) {
            hasStartIndex = YES;
            [reviewIDArray addObject:ZFToString(outfitsModel.outfitsId)];
        }
    }
    ZFCommunityPostDetailPageVC *topicDetailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:ZFToString(touchModel.outfitsId) title:@""];
    topicDetailViewController.sourceType = ZFAppsflyerInSourceTypeZMeExploreid;
    topicDetailViewController.reviewIDArray = reviewIDArray;
    [self.navigationController pushViewController:topicDetailViewController animated:YES];
}

/**
 * 跳转到满减页面
 */
- (void)pushToFullReductionVC:(GoodsReductionModel *)reductionModel {
    if (![reductionModel isKindOfClass:[GoodsReductionModel class]]) return;
    
    ZFFullReductionViewController *fullReductionVC = [[ZFFullReductionViewController alloc] init];
    fullReductionVC.title = ZFToString(reductionModel.activity_title);
    fullReductionVC.reduc_id = reductionModel.reduc_id;
    fullReductionVC.activity_type = reductionModel.activity_type;
    [self.navigationController pushViewController:fullReductionVC animated:YES];
}

- (void)openWebInfoWithUrl:(NSString *)url title:(NSString *)title {
    if (ZFIsEmptyString(url)) return ;
    
    if ([url hasPrefix:@"ZZZZZ:"]) {
        ZFBannerModel *model = [[ZFBannerModel alloc] init];
        model.deeplink_uri = ZFToString(url);
        [BannerManager doBannerActionTarget:self withBannerModel:model];
    }else{
        ZFWebViewViewController *webVC = [[ZFWebViewViewController alloc] init];
        webVC.link_url = ZFToString(url);
        webVC.title = ZFToString(title);
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

- (void)showNavCartInfoPopView:(GoodsDetailModel *)detailModel {
    [self.goodsDetailView hideAddCartInfoPopView];
    [self.goodsDetailView cancelHideAddCartPopViewAction];
    @weakify(self)
    [self.goodsDetailView showNavgationAddCarAnimation:^{
        @strongify(self)
        [self.goodsDetailView showAddCartInfoPopView:detailModel];
    } scrollToRecommend:NO];
}

/**
 ** 进入找相似页面
 * 1.将下架和售罄商品样式调整，增加找相似商品入口
 * 2.穿搭商品失效, 增加找相似商品入口
 */
- (void)pushToSimilarGoodsVC:(NSString *)imageUrl
                    goodsSku:(NSString *)goodsSku
                  sourceType:(ZFAppsflyerInSourceType)sourceType
{
    if (ZFIsEmptyString(goodsSku)) return;
    ZFUnlineSimilarViewController *similarVC = [[ZFUnlineSimilarViewController alloc] initWithImageURL:imageUrl sku:goodsSku];
    similarVC.sourceType = sourceType;
    [self.navigationController pushViewController:similarVC animated:YES];
}

#pragma mark - <get lazy Load>

- (NSDictionary *)detailArgument {
    return @{@"manzeng_id"      : ZFToString(self.freeGiftId),
             @"goods_id"        : ZFToString(self.goodsId),
             @"photoBts"        : @(self.isNeedProductPhotoBts),
             };//kShowLoadingFlag   : self.transformSourceImageView ? @"0" : @"1",
}

- (ZFGoodsDetailViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFGoodsDetailViewModel alloc] init];
        _viewModel.goodsDetailView = self.goodsDetailView;
        _viewModel.actionProtocol = self;
    }
    return _viewModel;
}

- (ZFGoodsDetailView *)goodsDetailView {
    if (!_goodsDetailView) {
        _goodsDetailView = [[ZFGoodsDetailView alloc] initWithActionProtocol:self];
        _goodsDetailView.backgroundColor = [UIColor whiteColor];
    }
    return _goodsDetailView;
}

- (ZFGoodsDetailTransformView *)transformView {
    if (!_transformView) {
        _transformView = [[ZFGoodsDetailTransformView alloc] initWithFrame:self.view.bounds];
        @weakify(self)
        _transformView.tapPopHandle = ^{
            @strongify(self)
            [self.viewModel cancelAllDataTask];
            [self goBackAction];
        };
        [self.view addSubview:_transformView];
    }
    return _transformView;
}

- (void)showTransformView:(BOOL)show {
    if (show) {
        [self.transformView startLoading];
        
    } else if (_transformView) {
        [self.transformView endLoading];
    }
}

#pragma mark - <UINavigationControllerDelegate>

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    BOOL isPushAnimation = [toVC isKindOfClass:[self class]] && operation == UINavigationControllerOperationPush;
    if (isPushAnimation && self.transformSourceImageView) {
        return [ZFPositonTranformAnimation transitionWithType:operation
                                                   sourceView:self.transformSourceImageView];
    }
    return nil;
}

@end
