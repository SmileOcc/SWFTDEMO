    //
//  YXSmartOrderListViewController.m
//  YouXinZhengQuan
//
//  Created by Mac on 2020/4/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXSmartOrderListViewController.h"

#import "YXSmartOrderListViewModel.h"
#import "YXTabPageView.h"

#import "uSmartOversea-Swift.h"
#import "UIGestureRecognizer+YYAdd.h"
#import <Masonry/Masonry.h>
#import "YXTableViewCell.h"
#import "YXSmartOrderListViewController.h"


@interface YXSmartOrderListViewController ()

@property (nonatomic, copy) YXTabPageScrollBlock scrollCallBack;


@property (nonatomic, strong) YXConditionOrderModel *selectedModel;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL isExpand;

@property (nonatomic, strong) YXSmartOrderListViewModel *viewModel;
@property (nonatomic, strong) YXOrderMarketFilterContainerView *marketFilterView;
@property (nonatomic, strong) YXOrderFilterView *filterView;

@end

@implementation YXSmartOrderListViewController

@dynamic viewModel;

- (instancetype)initWithViewModel:(YXViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.isHideNavBar = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (self.viewModel.isAll == NO) {
        self.tableView.backgroundColor = QMUITheme.foregroundColor;
    } else {
        self.tableView.backgroundColor = QMUITheme.foregroundColor;
    }

    [self.tableView registerClass:[YXTradeExpandCell class] forCellReuseIdentifier:NSStringFromClass([YXTradeExpandCell class])];
    [self.tableView registerClass:[YXTradeEmptyCell class] forCellReuseIdentifier:NSStringFromClass([YXTradeEmptyCell class])];

    if (self.viewModel.isAll) {
        [self.view addSubview:self.filterView];
        [self.view addSubview:self.marketFilterView];

        [self.marketFilterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.height.mas_equalTo(40);
        }];

        [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.marketFilterView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(57);
        }];
        
        if (self.viewModel.exchangeType == YXExchangeTypeUsop) {
//            self.filterView.stockFilterView.searchViewModel.mkts = kYXMarketUS;
        }
    }
    
    @weakify(self)
    [self.viewModel.validatePwd.executionSignals.switchToLatest subscribeNext:^(YXConditionOrderModel * _Nullable model) {
        @strongify(self)
        
        UIViewController *current = [UIViewController currentViewController];
        [current.view endEditing:YES];
        
        [YXUserUtility validateTradePwdInViewController:UIViewController.currentViewController successBlock:^(NSString * _Nullable token) {
            @strongify(self)
            if (model != nil) {
                [self undoEntrustSureActionWith:model];
            }
        } failureBlock:nil];
        
    }];
}

- (YXOrderMarketFilterContainerView *)marketFilterView {
    if (!_marketFilterView) {
        _marketFilterView = [[YXOrderMarketFilterContainerView alloc] initWithFrame:CGRectZero defaultMarketFilterType:self.viewModel.marketType];

        @weakify(self);
        _marketFilterView.didShowBlock = ^{
            @strongify(self)
            [self.filterView hideAllFilterView];
            [self.filterView unSelectedAllFilterButton];
        };

        _marketFilterView.selectOrderMarketBlock = ^(YXMarketFilterType market) {
            @strongify(self);
            [self.filterView resetStockFilter];
            self.viewModel.stockCode = @"";
            self.viewModel.marketType = market;
            [self loadFirstPage];
        };
    }
    return _marketFilterView;
}

- (YXOrderFilterView *)filterView {
    if (!_filterView) {
        
        YXOrderFilterType type = YXOrderFilterTypeSmartOrder;
        _filterView = [[YXOrderFilterView alloc] initWithFrame:CGRectZero type:type exchangeType:self.viewModel.exchangeType];
        _filterView.stockFilterView.parentViewController = self;
        @weakify(self);

        _filterView.filterConditionAction = ^(NSString *securityType, NSString *orderStatus, NSString *orderType){
            @strongify(self);
            self.viewModel.securityType = securityType;
            self.viewModel.orderStatus = orderStatus;
            self.viewModel.orderType = orderType;
            [self loadFirstPage];
        };
        
        _filterView.allSotckButtonAction = ^(QMUIButton * _Nonnull btn) {
            @strongify(self);
            self.viewModel.stockCode = @"";
            [self loadFirstPage];
        };
        
        _filterView.stockFilterAction = ^(YXSearchItem * _Nonnull item) {
            @strongify(self);
            NSString *title = [NSString stringWithFormat:@"%@", item.symbol];
            
            [self.filterView.stockFilter setTitle:title forState:UIControlStateNormal];
            self.filterView.stockFilterView.allStockButton.selected = NO;
            self.viewModel.stockCode = item.symbol;
            [self loadFirstPage];
        };
        
        _filterView.dateFilterAction = ^(NSString * _Nonnull dateFlag , NSString * _Nonnull beginDate, NSString * _Nonnull endDate) {
            @strongify(self);
            self.viewModel.transactionTime = dateFlag;
            self.viewModel.beginDate = beginDate;
            self.viewModel.endDate = endDate;
            [self loadFirstPage];
        };
        
    }
    return _filterView;
}

- (NSInteger)exchangeTypeWithMarket:(NSString *)market {
    if ([market isEqualToString:kYXMarketHK]) {
        return 0;
    }else if ([market isEqualToString:kYXMarketUS]) {
        return 5;
    }else {
        return 67;
    }
}

- (void)reloadData {
    if (self.isExpand) {
        __block BOOL contains = NO;
        __block NSInteger row = 0;
        __block NSInteger section = 0;
        [self.viewModel.dataSource enumerateObjectsUsingBlock:^(NSArray *  _Nonnull obj, NSUInteger sectionIdx, BOOL * _Nonnull stop) {
            [obj enumerateObjectsUsingBlock:^(YXConditionOrderModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[YXConditionOrderModel class]] && [self.selectedModel.conId isEqualToString: obj.conId]) {
                    contains = YES;
                    section = sectionIdx;
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
    
    [super reloadData];
}

- (NSArray<Class> *)cellClasses {
    return @[[YXSmartOrderListCell class],[YXDoneOrderTipCell class], [YXSmartOrderListCell class]];
}

- (UIImage *)customImageForEmptyDataSet {
    return [UIImage imageNamed:@"empty_noOrder"];
}

- (NSAttributedString *)customTitleForEmptyDataSet {
    return [[NSAttributedString alloc] initWithString:[YXLanguageUtility kLangWithKey:@"trade_no_smart_order_record"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [QMUITheme textColorLevel3]}];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[YXSmartOrderListCell class]]) {
        return;
    }
    if (!self.selectedIndexPath) {
        self.isExpand = YES;
        self.selectedIndexPath = indexPath;
        self.selectedModel = self.viewModel.dataSource[indexPath.section][indexPath.row];
        [tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    } else {
        if (self.isExpand) {
            if (self.selectedIndexPath == indexPath) {
                self.isExpand = NO;
                self.selectedIndexPath = nil;
                self.selectedModel = nil;
                [tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
            } else if (self.selectedIndexPath.row + 1 == indexPath.row && indexPath.section == self.selectedIndexPath.section) {
                
            } else {
                if (indexPath.row > self.selectedIndexPath.row && indexPath.section == self.selectedIndexPath.section) {
                    indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
                }
                
                self.isExpand = YES;
                self.selectedIndexPath = indexPath;
                self.selectedModel = self.viewModel.dataSource[indexPath.section][indexPath.row];
                [tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionNone animated:NO];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YXTableViewCell *cell;
    id object = nil;
    
    if (self.isExpand && self.selectedIndexPath.section == indexPath.section && self.selectedIndexPath.row < indexPath.row) {
        if (self.selectedIndexPath.row == indexPath.row - 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXTradeExpandCell class]) forIndexPath:indexPath];
            
            YXConditionOrderModel *model = self.viewModel.dataSource[self.selectedIndexPath.section][self.selectedIndexPath.row];

            YXTradeExpandCell *expandCell = (YXTradeExpandCell *)cell;
            expandCell.backgroundColor = QMUITheme.backgroundColor;

            if (model.status == 0) { // 生效中
                expandCell.items = @[@(YXTradeExpandItemPrice), @(YXTradeExpandItemModify), @(YXTradeExpandItemCancel), @(YXTradeExpandItemReorder)];
            } else if (model.status == 1) { // 已触发
                expandCell.items = @[@(YXTradeExpandItemPrice), @(YXTradeExpandItemDetail), @(YXTradeExpandItemReorder)];
            } else if (model.status == 4) { //休眠
                expandCell.items = @[@(YXTradeExpandItemPrice), @(YXTradeExpandItemCancel), @(YXTradeExpandItemDetail), @(YXTradeExpandItemReorder)];
            } else {
                expandCell.items = @[@(YXTradeExpandItemPrice), @(YXTradeExpandItemReorder)];
            }

            @weakify(self)

            ((YXTradeExpandCell *)cell).action = ^(enum YXTradeExpandItem type) {
                @strongify(self)
                if (type == YXTradeExpandItemModify) {
                    [self.viewModel.didClickChange execute:model];
                } else if (type == YXTradeExpandItemCancel) {
                    [self undoConditionAlert:model];
                } else if (type == YXTradeExpandItemDetail) {
                    [self.viewModel.didClickSmartDetail execute:model];
                } else if (type == YXTradeExpandItemPrice) {
                    [self.viewModel.didClickQuote execute:model];
                } else if (type == YXTradeExpandItemReorder) {
                    [self.viewModel.didClickSmartOneMore execute:model];
                }
            };
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierAtIndexPath:indexPath] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            object = self.viewModel.dataSource[indexPath.section][indexPath.row - 1];
        }
    } else if (self.viewModel.isAll == NO && indexPath.section == 0 && [self.viewModel.tradingOrders count] < 1) {
        YXTradeEmptyCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXTradeEmptyCell class]) forIndexPath:indexPath];
        emptyCell.emptyType = YXDefaultEmptyEnumsNoSmartOrder;
        emptyCell.hidden = self.viewModel.doneOrders.count > 0; // 如果存在已完成订单也不用显示空页面
        return emptyCell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierAtIndexPath:indexPath] forIndexPath:indexPath];
        object = self.viewModel.dataSource[indexPath.section][indexPath.row];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configureCell:cell atIndexPath:indexPath withObject:(id)object];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    if ([cell isKindOfClass:[YXDoneOrderTipCell class]]) {
        ((YXDoneOrderTipCell *)cell).isCondition = YES;
        ((YXDoneOrderTipCell *)cell).backgroundColor = QMUITheme.blockColor;
    }
    if ([cell isKindOfClass:[YXSmartOrderListCell class]]) {
        ((YXSmartOrderListCell *)cell).isOrderPage = self.viewModel.isOrder;
        ((YXSmartOrderListCell *)cell).isShowExpandCell = self.isExpand && self.selectedModel == object;
    }
    if ([cell isKindOfClass:[YXTradeEmptyCell class]]) {
        ((YXTradeEmptyCell *)cell).emptyType = YXDefaultEmptyEnumsNoSmartOrder;
    }

    [super configureCell:cell atIndexPath:indexPath withObject:object];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = [self.viewModel.dataSource[section] count];
    
    if (self.selectedIndexPath && self.selectedIndexPath.section == section && self.isExpand) {
        number += 1;
    }
    return number;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.isAll == NO) {
        if (indexPath.section == 0 && [self.viewModel.tradingOrders count] < 1) {
            if (self.viewModel.doneOrders.count > 0) {
                return 0; // 如果存在已完成订单也不用显示空页面
            }
            return 130;
        } else if (indexPath.section == 1) {
            return 24;
        } else if (self.isExpand && self.selectedIndexPath.section == indexPath.section && self.selectedIndexPath.row == indexPath.row - 1) {
            return 56;
        }
    } else {
        if (self.isExpand && self.selectedIndexPath.section == indexPath.section && self.selectedIndexPath.row == indexPath.row - 1) {
            return 56;
        }
    }
    NSInteger count = indexPath.row;
    if (self.isExpand && self.selectedIndexPath.section == indexPath.section && self.selectedIndexPath.row < indexPath.row) {
        count = count - 1;
    }
    YXConditionOrderModel *model = nil;
    if (self.viewModel.isAll) {
        if (self.viewModel.dataSource[indexPath.section].count > count) {
            model = self.viewModel.dataSource[indexPath.section][count];
        }
    } else {
        NSArray *list = nil;
        if (self.viewModel.dataSource[indexPath.section] == self.viewModel.tradingOrders) {
            list = self.viewModel.tradingOrders;
        }
        if (self.viewModel.dataSource[indexPath.section] == self.viewModel.doneOrders) {
            list = self.viewModel.doneOrders;
        }
        if (list.count > count) {
            model = list[count];
        }
    }

    CGFloat rowHeight = 262;
    
    if (YXUserManager.isENMode
        && (model.conditionType == SmartOrderTypeStopLossSell || model.conditionType == SmartOrderTypeStopProfitSell)) {
        rowHeight = 279;
    }

    if (model.entrustGear != nil && model.conditionType != SmartOrderTypeTralingStop) {
        rowHeight = 229;
    }

    if (model.conditionType == SmartOrderTypeStockHandicap) {
        if (model.entrustGear != nil) {
            rowHeight = 270;
        } else {
            rowHeight = 302;
        }
    }

    if (self.isExpand && self.selectedModel == model) {
        rowHeight -= 8; // 分割线
    }

    return rowHeight;
}

- (CGFloat)tableViewTop {
    if (self.viewModel.isAll && self.isHideNavBar == NO) {
        return YXConstant.navBarHeight;
    }else if (self.viewModel.isAll) {
        return 40 + 57;
    }else {
        return 0;
    }
    
}

- (void)pageScrollViewDidScrollCallback:(YXTabPageScrollBlock)callback {
    self.scrollCallBack = callback;
}

- (nonnull UIScrollView *)pageScrollView {
    return self.tableView;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.viewModel.isAll == NO) {
        if (self.scrollCallBack) {
            self.scrollCallBack(scrollView);
        }
    }
}

#pragma mark- 终止
- (void)undoConditionAlert:(YXConditionOrderModel *)model {
    
    YXAlertView *alertView = [YXAlertView alertViewWithMessage:[YXLanguageUtility kLangWithKey:@"trade_smart_stop_msg"]];
    alertView.clickedAutoHide = NO;
    YXAlertController *alertController = [YXAlertController alertControllerWithAlertView:alertView];
    
    @weakify(self,alertView, alertController)
    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleCancel handler:^(YXAlertAction *action) {
        @strongify(alertView)
        [alertView hideView];
    }]];
    
    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"trading_alert_cancel_cond_order_confirm"] style:YXAlertActionStyleDefault handler:^(YXAlertAction *action) {
        @strongify(self,alertView, alertController)
        
        alertController.dismissComplete = ^{
            [self undoEntrustSureActionWith:model];
        };
        [alertView hideView];
    }]];
    
    UIViewController *vc = [UIViewController currentViewController];
    [vc presentViewController:alertController animated:YES completion:nil];
}


//确认终止的响应
- (void)undoEntrustSureActionWith:(YXConditionOrderModel *)model {
    @weakify(self)
        [[self.viewModel.didClickStop execute:model] subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            self.isExpand = NO;
            self.selectedIndexPath = nil;
            [self reloadData];
            
            [self.viewModel.requestRemoteDataCommand execute:@(1)];
        }];
}

@end
