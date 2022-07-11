//
//  OSSVCountrySelectVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCountrySelectVC.h"
#import "OSSVCountryeViewModel.h"
#import "CountryModel.h"
#import "OSSVCountryeViewCell.h"

@interface OSSVCountrySelectVC ()

@property (nonatomic, strong) UITableView       *tableView;

@end

@implementation OSSVCountrySelectVC

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"country", nil);
    [self initView];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 谷歌统计
    if (!self.firstEnter) {
    }
    self.firstEnter = YES;
}

- (void)loadData {
//    if ([OSSVAccountsManager sharedManager].countryList.count <= 0) {
//        [self.viewModel requestNetwork:nil completion:^(id obj) {
//            [self.viewModel initDataSources];
//            [self.tableView reloadData];
//        } failure:^(id obj) {
//            
//        }];
//    }
}

#pragma mark - Action methods


#pragma mark - Private Methods


#pragma mark - MakeUI;
- (void)initView {
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self.viewModel;
    _tableView.dataSource = self.viewModel;
    _tableView.tableFooterView = [UIView new];
    _tableView.tableHeaderView = [UIView new];
    _tableView.separatorColor = OSSVThemesColors.col_F1F1F1;
    _tableView.allowsSelection = YES;
    _tableView.sectionIndexColor = [UIColor blackColor];
    [_tableView registerClass:[OSSVCountryeViewCell class] forCellReuseIdentifier:NSStringFromClass(OSSVCountryeViewCell.class)];
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (kIS_IPHONEX) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, STL_TABBAR_IPHONEX_H, 0));
        } else {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }
    }];
}

#pragma mark - LazyLoad
- (OSSVCountryeViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVCountryeViewModel alloc]init];
        _viewModel.controller = self;
        [_viewModel initDataSources];
        @weakify(self)
        _viewModel.countrySelect = ^(CountryModel *model) {
            //获取国家信息后，将model回传至地址编辑界面
            @strongify(self)
            self.countryBlock(model);
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
    return _viewModel;
}
@end
