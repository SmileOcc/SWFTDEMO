
//  ZFCommunityFavesListView.m
//  ZZZZZ
//
//  Created by YW on 2017/7/26.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityAccountFavesView.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityAccountFavesCell.h"
#import "ZFCommunityFavesViewModel.h"
#import "ZFCommunityFavesItemModel.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "ZFCommunityStyleLikesModel.h"
#import "ZFThemeManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

static NSString *const kZFCommunityFavesListCellIdentifier = @"kZFCommunityFavesListCellIdentifier";

@interface ZFCommunityAccountFavesView () <ZFInitViewProtocol, UICollectionViewDataSource, UICollectionViewDelegate,CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) ZFCommunityFavesViewModel       *viewModel;
@property (nonatomic, strong) NSMutableArray<ZFCommunityFavesItemModel *> *dataArray;
@property (nonatomic, strong) NSMutableArray *colorSet;


@end

@implementation ZFCommunityAccountFavesView
#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addNotifycation];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - notification methods

- (void)addNotifycation {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFavesData) name:kRefreshPopularNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStatusChangeValue:) name:kFollowStatusChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStatusChangeValue:) name:kLikeStatusChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteChangeValue:) name:kDeleteStatusChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviewCountsChangeValue:) name:kReviewCountsChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kChangeUserInfoNotification object:nil];
}

- (void)loginChangeValue:(NSNotification *)nofi {
    [self.favesListView.mj_header beginRefreshing];
}

- (void)deleteChangeValue:(NSNotification *)nofi {
    [self.favesListView.mj_header beginRefreshing];
}

- (void)reviewCountsChangeValue:(NSNotification *)nofi {
    //接收通知传过来的model StyleLikesModel
    ZFCommunityFavesItemModel *reviewsModel = nofi.object;
    //遍历当前列表数组找到相同reviewId增加评论数
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityFavesItemModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.reviewId isEqualToString:reviewsModel.reviewId]) {
            obj.replyCount = [NSString stringWithFormat:@"%d", [obj.replyCount intValue]+1];
            NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.favesListView reloadItemsAtIndexPaths:@[reloadIndexPath]];
            });
            *stop = YES;
        }
    }];
}

- (void)likeStatusChangeValue:(NSNotification *)nofi {
    //接收通知传过来的model StyleLikesModel
    ZFCommunityStyleLikesModel *likesModel = nofi.object;
    //遍历当前列表数组找到相同reviewId改变点赞按钮状态并且增加或减少点赞数
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityFavesItemModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.reviewId isEqualToString:likesModel.reviewId]) {
            if (likesModel.isLiked) {
                obj.likeCount = [NSString stringWithFormat:@"%d", [obj.likeCount intValue]+1];
            }else{
                obj.likeCount = [NSString stringWithFormat:@"%d", [obj.likeCount intValue]-1];
            }
            obj.isLiked = likesModel.isLiked;
            NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.favesListView reloadItemsAtIndexPaths:@[reloadIndexPath]];
            });
            *stop = YES;
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
        [self.favesListView.mj_header beginRefreshing];
        return;
    }
    
    //遍历当前列表数组找到相同userId改变状态
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityFavesItemModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:followedUserId]) {
            obj.isFollow = isFollow;
            NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.favesListView reloadItemsAtIndexPaths:@[reloadIndexPath]];
            });
            *stop = YES;
        }
    }];
}

- (void)reloadFavesData {
    [self.favesListView.mj_header beginRefreshing];
}

#pragma mark - private methods
- (void)communityFavesLikeOptionWithModel:(ZFCommunityFavesItemModel *)model andIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = @{kRequestModelKey : model,
                          kLoadingView : self};
//    @weakify(self);
    [self.viewModel requestLikeNetwork:dic completion:^(id obj) {
//        @strongify(self);
//        self.dataArray[indexPath.item].isLiked = !self.dataArray[indexPath.item].isLiked;
//        ZFCommunityFavesItemModel *model = self.dataArray[indexPath.item];
//        model.likeCount = [NSString stringWithFormat:@"%lu", [model.likeCount integerValue] + (model.isLiked ? 1 : -1)];
//        self.dataArray[indexPath.item] = model;
//        [self.favesListView reloadItemsAtIndexPaths:@[indexPath]];
    } failure:^(id obj) {
    }];
}

- (void)addMoreFriendToSeeMoreFavesInfo {
    if (self.communityFavesAddMoreFriendsCompletionHandler) {
        self.communityFavesAddMoreFriendsCompletionHandler();
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zf_accountFavesView:collectionView:willDisplayCell:forItemAtIndexPath:)]) {
        [self.delegate zf_accountFavesView:self collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFCommunityAccountFavesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCommunityFavesListCellIdentifier forIndexPath:indexPath];
    if (self.dataArray.count > indexPath.item) {
        cell.favesModel = self.dataArray[indexPath.item];
    }
    
    @weakify(self);
    cell.communityFavesLikeCompletionHandler = ^(ZFCommunityFavesItemModel *model) {
        @strongify(self);
        [self communityFavesLikeOptionWithModel:model andIndexPath:indexPath];
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (self.dataArray.count > indexPath.item) {
        ZFCommunityFavesItemModel *model = self.dataArray[indexPath.item];
        ZFCommunityFavesItemModel *tempModel = [model mutableCopy];
        if (self.communityFavesListDetailCompletionHandler) {
            self.communityFavesListDetailCompletionHandler(tempModel.userId, tempModel.reviewId, tempModel.type);
        }
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(zf_accountFavesView:collectionView:didSelectItemCell:forItemAtIndexPath:)]) {
            [self.delegate zf_accountFavesView:self collectionView:collectionView didSelectItemCell:cell forItemAtIndexPath:indexPath];
        }
    }
}

#pragma mark -===CHTCollectionViewDelegateWaterfallLayout===

/**
 * 每个section中显示Item的列数, 默认为瀑布流显示两列
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section
{
    return 2;
}

/**
 * 每个Item的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count <= indexPath.item) return CGSizeZero;
    ZFCommunityFavesItemModel *favesModel = self.dataArray[indexPath.item];
    if (favesModel) {
        return favesModel.twoColumnCellSize;
    }
    return CGSizeZero;
}

/**
 * 每个section中item的横向间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

/**
 * 每个section中item的纵向间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumColumnSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

/**
 * 每个section之间的缩进间距
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark -<ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
    [self.contentView addSubview:self.favesListView];
}

- (void)zfAutoLayoutView {
    [self.favesListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsMake(0, 0, 44, 0));
    }];
}

#pragma mark - getter

- (NSMutableArray *)colorSet {
    if (!_colorSet) {
        _colorSet = [[NSMutableArray alloc] init];
    }
    return _colorSet;
}

- (ZFCommunityFavesViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityFavesViewModel alloc] init];
    }
    return _viewModel;
}

- (ZFCommuntityCollectionView *)favesListView {
    if (!_favesListView) {
        CHTCollectionViewWaterfallLayout *collectionViewLayout = [[CHTCollectionViewWaterfallLayout alloc] init]; //创建布局
        
        _favesListView = [[ZFCommuntityCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:collectionViewLayout];
        _favesListView.backgroundColor = ZFCOLOR(247, 247, 247, 1);
        _favesListView.dataSource = self;
        _favesListView.delegate = self;
        _favesListView.showsHorizontalScrollIndicator = NO;
        _favesListView.showsVerticalScrollIndicator = YES;
        [_favesListView registerClass:[ZFCommunityAccountFavesCell class] forCellWithReuseIdentifier:kZFCommunityFavesListCellIdentifier];
        
        if (@available(iOS 11.0, *)) {
            _favesListView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        //请求空数据,失败提示图片文案
        _favesListView.blankPageViewCenter = CGPointMake(KScreenWidth/2, KScreenHeight/4);
        _favesListView.emptyDataImage = ZFImageWithName(@"blankPage_noFaves");
        _favesListView.emptyDataTitle = ZFLocalizedString(@"FavesViewModel_NoData_Title",nil);;
        _favesListView.emptyDataBtnTitle = ZFLocalizedString(@"FavesViewModel_NoData_AddMoreFriends",nil);
        
        @weakify(self);
        _favesListView.blankPageViewActionBlcok = ^(ZFBlankPageViewStatus status){
            @strongify(self);
            [self addMoreFriendToSeeMoreFavesInfo];
        };
        
        //添加刷新控件,请求数据
        [_favesListView addCommunityHeaderRefreshBlock:^{
            @strongify(self);
            [self requestAccountFavesListData:YES];
            
        } footerRefreshBlock:^{
            @strongify(self);
            [self requestAccountFavesListData:NO];
        } startRefreshing:YES];
    }
    return _favesListView;
}

#pragma mark - 获取数据

/**
 * 请求数据
 */
- (void)requestAccountFavesListData:(BOOL)isFirstPage
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(zf_accountFavesView:requestAccountFavesListData:)]) {
        [self.delegate zf_accountFavesView:self requestAccountFavesListData:isFirstPage];
    }
    
    NSString *requestFalg = nil;
    if (isFirstPage) {
        requestFalg = Refresh;
    } else {
        requestFalg = LoadMore;
    }
    
    @weakify(self);
    [self.viewModel requestFavesListData:requestFalg userId:self.userId completion:^(id obj, NSDictionary *pageDic) {
        @strongify(self);
        
        if (isFirstPage) {
            [self.colorSet removeAllObjects];
            self.dataArray = obj;
            self.favesListView.mj_footer.hidden = YES;
        } else {
            if (![obj isEqual:NoMoreToLoad]) {
                self.dataArray = obj;
            }
        }
        
        for (ZFCommunityFavesItemModel *itemModel in self.dataArray) {
            
            NSString *colorString =  [ZFThemeManager randomColorString:self.colorSet];
            if (self.colorSet.count == 3) {
                [self.colorSet removeObjectAtIndex:0];
            }
            [self.colorSet addObject:colorString];
            itemModel.randomColor = [UIColor colorWithHexString:colorString];
        }
        
        [self.favesListView reloadData];
        //处理空白页,和分页
        [self.favesListView showRequestTip:pageDic];
        
    } failure:^(id obj) {
        @strongify(self);
        [self.favesListView reloadData];
        [self.favesListView showRequestTip:nil];
    }];
}

@end

