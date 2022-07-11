//
//  YXSDDealStatisticalVC.m
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXSDDealStatisticalVC.h"
#import "YXSDWeavesDetailTopView.h"
#import "YXSDDealStatisticalHeaderView.h"
#import "YXDealStatisticalTypeHeaderView.h"

#import "YXSDDealStatisticalVModel.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

#import "YXStatisticalPriceDistributionVC.h"
#import "YXStatisticalPriceDistributionViewModel.h"

#import "YXExchangeDistributionVC.h"
#import "YXExchangeDistributionViewModel.h"


@interface YXSDDealStatisticalVC ()

@property (nonatomic, strong)YXSDWeavesDetailTopView * topView;

//1.5 viewModel
@property (nonatomic, strong) YXSDDealStatisticalVModel *viewModel;
@property (nonatomic, assign) BOOL isStockTypeConfirmed; //股票类型是否已经确定


@property (nonatomic, strong) YXDealStatisticalTypeHeaderView *typeView;

// 定时器
@property (nonatomic, assign) YXTimerFlag resetTimer;

@property (nonatomic, strong) YXStatisticalPriceDistributionVC *priceVC;
@property (nonatomic, strong) YXStatisticalPriceDistributionViewModel *priceViewModel;

@property (nonatomic, strong) YXExchangeDistributionVC *exchangeVC;
@property (nonatomic, strong) YXExchangeDistributionViewModel *exchangeViewModel;


@end

@implementation YXSDDealStatisticalVC

@dynamic viewModel;     //@dynamic

- (void)viewDidLoad {
    [super viewDidLoad];
            
    [self loadTradeDate];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.resetTimer == 0) {
        [self loadHttpData];

        [self setUpQuoteTimer];
    }
}



- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (self.resetTimer > 0) {
        [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.resetTimer];
        self.resetTimer = 0;
    }

    [self.viewModel.quoteRequset cancel];
}


- (void)loadHttpDataWithTimer {
    
    [self initUI];
    
    [self loadHttpData];
    [self setUpQuoteTimer];

}

- (void)setUpQuoteTimer {
    // 开启定时器
    if (self.resetTimer > 0) {
        [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.resetTimer];
    }
    NSTimeInterval interval = [YXGlobalConfigManager configFrequency:YXGlobalConfigParameterTypeQuotesResendFreq];
    @weakify(self);
    self.resetTimer = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
        @strongify(self);

        [self.priceViewModel.statisticRequset cancel];

        [self loadHttpData];
    } timeInterval:interval repeatTimes:NSIntegerMax atOnce:NO];
}

- (void)bindViewModel {
    @weakify(self);
    [self.viewModel.loadBasicQuotaDataSubject subscribeNext:^(id  _Nullable x){
        @strongify(self);
        //结束刷新
        YXV2Quote *quoteModel = self.viewModel.quotaModel;
        if (quoteModel == nil) {
            return;
        }
        // 添加底部的vc
        if (!self.isStockTypeConfirmed) {
            self.isStockTypeConfirmed = YES;
            // 请求其他接口数据
            [self loadSubVCData];
        }
        self.topView.quote = quoteModel;
        
    }];
    

}

#pragma mark - 3.1 http data
- (void)loadHttpData{
    [self loadQuoteData];
    if (self.isStockTypeConfirmed) {
        [self loadSubVCData];
    }
}
- (void)loadQuoteData {
    [self.viewModel.loadBasicQuotaDataCommand execute:nil];
}

- (void)loadTradeDate {
    @weakify(self);
    [[self.viewModel.loadTradeDateCommand execute:nil] subscribeNext:^(NSArray *list) {
        @strongify(self);
        self.typeView.tradeDateList = list;
    }];
}

- (void)loadSubVCData {
    if (self.isStockTypeConfirmed) {
        [self.priceVC loadStatisticalData];
        if ([self.viewModel.market isEqualToString:kYXMarketUS]) {
            [self.exchangeVC loadExchangeData];
        }
    }
}

- (void)initUI {
    
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    YXDealStatisticalTypeHeaderView *typeView = [[YXDealStatisticalTypeHeaderView alloc] initWithFrame:CGRectZero andMarket:self.viewModel.market];
    self.typeView = typeView;
    
    @weakify(self);
    if ([self.viewModel.market isEqualToString:kYXMarketUS]) {
        self.typeView.tapButtonView.tapAction = ^(NSInteger index) {
            @strongify(self);
            if (index == 0) {
                self.priceVC.view.hidden = NO;
                self.exchangeVC.view.hidden = YES;
            } else {
                self.priceVC.view.hidden = YES;
                self.exchangeVC.view.hidden = NO;
            }
        };
    }
    
    // 重置市场状态
    if ([self.viewModel.market isEqualToString:kYXMarketUS]) {
        if (self.viewModel.timeShareType != YXTimeShareLineTypeAll) {
            [self.typeView updateMarketType:self.viewModel.timeShareType];
            if (self.viewModel.timeShareType == YXTimeShareLineTypePre) {
                self.priceViewModel.requestModel.marketTimeType = 1;
                self.exchangeViewModel.requestModel.marketTimeType = 1;
            } else if (self.viewModel.timeShareType == YXTimeShareLineTypeIntra) {
                self.priceViewModel.requestModel.marketTimeType = 0;
                self.exchangeViewModel.requestModel.marketTimeType = 0;
            } else if (self.viewModel.timeShareType == YXTimeShareLineTypeAfter) {
                self.priceViewModel.requestModel.marketTimeType = 2;
                self.exchangeViewModel.requestModel.marketTimeType = 2;
            }
        }
    }
    

    [typeView setRefreshDataCallBack:^(NSInteger bidOrAskType, NSInteger marketTimeType, NSString * _Nonnull tradeDay) {
        @strongify(self);
        
        [self.priceVC refreshWithBidOrAskType:bidOrAskType andMarketTimeType:marketTimeType andTradeDay:tradeDay];
        if ([self.viewModel.market isEqualToString:kYXMarketUS]) {
            [self.exchangeVC refreshWithBidOrAskType:bidOrAskType andMarketTimeType:marketTimeType andTradeDay:tradeDay];
        }
    }];
    
    [self.view addSubview:typeView];
    [typeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);        
        make.top.equalTo(self.topView.mas_bottom).offset(6);
    }];
        
    UIView *contentView = [[UIView alloc] init];
    [contentView addSubview:self.priceVC.view];
    [self addChildViewController:self.priceVC];
    [self.priceVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView);
    }];
    
    if ([self.viewModel.market isEqualToString:kYXMarketUS]) {
        [contentView addSubview:self.exchangeVC.view];
        [self addChildViewController:self.exchangeVC];
        self.exchangeVC.view.hidden = YES;
        [self.exchangeVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(contentView);
        }];
    }
        

    [self.view addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(typeView.mas_bottom);
    }];
}

#pragma mark - lazy load | getter

- (YXStatisticalPriceDistributionVC *)priceVC {
    if (_priceVC == nil) {        
        _priceVC = [[YXStatisticalPriceDistributionVC alloc] initWithViewModel:self.priceViewModel];
    }
    return _priceVC;
}

-  (YXStatisticalPriceDistributionViewModel *)priceViewModel {
    if (!_priceViewModel) {
        _priceViewModel = [[YXStatisticalPriceDistributionViewModel alloc] initWithServices:self.viewModel.services params:self.viewModel.params];
    }
    return _priceViewModel;
}


- (YXExchangeDistributionVC *)exchangeVC {
    if (_exchangeVC == nil) {
        _exchangeVC = [[YXExchangeDistributionVC alloc] initWithViewModel:self.exchangeViewModel];
    }
    return _exchangeVC;
}

-  (YXExchangeDistributionViewModel *)exchangeViewModel {
    if (!_exchangeViewModel) {
        _exchangeViewModel = [[YXExchangeDistributionViewModel alloc] initWithServices:self.viewModel.services params:self.viewModel.params];
    }
    return _exchangeViewModel;
}

- (YXSDWeavesDetailTopView *)topView {
    if (!_topView) {
        _topView = [[YXSDWeavesDetailTopView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 69)];
    }
    return _topView;
}

#pragma mark - super class methods

@end
