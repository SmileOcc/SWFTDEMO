//
//  YXSDWeavesDetailViewController.m
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXSDWeavesDetailViewController.h"

#import "YXSDWeavesDetailVModel.h"

#import "YXSDWeavesDetailTopView.h"
#import "YXSDWeavesDetailHeaderView.h"
#import "YXSDWeavesDetailViewCell.h"
#import "UITableView+YYAdd.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

@interface YXSDWeavesDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong)YXSDWeavesDetailTopView * topView;

@property (nonatomic, strong) YXSDWeavesDetailHeaderView *tableHeaderView;

@property (nonatomic, strong) YXTableView *tableView;

@property (nonatomic, copy) NSString *identifier;

//1.5 viewModel
@property (nonatomic, strong) YXSDWeavesDetailVModel *viewModel;
@property (nonatomic, assign) BOOL isStockTypeConfirmed; //股票类型是否已经确定

@property (nonatomic, assign) BOOL isLoadMore;

@property (nonatomic, assign) BOOL didLoadFinish;//是否加载完毕，默认为NO

@property (nonatomic, strong) YXTickData *tickModel;
// 定时器
@property (nonatomic, assign) YXTimerFlag resetTimer;

@property (nonatomic, strong) UIImage *stockUpImage;
@property (nonatomic, strong) UIImage *stockdownImage;
@property (nonatomic, strong) UIImage *greyImage;

@property (nonatomic, strong) UIColor *stockRedColor;
@property (nonatomic, strong) UIColor *stockGreenColor;
@property (nonatomic, strong) UIColor *greyColor;

///下拉刷新之前的数量
@property (nonatomic, assign) NSInteger preListCount;

@end




@implementation YXSDWeavesDetailViewController

@dynamic viewModel;     //@dynamic

- (void)viewDidLoad {
    [super viewDidLoad];
        
    if (self.viewModel.extra == YXSocketExtraQuoteUsNation) {
        self.identifier = @"YXSDWeavesUsNationDetailTableViewCell";
    } else {
        self.identifier = @"YXSDWeavesDetailTableViewCell";
    }
    
    [self initUI];
    
    [self loadHttpDataWithTimer];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.resetTimer == 0) {
        [self loadHttpDataWithTimer];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 取消
    [self cancelTickRequset];
}


- (void)cancelTickRequset {
    // 取消
    [self.viewModel.tickRequset cancel];
    if (self.resetTimer > 0) {
        [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.resetTimer];
        self.resetTimer = 0;
    }
    [self.viewModel.quoteRequset cancel];
}


- (void)loadHttpDataWithTimer {
    [self loadHttpData];
    
    // 开启定时器
    if (self.resetTimer > 0) {
        [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.resetTimer];
    }
    NSTimeInterval interval = [YXGlobalConfigManager configFrequency:YXGlobalConfigParameterTypeQuotesResendFreq];
    @weakify(self);
    self.resetTimer = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
        @strongify(self);

        [self.viewModel.tickRequset cancel];
        
        [self loadHttpData];
    } timeInterval:interval repeatTimes:NSIntegerMax atOnce:NO];
}


- (void)initUI {

    self.view.backgroundColor = QMUITheme.backgroundColor;
    
    if ([YXUserManager curColorWithJudgeIsLogin:true] == YXLineColorTypeGRaiseRFall) {
        self.stockUpImage = [UIImage imageNamed:@"weaves_detial_green_up"];
    } else {
        self.stockUpImage = [UIImage imageNamed:@"weaves_detial_red_up"];
    }
    
    if ([YXUserManager curColorWithJudgeIsLogin:true] == YXLineColorTypeGRaiseRFall) {
        self.stockdownImage = [UIImage imageNamed:@"weaves_detial_red_down"];
    } else {
        self.stockdownImage = [UIImage imageNamed:@"weaves_detial_green_down"];
    }
    
    self.greyImage = [UIImage imageNamed:@"weaves_detial_gray_rect"];
    
    self.stockRedColor = QMUITheme.stockRedColor;
    self.stockGreenColor = QMUITheme.stockGreenColor;
    self.greyColor = QMUITheme.stockGrayColor;

    //
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo( 75 );
    }];
    
    [self.view addSubview:self.tableHeaderView];
    [self.tableHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.topView.mas_bottom);
        make.height.mas_equalTo( 48 );
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(self.view);
        make.top.equalTo(self.tableHeaderView.mas_bottom);
    }];
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
            // 请求其他接口数据
            [self loadTickData];
            self.isStockTypeConfirmed = YES;
        }
        self.topView.quote = quoteModel;
        
    }];
    
    [self.viewModel.loadTickDataSubject subscribeNext:^(YXTickData *tickModel) {
        @strongify(self);
        [self updateDataWith:tickModel];
        self.didLoadFinish = YES;
    }];
}

#pragma mark - 3.1 http data
- (void)loadHttpData{
    [self loadQuoteData];
    
    if (self.isStockTypeConfirmed) {
        [self loadTickData];
    }
}

- (void)loadQuoteData {
    [self.viewModel.loadBasicQuotaDataCommand execute:nil];
}
//加载tick数据
- (void)loadTickData {
    if ([YXStockDetailTool isShowTick:self.viewModel.quotaModel]) {
        /*http://szshowdoc.youxin.com/web/#/23?page_id=524
        --> quotes-dataservice(行情服务) -->v2-2(新协议、暗盘、全市场)
        --> Tick接口
        /quotes-dataservice-app/api/v2-2/tick */
        [self.viewModel.loadTickDataCommand execute:@{@"isMore": @"0"}];
    }
}

- (void)loadMoreData {
    [self.viewModel.loadTickDataCommand execute:@{@"isMore": @"1"}];
    self.didLoadFinish = NO;
    self.isLoadMore = YES;
    self.preListCount = self.tickModel.list.count;
}

#pragma mark - delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tickModel.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YXSDWeavesDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.identifier];
    if (indexPath.row < self.tickModel.list.count) {
        YXTick *model = self.tickModel.list[indexPath.row];
        double pClose = self.viewModel.pClose;
        if ([self.tickModel.market isEqualToString:kYXMarketUS]) {
            NSString *timeStr = @(model.time.value).stringValue;
            if (timeStr.length > 12) {
                NSString *resultStr = [timeStr substringWithRange:NSMakeRange(8, 4)];
                int time = [resultStr intValue];
                if (time > 930 && time < 1600) {
                    pClose = self.viewModel.pClose;
                } else {
                    pClose = self.viewModel.lastPrice;
                }
            }
        }
        [cell refreshWith:self.tickModel.list[indexPath.row] pClose: pClose priceBase: self.tickModel.priceBase.value];
        
        //1:买入 - 红, 2:卖出 - 绿 ,0: 不涨不跌 - 灰
       switch (model.direction.value) {
           case 0:
               cell.numLabel.textColor = self.greyColor;
               cell.directImgView.image = self.greyImage;
               break;
           case 1:
               cell.numLabel.textColor = self.stockRedColor;
               cell.directImgView.image = self.stockUpImage;
               break;
           case 2:
               cell.numLabel.textColor = self.stockGreenColor;
               cell.directImgView.image = self.stockdownImage;
               break;
           
           default:
               break;
       }

    }
    if (indexPath.row == self.tickModel.list.count - 1) {
        cell.isLastRow = YES;
    } else {
        cell.isLastRow = NO;
    }
    
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y == 0 && self.isStockTypeConfirmed && self.didLoadFinish) {
        [self loadMoreData];
    }
}

#pragma mark - setter

- (void)updateDataWith:(YXTickData *)tickModel {
    if (self.isLoadMore) {
        self.tickModel = tickModel;
        [self.tableView reloadData];
        /// 滚到上个位置
//        [self.tableView qmui_scrollToTop];
        
        NSInteger offset = self.tickModel.list.count - self.preListCount;
        if (offset < self.tickModel.list.count - 1) {            
            [self.tableView setContentOffset:CGPointMake(0, offset * 39)];
        }
        
        self.isLoadMore = NO;
    } else {
        // 推送来的
        if ([self.tableView isDragging] || [self.tableView isTracking] || [self.tableView isDecelerating]) {
        } else {
            [self refreshTcpData:tickModel];
        }
    }
}

- (void)refreshTcpData: (YXTickData *)tickModel {
    if (tickModel.list.count > 0) {
        self.tickModel = tickModel;
        [self.tableView reloadData];
        [self.tableView qmui_scrollToBottom];
    }
}

#pragma mark - lazy load | getter

- (YXSDWeavesDetailTopView *)topView {
    if (!_topView) {
        _topView = [[YXSDWeavesDetailTopView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 75)];
    }
    return _topView;
}

- (YXSDWeavesDetailHeaderView *)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[YXSDWeavesDetailHeaderView alloc] initWithFrame:CGRectZero andIsUsNation:(self.viewModel.extra == YXSocketExtraQuoteUsNation)];
        _tableHeaderView.directionMoreInfoBlock = ^{
            [YXWebViewModel pushToWebVC:[YXH5Urls tradeDirectionExplainUrl]];
        };
    }
    return _tableHeaderView;
}

- (YXTableView *)tableView{
    if (!_tableView) {
        _tableView = [[YXTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        if (self.viewModel.extra == YXSocketExtraQuoteUsNation) {
            [_tableView registerClass:[YXSDWeavesUsNationDetailViewCell class] forCellReuseIdentifier: self.identifier];
        } else {
            [_tableView registerClass:[YXSDWeavesDetailViewCell class] forCellReuseIdentifier: self.identifier];
        }
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 39;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //_tableView.tableHeaderView = self.tableHeaderView;
    }
    return _tableView;
}

#pragma mark - super class methods
@end
