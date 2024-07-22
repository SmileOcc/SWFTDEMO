
//
//  ZFCommunityFollowingViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityFollowingViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityFollowingCell.h"
#import "ZFCommunityFollowingViewModel.h"
#import "ZFCommunityAccountViewController.h"
#import "ZFCommunityFollowModel.h"
#import "ZFThemeManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"

static NSString *const kZFCommunityFollowingCellIdentifier = @"kZFCommunityFollowingCellIdentifier";

@interface ZFCommunityFollowingViewController () <ZFInitViewProtocol, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView                   *tableView;
@property (nonatomic, strong) ZFCommunityFollowingViewModel *viewModel;
@property (nonatomic, strong) NSMutableArray<ZFCommunityFollowModel*> *dataArray;
@end

@implementation ZFCommunityFollowingViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self zfInitView];
    [self zfAutoLayoutView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStatusChangeValue:) name:kFollowStatusChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private methods

/**
 * 请求分页数据
 */
- (void)requestFollowingPageData:(BOOL)isFirstPage {
    @weakify(self)
    [self.viewModel requestFollowingListData:isFirstPage completion:^(NSMutableArray *dataArray, NSDictionary *pageDic) {
        @strongify(self);
        self.dataArray = dataArray;
        [self.tableView reloadData];
        [self.tableView showRequestTip:pageDic];
        
    } failure:^(id obj) {
        @strongify(self);
        [self.tableView reloadData];
        [self.tableView showRequestTip:nil];
    }];
}

- (void)communityFollowUserWithModel:(ZFCommunityFollowModel *)model andIndexPath:(NSIndexPath *)indexPath{
    if (![AccountManager sharedManager].isSignIn) {
         @weakify(self);
        [self.navigationController judgePresentLoginVCCompletion:^{
            @strongify(self);
            [self.tableView.mj_header beginRefreshing];
        }];
        return ;
    }
    
    @weakify(self);
    NSDictionary *dic = @{kRequestModelKey : model,
                          kLoadingView : self.view};
    [self.viewModel requestFollowUserNetwork:dic completion:^(id obj) {
        @strongify(self);
        ZFCommunityFollowModel *model = self.dataArray[indexPath.row];
        self.dataArray[indexPath.row].isFollow = !model.isFollow;
        [self.tableView reloadData];
    } failure:^(id obj) {
        @strongify(self);
        [self.tableView reloadData];
    }];
}


#pragma mark - notification methods
- (void)followStatusChangeValue:(NSNotification *)noti {
    //接收通知传过来的两个值 dict[@"isFollow"],dict[@"userId"]
    NSDictionary *dict = noti.object;
    BOOL isFollow = [dict[@"isFollow"] boolValue];
    NSString *followedUserId = dict[@"userId"];
    // 当 FaversList 为空的时候，第一次去关注时自动刷新，避免手动刷新（球）
    if (self.dataArray.count == 0) {
        [self.tableView.mj_header beginRefreshing];
        return;
    }
    
    //遍历当前列表数组找到相同userId改变状态
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityFollowModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (isFollow == NO && [obj.userId isEqualToString:followedUserId]) {
            [self.dataArray removeObject:obj];
        }
        
        if (self.dataArray.count == 0){
            [self.tableView reloadData];
            [self.tableView showRequestTip:@{}];
        }
    }];
    [self.tableView reloadData];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityFollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFCommunityFollowingCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataArray[indexPath.row];
    @weakify(self);
    cell.communityFollowUserCompletionHandler = ^(ZFCommunityFollowModel *model) {
        @strongify(self);
        [self communityFollowUserWithModel:model andIndexPath:indexPath];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZFCommunityAccountViewController *accountVC = [[ZFCommunityAccountViewController alloc] init];
    accountVC.userId = self.dataArray[indexPath.row].userId;
    [self.navigationController pushViewController:accountVC animated:YES];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.title = ZFLocalizedString(@"Follow_VC_Title_Following",nil);
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - setter 
- (void)setUserId:(NSString *)userId {
    _userId = userId;
    self.viewModel.userId = _userId;
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - getter
- (ZFCommunityFollowingViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityFollowingViewModel alloc] init];
    }
    return _viewModel;
}

- (NSMutableArray<ZFCommunityFollowModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[ZFCommunityFollowingCell class] forCellReuseIdentifier:kZFCommunityFollowingCellIdentifier];
        
        _tableView.emptyDataImage = ZFImageWithName(@"blankPage_noImages");
        _tableView.emptyDataTitle = ZFLocalizedString(@"FollowViewModel_NoData_GetStatus",nil);
        
        @weakify(self);
        [_tableView addHeaderRefreshBlock:^{
            @strongify(self);
            [self requestFollowingPageData:YES];
            
        } footerRefreshBlock:^{
            @strongify(self);
            [self requestFollowingPageData:NO];
            
        } startRefreshing:YES];
    }
    return _tableView;
}

@end
