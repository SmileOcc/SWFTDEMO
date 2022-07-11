//
//  YXHomeHoldViewController.m
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXHomeHoldViewController.h"
#import "YXTabPageView.h"
#import "YXAuthorityReminderTool.h"
#import "YXHomeHoldViewModel.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"
#import <MMKV/MMKV.h>

#define ASSET_CELL @"asset_cell"
#define LIST_HEADER_CELL @"list_header_cell"
#define EXPAND @"expand"
#define EXPAND @"expand"
#define EMPTY @"empty"
#define OPEN @"open"

#define YXHomePostionHKSectionExpandStatus @"YXHomePostionHKSectionExpandStatus"
#define YXHomePostionSGSectionExpandStatus @"YXHomePostionSGSectionExpandStatus"
#define YXHomePostionUSSectionExpandStatus @"YXHomePostionUSSectionExpandStatus"
#define YXHomePostionUSOptionSectionExpandStatus @"YXHomePostionUSOptionSectionExpandStatus"
#define YXHomePostionUSFractionSectionExpandStatus @"YXHomePostionUSFractionSectionExpandStatus"

@interface YXHomeHoldViewController () <YXTabPageScrollViewProtocol, YXAuthorityReminderToolDelegate>

@property (nonatomic, copy) YXTabPageScrollBlock scrollCallBack;

@property (nonatomic, strong) YXAccountAssetHoldListItem *selectedModel;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, assign) BOOL shouldHideValue;

@property (nonatomic, strong) YXHomeHoldViewModel *viewModel;
@property (nonatomic, strong) YXAuthorityReminderTool *reminderTool;

@property (nonatomic, strong) YXHomePositionAssetHeaderView *hkView;
@property (nonatomic, strong) YXHomePositionAssetHeaderView *usView;
@property (nonatomic, strong) YXHomePositionAssetHeaderView *sgView;
@property (nonatomic, strong) YXHomePositionAssetHeaderView *usOptionsView;
@property (nonatomic, strong) YXHomePositionAssetHeaderView *usFractionView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) YXBottomSheetViewTool *bottomSheet;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation YXHomeHoldViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.shouldHideValue = YXAccountAssetView.assetHidden;

    self.tableView.backgroundColor = QMUITheme.foregroundColor;
    [self.tableView registerClass:[YXPositionAssetCell class] forCellReuseIdentifier:NSStringFromClass([YXPositionAssetCell class])];
    [self.tableView registerClass:[YXPostionListHeaderCell class] forCellReuseIdentifier:NSStringFromClass([YXPostionListHeaderCell class])];
    [self.tableView registerClass:[YXTradeExpandCell class] forCellReuseIdentifier:NSStringFromClass([YXTradeExpandCell class])];
    [self.tableView registerClass:[YXHomeHoldEmptyCell class] forCellReuseIdentifier:NSStringFromClass([YXHomeHoldEmptyCell class])];
    [self.tableView registerClass:[YXHoldListCell class] forCellReuseIdentifier:NSStringFromClass([YXHoldListCell class])];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.tableView registerClass:[YXHoldStarCell class] forCellReuseIdentifier:NSStringFromClass([YXHoldStarCell class])];
    [self.tableView registerClass:[YXHomeHoldOpenAccountCell class] forCellReuseIdentifier:NSStringFromClass([YXHomeHoldOpenAccountCell class])];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideValueNoti:) name:YXCanHideTextLabel.hideValueNotiName object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)hideValueNoti:(NSNotification *)noti {
    self.shouldHideValue = [noti.userInfo[@"shouldHide"] boolValue];
    [self resetExpandState];
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isHKSectionExpand = [MMKV.defaultMMKV getBoolForKey:YXHomePostionHKSectionExpandStatus];
    self.isSGSectionExpand = [MMKV.defaultMMKV getBoolForKey:YXHomePostionSGSectionExpandStatus];
    self.isUSSectionExpand = [MMKV.defaultMMKV getBoolForKey:YXHomePostionUSSectionExpandStatus];
    self.isUSOptionSectionExpand = [MMKV.defaultMMKV getBoolForKey:YXHomePostionUSOptionSectionExpandStatus];
    self.isUSFractionSectionExpand = [MMKV.defaultMMKV getBoolForKey:YXHomePostionUSFractionSectionExpandStatus];
    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (NSArray *)sortTypes {
    return @[@(YXMobileBrief1TypeMarketValueAndNumber), @(YXMobileBrief1TypeLastAndCostPrice), @(YXMobileBrief1TypeHoldingBalance)];
}

- (void)reloadData {
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(reloadDataIfNeeded) userInfo:nil repeats:NO];
    }
}

- (void)reloadDataIfNeeded {
    self.timer = nil;

    if (self.viewModel.dataSource == nil) {
        self.dataSource = nil;
        [self.tableView reloadData];
        return;
    }

    if (!self.isExpand) {
        self.selectedModel = nil;
    }
    self.selectedIndexPath = nil;

    NSMutableArray *dataSource = [NSMutableArray array];

    for (YXAccountAssetData *assetData in self.viewModel.assetModel.assetSingleInfoRespVOS) {
        BOOL isSectionExpand = NO;

        NSString *market = assetData.exchangeType.lowercaseString;
        if ([market isEqualToString:kYXMarketHK]) {
            isSectionExpand = self.isHKSectionExpand;
        } else if ([market isEqualToString:kYXMarketUS]) {
            switch (assetData.accountBusinessType) {
                case YXAccountBusinessTypeNormal: {
                    isSectionExpand = self.isUSSectionExpand;
                }
                    break;
                case YXAccountBusinessTypeUsFraction: {
                    isSectionExpand = self.isUSFractionSectionExpand;
                }
                    break;
                case YXAccountBusinessTypeUsOption: {
                    isSectionExpand = self.isUSOptionSectionExpand;
                }
                    break;
            }
        } else if ([market isEqualToString:kYXMarketSG]) {
            isSectionExpand = self.isSGSectionExpand;
        }

        BOOL isOpenAccount = assetData.fundAccountStatus == YXAccountStatusOpened;

        if (!isOpenAccount) { // 未开户固定展开，不支持隐藏
            isSectionExpand = YES;
        }

        if (isSectionExpand) {
            NSMutableArray *sectionCells = @[].mutableCopy;

            if (!isOpenAccount) {
                // 开户 cell
                [sectionCells addObject:OPEN];
            } else {
                // 资产 cell
                if (self.viewModel.isAssetPage) { // 交易首页显示，下单页不需要显示
                    [sectionCells addObject:ASSET_CELL];
                }

                NSInteger section = [self.viewModel.assetModel.assetSingleInfoRespVOS indexOfObject:assetData];
                NSArray *holdList = self.viewModel.dataSource[section];

                if (holdList.count == 0) {
                    // 空持仓 cell
                    [sectionCells addObject:EMPTY];
                } else {
                    [sectionCells addObject:LIST_HEADER_CELL];

                    // 持仓 cell
                    [sectionCells addObjectsFromArray:holdList];

                    if (self.isExpand) {
                        @weakify(self)
                        [sectionCells enumerateObjectsUsingBlock:^(YXAccountAssetHoldListItem   * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([obj isKindOfClass:[YXAccountAssetHoldListItem class]] && [self.selectedModel isKindOfClass:[YXAccountAssetHoldListItem class]]) {
                                @strongify(self)
                                if (self.selectedModel.accountBusinessType == obj.accountBusinessType
                                    && [self.selectedModel.stockCode isEqualToString:obj.stockCode]
                                    && self.selectedModel.exchangeType == obj.exchangeType) {
                                    *stop = YES;

                                    self.selectedModel = obj;
                                    self.selectedIndexPath = [NSIndexPath indexPathForRow:idx inSection:section];

                                    // 插入 expand cell
                                    [sectionCells insertObject:EXPAND atIndex:idx + 1];
                                }
                            }
                        }];
                    }
                }
            }

            [dataSource addObject:sectionCells];
       } else {
           [dataSource addObject:@[]];
       }
    }

    // 未匹配到选中项，重置 isExpand
    if (!self.selectedIndexPath) {
        self.isExpand = NO;
    }

    self.dataSource = [dataSource copy];
    [self.tableView reloadData];
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

    if (![cell isKindOfClass:[YXHoldListCell class]]) {
        return;
    }

    self.selectedModel = self.dataSource[indexPath.section][indexPath.row];

    if (self.isExpand && indexPath == self.selectedIndexPath) {
        self.isExpand = NO;
    }else {
        self.isExpand = YES;

        if (self.selectedIndexPath) {
            NSIndexPath *expandCellIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row + 1 inSection:self.selectedIndexPath.section];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXTradeExpandCell class]) forIndexPath:expandCellIndexPath];
            if ([cell isKindOfClass:[YXTradeExpandCell class]]) {
                [(YXTradeExpandCell *)cell resetScrollViewContentOffset];
            }
        }
    }

    if (self.selectedModel.stockCode) {
        [self trackViewClickEventWithName:@"stocklist_item"
                                    other:@{@"stock_code": self.selectedModel.stockCode,
                                            @"stock_name": self.selectedModel.stockName ?: @""}];
    }

    [self reloadData];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    id model = self.dataSource[indexPath.section][indexPath.row];

    if ([model isKindOfClass:[YXAccountAssetHoldListItem class]]) {
        if (self.shouldHideValue) {
            YXHoldStarCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXHoldStarCell class]) forIndexPath:indexPath];
            cell.model = model;
            RACChannelTerminal *channel = RACChannelTo(self.viewModel, contentOffset);
            RACChannelTerminal *cellChannel = RACChannelTo(((YXHoldStarCell *)cell).scrollView, contentOffset);

            [[channel takeUntil:cell.rac_prepareForReuseSignal] subscribe:cellChannel];
            [[cellChannel takeUntil:cell.rac_prepareForReuseSignal] subscribe:channel];
            return cell;
        }else {
            YXHoldListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXHoldListCell class]) forIndexPath:indexPath];
            cell.model = model;

            RACChannelTerminal *channel = RACChannelTo(self.viewModel, contentOffset);
            RACChannelTerminal *cellChannel = RACChannelTo(cell.scrollView, contentOffset);

            [[channel takeUntil:cell.rac_prepareForReuseSignal] subscribe:cellChannel];
            [[cellChannel takeUntil:cell.rac_prepareForReuseSignal] subscribe:channel];

            return cell;
        }

    } else if ([model isKindOfClass:[NSString class]]) {
        NSString *str = model;
        @weakify(self)

        if ([str isEqualToString:ASSET_CELL]) {
            YXPositionAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXPositionAssetCell class])];
            YXAccountAssetData *assetData = self.viewModel.assetModel.assetSingleInfoRespVOS[indexPath.section];
            cell.model = assetData;

            cell.detailButtonAction = ^() {
                @strongify(self)
                [self trackViewClickEventWithName:@"Account details_Tab" other:nil];

                NSString *market = assetData.exchangeType.lowercaseString;
                if ([market isEqualToString:kYXMarketHK]) {
                    NSString *url = [YXH5Urls assetExplainUrlWithAccountBusinessType:YXAccountBusinessTypeNormal moneyType:@"HKD" market:@"hk"];
                    [YXWebViewModel pushToWebVC:url];
                } else if ([market isEqualToString:kYXMarketUS]) {
                    switch (assetData.accountBusinessType) {
                        case YXAccountBusinessTypeNormal: {
                            NSString *url = [YXH5Urls assetExplainUrlWithAccountBusinessType:YXAccountBusinessTypeNormal moneyType:@"USD" market:@"us"];
                            [YXWebViewModel pushToWebVC:url];
                        }
                            break;
                        case YXAccountBusinessTypeUsFraction: {
                            NSString *url = [YXH5Urls assetExplainUrlWithAccountBusinessType:YXAccountBusinessTypeUsFraction moneyType:@"USD" market:@"us"];
                            [YXWebViewModel pushToWebVC:url];
                        }
                            break;
                        case YXAccountBusinessTypeUsOption: {
                            NSString *url = [YXH5Urls assetExplainUrlWithAccountBusinessType:YXAccountBusinessTypeUsOption moneyType:@"USD" market:@"us"];
                            [YXWebViewModel pushToWebVC:url];
                        }
                            break;
                    }
                } else if ([market isEqualToString:kYXMarketSG]) {
                    NSString *url = [YXH5Urls assetExplainUrlWithAccountBusinessType:YXAccountBusinessTypeNormal moneyType:@"SGD" market:@"sg"];
                    [YXWebViewModel pushToWebVC:url];
                }
            };

            return cell;
        } else if ([str isEqualToString:LIST_HEADER_CELL]) {
            YXPostionListHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXPostionListHeaderCell class])];
            cell.lineView.hidden = self.viewModel.isAssetPage;
            cell.sortTypes = self.sortTypes;

            YXAccountAssetData *assetData = self.viewModel.assetModel.assetSingleInfoRespVOS[indexPath.section];
            NSString *market = assetData.exchangeType.lowercaseString;

            if ([market isEqualToString:kYXMarketHK]) {
                [cell.stockListHeaderView setDefaultSortState:self.viewModel.hkstate mobileBrief1Type:self.viewModel.hktype];
            } else if ([market isEqualToString:kYXMarketUS]) {
                switch (assetData.accountBusinessType) {
                    case YXAccountBusinessTypeNormal: {
                        [cell.stockListHeaderView setDefaultSortState:self.viewModel.usstate mobileBrief1Type:self.viewModel.ustype];
                    }
                        break;
                    case YXAccountBusinessTypeUsFraction: {
                        [cell.stockListHeaderView setDefaultSortState:self.viewModel.usFractionState mobileBrief1Type:self.viewModel.usFractionType];
                    }
                        break;
                    case YXAccountBusinessTypeUsOption: {
                        [cell.stockListHeaderView setDefaultSortState:self.viewModel.usOptionState mobileBrief1Type:self.viewModel.usOptionType];
                    }
                        break;
                }
            } else if ([market isEqualToString:kYXMarketSG]) {
                [cell.stockListHeaderView setDefaultSortState:self.viewModel.sgstate mobileBrief1Type:self.viewModel.sgtype];
            }

            [cell.stockListHeaderView setOnClickSort:^(YXSortState state, YXMobileBrief1Type type) {
                @strongify(self)
                if ([market isEqualToString:kYXMarketHK]) {
                    self.viewModel.hkstate = state;
                    self.viewModel.hktype = type;
                    [self.viewModel.didClickSortCommand execute:@[@(YXAccountAreaHk), @(state), @(type)]];
                } else if ([market isEqualToString:kYXMarketUS]) {
                    switch (assetData.accountBusinessType) {
                        case YXAccountBusinessTypeNormal: {
                            self.viewModel.usstate = state;
                            self.viewModel.ustype = type;
                            [self.viewModel.didClickSortCommand execute:@[@(YXAccountAreaUs), @(state), @(type)]];
                        }
                            break;
                        case YXAccountBusinessTypeUsFraction: {
                            self.viewModel.usFractionState = state;
                            self.viewModel.usFractionType = type;
                            [self.viewModel.didClickSortCommand execute:@[@(YXAccountAreaUsFraction), @(state), @(type)]];
                        }
                            break;
                        case YXAccountBusinessTypeUsOption: {
                            self.viewModel.usOptionState = state;
                            self.viewModel.usOptionType = type;
                            [self.viewModel.didClickSortCommand execute:@[@(YXAccountAreaUsoptions), @(state), @(type)]];
                        }
                            break;
                    }
                } else if ([market isEqualToString:kYXMarketSG]) {
                    self.viewModel.sgstate = state;
                    self.viewModel.sgtype = type;
                    [self.viewModel.didClickSortCommand execute:@[@(YXAccountAreaSg), @(state), @(type)]];
                }
            }];

            RACChannelTerminal *channel = RACChannelTo(self.viewModel, contentOffset);
            RACChannelTerminal *cellChannel = RACChannelTo(cell.stockListHeaderView.scrollView, contentOffset);

            [[channel takeUntil:cell.rac_prepareForReuseSignal] subscribe:cellChannel];
            [[cellChannel takeUntil:cell.rac_prepareForReuseSignal] subscribe:channel];

            return cell;
        } else if ([str isEqualToString:EXPAND]) {
            YXTradeExpandCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXTradeExpandCell class]) forIndexPath:indexPath];

            if ([self.selectedModel.exchangeType.lowercaseString isEqualToString:kYXMarketHK]) {
                NSMutableArray *items = @[@(YXTradeExpandItemPrice), @(YXTradeExpandItemBuy), @(YXTradeExpandItemSell),@(YXTradeExpandItemSmart)].mutableCopy;
                if (!self.selectedModel.isWarrants) {
                    [items addObject:@(YXTradeExpandItemWarrant)];
                }
                [items addObject:@(YXTradeExpandItemShare)];
                cell.items = items;
            } else if ([self.selectedModel.exchangeType.lowercaseString isEqualToString:kYXMarketSG]){
                cell.items = @[@(YXTradeExpandItemPrice), @(YXTradeExpandItemBuy), @(YXTradeExpandItemSell), @(YXTradeExpandItemSmart), @(YXTradeExpandItemShare)];
            }  else {
                switch (self.selectedModel.accountBusinessType) {
                    case YXAccountBusinessTypeNormal:
                        cell.items = @[@(YXTradeExpandItemPrice), @(YXTradeExpandItemBuy), @(YXTradeExpandItemSell),@(YXTradeExpandItemSmart), @(YXTradeExpandItemShare)];
                        break;
                    case YXAccountBusinessTypeUsFraction:
                        cell.items = @[@(YXTradeExpandItemPrice), @(YXTradeExpandItemBuy), @(YXTradeExpandItemSell), @(YXTradeExpandItemShare)];
                        break;
                    case YXAccountBusinessTypeUsOption:
                        cell.items = @[@(YXTradeExpandItemPrice), @(YXTradeExpandItemBuy), @(YXTradeExpandItemSell), @(YXTradeExpandItemShare)];
                        break;
                }
            }

            cell.action = ^(enum YXTradeExpandItem type) {
                @strongify(self)
                if (type == YXTradeExpandItemBuy) {
                    [self trackViewClickEventWithName:@"Buy_Tab" other:nil];
                    [self.viewModel.didClickBuy execute:self.selectedModel];
                }else if (type == YXTradeExpandItemSell) {
                    [self trackViewClickEventWithName:@"Sell_Tab" other:nil];
                    [self.viewModel.didClickSell execute:self.selectedModel];
                }else if (type == YXTradeExpandItemLastLiq) {

                }else if (type == YXTradeExpandItemWarrant) {
                    [self.viewModel.didClickWarrant execute:self.selectedModel];
                }else if (type == YXTradeExpandItemPrice) {
                    [self trackViewClickEventWithName:@"Quote_Tab" other:nil];
                    [self.viewModel.didClickQuote execute:self.selectedModel];
                }else if (type == YXTradeExpandItemSmart){
                    [self trackViewClickEventWithName:@"Smart order_Tab" other:nil];
                    [self goToSmartTrde];
                }else if (type == YXTradeExpandItemShare){
                    [self trackViewClickEventWithName:@"share_Tab" other:nil];
                    [YXHoldShareView showShareViewWithType:HoldShareTypeHold
                                              exchangeType:self.selectedModel.exchangeType.lowercaseString.exchangeType
                                                     model:self.selectedModel];
                }
            };

            return cell;

        } else if ([str isEqualToString:EMPTY]) {
            YXHomeHoldEmptyCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXHomeHoldEmptyCell class]) forIndexPath:indexPath];
            return emptyCell;
        } else if([str isEqualToString:OPEN]) {
            YXHomeHoldOpenAccountCell *openCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXHomeHoldOpenAccountCell class]) forIndexPath:indexPath];

            YXAccountAssetData *assetData = self.viewModel.assetModel.assetSingleInfoRespVOS[indexPath.section];
            switch (assetData.accountBusinessType) {
                case YXAccountBusinessTypeNormal:
                    break;
                case YXAccountBusinessTypeUsFraction: {
                    openCell.titleLabel.text = [YXLanguageUtility kLangWithKey:@"account_open_usfraction_tips"];
                    openCell.openAction = ^{
                        [YXWebViewModel pushToWebVC:[YXH5Urls OpenUsFractionURL]];
                    };
                }
                    break;
                case YXAccountBusinessTypeUsOption: {
                    openCell.titleLabel.text = [YXLanguageUtility kLangWithKey:@"account_open_usoption_tips"];
                    openCell.openAction = ^{
                        [YXWebViewModel pushToWebVC:[YXH5Urls OpenUsOptionURL]];
                    };
                }
                    break;
            }

            return openCell;
        }
    }

    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = self.dataSource[indexPath.section][indexPath.row];
    if ([model isKindOfClass:[NSString class]]) {
        NSString *str = model;
        if ([str isEqualToString:EMPTY]) {
            return 213;
        } else if ([str isEqualToString:OPEN]){
            YXAccountAssetData *assetData = self.viewModel.assetModel.assetSingleInfoRespVOS[indexPath.section];
            if (assetData.accountBusinessType == YXAccountBusinessTypeUsFraction && YXUserManager.curLanguage == YXLanguageTypeEN) {
                return 104;
            }
            return 88;
        } else if ([str isEqualToString:EXPAND]) {
            return 56;
        } else if ([str isEqualToString:ASSET_CELL]) {
            return 58;
        } else if ([str isEqualToString:LIST_HEADER_CELL]) {
            return 35;
        }
    }
    return 58;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    YXHomePositionAssetHeaderView *view = nil;

    YXAccountAssetData *assetData = self.viewModel.assetModel.assetSingleInfoRespVOS[section];
    NSString *market = assetData.exchangeType.lowercaseString;

    BOOL isSectionExpand = NO;

    if ([market isEqualToString:kYXMarketHK]) {
        view = self.hkView;
        isSectionExpand = self.isHKSectionExpand;
    } else if ([market isEqualToString:kYXMarketUS]) {
        switch (assetData.accountBusinessType) {
            case YXAccountBusinessTypeNormal:
                view = self.usView;
                isSectionExpand = self.isUSSectionExpand;
                break;
            case YXAccountBusinessTypeUsFraction:
                view = self.usFractionView;
                isSectionExpand = self.isUSFractionSectionExpand;
                break;
            case YXAccountBusinessTypeUsOption:
                view = self.usOptionsView;
                isSectionExpand = self.isUSOptionSectionExpand;
                break;
        }
    } else if ([market isEqualToString:kYXMarketSG]) {
        view = self.sgView;
        isSectionExpand = self.isSGSectionExpand;
    }

    view.model = assetData;

    view.expandButton.selected = isSectionExpand;
    view.expandButton.hidden = assetData.fundAccountStatus == YXAccountStatusUnopened;

    view.topLineView.hidden = section == 0;

    if (assetData.fundAccountStatus == YXAccountStatusUnopened) {
        view.bottomLineView.hidden = YES;
    } else {
        BOOL isLastSection = section == self.viewModel.assetModel.assetSingleInfoRespVOS.count - 1;
        if (isLastSection && !isSectionExpand) {
            view.bottomLineView.hidden = NO;
        } else {
            view.bottomLineView.hidden = YES;
        }
    }

    return view;
}

- (CGFloat)tableViewTop {
    return 0;
}

- (UIScrollView *)pageScrollView {
    return self.tableView;
}

- (void)pageScrollViewDidScrollCallback:(YXTabPageScrollBlock)callback {
    self.scrollCallBack = callback;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollCallBack) {
        self.scrollCallBack(scrollView);
    }
}

- (void)goToSmartTrde{
    if (self.viewModel.isOrder) {
        [self.viewModel.changeSmartTrade execute:self.selectedModel];
    } else {
        YXSmartTradeGuideViewModel *vm = [[YXSmartTradeGuideViewModel alloc] initWithServices:self.viewModel.services params:nil];
        vm.tradeModel.market = [self.selectedModel.exchangeType lowercaseString];
        vm.tradeModel.symbol = self.selectedModel.stockCode;
        YXSmartTradeGuideViewController *vc = [[YXSmartTradeGuideViewController alloc] initWithViewModel:vm];
        self.bottomSheet.titleLabel.text = [YXLanguageUtility kLangWithKey:@"account_stock_order_title"];
        [self.bottomSheet showViewControllerWithVc:vc];
    }
}

- (YXHomePositionAssetHeaderView *)hkView {
    if (!_hkView) {
        _hkView = [[YXHomePositionAssetHeaderView alloc] initWithArea:YXAccountAreaHk];

        @weakify(self)
        _hkView.expandButtonAction = ^(BOOL isExpand) {
            @strongify(self)
            [self trackViewClickEventWithCustomPageName:@"Trade" name:@"HK Acc_Tab" other:nil];

            self.isHKSectionExpand = isExpand;
            self.isUSSectionExpand = NO;
            self.isSGSectionExpand = NO;
            self.isUSOptionSectionExpand = NO;
            self.isUSFractionSectionExpand = NO;

            [self reloadData];
        };
    }
    return _hkView;
}

- (YXHomePositionAssetHeaderView *)usView {
    if (!_usView) {
        _usView = [[YXHomePositionAssetHeaderView alloc] initWithArea:YXAccountAreaUs];

        @weakify(self)
        _usView.expandButtonAction = ^(BOOL isExpand) {
            @strongify(self)
            [self trackViewClickEventWithCustomPageName:@"Trade" name:@"US Acct_Tab" other:nil];

            self.isUSSectionExpand = isExpand;
            self.isHKSectionExpand = NO;
            self.isSGSectionExpand = NO;
            self.isUSOptionSectionExpand = NO;
            self.isUSFractionSectionExpand = NO;

            [self reloadData];
        };
    }
    return _usView;
}

- (YXHomePositionAssetHeaderView *)sgView {
    if (!_sgView) {
        _sgView = [[YXHomePositionAssetHeaderView alloc] initWithArea:YXAccountAreaSg];

        @weakify(self)
        _sgView.expandButtonAction = ^(BOOL isExpand) {
            @strongify(self)
            [self trackViewClickEventWithCustomPageName:@"Trade" name:@"SG Acct_Tab" other:nil];

            self.isSGSectionExpand = isExpand;
            self.isHKSectionExpand = NO;
            self.isUSSectionExpand = NO;
            self.isUSOptionSectionExpand = NO;
            self.isUSFractionSectionExpand = NO;

            [self reloadData];
        };
    }
    return _sgView;
}

- (YXHomePositionAssetHeaderView *)usOptionsView{
    if (!_usOptionsView) {
        _usOptionsView = [[YXHomePositionAssetHeaderView alloc] initWithArea:YXAccountAreaUsoptions];
        @weakify(self)
        _usOptionsView.expandButtonAction = ^(BOOL isExpand) {
            @strongify(self)
            [self trackViewClickEventWithCustomPageName:@"Trade" name:@"US Option Acc_Tab" other:nil];

            self.isUSOptionSectionExpand = isExpand;
            self.isHKSectionExpand = NO;
            self.isUSSectionExpand = NO;
            self.isSGSectionExpand = NO;
            self.isUSFractionSectionExpand = NO;

            [self reloadData];
        };
    }
    return  _usOptionsView;
}

- (YXHomePositionAssetHeaderView *)usFractionView {
    if (!_usFractionView) {
        _usFractionView = [[YXHomePositionAssetHeaderView alloc] initWithArea:YXAccountAreaUsFraction];

        @weakify(self)
        _usFractionView.expandButtonAction = ^(BOOL isExpand) {
            @strongify(self)
            [self trackViewClickEventWithCustomPageName:@"Trade" name:@"US Fraction Acc_Tab" other:nil];

            self.isUSFractionSectionExpand = isExpand;
            self.isHKSectionExpand = NO;
            self.isUSSectionExpand = NO;
            self.isSGSectionExpand = NO;
            self.isUSOptionSectionExpand = NO;

            [self reloadData];
        };
    }
    return _usFractionView;
}


- (void)resetExpandState {
    self.isExpand = false;
    self.selectedModel = nil;
    self.selectedIndexPath = nil;
}

- (YXBottomSheetViewTool *)bottomSheet{
    if (!_bottomSheet) {
        _bottomSheet = [[YXBottomSheetViewTool alloc] init];
        [_bottomSheet rightBtnOnlyImageWithIamge:[UIImage imageNamed:@"nav_info"]];
       // @weakify(self)
        _bottomSheet.rightButtonAction = ^{
           // @strongify(self)
            [(QMUIModalPresentationViewController *)[UIViewController currentViewController] hideWithAnimated:YES completion:^(BOOL finished) {
                [YXWebViewModel pushToWebVC:[YXH5Urls smartHelpUrl]];
                //[self.viewModel pushToSmartOrderWith:smartOrder];
            }];
        };
    }
    return  _bottomSheet;
}


- (NSString *)pageName {
    return @"Trade_Position";
}

#pragma mark - Setter

- (void)setIsHKSectionExpand:(BOOL)isHKSectionExpand {
    if (_isHKSectionExpand == isHKSectionExpand) {
        return;
    }
    _isHKSectionExpand = isHKSectionExpand;
    [MMKV.defaultMMKV setBool:isHKSectionExpand forKey:YXHomePostionHKSectionExpandStatus];
}

- (void)setIsSGSectionExpand:(BOOL)isSGSectionExpand {
    if (_isSGSectionExpand == isSGSectionExpand) {
        return;
    }
    _isSGSectionExpand = isSGSectionExpand;
    [MMKV.defaultMMKV setBool:isSGSectionExpand forKey:YXHomePostionSGSectionExpandStatus];
}

- (void)setIsUSSectionExpand:(BOOL)isUSSectionExpand {
    if (_isUSSectionExpand == isUSSectionExpand) {
        return;
    }
    _isUSSectionExpand = isUSSectionExpand;
    [MMKV.defaultMMKV setBool:isUSSectionExpand forKey:YXHomePostionUSSectionExpandStatus];
}

- (void)setIsUSOptionSectionExpand:(BOOL)isUSOptionSectionExpand {
    if (_isUSOptionSectionExpand == isUSOptionSectionExpand) {
        return;
    }
    _isUSOptionSectionExpand = isUSOptionSectionExpand;
    [MMKV.defaultMMKV setBool:isUSOptionSectionExpand forKey:YXHomePostionUSOptionSectionExpandStatus];
}

- (void)setIsUSFractionSectionExpand:(BOOL)isUSFractionSectionExpand {
    if (_isUSFractionSectionExpand == isUSFractionSectionExpand) {
        return;
    }
    _isUSFractionSectionExpand = isUSFractionSectionExpand;
    [MMKV.defaultMMKV setBool:isUSFractionSectionExpand forKey:YXHomePostionUSFractionSectionExpandStatus];
}

@end
