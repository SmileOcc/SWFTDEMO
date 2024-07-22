//
//  ZFCommunityPostReplyViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/7/13.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityPostReplyViewController.h"
#import "ZFCommentPostReviewCommentViewModel.h"
#import "ZFCommunityPostReplyCommentCell.h"
#import "InputTextView.h"
#import "YWLoginViewController.h"
#import "ZFCommunityPostOperateViewModel.h"
#import "ZFActionSheetView.h"
#import "ZFInitViewProtocol.h"
#import "IQKeyboardManager.h"
#import "ZFCommunityPostDetailReviewsModel.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Constants.h"
#import "ZFBranchAnalytics.h"
#import "ZFThemeManager.h"
#import "Masonry.h"

#import "ZFCommunityAccountViewController.h"

@interface ZFCommunityPostReplyViewController () <UITableViewDelegate, UITableViewDataSource,ZFInitViewProtocol>

@property (nonatomic, copy) NSString                   *reviewID;
@property (nonatomic, strong) NSMutableDictionary      *replyDict;
@property (nonatomic, strong) UITableView              *replyTableView;
@property (nonatomic, strong) InputTextView            *inputTextView;/*评论输入框*/
@property (nonatomic, strong) UIView                   *iPhonexBottomView;
@property (nonatomic, strong) ZFCommentPostReviewCommentViewModel *viewModel;
@property (nonatomic, strong) ZFCommunityPostOperateViewModel *interfaceViewModel;
@property (nonatomic, strong) UIView                   *bottomeSpaceView;


@property (nonatomic, strong) NSMutableArray           *topListData;

@property (nonatomic, assign) CGFloat currentViewH;

@property (nonatomic, assign) BOOL isFirstRequest;



@end

@implementation ZFCommunityPostReplyViewController

- (instancetype)initWithReviewID:(NSString *)reviewID {
    if (self = [super init]) {
        self.reviewID  = reviewID;
        self.interfaceViewModel = [[ZFCommunityPostOperateViewModel alloc] init];
        self.viewModel = [[ZFCommentPostReviewCommentViewModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"community_topic_commenttitle", nil);
    [self zfInitView];
    [self zfAutoLayoutView];
    
    if (self.firstReviewModel) {
        [self.topListData addObject:self.firstReviewModel];
    }
    
    if (self.navigationController.viewControllers.firstObject == self) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"z-me_outfits_post_close"] forState:UIControlStateNormal];
        backButton.size = CGSizeMake(50, 45);
        [backButton addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barItem               = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem =  barItem;
    }
}

- (void)actionBack:(UIButton *)sender {
    
    NSArray *viewcontrollers=self.navigationController.viewControllers;
    if (viewcontrollers.count > 1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count - 1] == self){
            //push方式
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        //present方式
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    YWLog(@"---- %f ----- %f",CGRectGetHeight(self.view.frame),KScreenHeight);
    
    if (self.is_13PresentationAutomatic) {
        
        self.inputTextView.isIphone13Show = self.is_13PresentationAutomatic;
        if (self.currentViewH <= 0) {
            
            CGFloat showScreenHeight = CGRectGetHeight(self.view.frame) + kiphoneXTopOffsetY + 44;
            CGFloat screenHeight = CGRectGetHeight(self.view.frame);
            self.inputTextView.showScreenHeight = showScreenHeight;
            CGFloat inputOffsetY = screenHeight - 44.0 - kiphoneXHomeBarHeight;

            CGRect tableFrame = self.replyTableView.frame;
            tableFrame.size.height = inputOffsetY;
            self.replyTableView.frame = tableFrame;
                        
            CGRect inputTextFrame = self.inputTextView.frame;
            inputTextFrame.origin.y = CGRectGetHeight(self.replyTableView.frame);
            self.inputTextView.frame = inputTextFrame;
            
            self.currentViewH = CGRectGetHeight(self.view.frame);
        }
    }
    
    if (self.currentViewH <= 0) {
        self.currentViewH = CGRectGetHeight(self.view.frame);
    }
    if (self.isEditing) {
        self.isEditing = NO;
        self.inputTextView.hidden = NO;
        [self.inputTextView.textView becomeFirstResponder];
    }

    if (self.isFirstRequest) {
        [self.replyTableView.mj_header beginRefreshing];
    }
}

#pragma - <ZFInitViewProtocol>
- (void)zfInitView {
    self.view.backgroundColor = ZFC0xF2F2F2();
    self.currentViewH = 0;
    self.isFirstRequest = YES;

    
    [self.view addSubview:self.bottomeSpaceView];
    [self.view addSubview:self.replyTableView];
    [self.view addSubview:self.inputTextView];
    [self.view addSubview:self.iPhonexBottomView];
}

- (void)zfAutoLayoutView {
    
    [self.bottomeSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(kiphoneXHomeBarHeight + 49);
    }];
}

#pragma mark - request
- (void)requestCommentDatas {
    @weakify(self)
    [self.viewModel reviewCommentListRequesWithReviewID:self.reviewID withPageSize:0 complateHandle:^(BOOL success){
        @strongify(self)
        
        [self filterAddFirstReviewData];
        [self.replyTableView reloadData];
        self.inputTextView.hidden = NO;
        
        if (kiphoneXHomeBarHeight > 0) {
            self.bottomeSpaceView.hidden = NO;
        } else {
            self.bottomeSpaceView.hidden = YES;
        }
        if (success) {
            if (self.viewModel.replyModelArray.count <= 0 && !self.isEditing && self.isFirstRequest) {
                if (self.currentViewH > 100) {
                    [self.inputTextView.textView becomeFirstResponder];
                }
            }
        }
        self.isFirstRequest = NO;
        [self.replyTableView doBlankViewWithCurrentPage:@(self.viewModel.currentPage)
                                              totalPage:@(self.viewModel.totalPage)];
    }];
}

- (void)filterAddFirstReviewData {
    if (self.viewModel.replyModelArray.count <= 0) {
        return;
    }
    
    if (self.topListData.count > 0) {
        
        NSMutableArray *filterListData = [[NSMutableArray alloc] initWithArray:self.viewModel.replyModelArray];
        NSMutableArray *tempFilterData = [[NSMutableArray alloc] initWithArray:self.topListData];
        [self.topListData enumerateObjectsUsingBlock:^(ZFCommunityPostDetailReviewsListMode *  _Nonnull topObj, NSUInteger topIdx, BOOL * _Nonnull topStop) {
            YWLog(@"------topStop: %lu",(unsigned long)topIdx);
            
            __block BOOL hasFind = NO;
            [filterListData enumerateObjectsUsingBlock:^(ZFCommunityPostDetailReviewsListMode *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([topObj.replyId isEqualToString:obj.replyId] && !ZFIsEmptyString(topObj.replyId)) {
                    hasFind = YES;
//                    if (topIdx != idx) {
                        YWLog(@"------ stop: %lu  %@",(unsigned long)idx,obj.content);

                        if (self.viewModel.replyModelArray.count > idx) {
                            [self.viewModel.replyModelArray removeObjectAtIndex:idx];
                        }
//                        *stop = YES;
//                    }
                    YWLog(@"------ stop: %lu",(unsigned long)idx);
                }
                
            }];
        }];
        
        if (tempFilterData.count > 0) {
            [self.topListData enumerateObjectsUsingBlock:^(ZFCommunityPostDetailReviewsListMode *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.viewModel.replyModelArray insertObject:obj atIndex:0];
            }];
        }
        
    }
}

/*
 * 删除评论
 */
- (void)deleteCommentsWithReplayID:(NSString *)replyID indexPath:(NSIndexPath *)indexPath {
    ShowLoadingToView(self.view);
    @weakify(self)
    [self.viewModel deleteCommentWithReviewID:self.reviewID replyID:replyID complateHandle:^{
        @strongify(self)
        HideLoadingFromView(self.view);
        if ([self.viewModel isRequestSuccess]) {
            
            if (self.viewModel.replyModelArray.count > indexPath.item) {
                ZFCommunityPostDetailReviewsListMode *reviewModel = self.viewModel.replyModelArray[indexPath.item];
                __block NSInteger index = -1;
                [self.topListData enumerateObjectsUsingBlock:^(ZFCommunityPostDetailReviewsListMode *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.replyId isEqualToString:reviewModel.replyId]) {
                        index = idx;
                        *stop = YES;
                    }
                }];
                if (index >= 0 && self.topListData.count > index) {
                    [self.topListData removeObjectAtIndex:index];
                }
            }

            [self.viewModel deleteCommentWithIndexPath:indexPath];
            [self.replyTableView reloadData];
            
            [self.replyTableView doBlankViewWithCurrentPage:@(self.viewModel.currentPage)
                                                  totalPage:@(self.viewModel.totalPage)];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReviewCountsChangeNotification object:nil];
        }
        ShowToastToViewWithText(self.view, [self.viewModel tipMessage]);
    }];
}

/**
 * 请求发送评论
 */
- (void)requestSendReplyData {
    ShowLoadingToView(self.view);
    @weakify(self)
    [self.interfaceViewModel requestReplyNetwork:self.replyDict completion:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);
        [self.inputTextView setPlaceholderText:ZFLocalizedString(@"CommunityDetail_VC_TextView_Placeholder",nil)];
        [self.replyDict removeAllObjects];
        
        if (obj) {
            if ([obj isKindOfClass:[ZFCommunityPostDetailReviewsListMode class]]) {
                [self.topListData addObject:obj];
                
                if (self.replayCommentBlock) {
                    self.replayCommentBlock(obj);
                }
            }
        }
        
        if (self.viewModel.replyModelArray.count <= 0) {
            [self.viewModel refresh];
            [self.topListData removeAllObjects];
            [self requestCommentDatas];
        } else {
            
            [self filterAddFirstReviewData];
            [self.replyTableView reloadData];
        }
        
        // branch统计
        [[ZFBranchAnalytics sharedManager] branchAnalyticsPostReviewWithPostId:self.reviewID postType:self.isOutfits ? @"outfit" : @"show"];
        
    } failure:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);
        ShowToastToViewWithText(self.view, @"fail");
    }];
}

- (void)inputTextViewAction:(NSString *)input
{
    @weakify(self)
    [self judgePresentLoginVCCompletion:^{
        @strongify(self)
        
        /*********************将数据装成字典进行请求*******************/
        /*为0的情况下是给自己的帖子评论,非0得情况是给他人回复评论*/
        self.replyDict[@"replyId"] = self.replyDict[@"replyId"] ? self.replyDict[@"replyId"] : @"0"; // 晒图回复的id,如果当前回复是对评论的回复则这个值传0
        self.replyDict[@"reviewId"] = self.reviewID; // 当前晒图的id
        self.replyDict[@"replyUserId"] = self.replyDict[@"replyUserId"] ? self.replyDict[@"replyUserId"] : @"0"; // 晒图回复人的用户id,如果当前回复是对评论的回复则这个值传0
        self.replyDict[@"content"] =  [input stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]; // 评论内容
        self.replyDict[@"isSecondFloorReply"] = self.replyDict[@"isSecondFloorReply"] ? self.replyDict[@"isSecondFloorReply"] : @"0"; // 1表示这条回复是对回复的回复，0表是这条回复是对晒图的回复
        
        //请求发送评论
        [self requestSendReplyData];
    }];
}

/*
 * 回复评论
 */
- (void)replayCommentWithIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
    [self judgePresentLoginVCCompletion:^{
        @strongify(self)
        [self.inputTextView.textView becomeFirstResponder];
        /*点击回复他人评论时截取的数据*/
        [self.inputTextView setPlaceholderText:[NSString stringWithFormat:@"Re %@", [self.viewModel userNickWithIndexPath:indexPath]]];
        self.replyDict[@"replyId"]     = [self.viewModel replyIDWithIndexPath:indexPath];
        self.replyDict[@"reviewId"]    = [self.viewModel reviewIDWithIndexPath:indexPath];
        self.replyDict[@"replyUserId"] = [self.viewModel userIDWithIndexPath:indexPath];
        self.replyDict[@"isSecondFloorReply"] = @"1";
        /**************************************/
    }];
}

- (void)jumpToUserCenter:(ZFCommunityPostDetailReviewsListMode *)model {
    if (!ZFIsEmptyString(model.userId)) {
        ZFCommunityAccountViewController *accoutCtrl = [[ZFCommunityAccountViewController alloc] init];
        accoutCtrl.userName = ZFToString(model.nickname);
        accoutCtrl.userId = model.userId;
        [self.navigationController pushViewController:accoutCtrl animated:YES];
    }
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel rowCount];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return [self.viewModel rowHeightWithIndexPath:indexPath];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityPostReplyCommentCell *cell = [ZFCommunityPostReplyCommentCell commentCellWithTableView:tableView indexPath:indexPath];
    cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    if (self.viewModel.replyModelArray.count > indexPath.row) {
        ZFCommunityPostDetailReviewsListMode *model = self.viewModel.replyModelArray[indexPath.row];
        cell.model = model;
        cell.isHideLine = [self.viewModel rowCount] - 1 == indexPath.row;
        
        @weakify(self)
        cell.userBlock = ^(ZFCommunityPostDetailReviewsListMode *model) {
            @strongify(self)
            [self jumpToUserCenter:model];
        };
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.viewModel isCanReplyWithIndexPath:indexPath]) {
        [self replayCommentWithIndexPath:indexPath];
        return;
    }
    
    NSString *sheetTitle = ZFLocalizedString(@"community_topiccomment_deletetitle", nil);
    NSString *deleteTitle = ZFLocalizedString(@"Address_List_Cell_Delete",nil);
    NSString *cancelTitle = ZFLocalizedString(@"Cancel",nil);
    NSDictionary *dictAttr = @{ NSForegroundColorAttributeName:[UIColor redColor] };
    NSAttributedString *deleteAttr = [[NSAttributedString alloc]initWithString:deleteTitle attributes:dictAttr];
    
    @weakify(self)
    [ZFActionSheetView actionSheetByBottomCornerRadius:^(NSInteger buttonIndex, id title) {
        @strongify(self)
        [self deleteCommentsWithReplayID:[self.viewModel replyIDWithIndexPath:indexPath] indexPath:indexPath];
    } cancelButtonBlock:nil sheetTitle:sheetTitle cancelButtonTitle:cancelTitle otherButtonTitleArr:@[deleteAttr]];
}

#pragma mark - private method
- (void)addRefreshHeader {
    @weakify(self);
    ZFRefreshHeader *header = [ZFRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self.viewModel refresh];
        [self.topListData removeAllObjects];
        [self requestCommentDatas];
    }];
    header.backgroundColor = [UIColor clearColor];
    [self.replyTableView setMj_header:header];
}

- (void)addRefreshFooter {
    @weakify(self)
    ZFRefreshFooter *footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self requestCommentDatas];
    }];
    [self.replyTableView setMj_footer:footer];
}

#pragma mark - geter/setter
- (UITableView *)replyTableView {
    if (!_replyTableView) {
        CGFloat inputOffsetY = IPHONE_X_5_15 ? KScreenHeight - 49 - 44.0 - 44.0 - 34 : KScreenHeight - 49 - 64;
        _replyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, inputOffsetY) style:UITableViewStylePlain];
        _replyTableView.delegate   = self;
        _replyTableView.dataSource = self;
        _replyTableView.estimatedRowHeight = 140;
        _replyTableView.backgroundColor = ZFC0xF2F2F2();
        _replyTableView.showsVerticalScrollIndicator = NO;
        _replyTableView.tableFooterView = [UIView new];
        _replyTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        
        // 有 bug
//        [self addRefreshHeader];
//        [self addRefreshFooter];
        
        @weakify(self)
        _replyTableView.emptyDataImage = ZFImageWithName(@"blankPage_noMeaagess");
        _replyTableView.emptyDataTitle = ZFLocalizedString(@"community_topic_commentempty", nil);
        
        [_replyTableView addHeaderRefreshBlock:^{
            @strongify(self)
            [self.viewModel refresh];
            [self.topListData removeAllObjects];
            [self requestCommentDatas];
            
        } footerRefreshBlock:^{
            @strongify(self)
            [self requestCommentDatas];
            
        } startRefreshing:NO];
    }
    return _replyTableView;
}

- (InputTextView *)inputTextView {
    if(!_inputTextView){
        _inputTextView = [[InputTextView alloc]initWithFrame:CGRectMake(0, self.replyTableView.height, KScreenWidth, 49)];
        _inputTextView.backgroundColor = [UIColor colorWithWhite:255 alpha:0];
        [_inputTextView setPlaceholderText:ZFLocalizedString(@"Community_Post_Detail_CommentQuestion",nil)];
        _inputTextView.hidden = YES;
        [self.view addSubview:_inputTextView];
        
        @weakify(self)
        _inputTextView.InputTextViewBlock = ^(NSString *input){
            @strongify(self)
            [self inputTextViewAction:input];
        };
    }
    return _inputTextView;
}

- (UIView *)iPhonexBottomView {
    if (!_iPhonexBottomView) {
        _iPhonexBottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.inputTextView.y + self.inputTextView.height, KScreenWidth, kiphoneXHomeBarHeight)];
        _iPhonexBottomView.backgroundColor = ZFC0xFFFFFF();
    }
    return _iPhonexBottomView;
}

- (UIView *)bottomeSpaceView {
    if (!_bottomeSpaceView) {
        _bottomeSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kiphoneXHomeBarHeight)];
        _bottomeSpaceView.backgroundColor = ZFC0xFFFFFF();
        _bottomeSpaceView.hidden = YES;

    }
    return _bottomeSpaceView;
}
- (NSMutableDictionary *)replyDict {
    if (!_replyDict) {
        _replyDict = [NSMutableDictionary new];
    }
    return _replyDict;
}

- (NSMutableArray *)topListData {
    if (!_topListData) {
        _topListData = [[NSMutableArray alloc] init];
    }
    return _topListData;
}
@end
