//
//  STLNewTrackingListViewController.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLNewTrackingListViewController.h"

#import "OSSVTrackingccItemcViewModel.h"
#import "OSSVTrackingccInfomatViewModel.h"

//Views
#import "OSSVLogistieeTrackeCell.h"
#import "OSSVNewTrackieListeHeadView.h"
#import "OSSVTrackingeAddresseTableCell.h"
#import "OSSVTrackingeWaitingeShipTableCell.h"
#import "OSSVTrackingeAlreadySendcTableCell.h"
#import "OSSVTrackingcTransporticTableVCell.h"
#import "OSSVTrackingcTransportiHeadTableCell.h"
#import "OSSVTrackingcAlreadySigncTableCell.h"
//Models
#import "OSSVTrackingcTotalInformcnModel.h"
#import "OSSVTransporteTrackeMode.h"

//ViewMode
#import "OSSVTrackingeTransportcViewModel.h"

@interface STLNewTrackingListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView  *tableView;
@property (nonatomic, strong) OSSVTrackingeTransportcViewModel  *infomationViewModel;
@property (nonatomic, strong) OSSVTrackingcTotalInformcnModel *totalTransportModel; //总的物流信息
@property (nonatomic, strong) NSMutableArray *trackArray; ///运输中轨迹
@end

@implementation STLNewTrackingListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
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
        [self requsetLoadData];
    }];
    header.automaticallyChangeAlpha = YES;
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
}

- (void)requsetLoadData {
    
    if (! (self.trackVal.length > 0)) return;
    @weakify(self)
    NSDictionary *paramDic = @{@"trackVal": self.trackVal,
                               @"trackType" :self.trackType
    };
    
    [self.infomationViewModel requestNetwork:paramDic completion:^(id obj) {
        @strongify(self)
        self.totalTransportModel = (OSSVTrackingcTotalInformcnModel *)obj;
        [self.trackArray removeAllObjects];
        //运输中的状态，把物流轨迹加入到轨迹数组中
        if (self.totalTransportModel.transport) {
            [self.trackArray addObjectsFromArray: self.totalTransportModel.transport.trackArray];
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];

    } failure:^(id obj) {
        [self.tableView.mj_header endRefreshing];

    }];
}

- (NSMutableArray *)trackArray {
    if (!_trackArray) {
        _trackArray = [[NSMutableArray alloc] init];
    }
    return _trackArray;
}

- (OSSVTrackingeTransportcViewModel *)infomationViewModel {
    if (!_infomationViewModel) {
        _infomationViewModel = [[OSSVTrackingeTransportcViewModel alloc] init];
    }
    return _infomationViewModel;
}
- (OSSVTrackingcTotalInformcnModel *)totalTransportModel {
    if (!_totalTransportModel) {
        _totalTransportModel = [[OSSVTrackingcTotalInformcnModel alloc] init];
    }
    return _totalTransportModel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = OSSVThemesColors.col_F5F5F5;
        [_tableView registerClass:[OSSVTrackingeAddresseTableCell class] forCellReuseIdentifier:@"OSSVTrackingeAddresseTableCell"];
        [_tableView registerClass:[OSSVTrackingeWaitingeShipTableCell class] forCellReuseIdentifier:@"OSSVTrackingeWaitingeShipTableCell"];
        [_tableView registerClass:[OSSVTrackingeAlreadySendcTableCell class] forCellReuseIdentifier:@"OSSVTrackingeAlreadySendcTableCell"];
        [_tableView registerClass:[OSSVTrackingcTransporticTableVCell class] forCellReuseIdentifier:@"OSSVTrackingcTransporticTableVCell"];
        [_tableView registerClass:[OSSVTrackingcTransportiHeadTableCell class] forCellReuseIdentifier:@"OSSVTrackingcTransportiHeadTableCell"];
        [_tableView registerClass:[OSSVTrackingcAlreadySigncTableCell class] forCellReuseIdentifier:@"OSSVTrackingcAlreadySigncTableCell"];
    }
    return _tableView;
}


#pragma mark ----UITableViewDelegate And UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //已签收------->待发货
    if (self.totalTransportModel.alreadySign || self.totalTransportModel.refuseSign) {
        if (section == 2) {
            //运输中状态
            return 1 + self.trackArray.count;
        } else {
            return 1;
        }
    } else if (self.totalTransportModel.transport) {
        if (section == 1) {
            return 1 + self.trackArray.count;
        } else {
            return 1;
        }
    } else if (self.totalTransportModel.alreadyShip) {
        return 1;
    } else if (self.totalTransportModel.waitingShip) {
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //已签收------->待发货

    if (self.totalTransportModel.alreadySign || self.totalTransportModel.refuseSign) {
        return 5 ;
    } else if (self.totalTransportModel.transport) {
        return 4 ;
    } else if (self.totalTransportModel.alreadyShip) {
        return 3;
    } else if (self.totalTransportModel.waitingShip) {
        return 2;
    } else {
        return 0;
    };
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     
    if (self.totalTransportModel.alreadySign || self.totalTransportModel.refuseSign) {///**********************************已签收 和 拒签状态
        if (indexPath.section == 0) {
            //地址
            OSSVTrackingeAddresseTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingeAddresseTableCell" forIndexPath:indexPath];
            cell.model = self.totalTransportModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (indexPath.section == 1) {
            //已签收
             OSSVTrackingcAlreadySigncTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingcAlreadySigncTableCell" forIndexPath:indexPath];
             cell.model = self.totalTransportModel;
             cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (indexPath.section == 2) {
            //运输中
            if (indexPath.row == 0) {
                OSSVTrackingcTransportiHeadTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingcTransportiHeadTableCell" forIndexPath:indexPath];
                cell.model = self.totalTransportModel;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                return cell;

            } else {
                OSSVTrackingcTransporticTableVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingcTransporticTableVCell" forIndexPath:indexPath];
                OSSVTransporteTrackeMode *trackModel = [[OSSVTransporteTrackeMode alloc] init];
                trackModel = self.trackArray[indexPath.row-1];
                cell.model = trackModel;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                return cell;
            }

        } else if (indexPath.section == 3) {
            OSSVTrackingeAlreadySendcTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingeAlreadySendcTableCell" forIndexPath:indexPath];
            cell.model = self.totalTransportModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            return cell;
        } else {
            OSSVTrackingeWaitingeShipTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingeWaitingeShipTableCell" forIndexPath:indexPath];
            cell.model = self.totalTransportModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            return cell;
        }
    } else if (self.totalTransportModel.transport) { ///**********************************运输中状态
        if (indexPath.section == 0) {
            //地址
            OSSVTrackingeAddresseTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingeAddresseTableCell" forIndexPath:indexPath];
            cell.model = self.totalTransportModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                OSSVTrackingcTransportiHeadTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingcTransportiHeadTableCell" forIndexPath:indexPath];
                cell.model = self.totalTransportModel;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                return cell;

            } else {
                OSSVTrackingcTransporticTableVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingcTransporticTableVCell" forIndexPath:indexPath];
                OSSVTransporteTrackeMode *trackModel = [[OSSVTransporteTrackeMode alloc] init];
                trackModel = self.trackArray[indexPath.row-1];
                cell.model = trackModel;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }

        } else if (indexPath.section == 2) {
            OSSVTrackingeAlreadySendcTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingeAlreadySendcTableCell" forIndexPath:indexPath];
            cell.model = self.totalTransportModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;

        } else {
            OSSVTrackingeWaitingeShipTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingeWaitingeShipTableCell" forIndexPath:indexPath];
            cell.model = self.totalTransportModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;

        }
    } else if (self.totalTransportModel.alreadyShip) { ///**********************************已发货状态
        if (indexPath.section == 0) {
            OSSVTrackingeAddresseTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingeAddresseTableCell" forIndexPath:indexPath];
            cell.model = self.totalTransportModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;

        } else if (indexPath.section == 1) {
            OSSVTrackingeAlreadySendcTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingeAlreadySendcTableCell" forIndexPath:indexPath];
            cell.model = self.totalTransportModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;

        } else {
            OSSVTrackingeWaitingeShipTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingeWaitingeShipTableCell" forIndexPath:indexPath];
            cell.model = self.totalTransportModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    } else { ///**********************************待发货状态
        if (indexPath.section == 0) {
            OSSVTrackingeAddresseTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingeAddresseTableCell" forIndexPath:indexPath];
            cell.model = self.totalTransportModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            OSSVTrackingeWaitingeShipTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVTrackingeWaitingeShipTableCell" forIndexPath:indexPath];
            cell.model = self.totalTransportModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;

        }
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        OSSVNewTrackieListeHeadView *view = [[OSSVNewTrackieListeHeadView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 54)];
        view.backgroundColor = OSSVThemesColors.col_FFFFFF;
        view.model = self.totalTransportModel;
        return view;

    } else {
        return [UIView new];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 62.f;
    } else {
        return 0.001;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

@end
