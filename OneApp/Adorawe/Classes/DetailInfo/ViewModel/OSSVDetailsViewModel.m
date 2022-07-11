//
//  OSSVDetailsViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailsViewModel.h"
#import "OSSVReviewsViewModel.h"

// API
#import "OSSVDetailsApi.h"
#import "OSSVDetailCartExitApi.h"
#import "OSSVItemNoCache.h"

#import "OSSVDelCollectApi.h"
#import "OSSVAddCollectApi.h"
#import "OSSVDetailsRecommendApi.h"

// Cell and View
#import "OSSVDetailsCell.h"
#import "OSSVDetailsHeaderView.h"
#import "OSSVRecommendSectionGoodsInfoModule.h"
#import "OSSVRecommendSectionModule.h"
#import "OSSVRecommendHeaderModule.h"
#import "OSSVDetailAdvertiseViewModel.h"
#import "OSSVDetailServiceModule.h"
#import "OSSVDetailSizeDescModule.h"
#import "OSSVDetailActivityModule.h"
#import "OSSVDetailReviewNewModule.h"

// Controller
#import "STLShareCtrl.h"
#import "OSSVDetailsVC.h"
#import "OSSVFlashSaleMainVC.h"
#import "OSSVCategorysListVC.h"
#import "OSSVGoodsReviewVC.h"


#import "OSSVBuyAndBuyApi.h"
#import "OSSVDetailFastAddCCell.h"
#import "STLActionSheet.h"
#import "Adorawe-Swift.h"

@import FirebasePerformance;

#define EMPTY_RECOMMENT_SECTION_HEIGHT 544

@interface OSSVDetailsViewModel ()
<
    OSSVDetailsHeaderViewDelegate,
//    GoodsDetailsCellDelegate
    OSSVDetailRecommendCellDelegate,
    STLDetailsFastAddItemDelegate,
//OSSVDetailActivityCellDelegate,
//OSSVDetailInfoCellDelegate
OSSVDetailBaseCellDelegate
>

@property (nonatomic, strong) OSSVReviewsViewModel               *reviewsModel;

@property (nonatomic, strong) OSSVCartCheckModel                      *cartModel;
@property (nonatomic, assign) NSInteger                           page;
@property (nonatomic, assign) NSInteger                           buyAndBuyPage;
@property (nonatomic, weak) OSSVDetailsHeaderView                *detailsHeader;
@property (nonatomic, assign) BOOL                                isNotFirst;

@property (nonatomic,strong) OSSVItemNoCache        *noCacheFlashSale;


@property (nonatomic,strong) NSMutableDictionary *recommendRequestparams;

@property (nonatomic, strong) NSMutableArray <id<OSSVCollectionSectionProtocol>> *dataSource;

@property (nonatomic,strong) STLActionSheet *detailSheet;

@property (nonatomic, assign) BOOL                                isShowSize;

@property (nonatomic,strong) FIRTrace *trace;

///折叠展开H5
@property (nonatomic,weak) OSSVDetailSizeDescCell *descCell;
@property (assign,nonatomic) BOOL shoDescH5;

@end

@implementation OSSVDetailsViewModel

-(void)dealloc {
    DLog(@"OSSVDetailsViewModel dealloc");
    
    [_detailsHeader clearMemory];
    [_detailsHeader removeConstraints:_detailsHeader.constraints];
    _reviewsModel = nil;
    _detailsReviewsModel = nil;
    _goodsDetailAnalyticsManager = nil;
    _dataSource = nil;
    _recommendGoodsArray = nil;
    _detailModel = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[OSSVAnalyticInjectsManager shareInstance] analyticsInject:self injectObject:self.goodsDetailAnalyticsManager];
    }
    return self;
}

- (void)setAnalyticsDic:(NSMutableDictionary *)analyticsDic {
    _analyticsDic = analyticsDic;
    self.goodsDetailAnalyticsManager.sourecDic = analyticsDic;
}

- (void)addCartEventSuccess:(OSSVDetailsBaseInfoModel *)viewModel status:(BOOL)flag {
    
}


- (void)scrollRecommendPosition {
    
    NSArray<id<OSSVCollectionSectionProtocol>> * tempSourceArrays = [self cellSourceDatas];
    
    BOOL hasRecommendGoods = NO;
    if (tempSourceArrays.lastObject && [tempSourceArrays.lastObject isKindOfClass:[OSSVRecommendSectionModule class]]) {
        OSSVRecommendSectionModule *recommendModule = (OSSVRecommendSectionModule *)tempSourceArrays.lastObject;
        if (STLJudgeNSArray(recommendModule.sectionDataSource) && recommendModule.sectionDataSource.count > 4) {
            hasRecommendGoods = YES;
        }
    }
    if (!hasRecommendGoods) {
        return;
    }
    
    CGFloat scrollContentOffsetY = 0;
    for (id<OSSVCollectionSectionProtocol> sectionProtocol in tempSourceArrays) {
        if (sectionProtocol.sectionType == STLGoodsDetailSectionTypeAdvertizeView) {
            
            OSSVDetailAdvertiseViewModel *advModel = (OSSVDetailAdvertiseViewModel *)sectionProtocol;
            if ([advModel respondsToSelector:@selector(sectionTop)]) {
                scrollContentOffsetY = [advModel sectionTop];
            }
            break;
        } else if(sectionProtocol.sectionType == STLGoodsDetailSectionTypeRecommendHeader) {
            OSSVRecommendHeaderModule *recommendHeaderModel = (OSSVRecommendHeaderModule *)sectionProtocol;
            
            if ([recommendHeaderModel respondsToSelector:@selector(sectionTop)]) {
                scrollContentOffsetY = [recommendHeaderModel sectionTop];
            }
            break;
        }
    }
    
    
    CGFloat topMarginttt = kIS_IPHONEX ? 84 : 60;
    CGFloat targetY = scrollContentOffsetY - topMarginttt;
    if (targetY <= 0) {
        return;
    }
    [self.weakCollectionView setContentOffset:CGPointMake(0, targetY + 5) animated:YES];
}

- (NSMutableArray<id<OSSVCollectionSectionProtocol>> *)cellSourceDatas {
    return self.dataSource;
}

#pragma mark
#pragma mark - Product data

- (void)requestGoodsListBaseInfo:(NSDictionary *)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure{
    ///1.4.6 先检查非CDN
    [self requestCartExit:parmaters completion:^(BOOL has) {
        [self requestGoodsListBaseInfoWithoutChenk:parmaters completion:completion failure:failure];
    } failure:^(BOOL has) {
        [self requestGoodsListBaseInfoWithoutChenk:parmaters completion:completion failure:failure];
    }];
}

- (void)requestGoodsListBaseInfoWithoutChenk:(NSDictionary *)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:parmaters];
    
    NSInteger isLogin = [OSSVAccountsManager sharedManager].isSignIn ? 1 : 0;
    if (isLogin && USERID) {
        [dic setObject:STLToString(USER_TOKEN) forKey:@"token"];
    }
    
    OSSVDetailsApi *api = [[OSSVDetailsApi alloc] initWithGoodsDetailGoods:dic];
    [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view isEnable:YES]];
    
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        
        if (request.isCacheData) {
            return;
        }
        
        id requestJSON = [OSSVNSStringTool desEncrypt:request];

        self.detailModel = [self dataAnalysisFromJson: requestJSON request:api];
        self.recommendGoodsArray = [NSMutableArray arrayWithArray:self.detailModel.recommend.goodList];
        
        if (self.noCacheFlashSale) {
            self.detailModel.goodsBaseInfo.flash_sale = [STLFlashSaleModel yy_modelWithJSON:[self.noCacheFlashSale.flash_sale yy_modelToJSONData]];
            self.detailModel.goodsBaseInfo.isCollect = [self.noCacheFlashSale.is_collect boolValue];
            self.detailModel.goodsBaseInfo.goodsNumber = self.noCacheFlashSale.goods_number;
        }
        self.noCacheFlashSale = nil;
        


        if (completion) {
            completion(self.detailModel.goodsBaseInfo);
        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

///商品详情快速加购
- (void)requestNetworkOnly:(NSDictionary *)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    ///1.4.6 先检查非CDN
    [self requestCartExit:parmaters completion:^(BOOL has) {
        [self requestNetworkOnlyWithoutCheck:parmaters completion:completion failure:failure];
    } failure:^(BOOL has) {
        [self requestNetworkOnlyWithoutCheck:parmaters completion:completion failure:failure];
    }];
    
}

- (void)requestNetworkOnlyWithoutCheck:(NSDictionary *)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:parmaters];
    
    NSInteger isLogin = [OSSVAccountsManager sharedManager].isSignIn ? 1 : 0;
    if (isLogin && USERID) {
        [dic setObject:STLToString(USER_TOKEN) forKey:@"token"];
    }
    OSSVDetailsApi *api = [[OSSVDetailsApi alloc] initWithGoodsDetailGoods:dic];
    if ([parmaters[@"loadState"] integerValue] == 1) {
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view isEnable:YES]];
    }
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        if (request.isCacheData) {
            return;
        }
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        OSSVDetailsListModel *detailsModel = [self dataAnalysisFromJson: requestJSON request:api];
        detailsModel.goodsBaseInfo.detailSourceType = self.detailSourceType;
        
        if (self.noCacheFlashSale) {
            detailsModel.goodsBaseInfo.flash_sale = [STLFlashSaleModel yy_modelWithJSON:[self.noCacheFlashSale.flash_sale yy_modelToJSONData]];
            detailsModel.goodsBaseInfo.isCollect = [self.noCacheFlashSale.is_collect boolValue];
            detailsModel.goodsBaseInfo.free_goods_exists = self.noCacheFlashSale.free_goods_exists;
            detailsModel.goodsBaseInfo.goodsNumber = self.noCacheFlashSale.goods_number;
        }
        self.noCacheFlashSale = nil;
        
        if (completion) {
            completion(detailsModel.goodsBaseInfo);
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}



////只商品详情请求 调用
- (void)requestNetwork:(NSDictionary *)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure{
    
    _trace = [FIRPerformance startTraceWithName:@"goods_details"];
    ///1.4.6 先检查非CDN
    [self requestCartExit:parmaters completion:^(BOOL has) {
        [self requestNetworkWithoutCheck:parmaters completion:completion failure:failure];
    } failure:^(BOOL has) {
        [self requestNetworkWithoutCheck:parmaters completion:completion failure:failure];
    }];
}

- (void)requestNetworkWithoutCheck:(NSDictionary *)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:parmaters];
    
    NSInteger isLogin = [OSSVAccountsManager sharedManager].isSignIn ? 1 : 0;
    if (isLogin && USERID) {
        [dic setObject:STLToString(USER_TOKEN) forKey:@"token"];
    }
    
    OSSVDetailsApi *api = [[OSSVDetailsApi alloc] initWithGoodsDetailGoods:dic];
    if ([parmaters[@"loadState"] integerValue] == 1) {
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view isEnable:YES]];
    }
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        [self.trace stop];
        if (request.isCacheData) {
            return;
        }
        
        //self.detailsReviewsModel = nil; 等待评论接口出来在刷新
        [self.goodsDetailAnalyticsManager refreshDataSource];
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        
        self.detailModel = [self dataAnalysisFromJson: requestJSON request:api];
        self.detailModel.reviewsModel = self.detailsReviewsModel;
       
        self.detailModel.goodsBaseInfo.detailSourceType = self.detailSourceType;
        self.goodsDetailAnalyticsManager.reviewStateDic = nil;
        
        self.shoDescH5 = false;
        self.descCell.webView.hidden = true;
        
        ///1.4.6 不走缓存
        if (self.noCacheFlashSale) {
            self.detailModel.goodsBaseInfo.flash_sale = [STLFlashSaleModel yy_modelWithJSON:[self.noCacheFlashSale.flash_sale yy_modelToJSONData]];
            self.detailModel.goodsBaseInfo.isCollect = [self.noCacheFlashSale.is_collect boolValue];
            self.detailModel.goodsBaseInfo.goodsNumber = self.noCacheFlashSale.goods_number;
        }
        
        self.noCacheFlashSale = nil;
        
        NSMutableDictionary *analyticsDic = [[NSMutableDictionary alloc] initWithDictionary:self.analyticsDic];
        [analyticsDic setObject:STLToString(self.detailModel.goodsBaseInfo.goods_sn) forKey:kAnalyticsSku];
        [analyticsDic setObject:self.detailModel.goodsBaseInfo ?:[OSSVDetailsBaseInfoModel new]  forKey:@"baseModel"];
        self.analyticsDic = analyticsDic;
        
        self.goodsDetailAnalyticsManager.controller = self.controller;
        
        [self baseViewChangePV:self.detailModel.goodsBaseInfo first:!self.isNotFirst];
        self.isNotFirst = YES;
        
        if (completion) {
            completion(self.detailModel.goodsBaseInfo);
        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        @strongify(self)
        [self.trace stop];
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestGoodsBuyAndBuyList:(NSDictionary *)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:parmaters];
    
    NSInteger currentPage = self.buyAndBuyPage;
    if ([parmaters[@"loadState"] integerValue] == 1) {
        self.buyAndBuyPage = 1;
        currentPage = 1;
    } else {
        currentPage ++;
    }
    
    dic[@"page"] = @(self.buyAndBuyPage);
    dic[@"sku"] = parmaters[@"sku"];
    dic[@"pageSize"] = @(20);

    ///1.3.8 区分买了又买
    //dic[@""] =
    OSSVBuyAndBuyApi *api = [[OSSVBuyAndBuyApi alloc] initWithParams:dic];
    
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        self.buyAndBuyPage++;
        
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        if (currentPage == 1) {
            self.recommendGoodsArray = [self dataAnalysisFromJson: requestJSON request:api];
        } else {
            if (!STLJudgeNSArray(self.recommendGoodsArray)) {
                self.recommendGoodsArray = [[NSMutableArray alloc] init];
            }
            [self.recommendGoodsArray addObjectsFromArray:[self dataAnalysisFromJson: requestJSON request:api]];
        }
        
        OSSVRecommendSectionModule *productSectionModel = self.dataSource.lastObject;
        if (productSectionModel && [productSectionModel isKindOfClass:[OSSVRecommendSectionModule class]]) {
            if (self.recommendGoodsArray.count > 0) {
                productSectionModel.sectionDataSource = self.recommendGoodsArray.mutableCopy;
            }else if(currentPage == 1){
                productSectionModel.sectionDataSource = [@[] mutableCopy];
                productSectionModel.contentHeight = EMPTY_RECOMMENT_SECTION_HEIGHT;
            }
        } else {
            //推荐商品
            if (self.recommendGoodsArray.count > 0 || currentPage == 1) {
                productSectionModel = [[OSSVRecommendSectionModule alloc] init];
                productSectionModel.sectionType = STLGoodsDetailSectionTypeRecommend;
                productSectionModel.minimumInteritemSpacing = 12;
                productSectionModel.minimumLineSpacing = 12;
                productSectionModel.lineRows = 2;
                productSectionModel.isTopSpace = YES;
                productSectionModel.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
                productSectionModel.sectionDataSource = self.recommendGoodsArray.mutableCopy;
                [self.dataSource addObject:productSectionModel];
                
                if (currentPage == 1) {
                    productSectionModel.contentHeight = EMPTY_RECOMMENT_SECTION_HEIGHT;
                }
            }
        }
        
        
        [self.weakCollectLayout reloadSection:1];

        if (completion) {
            id total = requestJSON[kResult][@"total"];
            NSArray *arr = self.recommendGoodsArray;
            NSDictionary *allCount = @{
                @"total":total,
                @"arr":arr
            };
            completion(allCount);
        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestGoodsRecommendsList:(NSDictionary *)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:parmaters];
    
    NSInteger currentPage = self.page;
    if ([parmaters[@"loadState"] integerValue] == 1) {
        self.page = 1;
        currentPage = 1;
    } else {
        currentPage ++;
    }
    
    dic[@"page"] = @(self.page);

    ///1.3.8 区分买了又买
    //dic[@""] =
    OSSVDetailsRecommendApi *api = [[OSSVDetailsRecommendApi alloc] initWithGoodsDetailRecommends:dic];
    
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        self.page++;
        
        OSSVDetailsListModel *goodsDetails = nil;
        
        if (currentPage == 1) {
            
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            goodsDetails = [self dataAnalysisFromJson: requestJSON request:api];
            self.recommendGoodsArray = [NSMutableArray arrayWithArray:goodsDetails.recommend.goodList];

            
        } else {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
//            requestJSON[@"result"][@"request_id"] = requestJSON[@"result"][@"recommend"][@"request_id"];
            goodsDetails = [self dataAnalysisFromJson: requestJSON request:api];
            if (!STLJudgeNSArray(self.recommendGoodsArray)) {
                self.recommendGoodsArray = [[NSMutableArray alloc] init];
            }
            [self.recommendGoodsArray addObjectsFromArray:goodsDetails.recommend.goodList];
        }
        
        ///test recommend
//        goodsDetails.request_id = @"request_id_from_item";
        
        self.analyticsDic[kAnalyticsRequestIdFromItem] = [ABTestTools Recommand_abWithRequestId:goodsDetails.request_id];
        
        OSSVRecommendSectionModule *productSectionModel = self.dataSource.lastObject;
        if (productSectionModel && [productSectionModel isKindOfClass:[OSSVRecommendSectionModule class]]) {
            if (self.recommendGoodsArray.count > 0) {
                productSectionModel.sectionDataSource = self.recommendGoodsArray.mutableCopy;
            }else if(currentPage == 1){
                productSectionModel.sectionDataSource = [@[] mutableCopy];
                productSectionModel.contentHeight = EMPTY_RECOMMENT_SECTION_HEIGHT;
            }
        } else {
            //推荐商品
            if (self.recommendGoodsArray.count > 0 || currentPage == 1) {
                productSectionModel = [[OSSVRecommendSectionModule alloc] init];
                productSectionModel.sectionType = STLGoodsDetailSectionTypeRecommend;
                productSectionModel.minimumInteritemSpacing = 12;
                productSectionModel.minimumLineSpacing = 12;
                productSectionModel.lineRows = 2;
                productSectionModel.isTopSpace = YES;
                productSectionModel.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
                productSectionModel.sectionDataSource = self.recommendGoodsArray.mutableCopy;
                [self.dataSource addObject:productSectionModel];
                
                if (currentPage == 1) {
                    productSectionModel.contentHeight = EMPTY_RECOMMENT_SECTION_HEIGHT;
                }
            }
        }
        
        
//        [self.weakCollectLayout reloadSection:1];
        [self.weakCollectionView reloadData];

        if (completion) {
            completion(goodsDetails);
        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}


///购物车里面是否有0元商品
- (void)requestCartExit:(NSDictionary *)parmaters completion:(void (^)(BOOL))completion failure:(void (^)(BOOL))failure{
    OSSVDetailCartExitApi *api = [[OSSVDetailCartExitApi alloc] initWithParms:parmaters];
    
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        
        OSSVItemNoCache *data = [self dataAnalysisFromJson: requestJSON request:api];
//        data.goods_number = @"3"; //测试信息
        self.noCacheFlashSale = data;
        BOOL isExit = NO;
        if (data && data.free_goods_exists.boolValue) {
            isExit = YES;
        }
        if (completion) {
            completion(isExit);
        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(NO);
        }
    }];
}


#pragma mark
#pragma mark - 猜你喜欢商品，收藏和取消收藏的 请求
- (void)requestCollectAddNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSArray *array = (NSArray *)parmaters;
    OSSVAddCollectApi *api = [[OSSVAddCollectApi alloc] initWithAddCollectGoodsId:array[0] wid:array[1]];
    [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];

    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        if (completion) {
            completion(nil);
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

#pragma mark - Cancel the collection
- (void)requestCollectDelNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSArray *array = (NSArray *)parmaters;
    OSSVDelCollectApi *api = [[OSSVDelCollectApi alloc] initWithAddCollectGoodsId:array[0] wid:array[1]];
    [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        if (completion) {
            completion(nil);
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

#pragma mark - Data parsing
- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[OSSVDetailsApi class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [OSSVDetailsListModel yy_modelWithJSON:json[kResult]];
        }else {
            [self alertMessage:json[@"message"]];
        }
    } else if([request isKindOfClass:[OSSVDetailsRecommendApi class]] ) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [OSSVDetailsListModel yy_modelWithJSON:json[kResult]];
        }
    }
    else if ([request isKindOfClass:[OSSVBuyAndBuyApi class]]){
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [NSArray yy_modelArrayWithClass:OSSVGoodsListModel.class json:json[kResult][@"goodsList"]];
        }else {
            [self alertMessage:json[@"message"]];
        }
    }else if([request isKindOfClass:[OSSVDetailCartExitApi class]]){
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            NSDictionary *result = json[kResult];
            if (STLJudgeNSDictionary(result)) {
                OSSVItemNoCache *data = [OSSVItemNoCache yy_modelWithJSON:result];
                return data;
            }
        }else {
            return nil;
        }
    }
    else {
        [self alertMessage:json[@"message"]];
    }
    return nil;
}

- (void)configureData:(OSSVDetailsListModel *)model {
    [model configureTopBannerWeight];
    
    OSSVRecommendSectionModule *recommendSectionModel = nil;
    if (self.dataSource.lastObject && [self.dataSource.lastObject isKindOfClass:[OSSVRecommendSectionModule class]]) {
        recommendSectionModel = (OSSVRecommendSectionModule *)self.dataSource.lastObject;
    }
    
    [self.dataSource removeAllObjects];
    
    
    
    CGFloat contetH = [OSSVDetailInfoCell fetchSizeCellHeight:model reviewModel:self.detailsReviewsModel];
    OSSVRecommendSectionGoodsInfoModule *goodsInfoModule = [[OSSVRecommendSectionGoodsInfoModule alloc] init];
    goodsInfoModule.sectionType = STLGoodsDetailSectionTypeGoodsInfo;
    goodsInfoModule.cellSize = CGSizeMake(SCREEN_WIDTH, contetH);
    goodsInfoModule.sectionDataSource = @[[[NSObject alloc] init]].mutableCopy;

    [_dataSource addObject:goodsInfoModule];
    

    OSSVDetailServiceModule *goodsServiceModule = [[OSSVDetailServiceModule alloc] init];
    goodsServiceModule.sectionType = STLGoodsDetailSectionTypeService;
    goodsServiceModule.sectionDataSource = @[[[NSObject alloc] init]].mutableCopy;
    [_dataSource addObject:goodsServiceModule];
    
    BOOL hasActivity = NO;
    //////闪购活动中 不显示满减活动
    if (!STLIsEmptyString(model.goodsBaseInfo.specialId) || (model.goodsBaseInfo.flash_sale && [model.goodsBaseInfo.flash_sale isFlashActiving])) {
    } else {
        if ([model.goodsBaseInfo.bundleActivity isKindOfClass:[NSArray class]] && model.goodsBaseInfo.bundleActivity.count > 0) {
            hasActivity = YES;
        }
    }
    
    if (hasActivity) {
        OSSVDetailActivityModule *goodsActiviytModule = [[OSSVDetailActivityModule alloc] init];
        goodsActiviytModule.sectionType = STLGoodsDetailSectionTypeAcitvity;
        goodsActiviytModule.sectionDataSource = @[[[NSObject alloc] init]].mutableCopy;
        [_dataSource addObject:goodsActiviytModule];
    }
    
    ///
    ///高度动态变
    ///
    OSSVDetailSizeDescModule *goodsSizeDescModule = [[OSSVDetailSizeDescModule alloc] init];
    goodsSizeDescModule.sectionType = STLGoodsDetailSectionTypeSizeDesc;
    goodsSizeDescModule.sectionDataSource = @[[[NSObject alloc] init]].mutableCopy;

    goodsSizeDescModule.cellSize = CGSizeMake(SCREEN_WIDTH, kSizeDescHeight);
//    OSSVSpecsModel *sizeModel = [model.goodsBaseInfo goodsChartSizeUrl];
//    if (sizeModel) {
//        goodsSizeDescModule.cellSize = CGSizeMake(SCREEN_WIDTH, 100);
//    }
    
    [_dataSource addObject:goodsSizeDescModule];
    
    OSSVDetailReviewNewModule *reviewNewModule = [[OSSVDetailReviewNewModule alloc] init];
    reviewNewModule.sectionType = STLGoodsDetailSectionTypeReviewNew;
    reviewNewModule.sectionDataSource = @[[[NSObject alloc] init]].mutableCopy;
    [_dataSource addObject:reviewNewModule];

    if (self.detailModel.banner.count > 0) {
        OSSVDetailAdvertiseViewModel *advertiseViewmodel = [[OSSVDetailAdvertiseViewModel alloc] init];
        advertiseViewmodel.sectionType = STLGoodsDetailSectionTypeAdvertizeView;
        advertiseViewmodel.sectionDataSource = @[self.detailModel].mutableCopy;
        //advertiseViewmodel.sectionDataSource = @[].mutableCopy;
        [_dataSource addObject:advertiseViewmodel];
    }
    
    
    OSSVRecommendHeaderModule *recommendHeaderModule = [[OSSVRecommendHeaderModule alloc] init];
    recommendHeaderModule.sectionType = STLGoodsDetailSectionTypeRecommendHeader;
    recommendHeaderModule.sectionDataSource = @[[[NSObject alloc] init]].mutableCopy;
    [_dataSource addObject:recommendHeaderModule];
    
    if (recommendSectionModel) {
        [_dataSource addObject:recommendSectionModel];
    }
}

#pragma mark
#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    id<OSSVCollectionSectionProtocol> sectionProtocl = self.dataSource[section];
    return sectionProtocl.sectionDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    id<OSSVCollectionSectionProtocol>sectionProtocol = self.dataSource[indexPath.section];
    id<OSSVCollectionCellDatasourceProtocol>dataSourceProtocol = sectionProtocol.sectionDataSource[indexPath.row];

    if (sectionProtocol.sectionType == STLGoodsDetailSectionTypeGoodsInfo) {
        OSSVDetailInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVDetailInfoCell.class) forIndexPath:indexPath];
        [cell updateDetailInfoModel:self.detailModel recommend:YES];
        cell.stlDelegate = self;
        cell.colorSizeView.colorSizeViewVIV.addButton = self.bottomView.addBtn;
        self.detailSizeSheet.colorSizePickView.siblingView = cell.colorSizeView.colorSizeViewVIV;
        return cell;
        
    } else if(sectionProtocol.sectionType == STLGoodsDetailSectionTypeAcitvity) {
        OSSVDetailActivityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVDetailActivityCell.class) forIndexPath:indexPath];
        [cell updateHeaderGoodsSelect:self.detailModel.goodsBaseInfo];
        cell.stlDelegate = self;
        return cell;
        
    } else if(sectionProtocol.sectionType == STLGoodsDetailSectionTypeService) {
        OSSVDetailServicesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVDetailServicesCell.class) forIndexPath:indexPath];
        cell.infoModel = self.detailModel.goodsBaseInfo;
        cell.stlDelegate = self;
        return cell;
        
    } else if(sectionProtocol.sectionType == STLGoodsDetailSectionTypeSizeDesc) {
        OSSVDetailSizeDescCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVDetailSizeDescCell.class) forIndexPath:indexPath];
        [cell addObserver:self forKeyPath:@"bodyH" options:NSKeyValueObservingOptionNew context:nil];
        self.descCell = cell;
        cell.stlDelegate = self;
        [cell updateHeaderGoodsSelect:self.detailModel.goodsBaseInfo];
        return cell;
    }
    else if(sectionProtocol.sectionType == STLGoodsDetailSectionTypeReviewNew) {
        OSSVDetailReviewNewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVDetailReviewNewCell.class) forIndexPath:indexPath];
        cell.layer.masksToBounds = true;
        cell.model = self.detailsReviewsModel;
        cell.stlDelegate = self;
        return cell;
    }
//    else if (sectionProtocol.sectionType == STLGoodsDetailSectionTypeReviewStar) {
//        OSSVDetailReviewStarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVDetailReviewStarCell.class) forIndexPath:indexPath];
//        cell.model = dataSourceProtocol;
//        return cell;;
//    } else if(sectionProtocol.sectionType == STLGoodsDetailSectionTypeReview) {
//        OSSVDetailReviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVDetailReviewCell.class) forIndexPath:indexPath];
//        cell.model = dataSourceProtocol;
//        return cell;
//    } else if(sectionProtocol.sectionType == STLGoodsDetailSectionTypeReviewViewAll) {
//        STLGoodsDetailReviewMoreCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(STLGoodsDetailReviewMoreCell.class) forIndexPath:indexPath];
//        return cell;
//    }
    else if(sectionProtocol.sectionType == STLGoodsDetailSectionTypeAdvertizeView) {
        OSSVDetailAdvertiseViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVDetailAdvertiseViewCell.class) forIndexPath:indexPath];
        self.advcertiseCell = cell;
        cell.model = dataSourceProtocol;
        cell.stlDelegate = self;
        return cell;
    }
    
    if ([sectionProtocol isKindOfClass:[OSSVRecommendSectionModule class]]) {
        ///1.3.8 买了又买下面添加加购按钮
        NSInteger bottomRequestType = [[self.controller valueForKey:@"bottomRequestType"] integerValue];
        if (bottomRequestType == 1) {
            OSSVDetailFastAddCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVDetailFastAddCCell.class) forIndexPath:indexPath];
            cell.model = dataSourceProtocol;
            cell.addToCartDelegate = self;
            return cell;
        }
        OSSVDetailRecommendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVDetailRecommendCell.class) forIndexPath:indexPath];
        cell.model = dataSourceProtocol;
        cell.delegate = self;
        return cell;
    } else if([sectionProtocol isKindOfClass:[OSSVRecommendHeaderModule class]]) {
        
        OSSVDetailRecommendHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVDetailRecommendHeaderCell.class) forIndexPath:indexPath];
        self.recommendHeaderCell = cell;
        return cell;
    }
    
    OSSVDetailRecommendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVDetailRecommendCell.class) forIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if([kind isEqualToString:DetailCustomerLayoutHeader]) {
        OSSVDetailsHeaderView *headerView = [OSSVDetailsHeaderView goodsDetailsHeaderWithCollectionView:collectionView Kind:kind IndexPath:indexPath];        
        headerView.coverImageUrl = self.coverImgaeUrl;
        headerView.userInteractionEnabled = NO;
        [headerView updateDetailInfoModel:self.detailModel recommend:NO];
        headerView.delegate = self;
        self.detailsHeader = headerView;
        return headerView;
    }
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
    headerView.backgroundColor = OSSVThemesColors.col_F1F1F1;
    headerView.hidden = YES;
    
    return headerView;
    
}

-(void)fastAddItemCell:(OSSVDetailFastAddCCell *)cell addToCart:(NSDictionary *)item{
    NSIndexPath *indexPath = [self.weakCollectionView indexPathForCell:cell];
    
    NSMutableDictionary *dic = @{kAnalyticsPositionNumber  :   @(indexPath.row + 1),
                                 kAnalyticsKeyWord         :   STLToString(self.analyticsDic[kAnalyticsKeyWord])
    }.mutableCopy;
    self.detailSheet.analyticsDic = dic;
    [self requesData:item[@"goodsId"] wid:item[@"wid"]];
    
    OSSVGoodsListModel *model = item[@"model"];
    [GATools logEventWithGoodsListWithEventName:@"add_to_cart"
                                    screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.detailModel.goodsBaseInfo.goodsTitle)]
                                       position:@"Product Detail_Recommend"
                                          value:STLToString(model.shop_price)
                                          items:@[
        [[GAEventItems alloc] initWithItem_id:STLToString(model.goodsId)
                                    item_name:STLToString(model.goodsTitle)
                                   item_brand:[OSSVLocaslHosstManager appName]
                                item_category:STLToString(model.cat_name)
                                 item_variant:@""
                                        price:STLToString(model.shop_price)
                                     quantity:@(1) currency:@"USD"
                                    index:nil]
    ]];
    
    
}

- (void)requesData:(NSString*)goodsId wid:(NSString*)wid {
    self.weakCollectionView.allowsSelection = NO;
    @weakify(self)
    NSDictionary *dic = dic = @{@"goods_id":STLToString(goodsId),
                                @"loadState":STLRefresh,
                                @"wid":STLToString(wid),
                                @"specialId":STLToString(@"")};
    
    [self requestNetworkOnly:dic completion:^(OSSVDetailsBaseInfoModel *obj) {
        self.weakCollectionView.allowsSelection = YES;
        @strongify(self)
        if (obj && [obj isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
            OSSVDetailsBaseInfoModel *baseInfoModel = (OSSVDetailsBaseInfoModel *)obj;
            self.detailSheet.baseInfoModel = baseInfoModel;
            self.detailSheet.hadManualSelectSize = YES;
            if (STLIsEmptyString(baseInfoModel.specialId) && baseInfoModel.flash_sale && !STLIsEmptyString(baseInfoModel.flash_sale.active_discount) && [baseInfoModel.flash_sale.active_discount floatValue] > 0) {
                _detailSheet.hasFirtFlash = YES;
            }else{
                _detailSheet.hasFirtFlash = NO;
            }
            [self.detailSheet addCartAnimationTop:0 moveLocation:CGRectZero showAnimation:NO];
            [self.controller.tabBarController.view addSubview:self.detailSheet];
            [UIView animateWithDuration: 0.25 animations: ^{
                [self.detailSheet shouAttribute];
                self.detailSheet.sourceType = STLAppsflyerGoodsSourceFlashList;
                self.detailSheet.type = GoodsDetailEnumTypeAdd;
            } completion: nil];
            
        }
    } failure:^(id obj) {
        self.weakCollectionView.allowsSelection = YES;
    }];
}

- (void)requesData:(NSString*)goodsId wid:(NSString*)wid specialId:(NSString *)specialId{
    @weakify(self)
    NSDictionary *dic = dic = @{@"goods_id":STLToString(goodsId),
                                @"loadState":STLRefresh,
                                @"wid":STLToString(wid),
                                @"specialId":STLToString(specialId)};
    
    [self requestNetworkOnly:dic completion:^(OSSVDetailsBaseInfoModel *obj) {
        @strongify(self)
        if (obj && [obj isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
            OSSVDetailsBaseInfoModel *baseInfoModel = (OSSVDetailsBaseInfoModel *)obj;
            self.detailSheet.baseInfoModel = baseInfoModel;
            self.detailSheet.hadManualSelectSize = YES;
            if (STLIsEmptyString(baseInfoModel.specialId) && baseInfoModel.flash_sale && !STLIsEmptyString(baseInfoModel.flash_sale.active_discount) && [baseInfoModel.flash_sale.active_discount floatValue] > 0) {
                _detailSheet.hasFirtFlash = YES;
            }else{
                _detailSheet.hasFirtFlash = NO;
            }
            [self.detailSheet addCartAnimationTop:0 moveLocation:CGRectZero showAnimation:NO];
            [self.controller.tabBarController.view addSubview:self.detailSheet];
            [UIView animateWithDuration: 0.25 animations: ^{
                [self.detailSheet shouAttribute];
                self.detailSheet.sourceType = STLAppsflyerGoodsSourceFlashList;
                self.detailSheet.type = GoodsDetailEnumTypeAdd;
            } completion: nil];
            
        }
    } failure:^(id obj) {
    }];
}

- (STLActionSheet *)detailSheet {
    if (!_detailSheet) {
        CGFloat detailSheetY = kIS_IPHONEX? 88.f : 64.f;
        _detailSheet = [[STLActionSheet alloc] initWithFrame:CGRectMake(0, -detailSheetY, SCREEN_WIDTH, SCREEN_HEIGHT+detailSheetY)];
        _detailSheet.type = GoodsDetailEnumTypeAdd;
//        _detailSheet.hasFirtFlash = YES;
        _detailSheet.isListSheet = YES;
        _detailSheet.addCartType = 2;
        _detailSheet.showCollectButton = YES;
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
            ///触发红点
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
            detailVC.sourceType = STLAppsflyerGoodsSourceDetailRecommendOften;
            detailVC.coverImageUrl = STLToString(goodsImageUrl);
            [self.controller.navigationController pushViewController:detailVC animated:YES];
            
            [self.detailSheet dismiss];
        };
    }
    return _detailSheet;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (self.dataSource.count > indexPath.section) {
        id<OSSVCollectionSectionProtocol>sectionProtocol = self.dataSource[indexPath.section];
        id<OSSVCollectionCellDatasourceProtocol>dataSourceProtocol = sectionProtocol.sectionDataSource[indexPath.row];
        
        if (sectionProtocol.sectionType == STLGoodsDetailSectionTypeRecommend) {
            [self goGoodsDetail:dataSourceProtocol withIndexPath:indexPath];
        } else if(sectionProtocol.sectionType == STLGoodsDetailSectionTypeReviewViewAll) {
            [self goReviewList];
        }else if(sectionProtocol.sectionType == STLGoodsDetailSectionTypeAdvertizeView) {
//            [self goReviewList];
        } else if(sectionProtocol.sectionType == STLGoodsDetailSectionTypeReviewStar) {
            [self goReviewList];
        }
    }
}

#pragma mark - layout dataSource  自定义

- (NSInteger)customerLayoutNumsSection:(UICollectionView *)collectionView {
    return [self.dataSource count];
}

-(id<OSSVCollectionSectionProtocol>)customerLayoutDatasource:(UICollectionView *)collectionView sectionNum:(NSInteger)section {
    return self.dataSource[section];
}


/**
 * 返回section header 高度的方法
 */
-(CGFloat)customerLayoutSectionHeightHeight:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout indexPath:(NSIndexPath *)indexPath {

    if(self.dataSource.count > indexPath.section) {
        
        id<OSSVCollectionSectionProtocol> sectionProtocl = self.dataSource[indexPath.section];
        
        if ([sectionProtocl isKindOfClass:[OSSVRecommendSectionGoodsInfoModule class]]) {
            CGFloat goodsHeaderHeight = [OSSVDetailsHeaderView headerViewHeight];
            
            NSLog(@"头部 viewForSupplementaryElementOfKind   %f",goodsHeaderHeight);
            
            return goodsHeaderHeight;
        }
    }
    return 0;
}

//#pragma mark - cell delegate

//- (void)goodsDetailsActivityCCell:(OSSVDetailActivityCell *)goodsSelectView goodsEvent:(HeaderGoodsSelectEvent)event index:(NSInteger)index {
//
//    if (event == HeaderGoodsSelectEventActivityTip) {
//
//        ShowAlertViewFormatteButton(STLAlertViewFormateTypeButton,STLLocalizedString_(@"Clarification", nil), STLLocalizedString_(@"Clarification_tip",nil), @[STLLocalizedString_(@"confirm",nil)], YES, ^(NSInteger buttonIndex, id buttonTitle) {
//
//        }, nil, nil);
//
//    } else if(event == HeaderGoodsSelectEventActivity){
//
//        //满减活动
//        NSArray *boudlesArray = self.detailModel.goodsBaseInfo.bundleActivity;
//        if (boudlesArray.count > index) {
//
//            OSSVBundleActivityModel *model = boudlesArray[index];
//            OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] init];
//            advEventModel.actionType =  AdvEventTypeNativeCustom;
//            advEventModel.url = STLToString(model.activeId);
//            advEventModel.name = STLToString(model.activeName);
//            if ([advEventModel.url intValue] > 0) { //新增判断，activeId > 0 才能跳转
//                [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:advEventModel];
//            }
//        }
//    }
//}

#pragma mark - cell点击
#pragma mark 评论
- (void)goReviewList {

    if (self.detailsReviewsModel.reviewList.count > 0) {
        OSSVGoodsReviewVC *reviewsViewController = [OSSVGoodsReviewVC new];
        reviewsViewController.sku = self.detailModel.goodsBaseInfo.goods_sn;
        reviewsViewController.goodsId = self.detailModel.goodsBaseInfo.goodsId;
        [self.controller.navigationController pushViewController:reviewsViewController animated:YES];
    }
}

#pragma mark 详情
- (void)goGoodsDetail:(OSSVGoodsListModel *)model withIndexPath:(NSIndexPath *)indexPath{
    if (model && [model isKindOfClass:[OSSVGoodsListModel class]]) {
        
        
        UICollectionViewCell *cell = [self.weakCollectionView cellForItemAtIndexPath:indexPath];
        
        NSString *pageName = [UIViewController currentTopViewControllerPageName];
        NSDictionary *sensorsDicClick = @{@"page_name":STLToString(pageName),
                                          @"attr_node_1":@"other",
                                          @"attr_node_2":@"goods_recommend",
                                          @"attr_node_3":@"",
                                          @"position_number":@(indexPath.row+1),
                                          @"venue_position":@(0),
                                          @"action_type":@(0),
                                          @"url":@"",
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDicClick];
        
        STLAppsflyerGoodsSourceType sourceType = STLAppsflyerGoodsSourceDetailRecommendLike;
        
        if ([cell isKindOfClass:[OSSVDetailFastAddCCell class]]) {
            sourceType = STLAppsflyerGoodsSourceDetailRecommendOften;
        }
        OSSVDetailsVC *detailVC = [[OSSVDetailsVC alloc] init];
        detailVC.goodsId = model.goodsId;
        detailVC.wid = model.wid;
        detailVC.sourceType = sourceType;
        detailVC.coverImageUrl = STLToString(model.goodsImg);

        NSDictionary *dic = @{kAnalyticsAction:[OSSVAnalyticsTool sensorsSourceStringWithType:sourceType sourceID:@""],
                              kAnalyticsUrl:STLToString(self.detailModel.goodsBaseInfo.goods_sn),
                              kAnalyticsPositionNumber:@(indexPath.row+1),
                              kAnalyticsRequestId:STLToString(self.analyticsDic[kAnalyticsRequestIdFromItem]),
        };
        [detailVC.transmitMutDic addEntriesFromDictionary:dic];
        @weakify(self)
        detailVC.collectionBlock = ^(NSString *isCollection, NSString *goodsId) {
            @strongify(self)
            model.isCollect = isCollection;
            if (indexPath && self.weakCollectionView) {

                // 防止数据问题
                if (self.dataSource.count > indexPath.section) {
                    id<OSSVCollectionSectionProtocol>sectionProtocol = self.dataSource[indexPath.section];
                    if (sectionProtocol.sectionDataSource.count > indexPath.row) {
                        [self.weakCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                    }
                }
                
            }
        };
        self.controller.navigationController.navigationBarHidden = YES;
        [self.controller.navigationController pushViewController:detailVC animated:YES];
    }
}

#pragma mark - OSSVDetailBaseCellDelegate

- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell reiveMore:(BOOL)flag {
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_GoodsDetailsOperate:event:content:)]) {
        [self.delegate STL_GoodsDetailsOperate:self event:OSSVDetailsViewModelEventReview content:nil];
    }
}

- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell activityFlash:(NSString *)flashChannelId {
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_GoodsDetailsOperate:event:content:)]) {
        [self.delegate STL_GoodsDetailsOperate:self event:OSSVDetailsViewModelEventActivityFlash content:flashChannelId];
    }
}

- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell activityBuyFree:(OSSVBundleActivityModel *)activityModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_GoodsDetailsOperate:event:content:)]) {
        [self.delegate STL_GoodsDetailsOperate:self event:OSSVDetailsViewModelEventActivityBuy content:activityModel];
    }
}

- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell titleShowAll:(BOOL )showAll {
    
    for (id<OSSVCollectionSectionProtocol>  _Nonnull obj in self.dataSource) {
        if (obj.sectionType == STLGoodsDetailSectionTypeGoodsInfo) {
            OSSVRecommendSectionGoodsInfoModule *goodsInfoModule = (OSSVRecommendSectionGoodsInfoModule*)obj;
            self.detailModel.goodsBaseInfo.isShowLess = showAll;
            CGFloat contetH = [OSSVDetailInfoCell fetchSizeCellHeight:self.detailModel reviewModel:self.detailsReviewsModel];
            goodsInfoModule.cellSize = CGSizeMake(SCREEN_WIDTH, contetH);
            break;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_GoodsDetailsOperate:event:content:)]) {
        [self.delegate STL_GoodsDetailsOperate:self event:OSSVDetailsViewModelEventTitleAll content:@(showAll)];
    }
   
}
- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell coinsTip:(BOOL)flag {
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_GoodsDetailsOperate:event:content:)]) {
        [self.delegate STL_GoodsDetailsOperate:self event:OSSVDetailsViewModelEventCoins content:nil];
    }
}
- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell shipTip:(BOOL)flag {
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_GoodsDetailsOperate:event:content:)]) {
        [self.delegate STL_GoodsDetailsOperate:self event:OSSVDetailsViewModelEventTransportTime content:nil];
    }
}
- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell serviceTip:(BOOL)flag {
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_GoodsDetailsOperate:event:content:)]) {
        [self.delegate STL_GoodsDetailsOperate:self event:OSSVDetailsViewModelEventService content:nil];
    }
}

- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell sizeChat:(OSSVSpecsModel *)sizeModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_GoodsDetailsOperate:event:content:)]) {
        [self.delegate STL_GoodsDetailsOperate:self event:OSSVDetailsViewModelEventSizeChart content:sizeModel];
    }
}

- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell description:(NSString *)url {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_GoodsDetailsOperate:event:content:)]) {
//        [self.delegate STL_GoodsDetailsOperate:self event:OSSVDetailsViewModelEventDescription content:url];
//    }
    ///改成折叠展开H5
    [self toggleH5];
}

-(void)toggleH5{
    self.shoDescH5 = !self.shoDescH5;
    for (id<OSSVCollectionSectionProtocol> obj in self.dataSource) {
        if (obj.sectionType == STLGoodsDetailSectionTypeSizeDesc) {
            OSSVDetailSizeDescModule *cellModel = obj;
            CGFloat webViewH = self.shoDescH5 ? self.descCell.bodyH : 0;
            cellModel.cellSize = CGSizeMake(SCREEN_WIDTH, kSizeDescHeight + webViewH);
            [self.weakCollectionView reloadData];
            break;
        }
    }
    self.descCell.webView.hidden = !self.shoDescH5;
    self.recommendHeaderCell = self.shoDescH5 ? nil : self.recommendHeaderCell;

    
    [UIView animateWithDuration:0.3 animations:^{
        self.descCell.descView.rightArrow.transform =self.shoDescH5 ? CGAffineTransformMakeRotation(M_PI_2) : CGAffineTransformIdentity;
        [self.descCell.webView layoutSubviews];
    }];
}

- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell adv:(OSSVAdvsEventsModel *)advModel {
    
    self.controller.currentPageCode = STLToString(self.detailModel.goodsBaseInfo.goods_sn);
    [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:advModel];
}

#pragma mark - 点击事件----OSSVDetailsHeaderViewDelegate---代理事件
-(void)OSSVDetailsHeaderViewDidClick:(GoodsDetailsHeaderEvent)event {

    if (event == GoodsDetailsHeaderEventShare) {
        
        if (![OSSVAccountsManager sharedManager].isSignIn) {
            SignViewController *signVC = [SignViewController new];
            signVC.modalPresentationStyle = UIModalPresentationFullScreen;
            @weakify(self)
            signVC.modalBlock = ^{
                @strongify(self)
                [self callTheCustomToShare];
                
            };
            [self.controller presentViewController:signVC animated:YES completion:nil];

        } else {
            [self callTheCustomToShare];
        }

         
        return;
    }

    if (event == GoodsDetailsHeaderEventCollect) {
        [self collectionGoods];
        return;
    }
    
    if (event == GoodsDetailsHeaderEventGoodsSimilar) {
        OSSVCategorysListVC *categoriesVC = [OSSVCategorysListVC new];
        categoriesVC.isSimilar = YES;
        categoriesVC.childId = self.detailModel.goodsBaseInfo.top_cat_id;
        categoriesVC.childDetailTitle = self.detailModel.goodsBaseInfo.top_cat_name;
        [self.controller.navigationController pushViewController:categoriesVC animated:YES]; 
    }
}
#pragma mark -----商详商品的 收藏和取消收藏
- (void)collectionGoods {
    
    if (USERID) {
        if (self.detailModel.goodsBaseInfo.isCollect) {
            @weakify(self)
        //取消收藏
            [self requestCollectDelNetwork:@[self.detailModel.goodsBaseInfo.goodsId,self.detailModel.goodsBaseInfo.goodsWid] completion:^(id obj) {
                @strongify(self)


                [self alertMessage:STLLocalizedString_(@"removedWishlist",nil)];
                self.detailModel.goodsBaseInfo.isCollect = NO;
                NSInteger wishCount = [self.detailModel.goodsBaseInfo.wishCount integerValue] - 1;
                self.detailModel.goodsBaseInfo.wishCount = [NSString stringWithFormat:@"%ld",(long)(wishCount >0 ? wishCount : 0)];

                if (self.delegate && [self.delegate respondsToSelector:@selector(STL_GoodsDetailsOperate:event:content:)]) {
                    [self.delegate STL_GoodsDetailsOperate:self event:OSSVDetailsViewModelEventCollect content:nil];
                }
                //回调-----
                if (self.collectionBlock) {
                    self.collectionBlock(@"0",self.detailModel.goodsBaseInfo.goodsId);
                }
                /**GA埋点-----取消收藏*/
                NSDictionary *itemsDic = @{@"screen_group" : [NSString stringWithFormat:@"ProductDetail_%@", STLToString(self.detailModel.goodsBaseInfo.goodsTitle)],
                                           @"action"       : @"Remove",
                                           @"content"      : STLToString(self.detailModel.goodsBaseInfo.goodsTitle)
                };
                [OSSVAnalyticsTool analyticsGAEventWithName:@"wishList_action" parameters:itemsDic];

                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_Favorite object:self.detailModel.goodsBaseInfo];
            } failure:^(id obj) {
            }];
        } else {
            
            //收藏
            @weakify(self)
            [self requestCollectAddNetwork:@[self.detailModel.goodsBaseInfo.goodsId,self.detailModel.goodsBaseInfo.goodsWid] completion:^(id obj) {
                @strongify(self)
        
                [self alertMessage:STLLocalizedString_(@"addedWishlist",nil)];
                self.detailModel.goodsBaseInfo.isCollect = YES;
                self.detailModel.goodsBaseInfo.wishCount = [NSString stringWithFormat:@"%ld",(long)([self.detailModel.goodsBaseInfo.wishCount integerValue] + 1)];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(STL_GoodsDetailsOperate:event:content:)]) {
                    [self.delegate STL_GoodsDetailsOperate:self event:OSSVDetailsViewModelEventCollect content:nil];
                }
                // 谷歌统计 收藏
                [OSSVAnalyticsTool appsFlyeraAddToWishlistWithProduct:self.detailModel.goodsBaseInfo fromProduct:YES];
                
                
                //和鲍勇再次确认完全可以拿着is_can_buy 字段来判断用户能否按照闪购价继续购买，以及闪购背景置灰和 价格不为红色
                //GA
                CGFloat price = [self.detailModel.goodsBaseInfo.shop_price floatValue];;
                // 0 > 闪购 > 满减
                if (!STLIsEmptyString(self.detailModel.goodsBaseInfo.specialId)) {//0元
                    price = [self.detailModel.goodsBaseInfo.shop_price floatValue];
                    
                } else if (STLIsEmptyString(self.detailModel.goodsBaseInfo.specialId) && self.detailModel.goodsBaseInfo.flash_sale &&  [self.detailModel.goodsBaseInfo.flash_sale.is_can_buy isEqualToString:@"1"] && [self.detailModel.goodsBaseInfo.flash_sale.active_status isEqualToString:@"1"]) {//闪购
                    price = [self.detailModel.goodsBaseInfo.flash_sale.active_price floatValue];
                }

                NSDictionary *items = @{
                    @"item_id": STLToString(self.detailModel.goodsBaseInfo.goods_sn),
                    @"item_name": STLToString(self.detailModel.goodsBaseInfo.goodsTitle),
                    @"item_category": STLToString(self.detailModel.goodsBaseInfo.cat_name),
                    @"price": @(price),
                    @"quantity": @(1),

                };
                
                NSDictionary *itemsDic = @{@"items":@[items],
                                           @"currency": @"USD",
                                           @"value":  @(price),
                };
                
                [OSSVAnalyticsTool analyticsGAEventWithName:@"add_to_wishlist" parameters:itemsDic];

                NSDictionary *sensorsDic = @{@"goods_sn":STLToString(self.detailModel.goodsBaseInfo.goods_sn),
                                            @"goods_name":STLToString(self.detailModel.goodsBaseInfo.goodsTitle),
                                             @"cat_id":STLToString(self.detailModel.goodsBaseInfo.cat_id),
                                             @"cat_name":STLToString(self.detailModel.goodsBaseInfo.cat_name),
                                             @"original_price":@([STLToString(self.detailModel.goodsBaseInfo.market_price) floatValue]),
                                             @"present_price":@(price),
                                             @"entrance":@"collect_goods",
                                             kAnalyticsKeyWord:STLToString(self.analyticsDic[kAnalyticsKeyWord]),
                                             @"position_number":@(0)
                        };
                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsCollect" parameters:sensorsDic];
                
                if (self.collectionBlock) {
                    
                    self.collectionBlock(@"1",self.detailModel.goodsBaseInfo.goodsId);
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_Favorite object:self.detailModel.goodsBaseInfo];
            } failure:^(id obj) {

            }];
        };
    } else {
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        signVC.signBlock = ^{
            @strongify(self)
            [self collectionGoods];
        };
        [self.controller presentViewController:signVC animated:YES completion:^{
        }];
    }
    
    
}

#pragma mark
#pragma mark - Share
- (void)callTheSystemToShare {
    /*
     NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.goodsDetailsListModel.goodsBaseInfo.goodsImg]];
     UIImage *image = [UIImage imageWithData:data];
     */
    
    //分享默认网页 ？？？？
    NSURL *url = [NSURL URLWithString:@"http://m.adorawe.com"];
    if (![OSSVNSStringTool isEmptyString:self.detailModel.goodsBaseInfo.urlShare]) {
        url = [NSURL URLWithString:self.detailModel.goodsBaseInfo.urlShare];
    }
    
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
//    activity.excludedActivityTypes = @[UIActivityTypeAirDrop]; // activity types listed will not be displayed
    activity.completionWithItemsHandler = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {

        if (activityType == UIActivityTypePostToFacebook) {
            STLLog(@"UIActivityTypePostToFacebook");
        } else if (activityType == UIActivityTypeMessage) {
            STLLog(@"UIActivityTypeMessage");
        } else if (activityType == UIActivityTypeCopyToPasteboard){
            STLLog(@"other");
        }
//        if (completed) {
//            [HUDManager showHUDWithMessage:STLLocalizedString_(@"shareSucceess", nil)];
//        }
    };
    [self.controller presentViewController:activity animated:YES completion:nil];
}

- (void)callTheCustomToShare {

    STLShareCtrl *shareVC = [[STLShareCtrl alloc] init];
    shareVC.shareImage = self.detailModel.goodsBaseInfo.goodsImg;
    shareVC.shareURL = self.detailModel.goodsBaseInfo.urlShare;
    shareVC.shareGoodsID = self.detailModel.goodsBaseInfo.goodsId;

    shareVC.shareContent = @"#Adorawe I'm really <3 this. Lots of chic boutiques on Adorawe. Check it out!";
    NSString *price = self.detailModel.goodsBaseInfo.shop_price;
    NSString *title = self.detailModel.goodsBaseInfo.goodsUrlTitle;
    shareVC.shareTitle = [NSString stringWithFormat:@"$%@  %@",price,title];
    shareVC.shareSourceId = self.detailModel.goodsBaseInfo.goods_sn;
    if (self.controller) {
        shareVC.shareSourcePageName = NSStringFromClass(self.controller.class);
    }
    shareVC.type = 1;
    shareVC.sku = self.detailModel.goodsBaseInfo.goods_sn;
    shareVC.goodsBaseInfo = self.detailModel.goodsBaseInfo;
    [self.controller presentTranslucentViewController:shareVC animated:NO completion:nil];
    
    [GATools logGoodsDetailSimpleEventWithEventName:@"share_channel"
                                        screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.detailModel.goodsBaseInfo.goodsTitle)]
                                         buttonName:@"Sharing"];
}

- (OSSVDetailAnalyticsAOP *)goodsDetailAnalyticsManager {
    if (!_goodsDetailAnalyticsManager) {
        _goodsDetailAnalyticsManager = [[OSSVDetailAnalyticsAOP alloc] init];
        _goodsDetailAnalyticsManager.source = STLAppsflyerGoodsSourceGoodsDetail;
    }
    return _goodsDetailAnalyticsManager;
}



#pragma mark ----- GoodsDetailsCellDelegate -----商品列表cell代理------收藏与取消收藏

- (void)goodsDetailRecommendCell:(OSSVDetailRecommendCell *)cell goodsModel:(OSSVGoodsListModel *)model buttonSelected:(UIButton *)sender {
    if (!self.weakCollectionView) {
        return;
    }
    NSIndexPath *indexPath = [self.weakCollectionView indexPathForCell:cell];
    
    [GATools logEventWithGoodsListWithEventName:@"add_to_wishlist"
                                    screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.detailModel.goodsBaseInfo.goodsTitle)]
                                       position:@"Product Detail_Recommend"
                                          value:STLToString(model.shop_price)
                                          items:@[
        [[GAEventItems alloc] initWithItem_id:STLToString(model.goodsId)
                                    item_name:STLToString(model.goodsTitle)
                                   item_brand:[OSSVLocaslHosstManager appName]
                                item_category:STLToString(model.cat_name)
                                 item_variant:@""
                                        price:STLToString(model.shop_price)
                                     quantity:@(1) currency:@"USD" index:nil]
    ]];
    
    
    //    用户未登录
        if (![OSSVAccountsManager sharedManager].isSignIn) {
            SignViewController *signVC = [SignViewController new];
            signVC.modalPresentationStyle = UIModalPresentationFullScreen;
            @weakify(self)
            signVC.modalBlock = ^{
                @strongify(self)
                [self requesCollectionData:model selectedButton:sender index:indexPath.row];
            };
            [self.controller presentViewController:signVC animated:YES completion:nil];

        } else {
            [self requesCollectionData:model selectedButton:sender index:indexPath.row];
        }

}

- (void)requesCollectionData:(OSSVGoodsListModel *)model selectedButton:(UIButton *)button index:(NSInteger)index{
    button.selected = !button.selected;
    if (button.selected == YES) {
        model.isCollect = @"1";
    } else {
        model.isCollect = @"0";
    }

    @weakify(self)
    if (button.selected == YES) {
        @strongify(self)
        [self requestCollectAddNetwork:@[model.goodsId, model.wid] completion:^(id obj) {
         [self alertMessage:STLLocalizedString_(@"addedWishlist",nil)];
            button.selected = YES;

            OSSVDetailsBaseInfoModel *itemBaseInfoModel = [[OSSVDetailsBaseInfoModel alloc] init];
            itemBaseInfoModel.shop_price = model.shop_price;
            itemBaseInfoModel.goods_sn = model.goods_sn;
            itemBaseInfoModel.cat_name = model.cat_name;
            itemBaseInfoModel.cat_id = model.cat_id;
            itemBaseInfoModel.flash_sale = model.flash_sale;
            itemBaseInfoModel.goodsTitle = model.goodsTitle;
            itemBaseInfoModel.market_price = model.market_price;
            // 谷歌统计 收藏
            [OSSVAnalyticsTool appsFlyeraAddToWishlistWithProduct:itemBaseInfoModel fromProduct:YES];
            
            
            
            //和鲍勇再次确认完全可以拿着is_can_buy 字段来判断用户能否按照闪购价继续购买，以及闪购背景置灰和 价格不为红色
            //GA
            CGFloat price = [itemBaseInfoModel.shop_price floatValue];;
            // 0 > 闪购 > 满减
            if (itemBaseInfoModel.flash_sale &&  [itemBaseInfoModel.flash_sale.is_can_buy isEqualToString:@"1"] && [itemBaseInfoModel.flash_sale.active_status isEqualToString:@"1"]) {//闪购
                price = [itemBaseInfoModel.flash_sale.active_price floatValue];
            }
            

            [GATools logAddToWishListWithScreenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.detailModel.goodsBaseInfo.goodsTitle)]
                                               value:STLToString(self.detailModel.goodsBaseInfo.shop_price)
                                               items:@[
                [[GAEventItems alloc] initWithItem_id:STLToString(self.detailModel.goodsBaseInfo.goodsId)
                                            item_name:STLToString(self.detailModel.goodsBaseInfo.goodsTitle)
                                           item_brand:[OSSVLocaslHosstManager appName]
                                        item_category:STLToString(self.detailModel.goodsBaseInfo.cat_name)
                                         item_variant:@""
                                                price:STLToString(self.detailModel.goodsBaseInfo.shop_price)
                                             quantity:@(1) currency:@"USD" index:nil]
            ]];

//            NSDictionary *items = @{
//                @"item_id": STLToString(itemBaseInfoModel.goods_sn),
//                @"item_name": STLToString(itemBaseInfoModel.goodsTitle),
//                @"item_category": STLToString(itemBaseInfoModel.cat_name),
//                @"price": @(price),
//                @"quantity": @(1),
//
//            };
//
//            NSDictionary *itemsDic = @{@"items":@[items],
//                                       @"currency": @"USD",
//                                       @"value":  @(price),
//            };
//
//            [OSSVAnalyticsTool analyticsGAEventWithName:@"add_to_wishlist" parameters:itemsDic];

            NSDictionary *sensorsDic = @{@"goods_sn":STLToString(itemBaseInfoModel.goods_sn),
                                        @"goods_name":STLToString(itemBaseInfoModel.goodsTitle),
                                         @"cat_id":STLToString(itemBaseInfoModel.cat_id),
                                         @"cat_name":STLToString(itemBaseInfoModel.cat_name),
                                         @"original_price":@([STLToString(itemBaseInfoModel.market_price) floatValue]),
                                         @"present_price":@(price),
                                         @"entrance":@"collect_quick",
                                         kAnalyticsKeyWord:STLToString(self.analyticsDic[kAnalyticsKeyWord]),
                                         @"position_number":@(index+1)
                    };
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsCollect" parameters:sensorsDic];
            
        } failure:^(id obj) {
            button.selected = NO;


        }];
        
        
    } else {
        @strongify(self)
        [self requestCollectDelNetwork:@[model.goodsId, model.wid] completion:^(id obj) {
            [self alertMessage:STLLocalizedString_(@"removedWishlist",nil)];
            button.selected = NO;
            /**GA埋点-----取消收藏*/
            NSDictionary *itemsDic = @{@"screen_group" : [NSString stringWithFormat:@"ProductDetail_%@", STLToString(self.detailModel.goodsBaseInfo.goodsTitle)],
                                       @"action"       : @"Remove",
                                       @"content"      : STLToString(self.detailModel.goodsBaseInfo.goodsTitle)
            };
            [OSSVAnalyticsTool analyticsGAEventWithName:@"wishList_action" parameters:itemsDic];

        } failure:^(id obj) {
            button.selected = YES;

        }];
        
    }
}


-(NSMutableArray<id<OSSVCollectionSectionProtocol>> *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}


- (id)getCellModuleType:(STLGoodsDetailSectionType)sectionType {
    
    __block id<OSSVCollectionSectionProtocol> resutleObj = nil;
    
    [self.dataSource enumerateObjectsUsingBlock:^(id<OSSVCollectionSectionProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.sectionType == sectionType) {
                resutleObj = obj;
                *stop = YES;
            }
    }];
    return resutleObj;
}

//评论
- (OSSVReviewsViewModel *)reviewsModel {
    if (!_reviewsModel) {
        _reviewsModel = [[OSSVReviewsViewModel alloc] init];
    }
    return _reviewsModel;
}

-(void)reloadReviewsWithoutReques{

    for (id<OSSVCollectionSectionProtocol>  _Nonnull obj in self.dataSource) {

        if (obj.sectionType == STLGoodsDetailSectionTypeGoodsInfo) {
            self.detailModel.reviewsModel = self.detailsReviewsModel;
            
            OSSVRecommendSectionGoodsInfoModule *goodsInfoModule = (OSSVRecommendSectionGoodsInfoModule*)obj;
            CGFloat contetH = [OSSVDetailInfoCell fetchSizeCellHeight:self.detailModel reviewModel:self.detailsReviewsModel];
            goodsInfoModule.cellSize = CGSizeMake(SCREEN_WIDTH, contetH);
            
        }else if (obj.sectionType == STLGoodsDetailSectionTypeReviewNew) {
            OSSVDetailReviewNewModule *reviewNewModule = (OSSVDetailReviewNewModule*)obj;
            if ( self.detailsReviewsModel.reviewList.count > 0) {
                CGFloat height = [OSSVDetailReviewNewCell contentHeight: self.detailsReviewsModel.reviewList.count];
                reviewNewModule.cellSize = CGSizeMake(SCREEN_WIDTH, height);
            }
            break;
        }
    }
    [self.weakCollectionView reloadData];
}


- (void)requestReveiwData {
    /// 1.4.6 只请求一次
    
    @weakify(self)
    [self.reviewsModel requestOnlyDetailReviewsNetwork:@{@"sku":STLToString(self.detailModel.goodsBaseInfo.goods_sn),
                                                         @"spu":STLToString(self.detailModel.goodsBaseInfo.virtual_spu),
                                                         @"goodsID":STLToString(self.detailModel.goodsBaseInfo.goodsId),
                                                         @"loadState":STLRefresh} completion:^(OSSVReviewsModel *reviewsModel) {
        
        if (reviewsModel && [reviewsModel isKindOfClass:[OSSVReviewsModel class]]) {
            @strongify(self)
            for (OSSVReviewsListModel *listModel in reviewsModel.reviewList) {
                
                CGFloat replayContentHeight = [OSSVDetailReviewCell heightReplayContent:listModel.content];
                CGFloat contentHeight = [OSSVDetailReviewCell fetchReviewCellHeight:listModel];
                listModel.detailReviewReplayHeight = replayContentHeight;
                listModel.detailReviewHeight = contentHeight;
            }
              
            self.detailsReviewsModel = reviewsModel;
            [self.goodsDetailAnalyticsManager reviewHadLoad:@"1" reviewHadData:reviewsModel.reviewList.count > 0 ?  @"1" : @"0"];

            for (id<OSSVCollectionSectionProtocol>  _Nonnull obj in self.dataSource) {

                if (obj.sectionType == STLGoodsDetailSectionTypeGoodsInfo) {
                    self.detailModel.reviewsModel = self.detailsReviewsModel;
                    
                    OSSVRecommendSectionGoodsInfoModule *goodsInfoModule = (OSSVRecommendSectionGoodsInfoModule*)obj;
                    CGFloat contetH = [OSSVDetailInfoCell fetchSizeCellHeight:self.detailModel reviewModel:self.detailsReviewsModel];
                    goodsInfoModule.cellSize = CGSizeMake(SCREEN_WIDTH, contetH);
                    
                }else if (obj.sectionType == STLGoodsDetailSectionTypeReviewNew) {
                    OSSVDetailReviewNewModule *reviewNewModule = (OSSVDetailReviewNewModule*)obj;
                    if (reviewsModel.reviewList.count > 0) {
                        CGFloat height = [OSSVDetailReviewNewCell contentHeight:reviewsModel.reviewList.count];
                        reviewNewModule.cellSize = CGSizeMake(SCREEN_WIDTH, height);
                    }
                    break;
                }
            }
            [self.weakCollectionView reloadData];
            
        } else {
            self.detailsReviewsModel = nil;
            [self.goodsDetailAnalyticsManager reviewHadLoad:@"1" reviewHadData:@"0"];

            for (id<OSSVCollectionSectionProtocol>  _Nonnull obj in self.dataSource) {

                if (obj.sectionType == STLGoodsDetailSectionTypeGoodsInfo) {
                    self.detailModel.reviewsModel = self.detailsReviewsModel;
                    
                    OSSVRecommendSectionGoodsInfoModule *goodsInfoModule = (OSSVRecommendSectionGoodsInfoModule*)obj;
                    CGFloat contetH = [OSSVDetailInfoCell fetchSizeCellHeight:self.detailModel reviewModel:self.detailsReviewsModel];
                    goodsInfoModule.cellSize = CGSizeMake(SCREEN_WIDTH, contetH);
                    
                }else if (obj.sectionType == STLGoodsDetailSectionTypeReviewNew) {
                    OSSVDetailReviewNewModule *reviewNewModule = (OSSVDetailReviewNewModule*)obj;
                    if (reviewsModel.reviewList.count > 0) {
                        CGFloat height = [OSSVDetailReviewNewCell contentHeight:reviewsModel.reviewList.count];
                        reviewNewModule.cellSize = CGSizeMake(SCREEN_WIDTH, height);
                    }
                    break;
                }
            }
            [self.weakCollectionView reloadData];

        }
    } failure:^(id obj) {
        @strongify(self)
        self.detailsReviewsModel = nil;
        [self.goodsDetailAnalyticsManager reviewHadLoad:@"1" reviewHadData:@"0"];

        for (id<OSSVCollectionSectionProtocol>  _Nonnull obj in self.dataSource) {

            if (obj.sectionType == STLGoodsDetailSectionTypeGoodsInfo) {
                self.detailModel.reviewsModel = self.detailsReviewsModel;
                
                OSSVRecommendSectionGoodsInfoModule *goodsInfoModule = (OSSVRecommendSectionGoodsInfoModule*)obj;
                CGFloat contetH = [OSSVDetailInfoCell fetchSizeCellHeight:self.detailModel reviewModel:self.detailsReviewsModel];
                goodsInfoModule.cellSize = CGSizeMake(SCREEN_WIDTH, contetH);
                
            }else if (obj.sectionType == STLGoodsDetailSectionTypeReviewNew) {
                OSSVDetailReviewNewModule *reviewNewModule = (OSSVDetailReviewNewModule*)obj;
                reviewNewModule.cellSize = CGSizeMake(SCREEN_WIDTH, 0);
                break;
            }
        }
        [self.weakCollectionView reloadData];

    }];
}

-(void)setDetailModel:(OSSVDetailsListModel *)detailModel{
    _detailModel = detailModel;
}

-(void)clearRecommendSection{
    OSSVRecommendSectionModule *productSectionModel = self.dataSource.lastObject;
    if (productSectionModel && [productSectionModel isKindOfClass:[OSSVRecommendSectionModule class]]){
        productSectionModel.sectionDataSource = [@[] mutableCopy];
        productSectionModel.contentHeight = EMPTY_RECOMMENT_SECTION_HEIGHT;
        [self.weakCollectLayout reloadSection:1];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    static float bodyH = 0;
    NSLog(@"-----keyPath,change---- %@ %@",keyPath,change);
    if ([keyPath isEqualToString:@"bodyH"]) {
        float newBodyH = [change[NSKeyValueChangeNewKey] floatValue];
        if (newBodyH != bodyH) {
            bodyH = newBodyH;
            //刷新
            [self toggleH5];
        }
    }
}


@end
