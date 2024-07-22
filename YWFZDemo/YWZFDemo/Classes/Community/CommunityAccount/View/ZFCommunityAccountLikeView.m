
//
//  ZFCommunityAccountLikeView.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityAccountLikeView.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityAccountLikesCell.h"
#import "ZFCommunityLikesViewModel.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ZFCommunityAccountLikesListModel.h"
#import "ZFCommunityAccountLikesModel.h"
#import "ZFCommunityStyleLikesModel.h"
#import "ZFThemeManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "Masonry.h"
#import "Constants.h"

static NSString *const kZFCommunityAccountLikesCellIdentifier = @"kZFCommunityAccountLikesCellIdentifier";

@interface ZFCommunityAccountLikeView () <ZFInitViewProtocol, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView                   *tableView;
@property (nonatomic, strong) ZFCommunityLikesViewModel     *viewModel;
@property (nonatomic, strong) ZFCommunityAccountLikesListModel  *likeListModel;
@property (nonatomic, strong) NSMutableArray<ZFCommunityAccountLikesModel *> *dataArray;

@end

@implementation ZFCommunityAccountLikeView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
       
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStatusChangeValue:) name:kFollowStatusChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStatusChangeValue:) name:kLikeStatusChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviewCountsChangeValue:) name:kReviewCountsChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteChangeValue:) name:kDeleteStatusChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kChangeUserInfoNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutChangeValue:) name:kLogoutNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - notification methods
- (void)loginChangeValue:(NSNotification *)nofi {
    [self.tableView.mj_header beginRefreshing];
}

- (void)logoutChangeValue:(NSNotification *)nofi {
    [self.tableView.mj_header beginRefreshing];
}

- (void)deleteChangeValue:(NSNotification *)nofi {
    [self.tableView.mj_header beginRefreshing];
}

- (void)reviewCountsChangeValue:(NSNotification *)nofi {
    //接收通知传过来的model StyleLikesModel
    ZFCommunityAccountLikesModel *reviewsModel = nofi.object;
    //遍历当前列表数组找到相同reviewId增加评论数
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityAccountLikesModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityAccountLikesModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.reviewId isEqualToString:likesModel.reviewId]) {
            if (likesModel.isLiked) {
                obj.likeCount = [NSString stringWithFormat:@"%d", [obj.likeCount intValue]+1];
            }else{
                obj.likeCount = [NSString stringWithFormat:@"%d", [obj.likeCount intValue]-1];
            }
            obj.isLiked = likesModel.isLiked;
            *stop = YES;
        }
    }];
    [self.tableView reloadData];
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
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityAccountLikesModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:followedUserId]) {
            obj.isFollow = isFollow;
        }
    }];
    [self.tableView reloadData];
    
}


#pragma mark - private methods
- (void)communityAccountFollowUserWithModel:(ZFCommunityAccountLikesModel *)model andIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = @{kRequestModelKey : model,
                          kLoadingView : self.controller.view};

    if (![AccountManager sharedManager].isSignIn) {
//        @weakify(self);
        [self.controller.navigationController judgePresentLoginVCCompletion:^{
//            @strongify(self);
            [self.viewModel requestFollowNetwork:dic completion:^(id obj) {
//                @strongify(self);
//                ZFCommunityAccountLikesModel *model = self.dataArray[indexPath.row];
//                self.dataArray[indexPath.row].isFollow = !model.isFollow;
//                [self.tableView reloadData];
//                NSDictionary *dic = @{@"userId"   : model.userId,
//                                      @"isFollow" : @(self.dataArray[indexPath.row].isFollow)};
            } failure:^(id obj) {
                //[self.tableView reloadData];
            }];
        }];
        return;
    }
    
//    @weakify(self);
    [self.viewModel requestFollowNetwork:dic completion:^(id obj) {
//        @strongify(self);
//        ZFCommunityAccountLikesModel *model = self.dataArray[indexPath.row];
//        self.dataArray[indexPath.row].isFollow = !model.isFollow;
//        [self.tableView reloadData];
//        NSDictionary *dic = @{@"userId"   : model.userId,
//                              @"isFollow" : @(self.dataArray[indexPath.row].isFollow)};
        
    } failure:^(id obj) {
        //[self.tableView reloadData];
    }];
}

- (void)communityAccountLikesLikeOptionWithModel:(ZFCommunityAccountLikesModel *)model andIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = @{kRequestModelKey : model,
                          kLoadingView : self.controller.view};
    
    if (![AccountManager sharedManager].isSignIn) {
         @weakify(self);
        [self.controller.navigationController judgePresentLoginVCCompletion:^{
            @strongify(self);
            [self.viewModel requestLikeNetwork:dic completion:^(id obj) {
//                @strongify(self);
//                self.dataArray[indexPath.row].isLiked = !self.dataArray[indexPath.row].isLiked;
//                self.dataArray[indexPath.row].likeCount = [NSString stringWithFormat:@"%lu", [self.dataArray[indexPath.row].likeCount integerValue] + (self.dataArray[indexPath.row].isLiked ? 1 : -1)];
//                [self.tableView reloadData];
            } failure:^(id obj) {
//                @strongify(self);
//                [self.tableView reloadData];
            }];
        }];
        return ;
    }
    
//    @weakify(self);
    [self.viewModel requestLikeNetwork:dic completion:^(id obj) {
//        @strongify(self);
//        self.dataArray[indexPath.row].isLiked = !self.dataArray[indexPath.row].isLiked;
//        self.dataArray[indexPath.row].likeCount = [NSString stringWithFormat:@"%lu", [self.dataArray[indexPath.row].likeCount integerValue] + (self.dataArray[indexPath.row].isLiked ? 1 : -1)];
//        [self.tableView reloadData];
    } failure:^(id obj) {
//        @strongify(self);
//        [self.tableView reloadData];
    }];
}

- (void)communityAccountLikesReviewOptionWithModel:(ZFCommunityAccountLikesModel *)model {
    if (![AccountManager sharedManager].isSignIn) {
        [self.controller.navigationController judgePresentLoginVCCompletion:nil];
        return ;
    }
    if (self.communityAccountLikeDetailCompletionHandler) {
        self.communityAccountLikeDetailCompletionHandler(model.userId, model.reviewId);
    }
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZFCommunityAccountLikesModel *model = self.dataArray[indexPath.row];
    if (self.communityAccountLikeDetailCompletionHandler) {
        self.communityAccountLikeDetailCompletionHandler(model.userId, model.reviewId);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityAccountLikesCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFCommunityAccountLikesCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataArray[indexPath.row];
    @weakify(self);
    cell.communityAccountLikesTopicCompletionHandler = ^(NSString *topic) {
        @strongify(self);
        if (self.communityAccountLikeTopicCompletionHandler) {
            self.communityAccountLikeTopicCompletionHandler(topic);
        }
    };
    
    cell.communityAccountLikesShareCompletionHandler = ^(ZFCommunityAccountLikesModel *model) {
        @strongify(self);
        if (self.communityAccountLikeShareCompletionHandler) {
            self.communityAccountLikeShareCompletionHandler(model);
        }
    };
    
    cell.communityAccountLikeFollowUserCompletionHandler = ^(ZFCommunityAccountLikesModel *model) {
        @strongify(self);
        [self communityAccountFollowUserWithModel:model andIndexPath:indexPath];
    };
    
    cell.communityAccountLikesLikeCompletionHandler = ^(ZFCommunityAccountLikesModel *model) {
        @strongify(self);
        [self communityAccountLikesLikeOptionWithModel:model andIndexPath:indexPath];
    };
    
    cell.communityAccountLikesUserAccountCompletionHandler = ^(NSString *userId) {
        @strongify(self);
        if (self.communityAccountLikeUserAccountCompletionHandler) {
            self.communityAccountLikeUserAccountCompletionHandler(userId);
        }
    };
    
    cell.communityAccountLikesReviewCompletionHandler = ^{
        @strongify(self);
        [self communityAccountLikesReviewOptionWithModel:self.dataArray[indexPath.row]];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:kZFCommunityAccountLikesCellIdentifier configuration:^(ZFCommunityAccountLikesCell *cell) {
        cell.model = self.dataArray[indexPath.row];
    }];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - setter
- (void)setUserId:(NSString *)userId {
    _userId = userId;
    if (self.dataArray.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        return ;
    }
    [self tableView];
}

#pragma mark - getter
- (NSMutableArray<ZFCommunityAccountLikesModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (ZFCommunityLikesViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityLikesViewModel alloc] init];
    }
    return _viewModel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _tableView.contentInset = UIEdgeInsetsMake(35, 0, 44, 0);
        } else {
            _tableView.contentInset = UIEdgeInsetsMake(44, 0, 44, 0);
        }
        [_tableView registerClass:[ZFCommunityAccountLikesCell class] forCellReuseIdentifier:kZFCommunityAccountLikesCellIdentifier];
        
        _tableView.emptyDataTitle = ZFLocalizedString(@"LikesViewModel_NoData_NotLikes", nil);
        
        //添加刷新控件,请求数据
        @weakify(self);
        [_tableView addCommunityHeaderRefreshBlock:^{
            @strongify(self);
            [self requestCommunityAccountLikeData:YES];
            
        } footerRefreshBlock:^{
            @strongify(self);
            [self requestCommunityAccountLikeData:NO];
            
        } startRefreshing:YES];
    }
    return _tableView;
}

- (void)requestCommunityAccountLikeData:(BOOL)isFirstPage
{
    NSString *userId = self.userId ? :@"0";
    @weakify(self)
    [self.viewModel requestCommunityLikesPageData:isFirstPage userId:userId completion:^(NSArray *currentPageData, NSDictionary *pageInfo) {
        @strongify(self)
        
        if (isFirstPage) {
            [self.dataArray removeAllObjects];
        }
        [self.dataArray addObjectsFromArray:currentPageData];
        [self.tableView reloadData];
        [self.tableView showRequestTip:pageInfo];
    }];
}

@end
