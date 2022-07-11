//
//  YXStockPickerResultViewController.m
//  uSmartOversea
//
//  Created by youxin on 2020/9/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockPickerResultViewController.h"
#import "YXPickerResultHeaderView.h"
#import "YXStockPickerResultCell.h"
#import "uSmartOversea-Swift.h"
#import "YXStockPickerResultViewModel.h"
#import <MJRefresh/MJRefresh.h>
#import "UILabel+create.h"
#import "YXStockPickerAddSelfBottomView.h"
#import "YXStockPickerSaveBottomView.h"
#import "YXGroupSettingView.h"
#import "YXOptionalSecu.h"
#import <YYCategories/YYCGUtilities.h>
#import <Masonry/Masonry.h>
#import <IQKeyboardManagerSwift-Swift.h>

@interface YXStockPickerResultViewController ()

@property (nonatomic, strong, readonly) YXStockPickerResultViewModel *viewModel;

@property (nonatomic, strong, readwrite) YXPickerResultHeaderView *stockListHeaderView;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, assign) YXTimerFlag timeFlag;

@property (nonatomic, strong) YXStockPickerAddSelfBottomView *addSelfBottomView;
@property (nonatomic, strong) YXStockPickerSaveBottomView *saveBottomView;

@end

@implementation YXStockPickerResultViewController
@dynamic viewModel;

- (void)viewDidLoad {
    // Do any additional setup after loading the view.

    [super viewDidLoad];

    self.title = [YXLanguageUtility kLangWithKey:@"view_results"];

    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(35);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view).offset(YXConstant.navBarHeight);
        }
    }];
    [self setTotalResultText:0];

    [self.view addSubview:self.saveBottomView];
    [self.saveBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(YXConstant.tabBarHeight);
    }];

    [self.view addSubview:self.addSelfBottomView];
    [self.addSelfBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(YXConstant.tabBarHeight);
    }];

    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.topView.mas_bottom);
        make.bottom.equalTo(self.saveBottomView.mas_top);
    }];

    [self.stockListHeaderView setDefaultSortState:self.viewModel.sortState filterType:self.viewModel.filterType];

    if (self.viewModel.updateType == YXStockFilterOperationTypeQuery) {
        [self.saveBottomView hiddenSaveButton];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)bindViewModel {
    [super bindViewModel];

    @weakify(self)
    if ([self.stockListHeaderView isKindOfClass:[YXPickerResultHeaderView class]]) {
        [[[RACObserve(self.viewModel, sortState) skip:1] combineLatestWith:RACObserve(self.viewModel, filterType)] subscribeNext:^(RACTuple * _Nullable tuple) {
            @strongify(self)
            [self.stockListHeaderView setSortState:[tuple.first integerValue] filterType:[tuple.second integerValue]];
        }];
        RACChannelTo(self.viewModel, contentOffset) = RACChannelTo(self.stockListHeaderView.scrollView, contentOffset);
    }

    [RACObserve(self.viewModel, filterType) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.tableView setContentOffset:CGPointZero];
    }];

    [self.viewModel.requestSubject subscribeNext:^(NSNumber*  _Nullable x) {
        @strongify(self)
        [self setTotalResultText:x.integerValue];
    }];

    [self.viewModel.endRefreshSubject subscribeNext:^(NSNumber*  _Nullable x) {
        @strongify(self)
        if (self.tableView.mj_footer) {
            [self.tableView.mj_footer endRefreshing];
        }

    }];

    [self.viewModel.bmpSubject subscribeNext:^(NSNumber*  _Nullable x) {
        @strongify(self)
        if (self.tableView.mj_footer != nil) {

            self.tableView.mj_footer = nil;
        }

        if (self.footerView == nil) {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 48)];
            footerView.backgroundColor = QMUITheme.foregroundColor;

            YXExpandAreaButton *moreButton = [[YXExpandAreaButton alloc] init];
            [moreButton setTitle:[YXLanguageUtility kLangWithKey:@"newStock_detail_see_more"] forState:(UIControlStateNormal)];
            [moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
            [moreButton setDisabledTheme:15];
            [footerView addSubview:moreButton];

            [moreButton addTarget:self action:@selector(showDelayOrBmpAlert) forControlEvents:(UIControlEventTouchUpInside)];

            [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(footerView);
                make.height.mas_equalTo(30);
                make.width.mas_equalTo(150);
            }];

            self.footerView = footerView;
            self.tableView.tableFooterView = footerView;
        }

    }];

    RAC(self.addSelfBottomView, checkedCount) = [RACObserve(self.viewModel, checkedSecus) map:^id _Nullable(id  _Nullable value) {
        NSArray *array = (NSArray *)value;
        return @([array count]);
    }];

    RAC(self.addSelfBottomView.selectAllButton, selected) = [RACObserve(self.viewModel, checkedSecus) map:^id _Nullable(id  _Nullable value) {
        @strongify(self);
        NSArray *array = (NSArray *)value;
        if (self.viewModel.dataSource.firstObject.count > 0) {
            return @([array count] == self.viewModel.dataSource.firstObject.count);
        } else {
            return @(NO);
        }
    }];

    RAC(self.saveBottomView.selectButton, enabled) = [RACObserve(self.viewModel, dataSource) map:^id _Nullable(NSArray *value) {
        NSArray *firstArray = value.firstObject;
        if (firstArray.count > 0 && value.count > 0) {
            return @(YES);
        } else {
            return @(NO);
        }
    }];

}

- (void)showDelayOrBmpAlert {

    YXAlertView *alertView = [YXAlertView alertViewWithTitle: [YXLanguageUtility kLangWithKey:@"common_tips"] message:[YXLanguageUtility kLangWithKey:@"filter_bmp_prompt"]];
    alertView.messageLabel.font = [UIFont systemFontOfSize:16];
    alertView.messageLabel.textAlignment = NSTextAlignmentLeft;
    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleCancel handler:^(YXAlertAction * _Nonnull action) {

    }]];
    @weakify(self)
    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"upgrade_immediately"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {
        @strongify(self)
        [YXWebViewModel pushToWebVC:[YXH5Urls myQuotesUrl]];

    }]];

    [alertView showInWindow];
}

- (void)saveStockPicker {
    @weakify(self)
    [[[self.viewModel.saveResultCommand execute:nil] deliverOnMainThread]
     subscribeNext:^(NSNumber *number) {
        @strongify(self);
        if (number.integerValue == -1) {
            self.saveBottomView.saveButton.enabled = YES;
            [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"user_saveFailed"]];
        } else {
            [YXProgressHUD showMessage:[YXLanguageUtility kLangWithKey:@"user_saveSucceed"]];
        }

    } error:^(NSError *error) {
    } completed:^{
    }];
}

- (void)startPolling {

    if (self.timeFlag > 0) {
        [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.timeFlag];
        self.timeFlag = 0;
    }
    @weakify(self)
    self.timeFlag = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
        @strongify(self)
        HLNetWorkStatus netWorkStatus = [YXNetworkUtil.sharedInstance.reachability currentReachabilityStatus];
        if (netWorkStatus == HLNetWorkStatusNotReachable) {
            return;
        }
        NSArray *cells = [self.tableView visibleCells];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cells.firstObject];

        [self.viewModel.requestOffsetDataCommand execute:@(indexPath.row)];
    } timeInterval:[YXGlobalConfigManager configFrequency:YXGlobalConfigParameterTypeRankFreq] repeatTimes:1 atOnce:NO]; //NSIntegerMax
}

- (void)stopPolling {
    if (self.timeFlag > 0) {
        [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.timeFlag];
        self.timeFlag = 0;
    }
}


- (void)setTotalResultText:(NSInteger)count {
    NSString *str = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"total_stocks"], count];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName : [QMUITheme.textColorLevel1 colorWithAlphaComponent:0.65], NSFontAttributeName : [UIFont systemFontOfSize:12]}];
    [attributeString addAttributes:@{NSForegroundColorAttributeName : QMUITheme.themeTextColor, NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]} range:[str rangeOfString:@(count).stringValue]];
    self.topLabel.attributedText = attributeString;
}

- (void)configureCell:(YXStockPickerResultCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {

    cell.sortTypes = self.sortTypes;
    RACChannelTerminal *channel = RACChannelTo(self.viewModel, contentOffset);
    RACChannelTerminal *cellChannel = RACChannelTo(cell.scrollView, contentOffset);

    [[channel takeUntil:cell.rac_prepareForReuseSignal] subscribe:cellChannel];
    [[cellChannel takeUntil:cell.rac_prepareForReuseSignal] subscribe:channel];

    cell.isEditing = self.viewModel.isEditing;
    cell.checked = [self.viewModel isChecked:object];
    @weakify(self, object)
    [[[RACObserve(cell, checked) skip:1] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self, object)
        BOOL checked = [x boolValue];
        if (checked) {
            [self.viewModel check:object];
        } else {
            [self.viewModel unCheck:object];
        }

    }];

    [super configureCell:cell atIndexPath:indexPath withObject:object];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.viewModel.isEditing) {
        id cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[YXStockPickerResultCell class]]) {
            ((YXStockPickerResultCell *)cell).checked = !((YXStockPickerResultCell *)cell).checked;
        }
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }

}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.viewModel.isLandscape) {
        return self.stockListHeaderView;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    view.backgroundColor = self.stockListHeaderView.backgroundColor;
    [view addSubview:self.stockListHeaderView];

    if (self.viewModel.isEditing) {
        UIView *editView = [UIView new];
        [view addSubview:editView];

        [editView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(view);
            make.width.mas_equalTo(15);
        }];

        [self.stockListHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(view);
            make.left.equalTo(editView.mas_right);
        }];
    } else {
        [self.stockListHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.right.equalTo(view);
        }];
    }

    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [QMUITheme.textColorLevel1 colorWithAlphaComponent:0.05];
    [view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(view);
        make.height.mas_equalTo(1);
    }];

    return view;
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSArray *cells = [self.tableView visibleCells];
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cells.firstObject];
//
//    [self.viewModel.requestOffsetDataCommand execute:@(indexPath.row)];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    if (!decelerate) {
//        NSArray *cells = [self.tableView visibleCells];
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:cells.firstObject];
//
//        [self.viewModel.requestOffsetDataCommand execute:@(indexPath.row)];
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)rowHeight {
    return 60;
}

- (NSArray<Class> *)cellClasses {
    return @[[YXStockPickerResultCell class]];
}

- (NSArray *)sortTypes {
    if (self.viewModel.sortTypes.count > 0) {
        return self.viewModel.sortTypes;
    }
    return @[@(YXStockFilterItemTypePrice), @(YXStockFilterItemTypePctchng), @(YXStockFilterItemTypeNetchng)];
}

- (YXPickerResultHeaderView *)stockListHeaderView {
    if (_stockListHeaderView == nil) {
        _stockListHeaderView = [[YXPickerResultHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40) sortTypes:self.sortTypes];
        _stockListHeaderView.namesDictionary = self.viewModel.namesDictionary;
        @weakify(self)
        [_stockListHeaderView setOnClickSort:^(YXSortState state, NSInteger type) {
            @strongify(self)
            [self.viewModel.didClickSortCommand execute:@[@(state), @(type)]];
        }];
    }
    return _stockListHeaderView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.frame = CGRectMake(0, YXConstant.navBarHeight, YXConstant.screenWidth, 35);
        _topView.backgroundColor = [QMUITheme foregroundColor];

        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = [QMUITheme.textColorLevel1 colorWithAlphaComponent:0.05];
        [_topView addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(_topView);
        }];

        [_topView addSubview:self.topLabel];
        [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_topView).offset(12);
            make.right.equalTo(_topView).offset(-12);
            make.centerY.equalTo(_topView);
        }];

    }
    return _topView;
}

- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [UILabel labelWithText:@"" textColor:[QMUITheme.textColorLevel1 colorWithAlphaComponent:0.65] textFont:[UIFont systemFontOfSize:12]];
        _topLabel.textAlignment = NSTextAlignmentLeft;
        _topLabel.adjustsFontSizeToFitWidth = YES;
        _topLabel.minimumScaleFactor = 0.3;
    }
    return _topLabel;
}

- (YXStockPickerAddSelfBottomView *)addSelfBottomView {
    if (!_addSelfBottomView) {
        _addSelfBottomView = [[YXStockPickerAddSelfBottomView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 49)];
        _addSelfBottomView.hidden = YES;
        @weakify(self)
        [_addSelfBottomView setOnClickChange:^{
            @strongify(self)
            if ([YXUserManager isLogin]) {
                NSMutableArray *secus = [NSMutableArray array];
                for (YXStockPickerList *info in self.viewModel.checkedSecus) {
                    YXOptionalSecu *secu = [[YXOptionalSecu alloc] init];
                    secu.symbol  = info.code;
                    secu.name = info.name;
                    secu.market = info.market;
                    [secus addObject:secu];
                }
                YXGroupSettingView *view = [[YXGroupSettingView alloc] initWithSecus:secus secuName:@"" currentOperationGroup:self.viewModel.secuGroup settingType:YXGroupSettingTypeAdd];
                @weakify(self)
                [view setAddResultCallback:^(BOOL result) {
                    @strongify(self)
                    if (result) {
                        [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"user_saveSucceed"]];
                        [self rightBarItemAction];
                    } else {
                        [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"stock_over_max"]];
                    }
                }];
                YXAlertController *alertController = [YXAlertController alertControllerWithAlertView:view preferredStyle:TYAlertControllerStyleActionSheet];
                alertController.backgoundTapDismissEnable = YES;
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                [(NavigatorServices *)self.viewModel.services pushToLoginVCWithCallBack:nil];
            }
        }];


        [_addSelfBottomView setOnClickSelectedAll:^(BOOL isSelected){
            @strongify(self);
            if (isSelected) {
                [self.viewModel AllCheck];
            }else {
                [self.viewModel removeAllChecked];
            }

            [self reloadData];
        }];
    }
    return _addSelfBottomView;
}

- (YXStockPickerSaveBottomView *)saveBottomView {
    if (!_saveBottomView) {
        _saveBottomView = [[YXStockPickerSaveBottomView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 49)];
        @weakify(self)
        [_saveBottomView setOnClickSave:^{
            @strongify(self)
            if ([YXUserManager isLogin]) {
                self.saveBottomView.saveButton.enabled = NO;
                if (self.viewModel.updateType == YXStockFilterOperationTypeNew) {
                    [self createStockPickerName];
                } else {
                    [self saveStockPicker];
                }
                
            } else {
                [(NavigatorServices *)self.viewModel.services pushToLoginVCWithCallBack:nil];
            }
        }];

        [_saveBottomView setOnClickSelected:^{
            @strongify(self)

            self.addSelfBottomView.hidden = NO;
            self.viewModel.isEditing = YES;
            [self addCancelRightBarButtonItem];
            self.tableView.bounces = NO;
            [self reloadData];
        }];
    }
    return _saveBottomView;
}

- (void)addCancelRightBarButtonItem {

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:(UIBarButtonItemStylePlain) target:self action:@selector(rightBarItemAction)];

    self.navigationItem.rightBarButtonItems = @[rightItem];
}

- (void)rightBarItemAction {
    [self.viewModel removeAllChecked];
    self.addSelfBottomView.hidden = YES;
    self.tableView.bounces = YES;
    self.viewModel.isEditing = NO;
    [self removeCancelRightBarButtonItem];
    [self reloadData];
}

- (void)removeCancelRightBarButtonItem {

    self.navigationItem.rightBarButtonItems = nil;
}

- (void)createStockPickerName {
    YXAlertView *alertView = [YXAlertView alertViewWithTitle:[YXLanguageUtility kLangWithKey:@"stock_scanner"] message:nil];
    alertView.messageLabel.font = [UIFont systemFontOfSize:16];
    alertView.messageLabel.textAlignment = NSTextAlignmentLeft;
    alertView.clickedAutoHide = NO;
    @weakify(alertView, self)
    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleCancel handler:^(YXAlertAction *action) {
        @strongify(alertView, self)
        self.saveBottomView.saveButton.enabled = YES;
        [alertView hideView];
    }]];

    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_confirm"] style:YXAlertActionStyleDefault handler:^(YXAlertAction *action) {
        @strongify(alertView, self)
        NSString *name = alertView.textField.text;
        if (name.length < 1 || [name stringByReplacingOccurrencesOfString:@" " withString:@""].length < 1) {
            [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"filter_name_emtpy_prompt"]];
        } else {
            self.viewModel.groupName = name;
            [self saveStockPicker];
            [alertView hideView];
        }
    }]];

    [alertView addTextFieldWithMaxNum:12 handler:^(UITextField * _Nonnull textField) {
        textField.placeholder = [YXLanguageUtility kLangWithKey:@"enter_name"];
        textField.keyboardDistanceFromTextField = 212;
        if ([UIScreen mainScreen].bounds.size.width < 375) {
            textField.keyboardDistanceFromTextField = CGFloatPixelRound([UIScreen mainScreen].bounds.size.height/667 * 212);
        }

    }];

    UILabel *propmtLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"enter_name_alert"] textColor:[QMUITheme.textColorLevel1 colorWithAlphaComponent:0.65] textFont:[UIFont systemFontOfSize:10]];
    if ([YXUserManager isENMode]) {
        propmtLabel.numberOfLines = 3;
    }
    propmtLabel.adjustsFontSizeToFitWidth = YES;
    propmtLabel.minimumScaleFactor = 0.3;
    [alertView addSubview:propmtLabel];
    [propmtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(alertView.textField).offset(-6);
        make.right.equalTo(alertView.textField).offset(-27);
        make.top.equalTo(alertView.textField.mas_bottom).offset(5);
    }];

    YXAlertController *alertController = [YXAlertController alertControllerWithAlertView:alertView];
    [UIViewController.currentViewController presentViewController:alertController animated:YES completion:nil];
}

//横屏默认隐藏
- (BOOL)prefersStatusBarHidden {
    if (self.viewModel.isLandscape) {
        return YES;
    } else {
        return NO;
    }
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.viewModel.dataSource == nil) {
        return [super titleForEmptyDataSet:scrollView];
    } else if (self.viewModel.dataSource.firstObject.count == 0) {
        UIColor *textColor = [QMUITheme textColorLevel3];
        if (self.whiteStyle) {
            textColor = QMUITheme.textColorLevel2;
        }
        return [[NSAttributedString alloc] initWithString:[YXLanguageUtility kLangWithKey:@"no_results"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: textColor}];
    }
    return [self customTitleForEmptyDataSet];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {

    if (self.viewModel.dataSource == nil) {
        return [super imageForEmptyDataSet:scrollView];
    } else if (self.viewModel.dataSource.firstObject.count == 0) {
        return [UIImage imageNamed:@"empty_no_stock"];
    }
    return [self customImageForEmptyDataSet];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    if (self.viewModel.dataSource == nil) {
        return [super buttonTitleForEmptyDataSet:scrollView forState:state];
    }
    return nil;
}

@end
