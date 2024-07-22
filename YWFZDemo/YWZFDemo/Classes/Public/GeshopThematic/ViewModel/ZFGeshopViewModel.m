//
//  ZFGeshopViewModel.m
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopViewModel.h"
#import "ZFGeshopSectionModel.h"
#import "ZFRequestModel.h"
#import "ZFNetwork.h"
#import "YWCFunctionTool.h"
#import "YWLocalHostManager.h"
#import "ZFApiDefiner.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "ZFColorDefiner.h"
#import "UIColor+ExTypeChange.h"
#import "NSString+Extended.h"
#import "ZFAnalytics.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>
#import "ZFGeshopSectionModel.h"
#import "NSStringUtils.h"
#import "ZFMergeRequest.h"
#import "ZFTimerManager.h"
#import "SystemConfigUtils.h"
#import "NSDictionary+SafeAccess.h"

@interface ZFGeshopViewModel ()
@property (nonatomic, strong) NSMutableArray       *timerKeyArray;
@property (nonatomic, strong) ZFGeshopSectionModel *siftSectionModel;
@property (nonatomic, strong) ZFGeshopSectionModel *lastGoodsSectionModel;
@end

@implementation ZFGeshopViewModel

- (void)dealloc {
    [self clearCountDownTimer];
}

- (void)clearCountDownTimer {
    for (NSString *timerKey in self.timerKeyArray) {
        if (!ZFIsEmptyString(timerKey)) {
            [[ZFTimerManager shareInstance] stopTimer:timerKey];
        }
    }
}

- (instancetype)init {
    if (self = [super init]) {
        self.curPage = 1;
        self.page_size = 20;
    }
    return self;
}

/// 配置请求模型Geshop公共参数
- (ZFRequestModel *)requestModel:(NSDictionary *)requestInfo
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.forbidAddPublicArgument = YES;
    requestModel.forbidEncrypt = YES;
    requestModel.taget = self.controller;
    requestModel.type = ZFNetworkRequestTypePOST;
    requestModel.requestHttpHeaderField = @{@"Accept" : @"application/vnd.GESHOP.v1+json"};
    
    NSInteger type = [AccountManager sharedManager].af_user_type.integerValue;
    type = (type == 1) ? 0 : 1; //新老客
    NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    NSString *pipeline = ZFToString(GetUserDefault(kLocationInfoPipeline));//国家站
    ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
    
    NSMutableDictionary *reqParmaters = [NSMutableDictionary dictionaryWithDictionary:requestInfo];
    reqParmaters[@"site_code"]     = @"zf-app";
    reqParmaters[@"agent"]         = @"ios";
    reqParmaters[@"pipeline"]      = pipeline;
    reqParmaters[@"user_group"]    = @(type);
    reqParmaters[@"lang"]          = ZFToString(lang);
    reqParmaters[@"cookie_id"]     = ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]);
    reqParmaters[ZFApiBtsUniqueID] = ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]);
    reqParmaters[@"country_code"]  = ZFToString(accountModel.region_code);
    reqParmaters[@"page_id"]       = ZFToString(self.nativeThemeId);
    requestModel.parmaters = reqParmaters;
    
    return requestModel;
}

/// 请求专题筛选数据列表 <接口里有一个失败就不显示页面>
/// @param requestInfo 请求参数
/// @param needRequestS3 是否需要请求S3备份数据
/// @param completion 回调
- (void)requestGeshopPageData:(NSDictionary *)requestInfo
                   completion:(ZFGeshopDataBlock)completion
{
    self.curPage = 1;
    ///专题详情数据
    ZFRequestModel *detailModel = [self requestModel:requestInfo];
    detailModel.url = [YWLocalHostManager geshopDetailURL];
    
    
    //组件异步数据
    ZFRequestModel *asyncInfoModel = [self requestModel:requestInfo];
    asyncInfoModel.url = [YWLocalHostManager geshopAsyncInfoURL];
    
    
    /// 合并请求: 两个都成功才刷新页面
    ZFMergeRequest *mergeRequestManager = [[ZFMergeRequest alloc] init];
    [mergeRequestManager addRequest:detailModel];
    [mergeRequestManager addRequest:asyncInfoModel];
    @weakify(self)
    [mergeRequestManager requestResult:^(NSDictionary<NSString *,NSDictionary *> *mergeSuccessResult, NSDictionary<NSString *,NSDictionary *> *mergeFailResult, NSError *error) {
        @strongify(self)
        if (error || mergeFailResult.count > 0) {
            if (completion) {
                completion(nil, nil);
            }
        } else {
            NSArray *pageModelArrray = [NSArray array];
            
            /// 1.解析专题页面列表数据模型
            NSString *detailDataKey = [NSString stringWithFormat:@"%p", detailModel];
            NSDictionary *detailDict = mergeSuccessResult[detailDataKey];
            if (ZFJudgeNSDictionary(detailDict)) {
                NSArray *resultArray = detailDict[ZFResultKey];
                if (ZFJudgeNSArray(resultArray)) {
                    pageModelArrray = [NSArray yy_modelArrayWithClass:[ZFGeshopSectionModel class] json:resultArray];
                }
            }
            
            /// 2.把异步接口数据合并到列表数据模型中
            NSString *asyncDataKey = [NSString stringWithFormat:@"%p", asyncInfoModel];
            NSDictionary *asyncDict = mergeSuccessResult[asyncDataKey];
            if (ZFJudgeNSDictionary(asyncDict)) {
                
                NSDictionary *asyncResponse = [asyncDict ds_dictionaryForKey:ZFResultKey];
                if (ZFJudgeNSDictionary(asyncResponse)) {
                    pageModelArrray = [self mergeGeshopAsyncData:pageModelArrray
                    asyncResponse:asyncResponse];
                }
            }
            
            if (pageModelArrray.count == 0) {
                if (completion) {
                    completion(nil, nil);
                }
                return ;
            }
            
            /// 3.合并接口数据后, 包装页面自定义显示模型
            NSArray *configModelArray = [self configGeshopAllSectionModel:pageModelArrray];
            
            if (completion) {
                NSDictionary *pageDict = [self fetchPageRequestInfo:configModelArray];
                completion(configModelArray, pageDict);
            }
        }
    }];
    [mergeRequestManager startRequest];
}

- (NSString *)fetchSiftComponent_ids {
    NSMutableString *component_ids = [NSMutableString string];
    [component_ids appendFormat:@"%@", self.lastGoodsSectionModel.component_id];
    [component_ids appendFormat:@",%@", self.siftSectionModel.component_id];
    self.curPage = 1;
    return component_ids;
}

- (NSString *)fetchMorePageComponent_ids {
    NSString *lastGoodsComponent_id = self.lastGoodsSectionModel.component_id;
    NSString *siftComponent_id = self.lastGoodsSectionModel.component_id;
    
    NSMutableString *component_ids = [NSMutableString string];
    [component_ids appendString:ZFToString(lastGoodsComponent_id)];
    
    if (![lastGoodsComponent_id isEqualToString:siftComponent_id]) {
        [component_ids appendFormat:@",%@", siftComponent_id];
    }
    self.curPage++;
    return component_ids;
}

/// 分页请求专题商品组件数据
/// @param requestInfo 请求参数
/// @param completion 回调

- (void)requestGeshopMoreData:(NSDictionary *)requestInfo
                    completion:(ZFGeshopMoreDataBlock)completion
{
    ZFRequestModel *requestModel = [self requestModel:requestInfo];
    requestModel.url = [YWLocalHostManager geshopAsyncInfoURL];
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSArray *goodsModelArray = [NSArray array];
        NSDictionary *asyncResponse = responseObject[ZFResultKey];
        if (ZFJudgeNSDictionary(asyncResponse)) {
            
            NSMutableDictionary *moreDataDict = [NSMutableDictionary dictionaryWithDictionary:asyncResponse];
            [moreDataDict removeObjectForKey:@"af_params"];//过滤参数

            //查到相应的商品组件
            NSDictionary *goodsDict = moreDataDict.allValues.firstObject;
            if (ZFJudgeNSDictionary(goodsDict)) {
                
                NSArray *goods_list = goodsDict[@"goods_list"];
                if (ZFJudgeNSArray(goods_list)) {
                    goodsModelArray = [NSArray yy_modelArrayWithClass:[ZFGeshopSectionListModel class] json:goods_list];
                }
            }
        }
        if (completion) {
            NSDictionary *pageDict = [self fetchPageRequestInfo:goodsModelArray];
            completion(goodsModelArray, pageDict);
        }
    } failure:^(NSError *error) {
        self.curPage--;
        if (completion) {
            completion(nil, nil);
        }
    }];
}

/// 异步请求指定组件id数据
/// @param requestInfo 请求参数
/// @param completion 回调
- (void)requestGeshopAsyncData:(NSDictionary *)requestInfo
               pageModelArrray:(NSArray<ZFGeshopSectionModel *> *)pageModelArrray
                    completion:(ZFGeshopDataBlock)completion
{
    ZFRequestModel *asyncInfoModel = [self requestModel:requestInfo];
    asyncInfoModel.url = [YWLocalHostManager geshopAsyncInfoURL];
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:asyncInfoModel success:^(id responseObject) {
        NSArray *configModelArray = [NSArray array];
        
        NSDictionary *asyncResponse = responseObject[ZFResultKey];
        if (ZFJudgeNSDictionary(asyncResponse)) {
            configModelArray = [self mergeGeshopAsyncData:pageModelArrray
                                            asyncResponse:asyncResponse];
        }
        if (completion) {
            NSDictionary *pageDict = [self fetchPageRequestInfo:configModelArray];
            completion(configModelArray, pageDict);
        }
    } failure:^(NSError *error) {
        if (completion) {
            completion(nil, nil);
        }
    }];
}

/// 每次获取列表数据后 获取最后一个商品组件的是否能分页加载的标识
- (NSDictionary *)fetchPageRequestInfo:(NSArray *)allSectionModelArray {
    
    NSMutableDictionary *pageDict = [NSMutableDictionary dictionary];
    for (ZFGeshopSectionModel *sectionModel in allSectionModelArray) {
        if (![sectionModel isKindOfClass:[ZFGeshopSectionModel class]]) continue;
        
        /// 拿到最后一个(103:商品组件)判断是否需要分页
        if (sectionModel.component_type == ZFGeshopGridGoodsCellType) {
            self.lastGoodsSectionModel = sectionModel;
        }
    }
    if (self.lastGoodsSectionModel.pagination) {
        NSInteger total_count = self.lastGoodsSectionModel.pagination.total_count;
        self.page_size = self.lastGoodsSectionModel.pagination.page_size;
        if (self.page_size == 0) {
            self.page_size = 20;
        }
        NSInteger pageNum = total_count / self.page_size;
        NSInteger leftPage = (total_count % self.page_size) > 0 ? 1 : 0;
        pageDict[kTotalPageKey] = @((pageNum + leftPage));
        pageDict[kCurrentPageKey] = @(self.curPage);
    }
    return pageDict;
}

#pragma mark ---- <ConfigData> ----

/// 合并合并两个接口返回的数据
- (NSArray *)mergeGeshopAsyncData:(NSArray *)pageModelArrray
                     asyncResponse:(NSDictionary *)asyncResponse
{
    for (ZFGeshopSectionModel *sectionModel in pageModelArrray) {
        if (![sectionModel isKindOfClass:[ZFGeshopSectionModel class]]) continue;
        NSDictionary *valueDict = asyncResponse[ZFToString(sectionModel.component_id)];
        if (!ZFJudgeNSDictionary(valueDict)) continue;

        if (!sectionModel.component_data) {
            sectionModel.component_data = [ZFGeshopComponentDataModel new];
        }
        if (sectionModel.component_type == ZFGeshopGridGoodsCellType) {
            //103:商品组件
            NSArray *goods_list = valueDict[@"goods_list"];
            if (ZFJudgeNSArray(goods_list)) {
                NSArray *goodsArrray = [NSArray yy_modelArrayWithClass:[ZFGeshopSectionListModel class] json:goods_list];
                sectionModel.component_data.list = [NSMutableArray arrayWithArray:goodsArrray];
                sectionModel.sectionItemCount = goodsArrray.count;
            }
            
            NSDictionary *pagination = valueDict[@"pagination"];
            if (ZFJudgeNSDictionary(pagination)) {
                sectionModel.pagination = [ZFGeshopPaginationModel yy_modelWithJSON:pagination];
            }
            
        } else if (sectionModel.component_type == ZFGeshopSiftGoodsCellType) {
            //104:筛选组件
            self.siftSectionModel = sectionModel;
            
            NSArray *category_list = valueDict[@"category_list"];
            if (ZFJudgeNSArray(category_list) && category_list.count > 0) {
                sectionModel.component_data.category_list = [NSArray yy_modelArrayWithClass:[ZFGeshopSiftItemModel class] json:category_list];
            }
            
            NSArray *sort_list = valueDict[@"sort_list"];
            if (ZFJudgeNSArray(sort_list) && sort_list.count > 0) {
                sectionModel.component_data.sort_list = [NSArray yy_modelArrayWithClass:[ZFGeshopSiftItemModel class] json:sort_list];
            }
            
            NSArray *refine_list = valueDict[@"refine_list"];
            if (ZFJudgeNSArray(refine_list) && refine_list.count > 0) {
                sectionModel.component_data.refine_list = [NSArray yy_modelArrayWithClass:[ZFGeshopSiftItemModel class] json:refine_list];
            }
            
        } else if (sectionModel.component_type == ZFGeshopSecKillSuperCellType) {
            //105:秒杀组件
            NSArray *goods_list = valueDict[@"goods_list"];
            if (ZFJudgeNSArray(goods_list)) {
                NSArray *goodsArrray = [NSArray yy_modelArrayWithClass:[ZFGeshopSectionListModel class] json:goods_list];
                sectionModel.component_data.list = [NSMutableArray arrayWithArray:goodsArrray];
                sectionModel.sectionItemCount = (goodsArrray.count > 0) ? 1 : 0;
            }
            
            NSDictionary *tsk_info = valueDict[@"tsk_info"];
            if (ZFJudgeNSDictionary(tsk_info)) {
                sectionModel.component_data.tsk_begin_time = ZFToString(tsk_info[@"tsk_begin_time"]);
                sectionModel.component_data.tsk_end_time = ZFToString(tsk_info[@"tsk_end_time"]);
            }
        }
    }
    return pageModelArrray;
}

/// 包装页面自定义显示模型
- (NSArray *)configGeshopAllSectionModel:(NSArray *)jsonArray {
    NSArray *configModelArray = [NSArray arrayWithArray:jsonArray];
    
    ZFGeshopSectionModel *navigationModel = nil;
    NSMutableArray *navigationItemIdArray = [NSMutableArray array];
    
    for (ZFGeshopSectionModel *sectionModel in configModelArray) {
        if (![sectionModel isKindOfClass:[ZFGeshopSectionModel class]]) continue;
        sectionModel.sectionItemCellClass = [self fetchCellClass:sectionModel.component_type];
        sectionModel.nativeThemeId = self.nativeThemeId;
        sectionModel.nativeThemeName = self.nativeThemeTitle;
        
        id cellBlcok = [self fetchCellBlock:sectionModel.component_type];
        CGFloat margin_top = sectionModel.component_style.margin_top;
        CGFloat margin_bottom = sectionModel.component_style.margin_bottom;
        
        switch (sectionModel.component_type) {
            case ZFGeshopTextImageCellType:  // 100:文本(标题栏)组件
            {
                BOOL isEmpty = (ZFIsEmptyString(sectionModel.component_data.title) && ZFIsEmptyString(sectionModel.component_style.bg_img));
                sectionModel.sectionItemCount = isEmpty ? 0 : 1;
                sectionModel.sectionMinimumLineSpacing = 0;
                sectionModel.sectionMinimumInteritemSpacing = 0;
                
                CGFloat padding_top = sectionModel.component_style.padding_top;
                CGFloat padding_bottom = sectionModel.component_style.padding_bottom;
                
                UIFont *textFont = [UIFont systemFontOfSize:14];
                if (sectionModel.component_style.text_size > 0) {
                    NSInteger text_size = sectionModel.component_style.text_size;
                    if (sectionModel.component_style.text_style == 1) {
                        textFont = [UIFont boldSystemFontOfSize:text_size];
                    } else {
                        textFont = [UIFont systemFontOfSize:text_size];
                    }
                }
                CGFloat textHeight = [sectionModel.component_data.title textSizeWithFont:textFont constrainedToSize:CGSizeMake(KScreenWidth, CGFLOAT_MAX) lineBreakMode:0].height;
                CGFloat itemHeight = padding_top + textHeight + padding_bottom ;
                
                sectionModel.sectionItemSize = CGSizeMake(KScreenWidth, itemHeight);
                sectionModel.sectionInsetForSection = UIEdgeInsetsMake(margin_top, 0, margin_bottom, 0);
            }
                break;
            case ZFGeshopCycleBannerCellType:   // 101:轮播组件
            {
                sectionModel.sectionItemCount = (sectionModel.component_data.list.count > 0) ? 1 : 0;
                CGFloat width = sectionModel.component_style.width;
                CGFloat height = sectionModel.component_style.height;
                CGFloat showHeight = 0.0;
                if (width != 0.0 && height != 0.0) {
                    showHeight = KScreenWidth * height / width;
                }
                sectionModel.sectionItemSize = CGSizeMake(KScreenWidth, showHeight);
                sectionModel.sectionMinimumLineSpacing = 10;
                sectionModel.sectionMinimumInteritemSpacing = 0;
                sectionModel.sectionInsetForSection = UIEdgeInsetsMake(margin_top, 0, margin_bottom, 0);
                sectionModel.clickCycleBannerBlock = cellBlcok;
            }
                break;
            case ZFGeshopNavigationCellType:      // 102:水平导航组件
            {
                //CGFloat height = sectionModel.component_style.height;
                //CGFloat showHeight = height > 0 ? height : 44;
                CGFloat showHeight = 44;
                sectionModel.sectionItemSize = CGSizeMake(KScreenWidth, showHeight);
                sectionModel.sectionMinimumLineSpacing = 10;
                sectionModel.sectionMinimumInteritemSpacing = 0;
                sectionModel.sectionInsetForSection = UIEdgeInsetsZero;
                sectionModel.sectionItemCount = (sectionModel.component_data.list.count > 0) ? 1 : 0;
                sectionModel.clickNavigationItemBlock = cellBlcok;
                
                CGFloat showAllWidth = 0.0;
                for (NSInteger i=0; i<sectionModel.component_data.list.count; i++) {
                    ZFGeshopSectionListModel *listModel = sectionModel.component_data.list[i];
                    [navigationItemIdArray addObject:ZFToString(listModel.component_id)];
                    if (i == 0) {//需求:默认选中第一个水平导航标签
                        listModel.isActiveNavigatorItem = YES;
                    }
                    CGFloat text_size = sectionModel.component_style.text_size;
                    NSInteger fontSize = (text_size > 0) ? text_size : 14;
                    
                    UILabel *tmpLabel = [[UILabel alloc] init];
                    tmpLabel.frame = CGRectMake(0, 0, 100, showHeight);
                    tmpLabel.text = listModel.component_title;
                    tmpLabel.font = [UIFont systemFontOfSize:fontSize];
                    [tmpLabel sizeToFit];
                    CGFloat textWidth = tmpLabel.bounds.size.width;
                    
                    CGFloat padding_left = 12;//sectionModel.component_style.padding_left;
                    CGFloat padding_right = 12;//sectionModel.component_style.padding_right;
                    listModel.navigatorItemWidth = padding_left + textWidth + padding_right;
                    
                    showAllWidth += listModel.navigatorItemWidth;
                }
                
                if (showAllWidth < KScreenWidth) { ///如果所有标签宽度总和小于屏幕宽度则平分撑满屏幕宽度
                    CGFloat averageWh = KScreenWidth / sectionModel.component_data.list.count;
                    for (ZFGeshopSectionListModel *listModel in sectionModel.component_data.list) {
                        if (listModel.navigatorItemWidth < averageWh) {
                            listModel.navigatorItemWidth = averageWh;
                        }
                    }
                }
                if (navigationModel) { //标记是否为第一个水平导航组件
                    navigationModel.isMultipartNavigation = YES;
                } else {
                    navigationModel = sectionModel;
                }
            }
                break;
            case ZFGeshopSiftGoodsCellType:       // 104:筛选组件
            {
                //CGFloat height = sectionModel.component_style.height;
                //CGFloat showHeight = height > 0 ? height : 44;
                CGFloat showHeight = 44;
                sectionModel.sectionItemSize = CGSizeMake(KScreenWidth, showHeight);
                sectionModel.sectionMinimumLineSpacing = 10;
                sectionModel.sectionMinimumInteritemSpacing = 0;
                sectionModel.sectionInsetForSection = UIEdgeInsetsZero;
                sectionModel.clickSiftItemBlock = cellBlcok;
                sectionModel.sectionItemCount = 1;
                self.siftSectionModel = sectionModel;
            }
                break;
                
            case ZFGeshopGridGoodsCellType:     // 103: 商品组件
            {
                CGFloat lineSpacing = 9;
                sectionModel.sectionItemCount = sectionModel.component_data.list.count;
                sectionModel.sectionMinimumInteritemSpacing = lineSpacing;
                sectionModel.sectionMinimumLineSpacing = 9;
                
                // box_is_whole= 1显示整体样式，0显示单个样式
                BOOL isWholeStyle = (sectionModel.component_style.box_is_whole == 1);
                CGFloat ratio = isWholeStyle ? 2.0 : 1.0;
                CGFloat percent = isWholeStyle ? (159 / 293.0) : (171 / 309.0);
                CGFloat itemWidth = (KScreenWidth - (24 * ratio + lineSpacing)) / 2.0;
                CGFloat itemHeight = itemWidth / percent;
                if (KScreenHeight <= 568) {
                    itemHeight += 18;//兼容在iphone上显示
                }
                sectionModel.sectionItemSize = CGSizeMake(itemWidth, itemHeight);
                sectionModel.sectionInsetForSection = UIEdgeInsetsMake(12 * ratio + margin_top, 12 * ratio, 12 * ratio + margin_bottom, 12 * ratio);
            }
                break;
                
            case ZFGeshopSecKillSuperCellType:    // 105: 商品秒杀组件
            {
                sectionModel.sectionItemCount = (sectionModel.component_data.list.count > 0) ? 1 : 0;
                sectionModel.sectionMinimumInteritemSpacing = 0;
                sectionModel.sectionMinimumLineSpacing = 0;
                sectionModel.sectionItemSize = CGSizeMake(KScreenWidth, 401);
                sectionModel.sectionInsetForSection = UIEdgeInsetsZero;

                //每次更新历史记录要滚到第一个位置 (-1标识阿语后最后一个)
                sectionModel.sliderScrollViewOffsetX = [SystemConfigUtils isRightToLeftShow] ? -1 : 0.0;
                
                long start_time = [sectionModel.component_data.tsk_begin_time longLongValue];
                long end_time = [sectionModel.component_data.tsk_end_time longLongValue];
                
                NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
                long currentStamp = [dat timeIntervalSince1970];

                //  0:默认 1:还未开始 2:已经开始 3:已经结束
                NSString *countdown_time = nil;
                if (currentStamp < start_time) { //开没开始
                    countdown_time = [NSString stringWithFormat:@"%ld", start_time - currentStamp];
                    sectionModel.component_data.countDownStatus = 1;
                    
                } else if (currentStamp > start_time && currentStamp < end_time) { //已经开始
                    countdown_time = [NSString stringWithFormat:@"%ld", end_time - currentStamp];
                    sectionModel.component_data.countDownStatus = 2;
                    
                } else { //已经过期
                    countdown_time = [NSString stringWithFormat:@"%d", 0];
                    sectionModel.component_data.countDownStatus = 3;
                }
                
                if (!ZFIsEmptyString(countdown_time)) {
                    if (!self.timerKeyArray) {
                        self.timerKeyArray = [NSMutableArray array];
                    }
                    sectionModel.component_data.countdown_time = countdown_time;
                     NSString *countDownTimerKey = [NSString stringWithFormat:@"ZFGeshopModel-%@",sectionModel.component_id];
                    sectionModel.component_data.geshopCountDownTimerKey = countDownTimerKey;
                    
                    [self.timerKeyArray addObject:countDownTimerKey];
                    /// 先开启倒计时
                    [[ZFTimerManager shareInstance] startTimer:countDownTimerKey];
                }
            }
                break;
            default:
                break;
        }
    }
    NSMutableArray *navListModelArray = [NSMutableArray array];
    for (ZFGeshopSectionModel *sectionModel in configModelArray) {
        if (![navigationItemIdArray containsObject:sectionModel.component_id])continue;
        if (sectionModel.isMultipartNavigation) break;
        
        for (ZFGeshopSectionListModel *listModel in navigationModel.component_data.list) {
            if ([sectionModel.component_id isEqualToString:listModel.component_id]) {
                [navListModelArray addObject:listModel];
                break;
            }
        }
    }
    for (ZFGeshopSectionModel *sectionModel in configModelArray) {
        if (sectionModel.isMultipartNavigation) break;
        if (sectionModel.component_type == ZFGeshopNavigationCellType) {
            sectionModel.component_data.list = navListModelArray;
        }
    }
    return configModelArray;
}

- (Class)fetchCellClass:(ZFGeshopCellType)component_type {
    NSArray *cellInfoArray = [ZFGeshopSectionModel fetchGeshopAllCellTypeArray];
    for (NSDictionary *infoDict in cellInfoArray) {
        if ([infoDict.allKeys.firstObject integerValue] == component_type) {
            return infoDict.allValues.firstObject;
        }
    }
    return [UICollectionViewCell class];
}

- (id)fetchCellBlock:(ZFGeshopCellType)component_type {
    for (NSDictionary *blockDict in self.listViewCellBlockArray) {
        if (![blockDict isKindOfClass:[NSDictionary class]]) continue;
        if ([blockDict.allKeys.firstObject integerValue] == component_type) {
            return blockDict.allValues.firstObject;
        }
    }
    return nil;
}

@end
