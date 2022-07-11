//
//  YXNormalTradeViewController.m
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/3/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXNormalTradeViewController.h"
#import "uSmartOversea-Swift.h"

#import <Masonry/Masonry.h>
#import "YXTabPageView.h"

//#import "YXStockDetailTopTipView.h"
#import "YXTradeGreyListView.h"
#import "NSDictionary+Category.h"

@interface YXNormalTradeViewController () <YXTabPageViewDelegate, YXTabViewDelegate>

@property (nonatomic, strong) YXNormalTradeViewModel *viewModel;

@property (nonatomic, strong) YXNormalTradeHeaderView *headerView;
@property (nonatomic, strong) YXTabPageView *tabPageView;
@property (nonatomic, strong) YXTabView *tabView;
@property (nonatomic, strong) YXPageView *pageView;

@property (nonatomic, strong) NSArray *defaultViewControllers;
@property (nonatomic, strong) NSArray *defaultTitles;

@property (nonatomic, strong) YXPosStatisticsViewController *posStatisticsViewController;

@property (nonatomic, strong) YXStockDetailTcpTimer *requestTimer;

@end

@implementation YXNormalTradeViewController
@dynamic viewModel;

    
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    [self.view addSubview:self.tabPageView];
    [self.tabPageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.strongNoticeView.mas_bottom);
    }];
    
    [self updateTitle];
    [self setupTabTitles];
    [self updatePageViews];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self topTipViewUpdate];
    
    [self.headerView.placeOrderView updatePaymentHidden];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
      
    [self.view endEditing:YES];

    [self.requestTimer invalidate];
}


- (void)bindViewModel{
    [super bindViewModel];

    RAC(self.headerView, needSingleUpdate) = RACObserve(self.viewModel, needSingleUpdate);
    RAC(self.headerView, tradeModel) = [RACObserve(self.viewModel, tradeModel) skip:1];
    RAC(self.headerView, quote) = RACObserve(self.viewModel, quote);
    
    @weakify(self)
    [[RACObserve(self.viewModel, tradeModel) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.tabPageView scrollToTop];
        [self updateTitle];
        [self topTipViewUpdate];
//        [self loadOptionAggravateData];
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

//    [self loadOptionAggravateData];
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
                }
            }
        }];
    }
    return _requestTimer;
}

//- (void)loadOptionAggravateData {
//
//    if (self.viewModel.tradeModel.tradeStatus == TradeStatusNormal || self.viewModel.tradeModel.tradeStatus == TradeStatusLimit) {
//        if ([self.viewModel.tradeModel.market isEqualToString:kYXMarketUS]
//            && self.viewModel.tradeModel.symbol.length > 0) {
//
//            @weakify(self);
//            [[self.viewModel.loadOptionAggravateDataCommand execute:nil] subscribeNext:^(id  _Nullable x) {
//                @strongify(self)
//                NSNumber *number = (NSNumber *)x;
//                if ([number isKindOfClass:[NSNumber class]] && number.integerValue > 0) {
//                    self.headerView.optionChainView.hidden = NO;
//                } else {
//                    self.headerView.optionChainView.hidden = YES;
//                }
//            }];
//        } else if ([self.viewModel.tradeModel.market isEqualToString:kYXMarketUsOption] && self.viewModel.tradeModel.symbol.length > 0) {
//            self.headerView.optionChainView.hidden = NO;
//        } else {
//            self.headerView.optionChainView.hidden = YES;
//        }
//    } else {
//        self.headerView.optionChainView.hidden = YES;
//    }
//}


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
        self.title = [YXLanguageUtility kLangWithKey:@"trading_navigation_title"];
    } else if (tradeModel.tradeStatus == TradeStatusLimit) {
        if (tradeModel.tradeType == TradeTypeShortSell) {
            if (tradeModel.direction == TradeDirectionBuy) {
                self.title = [YXLanguageUtility kLangWithKey:@"buy_by_close"];
            } else {
                self.title = [YXLanguageUtility kLangWithKey:@"sell_short"];
            }
        } else {
            if (tradeModel.direction == TradeDirectionBuy) {
                self.title = [YXLanguageUtility kLangWithKey:@"trading_buy"];
            } else {
                self.title = [YXLanguageUtility kLangWithKey:@"trading_sell"];
            }
        }
    } else {
        self.title = [YXLanguageUtility kLangWithKey:@"common_trade"];
    }
}


#pragma mark - SubViews

- (YXNormalTradeHeaderView *)headerView {
   if (_headerView == nil) {
       _headerView = [[YXNormalTradeHeaderView alloc] initWithTradeModel:self.viewModel.tradeModel];
       
       @weakify(self)
       [_headerView setHeightDidChange:^{
           @strongify(self)
           [self.tabPageView reloadData];
       }];
       
       [_headerView.stockView setClickBlock:^{
           @strongify(self)
           if (self.viewModel.tradeModel.tradeType == TradeTypeNormal) {
               [(NavigatorServices *)self.viewModel.services presentToTradeSearchWithMkts:nil showPopular:YES showLike:YES showHistory:YES didSelectedItem:^(YXSearchItem * _Nonnull item) {
                   [self.viewModel changeStock:item.market symbol:item.symbol name:item.name];
               }];
           } else if (self.viewModel.tradeModel.tradeType == TradeTypeFractional) {
               [(NavigatorServices *)self.viewModel.services presentToTradeSearchWithMkts:@[kYXMarketUS] showPopular:NO showLike:YES showHistory:YES didSelectedItem:^(YXSearchItem * _Nonnull item) {
                   [self.viewModel changeStock:item.market symbol:item.symbol name:item.name];
               }];
           }
       }];
       
       //点击刷新
       [_headerView.stockView setRefreshBlock:^{
           @strongify(self);
           [self.viewModel singleBmpSubRtFull];
       }];
//
//       [_headerView.optionChainView.chainButton setQmui_tapBlock:^(__kindof UIControl *sender) {
//           @strongify(self)
//
//           if ([YXUserManager isOpenUsOption]) {
//               NSString *market = self.viewModel.tradeModel.market;
//               NSString *symbol = self.viewModel.tradeModel.symbol;
//
//               if ([market isEqualToString:kYXMarketUsOption]) {
//                   market = self.viewModel.quote.underlingSEC.market;
//                   symbol = self.viewModel.quote.underlingSEC.symbol;
//               }
//
//               YXShareOptionsViewModel *viewModel = [[YXShareOptionsViewModel alloc] initWithServices:self.viewModel.services params:@{@"market": market, @"code": symbol}];
//               viewModel.tapCellAction = ^(NSString * _Nonnull market, NSString * _Nonnull symbol) {
//                   [self.navigationController popViewControllerAnimated:YES];
//
//                   [self.viewModel changeStock:market symbol:symbol name:@""];
//               };
//               [self.viewModel.services pushViewModel:viewModel animated:YES];
//           } else {
//               [YXWebViewModel pushToWebVC:[YXH5Urls OpenUsOptionURL]];
//           }
//       }];

       [_headerView setTradeOrderFinished:^{
           @strongify(self)
           
           if (self.viewModel.tradeModel.tradeStatus == TradeStatusChange) {
               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   [self.navigationController popViewControllerAnimated:YES];
               });
           }else {
               NSInteger index = 0;
               [self.viewModel refreshPowerAndCanBuySell];
               for (UIViewController *viewController in self.pageView.viewControllers) {
                   if ([viewController isKindOfClass:[YXTodayOrderViewController class]]) {
                       index = [self.pageView.viewControllers indexOfObject:viewController];
                       break;
                   }
               }
               [self.viewModel requestTodayViewModel];
               
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
                [self.headerView.placeOrderView.tradePriceView updatePriceWithPrice:priceString];
            }
            
            if (number) {
                [self.headerView.placeOrderView.tradeNumberView updateNumber:number];
            }
        };
    }
    return _posStatisticsViewController;
}

- (NSArray *)defaultViewControllers {
    if (!_defaultViewControllers) {
        YXHomeHoldViewController *holdViewCotnroller = [[YXHomeHoldViewController alloc] initWithViewModel:self.viewModel.holdViewModel];
        YXTodayOrderViewController *todayOrderViewCotnroller = [[YXTodayOrderViewController alloc] initWithViewModel:self.viewModel.todayOrderViewModel];
        _defaultViewControllers = @[self.posStatisticsViewController, holdViewCotnroller, todayOrderViewCotnroller];
    }
    return _defaultViewControllers;
}


- (YXTabPageView *)tabPageView {
    if (_tabPageView == nil) {
        _tabPageView = [[YXTabPageView alloc] initWithDelegate:self];
        _tabPageView.backgroundColor = QMUITheme.foregroundColor;
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
        _tabView.delegate = self;
        _tabView.backgroundColor = QMUITheme.foregroundColor;
        self.defaultTitles =  @[[YXLanguageUtility kLangWithKey:@"trading_ask_bid"],
                                [YXLanguageUtility kLangWithKey:@"trading_hold_warehouse"],
                                [YXLanguageUtility kLangWithKey:@"trading_today_order"],];
        _tabView.titles = self.defaultTitles;
        
        QuoteLevel level =  [[YXUserManager shared] getLevelWith:self.viewModel.tradeModel.market];
        if (!(self.viewModel.tradeModel.tradeStatus == TradeStatusChange && (level == QuoteLevelBmp || level == QuoteLevelDelay))) {
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
            RACObserve(self.viewModel.todayOrderViewModel, dataSource)
        ];
        
        [[RACSignal combineLatest:tempArray] subscribeNext:^(id  _Nullable x) {
            @strongify(self)
//            if (self.viewModel.tradeModel.tradeType != TradeTypeNormal) {
//                return;
//            }
            NSString *holdTitle = [YXLanguageUtility kLangWithKey:@"hold_holds"];

            if ([self.viewModel.holdViewModel holdSecurityCount] > 0) {
                holdTitle = [NSString stringWithFormat:@"%@ (%lu)", holdTitle,(unsigned long)[self.viewModel.holdViewModel holdSecurityCount]];
            }
            
            
            NSString *todayOrderTitle = [YXLanguageUtility kLangWithKey:@"trading_today_order"];
            __block NSInteger totalOrderCount = 0;
            [self.viewModel.todayOrderViewModel.dataSource enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[YXOrderModel class]]) {
                        totalOrderCount++;
                    }
                    
                }];
            }];
            
            if (totalOrderCount > 0) {
                todayOrderTitle = [NSString stringWithFormat:@"%@ (%lu)", todayOrderTitle, (unsigned long)totalOrderCount];
            }
            
            self.defaultTitles = @[[YXLanguageUtility kLangWithKey:@"trading_ask_bid"], holdTitle, todayOrderTitle];
            self.tabView.titles = self.defaultTitles;
            
            [self.tabView reloadDataKeepOffset];
        }];
    
    } else {
        _tabView.titles = @[[YXLanguageUtility kLangWithKey:@"trading_ask_bid"]];
    }
}

- (YXPageView *)pageView {
    if (_pageView == nil) {
        _pageView = [[YXPageView alloc] init];
        _pageView.parentViewController = self;
        _pageView.contentView.scrollEnabled = NO;
        _pageView.viewControllers = self.defaultViewControllers;
    }
    return _pageView;
}

- (void)updatePageViews {
//    NSInteger selectedIndex = self.tabView.selectedIndex;
    
    NSMutableArray *viewControllers = [self.defaultViewControllers mutableCopy];
    NSMutableArray *titles = [self.defaultTitles mutableCopy];
    
    if (self.viewModel.tradeModel.tradeStatus == TradeStatusChange) {
        viewControllers = [@[self.posStatisticsViewController] mutableCopy];
        titles = [@[[YXLanguageUtility kLangWithKey:@"trading_ask_bid"],] mutableCopy];
    }
    
    self.tabView.titles = titles;
    self.pageView.viewControllers = viewControllers;
    
    [self.pageView reloadData];
    [self.tabPageView reloadData];
    
    if (titles.count == 0) {
        [self.tabPageView.mainTableView setScrollEnabled:NO];
    }else{
        [self.tabPageView.mainTableView setScrollEnabled:YES];
    }
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
    NSInteger h = YXConstant.navBarHeight;

    if (!self.strongNoticeView.isHidden) {
        h += self.strongNoticeView.frame.size.height;
    }
    return YXConstant.screenHeight - 40 - h;
}

- (void)tabView:(YXTabView *)tabView didSelectedItemAtIndex:(NSUInteger)index withScrolling:(BOOL)scrolling {
    if (index == 1) {
        [self trackViewClickEventWithName:@"Positions_Tab" other:nil];
    } else if (index == 2) {
        [self trackViewClickEventWithName:@"Today's Orders_Tab" other:nil];
    }
}


- (NSString *)pageName {
    return @"Trade detail";
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
