//
//  ZFAccountTableDataViewAop.m
//  ZZZZZ
//
//  Created by YW on 2019/11/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountTableDataViewAop.h"
#import "YWCFunctionTool.h"
#import "ZFProductCCell.h"
#import "ZFAccountBannerCCell.h"
#import "ZFAccountCategoryCCell.h"
#import "ZFAccountDetailTextCCell.h"

#import "ZFGrowingIOAnalytics.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalytics.h"

#import "AccountManager.h"
#import "ZFGoodsModel.h"

#import "ZFAccountCMSBannerCell.h"
#import "ZFAccountUnpaidOrderCell.h"
#import "ZFAccountHeaderCellTypeModel.h"
#import "ZFAccountCategorySectionModel.h"

@interface ZFAccountTableDataViewAop ()
@property (nonatomic, strong) NSMutableArray *analyticsSet;
@property (nonatomic, weak) UIViewController *currentController;
@property (nonatomic, copy) NSString *af_recommend_name;
@property (nonatomic, assign) ZFAppsflyerInSourceType sourceType;
@property (nonatomic, copy) NSString *af_first_entrance;
@end

@implementation ZFAccountTableDataViewAop

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.analyticsSet = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)gainCurrentAopClass:(id)currentAopClass
{
    self.currentController = currentAopClass;
    
    if ([NSStringFromClass(self.currentController.class) isEqualToString:@"ZFAccountTableDataView"]) {
        
    }
}

- (void)after_setRefreshRecommendFirstPage
{
    [self.analyticsSet removeAllObjects];
}

- (void)after_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ZFAccountCMSBannerCell class]]) {
        ///统计展示CMS Banner
        ZFAccountCMSBannerCell *bannerCell = (ZFAccountCMSBannerCell *)cell;
        
        //增加AppsFlyer统计
        [bannerCell.cellTypeModel.cmsBannersModelArray enumerateObjectsUsingBlock:^(ZFNewBannerModel *newBannerModel, NSUInteger idx1, BOOL * _Nonnull stop1) {
            
            [newBannerModel.banners enumerateObjectsUsingBlock:^(ZFBannerModel *bannerModel, NSUInteger idx2, BOOL * _Nonnull stop2) {
                
                if ([bannerModel isKindOfClass:[ZFBannerModel class]]) {
                    if ([self.analyticsSet containsObject:ZFToString(bannerModel.name)]) {
                        return;
                    }
                    [self.analyticsSet addObject:ZFToString(bannerModel.name)];
                    NSDictionary *appsflyerParams = @{
                        @"af_content_type" : @"banner impression",  //固定值 banner impression
                        @"af_banner_name" : ZFToString(bannerModel.name), //banenr名，如叫拼团
                        @"af_channel_name" : ZFToString(bannerModel.menuid), //菜单id，如Homepage / NEW TO SALE
                        @"af_ad_id" : ZFToString(bannerModel.banner_id), //banenr id，数据来源于后台配置返回的id
                        @"af_component_id" : ZFToString(bannerModel.componentId),//组件id，数据来源于后台返回的组件id
                        @"af_col_id" : ZFToString(bannerModel.colid), //坑位id，数据来源于后台返回的坑位id
                        @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type)
                    };
                    [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_impression" withValues:appsflyerParams];
                    // [ZFGrowingIOAnalytics ZFGrowingIOActivityImpByCMS:bannerModel];
                    [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithBannerModel:bannerModel page:GIOSourceAccount];
                }
            }];
        }];
        
    } else if ([cell isKindOfClass:[ZFAccountUnpaidOrderCell class]]) {
        // 曝光未支付订单
        ZFAccountUnpaidOrderCell *bannerCell = (ZFAccountUnpaidOrderCell *)cell;
        
        MyOrdersModel *unpaidOrderModel = bannerCell.cellTypeModel.unpaidOrderModel;
        if (![unpaidOrderModel isKindOfClass:[MyOrdersModel class]]) return;
        if ([self.analyticsSet containsObject:ZFToString(unpaidOrderModel.order_id)])return;
        
        NSDictionary *appsflyerParams = @{
            @"af_content_type" : @"ordernotpay",
            @"af_reciept_id" : ZFToString(unpaidOrderModel.order_id),
            @"af_price" : ZFToString(unpaidOrderModel.total_fee),
        };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_ordernotpay_impression" withValues:appsflyerParams];
    }
}

-(NSDictionary *)injectMenthodParams
{
    NSDictionary *params = @{
        NSStringFromSelector(@selector(tableView:willDisplayCell:forRowAtIndexPath:)) : NSStringFromSelector(@selector(after_tableView:willDisplayCell:forRowAtIndexPath:)),
        
        @"setRefreshRecommendFirstPage" : @"after_setRefreshRecommendFirstPage"
    };
    return params;
}

@end
