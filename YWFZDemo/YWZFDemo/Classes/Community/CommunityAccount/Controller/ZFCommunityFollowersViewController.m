

//
//  ZFCommunityFollowersViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityFollowersViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityFollowersCell.h"
#import "ZFCommunityFollowersViewModel.h"
#import "ZFCommunityAccountViewController.h"
#import "ZFCommunityFollowModel.h"
#import "ZFThemeManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"

static NSString *const kZFCommunityFollowersCellIdentifier = @"kZFCommunityFollowersCellIdentifier";

@interface ZFCommunityFollowersViewController () <ZFInitViewProtocol, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView                   *tableView;
@property (nonatomic, strong) ZFCommunityFollowersViewModel *viewModel;

@property (nonatomic, strong) NSMutableArray<ZFCommunityFollowModel*> *dataArray;
@end

@implementation ZFCommunityFollowersViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self zfInitView];
    [self zfAutoLayoutView];
    [self addNotice];
}

- (void)addNotice{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStatusChangeValue:) name:kFollowStatusChangeNotification object:nil];
}

- (void)followStatusChangeValue:(NSNotification *)nofi{
    
    //接收通知传过来的两个值 dict[@"isFollow"],dict[@"userId"]
    NSDictionary *dict = nofi.object;
    BOOL isFollow = [dict[@"isFollow"] boolValue];
    NSString *followedUserId = dict[@"userId"];
    __block NSInteger index = -1;
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityFollowModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:followedUserId]) {
            obj.isFollow = isFollow;
            index = idx;
            *stop = YES;
        }
    }];
    if (index == -1) return;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - private methods
- (void)communityFollowUserWithModel:(ZFCommunityFollowModel *)model andIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic = @{kRequestModelKey : model,
                          kLoadingView : self.view};
    
    if (![AccountManager sharedManager].isSignIn) {
        @weakify(self);
        [self.navigationController judgePresentLoginVCCompletion:^{
            @strongify(self);
            [self.viewModel requestFollowUserNetwork:dic completion:^(id obj) {
//                @strongify(self);
//                ZFCommunityFollowModel *model = self.dataArray[indexPath.row];
//                model.isFollow = !model.isFollow;
//                [self.tableView reloadData];
            } failure:^(id obj) {
                [self.tableView reloadData];
            }];
        }];
        return ;
    }
    
    @weakify(self);
    [self.viewModel requestFollowUserNetwork:dic completion:^(id obj) {
//        @strongify(self);
//        ZFCommunityFollowModel *model = self.dataArray[indexPath.row];
//        self.dataArray[indexPath.row].isFollow = !model.isFollow;
//        model.isFollow = !model.isFollow;
//        [self.tableView reloadData];
    } failure:^(id obj) {
        @strongify(self);
        [self.tableView reloadData];
    }];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityFollowersCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFCommunityFollowersCellIdentifier];
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
    self.title = ZFLocalizedString(@"Follow_VC_Title_Followers",nil);
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
- (ZFCommunityFollowersViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityFollowersViewModel alloc] init];
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
        [_tableView registerClass:[ZFCommunityFollowersCell class] forCellReuseIdentifier:kZFCommunityFollowersCellIdentifier];
        
        //请求空数据提示图片文案
        _tableView.emptyDataImage = ZFImageWithName(@"blankPage_noCare");
        _tableView.emptyDataTitle = ZFLocalizedString(@"FollowViewModel_NoData_AddPhotos",nil);
        
        
        @weakify(self);
        [_tableView addHeaderRefreshBlock:^{
            @strongify(self);
            [self.viewModel requestFollowersListData:Refresh completion:^(id obj, NSDictionary *pageDic) {
                @strongify(self);
                self.tableView.mj_footer.hidden = NO;
                self.dataArray = obj;
                [self.tableView reloadData];
                [self.tableView showRequestTip:pageDic];
                
            } failure:^(id obj) {
                @strongify(self);
                [self.tableView reloadData];
                [self.tableView showRequestTip:nil];
            }];
            
        } footerRefreshBlock:^{
            @strongify(self);
            [self.viewModel requestFollowersListData:LoadMore completion:^(id obj, NSDictionary *pageDic) {
                @strongify(self);
                if(![obj isEqual: NoMoreToLoad]) {
                    self.dataArray = obj;
                }
                self.tableView.mj_footer.hidden = YES;
                [self.tableView reloadData];
                [self.tableView showRequestTip:pageDic];
                
            } failure:^(id obj) {
                @strongify(self);
                [self.tableView reloadData];
                [self.tableView showRequestTip:nil];
            }];
            
        } startRefreshing:NO];
    }
    return _tableView;
}

@end
