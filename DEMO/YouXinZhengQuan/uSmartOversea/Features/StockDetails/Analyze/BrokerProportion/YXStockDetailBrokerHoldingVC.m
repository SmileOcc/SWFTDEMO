//
//  YXStockDetailBrokerHoldingVC.m
//  uSmartOversea
//
//  Created by youxin on 2020/2/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockDetailBrokerHoldingVC.h"
#import "YXStockDetailBrokerTradeVC.h"
#import "YXStockDetailBrokerRatioVC.h"
#import "YXStockDetailBrokerHoldingVModel.h"
#import <YXKit/YXKit.h>
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

@interface YXStockDetailBrokerHoldingVC ()<YXTabViewDelegate>

@property (nonatomic, strong) YXTapButtonView *tapButtonView;
@property (nonatomic, strong) YXPageView *pageView;
@property (nonatomic, strong) YXStockTopView *topView;

@property (nonatomic, strong) NSArray<NSString *> *titles;
@property (nonatomic, strong) NSArray<__kindof UIViewController *> *viewControllers;

@property (nonatomic, strong) YXStockDetailBrokerTradeVC *tradeVC;
@property (nonatomic, strong) YXStockDetailBrokerRatioVC *ratioVC;

@property (nonatomic, strong, readonly) YXStockDetailBrokerHoldingVModel *viewModel;


@end


@implementation YXStockDetailBrokerHoldingVC

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [YXLanguageUtility kLangWithKey:@"broker_stock"];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self initUI];
    [self bindViewModel];

    [self.ratioVC loadHttpDataWithTimer];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel.loadBasicQuotaDataCommand execute:nil];
    [self.tradeVC.viewModel openTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel cancelRequest];
    [self.tradeVC.viewModel closeTimer];
}


- (void)initUI {

    self.view.backgroundColor = QMUITheme.foregroundColor;

    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(70);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view.mas_top).offset(YXConstant.navBarHeight);
        }
    }];

    [self.view addSubview:self.tapButtonView];
    [self.tapButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(16);
        make.trailing.equalTo(self.view).offset(-16);
        make.height.mas_equalTo(30);
        make.top.equalTo(self.topView.mas_bottom).offset(32);
    }];

    [self.view addSubview:self.pageView];
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.tapButtonView.mas_bottom);
    }];

    if (self.viewModel.selectIndex == 1) {
        [self.tapButtonView resetSelectIndex:1];
        [self.pageView.contentView setContentOffset:CGPointMake( YXConstant.screenWidth, 0) animated:NO];
    }
}


- (void)bindViewModel {

    @weakify(self)

    [self.viewModel.loadBasicQuotaDataSubject subscribeNext:^(id  _Nullable x){
        @strongify(self);
        //结束刷新
        YXV2Quote *quoteModel = self.viewModel.quotaModel;
        if (quoteModel == nil) {
            return;
        }
        self.topView.model = quoteModel;
    }];

    self.tapButtonView.tapAction = ^(NSInteger index) {
        @strongify(self);
        [self.pageView.contentView setContentOffset:CGPointMake(index * YXConstant.screenWidth, 0) animated:NO];
    };
}


#pragma mark - lazy load | getter
- (YXStockTopView *)topView {
    if (!_topView) {
        _topView = [[YXStockTopView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 70)];
        _topView.seperatorView.hidden = NO;
    }
    return _topView;
}


- (YXTapButtonView *)tapButtonView {
    if (!_tapButtonView) {
        _tapButtonView = [[YXTapButtonView alloc] initWithTitles:self.titles];
    }
    return _tapButtonView;
}

- (YXPageView *)pageView {
    if (_pageView == nil) {
        _pageView = [[YXPageView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, YXConstant.screenHeight - YXConstant.navBarHeight - 70 - 62)];
        _pageView.parentViewController = self;
        _pageView.viewControllers = self.viewControllers;
        _pageView.contentView.scrollEnabled = NO;
    }
    return _pageView;
}

- (NSArray<NSString *> *)titles {
    if (_titles == nil) {
        _titles = @[[YXLanguageUtility kLangWithKey:@"broker_buy_sell"], [YXLanguageUtility kLangWithKey:@"broker_percent"]];
    }
    return _titles;
}

- (NSArray<UIViewController *> *)viewControllers {
    if (_viewControllers == nil) {
        _viewControllers = @[self.tradeVC, self.ratioVC];
    }
    return _viewControllers;
}

- (YXStockDetailBrokerTradeVC *)tradeVC {
    if (!_tradeVC) {
        _tradeVC = [[YXStockDetailBrokerTradeVC alloc] initWithViewModel:self.viewModel.tradeVModel];
    }
    return _tradeVC;
}

- (YXStockDetailBrokerRatioVC *)ratioVC {
    if (!_ratioVC) {
        _ratioVC = [[YXStockDetailBrokerRatioVC alloc] initWithViewModel:self.viewModel.ratioVModel];
    }
    return _ratioVC;
}


@end
