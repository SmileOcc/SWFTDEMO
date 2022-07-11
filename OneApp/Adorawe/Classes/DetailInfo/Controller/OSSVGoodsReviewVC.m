//
//  OSSVGoodsReviewVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVGoodsReviewVC.h"

//当前ViewController的ViewModel
#import "OSSVReviewsViewModel.h"

//视图
#import "OSSVReviewsHeaderView.h"
#import "OSSVDetailsReviewsCell.h"

@interface OSSVGoodsReviewVC ()

//展示框架控件
@property (nonatomic,weak) UITableView *tableView;

//当前ViewController的ViewModel
@property (nonatomic,strong) OSSVReviewsViewModel *viewModel;

@end

@implementation OSSVGoodsReviewVC

/*========================================分割线======================================*/

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"reviews",nil);
    
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
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    
    tableView.sectionFooterHeight = 10;
    
    tableView.backgroundColor = [UIColor clearColor];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorStyle = NO;
    
    [tableView registerClass:[OSSVDetailsReviewsCell class] forCellReuseIdentifier:NSStringFromClass(OSSVDetailsReviewsCell.class)];
//    [tableView registerClass:[OSSVReviewsHeaderView class] forCellReuseIdentifier:NSStringFromClass(OSSVReviewsHeaderView.class)];
    
    [tableView registerClass:[OSSVReviewsHeaderView class]  forHeaderFooterViewReuseIdentifier:NSStringFromClass(OSSVReviewsHeaderView.class)];
    
    tableView.dataSource = self.viewModel;
    tableView.delegate = self.viewModel;
    tableView.emptyDataSetDelegate = self.viewModel;
    tableView.emptyDataSetSource = self.viewModel;
    
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (kIS_IPHONEX) {
            make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(0, 12, STL_TABBAR_IPHONEX_H, 12));
        } else {
            make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(0, 12, 0, 12));
        }
    }];
    self.tableView = tableView;
}

/*========================================分割线======================================*/

#pragma mark - 请求评论数据
- (void)requesData {
    @weakify(self)
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self) //@[STLToString(self.sku),STLRefresh]
        [self.viewModel requestNetwork:@{@"sku":STLToString(self.sku),
                                         @"spu":STLToString(self.spu),
                                         @"goodsID":STLToString(self.goodsId),
                                         @"loadState":STLRefresh} completion:^(id obj) {
            @strongify(self)
            
            [self handelTitle];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        } failure:^(id obj) {
            @strongify(self)
            [self.tableView.mj_header endRefreshing];
        }];
    }];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
    
    self.tableView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        [self.viewModel requestNetwork:@{@"sku":STLToString(self.sku),
                                         @"spu":STLToString(self.spu),
                                         @"goodsID":STLToString(self.goodsId),
                                         @"loadState":STLLoadMore} completion:^(id obj) {
            @strongify(self)
            [self handelTitle];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
        } failure:^(id obj) {
            @strongify(self)
            [self.tableView.mj_footer endRefreshing];
        }];
    }];
    [self.tableView.mj_header beginRefreshing];
}

- (void)handelTitle {
    
    if (self.viewModel.reviewsModel && self.viewModel.reviewsModel.reviewCount > 0) {
        self.title = [NSString stringWithFormat:@"%@(%lu)",STLLocalizedString_(@"reviews",nil),(long)self.viewModel.reviewsModel.reviewCount];
    } else {
        self.title = STLLocalizedString_(@"reviews",nil);
    }
}
/*========================================分割线======================================*/

#pragma mark - SetModel Method
- (OSSVReviewsViewModel *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [OSSVReviewsViewModel new];
        _viewModel.controller = self;
        
        @weakify(self)
        _viewModel.emptyOperationBlock = ^{
            @strongify(self)
            [self.tableView.mj_header beginRefreshing];
        };
        
    }
    return _viewModel;
}

/*========================================分割线======================================*/

- (void)dealloc {
    
}

@end
