//
//  ZFCommunityPostListViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/8/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostListViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityPostListViewModel.h"
#import "ZFCommunityTopicListCell.h"
#import "ZFCommunityPostListModel.h"
#import "ZFCommunityPictureModel.h"
#import "ZFShare.h"
#import "ZFCommunityAccountViewController.h"
#import "ZFCommunityPostReplyViewController.h"
#import "ZFCommunityPostDetailPageVC.h"

#import "ZFCommunityStyleLikesModel.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"
#import "Constants.h"

static NSString *const kZFCommunityPostListViewController = @"kZFCommunityPostListViewController";

@interface ZFCommunityPostListViewController () <ZFInitViewProtocol, UITableViewDelegate, UITableViewDataSource,ZFShareViewDelegate>
@property (nonatomic, strong) UITableView                               *tableView;
@property (nonatomic, strong) ZFCommunityPostListViewModel             *viewModel;
@property (nonatomic, strong) NSMutableArray<ZFCommunityPostListModel *>   *dataArray;
@property (nonatomic, strong) ZFShareView                               *shareView;
@property (nonatomic, strong) ZFCommunityPostListModel                     *topicModel;
@end

@implementation ZFCommunityPostListViewController

#pragma mark - Life Cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_shareView) {
        [self.shareView removeFromSuperview];
        self.shareView.delegate = nil;
        self.shareView = nil;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self zfInitView];
    [self zfAutoLayoutView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStatusChangeValue:) name:kFollowStatusChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStatusChangeValue:) name:kLikeStatusChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviewCountsChangeValue:) name:kReviewCountsChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteChangeValue:) name:kDeleteStatusChangeNotification object:nil];
}


#pragma mark - notification methods
- (void)deleteChangeValue:(NSNotification *)nofi {
    [self.tableView.mj_header beginRefreshing];
}

- (void)reviewCountsChangeValue:(NSNotification *)nofi {
    //接收通知传过来的model StyleLikesModel
    ZFCommunityPostListModel *reviewsModel = nofi.object;
    //遍历当前列表数组找到相同reviewId增加评论数
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityPostListModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.reviewId isEqualToString:reviewsModel.reviewId]) {
            obj.replyCount = [NSString stringWithFormat:@"%d", [obj.replyCount intValue]+1];
        }
    }];
    [self.tableView reloadData];
}

- (void)likeStatusChangeValue:(NSNotification *)nofi {
    //接收通知传过来的model StyleLikesModel
    ZFCommunityStyleLikesModel *likesModel = nofi.object;
    //遍历当前列表数组找到相同reviewId改变点赞按钮状态并且增加或减少点赞数
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityPostListModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.reviewId isEqualToString:likesModel.reviewId]) {
            if (likesModel.isLiked) {
                obj.likeCount = [NSString stringWithFormat:@"%d", [obj.likeCount intValue]+1];
            }else{
                obj.likeCount = [NSString stringWithFormat:@"%d", [obj.likeCount intValue]-1];
            }
            obj.isLiked = likesModel.isLiked;
            *stop = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[reloadIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            });
        }
    }];
}

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
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityPostListModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:followedUserId]) {
            obj.isFollow = isFollow;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[reloadIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            });
        }
    }];
}

#pragma mark - private methods
- (void)jumpToTopicListViewControllerWithTitle:(NSString *)title {
    if ([title isEqualToString:self.topicTitle]) {
        return ;
    }
    self.topicTitle = title;
}

- (void)jumpToCommunityDetailViewControllerWithUserId:(NSString *)userId reviewsId:(NSString *)reviewsId {
    ZFCommunityPostDetailPageVC *detailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:reviewsId title:self.topicTitle];

    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)jumpToCommunityAccountViewControllerWithUserId:(NSString *)userId {
    ZFCommunityAccountViewController *accountVC = [[ZFCommunityAccountViewController alloc] init];
    accountVC.userId = userId;
    [self.navigationController pushViewController:accountVC animated:YES];
}

- (void)communityTopicListFollowUserWithModel:(ZFCommunityPostListModel *)model andIndexPath:(NSIndexPath *)indexPath {
    if (![AccountManager sharedManager].isSignIn) {
        [self judgePresentLoginVCCompletion:nil];
        return ;
    }
    NSDictionary *dic = @{kRequestModelKey : model,
                          kLoadingView : self.view};
//    @weakify(self);
    [self.viewModel requestFollowNetwork:dic completion:^(id obj) {
//        @strongify(self);
//        self.dataArray[indexPath.row].isFollow = YES;
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(id obj) {
        //[self.tableView reloadData];
    }];
}

- (void)communityTopicListLikeOptionWithModel:(ZFCommunityPostListModel *)model andIndexPath:(NSIndexPath *)indexPath {
    if (![AccountManager sharedManager].isSignIn) {
        [self.navigationController  judgePresentLoginVCCompletion:nil];
        return ;
    }
    
    NSDictionary *dic = @{kRequestModelKey : model,
                          kLoadingView : self.view};
    
//    @weakify(self);
    [self.viewModel requestLikeNetwork:dic completion:^(id obj) {
//        @strongify(self);
//        self.dataArray[indexPath.row].isLiked = !self.dataArray[indexPath.row].isLiked;
//        self.dataArray[indexPath.row].likeCount = [NSString stringWithFormat:@"%lu", [self.dataArray[indexPath.row].likeCount integerValue] + (self.dataArray[indexPath.row].isLiked ? 1 : -1)];
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(id obj) {
//        @strongify(self);
//        [self.tableView reloadData];
    }];
}

- (void)communityTopicListReviewOptionWithModel:(ZFCommunityPostListModel *)model {
    if (![AccountManager sharedManager].isSignIn) {
        [self judgePresentLoginVCCompletion:nil];
        return ;
    }
    
    ZFCommunityPostReplyViewController *replyCtrl = [[ZFCommunityPostReplyViewController alloc] initWithReviewID:ZFToString(model.reviewId)];
    [self.navigationController pushViewController:replyCtrl animated:YES];
}

- (ZFShareTopView *)configureZFShareTopViewWithModel:(ZFCommunityPostListModel *)model {
    ZFCommunityPictureModel *imageModel = (ZFCommunityPictureModel *)model.reviewPic.firstObject;
    ZFShareTopView *shareTopView = [[ZFShareTopView alloc] init];
    [shareTopView updateImage:imageModel.bigPic
                        title:model.content
                      tipType:ZFShareDefaultTipTypeCommon];
    return shareTopView;
}

- (NativeShareModel *)adjustNativeShareModel {
    NativeShareModel *model = [[NativeShareModel alloc] init];
    NSString *nicknameStr = [NSString stringWithFormat:@"%@",self.topicModel.nickname];
    NSRange range = [nicknameStr rangeOfString:@" "];
    if (range.location != NSNotFound) {
        //有空格
        nicknameStr = [nicknameStr stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    }
    
    NSString *appCommunityShareURL = [YWLocalHostManager appCommunityShareURL];
    model.share_url =  [NSString stringWithFormat:@"%@?actiontype=6&url=2,%@,%@&name=%@&source=sharelink&lang=%@",appCommunityShareURL,self.topicModel.reviewId,self.topicModel.userId,nicknameStr, [ZFLocalizationString shareLocalizable].nomarLocalizable];
    model.fromviewController = self;
    return model;
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityTopicListCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFCommunityPostListViewController forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataArray[indexPath.row];
    @weakify(self);
    cell.communityTopicListTopicCompletionHandler = ^(NSString *topic) {
        @strongify(self);
        [self jumpToTopicListViewControllerWithTitle:topic];
    };
    
    cell.communityTopicListFollowCompletionHandler = ^(ZFCommunityPostListModel *model) {
        @strongify(self);
        [self communityTopicListFollowUserWithModel:model andIndexPath:indexPath];
    };
    
    cell.communityTopicListLikeCompletionHandler = ^(ZFCommunityPostListModel *model) {
        @strongify(self);
        [self communityTopicListLikeOptionWithModel:model andIndexPath:indexPath];
    };
    
    cell.communityTopicListShareCompletionHandler = ^(ZFCommunityPostListModel *model) {
        @strongify(self);
        self.topicModel = model;
        self.shareView.topView = [self configureZFShareTopViewWithModel:model];
        [self.shareView open];
    };
    
    cell.communityTopicListAccountCompletionHandler = ^(ZFCommunityPostListModel *model) {
        @strongify(self);
        [self jumpToCommunityAccountViewControllerWithUserId:model.userId];
    };
    
    cell.communityTopicListReviewCompletionHandler = ^{
        @strongify(self);
        [self communityTopicListReviewOptionWithModel:self.dataArray[indexPath.row]];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:kZFCommunityPostListViewController configuration:^(ZFCommunityTopicListCell *cell) {
        cell.model = self.dataArray[indexPath.row];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZFCommunityPostListModel *model = self.dataArray[indexPath.row];
    [self jumpToCommunityDetailViewControllerWithUserId:model.userId reviewsId:model.reviewId];
    
    //增加AppsFlyer统计
    NSDictionary *appsflyerParams = @{@"af_postid" : ZFToString(model.reviewId),
                                      @"af_post_channel" : @"",
                                      @"af_post_type" : @"normal",
                                      @"af_post_userid" : ZFToString(model.userId),
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"community_topic_list",    // 当前页面名称
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_post_click" withValues:appsflyerParams];
}

#pragma mark - ZFShareViewDelegate
- (void)zfShsreView:(ZFShareView *)shareView didSelectItemAtIndex:(NSUInteger)index {
    [ZFShareManager shareManager].model = [self adjustNativeShareModel];
    [ZFShareManager shareManager].model.share_imageURL = shareView.topView.imageName;
    [ZFShareManager shareManager].model.share_description = shareView.topView.title;
    [ZFShareManager shareManager].model.sharePageType = ZFSharePage_CommunityTopicsDetailListType;
    [ZFShareManager shareManager].currentShareType = index;
    switch (index) {
        case ZFShareTypeWhatsApp: {
            [[ZFShareManager shareManager] shareToWhatsApp];
        }
            break;
        case ZFShareTypeFacebook:
        {
            [[ZFShareManager shareManager] shareToFacebook];
        }
            break;
        case ZFShareTypeMessenger:
        {
            [[ZFShareManager shareManager] shareToMessenger];
        }
            break;
        case ZFShareTypePinterest: {
            [[ZFShareManager shareManager] shareToPinterest];
        }
            break;
        case ZFShareTypeCopy:
        {
            [[ZFShareManager shareManager] copyLinkURL];
        }
            break;
        case ZFShareTypeMore: {
            [[ZFShareManager shareManager] shareToMore];
        }
            break;
        case ZFShareTypeVKontakte: {
            [[ZFShareManager shareManager] shareVKontakte];
        }
            break;
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - getter/setter
- (void)setTopicTitle:(NSString *)topicTitle {
    _topicTitle = topicTitle;
    self.title = _topicTitle;
    [self.tableView.mj_header beginRefreshing];
}


- (ZFCommunityPostListViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityPostListViewModel alloc] init];
    }
    return _viewModel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ZFCommunityTopicListCell class] forCellReuseIdentifier:kZFCommunityPostListViewController];
        _tableView.emptyDataImage = ZFImageWithName(@"blankPage_noMeaagess");
        _tableView.emptyDataTitle = @"No data";
        
        @weakify(self);
        ZFRefreshHeader *header = [ZFRefreshHeader headerWithRefreshingBlock:^{
            
            @strongify(self);
            self.tableView.mj_footer.hidden = YES;
            [self.viewModel requestTopicListData:@[Refresh, self.topicTitle] completion:^(id obj, NSDictionary *pageDic) {
                @strongify(self);
                self.dataArray = obj;
                [self.tableView reloadData];
                [self.tableView showRequestTip:pageDic];
                
            } failure:^(id obj) {
                [self.tableView reloadData];
                [self.tableView showRequestTip:nil];
            }];
        }];
        [self.tableView setMj_header:header];
        
        ZFRefreshFooter *footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
            @strongify(self);
            [self.viewModel requestTopicListData:@[LoadMore, self.topicTitle] completion:^(id obj, NSDictionary *pageDic) {
                @strongify(self);
                if (![obj isEqual:NoMoreToLoad]) {
                    self.dataArray = obj;
                }
                [self.tableView reloadData];
                [self.tableView showRequestTip:pageDic];
                
            } failure:^(id obj) {
                [self.tableView reloadData];
                [self.tableView showRequestTip:nil];
            }];
        }];
        [self.tableView setMj_footer:footer];
        footer.hidden = YES;
    }
    return _tableView;
}

- (ZFShareView *)shareView {
    if (!_shareView) {
        _shareView = [[ZFShareView alloc] init];
        _shareView.delegate = self;
        [ZFShareManager authenticatePinterest];
    }
    return _shareView;
}

@end
