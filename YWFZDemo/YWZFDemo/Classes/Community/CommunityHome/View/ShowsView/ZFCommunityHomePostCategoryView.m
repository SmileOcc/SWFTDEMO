//
//  ZFCommunityHomePostCategoryView.m
//  ZZZZZ
//
//  Created by YW on 2018/11/24.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomePostCategoryView.h"
#import "ZFCommunityPostDetailPageVC.h"
#import "ZFCommunityVideoListVC.h"

#import "ZFInitViewProtocol.h"
#import "ZFCommunityGestureCollectionView.h"
#import "ZFCommunityHomePostCategoryCell.h"
#import "ZFCommunityHomeVideoCell.h"

#import "CHTCollectionViewWaterfallLayout.h"

#import "ZFCommunityShowsListViewModel.h"
#import "ZFCommunityStyleLikesModel.h"
#import "CommunityEnumComm.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFCommunityHomePostCategoryAOP.h"

@interface ZFCommunityHomePostCategoryView()
<ZFInitViewProtocol,
UIScrollViewDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
CHTCollectionViewDelegateWaterfallLayout
>

@property (nonatomic, strong) ZFCommunityShowsListViewModel                           *showsViewModel;

@property (nonatomic, strong) NSMutableArray <ZFCommunityFavesItemModel *>          *dataSource;
@property (nonatomic, assign) BOOL                                                  hasRequest;
@property (nonatomic, assign) BOOL                                                  fingerIsTouch;
@property (nonatomic, assign) BOOL                                                  cellCanScroll;
@property (nonatomic, strong) ZFCommunityHomePostCategoryAOP                        *analyticsAOP;

@end
@implementation ZFCommunityHomePostCategoryView
@synthesize baseCollectionView = _baseCollectionView;

- (void)dealloc {
    YWLog(@"-------ccccccccccc coumunity: %@",NSStringFromClass([self class]));
    ZFRemoveAllNotification(self);
}

- (instancetype)initWithFrame:(CGRect)frame itemModel:(ZFCommunityChannelItemModel *)itemModel startRequest:(BOOL)start {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.itemModel = itemModel;
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];
        self.dataSource = [NSMutableArray array];
        
        [self zfInitView];
        [self zfAutoLayoutView];
        
        [self addNotifyCation];
        if (start) {
            [self startFirstRequest];
        }
    }
    return self;
}

- (void)startFirstRequest {
    if (!self.hasRequest) {
        [self requestPostCategoryListData:YES];
    }
}

- (void)updateItemModel:(ZFCommunityChannelItemModel *)itemModel {
    self.itemModel = itemModel;
    if (self.hasRequest) {
        self.baseCollectionView.contentOffset = CGPointZero;
    }
}

- (void)addNotifyCation {
    //接收点赞状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStatusChangeValue:) name:kLikeStatusChangeNotification object:nil];
    
    //接收评论状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviewCountsChangeValue:) name:kReviewCountsChangeNotification object:nil];
    //接收登录状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kLoginNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFirstPageData:) name:kRefreshCommunityChannelRefreshNotification object:nil];
    //接收删除状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteChangeValue:) name:kDeleteStatusChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNestViewCanScrollStatus:) name:kCommunityExploreNestViewScrollStatus object:nil];
}

#pragma mark - <ZFInitViewProtocol>

-(void)zfInitView{
    [self addSubview:self.baseCollectionView];
}

-(void)zfAutoLayoutView{
    [self.baseCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsZero);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(self.mas_height);
    }];
}



#pragma mark - Notification

- (void)refreshFirstPageData:(NSNotification *)nofi{
    ZFCommunityChannelItemModel *itemModel = nofi.object;
    if (itemModel) {
        if ([itemModel.idx isEqualToString:self.itemModel.idx]) {
            [self requestPostCategoryListData:YES];
        }
    }
}

- (void)loginChangeValue:(NSNotification *)nofi {
    [self requestPostCategoryListData:YES];
}

- (void)setNestViewCanScrollStatus:(NSNotification *)notice {
    
    NSDictionary *dic = notice.userInfo;
    NSNumber *status = dic[@"status"];
    NSNumber *type = dic[@"type"];
    self.cellCanScroll = [status boolValue];
    
    //其他同级选项列表下滑是显示出上面【总广告视图时】，这个列表要滚动到顶部
    if ([type intValue] != ZFCommunityHomeSelectTypeExplore) {
        self.baseCollectionView.contentOffset = CGPointZero;
    }
}

- (void)deleteChangeValue:(NSNotification *)noti{
    
    NSString *reviewId =  noti.object;
    //遍历当前列表数组找到相同userId改变状态
    [self.dataSource enumerateObjectsUsingBlock:^(ZFCommunityFavesItemModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.reviewId isEqualToString:reviewId]) {
            @weakify(self)
            [self.baseCollectionView performBatchUpdates:^{
                @strongify(self)
                [self.dataSource removeObjectAtIndex:idx];
                
                [self.baseCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:idx inSection:0]]];
                
            }completion:^(BOOL finished){
                @strongify(self)
                [self.baseCollectionView reloadData];
                
            }];
            *stop = YES;
        }
    }];
}

/**
 接收通知传过来的model StyleLikesModel
 */
- (void)reviewCountsChangeValue:(NSNotification *)nofi {
    ZFCommunityStyleLikesModel *reviewsModel = nofi.object;
    
    //遍历当前列表数组找到相同reviewId增加评论数
    [self.dataSource enumerateObjectsUsingBlock:^(ZFCommunityFavesItemModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.reviewId isEqualToString:reviewsModel.reviewId]) {
            obj.replyCount = [NSString stringWithFormat:@"%ld", [reviewsModel.replyCount integerValue] + 1];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForItem:idx inSection:0];
                [self.baseCollectionView performBatchUpdates:^{
                    [self.baseCollectionView reloadItemsAtIndexPaths:@[reloadIndexPath]];
                } completion:nil];
            });
            *stop = YES;
        }
    }];
}

/**
 接收通知传过来的model StyleLikesModel
 */
- (void)likeStatusChangeValue:(NSNotification *)nofi {
    ZFCommunityStyleLikesModel *likesModel = nofi.object;
    //遍历当前列表数组找到相同reviewId改变点赞按钮状态并且增加或减少点赞数
    [self.dataSource enumerateObjectsUsingBlock:^(ZFCommunityFavesItemModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.reviewId isEqualToString:likesModel.reviewId]) {
            
            if (likesModel.isLiked) {
                obj.likeCount = [NSString stringWithFormat:@"%d", [obj.likeCount intValue]+1];
            }else{
                obj.likeCount = [NSString stringWithFormat:@"%d", [obj.likeCount intValue]-1];
            }
            obj.isLiked = likesModel.isLiked;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForItem:idx inSection:0];
                [self.baseCollectionView performBatchUpdates:^{
                    [self.baseCollectionView reloadItemsAtIndexPaths:@[reloadIndexPath]];
                } completion:nil];
            });
            *stop = YES;
        }
    }];
}

- (void)requestPostCategoryListData:(BOOL)firstPage {
    
    self.hasRequest = YES;
    [self.showsViewModel requestPostCategoryListData:firstPage catID:ZFToString(self.itemModel.idx) completion:^(NSArray<ZFCommunityFavesItemModel *> *showsListArray, NSDictionary *pageInfo) {
        
        if (firstPage) {
            [self.colorSet removeAllObjects];
        }
        //计算布瀑流
        if (ZFJudgeNSArray(showsListArray)) {
            [showsListArray enumerateObjectsUsingBlock:^(ZFCommunityFavesItemModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj calculateCellSize];
                
                
            }];
            
            for (ZFCommunityFavesItemModel *itemModel in showsListArray) {
                [itemModel calculateCellSize];
                
                NSString *colorString =  [ZFThemeManager randomColorString:self.colorSet];
                if (self.colorSet.count == 3) {
                    [self.colorSet removeObjectAtIndex:0];
                }
                [self.colorSet addObject:colorString];
                itemModel.randomColor = [UIColor colorWithHexString:colorString];
            }
        }
        
        self.baseCollectionView.backgroundView = nil;
        if (firstPage && showsListArray) {
            self.dataSource = [NSMutableArray arrayWithArray:showsListArray];
        }else{
            [self.dataSource addObjectsFromArray:showsListArray];
        }
        
        [self.baseCollectionView reloadData];
        [self.baseCollectionView showRequestTip:pageInfo];
    }];
}

#pragma mark - UICollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    collectionView.mj_footer.hidden = self.dataSource.count == 0;
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFCommunityFavesItemModel *model;
    if (self.dataSource.count > indexPath.item) {
        model = self.dataSource[indexPath.item];
        if (model.type == 3) {//视频
            ZFCommunityHomeVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ZFCommunityHomeVideoCell queryReuseIdentifier] forIndexPath:indexPath];
            cell.favesItemModel = model;
            return cell;
        }
    }
    
    ZFCommunityHomePostCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ZFCommunityHomePostCategoryCell queryReuseIdentifier] forIndexPath:indexPath];
    
    cell.favesItemModel = model;
    cell.postLikeBlock = ^(ZFCommunityFavesItemModel *model) {
        [self communityExploreLikeOptionWithModel:model andIndexPath:indexPath];
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataSource.count > indexPath.item) {
        ZFCommunityFavesItemModel *model = self.dataSource[indexPath.item];
        
        if (model.type == 3) {//视频
            
            [model updateViewNum:[NSString stringWithFormat:@"%zd",([model.view_num integerValue] + 1)]];
            [collectionView performBatchUpdates:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            } completion:nil];
            
            ZFCommunityVideoListVC *videoVC = [[ZFCommunityVideoListVC alloc] init];
            videoVC.title = ZFToString(model.video_title);
            videoVC.videoId = ZFToString(model.reviewId);
            [self.viewController.navigationController pushViewController:videoVC animated:YES];
        } else {
            
            ZFCommunityPostDetailPageVC *detailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:model.reviewId title:model.title];
            
            detailViewController.sourceType = ZFAppsflyerInSourceTypeZMeExploreid;
            [self.viewController.navigationController pushViewController:detailViewController animated:YES];
        }
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.dataSource.count > indexPath.item) {
        ZFCommunityFavesItemModel *postModel = self.dataSource[indexPath.item];
        return postModel.twoColumnCellSize;
    }
    
    return CGSizeZero;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:self.baseCollectionView]) {
        
        if (scrollView.contentOffset.y - self.lastOffSetY > 0) {//向上滚动不显示
            [[NSNotificationCenter defaultCenter] postNotificationName:kCommunityHomeChannelScrollDirectionUP object:@(YES)];
            
        } else if (scrollView.contentOffset.y - self.lastOffSetY < 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCommunityHomeChannelScrollDirectionUP object:@(NO)];
        }
        
        if (self.cellCanScroll) {
            scrollView.showsVerticalScrollIndicator = YES;
            if (scrollView.contentOffset.y <= 0) {
                [self.viewController.navigationController.navigationBar setShadowImage:[UIImage new]];//去导航线条
                self.baseCollectionView.contentOffset = CGPointZero;
                [[NSNotificationCenter defaultCenter] postNotificationName:kCommunityExploreScrollStatus object:@(YES)];
                [self tapNavBarCanMoveTop:NO];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:kCommunityExploreScrollStatus object:@(NO)];
                [self tapNavBarCanMoveTop:YES];
            }
        }else{
            //[self.viewController.navigationController.navigationBar setShadowImage:nil];//恢复导航线条
            scrollView.showsVerticalScrollIndicator = NO;
            if (!scrollView.isDragging) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kCommunityExploreScrollStatus object:@(YES)];
                [self tapNavBarCanMoveTop:NO];
            }
            self.baseCollectionView.contentOffset = CGPointZero;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    if ([scrollView isEqual:self.baseCollectionView]) {
//
//        BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
//        if (scrollToScrollStop) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:kCommunityHomeChannelScrollDirection object:@(YES)];
//        }
//
//    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    if ([scrollView isEqual:self.baseCollectionView]) {
//        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
//        if (dragToDragStop) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:kCommunityHomeChannelScrollDirection object:@(YES)];
//        }
//    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    if ([scrollView isEqual:self.baseCollectionView]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kCommunityHomeChannelScrollDirection object:@(NO)];
//    }
    if ([scrollView isEqual:self.baseCollectionView]) {
        self.lastOffSetY = scrollView.contentOffset.y;
    }
}

#pragma mark - action

- (void)communityExploreLikeOptionWithModel:(ZFCommunityFavesItemModel *)model andIndexPath:(NSIndexPath *)indexPath {
    if (![AccountManager sharedManager].isSignIn) {
        [self.viewController.navigationController judgePresentLoginVCCompletion:nil];
        return ;
    }
    
    @weakify(self);
    NSDictionary *dic = @{kRequestModelKey : model,
                          kLoadingView : self};
    [self.showsViewModel requestLikeNetwork:dic completion:^(id obj) {

    } failure:^(id obj) {
        @strongify(self);
        ShowToastToViewWithText(self, ZFLocalizedString(@"My_Coupon_Get_Coupon_False",nil));
    }];

    // firebase
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"click_explore_topic_like_%@", model.topicId]
                                        itemName:@"topic_like"
                                     ContentType:@"community_like"
                                    itemCategory:@"Button"];
}

- (void)tapNavBarCanMoveTop:(BOOL)canMove {
    self.baseCollectionView.scrollsToTop = canMove;
}

- (BOOL)collectionViewScrollsTopState {
    return self.baseCollectionView.scrollsToTop;
}

#pragma mark - setter/getter


- (ZFCommunityShowsListViewModel *)showsViewModel{
    if (!_showsViewModel) {
        _showsViewModel = [[ZFCommunityShowsListViewModel alloc] init];
    }
    return _showsViewModel;
}

-(ZFCommunityGestureCollectionView *)baseCollectionView{
    if (!_baseCollectionView) {
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        _baseCollectionView = [[ZFCommunityGestureCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _baseCollectionView.showsVerticalScrollIndicator = NO;
        _baseCollectionView.showsHorizontalScrollIndicator = NO;
        _baseCollectionView.delegate = self;
        _baseCollectionView.dataSource = self;
        _baseCollectionView.backgroundView = [UIView zfLoadingView];
        _baseCollectionView.backgroundColor = ZFC0xF2F2F2();
        _baseCollectionView.scrollsToTop = NO;
        
        [_baseCollectionView registerClass:[ZFCommunityHomePostCategoryCell class] forCellWithReuseIdentifier:[ZFCommunityHomePostCategoryCell queryReuseIdentifier]];
        [_baseCollectionView registerClass:[ZFCommunityHomeVideoCell class] forCellWithReuseIdentifier:[ZFCommunityHomeVideoCell queryReuseIdentifier]];
        
        _baseCollectionView.requestFailBtnTitle = ZFLocalizedString(@"EmptyCustomViewManager_refreshButton",nil);
        @weakify(self)
        _baseCollectionView.blankPageViewActionBlcok = ^(ZFBlankPageViewStatus status) {
            @strongify(self)
            [self requestPostCategoryListData:YES];
        };

        _baseCollectionView.mj_footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self requestPostCategoryListData:NO];
        }];
    }
    return _baseCollectionView;
}

- (ZFCommunityHomePostCategoryAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFCommunityHomePostCategoryAOP alloc] initChannelId:self.itemModel.idx];
        [_analyticsAOP baseConfigureChannelId:self.itemModel.idx channelName:self.itemModel.cat_name];
    }
    return _analyticsAOP;
}
@end
