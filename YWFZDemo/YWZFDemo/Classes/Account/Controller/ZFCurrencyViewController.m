//
//  ZFCurrencyViewController.m
//  Dezzal
//
//  Created by 7FD75 on 16/8/1.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "ZFCurrencyViewController.h"
#import "CurrencyViewModel.h"
#import "ZFInitViewProtocol.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCurrencyViewController () <ZFInitViewProtocol>
@property (nonatomic, strong) UITableView    * tableView;
@property (nonatomic, strong) CurrencyViewModel *viewModel;
@end

@implementation ZFCurrencyViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zfInitView];
    [self zfAutoLayoutView];
    [self.viewModel requestData:self.comeFromType];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.title = ZFLocalizedString(@"Currency_VC_Title",nil);
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).with.insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - getter
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self.viewModel;
        _tableView.dataSource = self.viewModel;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"currencyCell"];
        _tableView.rowHeight = 50;
//        if (@available(iOS 11.0, *)) _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return _tableView;
}

- (CurrencyViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[CurrencyViewModel alloc] init];
        _viewModel.controller = self;
        _viewModel.tableView = _tableView;
        _viewModel.shouldSelectedCurrency = self.shouldSelectedCurrency;
        @weakify(self)
        _viewModel.selectCurrencyBlock = ^(NSString *currency) {
            @strongify(self)
            if (self.convertCurrencyBlock) {
                self.convertCurrencyBlock(currency);
            }
        };
    }
    return _viewModel;
}

@end
