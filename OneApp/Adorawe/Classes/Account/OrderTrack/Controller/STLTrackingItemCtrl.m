//
//  STLTrackingItemCtrl.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLTrackingItemCtrl.h"
#import "OSSVTrackingccItemcViewModel.h"
#import "OSSVTrackingcRoutecHeadView.h"
#import "OSSVLogistieeTrackeCell.h"

@interface STLTrackingItemCtrl ()

/**
 *  此处尝试，用section 的方式尝试
 */
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) OSSVTrackingcRoutecHeadView *tableHeaderView;
@property (nonatomic, strong) OSSVTrackingccItemcViewModel *viewModel;

@end

@implementation STLTrackingItemCtrl

#pragma mark - Life Cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self requestLoadData];
    [self initSubViews];
}

#pragma mark - Method
- (void)requestLoadData {
//    self.viewModel.OSSVTrackingcInformationcModel = self.OSSVTrackingcInformationcModel;
    [self.viewModel setTrackingRoutesArray:self.trackingsArray];
}

#pragma mark - Delegate

#pragma mark - MakeUI
- (void)initSubViews {

    self.tableView = [[UITableView alloc] init];
    [self.tableView registerClass:[OSSVLogistieeTrackeCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.delegate = self.viewModel;
    self.tableView.dataSource = self.viewModel;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = self.tableHeaderView;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
//    [self.tableHeaderView setTitleString:self.OSSVTrackingcInformationcModel.shippingName
//                          trackingNumber:self.OSSVTrackingcInformationcModel.shippingNumber];
}

#pragma mark - LazyLoad
-(OSSVTrackingccItemcViewModel *)viewModel {
    
    if (!_viewModel) {
        _viewModel = [[OSSVTrackingccItemcViewModel alloc] init];
    }
    return _viewModel;
}

-(OSSVTrackingcRoutecHeadView *)tableHeaderView
{
    if (!_tableHeaderView) {
        _tableHeaderView = [[OSSVTrackingcRoutecHeadView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];
    }
    return _tableHeaderView;
}

@end
