//
//  YXRouter.m
//  uSmartOversea
//
//  Created by RuiQuan Dai on 2018/7/2.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXRouter.h"
#import "uSmartOversea-Swift.h"

@interface YXRouter ()


@property (nonatomic, copy) NSDictionary *viewModelViewMappings; // viewModel到view的映射
@property (nonatomic, copy) NSDictionary *swiftViewModelViewMappings;


@end

@implementation YXRouter


+ (instancetype)sharedInstance {
    static YXRouter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (YXViewController *)viewControllerForViewModel:(YXViewModel *)viewModel {
    //第一步：拿到vc的字符串
    NSString *viewController = self.viewModelViewMappings[NSStringFromClass(viewModel.class)];
    if (viewController == nil) {
        viewController = self.swiftViewModelViewMappings[NSStringFromClass(viewModel.class)];
    }

    NSParameterAssert([NSClassFromString(viewController) isSubclassOfClass:[YXViewController class]]);
    NSParameterAssert([NSClassFromString(viewController) instancesRespondToSelector:@selector(initWithViewModel:)]);
    //第三步：实例化vc并返回
    return [[NSClassFromString(viewController) alloc] initWithViewModel:viewModel];
}

- (NSDictionary *)viewModelViewMappings {
    return @{
        @"YXNormalTradeViewModel" : @"YXNormalTradeViewController",
        @"YXSmartTradeGuideViewModel": @"YXSmartTradeGuideViewController",
        @"YXSmartOrderViewModel": @"YXSmartOrderViewController",
        @"YXSmartOrderListViewModel":@"YXSmartOrderListViewController",
        @"YXTodayGreyStockViewModel":@"YXTodayGreyStockVC",
        @"YXBankTreasurerViewModel":@"YXBankTreasurerViewController",
        @"YXIntradayHoldHistoryViewModel": @"YXIntradayHoldHistoryController",
        @"YXStockDetailMyRemindersViewModel": @"YXStockDetailMyRemindersController",
        @"YXStockReminderTypeViewModel": @"YXStockReminderTypeController",
        @"YXStockDetailReminderSettingViewModel": @"YXStockDetailReminderSettingController",
        @"YXStockReminderHomeViewModel": @"YXStockReminderHomeViewController",
        @"YXOptionTradeOrderViewModel" : @"YXOptionTradeOrderViewController",
        @"YXOptionOrderViewModel" : @"YXOptionOrderViewController",
        @"YXOptionAssetsViewModel": @"YXOptionAssetsViewController",
        @"YXBankTreasurerResultViewModel": @"YXBankTreasurerResultViewController",
        @"YXBankTreasurerListViewModel": @"YXBankTreasurerListViewController",
        @"YXIntradayTradeOrderViewModel": @"YXIntradayTradeOrderViewController",
        @"YXStockPickerResultViewModel": @"YXStockPickerResultViewController",
        @"YXStockFilterGroupViewModel": @"YXStockFilterGroupViewController",
        @"YXSubIntervalListViewModel": @"YXSubIntervalListViewController",
        @"YXIntervalHomeViewModel": @"YXIntervalHomeViewController",
        @"YXPreLiveViewModel": @"YXPreLiveViewController",
        @"YXBrokerDetailViewModel": @"YXBrokerDetailVC",
        @"YXStockDetailBrokerHoldingVModel": @"YXStockDetailBrokerHoldingVC",
        @"YXStareHomeViewModel": @"YXStareHomeVC",
        @"YXKlineSubIndexViewModel": @"YXKilineSubIndexVC",
        @"YXStockDetailTradeStaticVModel": @"YXStockDetailTradeStaticVC",
        @"YXStockDetailAnalyzeViewModel": @"YXStockDetailBrokerAnalyzeVC",
        @"YXIntradayHoldViewModel": @"YXIntradayHoldViewController",
        @"YXShortSellOrderViewModel": @"YXShortSellOrderViewController",
        @"YXOrgAccountListViewModel": @"YXOrgAccountListViewController",
        @"YXWatchLiveViewModel":@"YXWatchLiveViewController",
        @"YXLiveChatLandscapeViewModel":@"YXLiveChatLandscapeViewController",
        @"YXSmartTradeViewModel":@"YXSmartTradeViewController",
        @"YXStockDetailDiscussViewModel":NSStringFromClass(SwiftStockDetailDiscussViewController.self),
        @"YXReportViewModel":@"YXReportViewController",
        @"YXStockCommentDetailViewModel":@"YXStockCommentDetailViewController",
        @"YXImportantNewsDetailViewModel":@"YXImportantNewsDetailViewController",
        @"YXNoticeAppViewModel":@"YXNoticeAppViewController",
    };
}

- (NSDictionary *)swiftViewModelViewMappings {
    return @{
        NSStringFromClass(YXBullBearAssetListViewModel.self): NSStringFromClass(YXBullBearAssetListViewController.self),
        NSStringFromClass(YXBullBearMoreViewModel.self): NSStringFromClass(YXBullBearMoreViewController.self),
        NSStringFromClass(YXHotETFViewModel.self): NSStringFromClass(YXHotETFViewController.self),
        NSStringFromClass(YXHotETFListViewModel.self): NSStringFromClass(YXHotETFListViewController.self),
        NSStringFromClass(YXInfoDetailViewModel.self): NSStringFromClass(YXInfoDetailViewController.self),
        NSStringFromClass(YXStockFilterViewModel.self): NSStringFromClass(YXStockFilterViewController.self),
        NSStringFromClass(YXStockFilterTabViewModel.self): NSStringFromClass(YXStockFilterTabViewController.self),
        NSStringFromClass(YXShareOptionsViewModel.self): NSStringFromClass(YXShareOptionsViewController.self),
        NSStringFromClass(YXWarrantsFundFlowDetailViewModel.self): NSStringFromClass(YXWarrantsFundFlowDetailViewController.self),
        NSStringFromClass(YXPbSignalViewModel.self): NSStringFromClass(YXPbSignalViewController.self),
        NSStringFromClass(YXMarketMakerRankViewModel.self): NSStringFromClass(YXMarketMakerRankViewController.self),
        NSStringFromClass(YXUSElementChangeViewModel.self):NSStringFromClass(YXUSElementChangeViewController.self),
        NSStringFromClass(YXUSElementViewModel.self):NSStringFromClass(YXUSElementViewController.self),
        NSStringFromClass(YXTradeViewModel.self):NSStringFromClass(YXTradeViewController.self),
        NSStringFromClass(YXTradeStatementViewModel.self):NSStringFromClass(YXTradeStatementViewController.self),
        NSStringFromClass(YXStatementSettingViewModel.self):NSStringFromClass(YXStatementSettingVC.self),
        NSStringFromClass(YXStatementWebViewModel.self):NSStringFromClass(YXStatementWebViewController.self),
        };
}


@end

