//
//  JumpManager.m
//  ZZZZZ
//
//  Created by DBP on 16/10/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "JumpManager.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFWebViewViewController.h"
#import "SearchResultViewController.h"
#import "ZFHomePageViewController.h"
#import "ZFCommunityFullLiveVideoVC.h"

#import "ZFCommunityHomeVC.h"
#import "ZFCommunityAccountViewController.h"

#import "ZFCommunityTopicDetailPageViewController.h"
#import "ZFCommunityMessageListVC.h"
#import "CouponViewController.h"
#import "ZFAccountViewController540.h"
#import "ZFMyOrderListViewController.h"
#import "ZFOrderDetailViewController.h"
#import "ZFCommunityVideoListVC.h"
#import "ZFCommunityPostCategoryViewController.h"
#import "ZFCommunityPostDetailPageVC.h"

#import "CategoryListPageViewController.h"
#import "CategoryDataManager.h"
#import "ZFNativeBannerViewModel.h"
#import "ZFNativeBannerViewController.h"

#import "NSArray+SafeAccess.h"
#import "ZFGoodsDetailViewModel.h"
#import "MyPointsViewController.h"
#import "ZFCommunityPostListViewController.h"
#import "ZFCustomerManager.h"

#import "ZFContactUsViewController.h"
#import "ZFCommunityMoreHotTopicsVC.h"
#import "CategoryVirtualViewController.h"
#import "ZFHandpickGoodsListVC.h"

#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFTabBarController.h"
#import "UIView+ZFViewCategorySet.h"
#import "Constants.h"
#import "ZFNewUserActivetyViewController.h"
#import "ZFCommunityLiveListVC.h"
#import "ZFCommunityLiveVideoVC.h"
#import "ZFSubmitReviewsViewController.h"
#import "BannerManager.h"
#import "ZFAddressEditViewController.h"
#import "ZFGeshopNativeThematicVC.h"

@import GlobalegrowIMSDK;
@implementation JumpManager

+ (void)doJumpActionTarget:(id)target withJumpModel:(JumpModel *)jumpModel {
    JumpActionType actionType    = jumpModel.actionType;
    NSString *url                = jumpModel.url;
    NSString *name               = jumpModel.name;
    NSString *featuring          = jumpModel.featuring;
    
    UIViewController *targetVC;
    if ([target isKindOfClass:[UIView class]]) {
        UIView *targetView = (UIView *)target;
        targetVC = targetView.viewController;
    } else if ([target isKindOfClass:[UIViewController class]]){
        targetVC = target;
    } else {
        targetVC = [UIViewController currentTopViewController];
    }
    
    BOOL animated = !jumpModel.noNeedAnimated;  // 转场动画，默认为yes
    
    switch (actionType) {
        case JumpDefalutActionType:
        {
            ZFTabBarController *tabbar = (ZFTabBarController *)targetVC.tabBarController;
            [tabbar setZFTabBarIndex:TabBarIndexHome];
            ZFNavigationController *nav = [tabbar navigationControllerWithMoudle:TabBarIndexHome];
            if (nav.viewControllers.count>1) {
                [nav popToRootViewControllerAnimated:NO];
            }
        }
            break;
        case JumpHomeActionType:
        {
            ZFTabBarController *tabbar = (ZFTabBarController *)targetVC.tabBarController;
            [tabbar setZFTabBarIndex:TabBarIndexHome];
            ZFNavigationController *nav = [tabbar navigationControllerWithMoudle:TabBarIndexHome];
            if (nav.viewControllers.count>1) {
                [nav popToRootViewControllerAnimated:NO];
            }
        }
            break;
        case JumpCategoryActionType:
        {
            if (ZFIsEmptyString(url) || [url isEqualToString:@"0"]) {
                [targetVC pushToViewController:@"ZFCategoryParentViewController" propertyDic:nil];
                return;
            }
            
            CategoryListPageViewController *listPageVC = [[CategoryListPageViewController alloc] init];
            
            CategoryNewModel *model = [[CategoryNewModel alloc] init];
            model.cat_id = url;
            model.cat_name = name;
            model.cat_featuring = featuring;
            listPageVC.model = model;
            
            listPageVC.isFromDeepLink = YES;
            listPageVC.selectedAttrsString = jumpModel.refine;
            listPageVC.price_max = jumpModel.maxprice;
            listPageVC.price_min = jumpModel.minprice;
            listPageVC.currentSort = jumpModel.sort;

            [targetVC.navigationController pushViewController:listPageVC animated:animated];
        }
            break;
        case JumpGoodDetailActionType:
        {
            ZFGoodsDetailViewController *goodsDetailVC = [[ZFGoodsDetailViewController alloc] init];
            goodsDetailVC.goodsId = url;
            goodsDetailVC.freeGiftId = ZFToString(jumpModel.giftId);
            AFparams *params = [[AFparams alloc] init];
            params.versionid = jumpModel.versionid;
            params.planid = jumpModel.planid;
            params.bucketid = jumpModel.bucketid;
            goodsDetailVC.afParams = params;
            goodsDetailVC.deeplinkSource = ZFToString(jumpModel.source);
            targetVC.navigationController.delegate = nil;
            [targetVC.navigationController pushViewController:goodsDetailVC animated:animated];
        }
            break;
        case JumpSearchActionType:
        {
            SearchResultViewController *searchResultVC = [[SearchResultViewController alloc] init];
            searchResultVC.searchString = [url stringByRemovingPercentEncoding];
            searchResultVC.featuring = featuring;
            searchResultVC.title = [url stringByRemovingPercentEncoding];
            searchResultVC.sourceType = ZFAppsflyerInSourceTypeSearchDeeplink;
            [targetVC.navigationController pushViewController:searchResultVC animated:animated];
        }
            break;
        case JumpInsertH5ActionType:
        {
            // 加载H5
            if ([NSStringUtils isBlankString:url]) {
                return;
            }
            //因为客服页面没有解决跨域问题,需要单独跳进低性能UIWebView页面
            if ([url containsString:@"ticket/ticket"]) {
                @weakify(targetVC)
                [targetVC judgePresentLoginVCCompletion:^{
                    @strongify(targetVC)
                    NSString *lang = ZFToString([ZFLocalizationString shareLocalizable].nomarLocalizable);
                    NSString *appdingStr = [NSString stringWithFormat:@"?type=app&lang=%@",lang];
                    
                    ZFContactUsViewController *webVC = [[ZFContactUsViewController alloc] init];
                    webVC.link_url = [url stringByAppendingString:appdingStr];
                    [targetVC.navigationController pushViewController:webVC animated:animated];
                }];
            } else {
                ZFWebViewViewController *webVC = [[ZFWebViewViewController alloc] init];
                webVC.link_url = url;
                webVC.title = ZFToString(name);
                [targetVC.navigationController pushViewController:webVC animated:animated];
            }
        }
            break;
        case JumpCommunityActionType:
        {
            //社区
            NSArray *communityInfo = [url componentsSeparatedByString:@","];
            NSInteger communityStyle = [communityInfo integerWithIndex:0];
            switch (communityStyle) {
                case 0:
                {   // 社区首页
                    [JumpManager jumpToActionTarget:targetVC mainTabBar:TabBarIndexCommunity];
                }
                    break;
                case 1:  // 个人主页
                {
                    NSString  *communityID = [communityInfo stringWithIndex:1];
                    if ([NSStringUtils isBlankString:communityID]) return;
                    ZFCommunityAccountViewController *styleVC = [ZFCommunityAccountViewController new];
                    styleVC.userId = communityID;
                    styleVC.isDeeplink = YES;
                    [targetVC.navigationController pushViewController:styleVC animated:animated];
                }
                    break;
                case 2:  // 评论详情
                {
                    NSString  *communityID = [communityInfo stringWithIndex:1];
                    //NSString  *userId = [communityInfo stringWithIndex:2];
                    if ([NSStringUtils isBlankString:communityID]) return;
                    
                    ZFCommunityPostDetailPageVC *detailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:communityID title:@""];

                    [targetVC.navigationController pushViewController:detailViewController animated:animated];
                }
                    break;
                case 3:  // 话题详情
                {
                    NSString  *topicId = [communityInfo stringWithIndex:1];
                    if ([NSStringUtils isBlankString:topicId]) return;
                    ZFCommunityTopicDetailPageViewController *topicVC = [[ZFCommunityTopicDetailPageViewController alloc] init];
                    topicVC.topicId = topicId;
                    topicVC.deeplinkSource = ZFToString(jumpModel.source);
                    [targetVC.navigationController pushViewController:topicVC animated:animated];
                }
                    break;
                case 4:  // 视频详情
                {
                    NSString  *videoId = [communityInfo stringWithIndex:1];
                    if ([NSStringUtils isBlankString:videoId]) return;
                    ZFCommunityVideoListVC *videoVC = [[ZFCommunityVideoListVC alloc] init];
                    videoVC.videoId = videoId;
                    [targetVC.navigationController pushViewController:videoVC animated:animated];
                }
                    break;
                case 5:  // 穿搭列表页Outfits
                {
                    ZFTabBarController *tabbar = (ZFTabBarController *)targetVC.tabBarController;
                    [tabbar setZFTabBarIndex:TabBarIndexCommunity];
                    
                    ZFNavigationController *navVC = [tabbar navigationControllerWithMoudle:TabBarIndexCommunity];
                    if ([navVC isKindOfClass:[UINavigationController class]]) {
                        
                        ZFCommunityHomeVC *vc = [navVC.viewControllers firstObject];
                        if ([vc isKindOfClass:[ZFCommunityHomeVC class]]) {
                            //跳转到社区首页第二个tab穿搭页面
                            [vc bannerJumpToSelectType:ZFCommunityHomeSelectTypeOutfits];
                        }
                    }
                }
                    break;
                case 6:  // 话题标签页
                {
                    ZFCommunityPostListViewController *topicListVC = [[ZFCommunityPostListViewController alloc] init];
                    NSString  *tag = [communityInfo stringWithIndex:1];
                    topicListVC.topicTitle = tag;
                    [targetVC.navigationController pushViewController:topicListVC animated:animated];
                }
                    break;
                case 7: //跳转社区标签列表页面
                {
                    ZFCommunityMoreHotTopicsVC *toplistOfVC = [[ZFCommunityMoreHotTopicsVC alloc] init];
                    [targetVC.navigationController pushViewController:toplistOfVC animated:animated];
                }
                    break;
                case 8: //跳转社区帖子分类
                {
                    ZFCommunityPostCategoryViewController *postPageVC = [[ZFCommunityPostCategoryViewController alloc] init];
                    postPageVC.jumpModel = jumpModel;
                    [targetVC.navigationController pushViewController:postPageVC animated:animated];
                }
                    break;
            }
        }
            break;
        case JumpExternalLinkActionType:
        {
             [SHAREDAPP openURL:[NSURL URLWithString:url]];
        }
            break;
        case JumpMessageActionType:
        {
            //社区消息列表
            @weakify(targetVC)
            [targetVC judgePresentLoginVCCompletion:^{
                @strongify(targetVC)
                ZFCommunityMessageListVC *messageVC = [[ZFCommunityMessageListVC alloc]init];
                [targetVC.navigationController pushViewController:messageVC animated:animated];
            }];
            
        }
            break;
        case JumpCouponActionType:
        {
            @weakify(targetVC)
            [targetVC judgePresentLoginVCCompletion:^{
                @strongify(targetVC)
                CouponViewController *couponVC = [[CouponViewController alloc] init];
                [targetVC.navigationController pushViewController:couponVC animated:animated];
            }];
        }
            break;
        case JumpOrderListActionType:
        {
            @weakify(self)
            [targetVC judgePresentLoginVCCompletion:^{
                @strongify(self)
                [self jumpToMyOrderListVC:targetVC url:url];
            }];
        }
            break;
        case JumpOrderDetailActionType:
        {
            @weakify(self)
            [targetVC judgePresentLoginVCCompletion:^{
                @strongify(self)
                [self jumpToOrderDetailVC:targetVC url:url];
            }];
        }
            break;
        case JumpCartActionType:
        {
            [targetVC pushToViewController:@"ZFCartViewController" propertyDic:nil];
        }
            break;
        case JumpCollectionActionType:
        {
            [targetVC pushToViewController:@"ZFCollectionViewController" propertyDic:nil];
        }
            break;
        case JumpVirtualCategoryActionType:
        {
            CategoryVirtualViewController *vc = [[CategoryVirtualViewController alloc] init];
            vc.argument = url;
            vc.virtualTitle = name;
            vc.coupon = jumpModel.coupon;  // 该参数只有coupon入口才有
            [targetVC.navigationController pushViewController:vc animated:animated];
        }
            break;
        case JumpNativeBannerActionType:
        {
            // 跳转原生专题
            ZFNativeBannerViewController *nativeBannerVC = [[ZFNativeBannerViewController alloc] init];
            nativeBannerVC.specialTitle = name;
            nativeBannerVC.specialId = url;
            nativeBannerVC.deeplinkSource = ZFToString(jumpModel.source);
            [targetVC.navigationController pushViewController:nativeBannerVC animated:animated];
        }
            break;
            
        case JumpAddToCartActionType:
        {
            if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                ZFTabBarController *tabbar = (ZFTabBarController *)targetVC.tabBarController;
                [tabbar setZFTabBarIndex:TabBarIndexHome];
            }
            [[ZFGoodsDetailViewModel new] requestAddToCart:ZFToString(url) loadingView:nil goodsNum:1 completion:nil];
        }
            break;
            
        case JumpChannelActionType:
        {
            ZFTabBarController *tabbar = (ZFTabBarController *)targetVC.tabBarController;
            [tabbar setZFTabBarIndex:TabBarIndexHome];
            
            ZFNavigationController *targetNavVC = [tabbar navigationControllerWithMoudle:TabBarIndexHome];
            // 转到首页
            ZFHomePageViewController *homeViewController = targetNavVC.viewControllers.firstObject;
            if ([homeViewController isKindOfClass:[ZFHomePageViewController class]]) {
                [homeViewController scrollToTargetVCWithChannelID:url];
            }
        }
            break;
        case JumpPointsActionType:
        {
            @weakify(targetVC)
            [targetVC judgePresentLoginVCCompletion:^{
                @strongify(targetVC)
                MyPointsViewController *couponVC = [[MyPointsViewController alloc] init];
                [targetVC.navigationController pushViewController:couponVC animated:animated];
            }];
        }
            break;
        case JumpMyShareActionType:
        {
            ZFInitializeModel *initializeModel = [AccountManager sharedManager].initializeModel;
            NSString *lineUrl = ZFToString(initializeModel.get_it_free);
            // 加载H5
            if ([NSStringUtils isBlankString:lineUrl]) {
                return;
            }
            ZFWebViewViewController *webVC = [[ZFWebViewViewController alloc] init];
            webVC.link_url = lineUrl;
            webVC.title = ZFToString(name);
            [targetVC.navigationController pushViewController:webVC animated:animated];
        }
            break;
            
        case JumpNewUserActivetType: {
            
            
            ZFNewUserActivetyViewController *activetyViewController = [[ZFNewUserActivetyViewController alloc] init];
            activetyViewController.title = ZFLocalizedString(@"newcomer_title", nil);
            [targetVC.navigationController pushViewController:activetyViewController animated:animated];
        }
            break;
          
        case JumpLiveChatActionType: {
            //弹出LiveChat客服页面
            [[ZFCustomerManager shareInstance] presentLiveChatWithGoodsInfo:@""];
        }
           break;
        case JumpHandpickGoodsListType: {
            //跳转到精选商品列表
            ZFHandpickGoodsListVC *handpickGoodsListVC = [[ZFHandpickGoodsListVC alloc] init];
            handpickGoodsListVC.goodsIDs = url;
            handpickGoodsListVC.ptsModel = jumpModel.pushPtsModel;
            handpickGoodsListVC.title = ZFToString(name);
            handpickGoodsListVC.isCouponListDeeplink = jumpModel.isCouponListDeeplink;
            [targetVC.navigationController pushViewController:handpickGoodsListVC animated:animated];
        }
            break;
        case JumpHandpickLiveListType: {
            //跳转到视频直播列表
            ZFCommunityLiveListVC *liveListVC = [[ZFCommunityLiveListVC alloc] init];
            [targetVC.navigationController pushViewController:liveListVC animated:animated];
        }
            break;
        case JumpHandpickLiveBroadcastType: {
            //跳转到视频直播播放
            ZFCommunityLiveVideoVC *liveVideoVC = [[ZFCommunityLiveVideoVC alloc] init];
            liveVideoVC.liveID = ZFToString(jumpModel.url);
            [targetVC.navigationController pushViewController:liveVideoVC animated:animated];
        }
            break;
        case JumpMultipleActionType:
        {
            //多重嵌套跳转（多个页面叠加）
            NSArray *deeplinkArray = [ZFToString(url) componentsSeparatedByString:@","];
            for (int i = 0; i < deeplinkArray.count; i ++) {
                NSString *deeplinkUrl = ZFToString(deeplinkArray[i]);
                NSMutableDictionary *paramDict = [BannerManager parseDeeplinkParamDicWithURL:[NSURL URLWithString:ZFEscapeString(ZFToString(deeplinkUrl), YES)]];
                if (i < deeplinkArray.count - 1) {
                    paramDict[@"noNeedAnimated"] = @"1"; // 关闭中间页面转场动画
                }
                [BannerManager jumpDeeplinkTarget:target deeplinkParam:paramDict];
            }
        }
            break;
        case JumpOrderReviewsActionType:
        {
            //跳转到订单评论页
            @weakify(targetVC)
            [targetVC judgePresentLoginVCCompletion:^{
                @strongify(targetVC)
                ZFSubmitReviewsViewController *reviewVC = [[ZFSubmitReviewsViewController alloc] init];
                reviewVC.orderId = ZFToString(jumpModel.url);
                [targetVC.navigationController pushViewController:reviewVC animated:animated];
            }];
            
        }
            break;
        case JumpOrderAddressEidtActionType:
        {
            if (!ZFIsEmptyString(jumpModel.url)) {
                //跳转到订单地址编辑页
                @weakify(targetVC)
                [targetVC judgePresentLoginVCCompletion:^{
                    @strongify(targetVC)
                    ZFAddressEditViewController *addressVC = [[ZFAddressEditViewController alloc] init];
                    addressVC.addressOrderSn = ZFToString(jumpModel.url);
                    [targetVC.navigationController pushViewController:addressVC animated:animated];
                }];
            }
            
        }
            break;
        case JumpHandpickZegoLiveBroadcastType: {
            //跳转到视频直播播放
            ZFCommunityFullLiveVideoVC *liveVideoVC = [[ZFCommunityFullLiveVideoVC alloc] init];
            liveVideoVC.liveID = ZFToString(jumpModel.url);
            liveVideoVC.isZego = YES;
            [targetVC.navigationController pushViewController:liveVideoVC animated:animated];
        }
            break;
        case JumpGeshopNewNativeThemeType: {
            // 跳转到Geshop新原生专题页面:
            ZFGeshopNativeThematicVC *geshopVC = [[ZFGeshopNativeThematicVC alloc] init];
            geshopVC.title = ZFToString(jumpModel.name);
            geshopVC.nativeThemeId = ZFToString(jumpModel.url);
            [targetVC.navigationController pushViewController:geshopVC animated:animated];
        }
            break;
    }
}


/**
 跳主要，防止模态的，回到主页
 */
+ (ZFTabBarController *)jumpToActionTarget:(UIViewController *)targetVC mainTabBar:(NSInteger)tabIndex {
    
    ZFTabBarController *tabbar = (ZFTabBarController *)targetVC.tabBarController;
    //防止是模态控制器
    if (!tabbar) {
        if (targetVC.parentViewController) {
            [targetVC dismissViewControllerAnimated:YES completion:nil];
            
            if ([targetVC.parentViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navVC = (UINavigationController *) targetVC.parentViewController;
                [navVC popToRootViewControllerAnimated:NO];
                [APPDELEGATE.tabBarVC setZFTabBarIndex:tabIndex];
            }
        }
    } else {
        [tabbar setZFTabBarIndex:tabIndex];
    }
    return tabbar;
}


#pragma mark - Private Method
/**
 * 跳订单详情
 */
+ (void)jumpToOrderDetailVC:(UIViewController *)targetVC url:(NSString *)url {
    ZFTabBarController *tabbar = (ZFTabBarController *)targetVC.tabBarController;
    [tabbar setZFTabBarIndex:TabBarIndexAccount];
    ZFNavigationController *nav = [tabbar navigationControllerWithMoudle:TabBarIndexAccount];
    if (nav) {
        if (nav.viewControllers.count>1) {
            [nav popToRootViewControllerAnimated:NO];
        }
        ZFAccountViewController540 *accountVC = nav.viewControllers[0];
        ZFMyOrderListViewController *orderListVC = [[ZFMyOrderListViewController alloc] init];
        orderListVC.sourceOrderId = url;
        [accountVC.navigationController pushViewController:orderListVC animated:NO];
        
        ZFOrderDetailViewController *orderDetailVC = [[ZFOrderDetailViewController alloc] init];
        orderDetailVC.orderId = url;
        [orderListVC.navigationController pushViewController:orderDetailVC animated:YES];
    }
}

/**
 * 跳订单列表
 */
+ (void)jumpToMyOrderListVC:(UIViewController *)targetVC url:(NSString *)url {
    ZFTabBarController *tabbar = (ZFTabBarController *)targetVC.tabBarController;
    [tabbar setZFTabBarIndex:TabBarIndexAccount];
    ZFNavigationController *nav = [tabbar navigationControllerWithMoudle:TabBarIndexAccount];
    if (nav) {
        if (nav.viewControllers.count>1) {
            [nav popToRootViewControllerAnimated:NO];
        }
        ZFAccountViewController540 *accountVC = nav.viewControllers[0];
        ZFMyOrderListViewController *orderListVC = [[ZFMyOrderListViewController alloc] init];
        [accountVC.navigationController pushViewController:orderListVC animated:YES];
    }
}

@end
