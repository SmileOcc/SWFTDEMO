//
//  ZFCommunityPostSameGoodsViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/6/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostSameGoodsViewModel.h"
#import "ZFCommunityGoodsInfosModel.h"
#import "ZFGoodsModel.h"
#import "YWLocalHostManager.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFGrowingIOAnalytics.h"
#import "ExchangeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "Configuration.h"

@interface ZFCommunityPostSameGoodsViewModel ()

@property (nonatomic, strong) NSCache        *sizeCashe;
@property (nonatomic, assign) NSInteger      curPage;// 当前页
@property (nonatomic, assign) NSInteger      totalGoodsCount;// 总数据数
@property (nonatomic, strong) NSMutableArray *currentPageGoodsArray;// 当前页数据



@property (nonatomic, assign) BOOL success;

@end

@implementation ZFCommunityPostSameGoodsViewModel

- (instancetype)init {
    if (self = [super init]) {
        self.goodsInfoArray = [NSMutableArray new];
        self.sizeCashe = [[NSCache alloc] init];
        self.totalGoodsCount = 0;
        self.success = NO;
    }
    return self;
}

/**
 * 请求相似商品标签页
 */
+ (void)requesttagLabelReviewID:(NSString *)reviewID
                         finishedHandle:(void (^)(NSArray *tagDataArray))finishedHandle {

    NSDictionary *parmars = @{@"type": @(9),
                              @"directory": @(66),
                              @"site": @"ZZZZZcommunity",
                              @"app_type": @(2),
                              @"reviewId": ZFToString(reviewID),
                              };
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.url = CommunityAPI;
    requestModel.parmaters = parmars;
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
    
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if (finishedHandle) {
            NSDictionary *dataDict = [responseObject ds_dictionaryForKey:ZFDataKey];
            NSArray *listDictArray = [dataDict ds_arrayForKey:@"catlist"];
            NSArray *tagModelArray = [NSArray yy_modelArrayWithClass:[ZFCommuitySameGoodsCatModel class] json:listDictArray];
            finishedHandle(tagModelArray);
        }
        
    } failure:^(NSError *error) {
        if (finishedHandle) {
            finishedHandle(nil);
        }
    }];
    
    
    NSDictionary *params = @{ @"af_content_type": @"allsimilarpage" };
    [ZFAnalytics appsFlyerTrackEvent:@"af_view_allsimilarpage" withValues:params];
}

/**
 * 请求相似商品标签对应的商品
 */
- (void)requestTheSameGoodsWithReviewID:(NSString *)reviewID
                            isFirstPage:(BOOL)isFirstPage
                                  catId:(NSString *)catId
                         finishedHandle:(void (^)(NSDictionary *pageInfo))finishedHandle {
    
    if (isFirstPage) {
        self.curPage = 1;
    } else{
        self.curPage += 1;
    }
    NSDictionary *parmars = @{@"type": @(9),
                              @"directory": @(64),
                              @"site": @"ZZZZZcommunity",
                              @"app_type": @(2),
                              @"pageSize": @(20),
                              @"curPage": @(self.curPage),
                              @"reviewId": ZFToString(reviewID),
                              @"catId":ZFToString(catId)
                              };
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.url = CommunityAPI;
    requestModel.parmaters = parmars;
    self.success = NO;
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        NSDictionary *dataDict = [responseObject ds_dictionaryForKey:@"data"];
        NSInteger totalPage    = [dataDict ds_integerForKey:@"pageCount"];
        NSArray *listDictArray = [dataDict ds_arrayForKey:@"list"];
        self.totalGoodsCount   = [dataDict ds_integerForKey:@"total"];
        NSInteger code = [responseObject ds_integerForKey:@"code"];
        self.success   = code == 0;
        if (self.curPage == 1) {
            [self.goodsInfoArray removeAllObjects];
            [self.sizeCashe removeAllObjects];
        }
        
        self.currentPageGoodsArray = [NSMutableArray new];
        for (NSDictionary *dict in listDictArray) {
            ZFCommunityGoodsInfosModel *model = [ZFCommunityGoodsInfosModel yy_modelWithJSON:dict];
            [self.goodsInfoArray addObject:model];
            [self.currentPageGoodsArray addObject:[self goodsInfoModelAdapterToGoodsModel:model]];
        }
        
        if (finishedHandle) {
            NSDictionary *pageInfo = @{ kTotalPageKey  : @(totalPage),
                                        kCurrentPageKey: @(self.curPage) };
            finishedHandle(pageInfo);
        }
        
    } failure:^(NSError *error) {
        --self.curPage;
        if (finishedHandle) {
            finishedHandle(nil);
        }
    }];
}

- (BOOL)isRequestSuccess {
    return self.success;
}

- (NSInteger)dataCount {
    return self.goodsInfoArray.count;
}

- (NSInteger)totalCount {
    return self.totalGoodsCount;
}

- (NSString *)goodsTitleWithIndex:(NSInteger)index {
    ZFCommunityGoodsInfosModel *model = [self.goodsInfoArray objectAtIndex:index];
    return model.goodsTitle;
}

- (NSString *)goodsImageWithIndex:(NSInteger)index {
    ZFCommunityGoodsInfosModel *model = [self.goodsInfoArray objectAtIndex:index];
    return model.goodsImg;
}

- (NSString *)goodsPriceWithIndex:(NSInteger)index {
    ZFCommunityGoodsInfosModel *model = [self.goodsInfoArray objectAtIndex:index];
    if ([model.shopPrice length] > 0) {
        return [ExchangeManager transforPrice:model.shopPrice];
    }
    return @"";
}

- (NSString *)goodsIDWithIndex:(NSInteger)index {
    ZFCommunityGoodsInfosModel *model = [self.goodsInfoArray objectAtIndex:index];
    return model.goodsId;
}

- (NSString *)goodsSNWithIndex:(NSInteger)index {
    ZFCommunityGoodsInfosModel *model = [self.goodsInfoArray objectAtIndex:index];
    return model.goods_sn;
}

- (BOOL)isTheSameWithIndex:(NSInteger)index {
    ZFCommunityGoodsInfosModel *model = [self.goodsInfoArray objectAtIndex:index];
    return model.isSame;
}

- (CGSize)cellSizeWithIndex:(NSInteger)index {
    if (index % 2 == 0) {
        NSInteger nextIndex = index + 1;
        CGSize currentSize  = [self dataContentSizeWithIndex:index];
        CGSize nextSize     = [self dataContentSizeWithIndex:nextIndex];
        return nextSize.height > currentSize.height ? nextSize : currentSize;
    } else {
        NSInteger preIndex  = index - 1;
        CGSize currentSize  = [self dataContentSizeWithIndex:index];
        CGSize preSize      = [self dataContentSizeWithIndex:preIndex];
        return preSize.height > currentSize.height ? preSize : currentSize;
    }
    return CGSizeZero;
}

- (CGSize)dataContentSizeWithIndex:(NSInteger)index {
    if (index < 0
        || index > self.goodsInfoArray.count - 1) {
        return CGSizeZero;
    }
    
    NSString *key = [NSString stringWithFormat:@"%ld", index];
    if ([self.sizeCashe objectForKey:key]) {
        NSString *sizeString = [self.sizeCashe objectForKey:key];
        return CGSizeFromString(sizeString);
    } else {
        ZFCommunityGoodsInfosModel *model = [self.goodsInfoArray objectAtIndex:index];
        // 图片宽高
        CGFloat width    = (KScreenWidth - 12 * 3) / 2;
        CGFloat height   = width * 227.0 / 170.0;
        
        height += 12.0;    // 间隙
        CGSize titleSize = [model.goodsTitle boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]} context:nil].size;
        height += titleSize.height;
        
        // 价格
        height += 8.0;
        height += 14.0;
        
        if (model.isSame) {
            height += 8.0;   // 间隙
            height += 16.0;  // 标签高度
        }
        
        height += 24.0;
        CGSize size = CGSizeMake(width, height);
        [self.sizeCashe setObject:NSStringFromCGSize(size) forKey:key];
        return size;
    }
}

#pragma mark - 统计
- (void)showAnalysicsWithCateName:(NSString *)cateName {

    NSString *impressList = [NSString stringWithFormat:@"%@_%@",ZFGASimalarGoodsList, cateName];
    NSString *screenName = [NSString stringWithFormat:@"simalar_goods_%@", cateName];
    [ZFAnalytics showProductsWithProducts:self.currentPageGoodsArray position:1 impressionList:impressList screenName:screenName event:nil];
    
    //occ v3.7.0hacker 添加 ok
    self.analyticsProduceImpression = [ZFAnalyticsProduceImpression initAnalyticsProducePosition:1
                                                                                  impressionList:impressList
                                                                                      screenName:screenName
                                                                                           event:nil];

    [self.currentPageGoodsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ZFGoodsModel class]]) {
            [ZFGrowingIOAnalytics ZFGrowingIOProductShow:obj page:@"SameGoodsList"];
        }
    }];
}

- (void)clickAnalysicsWithCateName:(NSString *)cateName index:(NSInteger)index {
    ZFCommunityGoodsInfosModel *infoModel = self.goodsInfoArray[index];
    [ZFAnalytics clickProductWithProduct:[self goodsInfoModelAdapterToGoodsModel:infoModel] position:1 actionList:[NSString stringWithFormat:@"%@_%@",ZFGASimalarGoodsList, cateName]];
    [ZFGrowingIOAnalytics ZFGrowingIOProductClick:[self goodsInfoModelAdapterToGoodsModel:infoModel] page:@"SameGoodsList" sourceParams:nil];
}

- (ZFGoodsModel *)goodsInfoModelAdapterToGoodsModel:(ZFCommunityGoodsInfosModel *)infoModel {
    ZFGoodsModel *goodsModel = [ZFGoodsModel new];
    goodsModel.goods_id      = infoModel.goodsId;
    goodsModel.goods_sn      = infoModel.goods_sn;
    goodsModel.goods_title   = infoModel.goodsTitle;
    return goodsModel;
}

@end
