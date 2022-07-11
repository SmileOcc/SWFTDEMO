//
//  OSSVMessageSystemVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/22.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageSystemVC.h"
#import "OSSVMessageSystemDetailVC.h"

#import "OSSVMessageSystemTableView.h"

#import "OSSVMessageNotifyViewModel.h"
#import "OSSVAdvsEventsManager.h"

@interface OSSVMessageSystemVC ()<STLMessageSystemTableViewDelegate>

@property (nonatomic, strong) OSSVMessageSystemTableView        *systemTableView;
@property (nonatomic, strong) OSSVMessageNotifyViewModel        *viewModel;
/**只执行一次*/
@property (nonatomic, assign) BOOL                              hasBlock;
@end

@implementation OSSVMessageSystemVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = STLLocalizedString_(@"system_notification", nil);
    self.view.backgroundColor = [OSSVThemesColors col_F5F5F5];
    
    [self initView];
    [self requesData:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (void)refreshRequest:(BOOL)refresh {
    if (self.viewModel.dataArray.count <= 0 || refresh) {
        self.hasBlock = NO;
        [self.systemTableView.mj_header beginRefreshing];
    }
}

- (void)initView {
    
    [self.view addSubview:self.systemTableView];
    [self.systemTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (void)requesData:(BOOL)isMore {
    
    NSString *loadMore = isMore ? STLLoadMore : STLRefresh;
    @weakify(self)
    [self.viewModel requestNetwork:@{@"type":@(4),@"refreshOrLoadmore":loadMore}
                        completion:^(NSArray *obj) {
                            @strongify(self)
        
                            self.systemTableView.dataArray = self.viewModel.dataArray;


                            [self.systemTableView updateData];
        
                            if (self.systemTableView.dataArray.count <= 0) {
                                [self.systemTableView showRequestTip:@{}];
                                
                            } else if(obj.count < kSTLPageSize) {
                                [self.systemTableView showRequestTip:@{kTotalPageKey  : @(1),
                                                                       kCurrentPageKey: @(1)}];
                                
                            } else {
                                [self.systemTableView showRequestTip:@{kTotalPageKey  : @(1),
                                                                       kCurrentPageKey: @(0)}];
                            }

                            
                            if (self.block && !self.hasBlock) {
                                self.hasBlock = YES;
                                self.block();
                            }
        
                            
                        }
                           failure:^(id obj) {
                               @strongify(self)
                                [self.systemTableView showRequestTip:nil];
                           }];
}



- (void)didDeselectItem:(OSSVAdvsEventsModel*)OSSVAdvsEventsModel {
    
    //数据GA
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"message_action" parameters:@{
        @"screen_group":@"Message",
        @"action":[NSString stringWithFormat:@"view_%@",STLToString(self.typeModel.type)]}];
    [OSSVAdvsEventsManager advEventTarget:self withEventModel:OSSVAdvsEventsModel];
}
#pragma mark - LazyLoad

- (OSSVMessageNotifyViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVMessageNotifyViewModel alloc] init];
    }
    return _viewModel;
}

- (OSSVMessageSystemTableView *)systemTableView {
    if (!_systemTableView) {
        _systemTableView = [[OSSVMessageSystemTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _systemTableView.frame = self.view.bounds;
        _systemTableView.myDelegate = self;
        
        _systemTableView.emptyDataTitle    = STLLocalizedString_(@"messageNoMsgTip",nil);
        _systemTableView.blankPageImageViewTopDistance = 40;
        _systemTableView.emptyDataImage = [UIImage imageNamed:@"my_message_bank"];
        
        @weakify(self)
        _systemTableView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self requesData:YES];
    
        }];
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self)
            [self requesData:NO];
        }];
        // 隐藏时间
        header.lastUpdatedTimeLabel.hidden = YES;

        // 隐藏状态
        header.stateLabel.hidden = YES;
        
        _systemTableView.mj_header = header;
    }
    return _systemTableView;
}

@end
