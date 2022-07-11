//
//  YXExchangeDistributionVC.m
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2022/1/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "YXExchangeDistributionVC.h"
#import "uSmartOversea-Swift.h"
#import "YXExchangeDistributionCell.h"
#import "YXSDDealStatisticalVModel.h"
#import "YXExchangeDistributionViewModel.h"
#import "YXExchangeDistributionSectionView.h"
#import <Masonry/Masonry.h>

@interface YXExchangeDistributionVC()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YXExchangeDistributionSectionView *sectionHeaderView;
@property (nonatomic, strong) YXExchangeDistributionViewModel *viewModel;
@property (nonatomic, strong) YXTableView *tableView;


@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *headerIdentifier;

@property (nonatomic, strong) UILabel *timelabel;

// 提示升级
@property (nonatomic, strong) UIView *updateTipView;

@end

@implementation YXExchangeDistributionVC

@dynamic viewModel;     //@dynamic
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)initUI {
    self.identifier = @"YXExchangeDistributionCell";
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 32)];
    headerView.backgroundColor = QMUITheme.foregroundColor;
    self.timelabel.frame = CGRectMake(12, 0, 300, 32);
    [headerView addSubview:self.timelabel];
    
    self.tableView.tableHeaderView = headerView;
    //头部刷新
    YXRefreshHeader *header =  [YXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadExchangeData)];
    self.tableView.mj_header = header;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    
}

- (void)bindViewModel {
    @weakify(self);
    [self.viewModel.loadExchangeDataSubject subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        
        BOOL isShowEmpty = [self.viewModel.market isEqualToString:kYXMarketUS] && [[YXUserManager shared] getLevelWith:kYXMarketUS] != QuoteLevelUsNational;        
        if (isShowEmpty) {        
            NSMutableArray *arrM = [NSMutableArray array];
            for (YXExchangeStatisticalSubModel *model in self.viewModel.exchangeListModel.exchangeData) {
                if (model.exchange == OBJECT_MARKETExchange_Nasdaq) {
                    [arrM addObject:model];
                    break;
                }
            }
            self.viewModel.exchangeListModel.exchangeData = [arrM copy];
        }
        if (self.viewModel.exchangeListModel.latestTime.length > 0) {
            NSString *timeStr = [YXDateHelper commonDateString:self.viewModel.exchangeListModel.latestTime format:YXCommonDateFormatDF_MDYHM scaleType:YXCommonDateScaleTypeScale showWeek:NO];
            self.timelabel.text = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"update_et_time"], timeStr];
            
            
            
        } else {
            self.timelabel.text = @"--";
        }
        if (isShowEmpty) {
            self.updateTipView.frame = CGRectMake(0, 0, YXConstant.screenWidth, self.view.mj_h - 80 - 32);
            self.tableView.tableFooterView = self.updateTipView;
            self.tableView.scrollEnabled = NO;
        } else {
            self.tableView.tableFooterView = [[UIView alloc] init];
            self.tableView.scrollEnabled = YES;
        }
        
        [self.tableView reloadData];
    }];
}

//加载Statistical数据
- (void)loadExchangeData {

    [self.viewModel.loadExchangeDataCommand execute: nil];
}

- (void)refreshWithBidOrAskType: (NSInteger)bidOrAskType andMarketTimeType: (NSInteger)marketTimeType andTradeDay:(NSString *)tradeDay {
            
    self.viewModel.requestModel.bidOrAskType = bidOrAskType;
    self.viewModel.requestModel.marketTimeType = marketTimeType;
    self.viewModel.requestModel.tradeDay = tradeDay;
    [self loadExchangeData];

}


#pragma mark - delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.viewModel.exchangeListModel.exchangeData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YXExchangeDistributionCell *cell = [tableView dequeueReusableCellWithIdentifier:self.identifier];
        
    RACChannelTerminal *channel = RACChannelTo(self.viewModel, contentOffset);
    RACChannelTerminal *cellChannel = RACChannelTo(cell.scrollView, contentOffset);
        
    [cell refreshWithModel:self.viewModel.exchangeListModel.exchangeData[indexPath.row] andMaxVolumn:self.viewModel.exchangeListModel.totalTradeVol andPriceBase:self.viewModel.exchangeListModel.priceBase];
    
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

- (YXTableView *)tableView{
    if (!_tableView) {
        _tableView = [[YXTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[YXExchangeDistributionCell class] forCellReuseIdentifier: self.identifier];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 42;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (YXExchangeDistributionSectionView *)sectionHeaderView {
    if (_sectionHeaderView == nil) {
        _sectionHeaderView = [[YXExchangeDistributionSectionView alloc] init];
        RACChannelTo(self.viewModel, contentOffset) = RACChannelTo(_sectionHeaderView.scrollView, contentOffset);
    }
    return _sectionHeaderView;
}

- (UILabel *)timelabel {
    if (_timelabel == nil) {
        _timelabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:10]];
        
    }
    return _timelabel;
}

- (UIView *)updateTipView {
    if (_updateTipView == nil) {
        _updateTipView = [[UIView alloc] init];
                
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exchange_distribution_empty"]];
        UILabel *tipLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"check_usnational_exchange_tip"] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14]];
        UIButton *updateBtn = [UIButton buttonWithType:UIButtonTypeCustom title:[YXLanguageUtility kLangWithKey:@"upgrade_immediately"] font:[UIFont systemFontOfSize:14] titleColor:UIColor.whiteColor target:self action:@selector(updataBtnClick:)];
        updateBtn.layer.cornerRadius = 4;
        updateBtn.clipsToBounds = true;
        updateBtn.backgroundColor = QMUITheme.themeTextColor;
        
        [_updateTipView addSubview:bgImageView];
        [_updateTipView addSubview:tipLabel];
        [_updateTipView addSubview:updateBtn];
        
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.updateTipView);
        }];
        [updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.updateTipView).offset(10);
            make.centerX.equalTo(self.updateTipView);
            make.width.mas_equalTo(115);
            make.height.mas_equalTo(40);
        }];
        
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.updateTipView);
            make.bottom.equalTo(updateBtn.mas_top).offset(-16);
        }];
    }
    return _updateTipView;
}

- (void)updataBtnClick:(UIButton *)sender {    
    [YXWebViewModel pushToWebVC:[YXH5Urls myQuotesUrlWithTab:1 levelType:2]];
}


#pragma mark - super class methods

@end
