//
//  YXTodayOrderViewController.m
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXTodayOrderViewController.h"
#import "YXTabPageView.h"
#import "YXTodayOrderViewModel.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

#define EXPAND @"expand"

@interface YXTodayOrderViewController () <YXTabPageScrollViewProtocol>

@property (nonatomic, copy) YXOrderHeaderView *headerView;
@property (nonatomic, copy) YXTabPageScrollBlock scrollCallBack;

@property (nonatomic, strong)  YXOrderModel *selectedModel;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL isExpand;

@property (nonatomic, strong) YXTodayOrderViewModel *viewModel;
@property (nonatomic, strong) YXHoldExpandHeaderView *tradingbBondHeaderView;
@property (nonatomic, strong) YXHoldExpandHeaderView *doneBondHeaderView;
@property (nonatomic, strong) YXDoneOrderTipCell *doneOrderTipHeaderView;

@property (nonatomic, assign) BOOL isBondTradingExpand; // 交易中债券展开
@property (nonatomic, assign) BOOL isBondDoneExpand; // 已完成债券展开
@property (nonatomic, assign) BOOL shouldHideValue;

@property (nonatomic, strong) YXStockPopoverButton *orderStatusButton;
@property (nonatomic, strong) YXStockPopoverButton *currencyButton;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation YXTodayOrderViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shouldHideValue = YXAccountAssetView.assetHidden;

    // Do any additional setup after loading the view.
    self.isBondDoneExpand = YES;
    self.isBondTradingExpand = YES;
    [self.tableView registerClass:[YXTradeExpandCell class] forCellReuseIdentifier:NSStringFromClass([YXTradeExpandCell class])];
    [self.tableView registerClass:[YXTradeEmptyCell class] forCellReuseIdentifier:NSStringFromClass([YXTradeEmptyCell class])];
    [self.tableView registerClass:[YXOrderListCell class] forCellReuseIdentifier:NSStringFromClass([YXOrderListCell class])];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.tableView registerClass:[YXTodayOrderStarCell class] forCellReuseIdentifier:NSStringFromClass([YXTodayOrderStarCell class])];
    self.tableView.backgroundColor = QMUITheme.foregroundColor;
    
    [self.view addSubview:self.headerView];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.mas_equalTo([self tableViewTop]);
        make.height.mas_equalTo(85);
    }];

    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.headerView.mas_bottom);
        make.bottom.equalTo(self.view);
    }];
    
    @weakify(self)
    [self.viewModel.validatePwd.executionSignals.switchToLatest subscribeNext:^(YXOrderModel * _Nullable orderModel) {
        @strongify(self)
        UIViewController *current = [UIViewController currentViewController];
        [current.view endEditing:YES];
        
        [YXUserUtility validateTradePwdInViewController:UIViewController.currentViewController successBlock:^(NSString * _Nullable token) {
            @strongify(self)
            if (orderModel != nil) {
                [self undoEntrustSureActionWith:orderModel];
            }
        } failureBlock:nil];
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideValueNoti:) name:YXCanHideTextLabel.hideValueNotiName object:nil];
}

- (void)hideValueNoti:(NSNotification *)noti {
    self.shouldHideValue = [noti.userInfo[@"shouldHide"] boolValue];
    [self reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)reloadData {
    
    self.headerView.model = self.viewModel.todayOrderResModel;

    if (self.viewModel.dataSource == nil) {
        self.dataSource = nil;
        [super reloadData];
        return;
    }


    @weakify(self)
    if (self.isExpand) {
        __block BOOL contains = NO;
        __block NSInteger row = 0;
        __block NSInteger section = 0;
        [self.viewModel.dataSource enumerateObjectsUsingBlock:^(NSArray * _Nonnull array, NSUInteger sectionidx, BOOL * _Nonnull outstop) {
            @strongify(self)
            [array enumerateObjectsUsingBlock:^(YXOrderModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                @strongify(self)
                if ([self isEqualWithA:self.selectedModel andB:obj]) {
                    contains = YES;
                    section = sectionidx;
                    row = idx;
                    *stop = YES;
                    self.selectedModel = obj;
                }
            }];
        }];
        
        if (!contains) {
            self.isExpand = NO;
            self.selectedModel = nil;
            self.selectedIndexPath = nil;
        } else {
            self.selectedIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
        }
    }
    
    NSMutableArray *temArr = [self.viewModel.dataSource.firstObject mutableCopy];
    if (self.isExpand && self.selectedIndexPath.row < temArr.count) {
        [temArr insertObject:EXPAND atIndex:(self.selectedIndexPath.row + 1)];
    }
    
    if (temArr.count > 0) {
        self.dataSource = @[[temArr copy]];
    }else {
        self.dataSource = @[@[[YXModel new]]];
    }
    
    [super reloadData];
}

- (BOOL)isEqualWithA:(YXOrderModel *)a andB:(YXOrderModel *)b {
    return [a.symbol isEqualToString:b.symbol] && [a.entrustId isEqualToString:b.entrustId] && (a.market == b.market);
}

- (YXOrderHeaderView *)headerView {
    if (_headerView == nil) {
        _headerView = [[YXOrderHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        @weakify(self)
        _headerView.orderFilterAction = ^(enum YXTodayOrderFilterType type) {
            @strongify(self)
            if (type == YXTodayOrderFilterTypeProcessing) {
                self.viewModel.enEntrustStatus = @"2";
                self.viewModel.categoryStatus = @"1";

            }else if (type == YXTodayOrderFilterTypeTraded) {
                self.viewModel.enEntrustStatus = @"0";
                self.viewModel.categoryStatus = @"2";

            }else if (type == YXTodayOrderFilterTypeCancelled) {
                self.viewModel.enEntrustStatus = @"6";
                self.viewModel.categoryStatus = @"3";

            }else {
                self.viewModel.enEntrustStatus = @"";
                self.viewModel.categoryStatus = @"0";
            }
            
            
            
            [self loadFirstPage];
        };
        
        _headerView.marketFilterAction = ^(enum YXMarketFilterType type) {
            @strongify(self)

            if (type == YXMarketFilterTypeSg) {
                self.viewModel.market = @"SG";
            }else if (type == YXMarketFilterTypeUs) {
                self.viewModel.market = @"US";
            }else if (type == YXMarketFilterTypeHk) {
                self.viewModel.market = @"HK";
            }else {
                self.viewModel.market = @"";
            }
            
            [self loadFirstPage];
        };
    }
    return _headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView; {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.dataSource[section];
    return arr.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (![cell isKindOfClass:[YXOrderListCell class]]) {
        return;
    }
    
    self.selectedModel = self.dataSource[indexPath.section][indexPath.row];
    
    if (self.isExpand && indexPath == self.selectedIndexPath) {
        self.isExpand = NO;
    }else {
        self.isExpand = YES;
    }
    
    [self reloadData];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    id model = self.dataSource[indexPath.section][indexPath.row];
    if ([model isKindOfClass:[YXOrderModel class]]) {
        YXOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXOrderListCell class]) forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath withObject:model];
        return cell;
    }else if ([model isKindOfClass:[NSString class]]) {
        NSString *str = model;
        @weakify(self)
        
        if ([str isEqualToString:EXPAND]) {
            YXTradeExpandCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXTradeExpandCell class]) forIndexPath:indexPath];
            NSMutableArray *items = [NSMutableArray arrayWithArray:@[@(YXTradeExpandItemPrice)]];

            if ([self.selectedModel.isFinalStatus isEqualToString:@"1"] || self.selectedModel.dayEnd == 1) {
                [items addObject:@(YXTradeExpandItemDetail)];
            }else {
                if (self.selectedModel.modifyFlag) {
                    [items addObject:@(YXTradeExpandItemModify)];
                }

                if (self.selectedModel.cancelFlag){
                    [items addObject:@(YXTradeExpandItemCancel)];
                }
                
                [items addObject:@(YXTradeExpandItemDetail)];
            }

            if (self.selectedModel.status == 20 || self.selectedModel.status == 28 || self.selectedModel.status == 29) { // 部分成交, 部成撤单, 全部成交
                [items addObject:@(YXTradeExpandItemShareOrder)];
            }

            cell.items = items;
            
            cell.action = ^(enum YXTradeExpandItem type) {
                @strongify(self)
                if (type == YXTradeExpandItemModify) {
                    [self.viewModel.didClickChange execute: self.selectedModel];
                }else if (type == YXTradeExpandItemCancel) {
                    [self undoEntrustAlert: self.selectedModel];
                }else if (type == YXTradeExpandItemDetail) {
                    [self.viewModel.didClickOrderDetail execute: self.selectedModel];
                }else if (type == YXTradeExpandItemPrice) {
                    [self.viewModel.didClickQuote execute: self.selectedModel];
                } else if (type == YXTradeExpandItemShare || type == YXTradeExpandItemShareOrder) {
                    [YXHoldShareView showShareViewWithType:HoldShareTypeOrder
                                              exchangeType:self.selectedModel.market.lowercaseString.exchangeType
                                                     model:self.selectedModel];
                }
            };

            return cell;
            
        }
    }
    YXTradeEmptyCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXTradeEmptyCell class]) forIndexPath:indexPath];
    emptyCell.emptyType = YXDefaultEmptyEnumsNoOrder;
    return emptyCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58;
}

- (CGFloat)tableViewTop {
    return 0;
}

- (void)pageScrollViewDidScrollCallback:(YXTabPageScrollBlock)callback {
    self.scrollCallBack = callback;
}

- (nonnull UIScrollView *)pageScrollView { 
    return self.tableView;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollCallBack) {
        self.scrollCallBack(scrollView);
    }
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    return [super customViewForEmptyDataSet:scrollView];
}

#pragma mark- 撤单
- (void)undoEntrustAlert:(YXOrderModel *)model {
    
    TradeModel *tradeModel = [[TradeModel alloc] init];
    tradeModel.tradeStatus = TradeStatusCancel;
    tradeModel.name = model.symbolName;
    tradeModel.symbol = model.symbol;
//    tradeModel.market = model.exchangeType == 0 ? kYXMarketHK : kYXMarketUS;
    tradeModel.market = model.market.lowercaseString;
    
    tradeModel.entrustPrice = [NSString stringWithFormat:@"%.3f", model.entrustPrice.doubleValue];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    numberFormatter.groupingSize = 3;
    numberFormatter.groupingSeparator = @",";
    numberFormatter.maximumFractionDigits = 4;
    
    tradeModel.entrustQuantity = [numberFormatter stringFromNumber:model.entrustQty];
    
    switch (model.symbolType) {
        case 2:
        {
            tradeModel.tradeType = TradeTypeFractional;
            NSNumberFormatter *amountFormatter = [[NSNumberFormatter alloc] init];
            amountFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
            amountFormatter.positiveFormat = @"###,##0.00";
            tradeModel.fractionalAmount = [amountFormatter stringFromNumber:model.entrustAmount];
            if (model.oddTradeType == 1) {
                tradeModel.fractionalTradeType = FractionalTradeTypeShares;
            } else {
                tradeModel.fractionalTradeType = FractionalTradeTypeAmount;
            }
            numberFormatter.minimumFractionDigits = 2;
            tradeModel.fractionalQuantity = [numberFormatter stringFromNumber:model.entrustQty];
        }
            break;
        case 4:
            tradeModel.market = kYXMarketUsOption;
            break;
        default:
            break;
    }
    
    @weakify(self);
    YXTradeConfirmView *confirmView = [[YXTradeConfirmView alloc] initWithTradeModel:tradeModel confirmBlock:^{
        @strongify(self);
        [self undoEntrustSureActionWith:model];
    }];
    [confirmView showInController: [UIViewController currentViewController]];

}

//确认「撤单」的响应
- (void)undoEntrustSureActionWith:(id)model {
    @weakify(self)
    if ([model isKindOfClass:[YXOrderModel class]]) { // 股票撤单
        [[self.viewModel.didClickRecall execute:model] subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            self.isExpand = NO;
            self.selectedIndexPath = nil;
            [self reloadData];
            
            [self.viewModel.requestRemoteDataCommand execute:@(1)];
        }];
    }
}

- (void)trackOrder:(YXOrderModel *)model {
    
//    NSString *tradeType = @"卖";
//    if (model.entrustType == 0) {
//        tradeType = @"买";
//    }
//    
//    NSString *currency = @"港币";
//    if ([YXToolUtility moneyUnitArray].count > model.moneyType && model.moneyType > 0) {
//        currency = [YXToolUtility moneyUnitArray][model.moneyType];
//    }
//    
//    NSString *viewPage = @"trade_hk";
//    switch (self.viewModel.pageSource) {
//        case 1:
//            viewPage = @"trade_hk";
//            break;
//        case 2:
//            viewPage = @"trade_us";
//            break;
//        case 3:
//            viewPage = @"trade_page";
//            break;
//            
//        default:
//            break;
//    }
//    
//    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
//    properties[YXSensorAnalyticsPropsConstants.propViewPage] = viewPage;
//    properties[YXSensorAnalyticsPropsConstants.propViewId] = @"today_order_cancel";
//    properties[YXSensorAnalyticsPropsConstants.propViewName] = @"今日订单-撤单";
//    if (model.symbol != nil) {
//        NSString *market = @"";
//        if (model.exchangeType == 0) {
//            market = kYXMarketHK;
//        } else if (model.exchangeType == 5) {
//            market = kYXMarketUS;
//        } else if (model.exchangeType == 6) {
//            market = kYXMarketChinaSH;
//        }else if (model.exchangeType == 7) {
//            market = kYXMarketChinaSZ;
//        }else if (model.exchangeType == 67) {
//            market = kYXMarketChina;
//        }
//        properties[YXSensorAnalyticsPropsConstants.propStockId] = [YXSensorAnalyticsPropsConstants stockIDWithMarket:market symbol:model.symbol];
//    }
//    if (model.symbolName != nil) {
//        properties[YXSensorAnalyticsPropsConstants.propStockName] = model.symbolName;
//    }
//    NSString *marketName = @"港股";
//    if (model.exchangeType == 5) {
//        marketName = @"美股";
//    } else if (model.exchangeType != 0) {
//        marketName = @"A股";
//    }
//    properties[YXSensorAnalyticsPropsConstants.propStockMarket] = marketName;
//    properties[YXSensorAnalyticsPropsConstants.propStockTradeType] = tradeType;
//    properties[YXSensorAnalyticsPropsConstants.propStockTradePrice] = model.entrustPrice;
//    properties[YXSensorAnalyticsPropsConstants.propStockShareNumber] = model.entrustQty;
//    properties[YXSensorAnalyticsPropsConstants.propStockTotalAmount] = @(model.entrustPrice.floatValue * model.entrustQty.floatValue);
//    properties[YXSensorAnalyticsPropsConstants.propStockMoneyUnit] = currency;
//    
//    [YXSensorAnalyticsTrack trackWithEvent: YXSensorAnalyticsEventOrder properties:properties];
}
@end
