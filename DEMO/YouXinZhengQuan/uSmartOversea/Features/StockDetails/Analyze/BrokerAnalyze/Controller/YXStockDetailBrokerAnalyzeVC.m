//
//  YXStockDetailBrokerAnalyzeVC.m
//  uSmartOversea
//
//  Created by youxin on 2020/3/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockDetailBrokerAnalyzeVC.h"
#import "YXStockDetailAnalyzeViewModel.h"
#import "YXStockAnalyzeBrokerListModel.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import <YXKit/YXKit.h>
#import "YXBrokerAnalyzeView.h"


@interface YXStockDetailBrokerAnalyzeVC ()<UIScrollViewDelegate>

@property (nonatomic, strong) YXStockDetailAnalyzeViewModel *viewModel;

@property (nonatomic, strong) YXStockAnalyzeBrokerHoldingsView *brokerHoldingsView;

@property (nonatomic, assign) BOOL isLoaded;

@property (nonatomic, assign) BOOL needShowBrokerList;

@property (nonatomic, strong) YXBrokerAnalyzeView *sellView;

@property (nonatomic, strong) YXBrokerAnalyzeView *hkVolumnView;

@property (nonatomic, strong) YXStockAnalyzeWarrantCbbcScoreView *warrantCbbcScoreView;

@property (nonatomic, assign) BOOL needShowHKVolumn;

@property (nonatomic, assign) BOOL needShowSell;

@property (nonatomic, assign) BOOL needShowScore;

@property (nonatomic, assign) BOOL needShowTechnical;

@property (nonatomic, assign) BOOL needShowEstimated;

@property (nonatomic, assign) BOOL needShowWarrantCbbc;

@property (nonatomic, strong) UIView *sellPercentView;

@property (nonatomic, strong) YXStockEmptyDataView *noDataView;

@property (nonatomic, strong) YXStockSmartScoreView *scoreView;

@property (nonatomic, strong) YXStockAnalyzeTechnicalView *technicalView;

@property (nonatomic, strong) YXStockAnylzeEstimatedView *estimatedView;

@property (nonatomic, strong) NSString *estimatedItemStr;

@property (nonatomic, strong) UIStackView *stackView;

@end

@implementation YXStockDetailBrokerAnalyzeVC
@dynamic viewModel;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.estimatedItemStr = @"pe";
    
    BOOL isHK = [self.viewModel.market isEqualToString:kYXMarketHK];
    //self.needShowScore = !self.viewModel.greyFlag && (isHK || [self.viewModel.market isEqualToString:kYXMarketUS]) && self.viewModel.isStock;
    self.needShowScore = NO;
    self.needShowBrokerList = isHK  && self.viewModel.isStock;
    self.needShowHKVolumn = self.viewModel.isHKVolumn && isHK  && self.viewModel.isStock;
    self.needShowSell = isHK && self.viewModel.isStock;
    
    self.needShowTechnical = self.viewModel.isStock;
    
    self.needShowWarrantCbbc = self.viewModel.isWarrantCbbc;

    self.needShowEstimated = ([self.viewModel.market isEqualToString:kYXMarketHK] || [self.viewModel.market isEqualToString:kYXMarketUS] || [self.viewModel.market isEqualToString:kYXMarketSG]) && self.viewModel.isStock;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserInfo:) name:YXUserManager.notiLogin object:nil];

    [self initUI];
    _isLoaded = YES;

    [self loadDataCommands];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.viewModel openTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.viewModel closeTimer];
}

- (void)initUI {

    self.view.backgroundColor = QMUITheme.foregroundColor;
    [self.view addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(6);
    }];
    
    @weakify(self);

    if (self.needShowScore) {
        [self.stackView addArrangedSubview:self.scoreView];
        self.scoreView.pushToAnalysisDetailBlock = ^{
            @strongify(self)
            [self.viewModel.pushToAnalyzeDetailCommand execute:nil];
        };
    }

    if (self.needShowTechnical) {
        [self.stackView addArrangedSubview:self.technicalView];
        self.technicalView.pushToTechnicalDetailBlock = ^(BOOL canJump){
            @strongify(self)
            [self.viewModel.pushToTechnicalDetailCommand execute:@(canJump)];
        };
    }

    if (self.needShowBrokerList) {
        [self.stackView addArrangedSubview:self.brokerHoldingsView];
    }
    
    if (self.needShowEstimated) {
        [self.stackView addArrangedSubview:self.estimatedView];
    }
    
    if (self.needShowWarrantCbbc) {

        [self.stackView addArrangedSubview:self.warrantCbbcScoreView];
    }

    if (self.needShowSell) {
        [self.stackView addArrangedSubview:self.sellView];
    }

    if (self.needShowHKVolumn) {
        [self.stackView addArrangedSubview:self.hkVolumnView];
    }
    
    /// 配置stackView
    for (UIView *view in self.stackView.subviews) {
        if ([view isKindOfClass:[YXStockAnalyzeBaseView class]]) {
            YXStockAnalyzeBaseView *tempView = (YXStockAnalyzeBaseView *)view;
            [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(tempView.contentHeight);
            }];
            @weakify(self);
            @weakify(tempView);
            [tempView setContentHeightChange:^(CGFloat height) {
                @strongify(self);
                @strongify(tempView);
                [tempView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(tempView.contentHeight);
                }];
                
                [self updateHeight];
            }];
        }
    }
    [self updateHeight];
}

- (void)updateHeight {
    
    CGFloat totalHeight = 6 + 8;
    for (UIView *view in self.stackView.subviews) {
        if ([view isKindOfClass:[YXStockAnalyzeBaseView class]]) {
            YXStockAnalyzeBaseView *tempView = (YXStockAnalyzeBaseView *)view;
            if (!tempView.isHidden) {
                totalHeight += tempView.contentHeight + self.stackView.spacing;
            }
        }
    }
    if (totalHeight != self.contentHieght) {
        self.contentHieght = totalHeight;
        if (self.contentHeightDidChange) {
            self.contentHeightDidChange(totalHeight);
        }
    }
}


- (void)bindViewModel {

    @weakify(self)
    if (self.viewModel.level == QuoteLevelLevel2) {
        self.viewModel.brokerTimerSubject = [RACSubject subject];
        [self.viewModel.brokerTimerSubject subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            if (self.viewModel.brokerType == 0) {
                [self loadBrokerListData];
            }
        }];
    }

    if (self.needShowSell) {
        [self.sellView.lineView setLoadMoreCallBack:^{
            @strongify(self);
            [self loadMoreSellLineData];
        }];
    }

    if (self.needShowHKVolumn) {
        [self.hkVolumnView.lineView setLoadMoreCallBack:^{
            @strongify(self);
            [self loadMoreHKVolumnLineData];
        }];
    }
    
    if (self.needShowEstimated) {
        [self.estimatedView setSelectCallBack:^(NSInteger type) {
            @strongify(self);
            if (type == 0) {
                self.estimatedItemStr = @"pe";
            } else if (type == 1) {
                self.estimatedItemStr = @"pb";
            } else if (type == 2) {
                self.estimatedItemStr = @"ps";
            }
            [self loadEstimateData];
        }];
    }
}

#pragma mark - 个股详情下拉刷新的同时刷新子控制器
- (void)refreshControllerData {
    if (_isLoaded) {
        [self loadDataCommands];
    }
}

- (void)loadDataCommands {

    if ([self.viewModel.market isEqualToString:kYXMarketHK]) {
        [self loadBrokerListData];
        [self loadBrokerShareHoldingData];
    }
    
    if (self.needShowTechnical) {
        [self loadTechnicalInsightData];
    }

    if (self.needShowScore) {
//        [self loadDiagnoseScoreData];
//        [self loadDiagnoseNumberData];
    }

    if (self.needShowSell) {
        [self loadSellLineData];
    }

    if (self.needShowHKVolumn) {
        [self loadHKVolumnLineData];
        [self loadHKVolumnChangeData];
    }
    
    if (self.needShowEstimated) {
        [self loadEstimateData];
    }

    if (self.needShowWarrantCbbc) {
        [self loadWarrantCbbcScoreData];
    }
}

- (void)loadBrokerListData {
    @weakify(self)
    [[self.viewModel.brokerListDataCommand execute:nil] subscribeNext:^(YXStockAnalyzeBrokerListModel *model) {
        @strongify(self);
        self.brokerHoldingsView.model = model;
    }];
}

- (void)loadBrokerShareHoldingData {
    @weakify(self)
    [[self.viewModel.brokerShareHoldingDataCommand execute:nil] subscribeNext:^(YXStockAnalyzeBrokerListModel *model) {
        @strongify(self);
        self.brokerHoldingsView.holdingModel = model;
    }];
}

- (void)loadSellLineData {
    @weakify(self);
    [[self.viewModel.loadSellCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.sellView.lineView.klineModel = self.viewModel.sellModel;
        // 卖空比例没有值的时候,隐藏.
        if (self.viewModel.sellModel.list.count == 0) {
            self.sellView.hidden = YES;
        } else {
            self.sellView.hidden = NO;
        }
    }];
}

- (void)loadMoreSellLineData {
    @weakify(self);
    [[self.viewModel.loadSellMoreCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.sellView.lineView.klineModel = self.viewModel.sellModel;
    }];
}

- (void)loadHKVolumnLineData {
    @weakify(self);
    [[self.viewModel.loadHKVolumnCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.hkVolumnView.lineView.klineModel = self.viewModel.HKVolumnModel;
    }];
}

- (void)loadMoreHKVolumnLineData {
    @weakify(self);
    [[self.viewModel.loadHKVolumnMoreCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.hkVolumnView.lineView.klineModel = self.viewModel.HKVolumnModel;
    }];
}

- (void)loadHKVolumnChangeData {
    @weakify(self);
    [[self.viewModel.loadHKVolumnChangeCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.hkVolumnView.volumnChangeView.model = self.viewModel.hkVolumnChangeModel;
        NSInteger count = self.viewModel.hkVolumnChangeModel.list.count;
        if (count > 0) {
            self.hkVolumnView.volumnChangeView.hidden = NO;
            self.hkVolumnView.contentHeight = 365 + (count + 1) * 40;
        } else {
            self.hkVolumnView.volumnChangeView.hidden = YES;
            self.hkVolumnView.contentHeight = 365;
        }
    }];
}

- (void)loadDiagnoseScoreData {
    @weakify(self)
    [[self.viewModel.diagnoseScoreDataCommand execute:nil] subscribeNext:^(YXStockAnalyzeDiagnoseScoreModel *model) {
        @strongify(self);
        if (model) {
            self.scoreView.hidden = NO;
            self.scoreView.model = model;
        } else {
            self.scoreView.hidden = YES;
        }

    }];
}

- (void)loadDiagnoseNumberData {

    if ([YXUserManager isLogin]) {
        [[self.viewModel.diagnoseNumberDataCommand execute:nil] subscribeNext:^(id x) {


        }];
    }
}

- (void)loadTechnicalInsightData {
    @weakify(self)
    [[self.viewModel.technicalInsightDataCommand execute:nil] subscribeNext:^(YXStockAnalyzeTechnicalModel *model) {
        @strongify(self);
        if (!model.not_show_flag && model != nil && model.summary_data != nil) {
            self.technicalView.hidden = NO;
            self.technicalView.model = model;
            self.noDataView.hidden = YES;
        }
    }];
}

- (void)loadEstimateData {
    @weakify(self);
    [[self.viewModel.estimateDataCommand execute:self.estimatedItemStr] subscribeNext:^(YXAnalyzeEstimateModel *model) {
        @strongify(self);
        self.estimatedView.model = model;
    }];
}

- (void)loadWarrantCbbcScoreData {
    @weakify(self);
    [[self.viewModel.warrantCbbcScoreDataCommand execute:nil] subscribeNext:^(YXStockAnalyzeWarrantCbbcScoreModel *model) {
        @strongify(self);
        self.warrantCbbcScoreView.model = model;
    }];
}

#pragma mark - 用户数据刷新
- (void)refreshUserInfo:(NSNotification *)noti {

    int level = (int)[[YXUserManager shared] getLevelWith:self.viewModel.market];
    if (self.viewModel.level != level) {
        self.viewModel.level = level;

        [self.brokerHoldingsView updateLevel: level];
    }
    [self loadDataCommands];
}


#pragma mark - 懒加载
- (UIStackView *)stackView {
    if (_stackView == nil) {
        _stackView = [[UIStackView alloc] init];
        _stackView.spacing = 0;
        _stackView.axis = UILayoutConstraintAxisVertical;
    }
    return _stackView;
}
- (YXStockSmartScoreView *)scoreView {
    if (!_scoreView) {
        _scoreView = [[YXStockSmartScoreView alloc] init];
        _scoreView.backgroundColor = QMUITheme.foregroundColor;
        _scoreView.hidden = YES;
        _scoreView.contentHeight = 190;
    }
    return _scoreView;
}

- (YXStockAnalyzeTechnicalView *)technicalView {
    if (!_technicalView) {
        _technicalView = [[YXStockAnalyzeTechnicalView alloc] init];
        _technicalView.backgroundColor = QMUITheme.foregroundColor;
        _technicalView.hidden = YES;
        @weakify(self)
        self.technicalView.pushToTechnicalDetailBlock = ^(BOOL canJump){
            @strongify(self)
            [self.viewModel.pushToTechnicalDetailCommand execute:@(canJump)];
        };
        _technicalView.contentHeight = 185;
    }
    return _technicalView;
}


- (YXStockAnalyzeBrokerHoldingsView *)brokerHoldingsView {
    if (!_brokerHoldingsView) {
        _brokerHoldingsView = [[YXStockAnalyzeBrokerHoldingsView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 460) level: self.viewModel.level];
        _brokerHoldingsView.backgroundColor = QMUITheme.foregroundColor;
        _brokerHoldingsView.contentHeight = 460;
        @weakify(self)
        self.brokerHoldingsView.tabClickBlock = ^(NSInteger type) {
            @strongify(self)
            self.viewModel.brokerType = (int)type;
            [self loadBrokerListData];
        };

        self.brokerHoldingsView.clickBlock = ^(NSDictionary *dic) {
            @strongify(self)
            [self.viewModel.pushToBrokerDetailCommand execute:dic];
        };

        self.brokerHoldingsView.arrowClickBlock = ^(NSDictionary *dic) {
            @strongify(self)
            [self.viewModel.pushToBrokerHoldingDetailCommand execute:dic];
        };
    }
    return _brokerHoldingsView;
}

- (YXBrokerAnalyzeView *)sellView {
    if (_sellView == nil) {
        _sellView = [[YXBrokerAnalyzeView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 290 + 75 + 10) andType:YXBrokerLineTypeSell];
        _sellView.backgroundColor = QMUITheme.foregroundColor;
        _sellView.contentHeight = 375;
    }
    return _sellView;
}

- (YXBrokerAnalyzeView *)hkVolumnView {
    if (_hkVolumnView == nil) {
        _hkVolumnView = [[YXBrokerAnalyzeView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 360) andType:YXBrokerLineTypeHkwolun];
        _hkVolumnView.backgroundColor = QMUITheme.foregroundColor;
        _hkVolumnView.contentHeight = 365;
    }
    return _hkVolumnView;
}


- (YXStockAnalyzeWarrantCbbcScoreView *)warrantCbbcScoreView {
    if (!_warrantCbbcScoreView) {
        _warrantCbbcScoreView = [[YXStockAnalyzeWarrantCbbcScoreView alloc] init];
        _warrantCbbcScoreView.contentHeight = 450;
    }
    return _warrantCbbcScoreView;
}

- (YXStockEmptyDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[YXStockEmptyDataView alloc] init];
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

- (YXStockAnylzeEstimatedView *)estimatedView {
    if (!_estimatedView) {
        _estimatedView = [[YXStockAnylzeEstimatedView alloc] init];
        _estimatedView.contentHeight = 430;
    }
    return _estimatedView;
}


@end
