//
//  ZFGrowingIOAnalytics.m
//  ZZZZZ
//
//  Created by YW on 2018/8/24.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "Configuration.h"
#import "AccountManager.h"
#import "NSStringUtils.h"

@implementation ZFGrowingIOAnalytics

+ (void)ZFGrowingIOTrack:(NSString *)eventId withVariable:(NSDictionary<NSString *, id> *)variable {
    [Growing track:ZFToString(eventId) withVariable:variable];
}

+ (void)ZFGrowingIOSetEvar:(NSDictionary<NSString *,NSObject *> *)dict {
    [Growing setEvar:dict];
}

#pragma mark - 活动展示统计
+ (void)ZFGrowingIOBannerImpWithCMSItemModel:(ZFCMSItemModel *)cmsModel
                                        page:(NSString *)page {
    [self ZFGrowingIOBannerImpWithCMSItemModel:cmsModel page:page channelID:page floorVar:nil];
}

+ (void)ZFGrowingIOBannerImpWithCMSItemModel:(ZFCMSItemModel *)cmsModel
                                        page:(NSString *)page
                                   channelID:(NSString *)channelID
                                    floorVar:(NSString *)floorVar {
    NSDictionary *params = @{
        @"bannerId_var" : ZFToString(cmsModel.ad_id),
        @"activityName_var" : ZFToString(cmsModel.name),
        @"goodsPage_var" : ZFToString(page),
        @"goodsPageId_var" : ZFToString(channelID),
        @"floor_var" : ZFToString(floorVar),
        @"channel_name_var" : ZFToString(channelID),                    //CMS菜单id
        @"component_id_var" : ZFToString(cmsModel.component_id),         //CMS组件id
        @"col_id_var" : ZFToString(cmsModel.col_id),                       //CMS坑位id
        @"ad_id_var" : ZFToString(cmsModel.ad_id),                 //CMSbanner id
        @"banner_name_var" : ZFToString(cmsModel.name), //CMSbanner名称
    };
    [self ZFGrowingIOTrack:@"activityImp" withVariable:params];
}

+ (void)ZFGrowingIOBannerImpWithBannerModel:(ZFBannerModel *)bannerModel
                                       page:(NSString *)page {
    [self ZFGrowingIOBannerImpWithBannerModel:bannerModel page:page channelID:page floorVar:nil];
}

+ (void)ZFGrowingIOBannerImpWithBannerModel:(ZFBannerModel *)bannerModel
                                       page:(NSString *)page
                                  channelID:(NSString *)channelID
                                   floorVar:(NSString *)floorVar {
    NSDictionary *params = @{
        @"bannerId_var" : ZFToString(bannerModel.banner_id),
        @"activityName_var" : ZFToString(bannerModel.name),
        @"goodsPage_var" : ZFToString(page),
        @"goodsPageId_var" : ZFToString(channelID),
        @"floor_var" : ZFToString(floorVar),
        @"channel_name_var" : ZFToString(bannerModel.menuid),                    //CMS菜单id
        @"component_id_var" : ZFToString(bannerModel.componentId),         //CMS组件id
        @"col_id_var" : ZFToString(bannerModel.colid),                       //CMS坑位id
        @"ad_id_var" : ZFToString(bannerModel.banner_id),                 //CMSbanner
        @"banner_name_var" : ZFToString(bannerModel.name), //CMSbanner名称
    };
    [self ZFGrowingIOTrack:@"activityImp" withVariable:params];
}

/// 原生专题轮播banner
+ (void)ZFGrowingIOBannerImpWithThemeSectionListModel:(ZFGeshopSectionListModel *)model
                              nativeThemeSectionModel:(ZFGeshopSectionModel *)nativeThemeSectionModel
                                             pageName:(NSString *)pageName
                                        nativeThemeId:(NSString *)nativeThemeId {
    NSDictionary *params = @{
        @"bannerId_var" : ZFToString(model.ad_id),
        @"activityName_var" : ZFToString(model.ad_name),
        @"goodsPage_var" : ZFToString(pageName),
        @"goodsPageId_var" : ZFToString(nativeThemeId),
        @"floor_var" : ZFToString(model.floor_id),
        @"positionId_var" : ZFToString(nativeThemeSectionModel.component_id),                    //CMS菜单id
        @"positionName_var" : ZFToString(nativeThemeSectionModel.component_name),         //CMS组件id
        @"position_var" : @(nativeThemeSectionModel.component_type)
    };
    [self ZFGrowingIOTrack:@"activityImpH5" withVariable:params];
}

/// 原生专题文本banner
+ (void)ZFGrowingIOBannerImpWithnativeThemeSectionModel:(ZFGeshopSectionModel *)nativeThemeSectionModel
                                               pageName:(NSString *)pageName
                                          nativeThemeId:(NSString *)nativeThemeId {
    NSDictionary *params = @{
        @"bannerId_var" : ZFToString(nativeThemeSectionModel.component_data.ad_id),
        @"activityName_var" : ZFToString(nativeThemeSectionModel.component_data.ad_name),
        @"goodsPage_var" : ZFToString(pageName),
        @"goodsPageId_var" : ZFToString(nativeThemeId),
        @"floor_var" : ZFToString(nativeThemeSectionModel.component_data.floor_id),
        @"positionId_var" : ZFToString(nativeThemeSectionModel.component_id),                    //CMS菜单id
        @"positionName_var" : ZFToString(nativeThemeSectionModel.component_name),         //CMS组件id
        @"position_var" : @(nativeThemeSectionModel.component_type)
    };
    [self ZFGrowingIOTrack:@"activityImpH5" withVariable:params];
}

#pragma mark - 活动点击统计
+ (void)ZFGrowingIObannerClickWithCMSItemModel:(ZFCMSItemModel *)cmsModel
                                          page:(NSString *)page
                                  sourceParams:(NSDictionary<NSString *,NSObject *> *)sourceParams {
    [self ZFGrowingIObannerClickWithCMSItemModel:cmsModel page:page channelID:page floorVar:nil sourceParams:sourceParams];
}

+ (void)ZFGrowingIObannerClickWithCMSItemModel:(ZFCMSItemModel *)cmsModel
                                          page:(NSString *)page
                                     channelID:(NSString *)channelID
                                      floorVar:(NSString *)floorVar
                                  sourceParams:(NSDictionary<NSString *,NSObject *> *)sourceParams {
    NSDictionary *params = @{
        @"bannerId_var" : ZFToString(cmsModel.ad_id),
        @"activityName_var" : ZFToString(cmsModel.name),
        @"goodsPage_var" : ZFToString(page),
        @"goodsPageId_var" : ZFToString(channelID),
        @"floor_var" : ZFToString(floorVar),
        @"channel_name_var" : ZFToString(channelID),                    //CMS菜单id
        @"component_id_var" : ZFToString(cmsModel.component_id),         //CMS组件id
        @"col_id_var" : ZFToString(cmsModel.col_id),                       //CMS坑位id
        @"ad_id_var" : ZFToString(cmsModel.ad_id),                 //CMSbanner id
        @"banner_name_var" : ZFToString(cmsModel.name), //CMSbanner名称
    };
    [self ZFGrowingIOTrack:@"activityClick" withVariable:params];
    if ([sourceParams isKindOfClass:[NSDictionary class]] && sourceParams.count > 0) {
        [self ZFGrowingIOSetEvar:sourceParams];
    }
}

+ (void)ZFGrowingIObannerClickWithBannerModel:(ZFBannerModel *)bannerModel
                                         page:(NSString *)page
                                 sourceParams:(NSDictionary<NSString *,NSObject *> *)sourceParams {
    [self ZFGrowingIObannerClickWithBannerModel:bannerModel page:page channelID:page floorVar:nil sourceParams:sourceParams];
}

+ (void)ZFGrowingIObannerClickWithBannerModel:(ZFBannerModel *)bannerModel
                                         page:(NSString *)page
                                    channelID:(NSString *)channelID
                                     floorVar:(NSString *)floorVar
                                 sourceParams:(NSDictionary<NSString *,NSObject *> *)sourceParams {
    NSDictionary *params = @{
        @"bannerId_var" : ZFToString(bannerModel.banner_id),
        @"activityName_var" : ZFToString(bannerModel.name),
        @"goodsPage_var" : ZFToString(page),
        @"goodsPageId_var" : ZFToString(channelID),
        @"floor_var" : ZFToString(floorVar)
    };
    [self ZFGrowingIOTrack:@"activityClick" withVariable:params];
    if ([sourceParams isKindOfClass:[NSDictionary class]] && sourceParams.count > 0) {
        [self ZFGrowingIOSetEvar:sourceParams];
    }
}

+ (void)ZFGrowingIOBannerClickWithThemeSectionListModel:(ZFGeshopSectionListModel *)model
                                nativeThemeSectionModel:(ZFGeshopSectionModel *)nativeThemeSectionModel
                                               pageName:(NSString *)pageName
                                          nativeThemeId:(NSString *)nativeThemeId {
    NSDictionary *params = @{
        @"bannerId_var" : ZFToString(model.ad_id),
        @"activityName_var" : ZFToString(model.ad_name),
        @"goodsPage_var" : ZFToString(pageName),
        @"goodsPageId_var" : ZFToString(nativeThemeId),
        @"floor_var" : ZFToString(model.floor_id),
        @"positionId_var" : ZFToString(nativeThemeSectionModel.component_id),                    //CMS菜单id
        @"positionName_var" : ZFToString(nativeThemeSectionModel.component_name),         //CMS组件id
        @"position_var" : @(nativeThemeSectionModel.component_type)
    };
    [self ZFGrowingIOTrack:@"activityClickH5" withVariable:params];
}

/// 原生专题文本banner
+ (void)ZFGrowingIOBannerClickWithnativeThemeSectionModel:(ZFGeshopSectionModel *)nativeThemeSectionModel
                                                 pageName:(NSString *)pageName
                                            nativeThemeId:(NSString *)nativeThemeId {
    NSDictionary *params = @{
        @"bannerId_var" : ZFToString(nativeThemeSectionModel.component_data.ad_id),
        @"activityName_var" : ZFToString(nativeThemeSectionModel.component_data.ad_name),
        @"goodsPage_var" : ZFToString(pageName),
        @"goodsPageId_var" : ZFToString(nativeThemeId),
        @"floor_var" : ZFToString(nativeThemeSectionModel.component_data.floor_id),
        @"positionId_var" : ZFToString(nativeThemeSectionModel.component_id),                    //CMS菜单id
        @"positionName_var" : ZFToString(nativeThemeSectionModel.component_name),         //CMS组件id
        @"position_var" : @(nativeThemeSectionModel.component_type)
    };
    [self ZFGrowingIOTrack:@"activityClickH5" withVariable:params];
}



//+(void)ZFGrowingIOActivityImp:(NSString *)activityName floor:(NSString *)floor position:(NSString *)position page:(NSString *)page
//{
//    NSDictionary *params = @{
//                             @"goodsPage_var" : ZFgrowingToString(page),                    //所属页面
//                             @"activityName_var" : ZFgrowingToString(activityName),         //活动名称
//                             @"floor_var" : ZFgrowingToString(floor),                       //流量位所在楼层位置
//                             @"position_var" : ZFgrowingToString(position),                 //流量位所在坑位位置
//                             };
//    [Growing track:@"activityImp" withVariable:params];
//}
//
/////CMS Banner活动曝光 key = activityImp
//+(void)ZFGrowingIOActivityImpByCMS:(ZFCMSItemModel *)cmsModel channelId:(NSString *)channelId
//{
//    NSDictionary *params = @{
//                             @"channel_name_var" : ZFgrowingToString(channelId),                    //CMS菜单id
//                             @"component_id_var" : ZFgrowingToString(cmsModel.component_id),         //CMS组件id
//                             @"col_id_var" : ZFgrowingToString(cmsModel.col_id),                       //CMS坑位id
//                             @"ad_id_var" : ZFgrowingToString(cmsModel.ad_id),                 //CMSbanner id
//                             @"banner_name_var" : ZFgrowingToString(cmsModel.name), //CMSbanner名称
//                             };
//    [Growing track:@"activityImp" withVariable:params];
//}
//
/////CMS Banner活动曝光 ZFBannerModel
//+(void)ZFGrowingIOActivityImpByCMS:(ZFBannerModel *)cmsModel
//{
//    NSDictionary *params = @{
//                             @"channel_name_var" : ZFgrowingToString(cmsModel.menuid),                    //CMS菜单id
//                             @"component_id_var" : ZFgrowingToString(cmsModel.componentId),         //CMS组件id
//                             @"col_id_var" : ZFgrowingToString(cmsModel.colid),                       //CMS坑位id
//                             @"ad_id_var" : ZFgrowingToString(cmsModel.banner_id),                 //CMSbanner
//                             @"banner_name_var" : ZFgrowingToString(cmsModel.name), //CMSbanner名称
//                             };
//    [Growing track:@"activityImp" withVariable:params];
//}
//
/////Banner活动点击 key = activityClick
//+(void)ZFGrowingIOActivityClick:(NSString *)activityName floor:(NSString *)floor position:(NSString *)position page:(NSString *)page
//{
//    NSDictionary *params = @{
//                             @"goodsPage_var" : ZFgrowingToString(page),                    //所属页面
//                             @"activityName_var" : ZFgrowingToString(activityName),         //活动名称
//                             @"floor_var" : ZFgrowingToString(floor),                       //流量位所在楼层位置
//                             @"position_var" : ZFgrowingToString(position),                 //流量位所在坑位位置
//                             };
//    [Growing track:@"activityClick" withVariable:params];
//
//    [self ZFGrowingIOActivityClick:floor position:position];
//}
//
//+(void)ZFGrowingIOActivityClickByCMS:(ZFCMSItemModel *)cmsModel channelId:(NSString *)channelId
//{
//    NSDictionary *params = @{
//                             @"channel_name_var" : ZFgrowingToString(channelId),                    //CMS菜单id
//                             @"component_id_var" : ZFgrowingToString(cmsModel.component_id),         //CMS组件id
//                             @"col_id_var" : ZFgrowingToString(cmsModel.col_id),                       //CMS坑位id
//                             @"ad_id_var" : ZFgrowingToString(cmsModel.ad_id),                 //CMSbanner id
//                             @"banner_name_var" : ZFgrowingToString(cmsModel.name), //CMSbanner名称
//                             };
//    [Growing track:@"activityClick" withVariable:params];
//    [Growing setEvar:params];
//}
//
//+(void)ZFGrowingIOActivityClickByCMS:(ZFBannerModel *)cmsModel
//{
//    NSDictionary *params = @{
//                             @"channel_name_var" : ZFgrowingToString(cmsModel.menuid),                    //CMS菜单id
//                             @"component_id_var" : ZFgrowingToString(cmsModel.componentId),         //CMS组件id
//                             @"col_id_var" : ZFgrowingToString(cmsModel.colid),                       //CMS坑位id
//                             @"ad_id_var" : ZFgrowingToString(cmsModel.banner_id),                 //CMSbanner
//                             @"banner_name_var" : ZFgrowingToString(cmsModel.name), //CMSbanner名称
//                             };
//    [Growing track:@"activityClick" withVariable:params];
//    [Growing setEvar:params];
//}

/**
 *  商品活动点击 转化变量
 *  floor impression_channel_banner_branch 楼层 position 0,1,2
 */
+(void)ZFGrowingIOActivityClick:(NSString *)floor position:(NSString *)position
{
    [Growing setEvar:@{@"floor_evar" : floor}];
    
    [Growing setEvar:@{@"position_evar" : position,
                       @"floor_evar" : floor}];
}

/**
 *  社区活动点击 转化变量
 *  floor impression_channel_banner_branch 楼层 position 0,1,2
 */
+(void)ZFGrowingIOCommunityActivityClick
{
    [Growing setEvarWithKey:GIOsourceRecent_evar andStringValue:@"社区"];
    [Growing setEvarWithKey:GIOsourceFirst_evar andStringValue:@"社区"];
    [Growing setEvarWithKey:GIOUserType_evar andStringValue:ZFgrowingToString([AccountManager sharedManager].account.user_id)];
}


#pragma mark - 商品展示统计

+(void)ZFGrowingIOProductShow:(ZFGoodsModel *)model page:(NSString *)page
{
    [self ZFGrowingIOProductAnalytice:@"goodsImp" model:model page:page sourceParams:nil];
}

///商品点击的收集 key = goodsClick
+(void)ZFGrowingIOProductClick:(ZFGoodsModel *)model page:(NSString *)page sourceParams:(NSDictionary<NSString *,NSObject *> *)sourceParams
{
    [self ZFGrowingIOProductAnalytice:@"goodsClick" model:model page:page sourceParams:sourceParams];
}

+(void)ZFGrowingIOProductAnalytice:(NSString *)event model:(ZFGoodsModel *)model page:(NSString *)page sourceParams:(NSDictionary<NSString *,NSObject *> *)sourceParams
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *skuSN = nil;
        if (model.goods_sn.length > 7) {
            skuSN = [model.goods_sn substringWithRange:NSMakeRange(0, 7)];
        }else{
            skuSN = model.goods_sn;
        }
    
        //商品推荐位的类型，取值包括We Recommend、Your Recent history、Customers also viewed；若没有则上传“无”
        //帖子详情页中的推荐商品所属的帖子类型，取值包括shows、outfits、videos；若没有则上传“无”
        NSDictionary *params = @{@"goodsName_var" : ZFgrowingToString(model.goods_title),  //商品名称
                                 @"SKU_var" : ZFgrowingToString(model.goods_sn),           //SKU id
                                 @"SN_var" : ZFgrowingToString(skuSN),                     //SN（取SKU前7位，即为产品SN）
                                 @"firstCat_var" : ZFgrowingToString(model.cat_level_column[@"first_cat_name"]),       //一级分类
                                 @"sndCat_var" : ZFgrowingToString(model.cat_level_column[@"snd_cat_name"]),           //二级分类
                                 @"thirdCat_var" : ZFgrowingToString(model.cat_level_column[@"third_cat_name"]),       //三级分类
                                 @"forthCat_var" : ZFgrowingToString(model.cat_level_column[@"forth_cat_name"]),       //四级分类
                                 @"storageNum_var" : ZFgrowingToString(model.goods_number),        //库存数量
                                 @"marketType_var" : ZFgrowingToString(model.channel_type),        //营销类型
                                 @"goodsPage_var" : ZFgrowingToString(page),            //商品所属页面
                                 @"recommendType_var" : ZFgrowingToString(model.recommentType),         //推荐位类型
                                 @"postType_var" : ZFgrowingToString(model.postType),              //帖子类型
                                 };
    [self ZFGrowingIOTrack:event withVariable:params];
    if ([event isEqualToString:@"goodsClick"] && sourceParams.count > 0) {
        [self ZFGrowingIOSetEvar:sourceParams];
        
        ///商品点击的时候，并且是推荐位商品时，增加一级购买 推荐位
//        if (ZFToString(model.recommentType).length) {
//            [Growing setEvarWithKey:GIOsourceRecent_evar andStringValue:@"推荐位"];
//            [Growing setEvarWithKey:GIOsourceFirst_evar andStringValue:@"推荐位"];
//            [Growing setEvarWithKey:GIORecommendType_evar andStringValue:ZFgrowingToString(model.recommentType)];
//            [Growing setEvarWithKey:GIORecommendPage_evar andStringValue:ZFgrowingToString(page)];
//        }
//        if (ZFToString(model.postType).length) {
//            [Growing setEvarWithKey:GIOsourceRecent_evar andStringValue:@"社区"];
//            [Growing setEvarWithKey:GIOsourceFirst_evar andStringValue:@"社区"];
//        }
    }
//    });
}

#pragma mark - 商品详情浏览 key = goodsDetailPageView

+(void)ZFGrowingIOProductDetailShow:(GoodsDetailModel *)model
{
    NSString *skuSN = nil;
    if (model.goods_sn.length > 7) {
        skuSN = [model.goods_sn substringWithRange:NSMakeRange(0, 7)];
    }else{
        skuSN = model.goods_sn;
    }
    __block NSString *marketType = @"";
    
    GoodsReductionModel *reductionModel = model.reductionModel;
    
    NSArray *titleArray = [reductionModel.msg componentsSeparatedByString:@"||"];
    if ([titleArray count]) {
        [titleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *string = obj;
            NSRegularExpression *regularExpretion = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>|\n|&nbsp"
                                                                                            options:0
                                                                                              error:nil];
            string = [regularExpretion stringByReplacingMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length) withTemplate:@""];
            if (idx == 0) {
                marketType = [marketType stringByAppendingFormat:@"%@", string];
            }else{
                marketType = [marketType stringByAppendingFormat:@" | %@", string];
            }
        }];
    }

    NSDictionary *params = @{
                             @"goodsName_var" : ZFgrowingToString(model.goods_name),   //商品名称
                             @"SKU_var" : ZFgrowingToString(model.goods_sn),           //SKU id
                             @"SN_var" : ZFgrowingToString(skuSN),                     //SN（取SKU前7位，即为产品SN）
                             @"firstCat_var" : ZFgrowingToString(model.cat_level_column[@"first_cat_name"]),   //一级分类
                             @"sndCat_var" : ZFgrowingToString(model.cat_level_column[@"snd_cat_name"]),       //二级分类
                             @"thirdCat_var" : ZFgrowingToString(model.cat_level_column[@"third_cat_name"]),   //三级分类
                             @"forthCat_var" : ZFgrowingToString(model.cat_level_column[@"forth_cat_name"]),   //四级分类
                             @"storageNum_var" : @(model.goods_number),     //库存数量
                             @"marketType_var" : ZFgrowingToString(marketType),                //营销类型
                             @"goodsPage_var" : @"ProductDetail"            //商品所属页面
                             };
    
    [Growing track:@"goodsDetailPageView" withVariable:params];
}

#pragma mark - 搜索结果展示统计
///搜索结果浏览 key = searchResultView
+(void)ZFGrowingIOSearchResult:(ZFGoodsModel *)model
                     searchKey:(NSString *)searchKey
                    searchType:(NSString *)searchType
                  searchAmount:(NSInteger)amount
                          page:(NSString *)page
{
    if ([model isKindOfClass:[ZFGoodsModel class]]) {
        NSString *skuSN = nil;
        if (model.goods_sn.length > 7) {
            skuSN = [model.goods_sn substringWithRange:NSMakeRange(0, 7)];
        }else{
            skuSN = model.goods_sn;
        }
        NSDictionary *params = @{@"goodsName_var" : ZFgrowingToString(model.goods_title),  //商品名称
                                 @"SKU_var" : ZFgrowingToString(model.goods_sn),           //SKU id
                                 @"SN_var" : ZFgrowingToString(skuSN),                     //SN（取SKU前7位，即为产品SN）
                                 @"firstCat_var" : ZFgrowingToString(model.cat_level_column[@"first_cat_name"]),       //一级分类
                                 @"sndCat_var" : ZFgrowingToString(model.cat_level_column[@"snd_cat_name"]),           //二级分类
                                 @"thirdCat_var" : ZFgrowingToString(model.cat_level_column[@"third_cat_name"]),       //三级分类
                                 @"forthCat_var" : ZFgrowingToString(model.cat_level_column[@"forth_cat_name"]),       //四级分类
                                 @"marketType_var" : ZFgrowingToString(model.channel_type),        //营销类型
                                 @"goodsPage_var" : ZFgrowingToString(page),            //商品所属页面
                                 @"searchWord_var" : ZFgrowingToString(searchKey),
                                 @"searchType_var" : ZFgrowingToString(searchType),
                                 @"searchResAmount_var" : [NSString stringWithFormat:@"%ld", amount]
                                 };
        [Growing track:@"searchResultView" withVariable:params];
    }
}

/* 搜索结果点击
 * @pragma key = searchResultClck
 * @pragma searchkey 搜索关键字
 * @pragma searchType 搜索类型，区分文字搜索，图片搜索
 * @pragma page 所属页面
 */
+(void)ZFGrowingIOSearchResultClick:(ZFGoodsModel *)model
                          searchKey:(NSString *)searchKey
                         searchType:(NSString *)searchType
                               page:(NSString *)page
{
    if ([model isKindOfClass:[ZFGoodsModel class]]) {
        NSString *skuSN = nil;
        if (model.goods_sn.length > 7) {
            skuSN = [model.goods_sn substringWithRange:NSMakeRange(0, 7)];
        }else{
            skuSN = model.goods_sn;
        }
        NSDictionary *params = @{@"goodsName_var" : ZFgrowingToString(model.goods_title),  //商品名称
                                 @"SKU_var" : ZFgrowingToString(model.goods_sn),           //SKU id
                                 @"SN_var" : ZFgrowingToString(skuSN),                     //SN（取SKU前7位，即为产品SN）
                                 @"firstCat_var" : ZFgrowingToString(model.cat_level_column[@"first_cat_name"]),       //一级分类
                                 @"sndCat_var" : ZFgrowingToString(model.cat_level_column[@"snd_cat_name"]),           //二级分类
                                 @"thirdCat_var" : ZFgrowingToString(model.cat_level_column[@"third_cat_name"]),       //三级分类
                                 @"forthCat_var" : ZFgrowingToString(model.cat_level_column[@"forth_cat_name"]),       //四级分类
                                 @"marketType_var" : ZFgrowingToString(model.channel_type),        //营销类型
                                 @"goodsPage_var" : ZFgrowingToString(page),            //商品所属页面
                                 @"searchWord_var" : ZFgrowingToString(searchKey),
                                 @"searchType_var" : ZFgrowingToString(searchType),
                                 };
        [Growing track:@"searchResultClick" withVariable:params];
    }
}

///添加到购物车 key = addToBag
+(void)ZFGrowingIOAddCart:(GoodsDetailModel *)model
{
    NSString *skuSN = @"";
    if (model.goods_sn.length > 7) {
        skuSN = [model.goods_sn substringWithRange:NSMakeRange(0, 7)];
    }else{
        skuSN = model.goods_sn;
    }
    __block NSString *marketType = @"";
    GoodsReductionModel *reductionModel = model.reductionModel;
    NSArray *titleArray = [reductionModel.msg componentsSeparatedByString:@"||"];
    if ([titleArray count]) {
        [titleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *string = obj;
            NSRegularExpression *regularExpretion = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>|\n|&nbsp"
                                                                                              options:0
                                                                                                error:nil];
            string = [regularExpretion stringByReplacingMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length) withTemplate:@""];
            if (idx == 0) {
                marketType = [marketType stringByAppendingFormat:@"%@", string];
            }else{
                marketType = [marketType stringByAppendingFormat:@" | %@", string];
            }
        }];
    }
    NSDictionary *params = @{
                             @"goodsName_var" : ZFgrowingToString(model.goods_name),   //商品名称
                             @"SKU_var" : ZFgrowingToString(model.goods_sn),           //SKU id
                             @"SN_var" : ZFgrowingToString(skuSN),                     //SN（取SKU前7位，即为产品SN）
                             @"firstCat_var" : ZFgrowingToString(model.cat_level_column[@"first_cat_name"]),   //一级分类
                             @"sndCat_var" : ZFgrowingToString(model.cat_level_column[@"snd_cat_name"]),       //二级分类
                             @"thirdCat_var" : ZFgrowingToString(model.cat_level_column[@"third_cat_name"]),   //三级分类
                             @"forthCat_var" : ZFgrowingToString(model.cat_level_column[@"forth_cat_name"]),   //四级分类
                             @"storageNum_var" : @(model.goods_number),     //库存数量
                             @"marketType_var" : ZFgrowingToString(marketType),                //营销类型
                             @"goodsPage_var" : @"ProductDetail",            //商品所属页面
                             @"buyQuantity_var" : @(model.buyNumbers)
                             };
    [Growing track:@"addToBag" withVariable:params];
}

///在购物车CHECKOUT订单的次数 key = checkOutOrder
///https://docs.google.com/spreadsheets/d/1vYxAtwOovNDVnyjCVDNZC4fRD_2Ok2JdECHohW76XfA/edit#gid=1202824116
+(void)ZFGrowingIOCartCheckOut:(ZFOrderCheckInfoDetailModel *)model
{
//    discount_var    折扣金额
//    marketType_var    营销类型
//    payAmount_var    实际购买金额
//    buyQuantity_var    购买数量
//    originalPrice_var    原价
//    __block NSInteger totalNumbers = 0;
//    [model.cart_goods.goods_list enumerateObjectsUsingBlock:^(CheckOutGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        totalNumbers += obj.goods_number.integerValue;
//    }];
//
//    NSDictionary *params = @{@"discount_var" : model.total.discount_amount,
//                             @"marketType_var" : @"",
//                             @"payAmount_var" : model.total.goods_price,
//                             @"buyQuantity_var" : @(totalNumbers),
//                             @"originalPrice_var" : model.total.goods_price
//                             };
//    [Growing track:@"checkOutOrder" withVariable:params];
//
//    [self ZFGrowingIOCartCheckOutSKU:model];
}

///在购物车CheckOut订单SKU的次数 key = checkOutSKU
///https://docs.google.com/spreadsheets/d/1vYxAtwOovNDVnyjCVDNZC4fRD_2Ok2JdECHohW76XfA/edit#gid=1202824116
+(void)ZFGrowingIOCartCheckOutSKU:(ZFOrderCheckInfoDetailModel *)model
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [model.cart_goods.goods_list enumerateObjectsUsingBlock:^(CheckOutGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSString *skuSN = nil;
//            if (obj.goods_sn.length > 7) {
//                skuSN = [obj.goods_sn substringWithRange:NSMakeRange(0, 6)];
//            }else{
//                skuSN = obj.goods_sn;
//            }
//            NSString *marketType = @"";
//            NSDictionary *params = @{
//                                     @"goodsName_var" : obj.goods_name,   //商品名称
//                                     @"SKU_var" : obj.goods_sn,           //SKU id
//                                     @"SN_var" : skuSN,                     //SN（取SKU前7位，即为产品SN）
//                                     @"firstCat_var" : ZFgrowingToString(obj.cat_level_column[@"first_cat_name"]),   //一级分类
//                                     @"sndCat_var" : ZFgrowingToString(obj.cat_level_column[@"snd_cat_name"]),       //二级分类
//                                     @"thirdCat_var" : ZFgrowingToString(obj.cat_level_column[@"third_cat_name"]),   //三级分类
//                                     @"forthCat_var" : ZFgrowingToString(obj.cat_level_column[@"forth_cat_name"]),   //四级分类
//                                     @"storageNum_var" : obj.g_goods_number,            //库存数量
//                                     @"marketType_var" : marketType,                    //营销类型
//                                     @"buyQuantity_var" : obj.goods_number,              //购买数量
//                                     @"payAmount_var" : obj.goods_price,                //购买金额
//                                     @"discount_var" : obj.coupon_amount                //折扣金额
//                                     };
//            [Growing track:@"checkOutSKU" withVariable:params];
//        }];
//    });
}

///订单支付的次数 key = payOrder
+(void)ZFGrowingIOPayOrder:(ZFOrderCheckDoneDetailModel *)model
              orderManager:(ZFOrderManager *)manager
                 paySource:(NSString *)paySource
{
    if (manager.paymentCode && manager.paymentCode.length) {
        model.hacker_point.order_pay_way = manager.paymentCode;
    }
    [self ZFGrowingIOPayOrder:model orderManager:manager paySource:paySource key:@"payOrder"];
}

///订单支付SKU统计， key = paySKU
+(void)ZFGrowingIOPayOrderSKU:(ZFOrderCheckDoneDetailModel *)model
          checkInfoOderDetail:(ZFOrderCheckInfoDetailModel *)checkModel
                 orderManager:(ZFOrderManager *)manager
                    paySource:(NSString *)paySource
{
    [self ZFGrowingIOPayOrderSKU:model checkInfoOderDetail:checkModel orderManager:manager paySource:paySource key:@"paySKU"];
}

///订单支付成功，key = payOrderSuccess
+(void)ZFGrowingIOPayOrderSuccess:(ZFOrderCheckDoneDetailModel *)model
                     orderManager:(ZFOrderManager *)manager
                        paySource:(NSString *)paySource
{
    if (manager.paymentCode && manager.paymentCode.length) {
        model.hacker_point.order_pay_way = manager.paymentCode;
    }
    if (ZFToString(model.realPayment).length) {
        model.hacker_point.order_pay_way = model.realPayment;
    }
    [self ZFGrowingIOPayOrder:model orderManager:manager paySource:paySource key:@"payOrderSuccess"];
}

///订单支付成功SKU，key = paySKUSuccess
+(void)ZFGrowingIOPayOrderSKUSuccess:(ZFOrderCheckDoneDetailModel *)model
                 checkInfoOderDetail:(ZFOrderCheckInfoDetailModel *)checkModel
                        orderManager:(ZFOrderManager *)manager
                           paySource:(NSString *)paySource
{
    [self ZFGrowingIOPayOrderSKU:model checkInfoOderDetail:checkModel orderManager:manager paySource:paySource key:@"paySKUSuccess"];
}

+(void)ZFGrowingIOPayOrder:(ZFOrderCheckDoneDetailModel *)model
              orderManager:(ZFOrderManager *)manager
                 paySource:(NSString *)paySource
                       key:(NSString *)key
{
    NSString *sourceId = [NSStringUtils getAppsflyerParamsWithKey:MEDIA_SOURCE];
    __block NSString *shippingName = @"";
    [manager.shippingListArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ShippingListModel class]]) {
            ShippingListModel *shippModel = obj;
            if (shippModel.default_select.integerValue == 1) {
                shippingName = shippModel.ship_name;
                *stop = YES;
            }
        }
    }];
    if (model.hacker_point.order_shipping_way && model.hacker_point.order_shipping_way.length) {
        shippingName = model.hacker_point.order_shipping_way;
    }
    NSString *totalNumbers = manager.totalNumbers;
    if (!totalNumbers || totalNumbers.integerValue <= 0) {
        totalNumbers = [manager gainBuyProductTotalNumbers];
    }
    NSString *isUseCoupon = nil;
    if (manager.couponCode) {
        isUseCoupon = @"true";
    }else{
        isUseCoupon = @"false";
    }
    
//    CGFloat couponAmount = manager.couponAmount.floatValue;
    NSDictionary *params = @{
                             @"adSource_var" : ZFgrowingToString(sourceId),    //投放来源
                             @"shippingWay_var" : ZFgrowingToString(shippingName),   //物流方式
                             @"payWay_var" : ZFgrowingToString(model.hacker_point.order_pay_way),    //支付方式
                             @"paySource_var" : ZFgrowingToString(paySource),  //支付来源
                             @"discount_var" : ZFgrowingToString(model.hacker_point.order_discount_amount),  //折扣金额
                             @"marketType_var" : ZFgrowingToString(model.hacker_point.order_market_type),   //营销类型
                             @"payAmount_var" : ZFgrowingToString(model.hacker_point.order_real_pay_amount),    //实际购买金额
                             @"buyQuantity_var" : ZFgrowingToString(totalNumbers), //购买数量
                             @"orderId_var" : ZFgrowingToString(model.order_id),   //订单ID
                             @"pointDeducted_var" : ZFgrowingToString(model.hacker_point.order_point_amount), //积分抵扣金额数
                             @"pointUsedAmount_var" : ZFgrowingToString(model.hacker_point.order_point_value), //积分使用数量
                             @"originalPrice_var" : ZFgrowingToString(model.hacker_point.order_origin_amount),
                             @"couponName_var" : ZFgrowingToString(model.hacker_point.coupon_name),            //优惠券名称
                             @"couponUsed_var" : ZFgrowingToString(model.hacker_point.coupon_used),            //优惠券使用数量
                             @"couponDeducted_var" : ZFgrowingToString(model.hacker_point.coupon_deducted),    //优惠券抵扣金额
                             @"couponType_var" : ZFgrowingToString(model.hacker_point.coupon_type),            //优惠券类型（系统发放or用户领取）
                             @"ifCouponUsed_var" : isUseCoupon,                                                //是否使用优惠券
                             };
    [Growing track:key withVariable:params];
}

+(void)ZFGrowingIOPayOrderSKU:(ZFOrderCheckDoneDetailModel *)model
          checkInfoOderDetail:(ZFOrderCheckInfoDetailModel *)checkModel
                 orderManager:(ZFOrderManager *)manager
                    paySource:(NSString *)paySource
                          key:(NSString *)key
{
    [checkModel.cart_goods.goods_list enumerateObjectsUsingBlock:^(CheckOutGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *skuSN = @"";
        if (obj.goods_sn.length > 7) {
            skuSN = [obj.goods_sn substringWithRange:NSMakeRange(0, 7)];
        }else{
            skuSN = obj.goods_sn;
        }
        CGFloat originAmount = obj.goods_number.floatValue * obj.hacker_point.goods_origin_amount.floatValue;
        NSString *marketType = ZFgrowingToString(obj.hacker_point.goods_market_type);
        NSDictionary *params = @{
                                 @"discount_var" : ZFgrowingToString(obj.hacker_point.goods_pay_discount),  //折扣金额
                                 @"payAmount_var" : ZFgrowingToString(obj.hacker_point.goods_real_pay_amount),    //实际购买金额
                                 @"buyQuantity_var" : ZFgrowingToString(obj.goods_number), //购买数量
                                 @"orderId_var" : ZFgrowingToString(model.order_id), //订单ID
                                 @"goodsName_var" : ZFgrowingToString(obj.goods_name),   //商品名称
                                 @"SKU_var" : ZFgrowingToString(obj.goods_sn),           //SKU id
                                 @"SN_var" : ZFgrowingToString(skuSN),                     //SN（取SKU前7位，即为产品SN）
                                 @"firstCat_var" : ZFgrowingToString(obj.cat_level_column[@"first_cat_name"]),   //一级分类
                                 @"sndCat_var" : ZFgrowingToString(obj.cat_level_column[@"snd_cat_name"]),       //二级分类
                                 @"thirdCat_var" : ZFgrowingToString(obj.cat_level_column[@"third_cat_name"]),   //三级分类
                                 @"forthCat_var" : ZFgrowingToString(obj.cat_level_column[@"forth_cat_name"]),   //四级分类
                                 @"storageNum_var" : ZFgrowingToString(obj.g_goods_number),            //库存数量
                                 @"marketType_var" : marketType,                    //营销类型
                                 @"originalPrice_var" : [NSNumber numberWithFloat:originAmount],    //原价
                                 };
        [Growing track:key withVariable:params];
    }];
}

#pragma mark - 订单列表统计代码

///订单列表发起支付的growingIO统计
+(void)ZFGrowingIOPayOrderWithOrderList:(MyOrdersModel *)model
{
    ZFOrderManager *manager = [[ZFOrderManager alloc] init];
    __block NSInteger num = 0;
    [model.goods enumerateObjectsUsingBlock:^(MyOrderGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        num += obj.goods_number.integerValue;
    }];
    manager.totalNumbers = [NSString stringWithFormat:@"%ld", num];
    
    ZFOrderCheckDoneDetailModel *detailModel = [[ZFOrderCheckDoneDetailModel alloc] init];
    detailModel.order_id = model.order_id;
    detailModel.hacker_point = model.hacker_point;
    
    [self ZFGrowingIOPayOrder:detailModel orderManager:manager paySource:@"OrderList"];
    ///支付成功SKU统计
    [self ZFGrowingIOOrderListPayOrderSKU:model key:@"paySKU"];
}
///支付成功的growingIO统计
+(void)ZFGrowingIOPayOrderSuccessWithBaseOrderModel:(ZFBaseOrderModel *)model
                                          paySource:(NSString *)paySource {
    ZFOrderManager *manager = [[ZFOrderManager alloc] init];
    __block NSInteger num = 0;
    [model.baseGoodsList enumerateObjectsUsingBlock:^(ZFBaseOrderGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        num += obj.goods_number.integerValue;
    }];
    manager.totalNumbers = [NSString stringWithFormat:@"%ld", num];
    ZFOrderCheckDoneDetailModel *detailModel = [[ZFOrderCheckDoneDetailModel alloc] init];
    detailModel.order_id = model.order_id;
    detailModel.hacker_point = model.hacker_point;
    if (ZFToString(model.realPayment).length) {
        detailModel.realPayment = model.realPayment;
    }
    ///支付成功订单统计
    [self ZFGrowingIOPayOrderSuccess:detailModel orderManager:manager paySource:paySource];
    ///支付成功SKU统计
    [self ZFGrowingIOOrderPayOrderSKU:model key:@"paySKUSuccess"];
}

///订单列表SKU收集
+(void)ZFGrowingIOOrderPayOrderSKU:(ZFBaseOrderModel *)model key:(NSString *)growingIOKey
{
    ///支付成功SKU统计
    [model.baseGoodsList enumerateObjectsUsingBlock:^(ZFBaseOrderGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *skuSN = @"";
        if (obj.goods_sn.length > 7) {
            skuSN = [obj.goods_sn substringWithRange:NSMakeRange(0, 7)];
        }else{
            skuSN = obj.goods_sn;
        }
        CGFloat originAmount = obj.goods_number.floatValue * obj.hacker_point.goods_origin_amount.floatValue;
        NSString *marketType = ZFgrowingToString(obj.hacker_point.goods_market_type);
        NSDictionary *params = @{
                                 @"discount_var" : ZFgrowingToString(obj.hacker_point.goods_pay_discount),  //折扣金额
                                 @"payAmount_var" : ZFgrowingToString(obj.hacker_point.goods_real_pay_amount),    //实际购买金额
                                 @"buyQuantity_var" : ZFgrowingToString(obj.goods_number), //购买数量
                                 @"orderId_var" : ZFgrowingToString(model.order_id), //订单ID
                                 @"goodsName_var" : ZFgrowingToString(obj.goods_title),   //商品名称
                                 @"SKU_var" : ZFgrowingToString(obj.goods_sn),           //SKU id
                                 @"SN_var" : ZFgrowingToString(skuSN),                     //SN（取SKU前7位，即为产品SN）
                                 @"firstCat_var" : ZFgrowingToString(obj.cat_level_column[@"first_cat_name"]),   //一级分类
                                 @"sndCat_var" : ZFgrowingToString(obj.cat_level_column[@"snd_cat_name"]),       //二级分类
                                 @"thirdCat_var" : ZFgrowingToString(obj.cat_level_column[@"third_cat_name"]),   //三级分类
                                 @"forthCat_var" : ZFgrowingToString(obj.cat_level_column[@"forth_cat_name"]),   //四级分类
                                 @"storageNum_var" : ZFgrowingToString(obj.hacker_point.goods_storage_num),            //库存数量
                                 @"marketType_var" : marketType,                    //营销类型
                                 @"originalPrice_var" : [NSNumber numberWithFloat:originAmount],
                                 };
        [Growing track:growingIOKey withVariable:params];
    }];
}

///订单列表支付成功的growingIO统计
//+(void)ZFGrowingIOPayOrderSuccessWithOrderList:(MyOrdersModel *)model
//{
//    ZFOrderManager *manager = [[ZFOrderManager alloc] init];
//    __block NSInteger num = 0;
//    [model.goods enumerateObjectsUsingBlock:^(MyOrderGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        num += obj.goods_number.integerValue;
//    }];
//    manager.totalNumbers = [NSString stringWithFormat:@"%ld", num];
//    ZFOrderCheckDoneDetailModel *detailModel = [[ZFOrderCheckDoneDetailModel alloc] init];
//    detailModel.order_id = model.order_id;
//    detailModel.hacker_point = model.hacker_point;
//    if (ZFToString(model.realPayment).length) {
//        detailModel.realPayment = model.realPayment;
//    }
//    ///支付成功订单统计
//    [self ZFGrowingIOPayOrderSuccess:detailModel orderManager:manager paySource:@"OrderList"];
//    ///支付成功SKU统计
//    [self ZFGrowingIOOrderListPayOrderSKU:model key:@"paySKUSuccess"];
//}

///订单列表SKU收集
+(void)ZFGrowingIOOrderListPayOrderSKU:(MyOrdersModel *)model key:(NSString *)growingIOKey
{
    ///支付成功SKU统计
    [model.goods enumerateObjectsUsingBlock:^(MyOrderGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *skuSN = @"";
        if (obj.goods_sn.length > 7) {
            skuSN = [obj.goods_sn substringWithRange:NSMakeRange(0, 7)];
        }else{
            skuSN = obj.goods_sn;
        }
        CGFloat originAmount = obj.goods_number.floatValue * obj.hacker_point.goods_origin_amount.floatValue;
        NSString *marketType = ZFgrowingToString(obj.hacker_point.goods_market_type);
        NSDictionary *params = @{
                                 @"discount_var" : ZFgrowingToString(obj.hacker_point.goods_pay_discount),  //折扣金额
                                 @"payAmount_var" : ZFgrowingToString(obj.hacker_point.goods_real_pay_amount),    //实际购买金额
                                 @"buyQuantity_var" : ZFgrowingToString(obj.goods_number), //购买数量
                                 @"orderId_var" : ZFgrowingToString(model.order_id), //订单ID
                                 @"goodsName_var" : ZFgrowingToString(obj.goods_title),   //商品名称
                                 @"SKU_var" : ZFgrowingToString(obj.goods_sn),           //SKU id
                                 @"SN_var" : ZFgrowingToString(skuSN),                     //SN（取SKU前7位，即为产品SN）
                                 @"firstCat_var" : ZFgrowingToString(obj.cat_level_column[@"first_cat_name"]),   //一级分类
                                 @"sndCat_var" : ZFgrowingToString(obj.cat_level_column[@"snd_cat_name"]),       //二级分类
                                 @"thirdCat_var" : ZFgrowingToString(obj.cat_level_column[@"third_cat_name"]),   //三级分类
                                 @"forthCat_var" : ZFgrowingToString(obj.cat_level_column[@"forth_cat_name"]),   //四级分类
                                 @"storageNum_var" : ZFgrowingToString(obj.hacker_point.goods_storage_num),            //库存数量
                                 @"marketType_var" : marketType,                    //营销类型
                                 @"originalPrice_var" : [NSNumber numberWithFloat:originAmount],
                                 };
        [Growing track:growingIOKey withVariable:params];
    }];
}

#pragma mark - 订单详情统计代码

///订单详情发起支付的growingIO统计
+(void)ZFGrowingIOPayOrderWithOrderDetail:(OrderDetailOrderModel *)model listModel:(ZFOrderDeatailListModel *)listModel
{
    ZFOrderManager *manager = [[ZFOrderManager alloc] init];
    __block NSInteger num = 0;
    
    [listModel.child_order enumerateObjectsUsingBlock:^(ZFOrderDetailChildModel * _Nonnull childModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [childModel.goods_list enumerateObjectsUsingBlock:^(OrderDetailGoodModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            num += obj.goods_number.integerValue;
        }];
    }];
    
    manager.totalNumbers = [NSString stringWithFormat:@"%ld", num];
    
    ZFOrderCheckDoneDetailModel *detailModel = [[ZFOrderCheckDoneDetailModel alloc] init];
    detailModel.order_id = model.order_id;
    detailModel.hacker_point = model.hacker_point;
    [self ZFGrowingIOPayOrder:detailModel orderManager:manager paySource:@"OrderDetail"];
    
    ///SKU统计
    [self ZFGrowingIOOrderDetailPayOrderSKU:model listModel:listModel key:@"paySKU"];
}

///订单详情支付成功的growingIO统计
//+(void)ZFGrowingIOPayOrderSuccessWithOrderDetail:(OrderDetailOrderModel *)model listModel:(ZFOrderDeatailListModel *)listModel
//{
//    ZFOrderManager *manager = [[ZFOrderManager alloc] init];
//    ZFOrderCheckDoneDetailModel *detailModel = [[ZFOrderCheckDoneDetailModel alloc] init];
//    detailModel.order_id = model.order_id;
//    detailModel.hacker_point = model.hacker_point;
//    if (ZFToString(model.realPayment).length) {
//        detailModel.realPayment = model.realPayment;
//    }
//    [self ZFGrowingIOPayOrderSuccess:detailModel orderManager:manager paySource:@"OrderDetail"];
//
//    [self ZFGrowingIOOrderDetailPayOrderSKU:model listModel:listModel key:@"paySKUSuccess"];
//}

///订单详情发起支付SKU
+(void)ZFGrowingIOOrderDetailPayOrderSKU:(OrderDetailOrderModel *)model listModel:(ZFOrderDeatailListModel *)listModel key:(NSString *)growingIOKey
{
    ///支付成功SKU统计
    
    [listModel.child_order enumerateObjectsUsingBlock:^(ZFOrderDetailChildModel * _Nonnull childModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [childModel.goods_list enumerateObjectsUsingBlock:^(OrderDetailGoodModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *skuSN = @"";
            if (obj.goods_sn.length > 7) {
                skuSN = [obj.goods_sn substringWithRange:NSMakeRange(0, 7)];
            }else{
                skuSN = obj.goods_sn;
            }
            CGFloat originAmount = obj.goods_number.floatValue * obj.hacker_point.goods_origin_amount.floatValue;
            NSString *marketType = ZFgrowingToString(obj.hacker_point.goods_market_type);
            NSDictionary *params = @{
                                     @"discount_var" : ZFgrowingToString(obj.hacker_point.goods_pay_discount),  //折扣金额
                                     @"payAmount_var" : ZFgrowingToString(obj.hacker_point.goods_real_pay_amount),    //实际购买金额
                                     @"buyQuantity_var" : ZFgrowingToString(obj.goods_number), //购买数量
                                     @"orderId_var" : ZFgrowingToString(model.order_id), //订单ID
                                     @"goodsName_var" : ZFgrowingToString(obj.goods_title),   //商品名称
                                     @"SKU_var" : ZFgrowingToString(obj.goods_sn),           //SKU id
                                     @"SN_var" : ZFgrowingToString(skuSN),                     //SN（取SKU前7位，即为产品SN）
                                     @"firstCat_var" : ZFgrowingToString(obj.cat_level_column[@"first_cat_name"]),   //一级分类
                                     @"sndCat_var" : ZFgrowingToString(obj.cat_level_column[@"snd_cat_name"]),       //二级分类
                                     @"thirdCat_var" : ZFgrowingToString(obj.cat_level_column[@"third_cat_name"]),   //三级分类
                                     @"forthCat_var" : ZFgrowingToString(obj.cat_level_column[@"forth_cat_name"]),   //四级分类
                                     @"storageNum_var" : ZFgrowingToString(obj.hacker_point.goods_storage_num),            //库存数量
                                     @"marketType_var" : marketType,                    //营销类型
                                     @"originalPrice_var" : [NSNumber numberWithFloat:originAmount],
                                     };
            [Growing track:growingIOKey withVariable:params];
        }];
    }];
}

#pragma mark - push

+(void)ZFGrowingIOShowPush:(NSString *)pushType pushName:(NSString *)pushName
{
    NSDictionary *params = @{@"pushType_var" : ZFgrowingToString(pushType),
                             @"pushName_var" : ZFgrowingToString(pushName)
                             };
    [Growing track:@"pushShow" withVariable:params];
}

+(void)ZFGrowingIOClickPush:(NSString *)pushType pushName:(NSString *)pushName
{
    NSDictionary *params = @{@"pushType_var" : ZFgrowingToString(pushType),
                             @"pushName_var" : ZFgrowingToString(pushName)
                             };
    [Growing track:@"pushClick" withVariable:params];
    [Growing setEvarWithKey:@"sourceRecent_evar" andStringValue:@"推送"];
    [Growing setEvarWithKey:@"sourceFirst_evar" andStringValue:@"推送"];
}

/*
 *  优惠券曝光
 *  key = couponImp
 *  @pragma couponName
 *  @pragma goodsPage
 **/
+(void)ZFGrowingIOCouponShow:(NSString *)couponName page:(NSString *)page
{
    NSDictionary *params = @{
                             @"couponName_var" : ZFgrowingToString(couponName),
                             @"goodsPage_var" : ZFgrowingToString(page)
                             };
    [Growing track:@"couponImp" withVariable:params];
}

/*
 *  优惠券点击
 *  key = couponClck
 *  @pragma couponName
 *  @pragma goodsPage
 **/
+(void)ZFGrowingIOCouponClick:(NSString *)couponName page:(NSString *)page
{
    NSDictionary *params = @{
                             @"couponName_var" : ZFgrowingToString(couponName),
                             @"goodsPage_var" : ZFgrowingToString(page)
                             };
    [Growing track:@"couponClick" withVariable:params];
}

/*
 *  优惠券领取成功
 *  key = couponGet
 *  @pragma couponName
 *  @pragma goodsPage
 **/
+(void)ZFGrowingIOCouponGetSuccess:(NSString *)couponName page:(NSString *)page
{
    NSDictionary *params = @{
                             @"couponName_var" : ZFgrowingToString(couponName),
                             @"goodsPage_var" : ZFgrowingToString(page)
                             };
    [Growing track:@"couponGet" withVariable:params];
}

/*  发帖成功
 *  key = postSuccess
 *  @pragma postId 帖子id
 *  @pragma postType 帖子详情页中的推荐商品所属的帖子类型，取值包括shows、outfits、videos；
 **/
+(void)ZFGrowingIOPostTopic:(NSString *)postId postType:(NSString *)postType
{
    NSDictionary *params = @{
                             @"postId_var" : ZFgrowingToString(postId),
                             @"postType_var" : ZFgrowingToString(postType)
                             };
    [Growing track:@"postSuccess" withVariable:params];
}

/*  帖子详情浏览
 *  key = communityTopicDetailView
 *  @pragma postId 帖子id
 *  @pragma postType 帖子详情页中的推荐商品所属的帖子类型，取值包括shows、outfits、videos；
 **/
+(void)ZFGrowingIOPostTopicShow:(NSString *)postId postType:(NSString *)postType
{
    NSDictionary *params = @{
                             @"postId_var" : ZFgrowingToString(postId),
                             @"postType_var" : ZFgrowingToString(postType)
                             };
    [Growing track:@"communityTopicDetailView" withVariable:params];
    ///增加帖子转化变量
//    [Growing setEvarWithKey:GIOPostId_evar andStringValue:ZFgrowingToString(postId)];
//    [Growing setEvarWithKey:GIOPostType_evar andStringValue:ZFgrowingToString(postType)];
//    [Growing setEvarWithKey:GIOsourceRecent_evar andStringValue:@"社区"];
}

@end

