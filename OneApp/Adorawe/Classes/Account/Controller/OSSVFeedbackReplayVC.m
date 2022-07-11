//
//  OSSVFeedbackReplayVC.m
// XStarlinkProject
//
//  Created by odd on 2021/4/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVFeedbackReplayVC.h"
#import "OSSVFeedBakReplaQuestiCell.h"
#import "OSSVFeedbackReplaAnsweCell.h"

#import "OSSVFeedbakReplaysViewModel.h"

#import "OSSVCommonnRequestsManager.h"
@interface OSSVFeedbackReplayVC ()

@property (nonatomic,strong) UITableView                    *tableView;
@property (nonatomic, strong) OSSVFeedbakReplaysViewModel    *viewModel;
@end

@implementation OSSVFeedbackReplayVC

/*========================================分割线======================================*/

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"REPALY",nil);
    
    [self initView];
    [self requesData];
}

/*========================================分割线======================================*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.firstEnter = YES;
}

/*========================================分割线======================================*/

#pragma mark - 初始化界面
- (void)initView {
    self.view.backgroundColor = [OSSVThemesColors col_F5F5F5];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (kIS_IPHONEX) {
            make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, STL_TABBAR_IPHONEX_H, 0));
        } else {
            make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }
    }];
}

/*========================================分割线======================================*/

#pragma mark - 请求评论数据
- (void)requesData {
    @weakify(self)
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        [self.viewModel requestNetwork:@{@"isRefresh":@(YES)} completion:^(id obj) {
            @strongify(self)
            AccountModel *accountModel = [OSSVAccountsManager sharedManager].account;
            accountModel.feedbackMessageCount = 0;
            
            [self.tableView reloadData];
            //更新用户信息---目的更新已读的消息数量
            if ([OSSVAccountsManager sharedManager].isSignIn) {
                [OSSVCommonnRequestsManager checkUpdateUserInfo:nil];
            }
            [self.tableView showRequestTip:@{kTotalPageKey  : @(1),
                                                 kCurrentPageKey: @(0)}];

        } failure:^(id obj) {
            @strongify(self)
            [self.tableView reloadData];
            [self.tableView showRequestTip:nil];
        }];
    }];

    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
//    self.tableView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
//        @strongify(self)
//        @weakify(self)
//        [self.viewModel requestNetwork:@{} completion:^(id obj) {
//            @strongify(self)
//            [self.tableView reloadData];
//            [self.tableView.mj_footer endRefreshing];
//        } failure:^(id obj) {
//            @strongify(self)
//            [self.tableView.mj_footer endRefreshing];
//        }];
//    }];
    [self.tableView.mj_header beginRefreshing];
}

/*========================================分割线======================================*/

#pragma mark - SetModel Method
- (OSSVFeedbakReplaysViewModel *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [OSSVFeedbakReplaysViewModel new];
        _viewModel.controller = self;

        @weakify(self)
        _viewModel.emptyOperationBlock = ^{
            @strongify(self)
            [self.tableView.mj_header beginRefreshing];
        };

    }
    return _viewModel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        
        tableView.sectionFooterHeight = 10;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        tableView.showsVerticalScrollIndicator = NO;
        tableView.separatorStyle = NO;
        
        [tableView registerClass:[OSSVFeedBakReplaQuestiCell class] forCellReuseIdentifier:NSStringFromClass(OSSVFeedBakReplaQuestiCell.class)];
        [tableView registerClass:[OSSVFeedbackReplaAnsweCell class] forCellReuseIdentifier:NSStringFromClass(OSSVFeedbackReplaAnsweCell.class)];
        
        tableView.dataSource = self.viewModel;
        tableView.delegate = self.viewModel;
        
        tableView.emptyDataImage = [UIImage imageNamed:@"replay_bank"];
        tableView.emptyDataTitle = STLLocalizedString_(@"messageNoMsgTip", nil);
        tableView.blankPageImageViewTopDistance = 40;

        _tableView = tableView;
    }
    return _tableView;
}

/*========================================分割线======================================*/

- (void)dealloc {
    
}


@end
