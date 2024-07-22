

//
//  ZFCommunityAccountShowView.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityAccountShowView.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityAccountShowCell.h"
#import "ZFCommunityShowViewModel.h"
#import "ZFCommunityAccountShowsListModel.h"
#import "ZFCommunityAccountShowsModel.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "ZFThemeManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

static NSString *const kZFCommunityAccountShowCellIdentifier = @"kZFCommunityAccountShowCellIdentifier";

@interface ZFCommunityAccountShowView () <ZFInitViewProtocol, UICollectionViewDataSource, UICollectionViewDelegate,CHTCollectionViewDelegateWaterfallLayout> {
    __block NSIndexPath *_currentIndexPath;
}
@property (nonatomic, strong) ZFCommunityShowViewModel          *viewModel;
@property (nonatomic, strong) ZFCommunityAccountShowsListModel  *showsListModel;
@property (nonatomic, strong) ZFCommunityAccountShowsModel      *deleteModel;
@property (nonatomic, strong) NSMutableArray<ZFCommunityAccountShowsModel *> *dataArray;

@property (nonatomic, strong) NSMutableArray *colorSet;


@end

@implementation ZFCommunityAccountShowView
#pragma mark - init methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addNotifycation];
    }
    return self;
}

#pragma mark -===========notification methods===========

- (void)addNotifycation {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStatusChangeValue:) name:kLikeStatusChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviewCountsChangeValue:) name:kReviewCountsChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteChangeValue:) name:kDeleteStatusChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kChangeUserInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutChangeValue:) name:kLogoutNotification object:nil];
}

- (void)loginChangeValue:(NSNotification *)nofi {
    [self.collectionView.mj_header beginRefreshing];
}

- (void)logoutChangeValue:(NSNotification *)nofi {
    [self.collectionView.mj_header beginRefreshing];
}

- (void)deleteChangeValue:(NSNotification *)nofi {
    [self.collectionView.mj_header beginRefreshing];
}

- (void)reviewCountsChangeValue:(NSNotification *)nofi {
    //接收通知传过来的model StyleLikesModel
    ZFCommunityAccountShowsModel *reviewsModel = nofi.object;
    //遍历当前列表数组找到相同reviewId增加评论数
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityAccountShowsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.reviewId isEqualToString:reviewsModel.reviewId]) {
            obj.replyCount = [NSString stringWithFormat:@"%d", [obj.replyCount intValue]+1];
        }
    }];
    [self.collectionView reloadData];
}

- (void)likeStatusChangeValue:(NSNotification *)nofi {
    //接收通知传过来的model StyleLikesModel
    ZFCommunityAccountShowsModel *likesModel = nofi.object;
    //遍历当前列表数组找到相同reviewId改变点赞按钮状态并且增加或减少点赞数
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityAccountShowsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [self.collectionView reloadData];
}

#pragma mark - private methods
- (void)communityAccountLikeWithModel:(ZFCommunityAccountShowsModel *)model
                         andIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    [self.controller.navigationController judgePresentLoginVCCompletion:^{
         @strongify(self);
         //请求点赞
         [self requestLike:model andIndexPath:indexPath];
     }];
}

/**
 * 请求点赞
 */
- (void)requestLike:(ZFCommunityAccountShowsModel *)model
       andIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = @{kRequestModelKey : model,
                          kLoadingView : self.controller.view};
//    @weakify(self);
    [self.viewModel requestLikeNetwork:dic completion:^(id obj) {
//        @strongify(self);
//        self.dataArray[indexPath.item].isLiked = !self.dataArray[indexPath.item].isLiked;
//        self.dataArray[indexPath.item].likeCount = [NSString stringWithFormat:@"%lu", [self.dataArray[indexPath.item].likeCount integerValue] + (self.dataArray[indexPath.item].isLiked ? 1 : -1)];
//        [self.collectionView reloadData];
    } failure:^(id obj) {
        //@strongify(self);
        //[self.collectionView reloadData];
    }];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(zf_accountShowView:collectionView:willDisplayCell:forItemAtIndexPath:)]) {
        [self.delegate zf_accountShowView:self collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (self.dataArray.count > indexPath.item) {
        ZFCommunityAccountShowsModel *model = self.dataArray[indexPath.item];
        if (self.communityAccountShowDetailCompletionHandler) {
            self.communityAccountShowDetailCompletionHandler(model.userId, model.reviewId);
        }
        
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if (self.delegate && [self.delegate respondsToSelector:@selector(zf_accountShowView:collectionView:didSelectItemCell:forItemAtIndexPath:)]) {
            [self.delegate zf_accountShowView:self collectionView:collectionView didSelectItemCell:cell forItemAtIndexPath:indexPath];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count <= indexPath.item) return nil;
    ZFCommunityAccountShowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCommunityAccountShowCellIdentifier forIndexPath:indexPath];
    
    if (self.dataArray.count > indexPath.item) {
        ZFCommunityAccountShowsModel *model = self.dataArray[indexPath.row];
        cell.showsModel = model;
    }
    
    @weakify(self);
    cell.communityAccountShowsLikeCompletionHandler = ^(ZFCommunityAccountShowsModel *model) {
        @strongify(self);
        [self communityAccountLikeWithModel:model andIndexPath:indexPath];
    };

    return cell;
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
    ZFCommunityAccountShowsModel *showsModel = self.dataArray[indexPath.item];
    if (showsModel) {
        return showsModel.twoColumnCellSize;
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

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    self.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
    [self addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 44, 0));
    }];
}

#pragma mark - getter

- (NSMutableArray *)colorSet {
    if (!_colorSet) {
        _colorSet = [[NSMutableArray alloc] init];
    }
    return _colorSet;
}

- (NSMutableArray<ZFCommunityAccountShowsModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (ZFCommunityShowViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityShowViewModel alloc] init];
    }
    return _viewModel;
}

- (ZFCommuntityCollectionView *)collectionView {
    if (!_collectionView) {
        CHTCollectionViewWaterfallLayout *collectionViewLayout = [[CHTCollectionViewWaterfallLayout alloc] init]; //创建布局
        
        _collectionView = [[ZFCommuntityCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:collectionViewLayout];
        _collectionView.backgroundColor = ZFCOLOR(247, 247, 247, 1);
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = YES;
        [_collectionView registerClass:[ZFCommunityAccountShowCell class] forCellWithReuseIdentifier:kZFCommunityAccountShowCellIdentifier];
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        //请求空数据,失败提示图片文案
        _collectionView.emptyDataImage = ZFImageWithName(@"blankPage_noImages");
        _collectionView.emptyDataTitle = ZFLocalizedString(@"ShowsViewModel_NoData_NotShowed", nil);
        _collectionView.emptyDataBtnTitle = ZFLocalizedString(@"EmptyCustomViewManager_refreshButton",nil);
        _collectionView.blankPageViewCenter = CGPointMake(KScreenWidth/2, KScreenHeight/3);
        
        @weakify(self);
        _collectionView.blankPageViewActionBlcok = ^(ZFBlankPageViewStatus status){
            @strongify(self);
            [self.collectionView.mj_header beginRefreshing];
        };
        
        //添加刷新控件,请求数据
        [_collectionView addCommunityHeaderRefreshBlock:^{
            @strongify(self);
            [self requestAccountShowListData:YES];
            
        } footerRefreshBlock:^{
            @strongify(self);
            [self requestAccountShowListData:NO];
        } startRefreshing:YES];
    }
    return _collectionView;
}

#pragma mark - 获取数据

/**
 * 请求数据
 */
- (void)requestAccountShowListData:(BOOL)isFirstPage
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(zf_accountShowView:requestAccountShowListData:)]) {
        [self.delegate zf_accountShowView:self requestAccountShowListData:isFirstPage];
    }
    NSArray *array = nil;
    if (isFirstPage) {
        array = @[self.userId ?: @"0", @(1)];
    } else {
        array = @[self.userId ?: @"0", @(self.showsListModel.curPage + 1)];
    }
    
    @weakify(self);
    [self.viewModel requestNetwork:array completion:^(id obj) {
        @strongify(self);
        
        if (isFirstPage) {
            [self.colorSet removeAllObjects];
        }
        self.showsListModel = obj;
        
        //防止添加空对象,计算瀑布流的高度
        if (self.showsListModel && self.showsListModel.list.count > 0) {
            self.showsListModel.list = [self calculateCellHeight:self.showsListModel.list];
        }
        
        if (isFirstPage) {
            self.dataArray = [NSMutableArray arrayWithArray:self.showsListModel.list];
            self.collectionView.mj_footer.hidden = YES;
        } else {
            if (self.showsListModel.list.count != 0) {
                [self.dataArray addObjectsFromArray:self.showsListModel.list];
            }
        }
        [self.collectionView reloadData];
        
        //处理空白页,和分页
        NSDictionary *pageDic  = @{kTotalPageKey:@(self.showsListModel.pageCount),
                                   kCurrentPageKey:@(self.showsListModel.curPage)};
        [self.collectionView showRequestTip:pageDic];
        
    } failure:^(id obj) {
        [self.collectionView reloadData];
        [self.collectionView showRequestTip:nil];
    }];
}

/**
 * 计算瀑布流的高度
 */
- (NSArray *)calculateCellHeight:(NSArray<ZFCommunityAccountShowsModel *> *)listArray
{
    if (listArray.count==0) return nil;
    
    for (ZFCommunityAccountShowsModel *showsModel in listArray) {
        //利用约束计算Cell大小
        [showsModel calculateCellSize];
        
        NSString *colorString =  [ZFThemeManager randomColorString:self.colorSet];
        if (self.colorSet.count == 3) {
            [self.colorSet removeObjectAtIndex:0];
        }
        [self.colorSet addObject:colorString];
        showsModel.randomColor = [UIColor colorWithHexString:colorString];
    }
    
    return listArray;
}

@end
