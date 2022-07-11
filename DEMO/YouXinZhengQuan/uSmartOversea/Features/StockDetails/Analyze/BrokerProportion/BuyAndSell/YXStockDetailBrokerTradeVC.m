//
//  YXStockDetailBrokerTradeVC.m
//  uSmartOversea
//
//  Created by youxin on 2020/2/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockDetailBrokerTradeVC.h"
#import "YXSDWeavesDetailTopView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXStockDetailBrokerTradeVC ()

@property (nonatomic, strong) YXStockAnalyzeTradeView *tradeView;

@property (nonatomic, strong) UIScrollView *chartScrollView;

@property (nonatomic, readwrite) YXStockDetailBrokerTradeVModel *viewModel;
@end

@implementation YXStockDetailBrokerTradeVC
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    [self bindViewModel];
    [self loadBrokerListData];
}

- (void)initUI {

    self.view.backgroundColor = QMUITheme.foregroundColor;


    [self.view addSubview:self.chartScrollView];
    [self.chartScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.view);
    }];

    [self.chartScrollView addSubview:self.tradeView];
    [self.tradeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.chartScrollView);
        make.right.equalTo(self.view);
        make.top.equalTo(self.chartScrollView).offset(4);
        make.bottom.equalTo(self.chartScrollView).offset(-30);
    }];
}


- (void)bindViewModel {

    @weakify(self)
    [self.viewModel.brokerTimerSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (self.viewModel.brokerType == 0) {
            [self loadBrokerListData];
        }
    }];

    self.tradeView.clickBlock = ^(NSDictionary *dic) {
        @strongify(self)
        [self.viewModel.pushToBrokerDetailCommand execute:dic];
    };

    self.tradeView.tabClickBlock = ^(NSInteger type) {
        @strongify(self)
        self.viewModel.brokerType = (int)type;
        [self loadBrokerListData];
    };
}


- (void)loadBrokerListData {
    @weakify(self)
    [[self.viewModel.brokerListDataCommand execute:nil] subscribeNext:^(YXStockAnalyzeBrokerListModel *model) {
        @strongify(self);
        self.tradeView.model = model;
    }];
}

#pragma mark - lazy load | getter

- (UIScrollView *)chartScrollView {
    if (_chartScrollView == nil) {
        _chartScrollView = [[UIScrollView alloc] init];
        _chartScrollView.showsVerticalScrollIndicator = NO;
        _chartScrollView.showsHorizontalScrollIndicator = NO;
        _chartScrollView.backgroundColor = [QMUITheme foregroundColor];
        _chartScrollView.bounces = YES;
    }
    return _chartScrollView;
}

- (YXStockAnalyzeTradeView *)tradeView {
    if (!_tradeView) {
        _tradeView = [[YXStockAnalyzeTradeView alloc] initWithFrame:CGRectZero level:self.viewModel.level itemCount:10 defaultTabSelectIndex: self.viewModel.brokerType];
        _tradeView.brokerDic = self.viewModel.brokerDic;
    }
    return _tradeView;
}

@end
