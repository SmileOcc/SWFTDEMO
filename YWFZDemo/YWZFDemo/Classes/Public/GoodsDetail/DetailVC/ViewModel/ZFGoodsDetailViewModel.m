//
//  ZFGoodsDetailViewModel.m
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailViewModel.h"
#import "ZFGoodsDetailViewModeImportFiles.h"

@interface ZFGoodsDetailViewModel ()

//切换到相同商品时缓存响应模型直接显示
@property (nonatomic, strong) NSMutableDictionary   *detailModelCacheDict;

@property (nonatomic, strong) NSArray               *cellTypeModelArr;
@property (nonatomic, strong) NSMutableArray        *similarGoodsSNArray;

@property (nonatomic, strong) NSDictionary          *realTimeRequestParmaters;
@property (nonatomic, strong) NSDictionary          *realTimeResponseDataDict;
@property (nonatomic, strong) NSDictionary          *cdnRequestParmaters;
@property (nonatomic, strong) NSDictionary          *cdnResponseDataDict;
@property (nonatomic, strong) NSURLSessionDataTask  *goodsDetailBtsTask;
@property (nonatomic, strong) NSURLSessionDataTask  *goodsDetailTask;
@property (nonatomic, strong) NSURLSessionDataTask  *goodsRealTimeTask;
@property (nonatomic, strong) NSURLSessionDataTask  *goodsCouponTask;
@property (nonatomic, strong) NSURLSessionDataTask  *goodsShowsTask;
@property (nonatomic, strong) NSURLSessionDataTask  *goodsReviewsTask;
@property (nonatomic, strong) NSURLSessionDataTask  *goodsRecommendTask;
@property (nonatomic, strong) NSURLSessionDataTask  *goodsGroupBuyTask;
@property (nonatomic, strong) NSURLSessionDataTask  *collocationBuyTask;
@property (nonatomic, strong) NSURLSessionDataTask  *goodsOutfitsTask;
@property (nonatomic, copy)   NSString              *goodsId;
@property (nonatomic, copy)   NSString              *freeGiftId;
@property (nonatomic, strong) NSDictionary          *detailInfoDict;
@property (nonatomic, assign) NSInteger             selectSkuCount;/** 选择SKU次数，用于AppFlys统计 */

/** ================== 主要接口没回来前先备份其他接口信息 ================== */
@property (nonatomic, strong) NSArray               *couponListModelArr;
@property (nonatomic, strong) NSArray               *reviewModelArray;
@property (nonatomic, strong) ReviewsSizeOverModel  *reviewsRankingModel;
@property (nonatomic, strong) NSArray               *showExploreModelArray;
@property (nonatomic, strong) NSArray               *outfitsModelArray;
@property (nonatomic, strong) ZFCollocationBuyModel *collocationBuyModel;
@property (nonatomic, strong) AFparams              *af_recommend_params;
@property (nonatomic, strong) NSArray               *recommendModelArray;
@property (nonatomic, strong) NSMutableArray        *recommendSimilarModelArray;
@property (nonatomic, assign) BOOL                  hasTrackProductReview;
@property (nonatomic, assign) BOOL                  hasTrackCollocationBuy;
@property (nonatomic, assign) BOOL                  hasAnalyticsOnce;// 标记同一个sku请求/切换商品只统计一次
@property (nonatomic, strong) UIImage               *placeHoldImage;
@property (nonatomic, assign) BOOL                  shouldScrollToRecommed;

@property (nonatomic, assign) BOOL                  showProductDescBts;
@end

@implementation ZFGoodsDetailViewModel

- (void)dealloc {
    [self cancelAllDataTask];
    [self initGoodsCountDownTimer:NO];
    YWLog(@"关闭商详页面时已取消所有接口请求 dealloc");
}

- (void)saveIdInfo:(NSDictionary *)detailInfoDict {
    self.detailInfoDict = detailInfoDict;
    self.goodsId = detailInfoDict[@"goods_id"];
    self.freeGiftId = detailInfoDict[@"manzeng_id"];
}

#pragma mark -============ 数据处理 ============

- (void)configuDetailViewCellType:(GoodsDetailModel *)detailModel
                      refreshType:(ZFGoodsDetailCellType)refreshType
                       refreshObj:(id)refreshObj
                     shouldReload:(BOOL)shouldReloadData
{
    if (self.cellTypeModelArr) {
        NSInteger index = 0;
        for (NSInteger i=0; i<self.cellTypeModelArr.count; i++) {
            index = i;
            ZFGoodsDetailCellTypeModel *cellTypeModel = self.cellTypeModelArr[i];
            cellTypeModel.detailModel = detailModel;
            if (refreshType != 0 && cellTypeModel.cellType != refreshType) continue;
            
            cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, 0);
            cellTypeModel.detailCellActionBlock = nil;
            cellTypeModel.sectionItemCount = 0;
            
            // 重新配置匹配的Cell
            [self setupSectionItemInfo:cellTypeModel
                           detailModel:detailModel
                           refreshType:refreshType
                            refreshObj:refreshObj];
        }
        if (shouldReloadData) {
            YWLog(@"刷新页面对应Section==%ld", refreshType);
            [self.goodsDetailView reloadDetailView:NO sectionIndex:index];
        }
    } else {
        // 获取商详页面所有的Cell类型
        NSArray *cellTypeArr = [ZFGoodsDetailCellTypeModel fetchDetailAllCellTypeArray];
        NSMutableArray *cellTypeModelArr = [NSMutableArray array];
        
        for (NSInteger i=0; i<cellTypeArr.count; i++) {
            NSDictionary *cellTypeDict = cellTypeArr[i];
            
            ZFGoodsDetailCellTypeModel *cellTypeModel = [[ZFGoodsDetailCellTypeModel alloc] init];
            cellTypeModel.cellType = [cellTypeDict.allKeys.firstObject integerValue];
            cellTypeModel.sectionItemCellClass = cellTypeDict.allValues.firstObject;
            
            cellTypeModel.detailModel = detailModel;
            cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, 0);
            cellTypeModel.detailCellActionBlock = nil;
            cellTypeModel.sectionItemCount = 0;
            
            [self setupSectionItemInfo:cellTypeModel
                           detailModel:detailModel
                           refreshType:refreshType
                            refreshObj:refreshObj];
            [cellTypeModelArr addObject:cellTypeModel];
        }
        self.cellTypeModelArr = cellTypeModelArr;
        self.goodsDetailView.sectionTypeModelArr = self.cellTypeModelArr;
    }
}

- (void)setupSectionItemInfo:(ZFGoodsDetailCellTypeModel *)cellTypeModel
                 detailModel:(GoodsDetailModel *)detailModel
                 refreshType:(ZFGoodsDetailCellType)refreshType
                  refreshObj:(id)refreshObj
{
    switch (cellTypeModel.cellType) {
        case ZFGoodsDetailCellTypeScrollBanner: // 一定显示: 商品大图
        {
            cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, 420);
            cellTypeModel.sectionItemCount = 1;
            cellTypeModel.detailCellActionBlock = self.goodsInfoCollectActionBlock;
            
            if (!self.placeHoldImage) {
                self.placeHoldImage = ((ZFGoodsDetailViewController *)self.actionProtocol).transformSourceImageView.image;
            }
            cellTypeModel.placeHoldImage = self.placeHoldImage;
            
            NSMutableArray *pictUrlArray = [NSMutableArray arrayWithCapacity:detailModel.pictures.count];
            for (int i = 0; i < detailModel.pictures.count; i++) {
                GoodsDetailPictureModel *pict = detailModel.pictures[i];
                if ([pict.goods_img_app length] > 0) {
                    [pictUrlArray addObject:pict.goods_img_app];
                } else {
                    [pictUrlArray addObject:pict.wp_image];
                }
            }
            detailModel.bannerPicturesUrlArray = pictUrlArray;
        }
            break;
        case ZFGoodsDetailCellTypeActivity: // 不一定显示: 商品活动信息
        {
            // 商详页活动类型
            if (detailModel.activityModel.type != GoodsDetailActivityTypeNormal
                || !ZFIsEmptyString(detailModel.activityIconModel.activityIcon)) {
                cellTypeModel.sectionItemCount = 1;
                
                // 根据服务端返回的比例计算高度
                CGFloat width = [cellTypeModel.detailModel.activityIconModel.width floatValue];
                CGFloat height = [cellTypeModel.detailModel.activityIconModel.height floatValue];
                CGFloat cellHeight = (width==0) ? 52 : (height * KScreenWidth / width);
                cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, cellHeight);
                cellTypeModel.detailCellActionBlock = self.actionProtocol.activityCellActionBlock;
            }
        }
            break;
        case ZFGoodsDetailCellTypeGoodsInfo: // 一定显示: 商品价格
        {
            cellTypeModel.sectionItemCount = 1;
            cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, 120);
            cellTypeModel.detailCellActionBlock = self.goodsInfoReviewActionBlock;
        }
            break;
        case ZFGoodsDetailCellTypeSelectStandard:   // 一定显示: 商品规格高度
        {
            cellTypeModel.sectionItemCount = 1;
            CGFloat celLHeight = [ZFGoodsDetailGoodsSelectSizeCell fetchSizeCellHeight:cellTypeModel];// 计算高度
            cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, celLHeight);
            cellTypeModel.detailCellActionBlock = self.selectStandardCellActionBlock;
        }
            break;
            
        case ZFGoodsDetailCellTypeProductModelDesc:   // 不一定显示: (BTS显示商品描述信息)
        {
            if (refreshType == ZFGoodsDetailCellTypeProductModelDesc
                && [refreshObj isKindOfClass:[GoodsDetailsProductDescModel class]]) {
                CGFloat htmlTextH = MIN(63, ((GoodsDetailsProductDescModel *)refreshObj).contentViewHeight);//默认不展开
                CGFloat celLHeight = htmlTextH + 105;
                cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, celLHeight);
                cellTypeModel.sectionItemCount = 1;
            } else {
                cellTypeModel.sectionItemCount = 0;
            }
            cellTypeModel.detailCellActionBlock = self.productDescCellActionBock;
        }
            break;
            
        case ZFGoodsDetailCellTypeQualified:    // 不一定显示: 商品其他信息
        {
            if (!ZFIsEmptyString(detailModel.reductionModel.msg)) {
                cellTypeModel.sectionItemCount = 1;
                cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, kCellDefaultHeight);
                cellTypeModel.detailCellActionBlock = self.actionProtocol.qualifiedCellActionBlock;
            }
        }
            break;
        case ZFGoodsDetailCellTypeShippingTips: // 不一定显示: 商品运费信息
        {
            if (!ZFIsEmptyString(detailModel.shipping_tips)) {
                cellTypeModel.sectionItemCount = self.showProductDescBts ? 0 : 1; //bts控制显示
                cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, kCellDefaultHeight);
                cellTypeModel.detailCellActionBlock = self.actionProtocol.normalArrowsActionBlock;
            }
        }
            break;
        case ZFGoodsDetailCellTypeDescription:  // 不一定显示: 商品描述信息
        {
            if (!ZFIsEmptyString(detailModel.desc_url)) {
                cellTypeModel.sectionItemCount = self.showProductDescBts ? 0 : 1; //bts控制显示
                cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, kCellDefaultHeight);
                cellTypeModel.detailCellActionBlock = self.actionProtocol.normalArrowsActionBlock;
            }
        }
            break;
        case ZFGoodsDetailCellTypeModelStats:   // 不一定显示: 商品Model信息
        {
            if (!ZFIsEmptyString(detailModel.model_url)) {
                cellTypeModel.sectionItemCount = self.showProductDescBts ? 0 : 1; //bts控制显示
                cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, kCellDefaultHeight);
                cellTypeModel.detailCellActionBlock = self.actionProtocol.normalArrowsActionBlock;
            }
        }
            break;
        case ZFGoodsDetailCellTypeCoupon:   // 不一定显示: 商品优惠券
        {
            if (refreshType == ZFGoodsDetailCellTypeCoupon && [refreshObj isKindOfClass:[NSArray class]]) {
                cellTypeModel.couponListModelArr = refreshObj;
                
            } else if (self.couponListModelArr) {
                cellTypeModel.couponListModelArr = self.couponListModelArr;
            }
            cellTypeModel.sectionItemCount = (cellTypeModel.couponListModelArr.count > 0) ? 1 : 0;
            cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, kCellDefaultHeight);
            cellTypeModel.detailCellActionBlock = self.actionProtocol.normalArrowsActionBlock;
        }
            break;
        case ZFGoodsDetailCellTypeReviewStar:   // 不一定显示: 评论星级
        {
            if (refreshType == ZFGoodsDetailCellTypeReviewStar
                && [refreshObj isKindOfClass:[ReviewsSizeOverModel class]]) {
                cellTypeModel.reviewsRankingModel = refreshObj;
                
            } else if (self.reviewsRankingModel) {
                cellTypeModel.reviewsRankingModel = self.reviewsRankingModel;
            }
            cellTypeModel.sectionItemCount = (cellTypeModel.reviewsRankingModel) ? 1 : 0;
            cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth,  98 + 44 + 8);
            cellTypeModel.detailCellActionBlock = nil;
        }
            break;
        case ZFGoodsDetailCellTypeReview:       // 不一定显示: 评论数据
        {
            if (refreshType == ZFGoodsDetailCellTypeReview
                && [refreshObj isKindOfClass:[NSArray class]]) {
                cellTypeModel.reviewModelArray = refreshObj;
                
            } else if (self.reviewModelArray) {
                cellTypeModel.reviewModelArray = self.reviewModelArray;
            }
            cellTypeModel.sectionItemCount = cellTypeModel.reviewModelArray.count;
            cellTypeModel.detailCellActionBlock = self.actionProtocol.reviewCellActionBlock;
            cellTypeModel.reviewCellActionBock = self.reviewCellActionBock;
            cellTypeModel.willShowReviewCellBock = self.shouldTrackProductReviewBock;
        }
            break;
        case ZFGoodsDetailCellTypeReviewViewAll:  // 不一定显示: 评论数据Veiw All
        {
            if (refreshType == ZFGoodsDetailCellTypeReviewViewAll
                && [refreshObj isKindOfClass:[NSArray class]]) {
                cellTypeModel.reviewModelArray = refreshObj;
                
            } else if (self.reviewModelArray) {
                cellTypeModel.reviewModelArray = self.reviewModelArray;
            }
            cellTypeModel.sectionItemCount = (cellTypeModel.reviewModelArray.count > 0) ? 1 : 0;
            cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, kCellDefaultHeight);
            cellTypeModel.detailCellActionBlock = self.actionProtocol.reviewCellActionBlock;
        }
            break;
        case ZFGoodsDetailCellTypeShow:     // 不一定显示: 在评论栏上方增加社区帖子Show一栏
        {
            if (refreshType == ZFGoodsDetailCellTypeShow
                && [refreshObj isKindOfClass:[NSArray class]]) {
                detailModel.showExploreModelArray = refreshObj;
                
            } else if (self.showExploreModelArray) {
                detailModel.showExploreModelArray = self.showExploreModelArray;
            }
            cellTypeModel.sectionItemCount = (detailModel.showExploreModelArray.count > 0) ? 1 : 0;
            cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, 188);
            cellTypeModel.detailCellActionBlock = self.actionProtocol.showCellActionBlock;
        }
            break;
        case ZFGoodsDetailCellTypeCollocationBuy:  // 一定显示: 搭配购Cell
        {
            if (refreshType == ZFGoodsDetailCellTypeCollocationBuy
                && [refreshObj isKindOfClass:[ZFCollocationBuyModel class]]) {
                detailModel.collocationBuyModel = refreshObj;
                
            } else if (self.collocationBuyModel) {
                detailModel.collocationBuyModel = self.collocationBuyModel;
            }
            cellTypeModel.sectionItemCount = detailModel.collocationBuyModel ? 1 : 0;
            cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, 220);
            cellTypeModel.detailCellActionBlock = self.actionProtocol.collocationBuyActionBlock;
            cellTypeModel.willShowCollocationBuyCellBock = self.shouldTrackCollocationBuyBock;
        }
            break;
        case ZFGoodsDetailCellTypeOutfits:       // 没有搭配购数据才显示: 穿搭Cell
        {
            if (refreshType == ZFGoodsDetailCellTypeOutfits
                && [refreshObj isKindOfClass:[NSArray class]]) {
                detailModel.outfitsModelArray = refreshObj;
                
            } else if (self.outfitsModelArray) {
                detailModel.outfitsModelArray = self.outfitsModelArray;
            }
            cellTypeModel.sectionItemCount = (detailModel.outfitsModelArray.count > 0) ? 1 : 0;
            cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, 207);
            cellTypeModel.detailCellActionBlock = self.actionProtocol.outfitsCellActionBlock;
        }
            break;
        case ZFGoodsDetailCellTTypeRecommendHeader:   // 不一定显示: 推荐头部
        {
            if (refreshType == ZFGoodsDetailCellTTypeRecommendHeader
                && [refreshObj isKindOfClass:[NSArray class]]) {
                detailModel.recommendModelArray = refreshObj;
                
            } else if (self.recommendModelArray) {
                detailModel.recommendModelArray = self.recommendModelArray;
                if (self.af_recommend_params) {
                    detailModel.af_recommend_params = self.af_recommend_params;
                }
            }
            cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, 8 + kCellDefaultHeight );
            cellTypeModel.sectionItemCount = 1;
            cellTypeModel.detailCellActionBlock = nil;
            cellTypeModel.willShowRecommendCellBock = self.shouldRequestRecommendPortBock;
        }
            break;
        case ZFGoodsDetailCellTTypeRecommend:   // 不一定显示: 推荐:大数据
        {
            if (refreshType == ZFGoodsDetailCellTTypeRecommend
                && [refreshObj isKindOfClass:[NSArray class]]) {
                detailModel.recommendModelArray = refreshObj;
                
            } else if (self.recommendModelArray) {
                detailModel.recommendModelArray = self.recommendModelArray;
                if (self.af_recommend_params) {
                    detailModel.af_recommend_params = self.af_recommend_params;
                }
            }
            CGFloat goodsImageWidth = (KScreenWidth - 12 * 4) / 3;
            CGFloat goodsImageHeight = (ThreeColumnGoodsImageHeight + 8 + 16);
            cellTypeModel.sectionItemSize = CGSizeMake(goodsImageWidth, goodsImageHeight);
            cellTypeModel.sectionItemCount = detailModel.recommendModelArray.count;
            cellTypeModel.detailCellActionBlock = self.actionProtocol.recommendCellActionBlock;
        }
            break;
        default:
            break;
    }
}

#pragma mark -============ 网络请求 ============

/**
 * 商详页面AB布局调整
 * photoAndSimilarBtsDict : @{请求商详博主图, 找相似的bts}
 */
- (void)requestGoodsDetailAllBts:(NSDictionary *)detailInfoDict
{
    [self saveIdInfo:detailInfoDict];
    NSMutableDictionary *btsDict = [NSMutableDictionary dictionary];
    btsDict[kZFBtsIosxaddbag] = kZFBts_A;  // 商详Bts优化(默认A版本)
    
    NSString *region_code = ZFToString([AccountManager sharedManager].accountCountryModel.region_code);
    if ([region_code isEqualToString:@"US"]) {
        btsDict[kZFBtsIosdeliverytime] = @"0";
    }
    
    if ([detailInfoDict[@"photoBts"] boolValue]) {
        // 只有当外部传有博主图标识到商详时,才请求博主图bts
        btsDict[kZFBtsProductPhoto] = kZFBts_A;  // 商详大banner显示博主图bts (默认A版本)
    }
    
    /// 请求商详主要接口判断转圈
    if ([self.actionProtocol respondsToSelector:@selector(showTransformView:)]) {
        [self.actionProtocol showTransformView:YES];
    }
    
    @weakify(self);
    self.goodsDetailBtsTask = [ZFBTSManager requestBtsModelList:btsDict timeoutInterval:3 completionHandler:^(NSArray<ZFBTSModel *> * _Nonnull modelArray, NSError * _Nonnull error) {
        @strongify(self);
        HideLoadingFromView(self.goodsDetailView);
        
        for (ZFBTSModel *btsModel in modelArray) {
            if ([btsModel.plancode isEqualToString:kZFBtsIosxaddbag]) {
                self.showProductDescBts = ![btsModel.policy isEqualToString:kZFBts_A];
            }
        }
        // 请求商详信息
        [self requestGoodsDetailPort:detailInfoDict];
        
        /** 以下接口商详页面只需请求一次 */
        
        // 请求商品拼团信息
        [self requestGoodsGroupBuyPort:self.goodsId];
        
        // 同时请求优惠券列表信息
        [self requestGoodsCouponPort:self.goodsId completion:nil];
    }];
}

/**
 * 请求商详主要信息接口
 */
- (void)requestGoodsDetailPort:(NSDictionary *)detailInfoDict {
    [self saveIdInfo:detailInfoDict];
    [self cancelMainDataTask];
    
    if ([detailInfoDict[kShowLoadingFlag] boolValue]) {
        ShowLoadingToView(self.goodsDetailView);
        //[self.actionProtocol showTransformView:YES];
    }
    @weakify(self);
    [self requestGoodsDetailData:detailInfoDict completion:^(GoodsDetailModel *detailModel) {
        @strongify(self);
        self.detailModel = detailModel;
        
        //判断是否需要创建活动定时器
        if (detailModel.detailMainPortSuccess == YES) {
            [self initGoodsCountDownTimer:YES];
        }
        [self dealwithGoodsDetailPort:detailModel error:nil];
        
    } failure:^(NSError *error) {
        @strongify(self);
        [self dealwithGoodsDetailPort:self.detailModel error:error];
        
        @weakify(self);
        [self.goodsDetailView showDetailEmptyView:error refreshBlock:^{
            @strongify(self);
            [self.actionProtocol showTransformView:YES];
            [self requestGoodsDetailPort:detailInfoDict];
        }];
    }];
}

- (void)calculateHTMLTextToProductModelDescCell:(GoodsDetailModel *)detailModel {
    NSString *text1 = @"<div class=\"xxkkk\">\n<div>  ";//去除头部换行
    if ([detailModel.goods_desc_data containsString:text1]) {
        detailModel.goods_desc_data = [detailModel.goods_desc_data stringByReplacingOccurrencesOfString:text1 withString:@""];
    }
    CGSize size = CGSizeMake(KScreenWidth - 16*2, CGFLOAT_MAX);
    UIFont *font = [UIFont systemFontOfSize:14];
    NSTextAlignment alignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight: NSTextAlignmentLeft;
    @weakify(self)
    [detailModel.goods_desc_data calculateHTMLText:size labelFont:font
                                         lineSpace:@(10)
                                         alignment:alignment
                                        completion:^(NSAttributedString *stringAttributed, CGSize calculateSize) {
        @strongify(self)
        if (!self.detailModel.goods_model_data) { //防止没有模特信息
            GoodsDetailsProductDescModel *modelData = [[GoodsDetailsProductDescModel alloc] init];
            modelData.isEmptyModelData = YES;
            self.detailModel.goods_model_data = modelData;
        }
        
        if ([SystemConfigUtils isRightToLeftShow]) { //V5.5.0:临时处理希伯来语无法解决的崩溃问题
            NSString *dealStr = [stringAttributed.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            //[stringAttributed.string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:dealStr];
            NSRange range = NSMakeRange(0, attributeString.string.length);
            [attributeString addAttribute:NSFontAttributeName value:font range:range];
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 10;
            paragraphStyle.alignment = alignment;
            [attributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
            
            NSStringDrawingOptions options = (NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin);
             CGRect rect = [attributeString boundingRectWithSize:size options:options context:nil];
            self.detailModel.goods_model_data.goodsDescAttriText = attributeString;
            self.detailModel.goods_model_data.contentViewHeight = rect.size.height;
            
        } else {
            self.detailModel.goods_model_data.goodsDescAttriText = stringAttributed;
            self.detailModel.goods_model_data.contentViewHeight = calculateSize.height;
        }
        self.detailModel.goods_model_data.selectedShowMoreFlag = NO;//默认不展开
        
        [self configuDetailViewCellType:self.detailModel
                            refreshType:ZFGoodsDetailCellTypeProductModelDesc
                             refreshObj:self.detailModel.goods_model_data
                           shouldReload:YES];
    }];
}

/**
 * 处理商详cdn接口, 实时信息接口, 非cdn接口请求回调
 */
- (void)dealwithGoodsDetailPort:(GoodsDetailModel *)detailModel error:(NSError *)error
{
    HideLoadingFromView(self.goodsDetailView);
    
    if (self.detailModel.detailMainPortSuccess) {
        [self.actionProtocol showTransformView:NO];
        self.goodsDetailView.detailModel = detailModel;
        
        [self configuDetailViewCellType:detailModel
                            refreshType:0
                             refreshObj:nil
                           shouldReload:YES];
        
        if (self.showProductDescBts) {
            [self calculateHTMLTextToProductModelDescCell:self.detailModel];
        }
        
        if (error) {
            ShowToastToViewWithText(self.goodsDetailView, error.domain);
        } else { /// 请求成功后添加统计
            [self addGoodsToHistoryDB];
            
            if ([self.actionProtocol isKindOfClass:[ZFGoodsDetailViewController class]]
                && self.hasAnalyticsOnce == NO) {
                self.hasAnalyticsOnce = YES;
                ZFGoodsDetailViewController *detailVC = (ZFGoodsDetailViewController *)self.actionProtocol;
                
                if (detailVC.goodsDetailSuccessBlock) {
                    detailVC.goodsDetailSuccessBlock(YES);
                }
                [ZFGoodsDetailAnalytics af_analysicsDetail:detailVC
                                               detailModel:self.detailModel
                                            selectSkuCount:self.selectSkuCount];
                
                [ZFGoodsDetailAnalytics ga_analyticsDetail:detailVC
                                               detailModel:self.detailModel];
            }
        }
    } else if (error) {
        [self.actionProtocol showTransformView:NO];
    }
    
    /** 以下接口每次切换商品后都需要重新请求 */
    
    // 评论接口
    [self requestGoodsReviewsPort:detailModel completion:nil];
    
    // 请求商品拼团信息
    [self requestGoodsGroupBuyPort:detailModel.goods_id];
    
    // Show社区接口
    [self requestGoodsShowsPort:detailModel];
    
    // 搭配购接口
    [self requestCollocationBuyPort:detailModel];
}

/// 处理切换到相同商品时缓存响应模型直接拿缓存模型显示,不做重复请求
- (ZFGoodsDetailFinishBlock)dealwithModelCacheBlock:(ZFGoodsDetailFinishBlock)completion {
    
    ZFGoodsDetailFinishBlock finishBlock = ^(GoodsDetailModel *detailModel) {
        NSString *goodId = ZFToString(detailModel.goods_id);
        
        if (detailModel.detailMainPortSuccess && detailModel.detailCdnPortSuccess) {
            self.detailModelCacheDict[goodId] = detailModel;
        }
        if (completion) {
            completion(detailModel);
        }
    };
    return finishBlock;
}

/**
 * 请求商品详情页商品信息
 *
 * 是否走cdn请求的两个必要条件
 * 1.商详有满赠id时不能请求cdn
 * 2.如果服务端的配置信息为appShouldRequestCdn=YES时 才能走cdn
 * shouldRequestOtherUrl: 是否需要请求商详页面其他接口
 */
- (void)requestGoodsDetailData:(NSDictionary *)dict
                    completion:(ZFGoodsDetailFinishBlock)completion
                       failure:(void (^)(NSError *error))failure
{
    NSString *goods_id = ZFToString(dict[@"goods_id"]);
    
    /// 做切换商品时缓存接口模型,下次再切换到相同商品时直接显示
    if (self.actionProtocol && completion) {
        GoodsDetailModel *cacheDetailModel = self.detailModelCacheDict[goods_id];
        if ([cacheDetailModel isKindOfClass:[GoodsDetailModel class]]) {
            if (completion) {
                completion(cacheDetailModel);
            }
            return;
        } else {
            completion = [self dealwithModelCacheBlock:completion];
        }
    }
    
    // 清空上次请求的返回数据
    self.realTimeResponseDataDict = nil;
    self.cdnResponseDataDict = nil;
    self.hasAnalyticsOnce = NO;
    
    NSString *manzeng_id = dict[@"manzeng_id"];
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.taget = self.actionProtocol;
    
    NSArray *btsTestArray = @[];
    if ([dict[@"photoBts"] boolValue]) { // 商详是否需要显示博主图bts
        ZFBTSModel *productPhotoBtsModel = [ZFBTSManager getBtsModel:kZFBtsProductPhoto defaultPolicy:kZFBts_A];
        if (productPhotoBtsModel) {
            NSDictionary *btsInfo = [productPhotoBtsModel getBtsParams];
            if (ZFJudgeNSDictionary(btsInfo)) {
                btsTestArray = @[btsInfo];
            }
        }
    }
    BOOL isCDNRequest = (ZFIsEmptyString(manzeng_id) && [AccountManager sharedManager].appShouldRequestCdn);
    if (isCDNRequest) {
        // 请求商详的CDN接口时,同时请求商品实时信息接口
        [self requestGoodsRealTimePort:dict
                            completion:completion
                               failure:failure];
        
        NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
        ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
        NSString *countryId = [[NSUserDefaults standardUserDefaults] valueForKey:kLocationInfoCountryId];
        if (ZFIsEmptyString(countryId)) {
            countryId = ZFToString(accountModel.region_id);
        }
        requestModel.forbidAddPublicArgument = YES;//警告: 请求商详CDN接口不能添加公共参数
        requestModel.url = API(Port_GoodsDetailCdn);
        requestModel.parmaters = @{@"goods_id"              : ZFToString(goods_id),
                                   ZFApiCountryIdKey        : ZFToString(accountModel.region_id),
                                   ZFApiCountryCodeKey      : ZFToString(accountModel.region_code),
                                   ZFApiCommunityCountryId  : ZFToString(countryId),
                                   ZFApiLangKey             : ZFToString(lang),
                                   @"is_enc"                : @"0",
                                   @"bts_test"              : btsTestArray,
                                   @"size_tips_bts"         : @(1), };
    } else {
        requestModel.url = API(Port_GoodsDetail);
        requestModel.parmaters = @{@"goods_id"      :  ZFToString(goods_id),
                                   @"manzeng_id"    :  ZFToString(manzeng_id),
                                   @"token"         :  ISLOGIN ? TOKEN : @"",
                                   @"sess_id"       :  ISLOGIN ? @"" : SESSIONID,
                                   @"appsFlyerUID"  :  ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                                   ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
                                   @"bts_test"      :  btsTestArray,
                                   @"size_tips_bts" :  @(1), };
    }
    self.cdnRequestParmaters = requestModel.parmaters;
    
    self.goodsDetailTask = [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        if (self.cdnRequestParmaters != requestModel.parmaters) return ;
        
        NSDictionary *resultDict = responseObject[ZFResultKey];
        if (ZFJudgeNSDictionary(resultDict) && [resultDict[ZFErrorKey] integerValue] == 0) {
            self.cdnResponseDataDict = isCDNRequest ? resultDict : nil;
            
            BOOL detailCdnPortSuccess = (self.goodsRealTimeTask.state == NSURLSessionTaskStateCompleted);
            if (isCDNRequest && ZFJudgeNSDictionary(self.realTimeResponseDataDict)) {
                NSMutableDictionary *uniteDataDict = [NSMutableDictionary dictionaryWithDictionary:resultDict];
                [uniteDataDict addEntriesFromDictionary:self.realTimeResponseDataDict];// 合并两个
                resultDict = uniteDataDict;
                detailCdnPortSuccess = YES;
            }
            YWLog(@"======== 请求商品详情接口返回成功: %@", detailCdnPortSuccess ? @"合并CDN" : @"主要信息");
            if (completion) {
                GoodsDetailModel *detailModel = [GoodsDetailModel yy_modelWithJSON:resultDict];
                detailModel.detailMainPortSuccess = YES;
                detailModel.detailCdnPortSuccess = detailCdnPortSuccess;
                completion(detailModel);
            }
        } else {
            NSString *errorTip = ZFToString(resultDict[ZFMsgKey]);
            if (![errorTip containsString:@"not exist"]) {
                if (!self.isNotShowError) {
                    ShowErrorToastToViewWithResult(self.goodsDetailView, resultDict);
                }
            }
            if (failure) {
                NSError *error = [NSError errorWithDomain:errorTip code:404 userInfo:nil];
                failure(error);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/**
 * 请求商详商品实时信息接口,(包括最新的价格, 氛围信息等)
 */
- (void)requestGoodsRealTimePort:(NSDictionary *)goodsInfo
                      completion:(void (^)(GoodsDetailModel *))completion
                         failure:(void (^)(NSError *))failure
{
    if (self.goodsRealTimeTask) {
        [self.goodsRealTimeTask cancel];
    }
    ZFBTSModel *deliverytimeBtsModel = [ZFBTSManager getBtsModel:kZFBtsIosdeliverytime defaultPolicy:@"0"];
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.eventName = @"realTime";
    requestModel.taget = self.actionProtocol;
    requestModel.url = API(Port_GoodsDetailRealTime);
    requestModel.parmaters = @{@"goods_id"      :  ZFToString(goodsInfo[@"goods_id"]),
                               @"detail_test_c" :  @"0", //V4.8.0商详版本默认都走A
                               @"token"         :  ISLOGIN ? TOKEN : @"",
                               @"sess_id"       :  ISLOGIN ? @"" : SESSIONID,
                               @"appsFlyerUID"  :  ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                               ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
                               @"ab_test_ship_desc"  :   ZFToString(deliverytimeBtsModel.policy)
    };
    self.realTimeRequestParmaters = requestModel.parmaters;
    
    self.goodsRealTimeTask = [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        YWLog(@"======== 请求商品详情接口返回成功: 实时信息接口");
        if (self.realTimeRequestParmaters != requestModel.parmaters) return ;
        
        NSDictionary *resultDict = responseObject[ZFResultKey];
        if (ZFJudgeNSDictionary(resultDict) && [resultDict[ZFErrorKey] integerValue] == 0) {
            self.realTimeResponseDataDict = resultDict;
            
            if (ZFJudgeNSDictionary(self.cdnResponseDataDict)) {
                NSMutableDictionary *uniteDataDict = [NSMutableDictionary dictionaryWithDictionary:self.cdnResponseDataDict];
                [uniteDataDict addEntriesFromDictionary:resultDict];// 合并两个
                YWLog(@"======== 请求商品详情接口返回成功: 合并两个接口");
                
                if (completion) {
                    GoodsDetailModel *detailModel = [GoodsDetailModel yy_modelWithJSON:uniteDataDict];
                    detailModel.detailMainPortSuccess = YES;
                    detailModel.detailCdnPortSuccess = YES;
                    completion(detailModel);
                }
            }
        } else {
            NSString *errorTip = ZFToString(resultDict[ZFMsgKey]);
            if (![errorTip containsString:@"not exist"]) {
                if (!self.isNotShowError) {
                    ShowErrorToastToViewWithResult(self.goodsDetailView, resultDict);
                }
            }
            if (failure) {
                NSError *error = [NSError errorWithDomain:errorTip code:404 userInfo:nil];
                failure(error);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/**
 * 请求此商品否是拼团商品数据
 */
- (void)requestGoodsGroupBuyPort:(NSString *)goods_id
{
    if (self.goodsGroupBuyTask) return;
    if (ZFIsEmptyString(goods_id)) return;
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_isJoinedActivity);
    requestModel.parmaters = @{@"goods_id"      :   ZFToString(goods_id),
                               @"sess_id"       :   ISLOGIN ? @"" : SESSIONID,
                               @"appsFlyerUID"  :   ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                               ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
    };
    self.goodsGroupBuyTask = [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *resultDict = responseObject[ZFResultKey];
        if (!ZFJudgeNSDictionary(resultDict)) return ;
        
        ZFGoodsDetailGroupBuyModel *groupBuyModel = [ZFGoodsDetailGroupBuyModel yy_modelWithJSON:resultDict];
        [self.goodsDetailView showGroupBuyWithModel:groupBuyModel];
        
    } failure:^(NSError *error) {
        YWLog(@"GoodsGroupBuy error: %@", error);
    }];
}

/**
 * 详情页领券coupon列表
 * isBtsBFlag: 是否为bts的B版本实验
 */
- (void)requestGoodsCouponPort:(NSString *)goods_id completion:(void (^)(NSArray *couponListModelArr))completion
{
    if (self.goodsCouponTask) return;
    if (ZFIsEmptyString(goods_id)) return;
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_GoodsDetailGetCouponList);
    requestModel.parmaters = @{@"goods_id" : ZFToString(goods_id),
                               @"detail_b_test" : @"0", };
    
    self.goodsCouponTask = [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *dataDic = responseObject[ZFResultKey];
        if (!ZFJudgeNSDictionary(dataDic)) return ;
        
        NSArray *list = dataDic[@"couponList"];
        if (!ZFJudgeNSArray(list) || list.count == 0) return ;
        
        NSArray *couponDataArr = [NSArray yy_modelArrayWithClass:[ZFGoodsDetailCouponModel class] json:list];
        if (self.detailModel.detailMainPortSuccess) {
            [self configuDetailViewCellType:self.detailModel
                                refreshType:ZFGoodsDetailCellTypeCoupon
                                 refreshObj:couponDataArr
                               shouldReload:YES];
        } else {
            self.couponListModelArr = couponDataArr;
        }
        if (completion) {
            completion(couponDataArr);
        }
    } failure:^(NSError *error) {
        YWLog(@"GoodsCoupon error: %@", error);
    }];
}

/**
 * 详情页面领取coupon
 */
- (void)requestGetCouponPort:(ZFGoodsDetailCouponModel *)couponModel
                   indexPath:(NSIndexPath *)indexPath
{
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_GoodsDetailGetCoupon);
    requestModel.parmaters = @{@"couponId" : ZFToString(couponModel.couponId),
                               @"user_id"  : ZFToString([[AccountManager sharedManager] userId]) };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *dataDic = [responseObject ds_dictionaryForKey:ZFResultKey];
        // couponStatus 1:可领取;2:领券Coupon不存在;3:已领券;4:没到领取时间;5:已过期;6:coupon 已领取完;7:赠送coupon 失败
        NSInteger couponStatus = [dataDic ds_integerForKey:@"couponStatus"];
        
        // 2. 每次领劵后需要重新获取优惠券列表, 防止优惠券被领光
        self.goodsCouponTask = nil;
        @weakify(self)
        [self requestGoodsCouponPort:self.goodsId completion:^(NSArray *couponListModelArr) {
            @strongify(self)
            // 刷新已显示优惠卷
            [self.goodsDetailView showCouponPopView:couponListModelArr shouldRefresh:YES];
            
            // 1:领劵成功;2:领券Coupon不存在;3:已领券;4:没到领取时间;5:已过期;6:coupon已领取完;7:赠送coupon失败
            // 默认提示已领完
            NSString *tiptext = ZFLocalizedString(@"Detail_ReceiveCouponFail", nil);
            
            if (couponStatus == 1) {
                tiptext = ZFLocalizedString(@"Detail_ReceiveCouponSuccess", nil);
                [ZFGoodsDetailAnalytics af_growingIOGetCoupon:couponModel.discounts];
                
            } else if (couponStatus == 6) {
                tiptext = ZFLocalizedString(@"Detail_ReceiveCouponUsedUp", nil);
            }
            ShowToastToViewWithText(self.goodsDetailView, tiptext);
        }];
    } failure:^(NSError *error) {
        ShowToastToViewWithText(self.goodsDetailView, ZFLocalizedString(@"Detail_ReceiveCouponFail",nil));
    }];
}

/**
 * 商品评论数据，前3条
 */
- (void)requestGoodsReviewsPort:(GoodsDetailModel *)detailModel completion:(void (^)(GoodsDetailsReviewsModel *reviewsModel))completion
{
    if (self.goodsReviewsTask) {
        return;
    }
    if (ZFIsEmptyString(detailModel.goods_sn) || ZFIsEmptyString(detailModel.goods_id)) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_GoodsReviews);
    requestModel.forbidAddPublicArgument = YES;
    
    NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
    NSString *countryId = [[NSUserDefaults standardUserDefaults] valueForKey:kLocationInfoCountryId];
    if (ZFIsEmptyString(countryId)) {
        countryId = ZFToString(accountModel.region_id);
    }
    //sort : V4.8.0排序传优先图片排序 "5"
    requestModel.parmaters = @{@"goods_id"              : ZFToString(detailModel.goods_id),
                               @"goods_sn"              : ZFToString(detailModel.goods_sn),
                               @"page"                  : @(1),
                               @"page_size"             : @"3",
                               @"sort"                  : @"5",
                               @"is_enc"                : @"0",
                               ZFApiCountryIdKey        : ZFToString(accountModel.region_id),
                               ZFApiCountryCodeKey      : ZFToString(accountModel.region_code),
                               ZFApiCommunityCountryId  : ZFToString(countryId),
                               ZFApiLangKey             : ZFToString(lang),
                               ZFApiAppsFlyerUID        : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                               ZFApiBtsUniqueID         : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId])
                               };
    requestModel.eventName = @"review";
    requestModel.taget = self.actionProtocol;
    
    self.goodsReviewsTask = [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        GoodsDetailsReviewsModel *reviewsModel = [GoodsDetailsReviewsModel yy_modelWithJSON:responseObject[ZFResultKey]];
        
        if (completion) {
            completion(reviewsModel);
        }
        if (reviewsModel.reviewList.count == 0) return ;
        
        self.reviewModelArray = reviewsModel.reviewList;
        self.reviewsRankingModel = reviewsModel.size_over_all;
        
        reviewsModel.size_over_all.reviewCount = reviewsModel.reviewCount;
        reviewsModel.size_over_all.agvRate = reviewsModel.agvRate;
        if (self.showProductDescBts) {
            self.detailModel.rateAVG = [NSString stringWithFormat:@"%.2f", reviewsModel.agvRate];
        }
        
        if (self.detailModel.detailMainPortSuccess) {
            // 评论星级
            [self configuDetailViewCellType:self.detailModel
                                refreshType:ZFGoodsDetailCellTypeReviewStar
                                 refreshObj:reviewsModel.size_over_all
                               shouldReload:NO];
            
            // 评论内容
            [self configuDetailViewCellType:self.detailModel
                                refreshType:ZFGoodsDetailCellTypeReview
                                 refreshObj:reviewsModel.reviewList
                               shouldReload:YES];
            
            // 评论ViewAll
            [self configuDetailViewCellType:self.detailModel
                                refreshType:ZFGoodsDetailCellTypeReviewViewAll
                                 refreshObj:reviewsModel.reviewList
                               shouldReload:NO];
        }
    } failure:^(NSError *error) {
        YWLog(@"GoodsReviews error: %@", error);
    }];
}

/**
 * 商品Shows数据
 */
- (void)requestGoodsShowsPort:(GoodsDetailModel *)detailModel
{
    if (self.goodsShowsTask) return;
    if (ZFIsEmptyString(detailModel.goods_sn)) return;
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.url = CommunityAPI;
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"page"] = @"1";
    info[@"pageSize"] = @"9";
    info[@"type"] = @"9";
    info[@"directory"] = @"65";
    info[@"sku"] = ZFToString(detailModel.goods_sn);
    info[@"simple"] = @"1";
    info[@"loginUserId"] = USERID ?: @"0";
    info[@"app_type"] = @"2";
    info[@"site"] = @"ZZZZZcommunity";
    requestModel.parmaters = info;
    requestModel.eventName = @"show";
    requestModel.taget = self.actionProtocol;
    
    self.goodsShowsTask = [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        NSDictionary *dataDict = responseObject[ZFDataKey];
        if (!ZFJudgeNSDictionary(dataDict)) return ;
        
        NSArray *list = dataDict[ZFListKey];
        if (!ZFJudgeNSArray(list)) return;
        
        NSArray *showModelArr = [NSArray yy_modelArrayWithClass:[GoodsShowExploreModel class] json:dataDict[ZFListKey]];
        
        if (self.detailModel.detailMainPortSuccess) {
            [self configuDetailViewCellType:self.detailModel
                                refreshType:ZFGoodsDetailCellTypeShow
                                 refreshObj:showModelArr
                               shouldReload:YES];
        } else {
            self.showExploreModelArray = showModelArr;
        }
    } failure:^(NSError *error) {
        YWLog(@"GoodsShows error: %@", error);
    }];
}

/**
 * 商品推荐数据
 */
- (void)requestGoodsRecommendPort:(NSString *)goods_id
{
    if (self.goodsRecommendTask) return;
    if (ZFIsEmptyString(goods_id)) return;
    YWLog(@"商品推荐数据===%@", goods_id);
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_GoodsSameCate);
    requestModel.eventName = @"detail_recommend";
    requestModel.taget = self.actionProtocol;
    
    NSString *afId = [[AppsFlyerTracker sharedTracker] getAppsFlyerUID];
    requestModel.parmaters = @{@"goods_id"      :   ZFToString(goods_id),
                               @"token"         :   ISLOGIN ? TOKEN : @"",
                               @"sess_id"       :   ISLOGIN ? @"" : SESSIONID,
                               @"appsFlyerUID"  :   ZFToString(afId),
                               ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
                               @"detail_test_b" :   @"1"
                               };
    self.goodsRecommendTask = [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *resultDict = responseObject[ZFResultKey];
        AFparams *params = nil;
        NSArray *commendGoodsArray = @[];
        
        if (ZFJudgeNSDictionary(resultDict)) {
            NSArray *sameCatGoodsArray = resultDict[@"same_cat_goods"];
            if (ZFJudgeNSArray(sameCatGoodsArray)) {
                commendGoodsArray = [NSArray yy_modelArrayWithClass:[GoodsDetailSameModel class] json:sameCatGoodsArray];
            }
            NSDictionary *af_params = resultDict[@"af_params"];
            if (ZFJudgeNSDictionary(af_params)) {
                params = [AFparams yy_modelWithJSON:af_params];
            }
        }
        [self dealwithCommendGoodsResult:commendGoodsArray commendParams:params];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.showProductDescBts && self.shouldScrollToRecommed) {
                self.shouldScrollToRecommed = NO;
                [self.goodsDetailView scrollToRecommendGoodsPostion];
            }
        });
    } failure:^(NSError *error) {
        [self dealwithCommendGoodsResult:nil commendParams:nil];
        YWLog(@"GoodsRecommend error: %@", error);
    }];
}

/**
 * 处理 推荐商品/找相似商品 结果
 */
- (void)dealwithCommendGoodsResult:(NSArray *)commendGoodsArray
                     commendParams:(AFparams *)params
{
    // 标记推荐接口已返回,Cell中需要隐藏转圈
    self.detailModel.recommendPortSuccess = YES;
    
    if (self.detailModel.detailMainPortSuccess) {
        [self configuDetailViewCellType:self.detailModel
                            refreshType:ZFGoodsDetailCellTTypeRecommendHeader
                             refreshObj:commendGoodsArray
                           shouldReload:NO];
        
        [self configuDetailViewCellType:self.detailModel
                            refreshType:ZFGoodsDetailCellTTypeRecommend
                             refreshObj:commendGoodsArray
                           shouldReload:YES];
        
        self.detailModel.af_recommend_params = params;
    } else {
        self.af_recommend_params = params;
        self.recommendModelArray = commendGoodsArray;
    }
    if ([self.actionProtocol isKindOfClass:[ZFGoodsDetailViewController class]]) {
        ZFGoodsDetailViewController *detailVC = (ZFGoodsDetailViewController *)self.actionProtocol;
        self.recommendAnalyticsImpression = [ZFGoodsDetailAnalytics fetchRecommendAnalytics:detailVC
                                                                                detailModel:self.detailModel];
    }
}

/// 商品收藏操作 (type = 0/1 0添加 1取消)
- (void)requestGoodsCollectPort:(GoodsDetailModel *)detailModel
                    collectFlag:(BOOL)isCollect
                      indexPath:(NSIndexPath *)reloadIndexPath
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.eventName = @"collecton";
    requestModel.taget = self.actionProtocol;
    requestModel.url = API(Port_operationCollection);
    requestModel.parmaters = @{@"goods_id"       : ZFToString(self.goodsId),
                               @"type"           : isCollect ? @"0" : @"1",
                               @"token"          : (ISLOGIN ? TOKEN : @""),
                               @"sess_id"        : (ISLOGIN ? @"" : SESSIONID),
                               @"is_enc"         :  @"0" };
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        NSDictionary *dict = responseObject[ZFResultKey];
        if ([dict[@"error"] integerValue] == 0) {
            NSDictionary *dataDict = dict[@"data"];
            if (ZFJudgeNSDictionary(dataDict)) {
                NSString *sess_id = dataDict[@"sess_id"];
                if (!ZFIsEmptyString(sess_id)) {
                    [[NSUserDefaults standardUserDefaults] setValue:sess_id forKey:kSessionId];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            detailModel.is_collect = [NSString stringWithFormat:@"%d", isCollect];
            NSInteger numCount = [detailModel.like_count integerValue] + (isCollect ? +1 : -1);
            if (numCount < 0) {//防止负数处理
                numCount = 0;
            }
            detailModel.like_count = [NSString stringWithFormat:@"%ld", (long)numCount];
            
            //添加收藏商品通知
            ZFPostNotificationInfo(kCollectionGoodsNotification, nil, dict);
            
        } else {
            ShowToastToViewWithText(self.goodsDetailView, responseObject[ZFResultKey][@"msg"]);
            detailModel.is_collect = [NSString stringWithFormat:@"%d", !isCollect];;
        }
        // 刷新收藏Cell 点赞动画有1S时间，防止点赞动画没有效果
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.goodsDetailView reloadDetailView:NO sectionIndex:reloadIndexPath.section];
        });

        
    } failure:^(NSError *error) {
        ShowToastToViewWithText(self.goodsDetailView, error.domain);
    }];
    
    // 收藏添加统计
    [ZFGoodsDetailAnalytics af_analyticsClickCollect:(ZFGoodsDetailViewController *)self.actionProtocol
                                         detailModel:self.detailModel
                                           isCollect:isCollect
                                      selectSkuCount:self.selectSkuCount];
}

/// 添加购物车 , 执行动画  然后刷新购物车数量
- (void)requestAddGoodsToCartPort:(BOOL)isFastBuy {
    self.isCollocationBuy = isFastBuy;
    
    // 在加购时如果没有请求过推荐数据则请求一次
    if (!self.recommendAnalyticsImpression || !self.detailModel.recommendPortSuccess) {
        self.shouldScrollToRecommed = YES;
        [self requestGoodsRecommendPort:self.goodsId];
    }
    
    if (!ZFIsEmptyString(self.freeGiftId)) {
        [self requestAddFreeGiftToCartPort];
        
    } else {
        
        @weakify(self);
        [self requestAddToCart:self.goodsId loadingView:self.goodsDetailView goodsNum:1 completion:^(BOOL isSuccess) {
            if (!isSuccess) return ;

            ZFBTSModel *btsModel = [ZFBTSManager getBtsModel:kZFBtsIosxaddbag defaultPolicy:kZFBts_A];
            
            @strongify(self);
            if (isFastBuy) { // 一键(快速)购买时再调checkOut接口去结算
                [self requestFastBuyCheckOutPort];
                
            } else if ([btsModel.policy isEqualToString:kZFBts_C]) {//C版本才显示右上角弹框
                [self.actionProtocol showNavCartInfoPopView:self.detailModel];
                
            }  else if ([btsModel.policy isEqualToString:kZFBts_B]) {//B版本:加购右上角动画
                [self.goodsDetailView showNavgationAddCarAnimation:nil scrollToRecommend:YES];
                
            } else { // 正常加购时才显示加购动画
                [self.goodsDetailView showAddCarAnimation];
            }
            // 警告:⚠️ 商详主要的加购统计事件
            ZFGoodsDetailViewController *goodsVC = (ZFGoodsDetailViewController *)self.actionProtocol;
            [ZFGoodsDetailAnalytics af_analysicsAddToBag:goodsVC
                                             detailModel:self.detailModel
                                          selectSkuCount:self.selectSkuCount
                                             fastBuyFlag:isFastBuy];
        }];
    }
}

/// 请求商品添加到购物车
- (void)requestAddToCart:(NSString *)goodsId
             loadingView:(UIView *)loadingView
                goodsNum:(NSInteger)goodsNum
              completion:(void (^)(BOOL isSuccess))completion
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_addCart);
    requestModel.eventName = @"add_to_bag";
    requestModel.taget = self.actionProtocol;
    requestModel.parmaters = @{@"detail_test_c" : @"0",
                               @"goods_id"      : ZFToString(goodsId),
                               @"num"           : @(goodsNum),
                               @"token"         : ISLOGIN ? TOKEN : @"",
                               @"sess_id"       : ISLOGIN ? @"" : SESSIONID,
                               @"is_enc"        :  @"0",
                               @"filter_invalid_goods" : (self.isCollocationBuy ? @"1" : @"0"), };
    
    ShowLoadingToView(loadingView);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        HideLoadingFromView(loadingView);
        
        CGFloat duration = 0;
        BOOL success = NO;
        NSDictionary *resultDcit = responseObject[ZFResultKey];
        if (ZFJudgeNSDictionary(resultDcit) && [resultDcit[@"error"] integerValue] == 0) {
            NSString *sess_id = resultDcit[@"sess_id"];
            if (!ZFIsEmptyString(sess_id)) {
                SaveUserDefault(kSessionId, ZFToString(sess_id));
            }
            if (resultDcit[@"goods_count"]) {
                SaveUserDefault(kCollectionBadgeKey, ZFToString(resultDcit[@"goods_count"]));
            }
            // 刷新购物车和数量
            ZFPostNotification(kCartNotification, nil);
            duration = self.goodsDetailView ? 1 : 0;
            success = YES;
        }
        
        ZFBTSModel *btsModel = [ZFBTSManager getBtsModel:kZFBtsIosxaddbag defaultPolicy:kZFBts_A];
        BOOL showToast = success ? ([btsModel.policy isEqualToString:kZFBts_C] ? NO : YES) : YES;
        
        ///C版本不显示加购成功
        if (showToast && ZFJudgeNSDictionary(resultDcit) && !ZFIsEmptyString(resultDcit[ZFMsgKey])) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                ShowToastToViewWithText(loadingView, resultDcit[ZFMsgKey]);
            });
        }
        if (completion) {
            completion(success);
        }
    } failure:^(NSError *error) {
        ShowToastToViewWithText(loadingView, ZFLocalizedString(@"CartVC_AddCarFiale_tip",nil));
        if (completion) {
            completion(NO);
        }
    }];
}

/// 一键(快速)购买时: 生成订单
- (void)requestFastBuyCheckOutPort {
    NSMutableDictionary *parmaters = [NSMutableDictionary dictionary];
    parmaters[@"token"] = TOKEN;
    parmaters[@"is_enc"] = @"0";
    parmaters[@"auto_coupon"] = @"0";
    
    NSMutableDictionary *extraInfo = [NSMutableDictionary dictionary];
    extraInfo[@"buy_now"] = @"1";
    extraInfo[@"goods_id"] = ZFToString(self.goodsId);
    [parmaters addEntriesFromDictionary:extraInfo];
    
    ZFBTSModel *deliverytimeBtsModel = [ZFBTSManager getBtsModel:kZFBtsIosdeliverytime defaultPolicy:@"0"];
    parmaters[@"ab_test_ship_desc"] = ZFToString(deliverytimeBtsModel.policy);
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.eventName = @"checkout_info";
    requestModel.taget = self.actionProtocol;
    requestModel.url = API(Port_checkout);
    requestModel.parmaters = parmaters;
    
    ShowLoadingToView(self.goodsDetailView);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        HideLoadingFromView(self.goodsDetailView);
        
        ZFOrderCheckInfoModel *infoModel = [ZFOrderCheckInfoModel yy_modelWithJSON:responseObject[ZFResultKey]];
        if (infoModel && [infoModel isKindOfClass:[ZFOrderCheckInfoModel class]]) {
            // 快速购买跳转
            infoModel.order_info = [ZFOrderCheckInfoDetailModel yy_modelWithJSON:responseObject[ZFResultKey]];
            
            @weakify(self);
            [self.actionProtocol fastBuyActionPush:infoModel extraInfo:extraInfo refreshBlock:^(NSInteger t){
                @strongify(self);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self requestFastBuyCheckOutPort];
                });
            }];
        } else {
            ShowToastToViewWithText(self.goodsDetailView, ZFLocalizedString(@"Global_VC_NO_DATA",nil));
        }
    } failure:^(NSError *error) {
        ShowToastToViewWithText(self.goodsDetailView, error.domain);
    }];
}

/// 添加赠品到购物车
- (void)requestAddFreeGiftToCartPort {
    if (self.detailModel.is_full && self.detailModel.is_added) {
        NSString *message = ZFLocalizedString(@"FreeGiftDetail_AddCartTips",nil);
        NSString *cancelTitle = ZFLocalizedString(@"OrderDetail_Cell_CancelOrder_No",nil);
        NSString *otherTitle = ZFLocalizedString(@"OrderDetail_Cell_CancelOrder_Yes",nil);
        
        ShowAlertView(nil, message, @[otherTitle], ^(NSInteger buttonIndex, id buttonTitle) {
            [self requestAddFreeGiftToCart];
        }, cancelTitle, nil);
        return ;
    }
    [self requestAddFreeGiftToCart];
}

/// 添加礼品
- (void)requestAddFreeGiftToCart {
    ZFRequestModel *model = [[ZFRequestModel alloc] init];
    model.url = API(Port_freeGiftAddCart);
    model.eventName = @"add_to_bag";
    model.taget = self.actionProtocol;
    
    model.parmaters = @{@"sku"       : ZFToString(self.detailModel.goods_sn),
                        @"manzeng_id": ZFToString(self.freeGiftId),
                        @"num"       : @(1),
                        @"token"     : ISLOGIN ? TOKEN : @"",
                        @"sess_id"   : ISLOGIN ? @"" : SESSIONID,
                        @"is_enc"   :  @"0" };
    
    ShowLoadingToView(self.goodsDetailView);
    [ZFNetworkHttpRequest sendRequestWithParmaters:model success:^(id responseObject) {
        HideLoadingFromView(self.goodsDetailView);
        
        ZFBTSModel *btsModel = [ZFBTSManager getBtsModel:kZFBtsIosxaddbag defaultPolicy:kZFBts_A];
        
        BOOL showToast = NO;
        if (![responseObject[ZFResultKey][@"error"] boolValue]) {
            SaveUserDefault(kSessionId, ZFToString(responseObject[ZFResultKey][@"sess_id"]));
            ZFPostNotification(kCartNotification, nil);
            showToast = YES;
        }
        
        if (showToast && [btsModel.policy isEqualToString:kZFBts_C]) {///C版本才显示右上角弹框
            [self.actionProtocol showNavCartInfoPopView:self.detailModel];
            showToast = NO;
            
        } else { // 正常加购时才显示加购动画
            [self.goodsDetailView showAddCarAnimation];
        }
        
        if (showToast) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                ShowToastToViewWithText(self.goodsDetailView, responseObject[ZFResultKey][@"msg"]);
            });
        }
        // 警告:⚠️ 商详主要的加购统计事件
        ZFGoodsDetailViewController *goodsVC = (ZFGoodsDetailViewController *)self.actionProtocol;
        [ZFGoodsDetailAnalytics af_analysicsAddToBag:goodsVC
                                         detailModel:self.detailModel
                                      selectSkuCount:self.selectSkuCount
                                         fastBuyFlag:NO];
        
    } failure:^(NSError *error) {
        HideLoadingFromView(self.goodsDetailView);
    }];
}

/**
 * 请求商品搭配购数据
 */
- (void)requestCollocationBuyPort:(GoodsDetailModel *)detailModel {
    if (self.collocationBuyTask) return;
    if (ZFIsEmptyString(detailModel.goods_sn)) return;
    self.collocationBuyTask = [ZFCollocationBuyViewModel requestCollocationBuy:detailModel.goods_sn
                                                                 showFirstPage:YES completion:^(ZFCollocationBuyModel *collocationBuyModel)
    {
        // 没有搭配购数据时再请求穿搭数据
        if (!collocationBuyModel || collocationBuyModel.collocationGoodsArr.count == 0) {
            [self requestGoodsOutfitsPort:detailModel.goods_sn];
            return;
        }
        if (![collocationBuyModel isKindOfClass:[ZFCollocationBuyModel class]]) return ;
        
        if (self.detailModel.detailMainPortSuccess) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self configuDetailViewCellType:self.detailModel
                                    refreshType:ZFGoodsDetailCellTypeCollocationBuy
                                     refreshObj:collocationBuyModel
                                   shouldReload:YES];
            });
        } else {
            self.collocationBuyModel = collocationBuyModel;
        }
    }];
}

/**
 * 请求商详关联的穿搭商品数据
 */
- (void)requestGoodsOutfitsPort:(NSString *)goods_sn {
    if (self.goodsOutfitsTask) return;
    if (ZFIsEmptyString(goods_sn)) return;
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.url = Community_API(Port_outfit_goods_review);
    requestModel.parmaters = @{@"app_type"      : @"2",
                               @"site"          : @"ZZZZZcommunity",
                               @"sku"           : ZFToString(goods_sn),
                               @"loginUserId"   : ZFToString(USERID) };
    
    self.goodsOutfitsTask = [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {        
        NSDictionary *dataDict = responseObject[ZFDataKey];
        if (!ZFJudgeNSDictionary(dataDict)) return ;
        
        NSArray *list = dataDict[ZFListKey];
        if (!ZFJudgeNSArray(list)) return;
        
        NSArray *outfitsModelArray = [NSArray yy_modelArrayWithClass:[ZFGoodsDetailOutfitsModel class] json:list];
        
        if (self.detailModel.detailMainPortSuccess) {
            [self configuDetailViewCellType:self.detailModel
                                refreshType:ZFGoodsDetailCellTypeOutfits
                                 refreshObj:outfitsModelArray
                               shouldReload:YES];
        } else {
            self.outfitsModelArray = outfitsModelArray;
        }
    } failure:nil];
}

/**
 * 请求商详穿搭商品关联的SKU
 */
- (void)requestOutfitsSkuPortOutfits:(NSString *)outfitsId
                            goods_sn:(NSString *)goods_sn
                          completion:(void(^)(NSArray<ZFGoodsModel *> *))completion
{
    if (ZFIsEmptyString(outfitsId) || ZFIsEmptyString(goods_sn)) return;
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.url = Community_API(Port_outfit_review_skus);
    requestModel.parmaters = @{@"app_type"      : @"2",
                               @"site"          : @"ZZZZZcommunity",
                               @"reviewId"      : ZFToString(outfitsId),
                               @"sku"           : ZFToString(goods_sn) };
    ShowLoadingToView(self.goodsDetailView);
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        HideLoadingFromView(self.goodsDetailView);
        NSDictionary *dataDict = responseObject[ZFDataKey];
        if (!ZFJudgeNSDictionary(dataDict)) return;
        NSArray *list = dataDict[@"skus"];
        if (!ZFJudgeNSArray(list)) return;
        
        NSString *relationshipSku = [list componentsJoinedByString:@","];
        [self.class requestOutfitsGoodsPort:relationshipSku
                                loadingView:self.goodsDetailView
                                 completion:completion];
    } failure:^(NSError *error) {
        HideLoadingFromView(self.goodsDetailView);
    }];
}

/**
 * 请求精选商品列表 (从deeplink进来)
 */
+ (void)requestOutfitsGoodsPort:(NSString *)relationshipSkus
                    loadingView:(UIView *)loadingView
                      completion:(void (^)(NSArray<ZFGoodsModel *> *))completion
{
    if (ZFIsEmptyString(relationshipSkus)) return;
    ZFRequestModel *model = [[ZFRequestModel alloc] init];
    model.url = API(Port_categorySearch);
    model.parmaters = @{
        @"goods_sn"         : ZFToString(relationshipSkus),
        @"returnOutOfStock" : @"1", //是否需要返回失效商品
    };
    ShowLoadingToView(loadingView);
    [ZFNetworkHttpRequest sendRequestWithParmaters:model success:^(id responseObject) {
        HideLoadingFromView(loadingView);
        
        NSDictionary *resultDict = responseObject[ZFResultKey];
        if (!ZFJudgeNSDictionary(resultDict)) return;

        NSArray *goodsListArr = resultDict[@"goods_list"];
        if (!ZFJudgeNSArray(goodsListArr))return;
        
        if (completion) {
            NSArray<ZFGoodsModel *> *goodsModelArray = [NSArray yy_modelArrayWithClass:[ZFGoodsModel class] json:goodsListArr];
            completion(goodsModelArray);
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(loadingView);
    }];
}

#pragma mark -============ <Blcok 回调事件> ============

/**
 * 将要显示推荐栏时请求推荐数据
 * ZFGoodsDetailView
 */
- (void(^)(GoodsDetailModel *))shouldRequestRecommendPortBock {
    @weakify(self);
    return ^(GoodsDetailModel *detailModel) {
        @strongify(self);
        [self requestGoodsRecommendPort:detailModel.goods_id];
    };
}

/**
 * 点击商品信息Cell事件回调
 * ZFGoodsDetailGoodsInfoCell
 */
- (ZFGoodsDetailActionBlock)goodsInfoCollectActionBlock {
    @weakify(self);
    return ^(GoodsDetailModel *model, NSDictionary *infoDict, id object){
        @strongify(self);
        if (self.showProductDescBts) { //V5.5.0收藏实验
            if (![infoDict isKindOfClass:[NSDictionary class]]) return ;
            
            if ([infoDict[@"isShowImageType"] boolValue]) {
                [self.goodsDetailView hideAddCartInfoPopView];
                
            } else if ([infoDict[@"isCollectionType"] boolValue]) {
                BOOL isCollect = [infoDict[@"isSelected"] boolValue];
                NSIndexPath *reloadIndexPath = infoDict[@"indexPath"];
                [self requestGoodsCollectPort:model
                                  collectFlag:isCollect
                                    indexPath:reloadIndexPath];
            }
        }
    };
}

/**
 * 点击商品信息Cell事件回调
 * ZFGoodsDetailGoodsInfoCell
 */
- (ZFGoodsDetailActionBlock)goodsInfoReviewActionBlock {
    @weakify(self);
    return ^(GoodsDetailModel *model, NSNumber *isCollect, NSIndexPath *reloadIndexPath){
        @strongify(self);
        if (self.showProductDescBts) {
            if (self.actionProtocol.reviewCellActionBlock) {
                self.actionProtocol.reviewCellActionBlock(model, nil, nil);
            }
        } else {
            [self requestGoodsCollectPort:model
                              collectFlag:[isCollect boolValue]
                                indexPath:reloadIndexPath];
        }
    };
}

/**
 * 商详页面"选择尺寸属性Cell"点击事件类型
 * ZFGoodsDetailGoodsSelectSizeCell
 */
- (ZFGoodsDetailActionBlock)selectStandardCellActionBlock {
    @weakify(self);
    return ^(GoodsDetailModel *model, NSNumber *actionType, id goodsObj){
        @strongify(self);
        switch ([actionType integerValue]) {
            case ZFSelectStandard_SizeGuideType: // 选择SizeGuide
            {
                [self.actionProtocol openWebInfoWithUrl:model.size_url title:ZFLocalizedString(@"Detail_Product_SizeGuides",nil)];
            }
                break;
            case ZFSelectStandard_ChangeGoodsIdType: // 选择颜色
            {
                self.placeHoldImage = [UIImage imageNamed:@"loading_product"];
                [self selectStandardWithGoodsId:goodsObj];
            }
                break;
            case ZFSelectStandard_ChangeGoodsIdBySizeType: // 选择尺寸
            {
                self.placeHoldImage = self.goodsDetailView.navigationGoodsImage;
                [self selectStandardWithGoodsId:goodsObj];
            }
                break;
            default:
                break;
        }
    };
}

/**
 * 滑动到评论Section所对应的回调
 * ZFGoodsDetailGoodsSelectSizeCell
 */
- (void(^)(GoodsDetailModel *))shouldTrackProductReviewBock {
    @weakify(self);
    return ^(GoodsDetailModel *model){
        @strongify(self);
        if (self.hasTrackProductReview == NO) {
            self.hasTrackProductReview = YES;
            if ([self.actionProtocol isKindOfClass:[ZFGoodsDetailViewController class]]) {
                [ZFGoodsDetailAnalytics af_analyticsReview:(ZFGoodsDetailViewController *)self.actionProtocol
                                               detailModel:model];
            }
        }
    };
}

/**
 * 滑动到搭配购Section所对应的回调
 * ZFGoodsDetailCollocationBuyItemCell
 */
- (void(^)(GoodsDetailModel *))shouldTrackCollocationBuyBock {
    @weakify(self);
    return ^(GoodsDetailModel *model){
        @strongify(self);
        if (self.hasTrackCollocationBuy == NO) {
            self.hasTrackCollocationBuy = YES;
            [ZFGoodsDetailAnalytics af_analyticsShowCollocationBuy];
        }
    };
}

/**
 * 点击评论Cell中的控件回调
 * ZFGoodsDetailGoodsReviewCell
 */
- (ZFGoodsDetailActionBlock)reviewCellActionBock {
    @weakify(self);
    return ^(GoodsDetailModel *model, GoodsDetailFirstReviewModel *reviewModel, id obj){
        @strongify(self);
        if (self.reviewModelArray.count == 0) return ;
        for (GoodsDetailFirstReviewModel *tmpModel in self.reviewModelArray) {
            if ([tmpModel.time isEqualToString:reviewModel.time]) {
                tmpModel.isTranslate = !tmpModel.isTranslate;
            }
        }
        // 刷新评论内容
        [self configuDetailViewCellType:self.detailModel
                            refreshType:ZFGoodsDetailCellTypeReview
                             refreshObj:self.reviewModelArray
                           shouldReload:YES];
    };
}

/**
 * 点击产品描述信息Cell中的控件回调
 * ZFGoodsDetailProductModelDescCell
 */
- (ZFGoodsDetailActionBlock)productDescCellActionBock {
    @weakify(self);
    return ^(GoodsDetailModel *model, id obj1, id obj2){
        @strongify(self);
        [self.goodsDetailView refreshProductDescHeight];
    };
}

#pragma mark - <private Method>

/**
 * 修改商品规格/尺寸
 */
- (void)selectStandardWithGoodsId:(NSString *)goodsId {
    if (!ZFIsEmptyString(goodsId)) {
        self.goodsId = ZFToString(goodsId);
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailInfoDict];
        dict[@"goods_id"] = self.goodsId;
        dict[kShowLoadingFlag] = @"1"; //标记请求转圈
        self.detailInfoDict = dict;
    }
    self.selectSkuCount += 1;
    self.goodsShowsTask = nil;     //切换尺码后需要重新请求Shows
    self.goodsGroupBuyTask = nil;  //切换尺码后需要重新请求拼团
    self.goodsRecommendTask = nil; //切换尺码后需要重新请求推荐
    self.similarGoodsSNArray = nil;
    self.collocationBuyTask = nil;
    self.recommendSimilarModelArray = nil;
    [self requestGoodsDetailPort:self.detailInfoDict];
}

//移除普通秒数商品开启的倒计时
- (void)initGoodsCountDownTimer:(BOOL)start {
    if (self.detailModel.activityModel &&
        self.detailModel.activityModel.type == GoodsDetailActivityTypeFlashing) {
        NSString *countDownTime = self.detailModel.activityModel.countDownTime;
        if (!ZFIsEmptyString(countDownTime) && ![countDownTime isEqualToString:@"0"]) {
            if (start) {
                self.detailModel.activityModel.countDownTimerKey = [NSString stringWithFormat:@"GoodsDetailActivity_%@", self.detailModel.goods_id ];
                [[ZFTimerManager shareInstance] startTimer:self.detailModel.activityModel.countDownTimerKey];
            } else {
                [[ZFTimerManager shareInstance] stopTimer:self.detailModel.activityModel.countDownTimerKey];
            }
        }
    }
}

/// 添加到历史记录数据表
- (void)addGoodsToHistoryDB {
    if (!ZFIsEmptyString(self.detailModel.manzeng_id))return ;
    
    ZFGoodsModel *goodsModel = [[ZFGoodsModel alloc] init];
    goodsModel.goods_id    = self.detailModel.goods_id;
    goodsModel.goods_sn    = self.detailModel.goods_sn;
    goodsModel.goods_title = self.detailModel.goods_name;
    goodsModel.shop_price  = self.detailModel.shop_price;
    goodsModel.market_price= self.detailModel.market_price;
    goodsModel.tagsArray   = self.detailModel.tagsArray;
    goodsModel.is_on_sale = self.detailModel.is_on_sale;
    goodsModel.is_collect = self.detailModel.is_collect;
    goodsModel.price_type = self.detailModel.price_type;
    goodsModel.goods_number = [NSString stringWithFormat:@"%ld",(long)self.detailModel.goods_number];;
    
    if (self.detailModel.pictures.count > 0) {
        GoodsDetailPictureModel *pictureModel = [self.detailModel.pictures firstObject];
        goodsModel.wp_image = pictureModel.wp_image;//商品缩略图
    } else {
        goodsModel.wp_image = @"";//商品缩略图
    }
    [self deleteCurrentSimilitudeGoods];
    [ZFGoodsModel insertDBWithModel:goodsModel];
}

/// 删除浏览历史中相同款sku
- (void)deleteCurrentSimilitudeGoods {
    NSString *goodsSN = self.detailModel.goods_sn;
    NSString *spuSN = goodsSN;
    if (goodsSN.length > 7) {  // sn的前7位为同款id
        spuSN = [goodsSN substringWithRange:NSMakeRange(0, 7)];
    }
    NSMutableArray *shouldDelateArray = [NSMutableArray array];
    NSArray *goodsDBS = [ZFGoodsModel selectAllGoods];
    for (ZFGoodsModel *tempModel in goodsDBS) {
        if ([tempModel.goods_sn hasPrefix:spuSN]) {
            [shouldDelateArray addObject:tempModel];
        }
    }
    for (ZFGoodsModel *deleteModel in shouldDelateArray) {
        [ZFGoodsModel deleteDBWithGoodsID:deleteModel.goods_id];
    }
}

- (NSMutableDictionary *)detailModelCacheDict {
    if (!_detailModelCacheDict) {
        _detailModelCacheDict = [NSMutableDictionary dictionary];
    }
    return _detailModelCacheDict;
}

#pragma mark -============ 其他操作 ============

/// 退出关闭当前页面时取消所有请求
- (void)cancelAllDataTask {
    [self cancelMainDataTask];
    [self cancelSubjoinDataTask];
}

/// 取消主要的请求接口
- (void)cancelMainDataTask {
    [self.goodsDetailTask cancel];
    self.goodsDetailTask = nil;
    
    [self.goodsRealTimeTask cancel];
    self.goodsRealTimeTask = nil;
    
    [self.goodsShowsTask cancel];
    self.goodsShowsTask = nil;
    
    [self.goodsRecommendTask cancel];
    self.goodsRecommendTask = nil;
    
    [self.goodsGroupBuyTask cancel];
    self.goodsGroupBuyTask = nil;
    
    [self.collocationBuyTask cancel];
    self.collocationBuyTask = nil;
    
    [self.goodsOutfitsTask cancel];
    self.goodsOutfitsTask = nil;
}

/// 取消附加的请求接口
- (void)cancelSubjoinDataTask {
    [self.goodsDetailBtsTask cancel];
    self.goodsDetailBtsTask = nil;
    
    [self.goodsCouponTask cancel];
    self.goodsCouponTask = nil;
    
    [self.goodsReviewsTask cancel];
    self.goodsReviewsTask = nil;
}

@end
