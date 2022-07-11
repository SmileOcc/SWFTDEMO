//
//  YXStockCommentDetailViewController.m
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/24.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXStockCommentDetailViewController.h"
#import "YXReportViewModel.h"
#import "YXCommentViewModel.h"
#import "YXCommentViewController.h"
//#import "YXNavigationController.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"
#import <IGListKit/IGListKit.h>



@interface YXStockCommentDetailViewController ()<IGListAdapterDataSource,IGListAdapterPerformanceDelegate>

@property (nonatomic, strong) YXStockCommentDetailViewModel *viewModel;

@property (nonatomic, strong) IGListAdapter *adapter;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSString * commentId; //加载更多回复
@property (nonatomic, assign) NSInteger replyOffset;

@property (nonatomic, strong) QMUIButton *moreButton;

@property (nonatomic, strong) YXCommentDetailNoDataView *noDataView;
@property (nonatomic, strong) YXCommentDetailToolView * toolView;

@property (nonatomic, strong) YXCommentDetailPostModel * postModel;
@property (nonatomic, strong) YXStockPopover *popover; //弹出框

@property (nonatomic, strong) NSString * postType;

@property (nonatomic, assign) NSUInteger commmentOffset;
@property (nonatomic, assign) BOOL isFirstLoad;


@end

@implementation YXStockCommentDetailViewController
@dynamic viewModel;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.postType = [NSString stringWithFormat:@"%ld",(long)YXInformationFlowTypeStockdiscuss];

    self.isFirstLoad = YES;
    [self initUI];
    
    [self loadData];
}


-(void)bindViewModel {
    
}

-(void)initUI {
    
    @weakify(self);
    self.dataSource = [NSMutableArray array];
    self.title = [YXLanguageUtility kLangWithKey:@"comment"] ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.moreButton];

    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
    
    [self.contentView addSubview:self.toolView];
    [self.contentView addSubview:self.noDataView];
    
}


-(void)loadData {
    [self reqStockCommentDetail:NO];
}

-(void)reqStockCommentDetail:(BOOL) isLoadMore {
    
    if (isLoadMore == NO) {
        self.commmentOffset = 0;
    }
    
    @weakify(self);
    if (self.isFirstLoad) {
        [YXProgressHUD showLoading:@"" in:self.view];
    }
  
    [YXSquareCommentManager queryPostDetailDataWithPostId:self.viewModel.cid limit:10 offset:self.commmentOffset completion:^(YXCommentDetailPostModel * _Nullable model) {
        @strongify(self);
        
        [YXProgressHUD hideHUDForView:self.view animated:YES];
      
        if (model) {
            self.postModel = model;
            self.isFirstLoad = NO;
            YXCommentDetailHeaderModel * headerModel = [self transformHeadeModel:model];
            self.navBarPublisherView.userModel = headerModel.creator_user;
            self.navBarPublisherView.descLabel.text =   [YXToolUtility compareCurrentTime:headerModel.create_time];
            if (isLoadMore == NO) {
                self.viewModel.headerModel = headerModel;
                self.dataSource = [NSMutableArray arrayWithObject:self.viewModel.headerModel];
            }
            
            self.viewModel.commentTitleModel.title = [NSString stringWithFormat:@"%@(%lld)",[YXLanguageUtility kLangWithKey:@"stock_detail_discuss"],model.comment_count];
            if ([self.dataSource containsObject:self.viewModel.commentTitleModel] == NO) {
                [self.dataSource addObject:self.viewModel.commentTitleModel];
            }
            
            if (model.comment_list.count > 0) {
                if ([self.dataSource containsObject:self.viewModel.noDataModel]) {
                    [self.dataSource removeObject:self.viewModel.noDataModel];
                }

                if (isLoadMore == NO) {
                    [self.viewModel.commentLists addObjectsFromArray:model.comment_list];
                }else{
                   
                    [self.viewModel.commentLists addObjectsFromArray:model.comment_list];
                }
                self.commmentOffset = self.viewModel.commentLists.count;
                if (self.viewModel.commentLists.count > 0) {
                    [self.dataSource addObjectsFromArray:self.viewModel.commentLists];
                }
            }else{
                if (isLoadMore == NO) {
                    self.viewModel.noDataModel.post_id = self.viewModel.cid;
                    self.viewModel.noDataModel.post_type = @"5";
                    if ([self.dataSource containsObject:self.viewModel.noDataModel] == NO ){
                        [self.dataSource addObject:self.viewModel.noDataModel];
                    }
                }
            }
            
            NSInteger sumlistCount = self.viewModel.commentLists.count;
            if (sumlistCount > 0 && model.comment_count > sumlistCount) {
                if ([self.dataSource containsObject:self.viewModel.footerTitleModel] == NO) {
                    [self.dataSource addObject:self.viewModel.footerTitleModel];
                }else{
                    [self.dataSource removeObject:self.viewModel.footerTitleModel];
                    [self.dataSource addObject:self.viewModel.footerTitleModel]; //把它放在最后面
                }
            }else{
                if ([self.dataSource containsObject:self.viewModel.footerTitleModel] == YES) {
                    [self.dataSource removeObject:self.viewModel.footerTitleModel];
                }
            }
            [self.toolView updateLikeCountWithLikeCount:model.likeCount likeFlag:model.like_flag];
        }
        self.noDataView.hidden = (self.dataSource.count > 0);
        [self.adapter performUpdatesAnimated:YES completion:nil];
    }];
}


-(void)refreshSingleComment:(NSString * )commentId {
    if (commentId.length == 0) {
        return;
    }
    @weakify(self)
    [YXUGCCommentManager querySingleCommentDataWithComment_id:commentId limit:5 offset:0 completion:^(YXSingleCommentModel * _Nullable model) {
        @strongify(self)
        if (model) {
            //这里相当于增加
            YXCommentDetailCommentModel * newModel = model.comment;
            [YXSquareCommentManager transformCommentDetailCommentListLayoutWithModel:newModel];
            
            if ([self.dataSource containsObject:self.viewModel.commentTitleModel] == NO) {
                [self.dataSource addObject:self.viewModel.commentTitleModel];
            }
            [self.viewModel.commentLists insertObject:newModel atIndex:0];
            self.postModel.comment_count = self.postModel.comment_count + 1;
         
            self.viewModel.commentTitleModel.title = [NSString stringWithFormat:@"%@(%lu)",[YXLanguageUtility kLangWithKey:@"stock_detail_discuss"], (unsigned long)self.postModel.comment_count];
            
            NSInteger titleIndex = [self.dataSource indexOfObject:self.viewModel.commentTitleModel];
            [self.dataSource insertObject:newModel atIndex:titleIndex + 1];
            
            //有数据时移除无数据模型
            if ([self.dataSource containsObject:self.viewModel.noDataModel]) {
                [self.dataSource removeObject:self.viewModel.noDataModel];
            }
            self.commmentOffset = self.viewModel.commentLists.count;
            
            [self.adapter performUpdatesAnimated:YES completion:nil];
            [self.adapter reloadObjects:@[self.viewModel.commentTitleModel]];
        }
    }];
}


#pragma mark - Private

-(void)rightAction {
    double uid = self.postModel.creator_user.uid.doubleValue;
    NSArray * popList = [NSArray array];
    if ([YXUserManager userUUID] == (UInt64)uid) {
        popList = @[@(CommentButtonTypeDelete) , @(CommentButtonTypeShare)];
    }else{
        popList = @[@(CommentButtonTypeReport) , @(CommentButtonTypeShare)];
    }
    @weakify(self)
    YXCommentDetailPopView * popView = [[YXCommentDetailPopView alloc] initWithList:popList isWhiteStyle:YES  clickCallBack:^(NSInteger type) {
        @strongify(self)
        [self.popover dismiss];
        
        if (![YXUserManager isLogin]) {
            [YXToolUtility handleBusinessWithLogin:^{
                 
            }];
            
            return;
        }
   
        if (type == CommentButtonTypeShare) {
            [self sharePostHandle];
        }else if(type == CommentButtonTypeDelete) { //删除帖子
            @weakify(self);
            [YXSquareCommentManager commentDeleteAlertWithCompletion:^{
                @strongify(self)
                @weakify(self);
                [YXSquareCommentManager queryUpdatePostStatusWithIgnorePush:YES ignoreWhiteList:YES postId:self.postModel.post_id status:3 completion:^(BOOL isSuc, BOOL isDelete) {
                    @strongify(self);
                    if (isSuc) {
                        [YXProgressHUD showMessage:[YXLanguageUtility kLangWithKey:@"mine_del_success"] ];
                        [self.dataSource removeAllObjects];

                        [self.viewModel.services popViewModelAnimated:YES];

                    }
                    if(isDelete) {

                    }
                }];
            }];
        }else if(type == CommentButtonTypeReport) {
            [YXSquareCommentManager queryUpdatePostStatusWithIgnorePush:YES ignoreWhiteList:YES postId:self.postModel.post_id status:4 completion:^(BOOL isSuc, BOOL isDelete) {
                if (isSuc) {
                    [YXProgressHUD showMessage:[YXLanguageUtility kLangWithKey:@"report_success"]];
                }
            }];
        }
       
    }];
    [self.popover show:popView fromView:self.moreButton];
}

-(YXCommentDetailHeaderModel *)transformHeadeModel:(YXCommentDetailPostModel *)dataModel {
    YXCommentDetailHeaderModel * headerModel = [[YXCommentDetailHeaderModel alloc] init];
    headerModel.channel_id = dataModel.channel_id;
    headerModel.comment_count = dataModel.comment_count;
    headerModel.comment_list = dataModel.comment_list;
    headerModel.content = dataModel.content;
    headerModel.create_time = dataModel.create_time;
    headerModel.creator_user = dataModel.creator_user;
    headerModel.likeCount = dataModel.likeCount;
    headerModel.like_flag = dataModel.like_flag;
    headerModel.pictures = dataModel.pictures;
    headerModel.post_id = dataModel.post_id;
    headerModel.status = dataModel.status;
    headerModel.postHeaderLayout = dataModel.postHeaderLayout;
    
    return headerModel;
}

//分享帖子
-(void)sharePostHandle {
    if (self.postModel) {
        YXSquareStockPostListModel *model = [[YXSquareStockPostListModel alloc] init];
        model.content = self.postModel.content;
        model.create_time = self.postModel.create_time;
        model.creator_user = self.postModel.creator_user;
        model.pictures = self.postModel.pictures;
        model.status = self.postModel.status;
        
        [YXDiscussShareView showShareViewWithModel:model];
    }
   
}

#pragma mark - ListAdapterMoveDelegate

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {

    return [self.dataSource qmui_filterWithBlock:^BOOL(id  _Nonnull item) {
        return [item conformsToProtocol:@protocol(IGListDiffable)];
    }];
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {

    @weakify(self);
    if ([object isKindOfClass:[YXCommentDetailHeaderModel class]]) {
        YXCommentDetailHeaderViewController * headerVC = [[YXCommentDetailHeaderViewController alloc] init];
        
        return headerVC;
    }else if ([object isKindOfClass:[YXCommentSectionTitleModel class]]) {
        return [[YXUGCCommentTitleSectionController alloc] init];
    }else if ([object isKindOfClass:[YXCommentDetailCommentModel class]]){
        YXCommentDetailIGViewController * detailVC = [[YXCommentDetailIGViewController alloc] init];
        
        detailVC.postType = self.postType;
        detailVC.postId = self.viewModel.cid;
     
        detailVC.refreshDataBlock = ^(id _Nullable model, CommentRefreshDataType type) {
            @strongify(self);
            if (type == CommentRefreshDataTypeDeleteData) { //直接删除
              
                self.viewModel.headerModel.comment_count = self.viewModel.headerModel.comment_count - 1;
                [self.dataSource removeObject:object];
                NSInteger commentIndex = [self.viewModel.commentLists indexOfObject:object];
                [self.viewModel.commentLists removeObjectAtIndex:commentIndex];
                self.postModel.comment_count = self.postModel.comment_count - 1;
                self.viewModel.commentTitleModel.title = [NSString stringWithFormat:@"%@(%lu)", [YXLanguageUtility kLangWithKey:@"stock_detail_discuss"],(unsigned long)self.postModel.comment_count];
                
                self.commmentOffset = self.viewModel.commentLists.count;
                if (self.viewModel.commentLists.count == 0 && [self.dataSource containsObject:self.viewModel.noDataModel] == NO) {
                    [self reqStockCommentDetail:NO];
                }else{
                    NSMutableArray * loadArr = [NSMutableArray array];
                    [loadArr addObject:self.viewModel.commentTitleModel];
            
                    [self.adapter performUpdatesAnimated:NO completion:nil];
                    [self.adapter reloadObjects:loadArr];
                }
            }else if(type == CommentRefreshDataTypeRefreshDataReplace) { //替换数据
                if (model) {
                    NSInteger index = [self.dataSource indexOfObject:object];
                    YXCommentDetailCommentModel * newModel = (YXCommentDetailCommentModel *)model;
                    [self.dataSource replaceObjectAtIndex:index withObject:newModel];
                    
                   NSInteger commentIndex = [self.viewModel.commentLists indexOfObject:object];
                   [self.viewModel.commentLists replaceObjectAtIndex:commentIndex withObject:newModel];

                    [self.adapter performUpdatesAnimated:YES completion:nil];
                    [self.adapter reloadObjects:@[newModel]];
                }
            }
        };
        return detailVC;
        
    }else if ([object isKindOfClass:[YXCommentSectionFooterTitleModel class]]) {
        YXCommentDetailFooterController * footeVC = [[YXCommentDetailFooterController alloc] init];
        [footeVC setShowMoreCommentBlock:^{
            @strongify(self)
            [self reqStockCommentDetail:YES];
        }];
        return footeVC;
    }else {
        YXCommentDetailNoDataSectionController * nodataVC = [[YXCommentDetailNoDataSectionController alloc] init];
        nodataVC.refreshDataBlock = ^{
            @strongify(self)
            [self loadData];
        };
        return nodataVC;
    }

}

- (void)listAdapter:(IGListAdapter *)listAdapter didCallScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navBarPublisherView.hidden = (offsetY > YXConstant.navBarHeight) ? NO : YES;
}

- (void)listAdapterWillCallSize:(IGListAdapter *)listAdapter {
    
}

- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didCallDequeueCell:(nonnull UICollectionViewCell *)cell onSectionController:(nonnull IGListSectionController *)sectionController atIndex:(NSInteger)index {
    
}


- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didCallDisplayCell:(nonnull UICollectionViewCell *)cell onSectionController:(nonnull IGListSectionController *)sectionController atIndex:(NSInteger)index {
    
}


- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didCallEndDisplayCell:(nonnull UICollectionViewCell *)cell onSectionController:(nonnull IGListSectionController *)sectionController atIndex:(NSInteger)index {
    
}


- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didCallSizeOnSectionController:(nonnull IGListSectionController *)sectionController atIndex:(NSInteger)index {
    
}


- (void)listAdapterWillCallDequeueCell:(nonnull IGListAdapter *)listAdapter {
    
}


- (void)listAdapterWillCallDisplayCell:(nonnull IGListAdapter *)listAdapter {
    
}


- (void)listAdapterWillCallEndDisplayCell:(nonnull IGListAdapter *)listAdapter {
    
}


- (void)listAdapterWillCallScroll:(nonnull IGListAdapter *)listAdapter {
    
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    
    return nil;
}

-(__kindof UIScrollView *)scrollView {
    return self.collectionView;
}


#pragma mark - lazy load
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout: [[UICollectionViewFlowLayout alloc] init]];
        _collectionView.backgroundColor = QMUITheme.foregroundColor;
    }
    return _collectionView;
}

- (CGFloat)bottomHeight {
    return 52 + YXConstant.safeAreaInsetsBottomHeight;
}

- (QMUIButton *)moreButton {
    if (_moreButton == nil) {
        _moreButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.frame = CGRectMake(0, 0, 40, 40);
        _moreButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_moreButton setImage:[UIImage imageNamed:@"more_icon"] forState:UIControlStateNormal];
        @weakify(self);
        
        [_moreButton setQmui_tapBlock:^(__kindof UIControl *sender) {
            @strongify(self);
            [self rightAction];
        }];
    }
    return _moreButton;
}

- (IGListAdapter *)adapter {
    if (_adapter == nil) {
        _adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init] viewController:self];
        _adapter.performanceDelegate = self;
    }
    return _adapter;
}

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}


- (YXCommentDetailNoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[YXCommentDetailNoDataView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, YXConstant.screenHeight /*self.contentView.height*/)];
        _noDataView.isWhiteStyle = YES;
        _noDataView.emptyImageView.image = [UIImage imageNamed:@"no_postData"];
        _noDataView.topOffset = 180;
        _noDataView.titleLabel.text = [YXLanguageUtility kLangWithKey:@"post_isDeleted"];
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

-(YXCommentDetailToolView *)toolView {
    if (!_toolView) {
        _toolView = [[YXCommentDetailToolView alloc] initWithFrame:CGRectMake(0, YXConstant.screenHeight - YXConstant.navBarHeight - 54 - YXConstant.safeAreaInsetsBottomHeight, YXConstant.screenWidth, 54 + YXConstant.safeAreaInsetsBottomHeight)];
       
        @weakify(self)
        _toolView.toolActionBlock = ^( CommentButtonType type) {
            @strongify(self)
            if (!self.postModel) {
                return;
            }
            if (YXUserManager.isLogin == NO) {
                [YXToolUtility handleBusinessWithLogin:^{
              
                }];
                return;
            }
            if (type == CommentButtonTypeComment) {
                NSString * post_id = self.postModel.post_id.length > 0 ? self.postModel.post_id:@"";
                NSDictionary * paraDic = @{
                    @"post_id":post_id,
                    @"post_type":self.postType
                                           
                };
                YXCommentViewModel *viewModel = [[YXCommentViewModel alloc] initWithServices:self.viewModel.services params:paraDic];
                viewModel.isReply = NO;
                @weakify(self);
                [viewModel setSuccessBlock:^(NSString *  commentId) {
                    @strongify(self);
                    if (post_id.length == 0) {
                        return;
                    }
                    [self refreshSingleComment:commentId];

                }];
                
                YXCommentViewController *viewController = [[YXCommentViewController alloc] initWithViewModel:viewModel];
                
                [YXToolUtility alertNoFullScreen:viewController];


            }else if (type == CommentButtonTypeLike) {
                NSInteger opration = (self.postModel.like_flag) ? -1 : 1;
                @weakify(self)
                [YXSquareCommentManager queryLikeOprationWithItemType:1 itemId:self.postModel.post_id opration:opration completion:^(BOOL isSuc, NSString * count, BOOL isDelete) {
                    @strongify(self)
                    if (isSuc) {
                        self.postModel.like_flag = !self.postModel.like_flag;
                        self.postModel.likeCount = count.intValue;
                        [self.toolView updateLikeCountWithLikeCount:count.integerValue likeFlag:self.postModel.like_flag];
                    }

                }];
            }else if(type == CommentButtonTypeShare){
                [self sharePostHandle];
            }
        };
    }
    
    return _toolView;
}


- (YXStockPopover *)popover{
    
    if (!_popover) {
        _popover = [[YXStockPopover alloc] init];
    }
    
    return _popover;
}

@end
