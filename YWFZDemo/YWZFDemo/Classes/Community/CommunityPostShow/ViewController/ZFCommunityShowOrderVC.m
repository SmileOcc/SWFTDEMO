//
//  ZFCommunityShowOrderVC.m
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityShowOrderVC.h"
#import "ZFCommunityPostShowOrderViewModel.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Constants.h"

@interface ZFCommunityShowOrderVC ()
@property (nonatomic,strong) UITableView *goodsTableView;
@property (nonatomic,strong) ZFCommunityPostShowOrderViewModel *viewModel;
@end

@implementation ZFCommunityShowOrderVC

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.goodsTableView];
    [self requestNetWorkGoods];
}

- (void)requestNetWorkGoods {
    @weakify(self)
    ZFRefreshHeader *header = [ZFRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self requstRefreshNetworkWith:Refresh];
    }];
    [self.goodsTableView setMj_header:header];
    
    ZFRefreshFooter *footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self requstRefreshNetworkWith:LoadMore];
    }];
    [self.goodsTableView setMj_footer:footer];
    self.goodsTableView.mj_footer.hidden = YES;
    [self.goodsTableView.mj_header beginRefreshing];
}

- (void)requstRefreshNetworkWith:(NSString *)refresh {
    @weakify(self)
    [self.viewModel requestOrderNetwork:refresh completion:^(NSDictionary *pageDic) {
        @strongify(self)
        [self.goodsTableView reloadData];
        [self.goodsTableView showRequestTip:pageDic];
    }];
}

#pragma mark - Setter/Getter
-(ZFCommunityPostShowOrderViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityPostShowOrderViewModel alloc] init];
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
        _goodsTableView.emptyDataImage = [UIImage imageNamed:@"blank_list"];
        _goodsTableView.emptyDataTitle = ZFLocalizedString(@"MyOrdersViewModel_NoData_Tip",nil);
    }
    return _goodsTableView;
}



@end
