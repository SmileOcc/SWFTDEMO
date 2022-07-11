//
//  OSSVWishListVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVWishListVC.h"
#import "OSSVWishListsTableCell.h"
#import "OSSVWishLitsViewModel.h"
#import "OSSVCartVC.h"
#import "UIButton+STLCategory.h"
#import "JSBadgeView.h"

@interface OSSVWishListVC ()

@property (nonatomic, strong) UITableView         *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *actView;
@property (nonatomic, strong) OSSVWishLitsViewModel   *viewModel;

@property (nonatomic,weak) UIButton *rightButton;
@property (nonatomic, strong) JSBadgeView                   *badgeView;  //购物车数字
@end

@implementation OSSVWishListVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.firstEnter) {
        self.firstEnter = YES;
    }
    
    [self requestDataLoadMore:NO isShowLoad:YES];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = STLLocalizedString_(@"My_WishList", nil);
    [self initSubViews];
    
    @weakify(self)
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self requestDataLoadMore:NO isShowLoad:NO];
    }];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
    
    self.tableView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self requestDataLoadMore:YES isShowLoad:NO];
        
    }];
    
    
    [self showCartCount];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBagValues) name:kNotif_CartBadge object:nil];
}

- (void)requestDataLoadMore:(BOOL)isLoadMore isShowLoad:(BOOL)isShowLoad{
    
    if (isLoadMore) {
        @weakify(self)
        [self.viewModel requestNetwork:nil completion:^(id obj) {
            @strongify(self)
            [self showLoading:NO];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
        } failure:^(id obj) {
            @strongify(self)
            [self showLoading:NO];
            [self.tableView.mj_footer endRefreshing];
        }];
    } else {
        
        if (STLJudgeNSArray(self.viewModel.dataArray) && self.viewModel.dataArray.count > 0) {
        } else {
            [self showLoading:YES];
        }
        @weakify(self)
        [self.viewModel requestNetwork:nil completion:^(id obj) {
            @strongify(self)
            [self showLoading:NO];
            [self.tableView reloadData];
            [self.tableView showRequestTip:@{kTotalPageKey  : @(1),
                                                 kCurrentPageKey: @(0)}];
        } failure:^(id obj) {
            @strongify(self)
            [self showLoading:NO];
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

#pragma mark - Method
#pragma mark - Delegate
#pragma mark - MakeUI
- (void)initSubViews {
    self.view.backgroundColor = OSSVThemesColors.col_F5F5F5;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.bounds = self.view.bounds;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self.viewModel;
    self.tableView.delegate = self.viewModel;
    [self.tableView registerClass:[OSSVWishListsTableCell class] forCellReuseIdentifier:NSStringFromClass(OSSVWishListsTableCell.class)];
    self.tableView.backgroundColor = OSSVThemesColors.col_F5F5F5;
    [self.view addSubview:self.tableView];
    if (APP_TYPE == 3) {
        self.tableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0);
    } else {
        self.tableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
    }

    self.tableView.blankPageImageViewTopDistance = 40;
    self.tableView.emptyDataTitle    = STLLocalizedString_(@"WishList_NoData_titleLabel",nil);
    self.tableView.emptyDataImage = [UIImage imageNamed:@"wishlist_bank"];
    self.tableView.emptyDataBtnTitle = STLLocalizedString_(@"go_shopping",nil);
    @weakify(self)
    self.tableView.blankPageViewActionBlcok = ^(STLBlankPageViewStatus status) {
        @strongify(self)
        OSSVAdvsEventsModel *model = [[OSSVAdvsEventsModel alloc] init];
        model.actionType = 0;
        [OSSVAdvsEventsManager advEventTarget:self withEventModel:model];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    };
    
        
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 8, 0));
    }];
    
    UIButton *rightButton = [[UIButton alloc] init];
    _rightButton = rightButton;
    [_rightButton setImage:[UIImage imageNamed:@"bag_new"] forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(actionCart) forControlEvents:UIControlEventTouchUpInside];
    _rightButton.imageView.contentMode = UIViewContentModeCenter;
    [_rightButton setEnlargeEdge:10];
    _rightButton.sensor_element_id = @"to_card_button";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

#pragma mark - LazyLoad
- (OSSVWishLitsViewModel *)viewModel {
    if(!_viewModel) {
        _viewModel = [[OSSVWishLitsViewModel alloc] init];
        _viewModel.controller = self;
        @weakify(self)
        _viewModel.swipeCallback = ^(MGSwipeTableCell *cell) {
            @strongify(self)
            return [self.tableView indexPathForCell:cell];
        };
        
        _viewModel.completeExecuteBlock = ^{
            @strongify(self)
            [self requestDataLoadMore:NO isShowLoad:YES];
        };
    }
    return _viewModel;
}

- (void)actionCart {
    OSSVCartVC *cartVC = nil;
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    NSInteger index = 0;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:OSSVCartVC.class] && index != 0) {
            cartVC = (OSSVCartVC*)vc;
            break;
        }
        index++;
    }
    if (cartVC) {
        [arr removeObject:cartVC];
        [self.navigationController setViewControllers:arr animated:YES];
    }
    if (!cartVC) {
        cartVC = [[OSSVCartVC alloc] init];
    }
    [self.navigationController pushViewController:cartVC animated:YES];
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
           @"screen_group":@"WishList",
           @"button_name":@"Cart"}];
}


- (JSBadgeView *)badgeView {
    if (!_badgeView) {
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            // 阿语
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.rightButton alignment:JSBadgeViewAlignmentTopLeft];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(0), 5);
        }else{
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.rightButton alignment:JSBadgeViewAlignmentTopRight];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(16), -10);
        }
        
        _badgeView.userInteractionEnabled = NO;
        _badgeView.badgeBackgroundColor = [OSSVThemesColors col_B62B21];
        _badgeView.badgeTextFont = [UIFont systemFontOfSize:9];
        _badgeView.badgeStrokeColor = [OSSVThemesColors stlWhiteColor];
        _badgeView.badgeStrokeWidth = 1.0;

    }
    return _badgeView;
}

- (void)refreshBagValues {
    [self showCartCount];
}

- (void)showCartCount {
    NSInteger allGoodsCount = [[OSSVCartsOperateManager sharedManager] cartValidGoodsAllCount];
    self.badgeView.badgeText = nil;
    if (allGoodsCount > 0) {
        self.badgeView.badgeText = [NSString stringWithFormat:@"%lu",(unsigned long)allGoodsCount];
        if (allGoodsCount > 99) {
            allGoodsCount = 99;
            self.badgeView.badgeText = [NSString stringWithFormat:@"%lu+",(unsigned long)allGoodsCount];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBagValues) name:kNotif_CartBadge object:nil];
}

@end
