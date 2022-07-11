//
//  YXSmartTradeViewController.m
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/4/15.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXSmartTradeViewController.h"
#import "uSmartOversea-Swift.h"

#import <Masonry/Masonry.h>
#import "YXTabPageView.h"

//#import "YXStockDetailTopTipView.h"
#import "YXTradeGreyListView.h"
#import "NSDictionary+Category.h"

@interface YXSmartTradeViewController () <YXTabPageViewDelegate>

@property (nonatomic, strong) YXSmartTradeViewModel *viewModel;

@property (nonatomic, strong) YXSmartTradeHeaderView *headerView;

@property (nonatomic, strong) YXTabPageView *tabPageView;
@property (nonatomic, strong) YXTabView *tabView;
@property (nonatomic, strong) YXPageView *pageView;

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) YXPosStatisticsViewController *posStatisticsViewController;

@property (nonatomic, strong) YXStockDetailTcpTimer *requestTimer;

@end

@implementation YXSmartTradeViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ///融资抵押率 提示
    [self.view addSubview:self.tabPageView];
    [self.tabPageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.strongNoticeView.mas_bottom);
    }];
    
    [self updateTitle];
    [self setupTabTitles];
    [self updatePageViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self topTipViewUpdate];
    
    [self.headerView.placeOrderView updatePaymentHidden];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.requestTimer invalidate];
}

- (void)bindViewModel{
    [super bindViewModel];

    RAC(self.headerView, needSingleUpdate) = RACObserve(self.viewModel, needSingleUpdate);
    RAC(self.headerView, tradeModel) = [RACObserve(self.viewModel, tradeModel) skip:1];
    RAC(self.headerView, quote) = RACObserve(self.viewModel, quote);
    RAC(self.headerView, followQuote) = [RACObserve(self.viewModel, followQuote) skip:1];
    
    @weakify(self)
    [[RACObserve(self.viewModel, tradeModel) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.tabPageView scrollToTop];
        [self topTipViewUpdate];
        [self updateTitle];
        [self updatePageViews];
    }];
    
    [[RACObserve(self.viewModel, quote) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self.viewModel.needSingleUpdate && !self.headerView.needSingleUpdate) {
            self.viewModel.needSingleUpdate = self.headerView.needSingleUpdate;
        }
        if (self.viewModel.needPosStatisticsUpdate) {
            YXV2Quote *quote = (YXV2Quote *)x;
            if ([[YXUserManager shared] getLevelWith:quote.market] > QuoteLevelBmp && quote.level.value == 0) {
                self.posStatisticsViewController.quoteModel = nil;
            } else {
                self.posStatisticsViewController.quoteModel = x;
            }
            self.viewModel.needPosStatisticsUpdate = NO;
        }
    }];
    
    if (self.viewModel.tradeModel.condition.smartOrderType == SmartOrderTypeStockHandicap) {
        [self.viewModel subFollowRtSimple];
    }
    
    [[self.viewModel rac_signalForSelector:@selector(refreshPowerAndCanBuySell)] subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(self)
        [self.headerView.placeOrderView requestCanBuyWithNeedReset:NO];
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kYXSocketTradeAccountChangeNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable noti) {
        @strongify(self);
        NSArray *arr = noti.object;
        if (self.qmui_isViewLoadedAndVisible && arr.count > 0) {
            [self.requestTimer onNext:arr scheme:SchemeTcp];
        }
    }];

}

- (YXStockDetailTcpTimer *)requestTimer {
    if (!_requestTimer) {
        @weakify(self)
        _requestTimer = [[YXStockDetailTcpTimer alloc] initWithInterval:3 excute:^(NSArray * _Nonnull arr, enum Scheme scheme) {
            @strongify(self)
            if ([arr containsObject:@(TradeRefreshTypeSingleAsset)]) {
                [self.viewModel requestSubViewModels];
            } else {
                if ([arr containsObject:@(TradeRefreshTypeTodayOrder)]) {
                    [self.viewModel requestTodayViewModel];
                } else if ([arr containsObject:@(TradeRefreshTypeSmartOrder)]) {
                    [self.viewModel requestSmartViewModel];
                }
            }
        }];
    }
    return _requestTimer;
}

#pragma mark - 顶部tipsView
-(void)topTipViewUpdate{
    QuoteLevel level = [[YXUserManager shared] getLevelWith:self.viewModel.tradeModel.market];
    
    if (level == QuoteLevelBmp && ![YXUserManager shared].isTradeTipsHide) {
        YXNoticeModel *model = [[YXNoticeModel alloc] initWithMsgId:0 title:@"" content:[YXLanguageUtility kLangWithKey:@"stock_detail_bmpTip"] pushType:YXPushTypeNone pushPloy:[@{@"clickClose": @"1"} yy_modelToJSONString] msgType:0 contentType:0 startTime:0.0 endTime:0.0 createTime:0.0 newFlag:0];
        model.isBmp = true;
        self.strongNoticeView.dataSource = @[model];
    } else {
        self.strongNoticeView.dataSource = @[];
    }
}

- (void)updateTitle{
    TradeModel *tradeModel = self.viewModel.tradeModel;
    if (tradeModel.tradeStatus == TradeStatusChange) {
        self.title = [YXLanguageUtility kLangWithKey:@"trading_modify_smart_order"];
    }
}


#pragma mark - SubViews

- (YXSmartTradeHeaderView *)headerView {
   if (_headerView == nil) {
       _headerView = [[YXSmartTradeHeaderView alloc] initWithTradeModel:self.viewModel.tradeModel];
       @weakify(self)
       [_headerView setHeightDidChange:^{
           @strongify(self)
           [self.tabPageView reloadData];
       }];
       
       [_headerView.stockView setClickBlock:^{
           @strongify(self)
           [(NavigatorServices *)self.viewModel.services presentToTradeSearchWithMkts:@[kYXMarketUS, kYXMarketHK, kYXMarketSG] showPopular:YES  showLike:YES showHistory:YES didSelectedItem:^(YXSearchItem * _Nonnull item) {
               [self.viewModel changeStock:item.market symbol:item.symbol name:item.name];
           }];
       }];
       
       [_headerView.conditionView setSubFollow:^{
           @strongify(self)
           [self.viewModel subFollowRtSimple];
       }];
       
       [_headerView.conditionView setUnSubFollow:^{
           @strongify(self)
           [self.viewModel unSubFollow];
       }];
       
       [_headerView.conditionView.trackStockView setRefreshBlock:^{
           @strongify(self)
           [self.viewModel singleBmpSubFollowRtSimple];
       }];
       
       [_headerView.conditionView.trackStockView setClickBlock:^{
           @strongify(self)
           if (self.viewModel.tradeModel.tradeStatus == TradeStatusChange || self.viewModel.tradeModel.symbol.length < 1) {
               return;
           }
           
           NSString *market = self.viewModel.tradeModel.market;
           NSArray *mkts = @[market];
           if ([market isEqualToString:kYXMarketChinaSH] || [market isEqualToString:kYXMarketChinaSZ]) {
               mkts = @[kYXMarketChinaSH, kYXMarketChinaSZ];
           }
           
           if ([self.viewModel.quote.underlingSEC.symbol isEqualToString:self.viewModel.tradeModel.condition.releationStockCode]
               && [self.viewModel.quote.underlingSEC.market isEqualToString:self.viewModel.tradeModel.condition.releationStockMarket]) {
               if ([self.viewModel.quote.underlingSEC.market isEqualToString:self.viewModel.tradeModel.market]) {
                   return;
               } else if (![self.viewModel.tradeModel.market isEqualToString:kYXMarketSG]) {
                   return;
               }
           }

           [(NavigatorServices *)self.viewModel.services presentToFollowSearchWithMkts:mkts showLike:YES didSelectedItem:^(YXSearchItem * _Nonnull item) {
               self.viewModel.tradeModel.condition.releationStockMarket = item.market;
               self.viewModel.tradeModel.condition.releationStockCode = item.symbol;
               self.viewModel.tradeModel.condition.releationStockName = item.name;
               
               [self.headerView.conditionView showTrackView];
           }];

 
       }];
       
       //点击刷新
       [_headerView.stockView setRefreshBlock:^{
           @strongify(self);
           [self.viewModel singleBmpSubRtFull];
       }];
       
       [_headerView.stockView setOptionKeyBlock:^{
           @strongify(self)
           [self.view endEditing:YES];
           @weakify(self)
           
           [YXToolUtility handleBusinessWithOptionLevel:NO callBack:nil excute:^{
               @strongify(self)
               YXShareOptionsViewModel *viewModel = [[YXShareOptionsViewModel alloc] initWithServices:self.viewModel.services params:@{@"market": self.viewModel.tradeModel.market, @"code": self.viewModel.tradeModel.symbol}];
               [self.viewModel.services pushViewModel:viewModel animated:YES];
           }];
           
       }];
              
       
       [_headerView setTradeOrderFinished:^{
           @strongify(self)
           
           if (self.viewModel.tradeModel.tradeStatus == TradeStatusChange) {
               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   [self.navigationController popViewControllerAnimated:YES];
               });
           }else {
               NSInteger index = 0;
               for (UIViewController *viewController in self.pageView.viewControllers) {
                   if ([viewController isKindOfClass:[YXSmartOrderListViewController class]]) {
                       index = [self.pageView.viewControllers indexOfObject:viewController];
                       break;
                   }
               }
               [self.viewModel requestSmartViewModel];

               if (index > 0) {
                   [self.pageView reloadData];
                   [self.tabView selectTabAtIndex:index];
               }
           }
       }];
       
   }
    return _headerView;
}

- (YXPosStatisticsViewController *)posStatisticsViewController {
    if (_posStatisticsViewController == nil) {
        _posStatisticsViewController = [[YXPosStatisticsViewController alloc] initWithViewModel:self.viewModel.statisticsViewModel];
        
        @weakify(self)
        _posStatisticsViewController.tapBlock = ^(NSDictionary<NSString *,id> * _Nonnull dic) {
            @strongify(self)
            NSString *priceString = [dic yx_stringValueForKey:@"price"];
            NSNumber *number = [dic valueForKey:@"number"];
            if (priceString.length > 0) {
                [self.headerView.placeOrderView.smartTradePriceView updatePriceWithPrice:priceString];
            }
            
            if (number) {
                [self.headerView.placeOrderView.smartTradeNumberView updateNumber:number];
            }
        };
    }
    return _posStatisticsViewController;
}

- (NSArray *)viewControllers {
    if (!_viewControllers) {
        YXTodayOrderViewController *todayOrderViewCotnroller = [[YXTodayOrderViewController alloc] initWithViewModel:self.viewModel.todayOrderViewModel];
        YXSmartOrderListViewController *conditionOrderViewController = [[YXSmartOrderListViewController alloc] initWithViewModel:self.viewModel.smartOrderViewModel];
        YXHomeHoldViewController *holdViewCotnroller = [[YXHomeHoldViewController alloc] initWithViewModel:self.viewModel.holdViewModel];
        _viewControllers = @[self.posStatisticsViewController, holdViewCotnroller, conditionOrderViewController, todayOrderViewCotnroller];
    }
    return  _viewControllers;
}

- (YXTabPageView *)tabPageView {
    if (_tabPageView == nil) {
        _tabPageView = [[YXTabPageView alloc] initWithDelegate:self];
    }
    return _tabPageView;
}

- (YXTabView *)tabView {
    if (_tabView == nil) {
        YXTabLayout *layout = [YXTabLayout defaultLayout];
        layout.linePadding = 1;
        layout.lineCornerRadius = 2;
        layout.titleFont = [UIFont systemFontOfSize:16];
        layout.titleSelectedFont = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        layout.lineWidth = 16;
        layout.lineHeight = 4;
        layout.titleColor = QMUITheme.textColorLevel3;
        layout.titleSelectedColor = QMUITheme.themeTextColor;
        layout.lineColor = QMUITheme.themeTextColor;
        _tabView = [[YXTabView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 40) withLayout:layout];
        _tabView.backgroundColor = QMUITheme.foregroundColor;
        self.titles = @[[YXLanguageUtility kLangWithKey:@"trading_ask_bid"],
                        [YXLanguageUtility kLangWithKey:@"trading_hold_warehouse"],
                        [YXLanguageUtility kLangWithKey:@"trading_smart_order_record"],
                        [YXLanguageUtility kLangWithKey:@"trading_today_order"]];
        _tabView.titles = self.titles;
        
        if (!(self.viewModel.tradeModel.tradeStatus == TradeStatusChange)) {
            UIView *line1 = [[UIView alloc] init];
            line1.backgroundColor = QMUITheme.separatorLineColor;
            [_tabView addSubview:line1];
            
            [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(_tabView);
                make.height.mas_equalTo(0.5);
            }];
        }
    }
    return _tabView;
}

- (void)setupTabTitles {
    if (self.viewModel.tradeModel.tradeStatus != TradeStatusChange) {
        //level --> 0：延时行情，1：bmp行情，2：level1行情 3: level2行情
        @weakify(self)
        NSArray *tempArray = @[
            RACObserve(self.viewModel.holdViewModel, dataSource),
            RACObserve(self.viewModel.todayOrderViewModel, dataSource),
            RACObserve(self.viewModel.smartOrderViewModel, dataSource),
        ];
        
        [[RACSignal combineLatest:tempArray] subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            
            NSString *holdTitle = [YXLanguageUtility kLangWithKey:@"trading_hold_warehouse"];
            if ([self.viewModel.holdViewModel holdSecurityCount] > 0) {
                holdTitle = [NSString stringWithFormat:@"%@ (%lu)", holdTitle,(unsigned long)[self.viewModel.holdViewModel holdSecurityCount]];
            }

            NSString *todayOrder = [YXLanguageUtility kLangWithKey:@"trading_today_order"];
            __block NSInteger totalOrderCount = 0;
            [self.viewModel.todayOrderViewModel.dataSource enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[YXOrderModel class]]) {
                        totalOrderCount++;
                    }
                    
                }];
            }];
            if (totalOrderCount > 0) {
                todayOrder = [NSString stringWithFormat:@"%@ (%lu)", todayOrder, (unsigned long)totalOrderCount];
            }
            
            NSString *smartOrder = [YXLanguageUtility kLangWithKey:@"trading_smart_order_record"];
            NSInteger smartOrderCount = [self.viewModel.smartOrderViewModel.tradingOrders count] + [self.viewModel.smartOrderViewModel.doneOrders count];;
            if (smartOrderCount > 0) {
                smartOrder = [NSString stringWithFormat:@"%@ (%lu/%lu)", smartOrder, (unsigned long)[self.viewModel.smartOrderViewModel.tradingOrders count], (unsigned long)smartOrderCount];
            }
            
            self.titles = @[[YXLanguageUtility kLangWithKey:@"trading_ask_bid"], holdTitle, smartOrder, todayOrder];
            NSMutableArray *titles = [self.titles mutableCopy];
            self.tabView.titles = titles;
            
            [self.tabView reloadData];
        }];
        
    }else {
        _tabView.titles = @[[YXLanguageUtility kLangWithKey:@"trading_ask_bid"]];
    }
}

- (void)updatePageViews {
    NSMutableArray *viewControllers = [self.viewControllers mutableCopy];
    NSMutableArray *titles = [self.titles mutableCopy];
    
    if (self.viewModel.tradeModel.tradeStatus == TradeStatusChange) {
        viewControllers = [@[self.posStatisticsViewController] mutableCopy];
        titles = [@[[YXLanguageUtility kLangWithKey:@"trading_ask_bid"],] mutableCopy];
    }
    
    self.tabView.titles = titles;
    self.pageView.viewControllers = viewControllers;
    
    [self.pageView reloadData];
    [self.tabPageView reloadData];
}
- (YXPageView *)pageView {
    if (_pageView == nil) {
        _pageView = [[YXPageView alloc] initWithFrame:self.view.bounds];
        _pageView.parentViewController = self;
        _pageView.contentView.scrollEnabled = NO;
        _pageView.viewControllers = self.viewControllers;
    }
    return _pageView;
}


#pragma mark- YXTabPageViewDelegate dategate
- (UIView *)headerViewInTabPage {
    return self.headerView;
}


- (CGFloat)heightForHeaderViewInTabPage {
    // 滑动收起键盘
    return self.headerView.bounds.size.height;
}

- (YXTabView *)tabViewInTabPage {
    return self.tabView;
}

- (CGFloat)heightForTabViewInTabPage {
    return 40;
}

- (YXPageView *)pageViewInTabPage {
    return self.pageView;
}

- (CGFloat)heightForPageViewInTabPage {
    NSInteger h = 0;
    
//    
//    if ([[YXUserManager shared] getLevelWith:self.viewModel.tradeModel.market] == QuoteLevelBmp && ![YXUserManager shared].isTradeTipsHide) {
//        h += self.topTipView.frame.size.height;
//    }

    if (!self.strongNoticeView.isHidden) {
        h += self.strongNoticeView.frame.size.height;
    }
    return YXConstant.screenHeight - YXConstant.navBarHeight - 40 - h;
}

- (NSString *)pageName {
    return @"Smart order detail";
}

- (NSDictionary<NSString *,NSString *> *)pageProperties {
    return @{@"stock_name": self.viewModel.tradeModel.name,
             @"stock_code": self.viewModel.tradeModel.symbol};
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
