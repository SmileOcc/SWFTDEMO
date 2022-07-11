//
//  STLTransportSplitViewController.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/23.
//  Copyright © 2020 starlink. All rights reserved.
//  -------物流拆单-------

#import "STLTransportSplitViewController.h"
#import "STLNewTrackingListViewController.h"

#import "OSSVTransportcSplitcTableCell.h"
#import "OSSVTransportcSplitccViewModel.h"
#import "OSSVTransporteSpliteTotalModel.h"
@interface STLTransportSplitViewController ()<UITableViewDelegate, UITableViewDataSource, STLTransportSplitTableViewCellDelegate>
@property (nonatomic, strong) UITableView  *tableView;
@property (nonatomic, strong) OSSVTransportcSplitccViewModel *viewModel;
@property (nonatomic, strong) NSMutableArray *totalArray; //总的拆单数据
@property (nonatomic, strong) OSSVTrackeListeMode *trackListModel;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *headerLabel;
@end

@implementation STLTransportSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"trackingTitle",nil);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    @weakify(self)
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self requestTrackData];
    }];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    header.automaticallyChangeAlpha = YES;
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];

}
- (void)requestTrackData {
    if (! (self.orderNumber.length > 0)) return;
    @weakify(self)
    [self.viewModel requestNetwork:self.orderNumber completion:^(id obj) {
        @strongify(self)
        OSSVTransporteSpliteTotalModel *totalModel = (OSSVTransporteSpliteTotalModel *)obj;
        [self.totalArray removeAllObjects];
//        if (STLJudgeNSDictionary(obj)) {
//            [self.totalArray addObject:self.totalModel.trackList];
//        }
        [self.totalArray addObjectsFromArray:totalModel.trackList];
        self.headerView.backgroundColor = OSSVThemesColors.col_FFF5DF;
        self.headerLabel.text = [NSString stringWithFormat:@"%@", STLToString(totalModel.track_text)];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];

    } failure:^(id obj) {
        [self.tableView.mj_header endRefreshing];

    }];

}

- (NSMutableArray *)totalArray {
    if (!_totalArray) {
        _totalArray = [NSMutableArray array];
    }
    return _totalArray;
}
- (OSSVTransportcSplitccViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVTransportcSplitccViewModel alloc] init];
    }
    return _viewModel;
}

- (OSSVTrackeListeMode *)trackListModel {
    if (!_trackListModel) {
        _trackListModel = [[OSSVTrackeListeMode alloc] init];
    }
    return _trackListModel;
}

- (UIView*)headerView {
    if (!_headerView) {
        _headerView = [UIView new];
        _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 32*kScale_375);
        _headerView.backgroundColor = [UIColor clearColor];
        
        _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH-24, CGRectGetHeight(_headerView.bounds))];
        _headerLabel.textColor = OSSVThemesColors.col_666666;
        _headerLabel.font = [UIFont systemFontOfSize:12];
        [_headerView addSubview:_headerLabel];
    }
    return _headerView;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = OSSVThemesColors.col_F5F5F5;
        [_tableView registerClass:[OSSVTransportcSplitcTableCell  class] forCellReuseIdentifier:@"OSSVTransportcSplitcTableCell"];
        
    }
    return _tableView;
}
#pragma mark ---UITableViewDelegate And UITableViewDatasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSSVTransportcSplitcTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTransportcSplitcTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.trackListModel = self.totalArray[indexPath.row];
    cell.delegate = self;
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.totalArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.trackListModel = self.totalArray[indexPath.row];

    if (self.trackListModel.goodsList) {
        return 227*kScale_375;
    } else {
        return 95*kScale_375;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32*kScale_375;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

#pragma mark ----STLTransportSplitTableViewCellDelegate 跳转到物流轨迹详情
- (void)jumpIntoTrackingListWithorderNumber:(NSString *)trackId {
    STLNewTrackingListViewController *listVc = [[STLNewTrackingListViewController alloc] init];
    listVc.trackVal = trackId;
    listVc.trackType = @"0";
    [self.navigationController pushViewController:listVc animated:YES];
}
@end
