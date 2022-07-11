//
//  YXBrokerDetailVC.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXBrokerDetailVC.h"
#import "YXBrokerDetailViewModel.h"
#import "uSmartOversea-Swift.h"
#import "YXBrokerLineView.h"
#import "YXBrokerDetailCell.h"
#import "YXBrokerSectionHeaderView.h"
#import <Masonry/Masonry.h>
#import <YXKit/YXKit.h>

@interface YXBrokerDetailVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YXStockTopView *stockView;

@property (nonatomic, strong) YXQuoteRequest *quoteRequset;

@property (nonatomic, strong) YXBrokerDetailViewModel *viewModel;

@property (nonatomic, strong) YXBrokerDetailTitleView *topTitleView;

@property (nonatomic, strong) YXBrokerLineView *lineView;

@property (nonatomic, strong) YXTableView *tableView;

@property (nonatomic, strong) UILabel *updateTimeLabel;

@property (nonatomic, strong) YXStockEmptyDataView *noDataView;

@end

@implementation YXBrokerDetailVC
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [YXLanguageUtility kLangWithKey:@"broker_stock_detail"];
    
    [self loadLineData];
    
    [self initUI];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadQuoteData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.quoteRequset cancel];
}

- (void)initUI {
    
    self.view.backgroundColor = QMUITheme.foregroundColor;
    [self.view addSubview:self.stockView];
    [self.stockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view.mas_top).offset(YXConstant.navBarHeight);
        }
        make.height.mas_equalTo(70);
    }];
    

    [self.view addSubview:self.topTitleView];
    [self.topTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stockView.mas_bottom);
        make.height.mas_equalTo(50);
        make.leading.trailing.equalTo(self.view);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[YXBrokerDetailCell class] forCellReuseIdentifier:@"YXBrokerDetailCell"];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topTitleView.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 410)];
    [headView addSubview:self.updateTimeLabel];
    [headView addSubview:self.lineView];
    self.tableView.tableHeaderView = headView;
    @weakify(self);
    YXRefreshAutoNormalFooter *footer = [YXRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self loadMoreLineData];
    }];
    self.tableView.mj_footer = footer;
    
    [self.view addSubview:self.noDataView];
    [self.noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.topTitleView.mas_bottom);
    }];
}

- (void)bindViewModel {
    @weakify(self);
    [self.topTitleView setClickCallBack:^(NSInteger index) {
        @strongify(self);
        self.viewModel.selecIndex = index;
        [self.lineView resetData];
        [self loadLineData];
    }];
}

- (void)loadQuoteData {
    @weakify(self);
    [self.quoteRequset cancel];
    Secu *secu = [[Secu alloc] initWithMarket:self.viewModel.market symbol:self.viewModel.symbol];
    self.quoteRequset = [[YXQuoteManager sharedInstance] subRtSimpleQuoteWithSecus:@[secu] level:QuoteLevelLevel2 handler:^(NSArray<YXV2Quote *> * _Nonnull list, enum Scheme scheme) {
        @strongify(self);
        self.stockView.model = list.firstObject;
    } failed:^{
        
    }];
}

- (void)loadLineData {
    @weakify(self);
    [[self.viewModel.loadCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.lineView.klineModel = self.viewModel.model;
        [self.tableView reloadData];
        
        if (self.viewModel.model.latestTime.length > 0) {
            NSString *timeString = [YXDateHelper commonDateString:self.viewModel.model.latestTime format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:NO];
            self.updateTimeLabel.text = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"broker_buy_sell_history_update_tip"], timeString];
        }
        if (self.lineView.klineModel.hasMore) {
            [self.tableView.mj_footer resetNoMoreData];
        }
        
        if (self.viewModel.model.list.count == 0) {
            self.noDataView.hidden = NO;
        } else {
            self.noDataView.hidden = YES;
        }
    }];
    
    [self.lineView setLoadMoreCallBack:^{
        @strongify(self);
        [self loadMoreLineData];
    }];
    
}

- (void)loadMoreLineData {
    @weakify(self);
    [[self.viewModel.loadMoreCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (!self.viewModel.model.hasMore) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer endRefreshing];
        }
        self.lineView.klineModel = self.viewModel.model;
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.model.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YXBrokerDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YXBrokerDetailCell" forIndexPath:indexPath];
    
    cell.priceBase = self.viewModel.model.priceBase;
    YXBrokerDetailSubModel *model = self.viewModel.model.list[indexPath.row];
    cell.subModel = model;
    
    RACChannelTerminal *channel = RACChannelTo(self.viewModel, contentOffset);
    RACChannelTerminal *cellChannel = RACChannelTo(cell.scrollView, contentOffset);
    
    [[channel takeUntil:cell.rac_prepareForReuseSignal] subscribe:cellChannel];
    [[cellChannel takeUntil:cell.rac_prepareForReuseSignal] subscribe:channel];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    YXBrokerSectionHeaderView *headerView = [[YXBrokerSectionHeaderView alloc] init];
    RACChannelTo(self.viewModel, contentOffset) = RACChannelTo(headerView.scrollView, contentOffset);
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - 懒加载
- (YXStockTopView *)stockView {
    if (_stockView == nil) {
        _stockView = [[YXStockTopView alloc] init];
        _stockView.seperatorView.hidden = NO;
    }
    return _stockView;
}

- (YXBrokerDetailTitleView *)topTitleView {
    if (_topTitleView == nil) {
        _topTitleView = [[YXBrokerDetailTitleView alloc] init];
        _topTitleView.backgroundColor = QMUITheme.foregroundColor;
        _topTitleView.list = self.viewModel.brokerList;
        _topTitleView.selectIndex = self.viewModel.selecIndex;
    }
    return _topTitleView;
}

- (YXBrokerLineView *)lineView {
    if (_lineView == nil) {
        _lineView = [[YXBrokerLineView alloc] initWithFrame:CGRectMake(16, 20, YXConstant.screenWidth - 32, 370) andType:YXBrokerLineTypeBroker];
        _lineView.backgroundColor = QMUITheme.foregroundColor;
    }
    return _lineView;
}

- (YXTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[YXTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 38;
        _tableView.backgroundColor = QMUITheme.foregroundColor;
    }
    return _tableView;
}

- (UILabel *)updateTimeLabel {
    if (_updateTimeLabel == nil) {
        _updateTimeLabel = [UILabel labelWithText:@"" textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:10]];
        _updateTimeLabel.frame = CGRectMake(16, 0, 300, 20);
    }
    return _updateTimeLabel;
}

- (YXStockEmptyDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[YXStockEmptyDataView alloc] init];
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

@end
