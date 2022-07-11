//
//  YXStatisticalPriceDistributionVC.m
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2022/1/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "YXStatisticalPriceDistributionVC.h"
#import "uSmartOversea-Swift.h"
#import "YXDealStatisticalTableViewCell.h"
#import "YXDealStatisticalTableHeadView.h"
#import "YXSDDealStatisticalVModel.h"
#import "YXSDDealStatisticalHeaderView.h"
#import "YXStatisticalPriceDistributionViewModel.h"
#import <Masonry/Masonry.h>

@interface YXStatisticalPriceDistributionVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YXStatisticalPriceDistributionViewModel *viewModel;
@property (nonatomic, strong) YXSDDealStatisticalHeaderView *sectionHeaderView;
@property (nonatomic, strong) YXTableView *tableView;
@property (nonatomic, strong) YXDealStatisticalTableHeadView *headView;


@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *headerIdentifier;

@property (nonatomic, strong) YXAnalysisStatisticData *statisticData;

@end

@implementation YXStatisticalPriceDistributionVC
@dynamic viewModel;     //@dynamic
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 取消
    [self.viewModel.statisticRequset cancel];
}

- (void)initUI {
    self.identifier = @"YXSDDealStatisticalVCCell";
    
    //头部刷新
    YXRefreshHeader *header =  [YXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadStatisticalData)];
    self.tableView.mj_header = header;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    
}

- (void)bindViewModel {
    @weakify(self);
    [self.viewModel.loadStatisticSubject subscribeNext:^(YXAnalysisStatisticData *sData) {
        @strongify(self);
        self.statisticData = sData;
    }];
    
    [self.headView setRefreshCount:^(NSInteger index) {
        @strongify(self);
        self.viewModel.requestModel.type = index;

        [self loadStatisticalData];
    }];
    
    [self.sectionHeaderView setRefreshData:^(NSInteger sortType, NSInteger sortMode) {
        @strongify(self);
        self.viewModel.requestModel.sortType = sortType;
        self.viewModel.requestModel.sortMode = sortMode;
        [self loadStatisticalData];
    }];
}

- (void)resetSelectBtn {
    [self.sectionHeaderView resetSelectBtn];
}

//加载Statistical数据
- (void)loadStatisticalData {
    /* http://szshowdoc.youxin.com/web/#/23?page_id=662 -->
    quotes-analysis(行情分析服务) --> v1 --> 成交统计接口
    quotes-analysis-app/api/v1/statistic
     type: 类型：0：最近20条，1：最近50条，2：全部 */
    [self.viewModel.loadStatisticDataCommand execute:@{@"isMore": @"0"}];
}

- (void)refreshWithBidOrAskType: (NSInteger)bidOrAskType andMarketTimeType: (NSInteger)marketTimeType andTradeDay:(NSString *)tradeDay {
    // 是否要重置排序的类型
    if (bidOrAskType == 1) {
        // 主买
        if (self.viewModel.requestModel.sortType == 2 || self.viewModel.requestModel.sortType == 3) {
            [self.sectionHeaderView resetSelectBtn];
            self.viewModel.requestModel.sortType = 0;
            self.viewModel.requestModel.sortMode = 0;
        }
    } else if (bidOrAskType == 2) {
        // 主卖
        if (self.viewModel.requestModel.sortType == 1 || self.viewModel.requestModel.sortType == 3) {
            [self.sectionHeaderView resetSelectBtn];
            self.viewModel.requestModel.sortType = 0;
            self.viewModel.requestModel.sortMode = 0;
        }
    } else if (bidOrAskType == 4) {
        // 中性盘
        if (self.viewModel.requestModel.sortType == 1 || self.viewModel.requestModel.sortType == 2) {
            [self.sectionHeaderView resetSelectBtn];
            self.viewModel.requestModel.sortType = 0;
            self.viewModel.requestModel.sortMode = 0;
        }
    }
    
    self.sectionHeaderView.bidOrAskType = bidOrAskType;
    
    self.viewModel.requestModel.bidOrAskType = bidOrAskType;
    self.viewModel.requestModel.marketTimeType = marketTimeType;
    self.viewModel.requestModel.tradeDay = tradeDay;
    [self loadStatisticalData];

}

#pragma mark - delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.statisticData.priceData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YXDealStatisticalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.identifier];
    
    [cell refreshWith:self.statisticData.priceData[indexPath.row] priceBase:self.statisticData.priceBase.value pClose:self.viewModel.pClose maxVolume:self.viewModel.maxVolume];
    
    RACChannelTerminal *channel = RACChannelTo(self.viewModel, contentOffset);
    RACChannelTerminal *cellChannel = RACChannelTo(cell.scrollView, contentOffset);
    
    [[channel takeUntil:cell.rac_prepareForReuseSignal] subscribe:cellChannel];
    [[cellChannel takeUntil:cell.rac_prepareForReuseSignal] subscribe:channel];
    
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    return self.sectionHeaderView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}


#pragma mark - setter
- (void)setStatisticData:(YXAnalysisStatisticData *)statisticData {
    _statisticData = statisticData;
    self.headView.statisData = statisticData;
    
    [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
    
}

- (YXDealStatisticalTableHeadView *)headView {
    if (!_headView) {
        _headView = [[YXDealStatisticalTableHeadView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 390)];
        
    }
    return _headView;
}


- (YXTableView *)tableView{
    if (!_tableView) {
        _tableView = [[YXTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[YXDealStatisticalTableViewCell class] forCellReuseIdentifier: self.identifier];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 40;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = self.headView;
    }
    return _tableView;
}

- (YXSDDealStatisticalHeaderView *)sectionHeaderView {
    if (_sectionHeaderView == nil) {
        _sectionHeaderView = [[YXSDDealStatisticalHeaderView alloc] init];
        RACChannelTo(self.viewModel, contentOffset) = RACChannelTo(_sectionHeaderView.scrollView, contentOffset);
    }
    return _sectionHeaderView;
}


#pragma mark - super class methods

@end
