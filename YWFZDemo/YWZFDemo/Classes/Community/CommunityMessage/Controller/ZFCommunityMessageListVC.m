
//
//  ZFCommunityMessageViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityMessageListVC.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityMessageListCell.h"
#import "ZFCommunityMessageViewModel.h"
#import "ZFCommunityAccountViewController.h"
#import "ZFCommunityMessageModel.h"
#import "ZFCommunityPostReplyViewController.h"
#import "ZFCommunityPostDetailPageVC.h"
#import "ZFCommunityTopicDetailPageViewController.h"

#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

static NSString *const kZFCommunityMessageListCellIdentifier = @"kZFCommunityMessageListCellIdentifier";

@interface ZFCommunityMessageListVC () <ZFInitViewProtocol, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView                   *tableView;
@property (nonatomic, strong) ZFCommunityMessageViewModel   *viewModel;
@property (nonatomic, strong) NSMutableArray<ZFCommunityMessageModel *>  *dataArray;
@end

@implementation ZFCommunityMessageListVC

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self zfInitView];
    [self zfAutoLayoutView];
    //设置刷新控件
    [self addTableViewRefreshKit];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.title = ZFLocalizedString(@"MessagesViewModel_title", nil);
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, kiphoneXHomeBarHeight, 0));
    }];
}


#pragma mark - private methods

/**
 * 设置表格刷新控件
 */
- (void)addTableViewRefreshKit
{
    @weakify(self);
    [self.tableView addCommunityHeaderRefreshBlock:^{
        @strongify(self);
        [self requestListPageData:YES];
        
    } footerRefreshBlock:^{
        @strongify(self);
        [self requestListPageData:NO];
        
    } startRefreshing:YES];
}

/**
 * 请求消息列表页面数据
 */
- (void)requestListPageData:(BOOL)isFirstPage
{
    NSString *pageFlag = isFirstPage ? Refresh : LoadMore;
    @weakify(self);
    [self.viewModel requestMessageListData:@[pageFlag] completion:^(id obj, NSDictionary *pageDic) {
        @strongify(self);
        
        if (isFirstPage) {
            if (!self.alreadyEnter && self.hasReadmsgCountBlock) {
                self.alreadyEnter = YES;
                self.hasReadmsgCountBlock();
            }
            self.dataArray = obj;
            
        } else {
            if(![obj isEqual: NoMoreToLoad]) {
                self.dataArray = obj;
            }
        }
        [self.tableView reloadData];
        [self.tableView showRequestTip:pageDic];
        
    } failure:^(id obj) {
        @strongify(self);
        [self.tableView reloadData];
        [self.tableView showRequestTip:nil];
    }];
}

- (void)jumpToMessageUserInfo:(ZFCommunityMessageModel *)model {
    ZFCommunityAccountViewController *accountVC = [[ZFCommunityAccountViewController alloc] init];
    accountVC.userName = ZFToString(model.nickname);
    accountVC.userId = ZFToString(model.user_id);
    [self.navigationController pushViewController:accountVC animated:YES];
}

- (void)followMessageUser:(ZFCommunityMessageModel *)model andIndexPath:(NSIndexPath *)indexPath{
    @weakify(self);
    NSDictionary *dic = @{kRequestUserIdKey : ZFToString(model.user_id),
                          kLoadingView : self.view};
    [self.viewModel requestFollowedNetwork:dic completion:^(id obj) {
        @strongify(self);
        self.dataArray[indexPath.row].isFollow = !self.dataArray[indexPath.row].isFollow;
        [self.tableView reloadData];
        NSDictionary *dic = @{@"userId"   : ZFToString(model.user_id),
                              @"isFollow" : @(self.dataArray[indexPath.row].isFollow)};
        [[NSNotificationCenter defaultCenter] postNotificationName:kFollowStatusChangeNotification object:dic];
    } failure:^(id obj) {
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
    ZFCommunityMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFCommunityMessageListCellIdentifier];
    if (self.dataArray.count > indexPath.row) {
        cell.model = self.dataArray[indexPath.row];
    }
    @weakify(self);
    cell.communityMessageListFollowUserCompletionHandler = ^(ZFCommunityMessageModel *model) {
        @strongify(self);
        [self followMessageUser:model andIndexPath:indexPath];
    };
    
    cell.communityMessageAccountDetailCompletioinHandler = ^(ZFCommunityMessageModel *model) {
        @strongify(self);
        [self jumpToMessageUserInfo:model];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.dataArray.count > indexPath.row) {
        
        ZFCommunityMessageListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        ZFCommunityMessageModel *model = self.dataArray[indexPath.row];

        if (![model.is_read boolValue]) {
            model.is_read = @"1";
            [cell showReadMark:NO];
        }

        if (model.message_type == MessageListCommendTag) {
            //评论列表
            ZFCommunityPostReplyViewController *topicReplyVC = [[ZFCommunityPostReplyViewController  alloc] initWithReviewID:model.review_id];
            topicReplyVC.firstReviewModel = model.review_data;
            [self.navigationController pushViewController:topicReplyVC animated:YES];

        } else if (model.message_type == MessageListTypePost || model.message_type == MessageListTypeCollect) {
            //跳转对应社区详情。
            ZFCommunityPostDetailPageVC *detailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:model.review_id title:ZFLocalizedString(@"Community_Videos_DetailTitle",nil)];
            [self.navigationController pushViewController:detailViewController animated:YES];

        } else if (model.message_type == MessageListTypeCertified) {
            ZFCommunityMessageModel *selfUserModel = [[ZFCommunityMessageModel alloc] init];
            selfUserModel.nickname = [AccountManager sharedManager].userNickname;
            selfUserModel.user_id = [AccountManager sharedManager].userId;
            [self jumpToMessageUserInfo:selfUserModel];
        } else if(model.message_type == MessageListTypeJoinTopic) {

            ZFCommunityTopicDetailPageViewController *topicDetailController = [[ZFCommunityTopicDetailPageViewController alloc] init];
            topicDetailController.topicId = model.topic_id;
            topicDetailController.review_id = model.review_id;
            [self.navigationController pushViewController:topicDetailController animated:YES];

        } else {
            [self jumpToMessageUserInfo:model];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - getter
- (ZFCommunityMessageViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityMessageViewModel alloc] init];
    }
    return _viewModel;
}

- (NSMutableArray<ZFCommunityMessageModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = ZFCOLOR_WHITE;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[ZFCommunityMessageListCell class] forCellReuseIdentifier:kZFCommunityMessageListCellIdentifier];
        
        _tableView.emptyDataImage = ZFImageWithName(@"blankPage_noMeaagess");
        _tableView.emptyDataTitle = ZFLocalizedString(@"MessagesViewModel_NoData_Message",nil);
    }
    return _tableView;
}

@end
