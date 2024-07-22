//
//  ZFCommunitySearchCommonView.m
//  ZZZZZ
//
//  Created by YW on 2017/7/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunitySearchCommonView.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunitySearchInviteFriendsView.h"
#import "ZFCommunitySearchSuggestUsersListCell.h"
#import "ZFCommunitySearchViewModel.h"
#import "ZFCommunitySuggestedUsersModel.h"
#import "ZFThemeManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

//static NSString *const kZFCommunitySearchSuggestedUserHearderViewIdentifier = @"kZFCommunitySearchSuggestedUserHearderViewIdentifier";
static NSString *const kZFCommunitySearchSuggestUsersListCellIdentifier = @"kZFCommunitySearchSuggestUsersListCellIdentifier";


@interface ZFCommunitySearchCommonView () <ZFInitViewProtocol, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ZFCommunitySearchInviteFriendsView    *inviteFriendsView;
@property (nonatomic, strong) UITableView                           *recommonListView;
@property (nonatomic, strong) ZFCommunitySearchViewModel            *viewModel;

@property (nonatomic, strong) NSMutableArray<ZFCommunitySuggestedUsersModel *> *dataArray;
@end

@implementation ZFCommunitySearchCommonView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStatusChangeValue:) name:kFollowStatusChangeNotification object:nil];

        [self.recommonListView.mj_header beginRefreshing];
    }
    return self;
}

- (void)followStatusChangeValue:(NSNotification *)noti {
    //接收通知传过来的两个值 dict[@"isFollow"],dict[@"userId"]
    NSDictionary *dict = noti.object;
    BOOL isFollow = [dict[@"isFollow"] boolValue];
    NSString *followedUserId = dict[@"userId"];
    // 当 FaversList 为空的时候，第一次去关注时自动刷新，避免手动刷新（球）
    if (self.dataArray.count == 0) {
        return;
    }
    //遍历当前列表数组找到相同userId改变状态
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunitySuggestedUsersModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.user_id isEqualToString:followedUserId]) {
            obj.isFollow = isFollow;
        }
    }];
    [self.recommonListView reloadData];
}

#pragma mark - private methods
- (void)communitySuggestUserFollowUserWithModel:(ZFCommunitySuggestedUsersModel *)model andIndexPath:(NSIndexPath *)indexPath {
    
//    @weakify(self);
    NSDictionary *dic = @{kRequestUserIdKey : ZFToString(model.user_id),
                          kLoadingView : self};
    [self.viewModel requestFollowedNetwork:dic UserID:model.user_id Follow:model.isFollow completion:^(id obj) {
//        @strongify(self);
//        ZFCommunitySuggestedUsersModel *model = self.dataArray[indexPath.row];
//        self.dataArray[indexPath.row].isFollow = !model.isFollow;
//        [self.recommonListView reloadData];
    } failure:^(id obj) {
//        [self.recommonListView reloadData];
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
    ZFCommunitySearchSuggestUsersListCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                                   kZFCommunitySearchSuggestUsersListCellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataArray[indexPath.row];
    @weakify(self);
    cell.followUserCompletionHandler = ^(ZFCommunitySuggestedUsersModel *model) {
        @strongify(self);
        [self communitySuggestUserFollowUserWithModel:model andIndexPath:indexPath];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZFCommunitySuggestedUsersModel *model = self.dataArray[indexPath.row];
    if (self.communitySuggestedUserInfoCompletionHandler) {
        self.communitySuggestedUserInfoCompletionHandler(model.user_id);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 185;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    ZFCommunitySearchSuggestedUserHearderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kZFCommunitySearchSuggestedUserHearderViewIdentifier];
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR(244, 244, 244, 1.f);
    [self addSubview:self.inviteFriendsView];
    [self addSubview:self.recommonListView];
    [self addSubview:self.maskView];
}

- (void)zfAutoLayoutView {
    [self.inviteFriendsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(120 * ScreenWidth_SCALE);
    }];
    
    [self.recommonListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(120 * ScreenWidth_SCALE, 0, 0, 0));
    }];
}

#pragma mark - setter
- (void)setNoResultTips:(BOOL)noResultTips {
    _noResultTips = noResultTips;
//    self.noResultView.hidden = !_noResultTips;
    self.inviteFriendsView.hidden = _noResultTips;
}

#pragma mark - getter
- (ZFCommunitySearchViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunitySearchViewModel alloc] init];
    }
    return _viewModel;
}

- (ZFCommunitySearchInviteFriendsView *)inviteFriendsView {
    if (!_inviteFriendsView) {
        _inviteFriendsView = [[ZFCommunitySearchInviteFriendsView alloc] initWithFrame:CGRectZero];
        @weakify(self);
        _inviteFriendsView.inviteFacebookCompletionHandler = ^{
            @strongify(self);
            if (self.communityInviteFacebookCompletionHandler) {
                self.communityInviteFacebookCompletionHandler();
            }
        };
        
        _inviteFriendsView.inviteContactCompletionHandler = ^{
            @strongify(self);
            if (self.communityInviteContactsCompletionHandler) {
                self.communityInviteContactsCompletionHandler();
            }
        };
    }
    return _inviteFriendsView;
}

- (UITableView *)recommonListView {
    if (!_recommonListView) {
        _recommonListView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _recommonListView.backgroundColor = ZFC0xF2F2F2();
        _recommonListView.contentInset = UIEdgeInsetsMake(6, 0, 6, 0);
        _recommonListView.delegate = self;
        _recommonListView.dataSource = self;
        _recommonListView.showsVerticalScrollIndicator = YES;
        _recommonListView.showsHorizontalScrollIndicator = NO;
        _recommonListView.tableFooterView = [UIView new];
        _recommonListView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_recommonListView registerClass:[ZFCommunitySearchSuggestUsersListCell class] forCellReuseIdentifier:kZFCommunitySearchSuggestUsersListCellIdentifier];
        //[_recommonListView registerClass:[ZFCommunitySearchSuggestedUserHearderView class] forHeaderFooterViewReuseIdentifier:kZFCommunitySearchSuggestedUserHearderViewIdentifier];
        
        if (@available(iOS 11.0, *)) _recommonListView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
        @weakify(self);
        [_recommonListView addHeaderRefreshBlock:^{
            @strongify(self);
            [self requestTablepageData:YES];
            
        } footerRefreshBlock:^{
            @strongify(self);
            [self requestTablepageData:NO];
            
        } startRefreshing:NO];
    }
    return _recommonListView;
}

// 分页请求数据
- (void)requestTablepageData:(BOOL)isFirstData {
    
    @weakify(self);
    [self.viewModel requestCommonPageData:isFirstData completion:^(NSMutableArray *dataArray, NSDictionary *pageDic) {
        @strongify(self);
        self.dataArray = dataArray;
        [self.recommonListView reloadData];
        [self.recommonListView showRequestTip:pageDic];
        
    } failure:^(id obj) {
        @strongify(self);
        [self.recommonListView reloadData];
        [self.recommonListView showRequestTip:nil];
    }];
}

@end

