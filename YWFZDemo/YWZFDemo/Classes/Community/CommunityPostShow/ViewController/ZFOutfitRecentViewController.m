//
//  ZFOutfitRecentViewController.m
//  Zaful
//
//  Created by TsangFa on 16/11/29.
//  Copyright © 2016年 Y001. All rights reserved.
//

#import "ZFCommunityRecentVC.h"
#import "RecentViewModel.h"

@interface ZFCommunityRecentVC ()
@property (nonatomic,strong) UITableView *goodsTableView;
@property (nonatomic,strong) RecentViewModel *viewModel;
@end

@implementation ZFCommunityRecentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.goodsTableView];
    [self requestRecentData];
}

- (void)requestRecentData {
    @weakify(self)
    [self.viewModel requestRecentNetwork:nil completion:^(NSDictionary *pageInfo) {
        @strongify(self)
        [self.goodsTableView reloadData];
        //处理数据空白页
        [self.goodsTableView showRequestTip:pageInfo];
    }];
}

#pragma mark - Setter/Getter
-(RecentViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[RecentViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

-(UITableView *)goodsTableView {
    if (!_goodsTableView) {
        _goodsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - 44) style:UITableViewStylePlain];
        _goodsTableView.rowHeight = 114;
        _goodsTableView.delegate = self.viewModel;
        _goodsTableView.dataSource = self.viewModel;
        _goodsTableView.showsVerticalScrollIndicator = YES;
        _goodsTableView.showsHorizontalScrollIndicator = NO;
        _goodsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _goodsTableView.tableFooterView = [[UIView alloc] init];
        _goodsTableView.estimatedRowHeight = 0;
        _goodsTableView.estimatedSectionFooterHeight = 0;
        _goodsTableView.estimatedSectionHeaderHeight = 0;
        _goodsTableView.emptyDataImage = [UIImage imageNamed:@"blankPage_noSearchData"];
        _goodsTableView.emptyDataTitle = ZFLocalizedString(@"RecentViewModel_NoData_Title",nil);
    }
    return _goodsTableView;
}

@end
