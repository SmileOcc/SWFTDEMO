//
//  YXWarrantsStreetViewController.m
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/11/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXWarrantsStreetViewController.h"
#import "YXWarrantsStreetViewModel.h"
#import "YXWarrantsSortView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "UIGestureRecognizer+YYAdd.h"

@interface YXWarrantsStreetViewController ()

@property (nonatomic, strong) YXWarrantsStreetViewModel *viewModel;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIButton *hideBtn;

@property (nonatomic, strong) YXStreetScaleView *scaleView;

@property (nonatomic, strong) YXQuoteRequest *quoteSubscribe;//行情订阅

@property (nonatomic, assign) BOOL showRangeSort;
@property (nonatomic, assign) BOOL showDateSort;

@property (nonatomic, strong) YXBottomSheetViewTool *bottomSheet;

@end

@implementation YXWarrantsStreetViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showRangeSort = NO;
    self.showDateSort = NO;
    
    [self.headerView addSubview:self.scaleView];
    [self.scaleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
        make.bottom.equalTo(self.headerView).offset(-20);
        make.left.equalTo(self.headerView).offset(16);
        make.right.equalTo(self.headerView).offset(-16);
    }];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
    self.tableView.backgroundColor = [QMUITheme foregroundColor];

     [self.headerView cleanStock];
     [self updateHeaderView];
     
     [self.view addSubview:self.backView];
     [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.right.bottom.equalTo(self.view);
         make.top.equalTo(self.headerView.stockView.mas_bottom).offset(40);
     }];
     
     [self.backView addSubview:self.hideBtn];
     [self.hideBtn mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.top.right.bottom.equalTo(self.backView);
     }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self subscribe];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self hideSortView];
    [self close];
    
}

- (void)bindViewModel {
    
    [super bindViewModel];
    
    @weakify(self)
    [[self.headerView.rangeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.headerView.rangeBtn.selected = YES;
        self.headerView.dateBtn.selected = NO;
        NSMutableArray *titles = [NSMutableArray array];
        for (NSNumber *number in self.headerView.rangeArr) {
            NSNumber *value = @(number.doubleValue / pow(10.0, self.viewModel.priceBase.integerValue));
            if ([YXToolUtility isPureInt:value.stringValue]) {
                [titles addObject: [NSString stringWithFormat: @"%dHKD", value.intValue]];
            } else {
                if (value.floatValue < 0.1) {
                    [titles addObject:[NSString stringWithFormat:@"%.2fHKD", value.floatValue]];
                } else {
                    [titles addObject:[NSString stringWithFormat:@"%.1fHKD", value.floatValue]];
                }
            }
        }
        YXWarrantsSortView *sortView = [[YXWarrantsSortView alloc] initWithTitleArr:titles selectIndex: self.headerView.rangeIndex];
        @weakify(self)
        sortView.seletedBlock = ^(NSInteger x) {
            @strongify(self)
            self.headerView.rangeIndex = x;
            [self hideSortView];
            self.viewModel.rangeIndex = x;
            [self.viewModel.detailCommand execute:nil];
            [self.bottomSheet hide];
        };

        self.bottomSheet.rightButton.hidden = YES;
        [self.bottomSheet showViewWithView:sortView contentHeight:380];
        
    }];
    
    [[self.headerView.dateBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.headerView.rangeBtn.selected = NO;
        self.headerView.dateBtn.selected = YES;
        NSMutableArray *titles = [NSMutableArray array];
        for (NSNumber *number in self.headerView.dateArr) {
            YXDateModel *dateModel = [YXDateToolUtility dateTimeAndWeekWithTimeString:number.stringValue];
            NSString *timeStr = [YXDateHelper commonDateStringWithNumber:number.longLongValue format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeSlash showWeek:NO];
            [titles addObject:[NSString stringWithFormat:@"%@(%@)", timeStr, dateModel.week]];
        }
        YXWarrantsSortView *sortView = [[YXWarrantsSortView alloc] initWithTitleArr:titles selectIndex: self.headerView.dateIndex];
        @weakify(self)
        sortView.seletedBlock = ^(NSInteger x) {
            @strongify(self)
            self.headerView.dateIndex = x;
            [self hideSortView];
            self.viewModel.dateIndex = x;
            [self.viewModel.detailCommand execute:nil];
            [self.bottomSheet hide];
        };
        
        self.bottomSheet.rightButton.hidden = YES;
        [self.bottomSheet showViewWithView:sortView contentHeight:YXConstant.screenHeight - YXConstant.navBarHeight];
    }];
    
    [RACObserve(self.viewModel, responseModel) subscribeNext:^(YXCbbcDetailResponseModel *  _Nullable x) {
        @strongify(self)
        if (x) {
            self.scaleView.model = x;
            [self updateHeaderView];
        } else {
            self.scaleView.model = nil;
            self.scaleView.hidden = YES;
        }
    }];
    
    self.viewModel.didSelectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSIndexPath * _Nullable indexPath) {
        @strongify(self)
        
        YXStreetCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self.mainViewController.tabView selectTabAtIndex:0];
        CbbcCell *cbbc = ((CbbcCell *)cell.model);
        if (cbbc.callPutFlag == 3) {
            [self.mainViewController.warrantsViewController setPrcDataWithLow:cell.prcLowerString up:cell.prcUpperString type:YXBullAndBellTypeBull];
        } else {
            [self.mainViewController.warrantsViewController setPrcDataWithLow:cell.prcLowerString up:cell.prcUpperString type:YXBullAndBellTypeBear];
        }
        
        
        return [RACSignal empty];
    }];
    
    [[self.headerView.stockBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        
        YXStockInputModel *input = [[YXStockInputModel alloc] init];
        input.name = self.viewModel.name;
        input.symbol = self.viewModel.code;
        input.market = kYXMarketHK;
        
        [self.viewModel.services pushPath:YXModulePathsStockDetail context:@{@"dataSource": @[input], @"selectIndex": @(0)} animated:YES];
    }];
}

- (void)updateHeaderViewStock {
    self.headerView.nameLab.text = self.viewModel.name;
    if (self.viewModel.now.length > 0 && [self.viewModel.now integerValue] != 0) {
        self.headerView.nowLab.text = [YXToolUtility stockPriceData:self.viewModel.now.doubleValue deciPoint:self.viewModel.priceBase.integerValue priceBase:self.viewModel.priceBase.integerValue];
    }else {
        self.headerView.nowLab.text = @"--";
    }
    
    NSString *change = [YXToolUtility stockPriceData:self.viewModel.change.doubleValue deciPoint:self.viewModel.priceBase.integerValue priceBase:self.viewModel.priceBase.integerValue];
    NSString *row = [NSString stringWithFormat:@"%.2lf%%", [self.viewModel.roc doubleValue]/100];
    if (self.viewModel.change.doubleValue > 0) {
        self.headerView.changeLab.text = [NSString stringWithFormat:@"+%@", change];
        self.headerView.rocLab.text = [NSString stringWithFormat:@"+%@", row];
    }else {
        self.headerView.changeLab.text = change;
        self.headerView.rocLab.text = row;
    }
    
    if ([self.viewModel.change doubleValue] > 0) {
        self.headerView.nowLab.textColor = QMUITheme.stockRedColor ;
        self.headerView.changeLab.textColor = QMUITheme.stockRedColor;
        self.headerView.rocLab.textColor = QMUITheme.stockRedColor;
    } else if ([self.viewModel.change doubleValue] == 0) {
        self.headerView.nowLab.textColor = QMUITheme.stockGrayColor;
        self.headerView.changeLab.textColor = QMUITheme.stockGrayColor;
        self.headerView.rocLab.textColor = QMUITheme.stockGrayColor;
    } else {
        self.headerView.nowLab.textColor = QMUITheme.stockGreenColor;
        self.headerView.changeLab.textColor = QMUITheme.stockGreenColor;
        self.headerView.rocLab.textColor = QMUITheme.stockGreenColor;
    }
}

- (void)updateHeaderView {
    
    if (self.viewModel.code.length > 0) {
       
        self.headerView.stockView.hidden = NO;
        self.scaleView.hidden = NO;
        self.headerView.sortView.hidden = NO;

        self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 280);
        
        [self.headerView.searchView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        [self.headerView.stockView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(68);
        }];
        
        [self.scaleView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(122);
        }];
        
    }else {
        
        self.headerView.stockView.hidden = YES;
        self.scaleView.hidden = YES;
        self.headerView.sortView.hidden = YES;
        
        self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 84);
        
        [self.headerView.searchView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(58);
        }];
        
        [self.headerView.stockView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        [self.scaleView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

- (YXWarrantsStreetHeaderView *)headerView {
    if (!_headerView){
        _headerView = [[YXWarrantsStreetHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 164)];
        _headerView.viewModel = self.viewModel;
        
        @weakify(self)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @strongify(self)
            [self.mainViewController searchActionWithType:YXStockWarrantsTypeCBBC];
        }];
        
        [[[_headerView.searchButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self.mainViewController searchActionWithType:YXStockWarrantsTypeCBBC];
        }];
        
        [_headerView.searchBgView addGestureRecognizer:tap];
    }
    return _headerView;
}

#pragma mark- subscribe
- (void)subscribe {
    if (self.viewModel.code.length == 0) {
        self.viewModel.responseModel = nil;
        self.viewModel.dataSource = @[];
        self.headerView.rangeArr = @[];
        self.headerView.dateArr = @[];
        return;
    }
    self.headerView.hidden = NO;
    [self.quoteSubscribe cancel];
    Secu *secu = [[Secu alloc] initWithMarket:kYXMarketHK symbol:self.viewModel.code];
    QuoteLevel level = [[YXUserManager shared] getLevelWith:kYXMarketHK];
    @weakify(self)
    self.quoteSubscribe = [[YXQuoteManager sharedInstance] subRtSimpleQuoteWithSecus:@[secu] level:level handler:^(NSArray<YXV2Quote *> * _Nonnull list, enum Scheme scheme) {
        @strongify(self)
        YXV2Quote *quotaModel = list.firstObject;
        if ([self.viewModel.code isEqualToString:quotaModel.symbol] && [self.viewModel.market isEqualToString:quotaModel.market]) {
            self.viewModel.name = quotaModel.name;
            self.viewModel.roc = [NSString stringWithFormat:@"%d", quotaModel.pctchng.value];
            self.viewModel.change = [NSString stringWithFormat:@"%lld", quotaModel.netchng.value];
            self.viewModel.now = [NSString stringWithFormat:@"%lld", quotaModel.latestPrice.value];
            self.viewModel.priceBase = [NSString stringWithFormat:@"%d", quotaModel.priceBase.value];
            self.viewModel.type1 = [NSString stringWithFormat:@"%d", quotaModel.type1.value];
//            [self updateHeaderViewStock];
            
            self.headerView.stockInfoView.model = quotaModel;
            
            if (scheme == SchemeHttp && (self.headerView.rangeArr.count < 1 || ![self.viewModel.code isEqualToString:self.headerView.symbol])) {
                [[self.viewModel.rangesCommand execute:self.viewModel.code] subscribeNext:^(id  _Nullable x) {
                    self.headerView.symbol = self.viewModel.code;
                    self.headerView.rangeArr = self.viewModel.range;
                    self.headerView.dateArr = self.viewModel.date;
                    self.headerView.rangeIndex = self.viewModel.rangeIndex;
                    self.headerView.dateIndex = self.viewModel.dateIndex;
                }];
            }
        }
        
    } failed:^{
        @strongify(self)
        self.viewModel.dataSource = @[];
    }];
}

- (void)close {
   [self.quoteSubscribe cancel];
}

- (void)dealloc {
    [self.quoteSubscribe cancel];
}

- (void)hideSortView {
    for (UIView *v in self.backView.subviews) {
        if (v != self.hideBtn) {
            [v removeFromSuperview];
        }
    }
    self.backView.hidden = YES;
    
    self.showRangeSort = NO;
    self.showDateSort = NO;
}

- (void)backViewTapAction {
    [self hideSortView];
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [QMUITheme.backgroundColor colorWithAlphaComponent:0.6];
        _backView.hidden = YES;
    }
    return _backView;
}

- (UIButton *)hideBtn {
    if (!_hideBtn) {
        _hideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _hideBtn.backgroundColor = [UIColor clearColor];
        [_hideBtn setTitle:@"" forState:UIControlStateNormal];
        [_hideBtn addTarget:self action:@selector(backViewTapAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hideBtn;
}

- (YXStreetScaleView *)scaleView {
    if (_scaleView == nil) {
        _scaleView = [[YXStreetScaleView alloc] initWithFrame: CGRectMake(0, 0, YXConstant.screenWidth, 96)];
    }
    return _scaleView;
}

- (YXBottomSheetViewTool *)bottomSheet {
    if (!_bottomSheet) {
        _bottomSheet = [[YXBottomSheetViewTool alloc] init];
    }
    return _bottomSheet;
}

#pragma mark- empty
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.viewModel.dataSource == nil) {
        UIColor *textColor = QMUITheme.textColorLevel3;
        NSString *failText = [NSString stringWithFormat:@"%@,%@", [YXLanguageUtility kLangWithKey:@"common_loadFailed"], [YXLanguageUtility kLangWithKey:@"common_click_refresh"]];
        return [[NSAttributedString alloc] initWithString:failText attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: textColor}];
    }
    return [self customTitleForEmptyDataSet];
}

- (NSAttributedString *)customTitleForEmptyDataSet {
    NSString *text = [YXLanguageUtility kLangWithKey:@"common_string_of_emptyPicture"];
    if (self.viewModel.code.length < 1) {
        text = [YXLanguageUtility kLangWithKey:@"cbbc_tip_text"];
    }
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16],
                                 NSForegroundColorAttributeName: QMUITheme.textColorLevel3};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


- (UIImage *)customImageForEmptyDataSet {
    if (self.viewModel.code.length < 1) {
        return [UIImage imageNamed:@"icon_search_empty"];
    }
    return [UIImage imageNamed:@"empty_noData"];
}

//- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
//    
//    if(YXConstant.deviceScaleEqualToXStyle) {
//        return -YXConstant.screenHeight*0.15 + 100 ;
//    }else {
//        return -YXConstant.screenHeight*0.15 + 100 + YXConstant.navBarHeight;
//    }
//}

- (CGFloat)tableViewTop {
//    return 0;
    return [YXConstant navBarHeight];
}

- (NSArray<Class> *)cellClasses {
    return @[[YXStreetCell class], [YXStreetCell class]];
}

- (void)configureCell:(YXStreetCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    cell.priceBase = self.viewModel.priceBase.intValue;
    cell.maxOutstanding = self.viewModel.maxOutstanding;
    [super configureCell:cell atIndexPath:indexPath withObject:object];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 30)];
    QMUILabel *label = [[QMUILabel alloc] init];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.3;
    
    [view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(16);
        make.right.equalTo(view).offset(-16);
        make.top.bottom.equalTo(view);
    }];
    
    
    if (section == 0) {
        label.textColor = QMUITheme.textColorLevel3;
        label.font = [UIFont systemFontOfSize:12];
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentLeft;
        view.backgroundColor = [UIColor clearColor];
        if (self.viewModel.type1.intValue == OBJECT_SECUSecuType1_StIndex) {
            label.text = [NSString stringWithFormat:@"*%@", [YXLanguageUtility kLangWithKey:@"barchart_futuresindex_explain_text"]];
        } else {
            label.text = [NSString stringWithFormat:@"*%@", [YXLanguageUtility kLangWithKey:@"barchart_stock_explain_text"]];
        }
    } else {
        
        [label mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(16);
            make.top.bottom.equalTo(view);
        }];
        
        label.textColor = QMUITheme.textColorLevel1;
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentLeft;
        view.backgroundColor = QMUITheme.blockColor;
        
        UILabel *ratioLabel = [[UILabel alloc] init];
        ratioLabel.font = [UIFont systemFontOfSize:12];
        ratioLabel.textColor = QMUITheme.textColorLevel1;
        ratioLabel.textAlignment = NSTextAlignmentRight;
        ratioLabel.adjustsFontSizeToFitWidth = YES;
        ratioLabel.minimumScaleFactor = 0.3;
        
        [view addSubview:ratioLabel];
        [ratioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(label.mas_right).offset(8);
            make.right.equalTo(view).offset(-16);
            make.centerY.equalTo(view);
        }];
        
        NSString *theDayPriceText = [YXLanguageUtility kLangWithKey:@"colse_price"];
        NSString *ratioText = [YXLanguageUtility kLangWithKey:@"bull_bear_hedge_ratio"];
        if (self.scaleView.bearPercent != 0) {
            double scale = self.scaleView.bullPercent/self.scaleView.bearPercent;
            NSString *priceBaseFormat = [NSString stringWithFormat:@"   %@:  %%.%df", theDayPriceText,self.viewModel.priceBase.intValue];
            
            label.text = [NSString stringWithFormat:priceBaseFormat, self.viewModel.responseModel.close/pow(10.0, self.viewModel.priceBase.intValue)];
            ratioLabel.text = [NSString stringWithFormat:@"%@:  %.1f:1.0", ratioText, scale];
        } else {
            NSString *priceBaseFormat = [NSString stringWithFormat:@"   %@:  %%.%df", theDayPriceText, self.viewModel.priceBase.intValue];
            label.text = [NSString stringWithFormat:priceBaseFormat, self.viewModel.responseModel.close/pow(10.0, self.viewModel.priceBase.intValue)];
            ratioLabel.text = [NSString stringWithFormat:@"%@:  --", ratioText];
        }
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 50;
    }
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

- (CGFloat)rowHeight {
    return 28;
}

@end
