//
//  STLTrackingListCtrl.m
// XStarlinkProject
//
//  Created by odd on 2020/8/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLTrackingListCtrl.h"
#import "OSSVTrackingccItemcViewModel.h"
#import "OSSVLogistieeTrackeCell.h"
#import "OSSVTrackingccInfomatViewModel.h"
@interface STLTrackingListCtrl ()

@property (nonatomic, strong) UITableView                  *tableView;
@property (nonatomic, strong) OSSVTrackingccItemcViewModel        *viewModel;
@property (nonatomic, strong) OSSVTrackingccInfomatViewModel  *infomationViewModel;

@end

@implementation STLTrackingListCtrl

#pragma mark - Life Cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self requsetLoadData];
    [self initSubViews];
}

#pragma mark - Method
- (void)requsetLoadData {
    
    if (! (self.orderNumber.length > 0)) return;
    @weakify(self)
    [self.infomationViewModel requestNetwork:self.orderNumber completion:^(id obj) {
        @strongify(self)
        [self.viewModel setTrackingRoutesArray:obj];
        [self.tableView reloadData];
    } failure:^(id obj) {
        
    }];
}


#pragma mark - Delegate

#pragma mark - MakeUI
- (void)initSubViews {

    self.tableView = [[UITableView alloc] init];
    [self.tableView registerClass:[OSSVLogistieeTrackeCell class] forCellReuseIdentifier:@"OSSVLogistieeTrackeCell"];
    self.tableView.delegate = self.viewModel;
    self.tableView.dataSource = self.viewModel;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

#pragma mark - LazyLoad
-(OSSVTrackingccItemcViewModel *)viewModel {
    
    if (!_viewModel) {
        _viewModel = [[OSSVTrackingccItemcViewModel alloc] init];
    }
    return _viewModel;
}

- (OSSVTrackingccInfomatViewModel *)infomationViewModel {
    if (!_infomationViewModel) {
        _infomationViewModel = [[OSSVTrackingccInfomatViewModel alloc] init];
    }
    return _infomationViewModel;;
}
@end
