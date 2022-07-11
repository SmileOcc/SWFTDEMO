//
//  OSSVAPPThemeHandleMangerView.m
// OSSVAPPThemeHandleMangerView
//
//  Created by odd on 2021/3/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVAPPThemeHandleMangerView.h"


@interface OSSVAPPThemeHandleMangerView()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    CustomerLayoutDatasource,
    CustomerLayoutDelegate,
    STLScrollerCollectionViewCellDelegate,
    STLThemeZeorActivityCCellDelegate,
    STLScrollerGoodsCCellDelegate,
    STLAsingleCCellDelegate,
    STLThemeGoodsRankModuleCCellDelegate,
    STLThemeGoodsRankCCellDelegate,
    WMMenuViewDelegate,
    WMMenuViewDataSource,
    DZNEmptyDataSetSource,
    DZNEmptyDataSetDelegate,
    STLThemeZeorActivityDoubleLinesCCellDelegate,
    STLThemeCouponsCCellDelegate
>

@end

@implementation OSSVAPPThemeHandleMangerView


- (instancetype)init {
    @throw [NSException exceptionWithName:@"STLThemeManagerView init error" reason:@"Please use the designated initializer." userInfo:nil];
    return [self initWithFrame:CGRectZero channelId:NSStringFromClass(OSSVAPPThemeHandleMangerView.class) showRecommend:NO];
}

- (instancetype)initWithFrame:(CGRect)frame channelId:(NSString *)channelId showRecommend:(BOOL)showRecommend {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.emptyShowType = EmptyViewShowTypeHide;
        self.customId = channelId;
        [self stlInitView];
        [self stlAutoLayoutView];
        
//        // 登录刷新通知
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginChangeCollectionRefresh) name:kLoginNotification object:nil];
//        // 登出刷新通知
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logoutChangeCollectionRefresh) name:kLogoutNotification object:nil];
    }
    return self;
}

- (void)baseConfigureSource:(STLAppsflyerGoodsSourceType)source analyticsId:(NSString *)idx screenName:(NSString *)screenName {
    
}

- (void)clearDatas {

    if (_menuView && [[self gainMenuList] count] > 0) {
        [_menuView selectItemAtIndex:0];
    }
    if(_menuView) {
        _menuView.hidden = YES;
    }
    [self.dataSourceList removeAllObjects];
    self.isChannel = NO;
    [self.allCoupons removeAllObjects];
    [self.customProductListCache removeAllObjects];
}

#pragma mark - 配置
- (void)reloadView:(BOOL)isEmptyDataRefresh {
    
    if (isEmptyDataRefresh) {//清除数据刷新时
     
    }
    [self.themeCollectionView reloadData];
}

#pragma mark - STLInitViewProtocol

- (void)stlInitView {
    [self addSubview:self.themeCollectionView];
}

- (void)stlAutoLayoutView {
    [self.themeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

//occ阿语适配
- (void)arMenuViewHandle {
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.menuView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        
        NSArray *subMenuViews = self.menuView.scrollView.subviews;
        for (UIView *subView in subMenuViews) {
            if ([subView isKindOfClass:[WMMenuItem class]]) {
                subView.transform = CGAffineTransformMakeScale(-1.0,1.0);
            }
        }
    }
}

#pragma mark - collection datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataSourceList count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id<CustomerLayoutSectionModuleProtocol>module = self.dataSourceList[section];
    return [module.sectionDataList count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<OSSVCollectCCellProtocol>cell;
    if (self.dataSourceList.count > indexPath.section) {
        id<CustomerLayoutSectionModuleProtocol>module = self.dataSourceList[indexPath.section];
        
        if (module.sectionDataList.count > indexPath.row) {
            id<CollectionCellModelProtocol>model = module.sectionDataList[indexPath.row];
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:[model reuseIdentifier] forIndexPath:indexPath];
            cell.model = model;
            cell.delegate = self;
        }
    }
    
    if (!cell) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[OSSVAsingleCCellModel reuseIdentifier] forIndexPath:indexPath];
    }
    
    return (UICollectionViewCell *)cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:willDisplayCell:forItemAtIndexPath:)]) {
        [self.delegate stl_themeManagerView:self collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:didSelectItemCell:forItemAtIndexPath:)]) {
        
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        [self.delegate stl_themeManagerView:self collectionView:collectionView didSelectItemCell:cell forItemAtIndexPath:indexPath];
    }
    id<CustomerLayoutSectionModuleProtocol>module = self.dataSourceList[indexPath.section];
    id<CollectionCellModelProtocol>model = module.sectionDataList[indexPath.row];
    if ([model.dataSource isKindOfClass:[STLAdvEventSpecialModel class]]) {
        STLAdvEventSpecialModel *modelSpecial = (STLAdvEventSpecialModel *)model.dataSource;
        
        if (modelSpecial.hasRule) {
            return;
        }
        OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] initWhtiSpecialModel:modelSpecial];
        
        NSString *pageName = [UIViewController currentTopViewControllerPageName];
        NSDictionary *sensorsDicClick = @{@"page_name":STLToString(pageName),
                                          @"attr_node_1":@"other",
                                          @"attr_node_2":@"collection_banner",
                                          @"attr_node_3":@"",
                                          @"position_number":@(indexPath.row + 1),
                                          @"venue_position":@"",
                                          @"action_type":@([advEventModel advActionType]),
                                          @"url":[advEventModel advActionUrl],
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDicClick];
        
        //数据GA埋点曝光 广告点击
                            
                            // item
                            NSMutableDictionary *item = [@{
                        //          kFIRParameterItemID: $itemId,
                        //          kFIRParameterItemName: $itemName,
                        //          kFIRParameterItemCategory: $itemCategory,
                        //          kFIRParameterItemVariant: $itemVariant,
                        //          kFIRParameterItemBrand: $itemBrand,
                        //          kFIRParameterPrice: $price,
                        //          kFIRParameterCurrency: $currency
                            } mutableCopy];


                            // Prepare promotion parameters
                            NSMutableDictionary *promoParams = [@{
                        //          kFIRParameterPromotionID: $promotionId,
                        //          kFIRParameterPromotionName:$promotionName,
                        //          kFIRParameterCreativeName: $creativeName,
                        //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                        //          @"screen_group":@"Home"
                            } mutableCopy];

                            // Add items
                            promoParams[kFIRParameterItems] = @[item];
                            
                            [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
        
        
        if (modelSpecial.pageType == 15 || modelSpecial.pageType == 8) {///当前页面领取优惠券
            if (modelSpecial.pageType == 8) {//一键领取
                [self getCoupon:self.allCoupons indexPath:indexPath];
            } else {
                [self getCoupon:@[modelSpecial] indexPath:indexPath];
            }
        } else{
            [OSSVAdvsEventsManager advEventTarget:self.viewController withEventModel:advEventModel];
        }
        
        return;
    }
    if ([model.dataSource isKindOfClass:[STLHomeCGoodsModel class]]) {
        STLHomeCGoodsModel *productModel = (STLHomeCGoodsModel *)model.dataSource;
        [self goGoodDetail:productModel indexPath:indexPath];
        
        return;
    }
}

#pragma mark - customerlayout datasource

-(id<CustomerLayoutSectionModuleProtocol>)customerLayoutDatasource:(UICollectionView *)collectionView sectionNum:(NSInteger)section
{
    id<CustomerLayoutSectionModuleProtocol>module = self.dataSourceList[section];
    return module;
}

-(NSInteger)customerLayoutThemeMenusSection:(UICollectionView *)collectionView {
    return [self themeMenuDataIndex];
}

- (NSInteger )themeMenuDataIndex {
    
    __block NSInteger section = -1;
    [self.dataSourceList enumerateObjectsUsingBlock:^(id<CustomerLayoutSectionModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[OSSVAsinglViewMould class]]) {
                
                OSSVAsinglViewMould *template = (OSSVAsinglViewMould *)obj;
                if (template.sectionDataList.firstObject &&[template.sectionDataList.firstObject isKindOfClass:[OSSVHomeChannelCCellModel class]]) {
                    section = idx;
                    *stop = YES;
                }
            }
    }];
    
    return section;
}

#pragma mark - menuView datasource

- (NSInteger)numbersOfTitlesInMenuView:(WMMenuView *)menu {
    return [[self gainMenuList] count];
}

- (NSString *)menuView:(WMMenuView *)menu titleAtIndex:(NSInteger)index {
    NSArray *list = [self gainMenuList];
    STLHomeCThemeChannelModel *model = list[index];
    return model.channelName;
}

-(CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index {
    NSArray *list = [self gainMenuList];
    STLHomeCThemeChannelModel *model = list[index];
    NSString *title = model.channelName;
    UIFont *titleFont = [UIFont fontWithName:menu.fontName size:18];
    NSDictionary *attrs = @{NSFontAttributeName: titleFont};
    CGFloat itemWidth = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attrs context:nil].size.width + 5;
    return ceil(itemWidth);
}

- (WMMenuItem *)menuView:(WMMenuView *)menu initialMenuItem:(WMMenuItem *)initialMenuItem atIndex:(NSInteger)index
{
    OSSVHomeCThemeModel *model = [self gainMenuThemeModel];
    initialMenuItem.selectedColor = [UIColor colorWithHexColorString:model.colour];
    return initialMenuItem;
}

- (CGFloat)menuView:(WMMenuView *)menu itemMarginAtIndex:(NSInteger)index
{
    return 10;
}

- (void)menuView:(WMMenuView *)menu didSelectedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {

    menu.selectIndex = index;
    //约定好，最后一排肯定是商品流
    id<CustomerLayoutSectionModuleProtocol>module = [self.dataSourceList lastObject];
    if (![module isKindOfClass:[OSSVWaterrFallViewMould class]]) {
        return;
    }
    OSSVCustThemePrGoodsListCacheModel *cacheModel = [self.customProductListCache objectForKey:@(index)];
    //保存上一个的位置，数据
    [self saveProductList:currentIndex list:module.sectionDataList offsetY:self.themeCollectionView.contentOffset pageIndex:0];
    if (cacheModel) {
        //如果有缓存，直接替换缓存
        [module.sectionDataList removeAllObjects];
        [module.sectionDataList addObjectsFromArray:cacheModel.cacheList];
        [self.layout reloadSection:[self.dataSourceList count] - 1];
        [self.themeCollectionView performBatchUpdates:^{
            [self.themeCollectionView reloadSections:[NSIndexSet indexSetWithIndex:[self.dataSourceList count] - 1]];
        } completion:NULL];
        if ([self menuViewIsFloating]) {
            ///悬浮使使用缓存的位置
//            if (!CGPointEqualToPoint(cacheModel.cacheOffset, CGPointZero)) {
//                [self.themeCollectionView setContentOffset:cacheModel.cacheOffset animated:NO];
//            }else{
                [self.themeCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:[self.dataSourceList count] - 2] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//            }
            [self resetMenuOffset];
        }else{
            ///不悬浮时使用当前的位置
            [self resetMenuOffset];
        }
    }
    self.themeCollectionView.mj_footer.hidden = NO;
    if (cacheModel.footStatus == FooterRefrestStatus_Show) {
        [self.themeCollectionView.mj_footer resetNoMoreData];
    }else if (cacheModel.footStatus == FooterRefrestStatus_NoMore){
        [self.themeCollectionView.mj_footer endRefreshingWithNoMoreData];
    }else{
        self.themeCollectionView.mj_footer.hidden = YES;
    }
    [self menuEndfootRefresh];
}

#pragma mark - scroller delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isChannel)return;
        
    CGFloat lastSectionHeight = [self.layout customerLastSectionFirstViewTop];
    CGFloat scrollerOffsetY = scrollView.contentOffset.y;
    if (_menuView) {
        CGFloat y = lastSectionHeight - scrollerOffsetY;
        if (y <= 0) {
            y = 0;
        }
        _menuView.frame = CGRectMake(_menuView.x, y, _menuView.width, _menuView.height);
    }
}

#pragma mark - customer layout delegate

-(void)customerLayoutDidLayoutDone {
    if (![_menuView superview]) {
        if (self.isChannel) {
            self.menuView.hidden = NO;
            [self addSubview:self.menuView];
            [self bringSubviewToFront:self.menuView];
            
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                [self arMenuViewHandle];
                [self.menuView resetFrames];
            }
        }
    } else {
        self.menuView.hidden = !self.isChannel;
    }
}

#pragma mark - ========== Menu 菜单 ==========
///保存数据到缓存
-(void)saveProductList:(NSInteger)selectIndex list:(NSMutableArray *)productList offsetY:(CGPoint)offset pageIndex:(NSInteger)pageIndex
{
    OSSVCustThemePrGoodsListCacheModel *cacheModel = [self.customProductListCache objectForKey:@(selectIndex)];
    if (cacheModel) {
        cacheModel.cacheList = [productList mutableCopy];
        if ([self menuViewIsFloating]) {
            //悬浮状态保存悬浮状态的位置
            cacheModel.cacheOffset = offset;
        }
    }else{
        OSSVCustThemePrGoodsListCacheModel *model = [[OSSVCustThemePrGoodsListCacheModel alloc] init];
        model.pageIndex = 1;
        model.cacheList = [productList mutableCopy];
        if ([self menuViewIsFloating]) {
            model.cacheOffset = offset;
        }
        [self.customProductListCache setObject:model forKey:@(selectIndex)];
    }
}

-(void)firstSaveProductList:(NSInteger)index list:(NSMutableArray *)productList sort:(NSString *)sort {
    OSSVCustThemePrGoodsListCacheModel *model = [[OSSVCustThemePrGoodsListCacheModel alloc] init];
    
    if (productList.count > 0) {
        model.pageIndex = 1;
    }
    model.cacheList = [productList mutableCopy];
    model.sort = sort;
    CGPoint offset = CGPointMake(0, [self.layout customerSectionFirstAttribute:[self.dataSourceList count] - 2].origin.y);
    model.floatingOffset = offset;
    model.footStatus = FooterRefrestStatus_Show;
    model.index = index;
    [self.customProductListCache setObject:model forKey:@(index)];
}

-(void)resetMenuOffset {
    CGFloat scrollerOffsetY = self.themeCollectionView.contentOffset.y;
    CGFloat lastSectionHeight = [self.layout customerSectionFirstAttribute:[self.dataSourceList count] - 2].origin.y;
    CGFloat y = lastSectionHeight - scrollerOffsetY;
    
    if (y <= 0) {
        y = 0;
    }
    _menuView.frame = CGRectMake(0, y, _menuView.width, _menuView.height);
}

///Menu视图是否悬浮
-(BOOL)menuViewIsFloating {
    if (_menuView.y == 0) {
        return YES;
    }
    return NO;
}

-(NSArray *)gainMenuList {
        
    NSInteger count = [self.dataSourceList count];
    if (count >= 2) {
        id<CustomerLayoutSectionModuleProtocol>module = self.dataSourceList[count - 2];
        id<CollectionCellModelProtocol>model = [module.sectionDataList firstObject];
        OSSVHomeCThemeModel *themeModel = (OSSVHomeCThemeModel *)model.dataSource;
        if ([themeModel isKindOfClass:[OSSVHomeCThemeModel class]] && STLJudgeNSArray(themeModel.channel)) {
            return themeModel.channel;
        }
    } else if(count == 1) {
        id<CustomerLayoutSectionModuleProtocol>module = self.dataSourceList.firstObject;
        id<CollectionCellModelProtocol>model = [module.sectionDataList firstObject];
        OSSVHomeCThemeModel *themeModel = (OSSVHomeCThemeModel *)model.dataSource;
        if ([themeModel isKindOfClass:[OSSVHomeCThemeModel class]] && STLJudgeNSArray(themeModel.channel)) {
            return themeModel.channel;
        }
    }
    return @[];
}

-(OSSVHomeCThemeModel *)gainMenuThemeModel {
    if (STLJudgeNSArray(self.dataSourceList) && self.dataSourceList.count >= 2) {
        OSSVHomeChannelCCellModel *model = [[self.dataSourceList objectAtIndex:[self.dataSourceList count] - 2].sectionDataList firstObject];
        OSSVHomeCThemeModel *themeModel = (OSSVHomeCThemeModel *)model.dataSource;
        if ([themeModel isKindOfClass:[OSSVHomeCThemeModel class]]) {
            return themeModel;
        }
    } else if(STLJudgeNSArray(self.dataSourceList) && self.dataSourceList.count == 1) {
        
        OSSVHomeChannelCCellModel *model = [[self.dataSourceList objectAtIndex:1].sectionDataList firstObject];
        OSSVHomeCThemeModel *themeModel = (OSSVHomeCThemeModel *)model.dataSource;
        if ([themeModel isKindOfClass:[OSSVHomeCThemeModel class]]) {
            return themeModel;
        }
    }
    return [[OSSVHomeCThemeModel alloc] init];
}

-(void)menuEndfootRefresh {
    NSInteger currentIndex = self.menuView.selectIndex;
    OSSVCustThemePrGoodsListCacheModel *cacheModel = [self.customProductListCache objectForKey:@(currentIndex)];
    if (cacheModel) {
        switch (cacheModel.footStatus) {
            case FooterRefrestStatus_Show:
                [self.themeCollectionView.mj_footer endRefreshing];
                break;
            case FooterRefrestStatus_NoMore:
                [self.themeCollectionView.mj_footer endRefreshingWithNoMoreData];
                break;
            case FooterRefrestStatus_Hidden:
                [self.themeCollectionView.mj_footer resetNoMoreData];
                break;
            default:
                break;
        }
    }
}

#pragma mark - ========== cell 事件代理 ==========

- (void)stl_scrollerCollectionViewCell:(OSSVScrollCCell *)scorllerCell itemCell:(UICollectionViewCell *)cell {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:themeCell:itemCell:isMore:)]) {
        BOOL isMore = ([scorllerCell isMoreButton] && [scorllerCell.datasourceModel.goods_list count]);
        [self.delegate stl_themeManagerView:self collectionView:self.themeCollectionView themeCell:scorllerCell itemCell:cell isMore:isMore];
    }
}

- (void)stl_themeGoodsRankModuleCCell:(OSSVThemeGoodsItesRankModuleCCell *)scrollerGoodsCCell selectItemCell:(OSSVThemeGoodsItesRankCCell *)goodsItemCell isMore:(BOOL)isMore {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:themeCell:itemCell:isMore:)]) {
        [self.delegate stl_themeManagerView:self collectionView:self.themeCollectionView themeCell:scrollerGoodsCCell itemCell:goodsItemCell isMore:NO];
    }
}


- (void)stl_themeGoodsRankModuleCCell:(OSSVThemeGoodsItesRankModuleCCell *)scrollerGoodsCCell selectItemCell:(OSSVThemeGoodsItesRankCCell *)goodsItemCell addMCart:(STLHomeCGoodsModel *)model {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:themeCell:itemCell:addCart:)]) {
        [self.delegate stl_themeManagerView:self collectionView:self.themeCollectionView themeCell:scrollerGoodsCCell itemCell:goodsItemCell addCart:model];
    }
}

// 还未测试
- (void)stl_themeGoodsRankCCell:(OSSVThemeGoodsItesRankCCell *)cell addCart:(STLHomeCGoodsModel *)model {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:themeCell:itemCell:addCart:)]) {
        [self.delegate stl_themeManagerView:self collectionView:self.themeCollectionView themeCell:cell itemCell:nil addCart:model];
    }
}

- (void)stl_themeGoodsRankCCell:(OSSVThemeGoodsItesRankCCell *)cell addWishList:(STLHomeCGoodsModel *)model{
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:themeCell:itemCell:addCart:)]) {
        [self.delegate stl_themeManagerView:self collectionView:self.themeCollectionView themeCell:cell itemCell:nil addWishList:model];
    }
}


- (void)stl_themeZeorActivityCCell:(OSSVThemeZeorsActivyCCell *)zeorActivityCCell selectItemCell:(STLThemeZeorGoodsItemCell *)goodsItemCell isMore:(BOOL)isMore{
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:themeCell:itemCell:isMore:)]) {
        [self.delegate stl_themeManagerView:self collectionView:self.themeCollectionView themeCell:zeorActivityCCell itemCell:goodsItemCell isMore:isMore];
    }
}

- (void)stl_themeZeorActivityDoubleCCell:(OSSVZeroActivyDoulesLineCCell *)zeorActivityCCell selectItemCell:(STLThemeZeorDoubleGoodsItemCell *)goodsItemCell isMore:(BOOL)isMore{
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:themeCell:itemCell:isMore:)]) {
        [self.delegate stl_themeManagerView:self collectionView:self.themeCollectionView themeCell:zeorActivityCCell itemCell:goodsItemCell isMore:isMore];
    }
}

- (void)stl_themeZeorActivityDoubleCCell:(OSSVZeroActivyDoulesLineCCell *)zeorActivityCCell selectItemCell:(STLThemeZeorDoubleGoodsItemCell *)goodsItemCell addCart:(OSSVThemeZeroPrGoodsModel *)model{
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:themeCell:itemCell:addCart:)]) {
        [self.delegate stl_themeManagerView:self collectionView:self.themeCollectionView themeCell:zeorActivityCCell itemCell:goodsItemCell addCart:model];
    }
}

//优惠劵组件的代理方法
-(void)stl_themeCouponsCCell:(OSSVThemesCouponsCCell *)themeCouponsCCell couponsString:(NSString *)couponsString{
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:themeCell:getCoupons:)]) {
        [self.delegate stl_themeManagerView:self collectionView:self.themeCollectionView themeCell:themeCouponsCCell getCoupons:couponsString];
    }
}

- (void)stl_asingleCCell:(OSSVAsinglesAdvCCell *)cell contentModel:(id)model {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:themeCell:itemCell:isMore:)]) {
        [self.delegate stl_themeManagerView:self collectionView:self.themeCollectionView themeCell:cell itemCell:nil isMore:NO];
    }
}


- (void)stl_scrollerGoodsCCell:(OSSVScrolllGoodsCCell *)scrollerGoodsCCell selectItemCell:(nonnull STLScrollerGoodsItemCell *)goodsItemCell isMore:(BOOL)isMore{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:themeCell:itemCell:isMore:)]) {
        [self.delegate stl_themeManagerView:self collectionView:self.themeCollectionView themeCell:scrollerGoodsCCell itemCell:goodsItemCell isMore:isMore];
    }
}

- (void)goGoodDetail:(STLHomeCGoodsModel *)model indexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [self.themeCollectionView cellForItemAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:themeCell:goodsModel:)]) {
        [self.delegate stl_themeManagerView:self collectionView:self.themeCollectionView themeCell:cell goodsModel:model];
    }
}

-(void)getCoupon:(NSArray <STLAdvEventSpecialModel *>*)coupns indexPath:(NSIndexPath *)indexPath{
    
    __block NSString *couponIds = @"";
    if (STLJudgeNSArray(coupns)) {
        [coupns enumerateObjectsUsingBlock:^(STLAdvEventSpecialModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            /* 1.3.8
             get_method
             coin_exchange--金币兑换；draw--抽奖；push--推送；code_exchange--优惠码兑换；check_in--签到;initiative--主动免费领取
             */
            //暂时没有优惠券name
            NSDictionary *sensorsDic = @{@"coupon_name":@"",
                                        @"coupon_id":STLToString(obj.url),
                                         @"get_method":@"initiative",
            };
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"ReceiveDiscount" parameters:sensorsDic];
            if (STLIsEmptyString(couponIds)) {
                couponIds = [NSString stringWithFormat:@"%@",obj.url];
            } else {
                couponIds = [NSString stringWithFormat:@"%@,%@",couponIds,obj.url];
            }
        }];
    }
    
    if (STLIsEmptyString(couponIds)) {
        return;
    }
    
    UICollectionViewCell *cell = [self.themeCollectionView cellForItemAtIndexPath:indexPath];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeManagerView:collectionView:themeCell:getCoupons:)]) {
        [self.delegate stl_themeManagerView:self collectionView:self.themeCollectionView themeCell:cell getCoupons:couponIds];
    }
}



#pragma mark - setter / getter

- (void)setBgColor:(UIColor *)bgColor {
    if (!bgColor) {
        if (APP_TYPE == 3) {
            bgColor = OSSVThemesColors.stlWhiteColor;
        } else {
            bgColor = OSSVThemesColors.col_F6F6F6;
        }
    }
    _bgColor = bgColor;
    self.themeCollectionView.backgroundColor = bgColor;
}
- (NSMutableArray *)allCoupons {
    if (!_allCoupons) {
        _allCoupons = [[NSMutableArray alloc] init];
    }
    return _allCoupons;
}

-(STLThemeCollectionView *)themeCollectionView
{
    if (!_themeCollectionView) {
        _themeCollectionView = ({
            self.layout = [[OSSVThemesMainLayout alloc] init];
            self.layout.dataSource = self;
            self.layout.delegate = self;
            self.layout.showBottomsGoodsSeparate = YES;
            STLThemeCollectionView *collectionView = [[STLThemeCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
            collectionView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
            collectionView.showsVerticalScrollIndicator = YES;
            collectionView.dataSource = self;
            collectionView.delegate = self;
            if (APP_TYPE == 3) {
                collectionView.backgroundColor = OSSVThemesColors.stlWhiteColor;
            } else {
                collectionView.backgroundColor = OSSVThemesColors.col_F6F6F6;
            }
            collectionView.emptyDataSetSource = self;
            collectionView.emptyDataSetDelegate = self;
            
            [collectionView registerClass:[OSSVAsinglesAdvCCell class] forCellWithReuseIdentifier:[OSSVAPPNewThemeMultiCCellModel reuseIdentifier]];
            [collectionView registerClass:[OSSVAsinglesAdvCCell class] forCellWithReuseIdentifier:[OSSVAsingleCCellModel reuseIdentifier]];
            [collectionView registerClass:[OSSVPrGoodsSPecialCCell class] forCellWithReuseIdentifier:[OSSVProGoodsCCellModel reuseIdentifier]];
            [collectionView registerClass:[OSSVMultiPGoodsSPecialCCell class] forCellWithReuseIdentifier:[OSSVMultProGoodsCCellModel reuseIdentifier]];

            [collectionView registerClass:[OSSVThemeZeorsActivyCCell class] forCellWithReuseIdentifier:[OSSVThemesZeroActivyCellModel reuseIdentifier]];
            [collectionView registerClass:[OSSVZeroActivyDoulesLineCCell class] forCellWithReuseIdentifier:[OSSVThemeZeroActivyTwoCCellModel reuseIdentifier]];
            [collectionView registerClass:[OSSVThemesCouponsCCell class] forCellWithReuseIdentifier:[OSSVThemeCouponCCellModel reuseIdentifier]];

            [collectionView registerClass:[OSSVThemesChannelsCCell class] forCellWithReuseIdentifier:[OSSVHomeChannelCCellModel reuseIdentifier]];
            [collectionView registerClass:[OSSVScrollCCell class] forCellWithReuseIdentifier:[OSSVScrollCCellModel reuseIdentifier]];
            [collectionView registerClass:[OSSVThemeGoodsItesRankCCell class] forCellWithReuseIdentifier:[OSSVThemeItemsGoodsRanksCCellModel reuseIdentifier]];
            [collectionView registerClass:[OSSVThemeGoodsItesRankModuleCCell class] forCellWithReuseIdentifier:[OSSVThemeItemGoodsRanksModuleModel reuseIdentifier]];
            [collectionView registerClass:[OSSVScrolllGoodsCCell class] forCellWithReuseIdentifier:[OSSVScrollGoodsItesCCellModel reuseIdentifier]];
            
            collectionView;
        });
    }
    return _themeCollectionView;
}

-(NSMutableDictionary *)customProductListCache
{
    if (!_customProductListCache) {
        _customProductListCache = [[NSMutableDictionary alloc] init];
    }
    return _customProductListCache;
}

-(NSMutableArray<id<CustomerLayoutSectionModuleProtocol>> *)dataSourceList
{
    if (!_dataSourceList) {
        _dataSourceList = [[NSMutableArray alloc] init];
    }
    return _dataSourceList;
}

-(WMMenuView *)menuView
{
    if (!_menuView) {
        _menuView = ({
            CGRect firstSectionRect = [self.layout customerSectionFirstAttribute:[self.dataSourceList count] - 2];
            WMMenuView *view = [[WMMenuView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(firstSectionRect), firstSectionRect.size.width, firstSectionRect.size.height)];
            view.backgroundColor = [UIColor whiteColor];
            view.style = WMMenuViewStyleLine;
            view.layoutMode = WMMenuViewLayoutModeLeft;
            view.speedFactor = 5;
            view.progressViewCornerRadius = 10;
            view.delegate = self;
            view.dataSource = self;
            OSSVHomeCThemeModel *themeModel = [self gainMenuThemeModel];
            view.lineColor = [UIColor colorWithHexColorString:themeModel.colour];
            view;
        });
    }
    return _menuView;
}

- (OSSVCouponsAlertView *)couponAlertView {
    if (!_couponAlertView) {
        _couponAlertView = [[OSSVCouponsAlertView alloc] initWithFrame:CGRectZero];
        _couponAlertView.operateBlock = ^{
            
        };
    }
    return _couponAlertView;
}

//- (STLActionSheet *)goodsAttributeSheet {
//    if (!_goodsAttributeSheet) {
//        _goodsAttributeSheet = [[STLActionSheet alloc] initWithFrame:self.view.bounds];
//        _goodsAttributeSheet.isNewUser = YES;
//        _goodsAttributeSheet.specialId = self.customId;
//        _goodsAttributeSheet.sourceType = STLAppsflyerGoodsSourceThemeActivity;
//        _goodsAttributeSheet.isListSheet = YES;
//        _goodsAttributeSheet.isQuickAddCart = YES;
//        @weakify(self)
//        _goodsAttributeSheet.cancelViewBlock = ^{   // cancel block
//            @strongify(self)
//            [self hideGoodsAttribute];
//        };
//        _goodsAttributeSheet.attributeBlock = ^(NSString *goodsId,NSString *wid) {
//            @strongify(self)
//            [self requestAttribute:goodsId wid:wid];
//        };
//
//        _goodsAttributeSheet.zeroStockBlock = ^(NSString *goodsId, NSString *wid) {
//            @strongify(self)
//            [self requestAttribute:goodsId wid:wid];
//            [self requestCustomData];
//        };
//        _goodsAttributeSheet.goToDetailBlock = ^(NSString *goodsId, NSString *wid) {
//            @strongify(self)
//            GoodsDetailsViewController *detailVC = [[GoodsDetailsViewController alloc] init];
//            detailVC.goodsId = goodsId;
//            detailVC.wid = wid;
//            detailVC.sourceType = STLAppsflyerGoodsSourceDetailRecommend;
//            [self.navigationController pushViewController:detailVC animated:YES];
//
//            [self.goodsAttributeSheet dismiss];
//        };
//        _goodsAttributeSheet.collectionStateBlock = ^(BOOL isCollection, NSString *wishCount) {
//            @strongify(self)
//            if ([self.goodsAttributeSheet.baseInfoModel.goodsId isEqualToString:self.tempNewsUserProductModel.goodsId]) {
//                self.tempNewsUserProductModel.isCollect = isCollection;
//            }
//        };
//    }
//    return _goodsAttributeSheet;
//}


#pragma mark - ========== 初始化下拉刷新控件 ==========
/** 初始化下拉刷新控件 */

- (void)addListHeaderRefreshBlock:(STLRefreshingBlock)headerBlock
                PullingShowBannerBlock:(PullingBannerBlock)pullingBannerBlock
                    footerRefreshBlock:(STLRefreshingBlock)footerBlock
                  startRefreshing:(BOOL)startRefreshing {
    
    
//    [self.themeCollectionView addCommunityHeaderRefreshBlock:headerBlock
//                                 PullingShowBannerBlock:pullingBannerBlock footerRefreshBlock:footerBlock
//                                        startRefreshing:startRefreshing];
    
    
    if (headerBlock) {
        @weakify(self)
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self)
            
            //1.先移除页面上已有的提示视图
            [self.themeCollectionView removeOldTipBgView];
            
            //2.每次下拉刷新时先结束上啦
            [self.themeCollectionView.mj_footer endRefreshing];
            
            if (headerBlock) {
               headerBlock();
            }
        }];
        // 隐藏时间
        header.lastUpdatedTimeLabel.hidden = YES;

        // 隐藏状态
        header.stateLabel.hidden = YES;
        
        self.themeCollectionView.mj_header = header;
        
        //是否需要立即刷新
        if (startRefreshing) {
            [self.themeCollectionView.mj_header beginRefreshing];
        }
    }
    
    if (footerBlock) {
        MJRefreshFooter *footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
            footerBlock();
        }];
        self.themeCollectionView.mj_footer = footer;
//        self.footerBlock = footerBlock;
//        self.themeCollectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(customeFootRefreshAction)];
        //这里需要先隐藏,否则已进入页面没有数据也会显示上拉View
        self.themeCollectionView.mj_footer.hidden = YES;
    }
    
}

- (void)customeFootRefreshAction {
    if (self.footerBlock) {
        self.footerBlock();
    }
}
/**
 * 设置是否能上拉加载更多
 */
- (void)addFooterLoadingMore:(BOOL)showLoadingMore footerBlock:(void (^)(void))footerBlock {
    
    if (showLoadingMore && (!self.themeCollectionView.mj_footer || self.themeCollectionView.mj_footer.isHidden)) {
        self.themeCollectionView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
            if (footerBlock) {
                footerBlock();
            }
        }];

//        self.themeCollectionView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(customeFootRefreshAction)];
//        self.footerBlock = footerBlock;
    }
    self.themeCollectionView.mj_footer.hidden = !showLoadingMore;
}

- (void)endHeaderOrFooterRefresh:(BOOL)isEndHeader {
    
    if (self.themeCollectionView.mj_header && self.themeCollectionView.mj_header.isRefreshing) {
        [self.themeCollectionView.mj_header endRefreshing];
    }
    if (isEndHeader) {
        if (self.themeCollectionView.mj_header) {
            [self.themeCollectionView.mj_header endRefreshing];
        }
    } else {
        if (self.themeCollectionView.mj_footer) {
            [self.themeCollectionView.mj_footer endRefreshing];
        }
    }
}

- (void)forbidCollectionRecognizeSimultaneously:(BOOL)forbid {
    self.themeCollectionView.isRecognizeSimultaneously = forbid;
}


#pragma mark - DZNEmptyDataSetSource Methods
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    self.emptyViewManager.customNoDataView = [self makeCustomNoDataView];
    return [self.emptyViewManager accordingToTypeReBackView:self.emptyShowType];
}

#pragma mark make - privateCustomView(NoDataView)
- (UIView *)makeCustomNoDataView {
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectZero];
    customView.backgroundColor = [UIColor whiteColor];
    YYAnimatedImageView *imageView = [YYAnimatedImageView new];
    imageView.image = [UIImage imageNamed:@"loading_failed"];
    imageView.userInteractionEnabled = YES;
    [customView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(customView.mas_top).offset(52 * DSCREEN_HEIGHT_SCALE);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = OSSVThemesColors.col_333333;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.text = STLLocalizedString_(@"load_failed", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [customView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(36);
        make.width.mas_equalTo(SCREEN_WIDTH - 30);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [OSSVThemesColors col_262626];
    button.titleLabel.font = [UIFont stl_buttonFont:14];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (APP_TYPE == 3) {
        [button setTitle:STLLocalizedString_(@"retry", nil) forState:UIControlStateNormal];
    } else {
        [button setTitle:STLLocalizedString_(@"retry", nil).uppercaseString forState:UIControlStateNormal];
    }
    [button addTarget:self action:@selector(emptyOperationTouch) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 3;
    [customView addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(33);
        make.centerX.mas_equalTo(customView.mas_centerX);
        make.width.mas_equalTo(@180);
        make.height.mas_equalTo(@40);
    }];
    
    return customView;
}

//- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
//    return 0;
//}

- (void)emptyOperationTouch {
    if (self.emptyTouchBlock) {
        self.emptyTouchBlock();
    }
}

#pragma mark setters and getters

- (EmptyCustomViewManager *)emptyViewManager {
    if (!_emptyViewManager) {
        _emptyViewManager = [[EmptyCustomViewManager alloc] init];
        @weakify(self)
        _emptyViewManager.emptyRefreshOperationBlock = ^{
            @strongify(self)
            if (self.emptyTouchBlock) {
                self.emptyTouchBlock();
            }
        };
    }
    return _emptyViewManager;
}

@end


@implementation STLThemeCollectionView

/**
 * 此方法是支持多手势，当滑动子控制器中的scrollView时，外层 scrollView 也能接收滑动事件
 * 当前类仅供社区个人中心三个列表使用
 */

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    //STLLog(@"inView: %@",otherGestureRecognizer.view);
//    if ([otherGestureRecognizer.view isKindOfClass:[STLThemeCollectionView class]] ||
//        [otherGestureRecognizer.view isKindOfClass:[WMScrollView class]] || self.isRecognizeSimultaneously) {//添加不支持
//        return NO;
//    }
//
//    return YES;
//}

@end
