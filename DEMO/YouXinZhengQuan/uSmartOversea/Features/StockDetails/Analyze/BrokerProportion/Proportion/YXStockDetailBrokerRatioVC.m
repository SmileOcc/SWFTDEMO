//
//  YXStockDetailBrokerRatioVC.m
//  uSmartOversea
//
//  Created by youxin on 2020/2/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockDetailBrokerRatioVC.h"
#import "uSmartOversea-Swift.h"
#import "YXStockAnalyzeBrokerListModel.h"
#import "UILabel+create.h"
#import <Masonry/Masonry.h>
#import <YXKit/YXKit.h>

@interface YXStockDetailBrokerRatioVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YXTableView *tableView;

@property (nonatomic, strong) YXStockEmptyDataView *noDataView;

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, strong, readwrite) YXStockDetailBrokerRatioVModel *viewModel;
@end

@implementation YXStockDetailBrokerRatioVC
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.identifier = @"YXStockDetailBrokerRatioCell";

}

- (void)loadHttpDataWithTimer {
    [self initUI];
    [self bindViewModel];
    [self loadBrokerShareHoldingData];
}

- (void)initUI {

    self.view.backgroundColor = QMUITheme.foregroundColor;

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(self.view);
        make.top.equalTo(self.view);
    }];

    [self.view addSubview:self.noDataView];
    [self.noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.tableView);
    }];
}

#pragma mark - delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.viewModel.dataSource.blist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YXStockDetailBrokerRatioCell *cell = [tableView dequeueReusableCellWithIdentifier:self.identifier];
    if (indexPath.row < self.viewModel.dataSource.blist.count) {
        YXStockAnalyzeBrokerListDetailInfo *info = self.viewModel.dataSource.blist[indexPath.row];
        [cell.buyView drawProgressWithName:self.viewModel.brokerDic[info.brokerCode] maxValue:self.viewModel.maxValue currentValue:info.holdRatio base:10000 pointCount:2 emptyString:@""];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 84;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 84)];
    headerView.backgroundColor = [QMUITheme foregroundColor];
    UILabel *timeLabel = [UILabel labelWithText:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"broker_buy_sell_history_update_tip"], @"--"] textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    UILabel *totalLabel = [UILabel labelWithText:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"broker_total_count"], @"--", @"--"] textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft];
    totalLabel.adjustsFontSizeToFitWidth = YES;
    totalLabel.minimumScaleFactor = 0.3;

    [headerView addSubview:totalLabel];
    [headerView addSubview:timeLabel];

    [totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(16);
        make.top.equalTo(headerView).offset(24);
        make.right.equalTo(headerView).offset(-16);
    }];

    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(16);
        make.top.equalTo(totalLabel.mas_bottom).offset(10);
        make.right.equalTo(headerView).offset(-16);
    }];

    if (self.viewModel.dataSource.blist.count > 0) {
        NSString *timeString = [YXDateHelper commonDateStringWithNumber:self.viewModel.dataSource.latestTime format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:NO];
        timeLabel.text = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"broker_buy_sell_history_update_tip"], timeString];
        NSString *ratioString = [NSString stringWithFormat:@"%.02f%%", self.viewModel.dataSource.totalHoldRatio * 1.0 / 100.0];
        totalLabel.text = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"broker_total_count"], @(self.viewModel.dataSource.brokerCount).stringValue, ratioString];
    }

    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.viewModel.dataSource.blist.count) {
        [self.viewModel.pushToBrokerDetailCommand execute:@{@"index" : @(indexPath.row),
                                                            @"brokerInfo" : self.viewModel.brokerNamesArray
        }];
    }
}

- (void)loadBrokerShareHoldingData {
    @weakify(self)
    [[self.viewModel.brokerShareHoldingDataCommand execute:nil] subscribeNext:^(YXStockAnalyzeBrokerListModel *model) {
        @strongify(self);
        if (model.blist.count <= 0) {
            self.noDataView.hidden = NO;
            return;
        } else {
            self.noDataView.hidden = YES;
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - lazy load | getter

- (YXTableView *)tableView{
    if (!_tableView) {
        _tableView = [[YXTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[YXStockDetailBrokerRatioCell class] forCellReuseIdentifier: self.identifier];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.bounces = false;
    }
    return _tableView;
}

- (YXStockEmptyDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[YXStockEmptyDataView alloc] init];
        _noDataView.hidden = YES;
    }
    return _noDataView;
}


@end
