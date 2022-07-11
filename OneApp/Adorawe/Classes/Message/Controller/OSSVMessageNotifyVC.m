//
//  OSSVMessageNotifyVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//


#import "OSSVAdvsEventsManager.h"
#import "OSSVMessageNotifyTableview.h"
#import "OSSVMessageNotifyVC.h"

@interface OSSVMessageNotifyVC ()<STLMessageNotifyTableviewDelegate>

@property (nonatomic, strong) OSSVMessageNotifyTableview *tableView;

@end

@implementation OSSVMessageNotifyVC

#pragma  mark life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.type == STLMessageTypeNotify)
    {
        self.title = STLLocalizedString_(@"messageNotify",nil);
    }
    else
    {
        self.title = STLLocalizedString_(@"messageOrder",nil);
    }
    
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

#pragma mark - STLMsgNotifyTableviewDelegate

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

- (void)makeConstraints
{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)requesData
{
    @weakify(self)
    self.tableView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        [self.viewModel requestNetwork:@{@"type":@(_type),@"refreshOrLoadmore":STLLoadMore}
                            completion:^(NSArray *obj) {
                                @strongify(self)
                                self.tableView.dataArray = self.viewModel.dataArray;
                                [self.tableView updateData];
                                if(obj.count == 0 || obj.count < kSTLPageSize)
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
        [self.viewModel requestNetwork:@{@"type":@(_type),@"refreshOrLoadmore":STLRefresh}
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
    [self.viewModel requestNetwork:@{@"type":@(_type),@"refreshOrLoadmore":STLRefresh}
                        completion:^(NSArray *obj) {
                            @strongify(self)
                            self.tableView.dataArray = self.viewModel.dataArray;
                            [self.tableView updateData];
                            if (self.block)
                            {
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
                            [self.tableView showRequestTip:nil];
                           }];
}


#pragma mark - setters and getters

- (OSSVMessageNotifyViewModel *)viewModel
{
    if (!_viewModel)
    {
        _viewModel = [[OSSVMessageNotifyViewModel alloc] init];
    }
    return _viewModel;
}

- (OSSVMessageNotifyTableview *)tableView
{
    if (!_tableView)
    {
        _tableView = [[OSSVMessageNotifyTableview alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.frame = self.view.bounds;
        _tableView.myDelegate = self;
        _tableView.emptyDataTitle    = STLLocalizedString_(@"messageNoMsgTip",nil);
        _tableView.blankPageImageViewTopDistance = 40;
        _tableView.emptyDataImage = [UIImage imageNamed:@"my_message_bank"];
    }
    return _tableView;
}

@end
