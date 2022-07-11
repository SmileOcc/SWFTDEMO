//
//  OSSVMessageActivityVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAdvsEventsManager.h"
#import "OSSVMessageActivityTableview.h"
#import "OSSVMessageActivityVC.h"
#import "OSSVMessageActivityViewModel.h"
#import "OSSVMessageListModel.h"

@interface OSSVMessageActivityVC ()<STLMessageActivityTableviewDelegate>

@property (nonatomic, strong) OSSVMessageActivityTableview *tableView;
@property (nonatomic, strong) OSSVMessageActivityViewModel *viewModel;

@end

@implementation OSSVMessageActivityVC

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"messagePromotion",nil);
    self.view.backgroundColor =  [OSSVThemesColors col_F5F5F5];
    
    [self.view addSubview:self.tableView];
    [self makeConstraints];
    
    [self loadMessageData];
    [self requesData];
}


- (void)refreshRequest:(BOOL)refresh {
    if (self.viewModel.dataArray.count <= 0 || refresh) {
        [self.tableView.mj_header beginRefreshing];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - STLMsgActivityTableviewDelegate

- (void)didDeselectItem:(OSSVAdvsEventsModel *)OSSVAdvsEventsModel
{
    if (OSSVAdvsEventsModel.actionType == AdvEventTypeOrderDetail)
    {
        OSSVAdvsEventsModel.actionType = AdvEventTypeMsgToOrderDetail;
    }
    
    //数据GA
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"message_action" parameters:@{
        @"screen_group":@"Message",
        @"action":[NSString stringWithFormat:@"view_%@",STLToString(self.typeModel.type)]}];
    
    [OSSVAdvsEventsManager advEventTarget:self withEventModel:OSSVAdvsEventsModel];
}


#pragma mark - private methods

- (void)requesData
{
    @weakify(self)
    self.tableView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        [self.viewModel requestNetwork:@{@"refreshOrLoadmore":STLLoadMore}
                            completion:^(NSArray *obj) {
                                @strongify(self)
                                self.tableView.dataArray = self.viewModel.dataArray;
                                [self.tableView updateData];
                                if (obj.count == 0 || obj.count < kSTLPageSize)
                                {
                                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                                    _tableView.mj_footer.hidden = NO;
                                }
                                else
                                {
                                    [self.tableView.mj_footer endRefreshing];
                                }
                            }
                               failure:^(id obj) {
                                   @strongify(self)
                                   [self.tableView.mj_footer endRefreshing];
                               }];
    }];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        [self.viewModel requestNetwork:@{@"refreshOrLoadmore":STLRefresh}
                            completion:^(NSArray *obj) {
                                @strongify(self)
            if (self.block)
            {
                self.block();
            }
                                
                                self.tableView.dataArray = self.viewModel.dataArray;
                                [self.tableView updateData];
                                if (self.tableView.dataArray.count <= 0) {
                                    [self.tableView showRequestTip:@{}];
                                    
                                } else if(obj.count < kSTLPageSize) {
                                    [self.tableView showRequestTip:@{kTotalPageKey  : @(1),
                                                                           kCurrentPageKey: @(1)}];
                                    
                                } else {
                                    [self.tableView showRequestTip:@{kTotalPageKey  : @(1),
                                                                           kCurrentPageKey: @(0)}];
                                }
                            }
                               failure:^(id obj) {
                                   @strongify(self)
                                   self.tableView.dataArray = self.viewModel.dataArray;
                                   [self.tableView updateData];
                                   [self.tableView showRequestTip:nil];

                               }];
    }];
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    
    self.tableView.mj_header = header;
}


- (void)loadMessageData
{
    @weakify(self)
    [self.viewModel requestNetwork:@{@"refreshOrLoadmore":STLRefresh}
                        completion:^(NSArray *obj) {
                            @strongify(self)
                            self.tableView.dataArray = self.viewModel.dataArray;
                            [self.tableView updateData];
                            if (self.block){
                                self.block();
                            }
        
                            if (self.tableView.dataArray.count <= 0) {
                                [self.tableView showRequestTip:@{}];
                                
                            } else if(obj.count < kSTLPageSize) {
                                [self.tableView showRequestTip:@{kTotalPageKey  : @(1),
                                                                       kCurrentPageKey: @(1)}];
                                
                            } else {
                                [self.tableView showRequestTip:@{kTotalPageKey  : @(1),
                                                                       kCurrentPageKey: @(0)}];
                            }

                        }
                           failure:^(id obj){
                            @strongify(self)
                            [self.tableView reloadData];
                            [self.tableView showRequestTip:nil];

                           }];
}

- (void)makeConstraints
{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}


#pragma mark - getters and setters

- (OSSVMessageActivityTableview *)tableView
{
    if (!_tableView)
    {
        _tableView = [[OSSVMessageActivityTableview alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.frame = self.view.bounds;
        _tableView.myDelegate = self;
        _tableView.emptyDataTitle    = STLLocalizedString_(@"messageNoMsgTip",nil);
        _tableView.blankPageImageViewTopDistance = 40;
        _tableView.emptyDataImage = [UIImage imageNamed:@"my_message_bank"];
    }
    return _tableView;
}

- (OSSVMessageActivityViewModel *)viewModel
{
    if (!_viewModel)
    {
        _viewModel = [[OSSVMessageActivityViewModel alloc] init];
    }
    return _viewModel;
}

@end
