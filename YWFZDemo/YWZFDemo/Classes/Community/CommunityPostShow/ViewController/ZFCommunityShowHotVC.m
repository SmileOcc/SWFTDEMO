//
//  ZFCommunityShowHotVC.m
//  ZZZZZ
//
//  Created by YW on 2018/9/11.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityShowHotVC.h"
#import "ZFCommunityShowHotViewModel.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Constants.h"

@interface ZFCommunityShowHotVC ()

@property (nonatomic,strong) ZFCommunityShowHotViewModel      *viewModel;
@property (nonatomic,strong) UITableView                      *goodsTableView;

@end

@implementation ZFCommunityShowHotVC

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
        [self requestPageData:[Refresh boolValue]];
    }];
    [self.goodsTableView setMj_header:header];
    
    ZFRefreshFooter *footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self requestPageData:[LoadMore boolValue]];
    }];
    [self.goodsTableView setMj_footer:footer];
    self.goodsTableView.mj_footer.hidden = YES;
    [self.goodsTableView.mj_header beginRefreshing];
}

- (void)requestPageData:(BOOL)firstPage {
    @weakify(self)
    [self.viewModel requestPageData:firstPage completion:^(NSDictionary *pageInfo) {
        @strongify(self)
        [self.goodsTableView reloadData];
        [self.goodsTableView showRequestTip:pageInfo];
    }];
}

#pragma mark - Setter/Getter
-(ZFCommunityShowHotViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityShowHotViewModel alloc] init];
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
        _goodsTableView.emptyDataImage = [UIImage imageNamed:@"blankPage_noCart"];
        _goodsTableView.emptyDataTitle = ZFLocalizedString(@"EmptyCustomViewHasNoData_titleLabel",nil);
    }
    return _goodsTableView;
}
@end
