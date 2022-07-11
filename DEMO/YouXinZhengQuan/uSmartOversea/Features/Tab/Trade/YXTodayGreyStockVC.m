//
//  YXTodayGreyStockVC.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/4/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTodayGreyStockVC.h"
#import "YXTodayGreyStockViewModel.h"
#import "YXTodayGreyStockCell.h"
#import "YXStockDetailUtility.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "NSDictionary+Category.h"


@interface YXTodayGreyStockVC ()

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong, readwrite) YXTodayGreyStockViewModel *viewModel;

@end

@implementation YXTodayGreyStockVC

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    
    [self loadFirstPage];
}

#pragma mark - initUI
- (void)initUI {
    
    self.title = [YXLanguageUtility kLangWithKey:@"today_grey"];
    self.tableView.backgroundColor = QMUITheme.foregroundColor;
    self.view.backgroundColor = QMUITheme.foregroundColor;
    [self.view addSubview:self.tipLabel];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.mas_equalTo(self.view).offset(YXConstant.navBarHeight);
        }
        make.height.mas_equalTo(30);
        make.leading.equalTo(self.view).offset(18);
        make.trailing.equalTo(self.view).offset(-5);
    }];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.tipLabel.mas_bottom);
    }];
    

}

- (void)bindViewModel {
    [super bindViewModel];
    @weakify(self);
    [self.viewModel.loadGreyDataSubject subscribeNext:^(NSDictionary *dic) {
        @strongify(self);
        NSString *startTime = [dic yx_stringValueForKey:@"greyStartTime"];
        NSString *endTime = [dic yx_stringValueForKey:@"greyEndTime"];
        NSString *str = [NSString stringWithFormat:@"%@: %@-%@", [YXLanguageUtility kLangWithKey:@"today_grey_time"],startTime, endTime];
        self.tipLabel.text = str;

    }];
}


#pragma mark - tableView delegate
- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)aIndexPath {
    
        return @"YXTodayGreyStockCell";
    
}

- (void)configureCell:(YXTodayGreyStockCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object{
    @weakify(self);
    [cell setOrderCallBack:^(YXV2Quote * _Nonnull quote) {
        @strongify(self);
//        YXTradeOrderModel *model = [YXStockDetailUtility getTradeModelWihtQuote:quote];
//        [YXTradeViewModel getOrderTypeWithMarket:model.market Complete:^(NSInteger type) {
//            
//            YXTradeViewModel *viewModel = [[YXTradeViewModel alloc] initWithServices:self.viewModel.services params:@{@"tradeModel":model, @"tradeType":@(YXTradeTypeNormal), @"defaultOrderType":@(type)}];
//            [self.viewModel.services pushViewModel:viewModel animated:YES];
//        }];
    }];
    cell.quote = self.viewModel.dataSource[indexPath.section][indexPath.row];
}


- (NSDictionary *)cellIdentifiers {
    return @{
              @"YXTodayGreyStockCell" : @"YXTodayGreyStockCell"
             };
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 30)];
    headView.backgroundColor = QMUITheme.foregroundColor;
    
    UILabel *label1 = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"hold_stock_name"] textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:14]];
    UILabel *label2 = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"warrants_latest_price"] textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:14]];
    UILabel *label3 = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"market_roc"] textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:14]];
    float scale = YXConstant.screenWidth / 375.0;
    label1.frame = CGRectMake(18 * scale, 0, 60, 30);
    label2.frame = CGRectMake(167 * scale, 0, 60, 30);
    label3.frame = CGRectMake(223 * scale, 0, 60, 30);
    
    [headView addSubview:label1];
    [headView addSubview:label2];
    [headView addSubview:label3];
    
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    YXV2Quote *quote = self.viewModel.dataSource[indexPath.section][indexPath.row];    

    YXStockInputModel *input = [[YXStockInputModel alloc] init];
    input.market = quote.market;
    input.symbol = quote.symbol;
    input.name = quote.name;
    [self.viewModel.services pushPath:YXModulePathsStockDetail context:@{@"dataSource": @[input], @"selectIndex": @(0)} animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return CGFLOAT_MIN;
}


- (UILabel *)tipLabel {
    if (_tipLabel == nil) {
        _tipLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:12]];
    }
    return _tipLabel;
}
@end
