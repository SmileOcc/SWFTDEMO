//
//  ZFCommunityHomeOutfitsView.m
//  ZZZZZ
//
//  Created by YW on 2018/11/20.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeOutfitsView.h"
#import "YWLoginViewController.h"
#import "ZFCommunityPostDetailPageVC.h"
#import "ZFInitViewProtocol.h"

#import "ZFCommunityOutfitsListCell.h"

#import "ZFCommunityOutfitsModel.h"
#import "ZFCommunityOutfitsListViewModel.h"
#import "ZFCommunityShowsListViewModel.h"
#import "ZFCommunityStyleLikesModel.h"

#import "ZFOutfitBuilderSingleton.h"

#import "NSDictionary+SafeAccess.h"
#import "CommunityEnumComm.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"

#import "ZFCommunityHomeOutfitsAOP.h"

@interface ZFCommunityHomeOutfitsView()
<ZFInitViewProtocol,
UIScrollViewDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>

@property (nonatomic, strong) ZFCommunityOutfitsListViewModel                         *outfitsViewModel;
@property (nonatomic, strong) NSMutableArray <ZFCommunityOutfitsModel *>     *dataArray;

@property (nonatomic, assign) BOOL                                           hasRequest;
@property (nonatomic, assign) BOOL                                           fingerIsTouch;
@property (nonatomic, assign) BOOL                                           cellCanScroll;
@property (nonatomic, strong) ZFCommunityHomeOutfitsAOP                      *analyticsAOP;

@end

@implementation ZFCommunityHomeOutfitsView
@synthesize baseCollectionView = _baseCollectionView;

- (void)dealloc {
    ZFRemoveAllNotification(self);
}


- (instancetype)initWithFrame:(CGRect)frame itemModel:(ZFCommunityChannelItemModel *)itemModel startRequest:(BOOL)start {
    self = [super initWithFrame:frame];
    if (self) {
        self.itemModel = itemModel;
         [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];
        
        self.dataArray = [NSMutableArray array];
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
        [self requestOutfitsListData:YES];
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
    //接收登录状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kLoginNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFirstPageData:) name:kRefreshCommunityChannelRefreshNotification object:nil];
    
    //接收删除状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteChangeValue:) name:kDeleteStatusChangeNotification object:nil];
    /** 发穿搭帖子成功,需要插入一条假数据,普通帖只需要刷新shows界面 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postSuccess:) name:kCommunityPostSuccessNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNestViewCanScrollStatus:) name:kCommunityExploreNestViewScrollStatus object:nil];
}

- (void)setNestViewCanScrollStatus:(NSNotification *)notice {
    
    NSDictionary *dic = notice.userInfo;
    NSNumber *status = dic[@"status"];
    NSNumber *type = dic[@"type"];
    self.cellCanScroll = [status boolValue];
    
    //其他同级选项列表下滑是显示出上面【总广告视图时】，这个列表要滚动到顶部
    if ([type intValue] != ZFCommunityHomeSelectTypeOutfits) {
        self.baseCollectionView.contentOffset = CGPointZero;
    }
}

- (void)postSuccess:(NSNotification *)noti{
    NSDictionary *noteDict = noti.object;
    NSInteger type = [noteDict ds_integerForKey:@"review_type"];
    
    if (type == 0) {
        return;//普通帖,
    }
    
    @weakify(self)
    [self.baseCollectionView performBatchUpdates:^{
        @strongify(self)
        [self.dataArray insertObject:[[ZFOutfitBuilderSingleton shareInstance] currentPostOutfitsModel] atIndex:0];
        [self.baseCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
        
    }completion:^(BOOL finished){
        @strongify(self)
        [self.baseCollectionView reloadData];
    }];
}

- (void)deleteChangeValue:(NSNotification *)noti{
    
    NSString *reviewId =  noti.object;
    
    //遍历当前列表数组找到相同userId改变状态
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityOutfitsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.reviewId isEqualToString:reviewId]) {
            @weakify(self)
            [self.baseCollectionView performBatchUpdates:^{
                @strongify(self)
                [self.dataArray removeObjectAtIndex:idx];
                
                [self.baseCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:idx inSection:0]]];
                
            }completion:^(BOOL finished){
                @strongify(self)
                [self.baseCollectionView reloadData];
            }];
        }
        *stop = YES;
    }];
}

- (void)loginChangeValue:(NSNotification *)nofi{
    [self requestOutfitsListData:YES];
}

- (void)refreshFirstPageData:(NSNotification *)nofi {
    ZFCommunityChannelItemModel *itemModel = nofi.object;
    if (itemModel) {
        if ([itemModel.idx isEqualToString:self.itemModel.idx]) {
            [self requestOutfitsListData:YES];
        }
    }
}


/**
 接收通知传过来的model StyleLikesModel
 */
- (void)likeStatusChangeValue:(NSNotification *)nofi
{
    ZFCommunityStyleLikesModel *likesModel = nofi.object;
    //遍历当前列表数组找到相同reviewId改变点赞按钮状态并且增加或减少点赞数
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityOutfitsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.reviewId isEqualToString:likesModel.reviewId]) {
            if (likesModel.isLiked) {
                obj.likeCount = [NSString stringWithFormat:@"%d", [obj.likeCount intValue]+1];
            }else{
                obj.likeCount = [NSString stringWithFormat:@"%d", [obj.likeCount intValue]-1];
            }
            obj.liked = [NSString stringWithFormat:@"%d",likesModel.isLiked];
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

/** 设置置顶数据 */
- (void)setTopData:(NSArray *)dataSource{
    NSMutableArray *topArray = [NSMutableArray array];
    NSMutableArray *otherArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < dataSource.count; i++) {
        ZFCommunityOutfitsModel *model = dataSource[i];
        
        if (model.is_top) {
            [topArray addObject:model];
        }else{
            [otherArray addObject:model];
        }
    }
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:topArray];
    [self.dataArray addObjectsFromArray:otherArray];
}

- (void)requestOutfitsListData:(BOOL)firstPage{
    
    self.hasRequest = YES;
    [self.outfitsViewModel requestOutfitsListData:firstPage completion:^(NSArray<ZFCommunityOutfitsModel *> *outfitsListArray, NSDictionary *pageInfo) {
        
        self.baseCollectionView.backgroundView = nil;
        
        if (firstPage) {
            [self.colorSet removeAllObjects];
        }
        
        if (ZFJudgeNSArray(outfitsListArray)) {
            
            for (ZFCommunityOutfitsModel *itemModel in outfitsListArray) {
                NSString *colorString =  [ZFThemeManager randomColorString:self.colorSet];
                if (self.colorSet.count == 3) {
                    [self.colorSet removeObjectAtIndex:0];
                }
                [self.colorSet addObject:colorString];
                itemModel.randomColor = [UIColor colorWithHexString:colorString];
            }
        }
        
        if (firstPage && outfitsListArray) {
            [self setTopData:outfitsListArray];
        }else{
            [self.dataArray addObjectsFromArray:outfitsListArray];
        }
        
        [self.baseCollectionView reloadData];
        [self.baseCollectionView showRequestTip:pageInfo];
    }];
}


- (void)tapNavBarCanMoveTop:(BOOL)canMove {
    self.baseCollectionView.scrollsToTop = canMove;
}

- (BOOL)collectionViewScrollsTopState {
    return self.baseCollectionView.scrollsToTop;
}

#pragma mark - private methods
- (void)communityOutfitsLikeOptionWithModel:(ZFCommunityOutfitsModel *)model andIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = @{kRequestModelKey : model,
                          kLoadingView : self};
    [self.outfitsViewModel requestLikeNetwork:dic completion:^(id obj) {
        
    } failure:^(id obj) {
        
    }];
    
    // firebase
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"click_outfits_topic_like_%@", model.reviewId] itemName:@"topic_like" ContentType:@"community_like" itemCategory:@"Button"];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    collectionView.mj_footer.hidden = self.dataArray.count == 0;
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityOutfitsListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommunityOutfitsListCell class]) forIndexPath:indexPath];
    if (self.dataArray.count > indexPath.row) {
        cell.model = self.dataArray[indexPath.row];
    }
    @weakify(self);
    cell.communityOutfitsLikeCompletionHandler = ^(ZFCommunityOutfitsModel *model) {
        @strongify(self);
        
        @weakify(self)
//        [self.viewController judgePresentLoginVCCompletion:^{
//            @strongify(self)
//            [self communityOutfitsLikeOptionWithModel:model andIndexPath:indexPath];
//        }];
        [self.viewController judgePresentLoginVCChooseType:YWLoginEnterTypeLogin comeFromType:YWLoginViewControllerEnterTypeCommunityHomePage Completion:^{
            @strongify(self)
            [self communityOutfitsLikeOptionWithModel:model andIndexPath:indexPath];
        }];
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = (KScreenWidth - 10*3)/2 + 60;
    return CGSizeMake((KScreenWidth - 10*3)/2, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    if (self.dataArray.count > indexPath.row) {
        ZFCommunityOutfitsModel *model = self.dataArray[indexPath.row];

        ZFCommunityPostDetailPageVC *detailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:model.reviewId title:model.reviewTitle];
        detailViewController.isOutfits = YES;
        detailViewController.sourceType = ZFAppsflyerInSourceTypeZMeOutfitid;
        [self.viewController.navigationController pushViewController:detailViewController animated:YES];
    }
    
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
            [[NSNotificationCenter defaultCenter] postNotificationName:kCommunityExploreScrollStatus object:@(YES)];
            [self tapNavBarCanMoveTop:NO];
            self.baseCollectionView.contentOffset = CGPointZero;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.baseCollectionView]) {
        self.lastOffSetY = scrollView.contentOffset.y;
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.baseCollectionView];
}

- (void)zfAutoLayoutView {
    [self.baseCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsZero);
    }];
}

- (ZFCommunityOutfitsListViewModel *)outfitsViewModel{
    if (!_outfitsViewModel) {
        _outfitsViewModel = [[ZFCommunityOutfitsListViewModel alloc] init];
    }
    return _outfitsViewModel;
}

-(ZFCommunityGestureCollectionView *)baseCollectionView{
    if (!_baseCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _baseCollectionView = [[ZFCommunityGestureCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _baseCollectionView.showsVerticalScrollIndicator = YES;
        _baseCollectionView.showsHorizontalScrollIndicator = NO;
        _baseCollectionView.delegate = self;
        _baseCollectionView.dataSource = self;
        //_showsCollectionView.bounces = NO;
        _baseCollectionView.backgroundView = [UIView zfLoadingView];
        _baseCollectionView.scrollsToTop = NO;

        
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10,10);
        _baseCollectionView.backgroundColor = ZFC0xF2F2F2();
        [_baseCollectionView registerClass:[ZFCommunityOutfitsListCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityOutfitsListCell class])];
        
        _baseCollectionView.requestFailBtnTitle = ZFLocalizedString(@"EmptyCustomViewManager_refreshButton",nil);
        @weakify(self)
        _baseCollectionView.blankPageViewActionBlcok = ^(ZFBlankPageViewStatus status) {
            @strongify(self)
            [self requestOutfitsListData:YES];
        };
        
        _baseCollectionView.mj_footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self requestOutfitsListData:NO];
        }];
    }
    return _baseCollectionView;
}

- (ZFCommunityHomeOutfitsAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFCommunityHomeOutfitsAOP alloc] initChannelId:self.itemModel.idx];
        [_analyticsAOP baseConfigureChannelId:self.itemModel.idx channelName:self.itemModel.cat_name];
    }
    return _analyticsAOP;
}

@end
