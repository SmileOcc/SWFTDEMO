
//
//  ZFNativeBannerViewModel.m
//  ZZZZZ
//
//  Created by YW on 25/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFNativeBannerViewModel.h"
#import "ZFNativeBannerListModel.h"
#import "ZFNativeNavgationGoodsModel.h"
#import "ZFNativeBannerBaseLayout.h"
#import "ZFBannerModel.h"
#import "ZFNativeBannerModel.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFTimerManager.h"
#import "YWLocalHostManager.h"
#import "NSArray+SafeAccess.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"

@interface ZFNativeBannerViewModel()
@property (nonatomic, strong) ZFNativeBannerResultModel                         *dataModel;
@property (nonatomic, strong) ZFNativeNavgationGoodsModel                       *goodsModel;
@property (nonatomic, strong) NSMutableArray <ZFNativeBannerBaseLayout *>       *sections;
@property (nonatomic, strong) NSMutableArray <ZFGoodsModel *>                   *goodsArray;
@end

@implementation ZFNativeBannerViewModel
#pragma mark - Public Methods
- (void)requestNativeBannerDataWithSpecialId:(NSString *)specialId
                                  completion:(void (^)(ZFNativeBannerResultModel *bannerModel,BOOL isSuccess))completion {
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_NativeBanner);
    requestModel.parmaters = @{
                               @"specialId": ZFToString(specialId),
                               @"user_id"  : USERID
                               };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        self.dataModel = [ZFNativeBannerResultModel yy_modelWithJSON:responseObject[ZFResultKey]];
        
        if (!self.dataModel ||
            (self.dataModel.plateGoodsArray.count == 0 &&
             self.dataModel.bannerList.count == 0)) {
            if (completion) {
                completion(nil,NO);
            }
            return;
        }
        
        if (self.dataModel.plateGoodsArray.count > 0) {
            // Groing IO
            [self addAnalysicsNativePlateGoods:self.dataModel.plateGoodsArray];
        }
        [self.sections removeAllObjects];
        
        if (self.dataModel.bannerList.count > 0) {
            [self.dataModel.bannerList enumerateObjectsUsingBlock:^(ZFNativeBannerListModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
                // 添加多分馆
                [self addBranchSectionWithModel:model index:idx];
                // 添加滑动banner
                [self addSlideSectionWithModel:model];
            }];
        }
        if (completion) {
            completion(self.dataModel,YES);
        }
        
    } failure:^(NSError *error) {
        if (completion) {
            completion(nil,NO);
        }
    }];
}

- (void)requestBannerGoodsListData:(BOOL)firstPage
                             navId:(NSString *)navId
                         specialId:(NSString *)specialId
                        completion:(void (^)(ZFNativeNavgationGoodsModel *model,NSArray *currentPageArray,NSDictionary *pageInfo))completion
{
     NSInteger currentPage = firstPage ? 1 : ++self.goodsModel.curPage;
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_NativeBannerGoodsList);
    requestModel.parmaters = @{
                               @"specialId": ZFToString(specialId),
                               @"navId"    : ZFToString(navId),
                               @"page"     : @(currentPage),
                               @"pageSize" : @(15)
                               };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        self.goodsModel = [ZFNativeNavgationGoodsModel yy_modelWithJSON:responseObject[ZFResultKey]];
        NSArray *currentPageArray = self.goodsModel.goodsList;
        if (self.goodsModel && currentPageArray.count > 0) {
            if (firstPage) {
                self.goodsArray = [NSMutableArray arrayWithArray:currentPageArray];
            } else {
                [self.goodsArray addObjectsFromArray:currentPageArray];
            }
            self.goodsModel.goodsList = self.goodsArray;
        }
        
        //occ v3.7.0hacker 添加 ok
        if (currentPageArray.count > 0) {
            [self addAnalysicsNativeGoods:currentPageArray];
        }
        if (completion) {
            NSDictionary *pageInfo = @{ kTotalPageKey  : @(self.goodsModel.totalPage),
                                        kCurrentPageKey: @(self.goodsModel.curPage) };
            completion(self.goodsModel,currentPageArray,pageInfo);
        }
    } failure:^(NSError *error) {
        if (!firstPage) (-- self.goodsModel.curPage);
        if (completion) {
            completion(self.goodsModel,nil,nil);
        }
    }];
}

- (NSMutableArray<ZFNativeBannerBaseLayout *> *)queryLayoutSections {
    return self.sections;
}

- (CGSize)itemSizeAtIndexPath:(NSIndexPath *)indexPath {
    ZFNativeBannerBaseLayout *sectionLayout = self.sections[indexPath.section];
    switch (sectionLayout.type) {
        case ZFNativeBannerTypeBranch:
        case ZFNativeBannerTypeVideo:
        {
            ZFNativeBannerBranchLayout *branchLayout = (ZFNativeBannerBranchLayout *)sectionLayout;
            return [branchLayout itemSizeAtRowIndex:indexPath.item];
        }
            break;
        case ZFNativeBannerTypeSKUBanner:
        {
            ZFNativeBannerSKUBannerLayout *skuBannerLayout = (ZFNativeBannerSKUBannerLayout *)sectionLayout;
            return skuBannerLayout.itemSize;
        }
            break;
            
        case ZFNativeBannerTypeSlide:
        {
            ZFNativeBannerSlideLayout *slideLayout= (ZFNativeBannerSlideLayout *)sectionLayout;
            return slideLayout.itemSize;
        }
            break;
        default:{
            return CGSizeZero;
        }
            break;
    }
}

#pragma mark - Private method
- (void)addSlideSectionWithModel:(ZFNativeBannerListModel *)model {
    if (model.bannerType == ZFNativeBannerTypeSlide) {
        if (model.bannerList.count == 0)  return;
        ZFNativeBannerSlideLayout *slideItemSection = [[ZFNativeBannerSlideLayout alloc] init];
        slideItemSection.slideArray = model.bannerList;
        [self.sections addObject:slideItemSection];
    }
}

- (void)addBranchSectionWithModel:(ZFNativeBannerListModel *)model index:(NSUInteger)index  {
    
    if (model.bannerType == ZFNativeBannerTypeSlide ||
        model.bannerType == ZFNativeBannerTypeGoodsList) {
        return;
    }
    
    index = index + (self.sections.count - 1);

    if (model.bannerList.count == 0) return;
    NSInteger branch = model.bannerList.count; // 数组个数代表分馆数
    ZFNativeBannerBranchLayout *branchItemSection = [[ZFNativeBannerBranchLayout alloc] init];
    
    if (model.bannerType == ZFNativeBannerTypeVideo) { //视频
        for (ZFNativeBannerModel *bannerModel in model.bannerList) {
            bannerModel.bannerType = ZFBannerTypeVideo;
        }
    }
    branchItemSection.banners = model.bannerList;
    branchItemSection.branch  = branch;
    [self.sections addObject:branchItemSection];
    
    // 这里的一分馆判断是否需要开启定时器
    if (branchItemSection.branch == 1) {
        NSInteger index = 0;
        for (ZFNativeBannerModel *branchBannerModel in branchItemSection.banners) {
            index++;
            if (!ZFIsEmptyString(branchBannerModel.bannerCountDown) &&
                [branchBannerModel.countdownShow boolValue]) {
                NSString *timerKey = [NSString stringWithFormat:@"ZFNativeBannerModel-%ld-%@",(long)index , branchBannerModel.bannerImg];
                branchBannerModel.nativeCountDownTimerKey = timerKey;
                [[ZFTimerManager shareInstance] startTimer:timerKey];
            }
        }
    }
    
    //GrowingIO 原生专题活动统计
    [model.bannerList enumerateObjectsUsingBlock:^(ZFNativeBannerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.bannerType == ZFBannerTypeCoupon) {
            ///优惠券要统计 growingIO
            [ZFGrowingIOAnalytics ZFGrowingIOCouponShow:obj.bannerName page:@"NativeCouponPage"];
        }else{
//            NSString *position = [NSString stringWithFormat:@"%ld", idx];
//            NSString *floor = [NSString stringWithFormat:@"impression_channel_banner_branch%ld_%@_%@", branch, position, model.bannerName];
//            [ZFGrowingIOAnalytics ZFGrowingIOActivityImp:model.bannerName floor:floor position:position page:@"原生专题"];
        }
    }];
 
    // 添加skuBanner
    if (model.skuArrays.count == 0) return;
    ZFNativeBannerSKUBannerLayout *skuBannerSection = [[ZFNativeBannerSKUBannerLayout alloc] init];
    skuBannerSection.goodsArray = model.skuArrays;
    
    ZFNativeBannerModel *bannerModel = [model.bannerList objectWithIndex:0];
    ZFBannerModel *tempModel = [[ZFBannerModel alloc] init];
    tempModel.deeplink_uri = bannerModel.deeplinkUri;
    skuBannerSection.bannerModel = tempModel;
    
    [self.sections addObject:skuBannerSection];
    /// sku + banner 统计
    //  impression_thematic_banner_bannerModel.name_1022012 (原生专题)
    NSString *GAName = @"impression_thematic_banner";
    [model.skuArrays enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *GASKUName = [NSString stringWithFormat:@"%@_%@_%@",GAName, bannerModel.bannerName, obj.goods_sn];
        [ZFAnalytics showAdvertisementWithBanners:@[@{@"name" : GASKUName}] position:@"1" screenName:@"NativeSkuBanner"];
//        obj.nativeBannerName = GASKUName;
//        NSString *position = [NSString stringWithFormat:@"%ld", idx];
//        [ZFGrowingIOAnalytics ZFGrowingIOActivityImp:GASKUName floor:GASKUName position:position page:@"原生专题"];
    }];
}

- (void)addAnalysicsNativePlateGoods:(NSArray <ZFNativePlateGoodsModel *>*)array {
//    for (ZFNativePlateGoodsModel *plateModel in array) {
//        [ZFAppsflyerAnalytics trackGoodsList:plateModel.goodsArray inSourceType:ZFAppsflyerInSourceTypePromotion sourceID:self.dataModel.infoModel.specialTitle];
//        if (plateModel.goodsArray.count <= 0) return;
        NSString *impression = [NSString stringWithFormat:@"%@_%@",ZFGANativeList, self.dataModel.infoModel.specialTitle];
        NSString *screenName = [NSString stringWithFormat:@"native_%@", self.dataModel.infoModel.specialTitle];
//        [ZFAnalytics showProductsWithProducts:plateModel.goodsArray position:1 impressionList:impression screenName:screenName event:@"load"];
//
//        //occ v3.7.0hacker 添加 ok
        self.analyticsProduceImpressionSpecial = [ZFAnalyticsProduceImpression initAnalyticsProducePosition:1
                                                                                      impressionList:impression
                                                                                          screenName:screenName
                                                                                               event:@"load"];
//
//        [plateModel.goodsArray enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSString *pageName = [NSString stringWithFormat:@"GIO_NativeList_%@", self.dataModel.infoModel.specialTitle];
//            [ZFGrowingIOAnalytics ZFGrowingIOProductShow:obj page:pageName];
//        }];
//    }
}

- (void)addAnalysicsNativeGoods:(NSArray <ZFGoodsModel *>*)array {

//    [ZFAppsflyerAnalytics trackGoodsList:array inSourceType:ZFAppsflyerInSourceTypePromotion sourceID:self.dataModel.infoModel.specialTitle];
    if (array.count <= 0) return;
    NSString *impression = [NSString stringWithFormat:@"%@_%@",ZFGANativeList, self.dataModel.infoModel.specialTitle];
    NSString *screenName = [NSString stringWithFormat:@"native_%@", self.dataModel.infoModel.specialTitle];
//    [ZFAnalytics showProductsWithProducts:array position:1 impressionList:impression screenName:screenName event:@"load"];
    
    //occ v3.7.0hacker 添加 ok
    self.analyticsProduceImpressionGoodsList = [ZFAnalyticsProduceImpression initAnalyticsProducePosition:1
                                                                                  impressionList:impression
                                                                                      screenName:screenName
                                                                                           event:@"load"];
}

- (void)getCouponWithCouponId:(NSString*)coupon_center_id
                   completion:(void (^)(id obj))completion
{
    ///growingIO 点击优惠券
    [ZFGrowingIOAnalytics ZFGrowingIOCouponClick:coupon_center_id page:@"NativeCouponPage"];
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_NativeBannerGetCoupon);
    requestModel.parmaters = @{
                               @"coupon_center_id":ZFToString(coupon_center_id)
                               };
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSString *code = ZFToString(responseObject[ZFResultKey][@"code"]);
        
        if ([code isEqualToString:@"0"]) {
            ShowToastToViewWithText(nil,ZFLocalizedString(@"My_Coupon_Get_Coupon_Success", nil));
            if (completion) {
                completion(nil);
            }
            [ZFGrowingIOAnalytics ZFGrowingIOCouponGetSuccess:coupon_center_id page:@"NativeCouponPage"];
        } else if ([code isEqualToString:@"-2"]) {
            ShowToastToViewWithText(nil,ZFLocalizedString(@"My_Coupon_Alread_Get_Coupon", nil));
        } else if ([code isEqualToString:@"-3"]) {
            ShowToastToViewWithText(nil,ZFLocalizedString(@"My_Coupon_Have_Been_Claimed", nil));
        } else {
            ShowToastToViewWithText(nil,ZFLocalizedString(@"My_Coupon_Get_Coupon_False", nil));
        }
    } failure:^(NSError *error) {
        ShowToastToViewWithText(nil,ZFLocalizedString(@"My_Coupon_Get_Coupon_False", nil));
    }];
}

#pragma mark - Getter
- (NSMutableArray<ZFNativeBannerBaseLayout *> *)sections {
    if (!_sections) {
        _sections = [NSMutableArray array];
    }
    return _sections;
}

@end

