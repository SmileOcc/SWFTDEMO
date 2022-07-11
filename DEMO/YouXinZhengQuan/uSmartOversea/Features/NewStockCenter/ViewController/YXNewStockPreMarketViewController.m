//
//  YXNewStockPreMarketViewController.m
//  uSmartOversea
//
//  Created by Kelvin on 2019/2/18.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

#import "YXNewStockPreMarketViewController.h"
#import "uSmartOversea-Swift.h"
#import "YXTabPageView.h"
#import "YXNewStockPreMarketViewModel.h"
#import <Masonry/Masonry.h>

@interface YXNewStockPreMarketViewController () <YXTabPageScrollViewProtocol>

@property (nonatomic, copy) YXTabPageScrollBlock scrollCallBack;

@property (nonatomic, strong, readwrite) YXNewStockPreMarketViewModel *viewModel;

//@property (nonatomic, strong) YXNewStockPurchaseSortView *purchaseSectionSortView;
@property (nonatomic, strong) YXNewStockPreMarketSortView *preMarketSectionView;

@end

@implementation YXNewStockPreMarketViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = QMUITheme.foregroundColor;
    self.tableView.backgroundColor = QMUITheme.foregroundColor;
    
    //closures
    [self initClosures];
    
    [self.view addSubview:self.strongNoticeView];
    
    @weakify(self)
    self.strongNoticeView.selectedBlock = ^{
        @strongify(self)
        
        [self.goProCommand execute:nil];
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadFirstPage];
}

- (void)bindViewModel {
    [super bindViewModel];
    
}

- (void)initClosures {
    
    @weakify(self)
    //认购中
//    [self.purchaseSectionSortView setSortClosure:^(YXSortState sortType, YXMobileBrief1Type briefType) {
//        @strongify(self)
//
//        [self sortTypeChangedWithSortType:sortType Brief1Type:briefType];
//
//    }];
    
//    待上市
//    [self.preMarketSectionView setSortClosure:^(int sortType, YXMobileBrief1Type briefType) {
//        @strongify(self)
//
//        [self sortTypeChangedWithSortType:sortType Brief1Type:briefType];
//
//    }];
    
//    [self.preMarketSectionView setSortClosure:^(NSInteger sortType, YXMobileBrief1Type briefType) {
//        @strongify(self)
//        if (sortType == 1) {
//            [self sortTypeChangedWithSortType:YXSortStateDescending Brief1Type:briefType];
//        }else if (sortType == 2 ) {
//            [self sortTypeChangedWithSortType:YXSortStateAscending Brief1Type:briefType];
//        }
//        
//    }];
    
    [self.preMarketSectionView setSortClosure:^(NSInteger sortType, YXMobileBrief1Type briefType) {
        @strongify(self)
        if (sortType == 1) {
            [self sortTypeChangedWithSortType:YXSortStateDescending Brief1Type:briefType];
        }else {
            [self sortTypeChangedWithSortType:YXSortStateAscending Brief1Type:briefType];
        }
    }];
    
}

- (void)sortTypeChangedWithSortType: (YXSortState)sortType Brief1Type: (YXMobileBrief1Type)briefType {
    self.viewModel.page = 1;
    switch (sortType) {
        case YXSortStateDescending:
            self.viewModel.orderDirection = 0;
            break;
        case YXSortStateAscending:
            self.viewModel.orderDirection = 1;
            break;
            
        default:
            break;
    }
    switch (briefType) {
        case YXMobileBrief1TypePurchaseMoney:
            self.viewModel.orderBy = @"least_amount";
            break;
        case YXMobileBrief1TypePurchaseEndDay:
            self.viewModel.orderBy = @"latest_endtime";
            break;
        case YXMobileBrief1TypeMarketDate:
            self.viewModel.orderBy = @"listing_time";
            break;
        default:
            break;
    }
    self.viewModel.loadNoMore = NO;
}

#pragma mark - tabelview delegate

- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)aIndexPath {

    if (self.viewModel.stockStatus == YXNewStockStatusPurchase) {
        return @"subscribeCellIdentity";
    } else {
        return @"preMarketCellIdentity";
    }
}

- (void)configureCell:(YXNewStockSubscribeCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    cell.stockStatus = self.viewModel.stockStatus;
    [super configureCell:cell atIndexPath:indexPath withObject:object];
}

- (NSDictionary *)cellIdentifiers {
    return @{
             @"preMarketCellIdentity" : NSStringFromClass(YXNewStockPreMarketCell.class),
             @"subscribeCellIdentity" : NSStringFromClass(YXNewStockSubscribeCell.class)
             };
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (self.viewModel.stockStatus == YXNewStockStatusPurchase) {
        UIView *line = [UIView lineView];
        line.backgroundColor = [QMUITheme separatorLineColor];
        return line;
    } else {
        return self.preMarketSectionView;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.viewModel.stockStatus == YXNewStockStatusPurchase) {
        return 1;
    } else {
        return 40.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    YXNewStockCenterPreMarketStockModel2 *model = self.viewModel.dataSource[indexPath.section][indexPath.row];
    
    if (self.viewModel.stockStatus == YXNewStockStatusPurchase) {
        if (model.exchangeType == 5) {
            if ([@[@"0", @"1", @"2"] containsObject:model.labelStatus] || [model isCanECM] || model.ecmStatus == 15 || model.ecmLabelV2.length > 0) {
                return 178.0f;
            }else {
                return 158.0f;
            }
        }else {
            if ([model isCanECM] && [model isCanPublic]) {
                return 210.0f;
            }else if ([@[@"0", @"1", @"2"] containsObject:model.labelStatus] || [model isCanECM] || [model isCanIPO] || model.ecmLabelV2.length > 0) {
                return 178.0f;
            }
            else {
                return 158.0f;
            }
        }
    } else {
        if (model.labelStatus.length > 0 && model.labelStatus.doubleValue < 3) {
            return 79.0f;
        }
        return 60.0f;
    }
}

#pragma mark - no data

- (NSAttributedString *)customTitleForEmptyDataSet {

    NSString *text;
    if (self.viewModel.stockStatus == YXNewStockStatusPurchase) {
        text = [YXLanguageUtility kLangWithKey:@"newStock_center_noSubStock"];
    } else {
        text = [YXLanguageUtility kLangWithKey:@"newStock_center_noWaitingListStock"];
    }
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16],
                                 NSForegroundColorAttributeName: [QMUITheme textColorLevel3]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)customImageForEmptyDataSet {
    return [UIImage imageNamed:@"empty_hold"];
}

//- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
//    return -(YXConstant.screenHeight-40-YXConstant.navBarHeight)*0.5 + 114;
//}

#pragma mark -
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

- (double)tableViewTop {
    return 0;
}

- (UITableViewStyle)tableViewStyle {
    
    return UITableViewStylePlain;
    
}

#pragma mark - lazy load
//- (YXNewStockPurchaseSortView *)purchaseSectionSortView {
//
//    if (!_purchaseSectionSortView) {
//        _purchaseSectionSortView = [[YXNewStockPurchaseSortView alloc] init];
//    }
//    return _purchaseSectionSortView;
//
//}

- (YXNewStockPreMarketSortView *)preMarketSectionView {
    
    if (!_preMarketSectionView) {
        _preMarketSectionView = [[YXNewStockPreMarketSortView alloc] init];
    }
    return _preMarketSectionView;
    
}

//- (void)showProWithTip:(NSString *)tip {
//
//   if (self.financingAccountDiff && [tip isNotEmpty] && (![YXUserManager isLogin] || [YXUserManager shareInstance].curLoginUser.userRoleType==1)) {
//        YXNoticeModel *noticeModel = [[YXNoticeModel alloc] init];
//        noticeModel.content = tip;
//        self.strongNoticeView.dataSource = @[noticeModel];
//        self.strongNoticeView.noticeType = YXStrongNoticeTypeGoPro;
//    } else {
//        self.strongNoticeView.dataSource = @[];
//    }
//}

@end
