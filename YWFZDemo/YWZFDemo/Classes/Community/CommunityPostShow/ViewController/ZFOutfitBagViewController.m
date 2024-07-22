//
//  ZFOutfitBagViewController.m
//  Zaful
//
//  Created by TsangFa on 16/11/28.
//  Copyright © 2016年 Y001. All rights reserved.
//

#import "ZFCommunityShowBagVC.h"
#import "BagViewModel.h"

@interface ZFCommunityShowBagVC ()
@property (nonatomic,strong) UITableView *goodsTableView;
@property (nonatomic,strong) BagViewModel *viewModel;
@end

@implementation ZFCommunityShowBagVC

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.goodsTableView];
    [self setupGoodsTableRefreshKit];
}

- (void)setupGoodsTableRefreshKit {
    @weakify(self)
    ZFRefreshHeader *header = [ZFRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self requestBagData];
    }];
    [self.goodsTableView setMj_header:header];
    [self.goodsTableView.mj_header beginRefreshing];
}

/**
 * 请求购物车数据
 */
- (void)requestBagData
{
    @weakify(self)
    [self.viewModel requestBagNetwork:LoadHUD completion:^(NSDictionary *pageDic) {
        @strongify(self)
        [self.goodsTableView reloadData];
        [self.goodsTableView showRequestTip:pageDic];
    }];
}

#pragma mark - Setter/Getter
-(BagViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[BagViewModel alloc] init];
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
        _goodsTableView.emptyDataImage = [UIImage imageNamed:@"blank_bag"];
        _goodsTableView.emptyDataTitle = ZFLocalizedString(@"CartViewModel_NoData_TitleLabel",nil);
    }
    return _goodsTableView;
}

@end
