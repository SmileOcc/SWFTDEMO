//
//  ZFSearchMapResultAnalytics.m
//  ZZZZZ
//
//  Created by YW on 2018/10/8.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFSearchMapResultAnalyticsAOP.h"
#import "ZFSearchMapResultViewController.h"
#import <Growing/Growing.h>
#import "ZFGoodsModel.h"
#import "ZFGoodsListItemCell.h"
#import "ZFHomeGoodsCell.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "ZFBranchAnalytics.h"

@interface ZFSearchMapResultAnalyticsAOP ()

@property (nonatomic, strong) NSMutableArray *analyticsSet;
@property (nonatomic, strong) NSArray *dataList;

///GA 统计的key
@property (nonatomic, copy) NSString *GAImpressionKey;
@property (nonatomic, copy) NSString *GAScreenName;

//老的搜索字段,用于区分新传入的搜索字段,Appflyers统计判重
@property (nonatomic, copy) NSString *oldSearchKey;

@property (nonatomic, copy) NSString *gioSearchType;

@end

@implementation ZFSearchMapResultAnalyticsAOP

-(void)dealloc
{
    YWLog(@"ZFSearchMapResultAnalytics dealloc");
}

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.analyticsSet = [[NSMutableArray alloc] init];
        self.GAImpressionKey = ZFGASearchResultList;
        self.GAScreenName = @"搜索结果列表";
        self.oldSearchKey = @"unknow";
        self.gioSearchType = @"direct_search";
    }
    return self;
}

//public aop method
-(void)after_viewDidLoad
{
    //设置自定义统计key
    NSString *searchKey = [self gainSearchKey];
    [Growing setEvarWithKey:GIOSearchWord_evar andStringValue:ZFgrowingToString(searchKey)];
    if ([NSStringFromClass(self.datasource.class) isEqualToString:@"SearchResultViewController"]) {
        [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"SearchResult_KeyWords_%@", searchKey] itemName:searchKey ContentType:@"SearchKeyWords" itemCategory:@"Goods"];
    }else{
        [Growing setEvarWithKey:GIOsourceRecent_evar andStringValue:@"搜索"];
        [Growing setEvarWithKey:GIOsourceFirst_evar andStringValue:@"搜索"];
    }
}

//SearchResultViewController aop method
-(void)after_loadHead
{
    ///增加GrowingIO搜索转化变量
    [Growing setEvarWithKey:GIOsourceRecent_evar andStringValue:@"搜索"];
    [Growing setEvarWithKey:GIOsourceFirst_evar andStringValue:@"搜索"];
}

//在外部设置总数的时候，统计一下搜索的数据
-(void)setTotalCount:(NSInteger)totalCount
{
    _totalCount = totalCount;
    
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    if (_totalCount <= 0) {
        _totalCount = 0;
    }
    valuesDic[@"af_search_number"] = @(_totalCount);
    valuesDic[@"af_first_entrance"] = @"search";
    if ([NSStringFromClass(self.datasource.class) isEqualToString:@"SearchResultViewController"]) {
        //设置自定义统计key
        NSString *searchKey = [self gainSearchKey];
        if (![searchKey isEqualToString:self.oldSearchKey]) {
            //是文字搜索的时候,用户执行搜索操作统计
            NSString *searchPage = @"direct_search";
            switch (self.sourceType) {
                case ZFAppsflyerInSourceTypeSearchDirect:
                    searchPage = @"direct_search";
                    break;
                case ZFAppsflyerInSourceTypeSearchDeeplink:
                    searchPage = @"deeplink_search";
                    break;
                case ZFAppsflyerInSourceTypeSearchFix:
                    searchPage = @"fix_search";
                    break;
                case ZFAppsflyerInSourceTypeSearchAssociation:
                    searchPage = @"association_search";
                    break;
                case ZFAppsflyerInSourceTypeSearchHistory:
                    searchPage = @"history_search";
                    break;
                case ZFAppsflyerInSourceTypeSearchRecommend:
                    searchPage = @"recommend_search";
                    break;
                default:
                    break;
            }
            self.gioSearchType = [NSString stringWithFormat:@"%@_%@", searchPage, ZFToString(searchKey)];
            valuesDic[AFEventParamContentType] = ZFToString(searchKey);
            valuesDic[@"af_search_page"] = searchPage;
            
            [ZFAnalytics appsFlyerTrackEvent:@"af_search" withValues:valuesDic];
            // Branch
            [[ZFBranchAnalytics sharedManager] branchSearchEvenWithSearchKey:searchKey searchType:@"normal_search"];
            [ZFFireBaseAnalytics searchResultWithTerm:searchKey];
            [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOFistEvar : GIOSourceSearch,
                                                       GIOGoodsTypeEvar : GIOGoodsTypeSearch,
                                                       GIOGoodsNameEvar : [NSString stringWithFormat:@"%@_%@", searchPage, ZFToString(searchKey)]
            }];
        }
        self.oldSearchKey = searchKey;
    }
    
    if ([NSStringFromClass(self.datasource.class) isEqualToString:@"ZFSearchMapResultViewController"]) {
        valuesDic[AFEventParamContentType] = @"no keyword";
        valuesDic[@"af_search_page"] = @"pic_search";
        [ZFAnalytics appsFlyerTrackEvent:@"af_search" withValues:valuesDic];
        // Branch
        [[ZFBranchAnalytics sharedManager] branchSearchEvenWithSearchKey:@"" searchType:@"pic_search"];
        [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOFistEvar : GIOSourceSearch,
                                                   GIOGoodsTypeEvar : GIOGoodsTypeSearch,
                                                   GIOGoodsNameEvar : @"direct_search_pic"}];
    }
}

//public aop method
-(void)after_collectionView:(UICollectionView *)collectionView
     cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.datasource) return;
    self.dataList = [self.datasource ZFSearchMapResultAnalyticsDataList];
    
    //设置自定义统计key
    NSString *searchKey = [self gainSearchKey];
    if ([NSStringFromClass(_datasource.class) isEqualToString:@"SearchResultViewController"]) {
        self.GAImpressionKey = [NSString stringWithFormat:@"%@_%@", ZFGASearchKeyList, ZFToString(searchKey)];
        self.GAScreenName = @"搜索结果列表";
    }
    
    if ([NSStringFromClass(_datasource.class) isEqualToString:@"ZFSearchMapResultViewController"]) {
        self.GAImpressionKey = ZFGASearchResultList;
        self.GAScreenName = @"以图搜图结果列表";
    }
  
    ZFGoodsModel *model = self.dataList[indexPath.row];
    if ([self.analyticsSet containsObject:model.goods_id]) {
        return;
    }
    if ([model isKindOfClass:[ZFGoodsModel class]]) {
        NSString *skuSN = nil;
        if (model.goods_sn.length > 7) {
            skuSN = [model.goods_sn substringWithRange:NSMakeRange(0, 7)];
        }else{
            skuSN = model.goods_sn;
        }
        NSDictionary *params = @{@"goodsName_var" : model.goods_title,  //商品名称
                                 @"SKU_var" : model.goods_sn,           //SKU id
                                 @"SN_var" : skuSN,                     //SN（取SKU前7位，即为产品SN）
                                 @"firstCat_var" : ZFgrowingToString(model.cat_level_column[@"first_cat_name"]),       //一级分类
                                 @"sndCat_var" : ZFgrowingToString(model.cat_level_column[@"snd_cat_name"]),           //二级分类
                                 @"thirdCat_var" : ZFgrowingToString(model.cat_level_column[@"third_cat_name"]),       //三级分类
                                 @"forthCat_var" : ZFgrowingToString(model.cat_level_column[@"forth_cat_name"]),       //四级分类
                                 @"marketType_var" : ZFgrowingToString(model.channel_type),        //营销类型
                                 @"goodsPage_var" : self.page,            //商品所属页面
                                 @"searchWord_var" : searchKey,
                                 @"searchType_var" : self.searchType,
                                 @"searchResAmount_var" : [NSString stringWithFormat:@"%ld", self.totalCount]
                                 };
        [Growing track:@"searchResultView" withVariable:params];
        [self.analyticsSet addObject:model.goods_id];
        
        [ZFAnalytics showProductsWithProducts:@[model]
                                     position:(int)indexPath.row
                               impressionList:self.GAImpressionKey
                                   screenName:self.GAScreenName
                                        event:@"load"];
        
        model.af_rank = indexPath.row + 1;
        [ZFAppsflyerAnalytics trackGoodsList:@[model] inSourceType:self.sourceType sourceID:[self gainSearchKey] sort:self.sort aFparams:nil];
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:model page:GIOSourceSearch];
    }
}

//public aop method
-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    //设置自定义统计key
    NSString *searchKey = [self gainSearchKey];
    ZFGoodsModel *model = nil;
    if ([cell isKindOfClass:[ZFGoodsListItemCell class]]) {
        ZFGoodsListItemCell *itemCell = (ZFGoodsListItemCell *)cell;
        model = itemCell.selectedGoodsModel;
        if (!model) {
            model = itemCell.goodsModel;
        } else {
            model.cat_level_column = itemCell.goodsModel.cat_level_column;
            model.channel_type = itemCell.goodsModel.channel_type;
            model.goods_number = itemCell.goodsModel.goods_number;
        }
    }
    if ([cell isKindOfClass:[ZFHomeGoodsCell class]]) {
        ZFHomeGoodsCell *goodsCell = (ZFHomeGoodsCell *)cell;
        model = goodsCell.goodsModel;
    }
    if ([model isKindOfClass:[ZFGoodsModel class]]) {
        NSString *skuSN = nil;
        if (model.goods_sn.length > 7) {
            skuSN = [model.goods_sn substringWithRange:NSMakeRange(0, 7)];
        }else{
            skuSN = model.goods_sn;
        }
        NSDictionary *params = @{@"goodsName_var" : model.goods_title,  //商品名称
                                 @"SKU_var" : model.goods_sn,           //SKU id
                                 @"SN_var" : skuSN,                     //SN（取SKU前7位，即为产品SN）
                                 @"firstCat_var" : ZFgrowingToString(model.cat_level_column[@"first_cat_name"]),       //一级分类
                                 @"sndCat_var" : ZFgrowingToString(model.cat_level_column[@"snd_cat_name"]),           //二级分类
                                 @"thirdCat_var" : ZFgrowingToString(model.cat_level_column[@"third_cat_name"]),       //三级分类
                                 @"forthCat_var" : ZFgrowingToString(model.cat_level_column[@"forth_cat_name"]),       //四级分类
                                 @"marketType_var" : ZFgrowingToString(model.channel_type),        //营销类型
                                 @"goodsPage_var" : self.page,            //商品所属页面
                                 @"searchWord_var" : searchKey,
                                 @"searchType_var" : self.searchType,
                                 @"storageNum_var" : ZFgrowingToString(model.goods_number)
                                 };
        [Growing track:@"searchResultClick" withVariable:params];

        //GA 统计
        [ZFAnalytics clickProductWithProduct:model
                                    position:(int)indexPath.row
                                  actionList:self.GAImpressionKey];

        // fireBase 统计
        [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Click_SearchResult_Goods_%@", model.goods_sn]
                                            itemName:model.goods_title
                                         ContentType:@"Goods"
                                        itemCategory:@"SearchResult_Goods"];
        
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(model.goods_sn),
                                          @"af_spu_id" : ZFToString(model.goods_spu),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : ZFToString(self.searchType),    // 当前页面名称search_result
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
        
        [ZFGrowingIOAnalytics ZFGrowingIOProductClick:model page:GIOSourceSearch sourceParams:@{
            GIOGoodsTypeEvar : GIOGoodsTypeSearch,
            GIOGoodsNameEvar : ZFToString(self.gioSearchType)
        }];
    }
}

- (NSString *)gainSearchKey
{
    NSString *searchKey = @"";
    if (self.datasource && [self.datasource respondsToSelector:@selector(ZFSearchMapResultAnalyticsSearchKey)]) {
        searchKey = [self.datasource ZFSearchMapResultAnalyticsSearchKey];
    }
    return searchKey;
}

-(NSDictionary *)injectMenthodParams
{
    NSMutableDictionary *params = [@{
                                     NSStringFromSelector(@selector(collectionView:cellForItemAtIndexPath:)) : NSStringFromSelector(@selector(after_collectionView:cellForItemAtIndexPath:)),
                                     NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                                         NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                                     NSStringFromSelector(@selector(viewDidLoad)) :
                                         NSStringFromSelector(@selector(after_viewDidLoad)),
                                     }
                                   mutableCopy];
    
    if ([NSStringFromClass(self.datasource.class) isEqualToString:@"SearchResultViewController"]) {
        [params setObject:NSStringFromSelector(@selector(after_loadHead)) forKey:@"loadHead"];
    }
    
    return [params copy];
}

@end
