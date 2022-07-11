//
//  YXStockFilterGroupViewController.m
//  uSmartOversea
//
//  Created by youxin on 2020/9/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockFilterGroupViewController.h"
#import "YXStockFilterGroupViewModel.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "YXStockFilterMarketGroupVC.h"
#import "YXStockFilterMarketGroupViewModel.h"

@interface YXStockFilterGroupViewController () <YXTabViewDelegate>

@property (nonatomic, strong, readonly) YXStockFilterGroupViewModel *viewModel;
@property (nonatomic, strong) YXTabView *tabView;
@property (nonatomic, strong) YXPageView *pageView;
@property (nonatomic, strong) YXStockFilterMarketGroupVC *allGroupVC;
@property (nonatomic, strong) YXStockFilterMarketGroupVC *hkGroupVC;
@property (nonatomic, strong) YXStockFilterMarketGroupVC *usGroupVC;
@property (nonatomic, strong) YXStockFilterMarketGroupVC *hsGroupVC;
@end

@implementation YXStockFilterGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [YXLanguageUtility kLangWithKey:@"my_stock_scanner"];

    [self.view addSubview:self.tabView];
    [self.view addSubview:self.pageView];

    [self.tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(40);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view).offset(YXConstant.navBarHeight);
        }
    }];

    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.tabView.mas_bottom);
    }];

    self.allGroupVC = [self marketVC:@""];
    self.hkGroupVC = [self marketVC:kYXMarketHK];
    self.usGroupVC = [self marketVC:kYXMarketUS];
    self.hsGroupVC = [self marketVC:kYXMarketHS];

    self.tabView.pageView = self.pageView;
    self.pageView.viewControllers = @[self.allGroupVC, self.hkGroupVC, self.usGroupVC, self.hsGroupVC];

    if ([self.viewModel.market isEqualToString:kYXMarketHK]) {
        self.tabView.defaultSelectedIndex = 1;
    } else if ([self.viewModel.market isEqualToString:kYXMarketUS]) {
        self.tabView.defaultSelectedIndex = 2;
    } else if ([self.viewModel.market isEqualToString:kYXMarketHS] || [self.viewModel.market isEqualToString:kYXMarketChinaSH] || [self.viewModel.market isEqualToString:kYXMarketChinaSZ]) {
        self.tabView.defaultSelectedIndex = 3;
    }
}


#pragma market - YXTabViewDelegate

- (void)tabView:(YXTabView *)tabView didSelectedItemAtIndex:(NSUInteger)index withScrolling:(BOOL)scrolling {

}

#pragma mark - Getter

- (YXTabView *)tabView {
    if (!_tabView) {

        YXTabLayout *layout = [YXTabLayout defaultLayout];
        layout.lineColor = QMUITheme.themeTextColor;
        layout.titleColor = [QMUITheme.textColorLevel1 colorWithAlphaComponent:0.65];
        layout.titleSelectedColor = QMUITheme.themeTextColor;
        _tabView = [[YXTabView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 40) withLayout:layout];
        _tabView.delegate = self;
        _tabView.titles = @[[YXLanguageUtility kLangWithKey:@"common_all"], [YXLanguageUtility kLangWithKey:@"community_hk_stock"], [YXLanguageUtility kLangWithKey:@"community_us_stock"], [YXLanguageUtility kLangWithKey:@"sh_sz"]];
        _tabView.backgroundColor = QMUITheme.foregroundColor;
    }
    return _tabView;
}

- (YXPageView *)pageView {
    if (!_pageView) {
        _pageView = [[YXPageView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, YXConstant.screenHeight - YXConstant.navBarHeight - 40)];
        _pageView.parentViewController = self;
    }
    return _pageView;
}

- (YXStockFilterMarketGroupVC *)marketVC:(NSString *)market {
    YXStockFilterMarketGroupViewModel *viewModel = [[YXStockFilterMarketGroupViewModel alloc] initWithServices:self.viewModel.services params:@{@"market" : market}];
    YXStockFilterMarketGroupVC *vc = [[YXStockFilterMarketGroupVC alloc] initWithViewModel:viewModel];
    return vc;
}




@end
