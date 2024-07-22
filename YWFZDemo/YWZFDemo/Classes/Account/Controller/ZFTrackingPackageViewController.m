//
//  ZFTrackingPackageViewController.m
//  ZZZZZ
//
//  Created by YW on 4/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFTrackingPackageViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFTrackingPackageViewModel.h"
#import "ZFTrackingListCell.h"
#import "ZFTrackingGoodsCell.h"
#import "ZFTrackingEmptyCell.h"
#import "ZFTrackingPackageModel.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import <Masonry/Masonry.h>

@interface ZFTrackingPackageViewController ()<ZFInitViewProtocol>
@property (nonatomic, strong) UITableView   *tableView;
@property (nonatomic, strong) ZFTrackingPackageViewModel   *viewModel;
@property (nonatomic, strong) UIView   *empatyView;
@end

@implementation ZFTrackingPackageViewController
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self zfInitView];
    [self zfAutoLayoutView];
    
    self.viewModel.model = self.model;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark -<ZFInitViewProtocol>
- (void)zfInitView {
    self.view.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).mas_offset(UIEdgeInsetsMake(0, 0, STATUSHEIGHT + NAVBARHEIGHT + kiphoneXHomeBarHeight, 0));
    }];
}

#pragma mark - Getter
-(UITableView *)tableView{
    if (!_tableView) {
//        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - 44) style:UITableViewStyleGrouped];
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.showsHorizontalScrollIndicator = NO;
        [_tableView registerClass:[ZFTrackingListCell class] forCellReuseIdentifier:[ZFTrackingListCell setIdentifier]];
        [_tableView registerClass:[ZFTrackingGoodsCell class] forCellReuseIdentifier:[ZFTrackingGoodsCell setIdentifier]];
         [_tableView registerClass:[ZFTrackingEmptyCell class] forCellReuseIdentifier:[ZFTrackingEmptyCell setIdentifier]];
        _tableView.dataSource = self.viewModel;
        _tableView.delegate = self.viewModel;
        _tableView.scrollsToTop = YES;
        _tableView.estimatedSectionFooterHeight = 12;
        _tableView.estimatedSectionHeaderHeight = 0;
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return _tableView;
}

- (ZFTrackingPackageViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFTrackingPackageViewModel alloc] init];
        
    }
    return _viewModel;
}



@end
