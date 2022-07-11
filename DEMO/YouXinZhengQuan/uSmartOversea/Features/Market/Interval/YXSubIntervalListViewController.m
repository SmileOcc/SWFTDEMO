//
//  YXSubIntervalListViewController.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/28.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXSubIntervalListViewController.h"
#import "YXSubIntervalListViewModel.h"
#import "YXIntervalTypeView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXSubIntervalListViewController ()

@property (nonatomic, strong) YXSubIntervalListViewModel *viewModel;

@property (nonatomic, assign) YXTimerFlag timeFlag;

@property (nonatomic, strong) YXIntervalTypeView *typeView;

@end

@implementation YXSubIntervalListViewController
@synthesize viewModel;

- (CGFloat)tableViewTop {
    
    if (self.viewModel.isLandscape) {
        return 0;
    } else {
        return 96;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.typeView];
    [self.typeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(96);
    }];
    
    if (self.viewModel.isLandscape) {
        self.typeView.hidden = YES;
    } else {
        self.typeView.hidden = NO;
    }
    
    self.typeView.defalutSelect = self.viewModel.selectType;
}

- (void)bindViewModel {
    [super bindViewModel];
    
    @weakify(self)
    [RACObserve(self.viewModel, sortType) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.tableView setContentOffset:CGPointZero];
    }];
    
    [self.typeView setClickCallBack:^(UIButton * _Nonnull sender) {
        @strongify(self);
        self.viewModel.sortState = YXSortStateDescending;
        NSString *title = @"";
        switch (sender.tag) {
            case 0:
            {
                title = @"5分钟";
                self.viewModel.sortType = YXMarketSortTypeAccer5;
            }
                break;
            case 1:
            {
                title = @"5日";
                self.viewModel.sortType = YXMarketSortTypePctChg5day;
            }
                break;
            case 2:
            {
                title = @"10日";
                self.viewModel.sortType = YXMarketSortTypePctChg10day;
            }
                break;
            case 3:
            {
                title = @"30日";
                self.viewModel.sortType = YXMarketSortTypePctChg30day;
            }
                break;
            case 4:
            {
                title = @"60日";
                self.viewModel.sortType = YXMarketSortTypePctChg60day;
            }
                break;
            case 5:
            {
                title = @"120日";
                self.viewModel.sortType = YXMarketSortTypePctChg120day;
            }
                break;
            case 6:
            {
                title = @"250日";
                self.viewModel.sortType = YXMarketSortTypePctChg250day;
            }
                break;
            case 7:
            {
                title = @"52周";
                self.viewModel.sortType = YXMarketSortTypePctChg1year;
            }
                break;
                
            default:
                break;
        }

        self.viewModel.selectType = sender.tag;
        
        [self.stockListHeaderView resetButtonsWithArr:self.sortTypes];
        NSNumber *type = self.sortTypes.firstObject;
        [self.stockListHeaderView setDefaultSortState:self.viewModel.direction mobileBrief1Type: type.intValue];
        [self.stockListHeaderView scrollToVisibleMobileBrief1Type:type.intValue animated:YES];
        [self.tableView reloadData];
        
    }];


    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:YXUserManager.notiQuoteKick object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        if (self.qmui_isViewLoadedAndVisible) {
            [self refreshVisibleCellsData];
        }
    }];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startPolling];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self updateAuthorityUI];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopPolling];
}


- (void)startPolling {
//    NSString *code = self.viewModel.params[@"code"];

//    BOOL needPolling = [code containsString:@"INDUSTRY"] || [code containsString:@"BK"];
//    if ([self.authorityTool isHKBMP] && [self.viewModel.params[@"market"] isEqualToString:kYXMarketHK] && !needPolling) {
//        return;
//    }
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
        [self refreshVisibleCellsData];
    } timeInterval:[YXGlobalConfigManager configFrequency:YXGlobalConfigParameterTypeRankFreq] repeatTimes:NSIntegerMax atOnce:YES];
}

- (void)stopPolling {
    if (self.timeFlag > 0) {
        [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.timeFlag];
        self.timeFlag = 0;
    }
}


- (NSArray *)sortTypes {
    
    switch (self.viewModel.selectType) {
        case 0:
        {
            return @[@(YXMobileBrief1TypeAccer5), @(YXMobileBrief1TypeNow), @(YXMobileBrief1TypeRoc), @(YXMobileBrief1TypeChange), @(YXMobileBrief1TypePe), @(YXMobileBrief1TypeMarketValue), @(YXMobileBrief1TypePctChg5day), @(YXMobileBrief1TypePctChg10day), @(YXMobileBrief1TypePctChg30day), @(YXMobileBrief1TypePctChg60day), @(YXMobileBrief1TypePctChg120day), @(YXMobileBrief1TypePctChg250day), @(YXMobileBrief1TypePctChg1year)];
        }
            break;
        case 1:
        {
            return @[@(YXMobileBrief1TypePctChg5day), @(YXMobileBrief1TypeNow), @(YXMobileBrief1TypeRoc), @(YXMobileBrief1TypeChange), @(YXMobileBrief1TypePe), @(YXMobileBrief1TypeMarketValue), @(YXMobileBrief1TypeAccer5), @(YXMobileBrief1TypePctChg10day), @(YXMobileBrief1TypePctChg30day), @(YXMobileBrief1TypePctChg60day), @(YXMobileBrief1TypePctChg120day), @(YXMobileBrief1TypePctChg250day), @(YXMobileBrief1TypePctChg1year)];
        }
            break;
        case 2:
        {
            return @[@(YXMobileBrief1TypePctChg10day), @(YXMobileBrief1TypeNow), @(YXMobileBrief1TypeRoc), @(YXMobileBrief1TypeChange), @(YXMobileBrief1TypePe), @(YXMobileBrief1TypeMarketValue), @(YXMobileBrief1TypeAccer5), @(YXMobileBrief1TypePctChg5day), @(YXMobileBrief1TypePctChg30day), @(YXMobileBrief1TypePctChg60day), @(YXMobileBrief1TypePctChg120day), @(YXMobileBrief1TypePctChg250day), @(YXMobileBrief1TypePctChg1year)];
        }
            break;
        case 3:
        {
            return @[@(YXMobileBrief1TypePctChg30day), @(YXMobileBrief1TypeNow), @(YXMobileBrief1TypeRoc), @(YXMobileBrief1TypeChange), @(YXMobileBrief1TypePe), @(YXMobileBrief1TypeMarketValue), @(YXMobileBrief1TypeAccer5), @(YXMobileBrief1TypePctChg5day), @(YXMobileBrief1TypePctChg10day), @(YXMobileBrief1TypePctChg60day), @(YXMobileBrief1TypePctChg120day), @(YXMobileBrief1TypePctChg250day), @(YXMobileBrief1TypePctChg1year)];
        }
            break;
        case 4:
        {
            return @[@(YXMobileBrief1TypePctChg60day), @(YXMobileBrief1TypeNow), @(YXMobileBrief1TypeRoc), @(YXMobileBrief1TypeChange), @(YXMobileBrief1TypePe), @(YXMobileBrief1TypeMarketValue), @(YXMobileBrief1TypeAccer5), @(YXMobileBrief1TypePctChg5day), @(YXMobileBrief1TypePctChg10day), @(YXMobileBrief1TypePctChg30day), @(YXMobileBrief1TypePctChg120day), @(YXMobileBrief1TypePctChg250day), @(YXMobileBrief1TypePctChg1year)];
        }
            break;
        case 5:
        {
            return @[@(YXMobileBrief1TypePctChg120day), @(YXMobileBrief1TypeNow), @(YXMobileBrief1TypeRoc), @(YXMobileBrief1TypeChange), @(YXMobileBrief1TypePe), @(YXMobileBrief1TypeMarketValue), @(YXMobileBrief1TypeAccer5), @(YXMobileBrief1TypePctChg5day), @(YXMobileBrief1TypePctChg10day), @(YXMobileBrief1TypePctChg30day), @(YXMobileBrief1TypePctChg60day), @(YXMobileBrief1TypePctChg250day), @(YXMobileBrief1TypePctChg1year)];
        }
            break;
        case 6:
        {
            return @[@(YXMobileBrief1TypePctChg250day), @(YXMobileBrief1TypeNow), @(YXMobileBrief1TypeRoc), @(YXMobileBrief1TypeChange), @(YXMobileBrief1TypePe), @(YXMobileBrief1TypeMarketValue), @(YXMobileBrief1TypeAccer5), @(YXMobileBrief1TypePctChg5day), @(YXMobileBrief1TypePctChg10day), @(YXMobileBrief1TypePctChg30day), @(YXMobileBrief1TypePctChg60day), @(YXMobileBrief1TypePctChg120day), @(YXMobileBrief1TypePctChg1year)];
        }
            break;
        case 7:
        {
            return @[@(YXMobileBrief1TypePctChg1year), @(YXMobileBrief1TypeNow), @(YXMobileBrief1TypeRoc), @(YXMobileBrief1TypeChange), @(YXMobileBrief1TypePe), @(YXMobileBrief1TypeMarketValue), @(YXMobileBrief1TypeAccer5), @(YXMobileBrief1TypePctChg5day), @(YXMobileBrief1TypePctChg10day), @(YXMobileBrief1TypePctChg30day), @(YXMobileBrief1TypePctChg60day), @(YXMobileBrief1TypePctChg120day), @(YXMobileBrief1TypePctChg250day)];
        }
            break;
        default:
            return @[@(YXMobileBrief1TypeAccer5), @(YXMobileBrief1TypeNow), @(YXMobileBrief1TypeRoc), @(YXMobileBrief1TypeChange), @(YXMobileBrief1TypePe), @(YXMobileBrief1TypeMarketValue), @(YXMobileBrief1TypeAccer5), @(YXMobileBrief1TypePctChg5day), @(YXMobileBrief1TypePctChg10day), @(YXMobileBrief1TypePctChg30day), @(YXMobileBrief1TypePctChg60day), @(YXMobileBrief1TypePctChg120day), @(YXMobileBrief1TypePctChg250day), @(YXMobileBrief1TypePctChg1year)];
            break;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self refreshVisibleCellsData];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self refreshVisibleCellsData];
    }
}

- (void)refreshVisibleCellsData {
    NSArray *cells = [self.tableView visibleCells];
    if (cells.count > 0) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cells.firstObject];

        [self.viewModel.requestOffsetDataCommand execute:@(indexPath.row)];
    }
}


- (UIImage *)customImageForEmptyDataSet {
    if (self.viewModel.dataSource && self.viewModel.dataSource.count == 0) {
        return [UIImage imageNamed:@"empty_noData"];
    }
    return [super customImageForEmptyDataSet];
}

- (NSAttributedString *)customTitleForEmptyDataSet {
    if (self.viewModel.dataSource && self.viewModel.dataSource.count == 0) {
        return [[NSAttributedString alloc] initWithString:[YXLanguageUtility kLangWithKey:@"common_string_of_emptyPicture"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [QMUITheme textColorLevel3]}];
    }
    return [super customTitleForEmptyDataSet];
}


- (UITableView *)needLayoutTableView {
    return self.tableView;
}

- (YXIntervalTypeView *)typeView {
    if (_typeView == nil) {
        _typeView = [[YXIntervalTypeView alloc] init];
        _typeView.backgroundColor = QMUITheme.foregroundColor;
    }
    return _typeView;
}

@end
