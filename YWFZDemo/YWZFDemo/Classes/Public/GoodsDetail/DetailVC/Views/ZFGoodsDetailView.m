//
//  ZFGoodsDetailView.m
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailView.h"
#import "ZFGoodsDetailViewImportFiles.h"

@interface ZFGoodsDetailView () <ZFShareViewDelegate>
@property (nonatomic, weak) id<GoodsDetailVCActionProtocol>     actionProtocol;

@property (nonatomic, strong) ZFGoodsDetailCollectionView       *collectionContentView;
@property (nonatomic, strong) ZFGoodsDetailNavigationView       *navigationView;
@property (nonatomic, strong) ZFGoodsDetailCartInfoPopView      *cartInfoPopView;
@property (nonatomic, strong) ZFNewBannerScrollView             *bannerView;
@property (nonatomic, strong) ZFGoodsDetailAddCartView          *addCartView;
@property (nonatomic, strong) ZFGoodsdetailCouponListView       *couponListView;
@property (nonatomic, strong) ZFGoodsDetailOutfitsListView      *outfitsListView;
@property (nonatomic, strong) ZFShareView                       *shareView;
@property (nonatomic, strong) UIButton                          *groupBuyH5Button;
@property (nonatomic, strong) ZFGoodsDetailGroupBuyModel        *groupBuyH5Model;
@property (nonatomic, assign) CGFloat                           lastOffsetY;
@property (nonatomic, strong) ZFGoodsDetailSelectTypeView       *attributeView;
@property (nonatomic, copy) NSString                            *tmpOutfitsGoodsSpu;
@property (nonatomic, assign) BOOL                              isHideingCartInfoFlag;
@end

@implementation ZFGoodsDetailView

- (void)dealloc {
    YWLog(@"ZFGoodsDetailView dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithActionProtocol:(id<GoodsDetailVCActionProtocol>)actionProtocol {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.actionProtocol = actionProtocol;
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addNotification];
    }
    return self;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takeScreenShotToShare:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCollectionInfo:) name:kCollectionGoodsNotification object:nil];
}

#pragma mark - <NSNotification>

/** 通知收藏,刷新页面 */
- (void)refreshCollectionInfo:(NSNotification *)info {
    if (![info.userInfo[kLoadingView] isEqual:self]) return;
    
    NSDictionary *infoDict = info.userInfo;
    NSString *goods_id = ZFToString(infoDict[@"goods_id"]);
    if (![self.detailModel.goods_id isEqualToString:goods_id]) return;
    self.detailModel.is_collect = ZFToString(infoDict[@"is_collect"]);
    [self reloadDetailView:NO sectionIndex:1];
}

/** 捕获截屏操作, 引导用户分享 */
- (void)takeScreenShotToShare:(NSNotification *)notice {
    NSString *shreTitle = ZFLocalizedString(@"GoodsDetail_TellYourFriends",nil);
    NSString *btnTitle = ZFLocalizedString(@"GoodsDetail_ShareIt",nil);
    ShowScreenTopToolBarToView(self, shreTitle, btnTitle, ^{
        [self showShareView];
    });
}

#pragma mark - Set SourceData

/** 刷新商详数据源 */
- (void)setDetailModel:(GoodsDetailModel *)detailModel {
    _detailModel = detailModel;
    if (self.navigationView.isHidden) {
        self.navigationView.hidden = NO;
    }
    if (self.addCartView.isHidden) {
        self.addCartView.hidden = NO;
    }
    if (!ZFIsEmptyString(self.groupBuyH5Model.jump_url)) {
        [self showGroupBuyWithModel:self.groupBuyH5Model];
    }
    self.navigationView.imageUrl = detailModel.pictures.firstObject.wp_image;
    self.addCartView.model = detailModel;
}

- (void)setSectionTypeModelArr:(NSArray<ZFGoodsDetailCellTypeModel *> *)sectionTypeModelArr {
    _sectionTypeModelArr = sectionTypeModelArr;
    self.collectionContentView.sectionTypeModelArr = sectionTypeModelArr;
}

- (void)reloadDetailView:(BOOL)reloadAll sectionIndex:(NSInteger)sectionIndex {
    [self.collectionContentView reloadCollectionView:reloadAll sectionIndex:sectionIndex];
}

- (void)showDetailEmptyView:(NSError *)error refreshBlock:(void(^)(void))refreshBlock {
    self.navigationView.hidden = NO;
    [self.collectionContentView confiugEmptyView:error refreshBlock:refreshBlock];
}

- (void)showDetailFooterRefresh:(BOOL)showFooterRefresh refreshBlock:(void(^)(void))refreshBlock {
    [self.collectionContentView showFooterRefresh:showFooterRefresh refreshBlock:refreshBlock];
}

- (void)refreshProductDescHeight {
    [self.collectionContentView convertProductDescCellHeight];
    
}

- (UIImage *)navigationGoodsImage {
    return self.navigationView.fetchGoodsImage;
}

#pragma mark - <Public Method>
/**
 * 刷新/显示优惠券列表
 */
- (void)showCouponPopView:(NSArray *)couponModelArr shouldRefresh:(BOOL)isRefresh {
    if (isRefresh) {
        [self.couponListView refreshListData:couponModelArr];
    } else {
        [self bringSubviewToFront:self.couponListView];
        self.couponListView.hidden = NO;
        [self layoutIfNeeded];
        // 显示优惠券列表
        [self.couponListView convertCouponListView:couponModelArr showCoupon:YES];
        // 统计优惠券点击次数
        [ZFGoodsDetailAnalytics af_analyticsShowCoupon];
    }
}

/**
 * 显示穿搭弹框列表
 */
- (void)showOutfitsListPopView:(NSArray *)goodsModelArr {
    [self bringSubviewToFront:self.outfitsListView];
    self.outfitsListView.hidden = NO;
    [self layoutIfNeeded];
    // 显示穿搭列表
    [self.outfitsListView convertOutfitsListView:goodsModelArr showOutfits:YES];
}

/**
 * 刷新购物车, 导航栏按钮换肤
 */
- (void)refreshNavAndCartBage {
    showSystemStatusBar();
    [self.addCartView changeCartNumberInfo];
    [self.navigationView zfChangeSkinToShadowNavgationBar];
}

/**
 * 显示购物车加购动画
 */
- (void)showNavgationAddCarAnimation:(void(^)(void))finishAnimation
                   scrollToRecommend:(BOOL)scrollToRecommend
{
    CGRect rect = [self.navigationView convertRect:self.navigationView.cartButton.frame toView:WINDOW];
    CGPoint endPoint = CGPointMake(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
    
    ZFPopDownAnimation *popAnimation = [[ZFPopDownAnimation alloc] init];
    popAnimation.animationImage = self.navigationView.fetchGoodsImage;
    popAnimation.animationDuration = 0.5f;
    popAnimation.endPoint = endPoint;
    
    @weakify(self)
    [popAnimation startAnimation:self endBlock:^{
        @strongify(self)
        //震动反馈
        ZFPlaySystemQuake();
        
        //添加到购物车后滚动到推荐商品列表
        if (scrollToRecommend) {
            [self.collectionContentView scrollToRecommendGoodsSection];
        }
        
        [ZFPopDownAnimation popDownRotationAnimation:self.navigationView.cartButton];
        
        if (finishAnimation) {
            finishAnimation();
        }
    }];
}

/**
 * 显示购物车加购动画
 */
- (void)showAddCarAnimation {
    CGRect rect = [self.addCartView convertRect:self.addCartView.cartButton.frame toView:WINDOW];
    CGPoint endPoint = CGPointMake(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
    
    ZFPopDownAnimation *popAnimation = [[ZFPopDownAnimation alloc] init];
    popAnimation.animationImage = self.navigationView.fetchGoodsImage;
    popAnimation.animationDuration = 0.5f;
    popAnimation.endPoint = endPoint;
    
    @weakify(self)
    [popAnimation startAnimation:self endBlock:^{
        @strongify(self)
        //震动反馈
        ZFPlaySystemQuake();
        
        [self.addCartView changeCartNumberInfo];
        
        //添加到购物车后滚动到推荐商品列表
        [self.collectionContentView scrollToRecommendGoodsSection];
        [ZFPopDownAnimation popDownRotationAnimation:self.addCartView.cartButton];
    }];
}

- (void)scrollToRecommendGoodsPostion {
    [self.collectionContentView scrollToRecommendGoodsSection];
}

#pragma mark - <ZFShareViewDelegate>
/**
 * 点击分享Item按钮
 */
- (void)zfShsreView:(ZFShareView *)shareView didSelectItemAtIndex:(NSUInteger)index
{
    NativeShareModel *model = [[NativeShareModel alloc] init];
    model.share_url = self.detailModel.seid_url;
    model.sharePageType = ZFSharePage_ProductDetailType;
    model.share_imageURL = shareView.topView.imageName;
    model.share_description = shareView.topView.title;
    [ZFShareManager shareManager].model = model;
    [ZFShareManager shareManager].currentShareType = index;
    
    switch (index) {
        case ZFShareTypeWhatsApp: {
            [[ZFShareManager shareManager] shareToWhatsApp];
        }
            break;
        case ZFShareTypeFacebook: {
            [[ZFShareManager shareManager] shareToFacebook];
        }
            break;
        case ZFShareTypeMessenger: {
            [[ZFShareManager shareManager] shareToMessenger];
        }
            break;
        case ZFShareTypePinterest: {
            [[ZFShareManager shareManager] shareToPinterest];
        }
            break;
        case ZFShareTypeCopy: {
            [[ZFShareManager shareManager] copyLinkURL];
        }
            break;
        case ZFShareTypeMore: {
            [[ZFShareManager shareManager] shareToMore];
        }
            break;
        case ZFShareTypeVKontakte: {
            [[ZFShareManager shareManager] shareVKontakte];
        }
            break;
    }
    //需求: 统计分享, 不管成功失败一点击就统计
    [ZFGoodsDetailAnalytics af_analyticsShare:(ZFGoodsDetailViewController *)self.actionProtocol
                                    shareType:index
                                     goods_sn:self.detailModel.goods_sn];
}

- (void (^)(UIButton *))shareButtonBlcok {
    @weakify(self);
    return ^(UIButton *btn) {
        @strongify(self);
        [self showShareView];
    };
}

- (void)showShareView {
    ZFShareTopView *shareTopView = [[ZFShareTopView alloc] init];
    [shareTopView updateImage:self.detailModel.pictures.firstObject.img_url
                        title:self.detailModel.goods_name
                      tipType:ZFShareDefaultTipTypeCommon];
    self.shareView.topView = shareTopView;
    [self.shareView open];
    [ZFGoodsDetailAnalytics af_analyticsShowShare:self.detailModel.goods_sn];
}

#pragma mark - <Dealwith outfits convert godds>

/**
 * 点击穿搭关联商品Itmes->弹出框->加购按钮->弹出框->切换商品
 */
- (void)dealwithOutfitsAddGoods:(NSString *)goodsId
{
    ZFGoodsDetailViewModel *detailViewModel = [[ZFGoodsDetailViewModel alloc] init];
    [detailViewModel requestAddToCart:ZFToString(goodsId)
                         loadingView:nil
                            goodsNum:1
                          completion:^(BOOL isSuccess) {
        if (isSuccess) {
            [self.attributeView hideSelectTypeView];
            [ZFGoodsDetailAnalytics outfitsClickGoods:self.attributeView.model
                                            goods_spu:self.tmpOutfitsGoodsSpu
                                            outfitsId:self.tmpShowOutfitsId];
        } else {
            [self.attributeView bottomCartViewEnable:YES];
        }
    }];
}

- (void)showOutfitsAttributePopView:(ZFGoodsModel *)goodsModel {
    @weakify(self);
    [self dealwithOutfitsConvertGoods:goodsModel.goods_id completion:^(GoodsDetailModel *goodsDetailInfo) {
        @strongify(self);
        self.tmpOutfitsGoodsSpu = goodsModel.goods_spu;
        self.attributeView.model = goodsDetailInfo;
        [self.attributeView openSelectTypeView];
    }];
}

- (void)dealwithOutfitsConvertGoods:(NSString *)goodsId completion:(void (^)(GoodsDetailModel *))completion {
    ShowLoadingToView(self);
    ZFGoodsDetailViewModel *detailViewModel = [[ZFGoodsDetailViewModel alloc] init];
    [detailViewModel requestGoodsDetailData:@{@"goods_id": ZFToString(goodsId)}
                                completion:^(GoodsDetailModel *model) {
        HideLoadingFromView(self);
        if (completion) {
            completion(model);
        }
    } failure:^(NSError *error) {
        ShowToastToViewWithText(self, error.domain);
    }];
}

- (void)showAddCartInfoPopView:(GoodsDetailModel *)detailModel {
    self.cartInfoPopView.detailModel = detailModel;
    [self showCartInfoPopViewWithAnimation:YES];
}

- (void)hideAddCartInfoPopView {
    if (_cartInfoPopView && _cartInfoPopView.alpha > 0
        && !_cartInfoPopView.hidden && !self.isHideingCartInfoFlag) {
        
        self.isHideingCartInfoFlag = YES;
        [self showCartInfoPopViewWithAnimation:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isHideingCartInfoFlag = NO;
        });
    }
}

- (void)showCartInfoPopViewWithAnimation:(BOOL)show {
    CGFloat beforeScale = show ? 0.7 : 1.0;
    CGFloat afterScale = show ? 1.0 : 0.5;
    self.cartInfoPopView.transform = CGAffineTransformMakeScale(beforeScale, beforeScale);
    self.cartInfoPopView.alpha = show ? 0.0 : 1.0;
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:3
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.cartInfoPopView.transform = CGAffineTransformMakeScale(afterScale, afterScale);
        self.cartInfoPopView.alpha = show ? 1.0 :0.0;
        
    } completion:^(BOOL finished) {
        ///5秒后消失
        [self performSelector:@selector(hideAddCartInfoPopView) withObject:nil afterDelay:5];
    }];
}

- (void)cancelHideAddCartPopViewAction {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(hideAddCartInfoPopView)
                                               object:nil];
}

#pragma mark - private

- (void (^)(void))tapNavigationGoodsImageBlcok {
    @weakify(self);
    return ^(void) {
        @strongify(self);
        [self.collectionContentView collectionViewScrollsToTop];
    };
}

- (void)groupBuyH5Action:(UIButton *)button {
    if ([self.actionProtocol respondsToSelector:@selector(openWebInfoWithUrl:title:)]) {
        [self.actionProtocol openWebInfoWithUrl:self.groupBuyH5Model.jump_url
                                          title:self.groupBuyH5Model.title];
    }
}

- (void)showGroupBuyWithModel:(ZFGoodsDetailGroupBuyModel *)groupBuyModel {
    if (ZFIsEmptyString(groupBuyModel.jump_url)) {
        _groupBuyH5Button.hidden = YES;
        return;
    }
    self.groupBuyH5Model = groupBuyModel;
    [self bringSubviewToFront:self.groupBuyH5Button];
    self.groupBuyH5Button.hidden = self.navigationView.isHidden;
    
    ZFBTSModel *btsModel = [ZFBTSManager getBtsModel:kZFBtsIosxaddbag defaultPolicy:kZFBts_A];
    BOOL hasShowCollection = ![btsModel.policy isEqualToString:kZFBts_A];
    self.groupBuyH5Button.y = hasShowCollection ? (420-100) : (420-50);
    
    if (!self.groupBuyH5Button.isHidden) {
        [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
            self.groupBuyH5Button.x = KScreenWidth - self.groupBuyH5Button.width;
        } completion:nil];
    }
}

/** 表格滚动回调 */
- (void)collectionViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navigationView.refreshAlpha = offsetY / (kDetailBannerHeight - self.navigationView.height);
    
    if (!ZFIsEmptyString(self.groupBuyH5Model.jump_url)
        && offsetY > 0 && offsetY < (scrollView.contentSize.height - KScreenHeight)) {
        self.groupBuyH5Button.hidden = NO;
        CGFloat buyButtonX = KScreenWidth - ((offsetY < self.lastOffsetY) ? self.groupBuyH5Button.width : 30);
        [UIView animateWithDuration:0.4 animations:^{
            self.groupBuyH5Button.x = buyButtonX;
        }];
    }
    self.lastOffsetY = offsetY;
    
    ///滚动时隐藏加购弹窗视图
    if (!scrollView.decelerating) {
        //[self hideAddCartInfoPopView];
    }
}

- (void)actionForNavigation:(ZFDetailNavButtonActionType)actionType {
    if (actionType == ZFDetailNavButtonAction_ShareType) {
        if (self.shareButtonBlcok) {
            self.shareButtonBlcok(nil);
        }
    } else if (actionType == ZFDetailNavButtonAction_TapImageType) {
        if (self.tapNavigationGoodsImageBlcok) {
            self.tapNavigationGoodsImageBlcok();
        }
    } else {
        if ([self.actionProtocol respondsToSelector:@selector(handleNavgationAction:)]) {
            [self.actionProtocol handleNavgationAction:actionType];
        }
    }
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionContentView];
    [self addSubview:self.addCartView];
    [self addSubview:self.navigationView];
}

- (void)zfAutoLayoutView {
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(STATUSHEIGHT + 44);
    }];
    
    [self.addCartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
    }];
    
    [self.collectionContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.addCartView.mas_top);
    }];
}

#pragma mark - <set >
- (void)setTmpShowOutfitsId:(NSString *)tmpShowOutfitsId {
    _tmpShowOutfitsId = tmpShowOutfitsId;
    self.outfitsListView.tmpShowOutfitsId = tmpShowOutfitsId;
}

#pragma mark - <get lazy Load>

- (ZFShareView *)shareView {
    if (!_shareView) {
        _shareView = [[ZFShareView alloc] initWithFrame:CGRectZero];
        _shareView.delegate = self;
    }
    return _shareView;
}

- (ZFGoodsDetailNavigationView *)navigationView {
    if (!_navigationView) {
        _navigationView = [[ZFGoodsDetailNavigationView alloc] initWithFrame:CGRectZero];
        _navigationView.hidden = YES;
        
        @weakify(self);
        _navigationView.navigationBlcok = ^(ZFDetailNavButtonActionType actionType) {
            @strongify(self);
            [self actionForNavigation:actionType];
        };
    }
    return _navigationView;
}

- (ZFGoodsdetailCouponListView *)couponListView {
    if (!_couponListView) {
        _couponListView = [[ZFGoodsdetailCouponListView alloc] initWithFrame:CGRectZero];
        _couponListView.getCouponBlock = self.actionProtocol.getCouponBlock;
        _couponListView.hidden = YES;
        [self addSubview:_couponListView];
        
        [_couponListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
        }];
    }
    return _couponListView;
}

- (ZFGoodsDetailOutfitsListView *)outfitsListView {
    if (!_outfitsListView) {
        _outfitsListView = [[ZFGoodsDetailOutfitsListView alloc] initWithFrame:CGRectZero];
        _outfitsListView.outfitsActionBlock = self.actionProtocol.outfitsActionBlock;
        _outfitsListView.hidden = YES;
        [self addSubview:_outfitsListView];
        
        [_outfitsListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
        }];
    }
    return _outfitsListView;
}

- (ZFGoodsDetailCartInfoPopView *)cartInfoPopView {
    if (!_cartInfoPopView) {
        CGRect rect = CGRectMake(KScreenWidth - (180+8), STATUSHEIGHT+44+4, 180, 118);
        _cartInfoPopView = [[ZFGoodsDetailCartInfoPopView alloc] initWithFrame:rect];
        [self addSubview:_cartInfoPopView];
        
        ///C版本才显示右上角弹框
        ZFBTSModel *btsModel = [ZFBTSManager getBtsModel:kZFBtsIosxaddbag defaultPolicy:kZFBts_A];
        _cartInfoPopView.hidden = ![btsModel.policy isEqualToString:kZFBts_C];
        
        @weakify(self);
        _cartInfoPopView.addToCartBlcok = ^(GoodsDetailModel * _Nonnull detailModel) {
            @strongify(self);
            [self actionForNavigation:(ZFDetailNavButtonAction_CartType)];
        };
    }
    [self bringSubviewToFront:_cartInfoPopView];
    return _cartInfoPopView;
}

/**
* 点击穿搭关联商品Itmes->弹出框->加购按钮->弹出框->切换商品
* ZFGoodsDetailSelectTypeView
*/
- (ZFGoodsDetailSelectTypeView *)attributeView {
    if (!_attributeView) {
        NSString *bagTitle = ZFLocalizedString(@"Detail_Product_AddToBag", nil);
        _attributeView = [[ZFGoodsDetailSelectTypeView alloc] initSelectSizeView:NO bottomBtnTitle:bagTitle];
        _attributeView.hidden = YES;
        @weakify(self);
        _attributeView.openOrCloseBlock = ^(BOOL isOpen) {
            @strongify(self);
            [self.attributeView bottomCartViewEnable:YES];
        };

        _attributeView.goodsDetailSelectTypeBlock = ^(NSString *goodsId) {
            @strongify(self);
            
            @weakify(self);
            [self dealwithOutfitsConvertGoods:goodsId completion:^(GoodsDetailModel *model) {
                @strongify(self);
                self.attributeView.model = model;
            }];
        };
        
        _attributeView.goodsDetailSelectSizeGuideBlock = ^(NSString *url){
            @strongify(self);
            [self.attributeView hideSelectTypeView];
            if ([self.actionProtocol respondsToSelector:@selector(openWebInfoWithUrl:title:)]) {
                NSString *title = ZFLocalizedString(@"Detail_Product_SizeGuides",nil);
                [self.actionProtocol openWebInfoWithUrl:self.attributeView.model.size_url title:title];
            }
        };

        _attributeView.addCartBlock = ^(NSString *goodsId, NSInteger count) {
            @strongify(self);
            [self.attributeView bottomCartViewEnable:NO];
            [self dealwithOutfitsAddGoods:goodsId];
        };
        
        [WINDOW addSubview:_attributeView];
        [_attributeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(WINDOW).insets(UIEdgeInsetsZero);
        }];
    }
    return _attributeView;
}

- (ZFGoodsDetailCollectionView *)collectionContentView {
    if (!_collectionContentView) {
        _collectionContentView = [[ZFGoodsDetailCollectionView alloc] initWithFrame:self.bounds];
    }
    return _collectionContentView;
}

- (ZFGoodsDetailAddCartView *)addCartView {
    if (!_addCartView) {
        _addCartView = [[ZFGoodsDetailAddCartView alloc] initWithFrame:CGRectZero];
        _addCartView.goodsDetailBottomViewBlock = self.actionProtocol.goodsDetailBottomViewBlock;
        _addCartView.hidden = YES;
    }
    return _addCartView;
}

- (UIButton *)groupBuyH5Button {
    if (!_groupBuyH5Button) {
        CGRect rect = CGRectMake(0, 420-50, 100, 36);
        _groupBuyH5Button = [[UIButton alloc] initWithFrame:rect];
        _groupBuyH5Button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [_groupBuyH5Button setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        [_groupBuyH5Button setTitleColor:[ZFCOLOR_WHITE colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        _groupBuyH5Button.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 8);
        [_groupBuyH5Button addTarget:self action:@selector(groupBuyH5Action:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *image = ZFImageWithName(@"detail_corner_background");
        [_groupBuyH5Button setBackgroundImage:image forState:UIControlStateNormal];
        [_groupBuyH5Button setBackgroundImage:image forState:UIControlStateHighlighted];
        
        NSString *title = ZFLocalizedString(@"Detail_GroupBuy_GetItFreeTitle", nil);
        UIImage *normalImage = [UIImage imageNamed:@"account_zme"];
        [_groupBuyH5Button setTitle:title forState:UIControlStateNormal];
        [_groupBuyH5Button setImage:normalImage forState:UIControlStateNormal];
        [_groupBuyH5Button zfLayoutStyle:ZFButtonEdgeInsetsStyleRight imageTitleSpace:3];
        [_groupBuyH5Button convertUIWithARLanguage];
        [_groupBuyH5Button sizeToFit];
        
        _groupBuyH5Button.height = 36;
        _groupBuyH5Button.x = KScreenWidth;
        _groupBuyH5Button.y = 420-50;
        [self addSubview:_groupBuyH5Button];
    }
    return _groupBuyH5Button;
}

@end
