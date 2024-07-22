//
//  ZFHomeManager.m
//  ZZZZZ
//
//  Created by YW on 23/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFHomeManager.h"
#import "ZFProgressHUD.h"
#import "YWCFunctionTool.h"
#import "ZFCommonRequestManager.h"
#import "ZFNetworkManager.h"
#import "AccountManager.h"
#import "Constants.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFBannerModel.h"
#import "ZFApiDefiner.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFGrowingIOAnalytics.h"

@implementation ZFHomeManager

/**
 * 监听主页无网络提示弹框
 */
+ (void)showNoNetWorkError:(UIView *)view offset:(CGFloat)offset{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![ZFNetworkManager isReachable]) {
            ShowNetworkErrorTipToView(view,offset);
        }
        
        [ZFNetworkManager reachabilityChangeBlock:^(AFNetworkReachabilityStatus currentStatus, AFNetworkReachabilityStatus beforeStatus) {
            YWLog(@"网络已发生变化===%zd===%zd",beforeStatus, currentStatus);
            if (currentStatus == AFNetworkReachabilityStatusNotReachable) {
                ShowNetworkErrorTipToView(view,offset);
            } else {
                HideNetworkErrorTipToView(view);
            }
            
            //启动App时无网络, 后来有了网络, 此时应该请求必要接口
            if (beforeStatus == AFNetworkReachabilityStatusNotReachable) {
                if (currentStatus == AFNetworkReachabilityStatusReachableViaWWAN ||
                    currentStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
                    YWLog(@"网络由无网络变为有网络时,请求必要接口数据");
                    [ZFCommonRequestManager requestNecessaryData];
                    
                    // 请求cod接口
                    [ZFCommonRequestManager requestCurrencyData];
                    
                    // 启动后判断是否检查过强制更新
                    if ([AccountManager sharedManager].hasRequestUpgradeAppUrl == NO) {                        
                        [ZFCommonRequestManager checkUpgradeZFApp:nil];
                    }
                }
            }
        }];
    });
}

/**
 * 加载浮窗banner按钮UI
 */
+ (void)requestBottomFloatBanner:(void (^)(ZFBannerModel *bannerModel))completion {
    
    [ZFCommonRequestManager requestCMSAppAdvertsWithTpye:(ZFCMSAppAdvertsType_HomeSmallFloating) otherId:nil completion:^(NSDictionary *responseObject) {
        NSArray *resultArray = responseObject[ZFDataKey];
        if (!ZFJudgeNSArray(resultArray)) return;
        
        NSDictionary *resultDic = [resultArray firstObject];
        if(!ZFJudgeNSDictionary(resultDic)) return;
        NSArray *listArray = [resultDic ds_arrayForKey:@"list"];
        
        NSDictionary *bannerDict = [listArray firstObject];
        if (!ZFJudgeNSDictionary(bannerDict)) return;
        
        ZFBannerModel *bannerModel = [[ZFBannerModel alloc] init];
        bannerModel.image = [bannerDict ds_stringForKey:@"img"];
        bannerModel.name = [bannerDict ds_stringForKey:@"name"];
        bannerModel.colid = [bannerDict ds_stringForKey:@"colId"];
        bannerModel.componentId = [bannerDict ds_stringForKey:@"componentId"];
        bannerModel.banner_id = [bannerDict ds_stringForKey:@"advertsId"];
        bannerModel.menuid = [bannerDict ds_stringForKey:@"menuId"];
        NSString *actionType = [bannerDict ds_stringForKey:@"actionType"];
        NSString *url = [bannerDict ds_stringForKey:@"url"];
        
        //如果actionType=-2,则特殊处理自定义完整ddeplink
        if (actionType.integerValue == -2) {
            bannerModel.deeplink_uri = ZFToString(ZFEscapeString(url, YES));
        } else {
            bannerModel.deeplink_uri = [NSString stringWithFormat:ZFCMSConvertDeepLinkString, actionType, url, bannerModel.name];;
        }
        if (completion) {
            completion(bannerModel);
        }
        
        //增加AppsFlyer统计
        NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                          @"af_banner_name" : ZFToString(bannerDict[@"name"]), //banenr名，如叫拼团
                                          @"af_channel_name" : ZFToString(bannerDict[@"menuId"]), //菜单id，如Homepage / NEW TO SALE
                                          @"af_ad_id" : ZFToString(bannerDict[@"advertsId"]), //banenr id，数据来源于后台配置返回的id
                                          @"af_component_id" : ZFToString(bannerDict[@"componentId"]),//组件id，数据来源于后台返回的组件id
                                          @"af_col_id" : ZFToString(bannerDict[@"colId"]), //坑位id，数据来源于后台返回的坑位id
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type) //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_impression" withValues:appsflyerParams];
        
//        [ZFGrowingIOAnalytics ZFGrowingIOActivityImpByCMS:bannerModel];
        [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithBannerModel:bannerModel page:GIOSourceHomeSmallFloat];
    } target:nil];
}

@end
