 //
//  OSSVAdvsEventsManager.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAdvsEventsManager.h"
#import "STLAdvEventModel.h"
#import "OSSVDetailsVC.h"
#import "OSSVSearchResultVC.h"
#import "STLActivityWWebCtrl.h"
#import "OSSVCategorysListVC.h"
#import "AppDelegate+STLCategory.h"
#import "H5ShareModel.h"
#import "OSSVAccountOrdersPageVC.h"
#import "OSSVAccountsOrderDetailVC.h"
#import "OOSVAccountVC.h"
//#import "STLAccountCtrl.h"
#import "SignViewController.h"
#import "OSSVWMCouponVC.h"
#import "OSSVWishListVC.h"
#import "OSSVCartVC.h"
#import "RateModel.h"
#import "OSSWMHomeVC.h"
#import "OSSVAppNewThemeVC.h"
#import "OSSVCategorysVirtualListVC.h"
#import "OSSVCategorysNewZeroListVC.h"
#import "OSSVFlashSaleMainVC.h"
#import "OSSVDiscoverBlocksModel.h"
#import "OSSVSearchVC.h"
#import "OSSVFeedbackReplayVC.h"
#import "Adorawe-Swift.h"

@implementation OSSVAdvsEventsManager

+(OSSVAdvsEventsManager*)sharedManager
{
    static OSSVAdvsEventsManager *sharedInstance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OSSVAdvsEventsManager alloc] init];
    });
    return sharedInstance;
}

+ (void)advEventTarget:(id)target withEventModel:(STLAdvEventModel *)advEventModel {
    AdvEventType actionType = advEventModel.actionType;
    if (actionType == AdvEventTypeNOEvent || !target) {
        return;
    }
    NSString *url = advEventModel.url;
    NSString *name = advEventModel.name;
    NSString *webtype = advEventModel.webtype;
    
    UIViewController *targetVC = target;
    
    [AccountManager testLaunchMessage:[NSString stringWithFormat:@"advEventTarget:%@ url:%@,hasNav:%@",NSStringFromClass(targetVC.class),url,targetVC.navigationController ? @"1" : @"0"]];
    if (!STLIsEmptyString(url) && [url hasPrefix:[OSSVLocaslHosstManager appDeeplinkPrefix]]) {
        NSMutableDictionary *md = [OSSVAdvsEventsManager parseDeeplinkParamDicWithURL:[NSURL URLWithString:url]];
        if ([md[@"actiontype"] integerValue] > 0) {            
            actionType = [md[@"actiontype"] integerValue];
            url        = REMOVE_URLENCODING(STLToString(md[@"url"]));
            name       = REMOVE_URLENCODING(STLToString(md[@"name"]));
            webtype       = REMOVE_URLENCODING(STLToString(md[@"webtype"]));
        }
    }
    
    /* 
     * actionType;
     * 0.默认备注(后台没有返回); 1.频道(首页); 2.分类页; 3.商品详情页; 4.搜索(结果列表); 5.嵌入H5页面; 6.买家秀; 7.外部链接; 8.店铺; 9.订单详情; 10.Coupon页; 11.购物车; 12.收藏列表
     * Adorawe://action?actiontype=1&url=1,1&name=women&source=banner
     */

    switch (actionType) {
        case AdvEventTypeDefault:
        {
            OSSVTabBarVC *tabbar = (OSSVTabBarVC *)targetVC.tabBarController;

            [tabbar setModel:STLMainMoudleHome];
            OSSVNavigationVC *nav = [tabbar navigationControllerWithMoudle:STLMainMoudleHome];
            if (nav) {
                if (nav.viewControllers.count>1) {
                    [nav popToRootViewControllerAnimated:NO];
                }
            }
        }
            break;
        case AdvEventTypeHomeChannel:
        {
            OSSVTabBarVC *tabbar = (OSSVTabBarVC *)targetVC.tabBarController;
            
            if ([tabbar presentedViewController]) {
                [tabbar dismissViewControllerAnimated:NO completion:nil];
            }
            
            if(targetVC.navigationController.childViewControllers.count > 1){
                [targetVC.navigationController popToRootViewControllerAnimated:NO];
            }

            [tabbar setModel:STLMainMoudleHome];

        }
            break;
        case AdvEventTypeCategory:
        {
            NSString *cat_id = nil;
            NSString *deepLinkId = nil;
            NSString *is_new_in = nil;
            if ([url containsString:@","]) {
                NSArray *urlArray = [url componentsSeparatedByString:@","];
                cat_id = urlArray[0];
                deepLinkId = urlArray[1];
                if (urlArray.count > 2) {
                    is_new_in =  urlArray[2];
                }
            }else{
                cat_id = url;
            }
            if (cat_id.length == 0 || [cat_id intValue] == 0) { // 有cateId则跳到分类，无没cateId刚跳分类首页
                OSSVTabBarVC *tabbar = (OSSVTabBarVC *)targetVC.tabBarController;
                [tabbar setModel:STLMainMoudleCategory];
                OSSVNavigationVC *nav = [tabbar navigationControllerWithMoudle:STLMainMoudleCategory];
                if (nav) {
                    if (nav.viewControllers.count>1) {
                        [nav popToRootViewControllerAnimated:NO];
                    }
                }
            } else {
                OSSVCategorysListVC *categoriesVC = [OSSVCategorysListVC new];
                categoriesVC.childId = cat_id;
                categoriesVC.deepLinkId = deepLinkId;
                categoriesVC.childDetailTitle = name;
                categoriesVC.is_new_in = is_new_in;
                [targetVC.navigationController pushViewController:categoriesVC animated:YES];
            }
        }
            break;
        case AdvEventTypeGoodDetail:
        {
            NSArray *goodsInfo = [url componentsSeparatedByString:@","];
            if (goodsInfo.count > 1) {
                OSSVDetailsVC *goodsDetailVC = [[OSSVDetailsVC alloc] init];
                goodsDetailVC.goodsId = goodsInfo[0];
                goodsDetailVC.wid = goodsInfo[1];
                NSString *actionStr = STLToString(advEventModel.webtype);
                
                //在此判断，如果来自热搜，设置来源类型为热搜
                if ([targetVC isKindOfClass:[OSSVSearchVC class]]) {
                    goodsDetailVC.sourceType = STLAppsflyerGoodsSourceHotSearch;
                }
                
                NSDictionary *dic = @{kAnalyticsRequestId:STLToString(advEventModel.request_id),kAnalyticsAction:actionStr};
                [goodsDetailVC.transmitMutDic addEntriesFromDictionary:dic];
                [targetVC.navigationController pushViewController:goodsDetailVC animated:YES];
            }
        }
            break;
        case AdvEventTypeSearch:
        {
           
            OSSVSearchResultVC *searchResultVC = [[OSSVSearchResultVC alloc] init];
            
            if ([url containsString:@","]) {
                NSArray *urlArray = [url componentsSeparatedByString:@","];
                searchResultVC.keyword = urlArray[0];
                searchResultVC.deepLinkId = urlArray[1];
            }else{
                searchResultVC.keyword = url;
            }
            searchResultVC.title = name;
            searchResultVC.keyWordType = STLToString(advEventModel.keyCotent);
            searchResultVC.sourceDeeplinkUrl = STLToString(advEventModel.sourceDeeplinkUrl);
            [targetVC.navigationController pushViewController:searchResultVC animated:YES];

        }
            break;
        case AdvEventTypeInsertH5: // embedPage 嵌入H5
        {
            RateModel *rate = [ExchangeManager localCurrency];
            STLActivityWWebCtrl *webVC = [[STLActivityWWebCtrl alloc] init];
            
            NSString *version = kAppVersion;
            NSString *lang = [STLLocalizationString shareLocalizable].nomarLocalizable;
            NSString *platform = @"ios";
            NSString *device = STLToString([AccountManager sharedManager].device_id);
            //应该不需要的
            NSString *channel = @"";//STLToString([AccountManager sharedManager].shareChannelSource);
            
            NSString *userToken = AccountManager.sharedManager.isSignIn ? STLToString(USER_TOKEN) : @"";
            if ([url rangeOfString:@"?"].location != NSNotFound) {
                 if ([AccountManager sharedManager].isSignIn) {
                    url = [NSString stringWithFormat:@"%@&token=%@&currency=%@&lang=%@&version=%@&platform=%@&device_id=%@&channel=%@",url,userToken,rate.code,lang,version,platform,device,channel];
                } else {
                    url = [NSString stringWithFormat:@"%@&currency=%@&lang=%@&version=%@&platform=%@&device_id=%@&channel=%@",url, rate.code,lang,version,platform,device,channel];

                }
            }else{
                if ([AccountManager sharedManager].isSignIn) {
                    url = [NSString stringWithFormat:@"%@?token=%@&currency=%@&lang=%@&version=%@&platform=%@&device_id=%@&channel=%@",url,userToken, rate.code,lang,version,platform,device,channel];
                } else {
                    url = [NSString stringWithFormat:@"%@?currency=%@&lang=%@&version=%@&platform=%@&device_id=%@&channel=%@",url, rate.code,lang,version,platform,device,channel];
                }
            }
            webVC.strUrl = url;
            H5ShareModel *model = [[H5ShareModel alloc] init];
            model.isShare = advEventModel.isShare;
            model.shareImageURL = advEventModel.shareImageURL;
            model.shareLinkURL = advEventModel.shareLinkURL;
            model.shareTitle = advEventModel.shareTitle;
            model.shareContent = advEventModel.shareDoc;
            webVC.model = model;
            [targetVC.navigationController pushViewController:webVC animated:YES];
            NSLog(@"跳转的URL链接 === %@", url);

        }
            break;
        case AdvEventTypeBuyShow:
        {//买家秀
        }
            break;
        case AdvEventTypeExternalLink: // 外部链接
        {
            STLLog(@"📌Open Link📌 : %@",REMOVE_URLENCODING((url)));
            [SHAREDAPP openURL:[NSURL URLWithString:REMOVE_URLENCODING(url)] options:@{} completionHandler:nil];
        }
            break;
        case AdvEventTypeStoreList:
        {
            
        }
            break;
        case AdvEventTypeOrderDetail:
        {
            if (USERID) {
                if (advEventModel.country_site.length > 0) {
                    if (![STLWebsitesGroupManager.currentCountrySiteCode.lowercaseString isEqualToString:advEventModel.country_site.lowercaseString]) {
//                    if (true) {//测试代码
                        [STLAlertViewNew showAlertWithFrame:[UIScreen mainScreen].bounds alertType:STLAlertTypeButtonColumn isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:STLLocalizedString_(@"ip_alert_title", nil) message:STLLocalizedString_(@"ip_alert_content", nil) buttonTitles:@[STLLocalizedString_(@"ip_alert_ok", nil)] buttonBlock:^(NSInteger index , NSString * _Nonnull title) {
                                   
                               } closeBlock:^{
                                   
                               }];
                        break;
                    }
                }
                // 有订单id就跳转到订单详情，无则跳转至订单列表
                OSSVTabBarVC *tabbar = (OSSVTabBarVC *)targetVC.tabBarController;

                [tabbar setModel:STLMainMoudleAccount];
                OSSVNavigationVC *nav = [tabbar navigationControllerWithMoudle:STLMainMoudleAccount];
                if (nav) {
                    if (nav.viewControllers.count>1) {
                        [nav popToRootViewControllerAnimated:NO];
                    }
                }
                OOSVAccountVC *accountVC = nav.viewControllers[0];
                OSSVAccountOrdersPageVC *orderListVC = [[OSSVAccountOrdersPageVC alloc] init];
                [accountVC.navigationController pushViewController:orderListVC animated:NO];
                if (![NSStringTool isEmptyString:url]) {
                    OSSVAccountsOrderDetailVC *orderDetailVC = [[OSSVAccountsOrderDetailVC alloc] initWithOrderId:url];
                    [orderListVC.navigationController pushViewController:orderDetailVC animated:YES];
                }

            } else {
                
                [OSSVAdvsViewsManager sharedManager].isEndSheetAdv = YES;
                
                SignViewController *signVC = [SignViewController new];
                signVC.modalPresentationStyle = UIModalPresentationFullScreen;
                signVC.modalBlock = ^{

                    OSSVTabBarVC *tabbar = (OSSVTabBarVC *)targetVC.tabBarController;
                    
                    [tabbar setModel:STLMainMoudleAccount];
                    OSSVNavigationVC *nav = [tabbar navigationControllerWithMoudle:STLMainMoudleAccount];
                    if (nav) {
                        if (nav.viewControllers.count>1) {
                            [nav popToRootViewControllerAnimated:NO];
                        }
                    }
                    OOSVAccountVC *accountVC = nav.viewControllers[0];
                    OSSVAccountOrdersPageVC *orderListVC = [[OSSVAccountOrdersPageVC alloc] init];
                    [accountVC.navigationController pushViewController:orderListVC animated:NO];

                    if (![NSStringTool isEmptyString:url]) {
                        OSSVAccountsOrderDetailVC *orderDetailVC = [[OSSVAccountsOrderDetailVC alloc] initWithOrderId:url];
                        [orderListVC.navigationController pushViewController:orderDetailVC animated:YES];

                    }

                };
                [targetVC presentViewController:signVC animated:YES completion:nil];
            }
        }
            break;
        case AdvEventTypeOrderCoupon:
        {
            if (USERID) {
                
                ///获取到当前控制器
                STLBaseCtrl *baseVC = (STLBaseCtrl *)[OSSVAdvsEventsManager gainTopViewController];
                if (baseVC) {
                    OSSVWMCouponVC *couponVC = [OSSVWMCouponVC new];
                    [baseVC.navigationController pushViewController:couponVC animated:YES];
                }else{
                    OSSVTabBarVC *tabbar = (OSSVTabBarVC *)targetVC.tabBarController;
                    [tabbar setModel:STLMainMoudleAccount];
                    OSSVNavigationVC *nav = [tabbar navigationControllerWithMoudle:STLMainMoudleAccount];
                    if (nav) {
                        if (nav.viewControllers.count>1) {
                            [nav popToRootViewControllerAnimated:NO];
                        }
                    }
                    OSSWMHomeVC *accountVC = nav.viewControllers[0];
                    OSSVWMCouponVC *couponVC = [OSSVWMCouponVC new];
                    [accountVC.navigationController pushViewController:couponVC animated:YES];
                }

            } else {

                [OSSVAdvsViewsManager sharedManager].isEndSheetAdv = YES;
                SignViewController *signVC = [SignViewController new];
                signVC.modalPresentationStyle = UIModalPresentationFullScreen;
                signVC.modalBlock = ^{
                    OSSVTabBarVC *tabbar = (OSSVTabBarVC *)targetVC.tabBarController;

                        [tabbar setModel:STLMainMoudleAccount];
                        OSSVNavigationVC *nav = [tabbar navigationControllerWithMoudle:STLMainMoudleAccount];
                        if (nav) {
                            if (nav.viewControllers.count>1) {
                                [nav popToRootViewControllerAnimated:NO];
                            }
                        }
                    OOSVAccountVC *accountVC = nav.viewControllers[0];
                        OSSVWMCouponVC *couponVC = [OSSVWMCouponVC new];
                        [accountVC.navigationController pushViewController:couponVC animated:YES];
                };
                [targetVC presentViewController:signVC animated:YES completion:nil];
            }
        }
            break;
        case AdvEventTypeCart:
        {
            OSSVCartVC *ctrlVC = [[OSSVCartVC alloc] init];
            [targetVC.navigationController pushViewController:ctrlVC animated:YES];

//            STLBaseCtrl *baseVC = (STLBaseCtrl *)[OSSVAdvsEventsManager gainTopViewController];
//            if (baseVC) {
//                if (baseVC.navigationController.viewControllers.count>1) {
//                    [baseVC.navigationController popToRootViewControllerAnimated:NO];
//                }
//            }
            
        }
            break;
        case AdvEventTypeMyWishList:
        {
            if (USERID) {
                OSSVTabBarVC *tabbar = (OSSVTabBarVC *)targetVC.tabBarController;
                
                [tabbar setModel:STLMainMoudleAccount];
                OSSVNavigationVC *nav = [tabbar navigationControllerWithMoudle:STLMainMoudleAccount];
                if (nav) {
                    if (nav.viewControllers.count>1) {
                        [nav popToRootViewControllerAnimated:NO];
                    }
                }
                OOSVAccountVC *accountVC = nav.viewControllers[0];
                OSSVWishListVC *couponVC = [OSSVWishListVC new];
                [accountVC.navigationController pushViewController:couponVC animated:YES];
                
            }else{

                [OSSVAdvsViewsManager sharedManager].isEndSheetAdv = YES;
                SignViewController *signVC = [SignViewController new];
                signVC.modalPresentationStyle = UIModalPresentationFullScreen;
                signVC.modalBlock = ^{
                    OSSVTabBarVC *tabbar = (OSSVTabBarVC *)targetVC.tabBarController;

                        [tabbar setModel:STLMainMoudleAccount];
                        OSSVNavigationVC *nav = [tabbar navigationControllerWithMoudle:STLMainMoudleAccount];
                        if (nav) {
                            if (nav.viewControllers.count>1) {
                                [nav popToRootViewControllerAnimated:NO];
                            }
                        }
                    OOSVAccountVC *accountVC = nav.viewControllers[0];
                        OSSVWishListVC *couponVC = [OSSVWishListVC new];
                        [accountVC.navigationController pushViewController:couponVC animated:YES];
//                    }
                };
                [targetVC presentViewController:signVC animated:YES completion:nil];
            }
        }
            break;
        case AdvEventTypeVirtualGoodsList:
        {
            OSSVCategorysVirtualListVC *categoriesVC = [OSSVCategorysVirtualListVC new];
            categoriesVC.childName = url;
            categoriesVC.childDetailTitle = name;
            if (!STLIsEmptyString(advEventModel.parentId)) {
                categoriesVC.relatedID = advEventModel.parentId;
                categoriesVC.vitrualTypes = @"banner";
            } else if(!STLIsEmptyString(advEventModel.msgId)) {
                categoriesVC.relatedID = advEventModel.msgId;
                categoriesVC.vitrualTypes = @"msg";
            } else if(!STLIsEmptyString(advEventModel.bannerId)) {
                categoriesVC.relatedID = advEventModel.bannerId;
                categoriesVC.vitrualTypes = @"banner";
            }
            [targetVC.navigationController pushViewController:categoriesVC animated:YES];
        }
            break;
        case AdvEventTypeNativeCustom:{
            OSSVAppNewThemeVC *customTheme = [[OSSVAppNewThemeVC alloc] init];
            if ([url containsString:@","]) {
                NSArray *urlArray = [url componentsSeparatedByString:@","];
                customTheme.customId = urlArray[0];
                customTheme.deepLinkId = urlArray[1];
            }else{
                customTheme.customId = url;
            }
            
            customTheme.customName = name;
            [targetVC.navigationController pushViewController:customTheme animated:YES];
        }
            break;
        case AdvEventTypeSpecialList: {
            OSSVCategorysNewZeroListVC *ctrl = [[OSSVCategorysNewZeroListVC alloc] init];
            ctrl.specialId = url;
            ctrl.titleName = name;
            [targetVC.navigationController pushViewController:ctrl animated:YES];
        }
            break;
        case AdvEventTypeMsgToOrderDetail:
        {
            
            // 有订单id就跳转到订单详情，无则跳转至订单列表
            if (![NSStringTool isEmptyString:url])
            {
                OSSVAccountsOrderDetailVC *orderDetailVC = [[OSSVAccountsOrderDetailVC alloc] initWithOrderId:url];
                [targetVC.navigationController pushViewController:orderDetailVC animated:YES];
            }
        }
            break;
        case AdvEventTypeFlashActivity:
        {
            // 闪购活动
            if (![NSStringTool isEmptyString:url])
            {
                OSSVFlashSaleMainVC *vc = [[OSSVFlashSaleMainVC alloc] init];
            //    NSLog(@"跳转到闪购页面");
                vc.channelId = url;
                [targetVC.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        case AdvEventTypeOrderList:
        {
            
            if (USERID) {
                
                if (targetVC.navigationController) {
                    OSSVAccountOrdersPageVC *orderListVC = [[OSSVAccountOrdersPageVC alloc] init];
                    
                    if (!STLIsEmptyString(url) && [url intValue] >= 0 && [url intValue] <= 4) {
                        orderListVC.choiceIndex = url;
                    }
                    [targetVC.navigationController pushViewController:orderListVC animated:NO];
                }
                
            } else {
                
                SignViewController *signVC = [SignViewController new];
                signVC.modalPresentationStyle = UIModalPresentationFullScreen;
                signVC.modalBlock = ^{
                    
                    if (targetVC.navigationController) {
                        OSSVAccountOrdersPageVC *orderListVC = [[OSSVAccountOrdersPageVC alloc] init];
                        
                        if (!STLIsEmptyString(url) && [url intValue] >= 0 && [url intValue] <= 4) {
                            orderListVC.choiceIndex = url;
                        }
                        [targetVC.navigationController pushViewController:orderListVC animated:NO];
                    }
                };
                [targetVC presentViewController:signVC animated:YES completion:nil];
            }
        }
            break;
        case AdvEventTypeHelpMessageList:
        {
            
            if (USERID) {
                OSSVFeedbackReplayVC *ctrl = [[OSSVFeedbackReplayVC alloc] init];
                [targetVC.navigationController pushViewController:ctrl animated:YES];
            } else {
                
                SignViewController *signVC = [SignViewController new];
                signVC.modalPresentationStyle = UIModalPresentationFullScreen;
                signVC.modalBlock = ^{
                    OSSVFeedbackReplayVC *ctrl = [[OSSVFeedbackReplayVC alloc] init];
                    [targetVC.navigationController pushViewController:ctrl animated:YES];
                };
                [targetVC presentViewController:signVC animated:YES completion:nil];
            }
            
        }
            break;
        default:
            break;
    }
}

+(void)advEventOrderListWithPaymentStutas:(STLOrderPayStatus)status {
    [OSSVAdvsEventsManager advEventOrderListWithPaymentStutas:status OSSVAddresseBookeModel:nil];
}

+(void)advEventOrderListWithPaymentStutas:(STLOrderPayStatus)status OSSVAddresseBookeModel:(OSSVAccounteMyeOrdersListeModel *)orderAddress
{
//    OSSVTabBarVC *tabbarCtrl = [OSSVTabBarVC sharedInstance];
    
    if ([AppDelegate mainTabBar]) {
        OSSVTabBarVC *tabbarCtrl = [AppDelegate mainTabBar];
        
        STLMainMoudle curModel = tabbarCtrl.selectedIndex;
        OSSVNavigationVC *curNav = [tabbarCtrl navigationControllerWithMoudle:curModel];
        ///1.4.6  不展示中间步骤
        /*
        if (curNav) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                OSSVNavigationVC *accountNav = [tabbarCtrl navigationControllerWithMoudle:STLMainMoudleAccount];
                OSSVAccountOrdersPageVC *ordersVC = [[OSSVAccountOrdersPageVC alloc] init];
                ordersVC.codOrderAddressModel = orderAddress;
                if ([orderAddress.payCode isEqualToString:@"Cod"]) {
                    ordersVC.isConcelCodEnter = YES;
                }
                if (accountNav.viewControllers.count > 1) {
                    accountNav.viewControllers = @[accountNav.childViewControllers.firstObject];
                }
                [accountNav pushViewController:ordersVC animated:NO];
                [tabbarCtrl setModel:STLMainMoudleAccount];
                curNav.viewControllers = @[curNav.viewControllers.firstObject];
            });
        }
         */
        
         if (curNav) {
             if (curNav.viewControllers.count>1) {
                 [curNav popToRootViewControllerAnimated:NO];
             }
             
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 
                 [tabbarCtrl setModel:STLMainMoudleAccount];
                 OSSVNavigationVC *accountNav = [tabbarCtrl navigationControllerWithMoudle:STLMainMoudleAccount];
                 if (accountNav) {
                     if (accountNav.viewControllers.count>1) {
                         [accountNav popToRootViewControllerAnimated:NO];
                     }
                     OSSVAccountOrdersPageVC *ordersVC = [[OSSVAccountOrdersPageVC alloc] init];
                     ordersVC.codOrderAddressModel = orderAddress;
                     if ([orderAddress.payCode isEqualToString:@"Cod"]) {
                         ordersVC.isConcelCodEnter = YES;
                     }
                     ordersVC.title = STLLocalizedString_(@"myOrder", nil);

                     dispatch_async(dispatch_get_main_queue(), ^{
                         [accountNav pushViewController:ordersVC animated:YES];
                     });
                 }
             });
         }
        
        
    }
}

+ (void)jumpDeeplinkTarget:(id)target deeplinkParam:(NSDictionary *)paramDict {
    STLAdvEventModel *eventModel = [[STLAdvEventModel alloc] init];
    
    if ([paramDict[@"actiontype"] integerValue] > 0) {
        eventModel.actionType = [paramDict[@"actiontype"] integerValue];
        eventModel.url        = REMOVE_URLENCODING(STLToString(paramDict[@"url"]));
        eventModel.name       = REMOVE_URLENCODING(STLToString(paramDict[@"name"]));
    }
    
    [OSSVAdvsEventsManager advEventTarget:target withEventModel:eventModel];
}


+ (void)goHomeModule {
    
    OSSVTabBarVC *tabbarCtrl = [AppDelegate mainTabBar];
    
    STLMainMoudle curModel = tabbarCtrl.selectedIndex;
    OSSVNavigationVC *curNav = [tabbarCtrl navigationControllerWithMoudle:curModel];
    if (curNav) {
        if (curNav.viewControllers.count>1) {
            [curNav popToRootViewControllerAnimated:NO];
        }
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [tabbarCtrl setModel:STLMainMoudleHome];
            OSSVNavigationVC *accountNav = [tabbarCtrl navigationControllerWithMoudle:STLMainMoudleAccount];
            if (accountNav) {
                if (accountNav.viewControllers.count>1) {
                    [accountNav popToRootViewControllerAnimated:NO];
                }
            }
//        });
    }
}

/**
 * 根据url解析Deeplink参数
 * adorawe://action?actiontype=2&url=66&name=woment&source=deeplink
 */
+ (NSMutableDictionary *)parseDeeplinkParamDicWithURL:(NSURL *)url {
    NSMutableDictionary *deeplinkParamDic = [NSMutableDictionary dictionary];
    
    if ([url isKindOfClass:[NSURL class]] && url.query) {
        NSString *deeplinkAddress = url.query;
        
        // 防止url中有逗号(,)导致获取参数失败
        NSString *componentKey = @"actiontype=";
        if ([url.absoluteString containsString:@","] && [url.absoluteString containsString:componentKey]) {
            NSString *componentObj = [[url.absoluteString componentsSeparatedByString:componentKey] lastObject];
            deeplinkAddress = [NSString stringWithFormat:@"%@%@", componentKey, componentObj];
        }
        
        NSArray *arr = [deeplinkAddress componentsSeparatedByString:@"&"];
        for (NSString *str in arr) {
            if ([str rangeOfString:@"="].location != NSNotFound) {
                NSString *key = [str componentsSeparatedByString:@"="][0];
                NSString *value;
                if ([key isEqualToString:@"url"]) {
                    value = [str substringFromIndex:4];
                }else{
                    value = [str componentsSeparatedByString:@"="][1];
                }
                NSString *decodeValue = [value stringByRemovingPercentEncoding];
                
                // 防止多次编码,判断如果还有百分号就再解码一次
                if ([key isEqualToString:@"url"] && [decodeValue containsString:@"%"]) {
                    decodeValue = [decodeValue stringByRemovingPercentEncoding];
                }
                
                if (key && decodeValue) {
                    [deeplinkParamDic setObject:decodeValue forKey:key];
                }
            }
        }
    } else if(url && [url isKindOfClass:[NSString class]]) {
        NSString *deeplinkAddress = (NSString *)url;
        
        
        NSString *componentKey = @"actiontype=";
        if ([deeplinkAddress containsString:componentKey]) {
            NSString *componentObj = [[deeplinkAddress componentsSeparatedByString:componentKey] lastObject];
            deeplinkAddress = [NSString stringWithFormat:@"%@%@", componentKey, componentObj];
        }
        
        NSArray *arr = [deeplinkAddress componentsSeparatedByString:@"&"];
        for (NSString *str in arr) {
            if ([str rangeOfString:@"="].location != NSNotFound) {
                NSString *key = [str componentsSeparatedByString:@"="][0];
                NSString *value;
                if ([key isEqualToString:@"url"]) {
                    value = [str substringFromIndex:4];
                }else{
                    value = [str componentsSeparatedByString:@"="][1];
                }
                NSString *decodeValue = [value stringByRemovingPercentEncoding];
                
                // 防止多次编码,判断如果还有百分号就再解码一次
                if ([key isEqualToString:@"url"] && [decodeValue containsString:@"%"]) {
                    decodeValue = [decodeValue stringByRemovingPercentEncoding];
                }
                
                if (key && decodeValue) {
                    [deeplinkParamDic setObject:decodeValue forKey:key];
                }
            }
        }
    }
    STLLog(@"\n================================ Deeplink 参数 =======================================\n👉: %@", deeplinkParamDic);
    return deeplinkParamDic;
}


+ (UIViewController *)gainTopViewController
{
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

/**
 * 保存推送信息
 */
+ (void)saveNotificationsPaymentParmaters:(NSDictionary *)userInfo {
    if ([userInfo isKindOfClass:[NSDictionary class]]) {
        NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
        [us setObject:userInfo forKey:NOTIFICATIONS_PAYMENT_PARMATERS];  // 推送摧付参数
        [us setInteger:[[NSStringTool getCurrentTimestamp] integerValue] forKey:SAVE_NOTIFICATIONS_PARMATERS_TIME]; // 推送时间
        [self saveOneLinkeParams:userInfo];
        [us synchronize];
    }
}

+ (void)saveOneLinkeParams:(NSDictionary *)paramDict {
    
    if ([paramDict isKindOfClass:[NSDictionary class]]) {        
        if (!STLIsEmptyString(paramDict[@"utm_source"]) ||
            !STLIsEmptyString(paramDict[@"utm_medium"]) ||
            !STLIsEmptyString(paramDict[@"utm_campaign"])) {
            
            NSString *timeStr = [NSStringTool getCurrentTimestamp];
            NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
            [us setObject:paramDict forKey:ONELINK_PARMATERS];  // 推广广告参数
            
            if (!STLIsEmptyString(paramDict[@"share_uid"])) {
                NSString *str= [NSString stringWithFormat:@"%@", paramDict[@"share_uid"]];
                [us setObject:str forKey:ONELINK_SHAREUSERID];  // 推广广告用户
            }
            
            [us setInteger:[timeStr integerValue] forKey:SAVE_ONELINK_PARMATERS_TIME]; // 推广广告时间
            [us synchronize];
        }
    }
}

+ (NSString *)adv_utm_source {
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSDictionary *notificationsParmaters = [us objectForKey:ONELINK_PARMATERS];
    NSString *str = notificationsParmaters[@"utm_source"];
    return STLToString(str);
}

+ (NSString *)adv_utm_medium {
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSDictionary *notificationsParmaters = [us objectForKey:ONELINK_PARMATERS];
    NSString *str = notificationsParmaters[@"utm_medium"];
    return STLToString(str);
}

+ (NSString *)adv_utm_campaign {
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSDictionary *notificationsParmaters = [us objectForKey:ONELINK_PARMATERS];
    NSString *str = notificationsParmaters[@"utm_campaign"];
    return STLToString(str);
}

+ (NSString *)adv_utm_date {
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSInteger saveTime = [us integerForKey:SAVE_ONELINK_PARMATERS_TIME];
    NSString *str = [NSString stringWithFormat:@"%li",(long)saveTime];
    return str;
}


+(NSString *)adv_shared_uid{
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSString *str = [us objectForKey:ONELINK_SHAREUSERID];
    return STLToString(str);
}

@end
