//
//  YXStockDetailTradeStaticVC.m
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXStockDetailTradeStaticVC.h"

#import "YXSDWeavesDetailViewController.h"
#import "YXSDDealStatisticalVC.h"

#import "YXStockDetailTradeStaticVModel.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import <YXKit/YXKit.h>

@interface YXStockDetailTradeStaticVC ()<YXTabViewDelegate>

@property (nonatomic, strong) YXTabView *tabView;
@property (nonatomic, strong) YXPageView *pageView;

@property (nonatomic, strong) NSArray<NSString *> *titles;
@property (nonatomic, strong) NSArray<__kindof UIViewController *> *viewControllers;

@property (nonatomic, strong) YXSDWeavesDetailViewController *weavesDetailVC;
@property (nonatomic, strong) YXSDDealStatisticalVC *dealStaticVC;

@property (nonatomic, strong, readonly) YXStockDetailTradeStaticVModel *viewModel;

@property (nonatomic, assign) CGFloat tabWidth;

@property (nonatomic, assign) BOOL isOnlyTick;

@end


@implementation YXStockDetailTradeStaticVC

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabWidth = 150;
    if (YXUserManager.curLanguage == YXLanguageTypeTH) {
        self.tabView.width = 220;
    }
    self.isOnlyTick = [self.viewModel.params[@"onlyTick"] boolValue];

    [self.view addSubview:self.pageView];
    
    self.navigationItem.titleView = self.tabView;
    
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view.mas_top).offset(YXConstant.navBarHeight);
        }
    }];
    
    if (!self.isOnlyTick) {
       [self.dealStaticVC loadHttpDataWithTimer];
    }
    
    if (@available(iOS 11.0, *)) {        
        self.edgesForExtendedLayout = UIRectEdgeTop;
    }
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.weavesDetailVC cancelTickRequset];    //取消轮询
}



#pragma mark - getter
- (YXTabView *)tabView {
    if (_tabView == nil) {
        YXTabLayout *layout = [YXTabLayout defaultLayout];
        layout.lrMargin = 0;
        layout.tabMargin = 0;
        layout.lineHidden = YES;
        layout.titleSelectedColor = [QMUITheme textColorLevel1];
        layout.titleColor = [QMUITheme textColorLevel3];
        layout.tabSelectedColor = [QMUITheme foregroundColor];
        layout.tabColor = [QMUITheme foregroundColor];
        layout.lineCornerRadius = 0;
        layout.titleFont = [UIFont systemFontOfSize:16];
        layout.titleSelectedFont = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        CGFloat tabHeight = 30;
        _tabView = [[YXTabView alloc] initWithFrame:CGRectMake(0, 0, _tabWidth, tabHeight) withLayout:layout];
        layout.tabWidth = (_tabWidth)/2;
        if (_isOnlyTick) {
            layout.tabWidth = _tabWidth;
        }
        _tabView.backgroundColor = [QMUITheme foregroundColor];
        _tabView.titles = self.titles;
        _tabView.pageView = self.pageView;
        _tabView.delegate = self;
        NSInteger index = [self.viewModel.params[@"Index"] integerValue];
        [self.tabView setDefaultSelectedIndex:index];
    }
    
    return _tabView;
}
- (YXPageView *)pageView {
    if (_pageView == nil) {
        _pageView = [[YXPageView alloc] initWithFrame:self.view.bounds];
        _pageView.parentViewController = self;
        _pageView.viewControllers = self.viewControllers;
        _pageView.contentView.scrollEnabled = YES;
    }
    return _pageView;
}
- (NSArray<NSString *> *)titles {
    if (_titles == nil) {
        if ([self.viewModel.market isEqualToString:kYXMarketChinaSZ] ||
            [self.viewModel.market isEqualToString:kYXMarketChinaSH]) {
            if (_isOnlyTick) {
                _titles = @[[YXLanguageUtility kLangWithKey:@"stock_detail_tricker2_detail"]];
            } else {
                _titles = @[[YXLanguageUtility kLangWithKey:@"stock_detail_tricker2_detail"], [YXLanguageUtility kLangWithKey:@"stock_deal_transaction_statistics"]];
            }
        } else {
            if (_isOnlyTick) {
                _titles = @[[YXLanguageUtility kLangWithKey:@"stock_detail_tricker_detail"]];
            } else {
                _titles = @[[YXLanguageUtility kLangWithKey:@"stock_detail_tricker_detail"], [YXLanguageUtility kLangWithKey:@"stock_deal_transaction_statistics"]];
            }
        }
    }
    return _titles;
}
- (NSArray<UIViewController *> *)viewControllers {
    if (_viewControllers == nil) {
        if (_isOnlyTick) {
            _viewControllers = @[self.weavesDetailVC];
        } else {
            _viewControllers = @[self.weavesDetailVC, self.dealStaticVC];
        }
    }
    return _viewControllers;
}
- (YXSDWeavesDetailViewController *)weavesDetailVC {
    if (!_weavesDetailVC) {
        _weavesDetailVC = [[YXSDWeavesDetailViewController alloc] initWithViewModel:self.viewModel.weavesVModel];
    }
    return _weavesDetailVC;
}
- (YXSDDealStatisticalVC *)dealStaticVC {
    if (!_dealStaticVC) {
        _dealStaticVC = [[YXSDDealStatisticalVC alloc] initWithViewModel:self.viewModel.staticVModel];
    }
    return _dealStaticVC;
}


#pragma mark - YXTabViewDelegate
- (void)tabView:(YXTabView *)tabView didSelectedItemAtIndex:(NSUInteger)index withScrolling:(BOOL)scrolling {
    
}
@end
