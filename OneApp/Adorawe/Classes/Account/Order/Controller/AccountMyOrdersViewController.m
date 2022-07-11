//
//  OSSVAccountsMyOrderVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccountsMyOrderVC.h"
#import "STLBindCountrySelectViewController.h"

#import "STLBindPhoneNumViewModel.h"  

#import "AccountMyOrdersViewModel.h"
#import "AccountMyOrdersHeaderView.h"
#import "AccountMyOrdersCell.h"
#import "STLServiceTipsAlertView.h"
#import "STLAlertControllerView.h"
#import "STLWhatsAppContentView.h"
#import "STLBindCountryModel.h"
@interface OSSVAccountsMyOrderVC ()<STLWhatsAppContentViewDelegate>


@property (nonatomic, strong) UIBarButtonItem            *rightNavigationItem;
@property (nonatomic, strong) STLWhatsAppContentView     *whatsAppView; //whatsAPP 背景视图
@property (nonatomic, strong) AccountMyOrdersViewModel   *viewModel;
@property (nonatomic, strong) STLBindCountryModel        *countryModel;
@property (nonatomic, strong) STLBindPhoneNumViewModel   *phoneViewModel;
@property (nonatomic, strong) UIActivityIndicatorView     *actView;//加载菊花

@property (nonatomic,strong) UIView *ipChangedView;

@end


@implementation OSSVAccountsMyOrderVC

-(void)dealloc {
    if (_viewModel) {
        [self.viewModel freesource];
        [self.viewModel stopCellTimer];
        self.viewModel = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.firstEnter) {
        self.firstEnter = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"myOrder",nil);
    
    if (!STLIsEmptyString(self.orderTitle)) {
        self.title = self.orderTitle;
    }
    
    if ([self.status isEqualToString:@""]) {
        self.tableView.emptyDataTitle    = STLLocalizedString_(@"order_all_blank",nil);

    } else if([self.status isEqualToString:@"0"]) {
        self.tableView.emptyDataTitle    = STLLocalizedString_(@"order_unpaid_blank",nil);

    } else if([self.status isEqualToString:@"2"]) {
        self.tableView.emptyDataTitle    = STLLocalizedString_(@"order_processing_blank",nil);

    } else if([self.status isEqualToString:@"3"]) {
        self.tableView.emptyDataTitle    = STLLocalizedString_(@"order_shipped_blank",nil);

    } else if([self.status isEqualToString:@"4"]) {
        self.tableView.emptyDataTitle    = STLLocalizedString_(@"order_reviewed_blank",nil);

    }
    [self initView];
    [self requestData];

    NSString *phoneHead = STLToString([AccountManager sharedManager].account.subscribeDic [@"phone_head"]);
    NSString *defaultCountyPhoneHead = STLToString([[NSUserDefaults standardUserDefaults] valueForKey:kDefaultCountryPhoneCode]);
    NSString *defaultCountyPicUrlSting = STLToString([[NSUserDefaults standardUserDefaults] valueForKey:kDefaultCountryPicUrl]);
    
    if (STLIsEmptyString(phoneHead)) {
        [self.whatsAppView.countryImageView yy_setImageWithURL:[NSURL URLWithString:defaultCountyPicUrlSting] placeholder:[UIImage imageNamed:@"region_place_polder"]];
        self.whatsAppView.phoneCode.text = [NSString stringWithFormat:@"+%@",defaultCountyPhoneHead];
    }
    
    //如果这两个字段都为空， 再次请求国家列表数据
    if (STLIsEmptyString(defaultCountyPhoneHead) && STLIsEmptyString(defaultCountyPicUrlSting)) {
            @weakify(self)
            [self.phoneViewModel requestInfo:^(STLBindCountryResultModel *  _Nonnull obj, NSString * _Nonnull msg) {
                @strongify(self)
                [self afterInfoGot:obj];
            } failure:^(id  _Nonnull obj, NSString * _Nonnull msg) {
        
            }];

    }
    //接收刷新通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataOperation:) name:kNotif_RefreshOrderList object:nil];
}

- (void)initView {
    self.view.backgroundColor = [STLThemeColor col_F5F5F5];
    [self.view addSubview:self.whatsAppView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.actView];
    [self.view addSubview:self.ipChangedView];
    self.viewModel.tableView = self.tableView;
    
    //是否展示WhatsApp 引流视图
    if(AccountManager.sharedManager.sysIniModel.isShowWhatsAppSubscribe) {
        self.whatsAppView.hidden = NO;
        [self.whatsAppView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_equalTo(self.view);
            make.height.equalTo(90);
        }];

    } else {
        self.whatsAppView.hidden = YES;
        [self.whatsAppView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_equalTo(self.view);
            make.height.equalTo(0);
        }];
    }
    
    [self.ipChangedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.view);
        make.top.equalTo(self.whatsAppView.mas_bottom);
        make.height.equalTo(0);
    }];


    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        make.leading.trailing.bottom.mas_equalTo(self.view);
//        make.top.mas_equalTo(self.whatsAppView.mas_bottom);
        make.top.mas_equalTo(self.ipChangedView.mas_bottom);
    }];
    
    if (self.isNeedTransform) {
        if ([SystemConfigUtils isRightToLeftShow]) {
            self.view.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    
    [self.actView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(20);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(-44);
    }];
    
}
-(void)setCountryModel:(STLBindCountryModel *)countryModel{
    _countryModel = countryModel;
    
    NSString *phoneHead = STLToString([AccountManager sharedManager].account.subscribeDic [@"phone_head"]);
    if (STLIsEmptyString(phoneHead)) {
        [self.whatsAppView.countryImageView yy_setImageWithURL:[NSURL URLWithString:STLToString(_countryModel.picture)] placeholder:[UIImage imageNamed:@"region_place_polder"]];
        self.whatsAppView.phoneCode.text = [NSString stringWithFormat:@"+%@",STLToString(_countryModel.code)];
    }
}

-(STLBindPhoneNumViewModel *)phoneViewModel{
    if (!_phoneViewModel) {
        _phoneViewModel = [[STLBindPhoneNumViewModel alloc] init];
    }
    return _phoneViewModel;
}


- (STLWhatsAppContentView *)whatsAppView {
    if (!_whatsAppView) {
        _whatsAppView = [[STLWhatsAppContentView alloc] init];
        _whatsAppView.backgroundColor = [UIColor whiteColor];
        _whatsAppView.delegate = self;
    }
    return _whatsAppView;
}

- (UIView *)ipChangedView{
    ///到时候再加逻辑判断是否展示
    if (!_ipChangedView) {
        _ipChangedView = [[UIView alloc] init];
        _ipChangedView.backgroundColor = STLThemeColor.col_FBE9E9;
        _ipChangedView.hidden = YES;
        UILabel *contentLbl = [[UILabel alloc] init];
        contentLbl.numberOfLines = 0;
        contentLbl.font = [UIFont systemFontOfSize:12];
        contentLbl.textColor = STLThemeColor.col_B62B21;
        [contentLbl convertTextAlignmentWithARLanguage];
        contentLbl.text = STLLocalizedString_(@"ip_alert_content", nil);
        [_ipChangedView addSubview:contentLbl];
        [contentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(12);
            make.trailing.equalTo(-12);
            make.top.equalTo(8);
            make.bottom.equalTo(-8);
        }];
    }
    return _ipChangedView;
}
#pragma mark - Request
//默认国家数据
-(void)afterInfoGot:(STLBindCountryResultModel *)obj{
    for (STLBindCountryModel* country in obj.countries) {
        if ([country.countryId isEqualToString:obj.default_country_id]) {
            self.countryModel = country;
        }
    }
}

- (void)requestData {
    @weakify(self)
    self.tableView.mj_footer = [STLRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        
        NSDictionary *dic = @{@"isRfersh":@(0),@"status":STLToString(self.status)};
        [self.viewModel requestNetwork:dic completion:^(id obj) {
            @strongify(self)
            [self.tableView reloadData];
            if([obj isEqual: STLNoMoreToLoad]) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                [UIView animateWithDuration:0.3 animations:^{
                    self.tableView.mj_footer.hidden = YES;
                }];
            }else {
                [self.tableView.mj_footer endRefreshing];
            }
        } failure:^(id obj) {
            @strongify(self)
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
        }];
    }];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self refresRequest:NO];
    }];
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
    //[self.tableView.mj_header beginRefreshing];
    
    [self refresRequest:YES];
}

- (void)refresRequest:(BOOL)showLoading {
    if (showLoading) {
        [self.actView startAnimating];
    }
    @weakify(self)
    NSDictionary *dic = @{@"isRfersh":@(1),@"status":STLToString(self.status)};
    [self.viewModel requestNetwork:dic completion:^(id obj) {
        @strongify(self)
        [self.tableView reloadData];
        if (self.tableView.mj_footer.state == MJRefreshStateNoMoreData) {
            [self.tableView showRequestTip:@{kTotalPageKey  : @(1),
                                             kCurrentPageKey: @(1)}];
        } else {
            [self.tableView showRequestTip:@{kTotalPageKey  : @(1),
                                             kCurrentPageKey: @(0)}];
        }
        

        if (self.isConcelCodEnter) {
            self.isConcelCodEnter = NO;
            [self.viewModel showCancelCodAlterView:self.codOrderAddressModel];
            
        }
        [self.actView stopAnimating];
    } failure:^(id obj) {
        @strongify(self)
        [self.tableView reloadData];
        [self.tableView showRequestTip:nil];
        [self.actView stopAnimating];

    }];
}


#pragma mark - target
///客服按钮 action
-(void)customerServiceBtnAction {
    STLServiceTipsAlertView *popView = [[STLServiceTipsAlertView alloc] init];
    [popView show];
}

- (void)goShopping {
    [STLAdvEventManager goHomeModule];
}

#pragma mark --STLWhatsAppContentViewDelegate
- (void)didtapedSelectCountryButton:(id)currentCountry {
    NSLog(@"进入国家列表");
    STLBindCountrySelectViewController *vc = [[STLBindCountrySelectViewController alloc]init];
    UIImage *image = [UIImage imageNamed:@"close_18"];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    [backBtn setImage:image forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(dismissSelect) forControlEvents:UIControlEventTouchUpInside];
    if ([SystemConfigUtils isRightToLeftShow]) {
        backBtn.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    vc.navigationItem.rightBarButtonItem = item;
    vc.isModalPresent = YES;
    
    @weakify(self)
    vc.countryBlock = ^(STLBindCountryModel * _Nonnull model) {
        @strongify(self)
        self.countryModel = model;
        [self.whatsAppView.countryImageView yy_setImageWithURL:[NSURL URLWithString:STLToString(model.picture)] placeholder:[UIImage imageNamed:@"region_place_polder"]];
        
        if ([STLToString(model.code) hasPrefix:@"+"]) {
            self.whatsAppView.phoneCode.text = STLToString(model.code);
        } else {
            self.whatsAppView.phoneCode.text = [NSString stringWithFormat:@"+%@",STLToString(model.code)];
        }

        [self dismissSelect];
    };
    if (self.phoneViewModel.keyArr.count > 0) {
        vc.keyArr = self.phoneViewModel.keyArr;
        OSSVNavigationVC *nav = [[OSSVNavigationVC alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:nav animated:YES completion:nil];
    }else{
        [self.phoneViewModel requestInfo:^(id  _Nonnull obj, NSString * _Nonnull msg) {
            [self afterInfoGot:obj];
            vc.keyArr = self.phoneViewModel.keyArr;
            OSSVNavigationVC *nav = [[OSSVNavigationVC alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationPageSheet;
            [self presentViewController:nav animated:YES completion:nil];

        } failure:^(id  _Nonnull obj, NSString * _Nonnull msg) {
            [HUDManager showHUDWithMessage:msg];
        }];
    }
}

-(void)dismissSelect{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications
- (void)reloadDataOperation:(NSNotification *)noti {
    [self refresRequest:NO];
}

#pragma mark - setter and getter

-(UIBarButtonItem *)rightNavigationItem {
    if (!_rightNavigationItem) {
        _rightNavigationItem = ({
            UIButton *customerServiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [customerServiceBtn setImage:[UIImage imageNamed:@"customerService"] forState:UIControlStateNormal];
            [customerServiceBtn addTarget:self action:@selector(customerServiceBtnAction) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *navigationItem = [[UIBarButtonItem alloc] initWithCustomView:customerServiceBtn];
            navigationItem;
        });
    }
    return _rightNavigationItem;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [STLThemeColor col_F5F5F5];
        _tableView.bounds = self.view.bounds;
        [_tableView registerClass:[AccountMyOrdersCell class] forCellReuseIdentifier:NSStringFromClass(AccountMyOrdersCell.class)];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.dataSource = self.viewModel;
        _tableView.delegate = self.viewModel;
        _tableView.multipleTouchEnabled = NO;
        
        _tableView.emptyDataTitle    = STLLocalizedString_(@"order_all_blank",nil);
        _tableView.blankPageImageViewTopDistance = 40;
        _tableView.emptyDataImage = [UIImage imageNamed:@"order_bank"];
        _tableView.emptyDataBtnTitle = APP_TYPE == 3 ? STLLocalizedString_(@"go_shopping", nil) : STLLocalizedString_(@"go_shopping", nil).uppercaseString;
        
        @weakify(self)
        _tableView.blankPageViewActionBlcok = ^(STLBlankPageViewStatus status) {
            @strongify(self)
            if (status == RequestEmptyDataStatus) {
                [self goShopping];
            } else {
                [self.tableView.mj_header beginRefreshing];
            }
        };
    }
    return _tableView;
}

- (AccountMyOrdersViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[AccountMyOrdersViewModel alloc] init];
        _viewModel.controller = self;
        @weakify(self)
        _viewModel.reloadDataBlock = ^{
            @strongify(self)
            [self.tableView.mj_header beginRefreshing];
            [self.tableView reloadData];
        };
        _viewModel.ipChangedView = self.ipChangedView;
    }
    return _viewModel;
}



- (UIActivityIndicatorView *)actView {
    if (!_actView) {
        _actView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        _actView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _actView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }
    return _actView;
}

@end
