//
//  OSSVMyCouponsItemVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMyCouponsItemVC.h"
#import "OSSVMyCouponItemseViewModel.h"

@interface OSSVMyCouponsItemVC ()

@property (nonatomic, strong) UITableView            *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *actView;
@property (nonatomic, strong) OSSVMyCouponItemseViewModel *viewModel;

@end

@implementation OSSVMyCouponsItemVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];

    //occ阿语适配 阿语时: 外部容器控制器已翻转, 自控制器需要再次翻转显示才正确
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.view.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
    

    if ([self.identifier isEqualToString:@"unused"]) {
        self.tableView.emptyDataTitle    = STLLocalizedString_(@"Coupon_NoData_Available_titleLabel",nil);

    } else if([self.identifier isEqualToString:@"expired"]) {
        self.tableView.emptyDataTitle    = STLLocalizedString_(@"Coupon_NoData_Expired_titleLabel",nil);

    } else if([self.identifier isEqualToString:@"used"]) {
        self.tableView.emptyDataTitle    = STLLocalizedString_(@"Coupon_NoData_Applied_titleLabel",nil);

    }
    self.tableView.blankPageImageViewTopDistance = 40;
    self.tableView.emptyDataImage = [UIImage imageNamed:@"my_coupon_bank"];

    
    @weakify(self)
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self requestDataLoadMore:YES isShowLoad:NO];
    }];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self requestDataLoadMore:NO isShowLoad:YES];
    }];
    
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    
    self.tableView.mj_header = header;
    
    [self requestDataLoadMore:NO isShowLoad:YES];
}

- (void)requestDataLoadMore:(BOOL)isLoadMore isShowLoad:(BOOL)isShowLoad{
    
    if (isLoadMore) {
        @weakify(self)
        [self.viewModel requestNetwork:self.identifier completion:^(id obj) {
            @strongify(self)
            [self showLoading:NO];
            [self.tableView reloadData];
            if([obj isEqual: STLNoMoreToLoad]) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                self.tableView.mj_footer.hidden = YES;
            }else {
                [self.tableView.mj_footer endRefreshing];
            }
            
        } failure:^(id obj) {
            @strongify(self)
            [self showLoading:NO];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
        }];
    } else {
        
        if (STLJudgeNSArray(self.viewModel.dataArray) && self.viewModel.dataArray.count > 0) {
        } else {
            [self showLoading:YES];
        }
        
        @weakify(self)
        [self.viewModel requestNetwork:self.identifier completion:^(id obj) {
            @strongify(self)
//            if (self.tableView.mj_footer.state == MJRefreshStateNoMoreData) {
//                // 此处是对应 mj_footer.state == 不能加载更多后的重置
//                [self.tableView.mj_footer resetNoMoreData];
//                self.tableView.mj_footer.hidden = NO;
//            }
            [self showLoading:NO];
            [self.tableView reloadData];
            //消除未读coupons提示
            AccountModel *model = [OSSVAccountsManager sharedManager].account;
            model.appUnreadCouponNum = 0;
            [[OSSVAccountsManager sharedManager] updateUserInfo:model];
            [self.tableView showRequestTip:@{kTotalPageKey  : @(1),
                                                 kCurrentPageKey: @(0)}];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_ChangeAccountRedDot object:nil];
        } failure:^(id obj) {
            @strongify(self)
            [self showLoading:NO];
            [self.tableView reloadData];
            [self.tableView showRequestTip:nil];

            
        }];
    }
}

- (void)showLoading:(BOOL)showLoading {
    
    if (!_actView) {
        [self.view addSubview:self.actView];
        [self.actView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.equalTo(20);
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.centerY.mas_equalTo(self.view.mas_centerY);
        }];
    }
    if (showLoading) {
        [self.actView startAnimating];
    } else {
        [self.actView stopAnimating];
    }
}

- (UIActivityIndicatorView *)actView {
    if (!_actView) {
        _actView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        _actView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _actView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }
    return _actView;
}

- (void)initView {
    self.view.backgroundColor = [OSSVThemesColors col_F5F5F5];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

#pragma mark LazyLoad

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.bounds = self.view.bounds;
        _tableView.backgroundColor = [OSSVThemesColors col_F5F5F5];

        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.dataSource = self.viewModel;
        _tableView.delegate = self.viewModel;
        _tableView.mj_footer.hidden = YES;
    }
    return _tableView;
}

- (OSSVMyCouponItemseViewModel*)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVMyCouponItemseViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
