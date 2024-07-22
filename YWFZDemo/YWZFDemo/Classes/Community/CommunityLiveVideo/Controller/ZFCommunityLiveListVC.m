//
//  ZFCommunityLiveVideoListVC.m
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveListVC.h"
#import "ZFInitViewProtocol.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "ZFThemeManager.h"

#import "ZFCommunityLiveVideoVC.h"
#import "ZFCommunityFullLiveVideoVC.h"

#import "ZFCommunityLiveLivingCCell.h"
#import "ZFCommunityLiveVideoCCell.h"
#import "ZFCommunityLiveLlistHeaderView.h"

#import "ZFCommunityLiveViewModel.h"

@interface ZFCommunityLiveListVC ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
ZFInitViewProtocol
>

@property (nonatomic, strong) UICollectionView                      *collectionView;

@property (nonatomic, strong) ZFCommunityLiveViewModel              *liveViewModel;

@end

@implementation ZFCommunityLiveListVC

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestLivePageData:YES showLoad:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = ZFLocalizedString(@"Community_LivesListVC_Title", nil);
    
    self.view.backgroundColor = ZFC0xFFFFFF();
    [self zfInitView];
    [self zfAutoLayoutView];
    
    [self requestLivePageData:YES showLoad:YES];
}

- (void)zfInitView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)requestLivePageData:(BOOL)isFirstPage showLoad:(BOOL)isShow{
    
    if (isFirstPage && isShow) {
        ShowLoadingToView(self.view);
    }
    @weakify(self);
    [self.liveViewModel requestCommunityLiveListisFirstPage:isFirstPage completion:^(NSDictionary * _Nonnull pageInfo) {
        @strongify(self);
        HideLoadingFromView(self.view);

        [self.collectionView reloadData];
        [self.collectionView showRequestTip:pageInfo];
    }];
 
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.liveViewModel.live_list.count;
    }
    return self.liveViewModel.end_live_list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFCommunityLiveListModel *liveItemModel;
    
    if (indexPath.section == 0) {//直播中
    
        if (self.liveViewModel.live_list.count > indexPath.row) {
            liveItemModel = self.liveViewModel.live_list[indexPath.row];
            liveItemModel.section = indexPath.section;
        }
        
        ZFCommunityLiveLivingCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommunityLiveLivingCCell class]) forIndexPath:indexPath];
        cell.liveItemModel = liveItemModel;
        return cell;
    }

    // 录像
    if (self.liveViewModel.end_live_list.count > indexPath.row) {
        liveItemModel = self.liveViewModel.end_live_list[indexPath.row];
        liveItemModel.section = indexPath.section;
    }

    ZFCommunityLiveLivingCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommunityLiveLivingCCell class]) forIndexPath:indexPath];
    cell.liveItemModel = liveItemModel;

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    ZFCommunityLiveLlistHeaderView *headView = [ZFCommunityLiveLlistHeaderView headWithCollectionView:collectionView Kind:kind IndexPath:indexPath];
    if ([kind isEqualToString: UICollectionElementKindSectionHeader] ) {

        if (indexPath.section == 0) {
            headView.title = ZFLocalizedString(@"Community_Lives_Livestreams", nil);
            [headView updateLeftImage:ZFImageWithName(@"community_live_header_left") rightImage:ZFImageWithName(@"community_live_header_right")];
        } else {
            headView.title = ZFLocalizedString(@"Community_Lives_Videos", nil);
            [headView updateLeftImage:ZFImageWithName(@"community_replay_left") rightImage:ZFImageWithName(@"community_replay_right")];
        }
    }
    return headView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFCommunityLiveListModel *liveItemModel;
    if (indexPath.section == 0) {
        if (self.liveViewModel.live_list.count > indexPath.row) {
            liveItemModel = self.liveViewModel.live_list[indexPath.row];
        }
        
    } else if (indexPath.section == 1) {
        if (self.liveViewModel.end_live_list.count > indexPath.row) {
            liveItemModel = self.liveViewModel.end_live_list[indexPath.row];
        }
    }
    
    
    if ([liveItemModel.live_platform integerValue] == ZFCommunityLivePlatformZego || [liveItemModel.live_platform integerValue] == ZFCommunityLivePlatformThirdStream) {
        
        ZFCommunityLiveLivingCCell *cell = (ZFCommunityLiveLivingCCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
     
        ZFCommunityFullLiveVideoVC *fullLiveVC = [[ZFCommunityFullLiveVideoVC alloc] init];
        fullLiveVC.coverImage = cell.coverImageView.image;
        fullLiveVC.videoModel = liveItemModel;
        [self.navigationController pushViewController:fullLiveVC animated:YES];
        return;
    }
    
    ZFCommunityLiveVideoVC *videoVC = [[ZFCommunityLiveVideoVC alloc] init];
    
    videoVC.videoModel = liveItemModel;
    
    @weakify(self);
    videoVC.playNeedStatisticsBlock = ^(ZFCommunityLiveListModel *videoModel) {
        @strongify(self);
        [self refreshCellStatisticsState:videoModel];
    };
    
    videoVC.playStatusBlock = ^(ZFCommunityLiveListModel *videoModel) {
        @strongify(self);
        [self refreshCellPlayState:videoModel];
    };
    
    [self.navigationController pushViewController:videoVC animated:YES];
}

- (void)refreshCellStatisticsState:(ZFCommunityLiveListModel *)videoModel{
    
    if (ZFIsEmptyString(videoModel.idx)) {
        return;
    }
    __block NSInteger indexPathRow = -1;
    
    if (videoModel.section == 0) {
        [self.liveViewModel.live_list enumerateObjectsUsingBlock:^(ZFCommunityLiveListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.idx isEqualToString:ZFToString(videoModel.idx)]) {
                indexPathRow = idx;
                obj.view_num = videoModel.view_num;
                obj.format_view_num = videoModel.format_view_num;
                *stop = YES;
            }
        }];
    }
    
    if (videoModel.section == 1) {
        [self.liveViewModel.end_live_list enumerateObjectsUsingBlock:^(ZFCommunityLiveListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.idx isEqualToString:ZFToString(videoModel.idx)]) {
                indexPathRow = idx;
                obj.view_num = videoModel.view_num;
                obj.format_view_num = videoModel.format_view_num;
                *stop = YES;
            }
        }];
    }
    
    
    
    if (indexPathRow >= 0 && self.liveViewModel.live_list.count > indexPathRow) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexPathRow inSection:0];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    
}

// 在组一播放中查找
- (void)refreshCellPlayState:(ZFCommunityLiveListModel *)videoModel {
    
    if (ZFIsEmptyString(videoModel.idx)) {
        return;
    }
    __block NSInteger indexPathRow = -1;
    
    if (videoModel.section == 0) {
        [self.liveViewModel.live_list enumerateObjectsUsingBlock:^(ZFCommunityLiveListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.idx isEqualToString:ZFToString(videoModel.idx)]) {
                indexPathRow = idx;
                obj.state = videoModel.state;
                obj.like_num = videoModel.like_num;
                *stop = YES;
            }
        }];
    }
    
    if (videoModel.section == 1) {
        [self.liveViewModel.end_live_list enumerateObjectsUsingBlock:^(ZFCommunityLiveListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.idx isEqualToString:ZFToString(videoModel.idx)]) {
                indexPathRow = idx;
                obj.state = videoModel.state;
                obj.like_num = videoModel.like_num;
                *stop = YES;
            }
        }];
    }
    
    
    
    if (indexPathRow >= 0 && self.liveViewModel.live_list.count > indexPathRow) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexPathRow inSection:0];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}


#pragma mark -===CHTCollectionViewDelegateWaterfallLayout===


/**
 * 每个Item的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFCommunityLiveListModel *liveItemModel;
    if (indexPath.section == 0) {
        if (self.liveViewModel.live_list.count > indexPath.row) {
            liveItemModel = self.liveViewModel.live_list[indexPath.row];
            return liveItemModel.oneColumnCellSize;
        }
        
    } else if (indexPath.section == 1) {
        if (self.liveViewModel.end_live_list.count > indexPath.row) {
            liveItemModel = self.liveViewModel.end_live_list[indexPath.row];
            return liveItemModel.oneColumnCellSize;
        }
    }
    return CGSizeZero;
}

/**
 * 每个section之间的缩进间距
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 0, 12, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section {
    return  0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.liveViewModel.live_list.count <= 0 && section == 0) {
        return CGSizeZero;
    }
    if (self.liveViewModel.end_live_list.count <= 0 && section == 1) {
        return CGSizeZero;
    }
    return CGSizeMake(KScreenWidth, 45);
}


#pragma mark - XXX Action

#pragma mark - Private Method

#pragma mark - Public Method

#pragma mark - Property Method

- (ZFCommunityLiveViewModel *)liveViewModel {
    if (!_liveViewModel) {
        _liveViewModel = [[ZFCommunityLiveViewModel alloc] init];
    }
    return _liveViewModel;
}


- (UICollectionView *)collectionView {
    if(!_collectionView){
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 12;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.contentInset = UIEdgeInsetsMake(12, 12, 0, 12);
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_collectionView registerClass:[ZFCommunityLiveLivingCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityLiveLivingCCell class])];
        [_collectionView registerClass:[ZFCommunityLiveVideoCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityLiveVideoCCell class])];
        
        @weakify(self);
        [self.collectionView addCommunityHeaderRefreshBlock:^{
            @strongify(self);
            [self requestLivePageData:YES showLoad:NO];
            
            
        } footerRefreshBlock:^{
            @strongify(self);
            [self requestLivePageData:NO showLoad:NO];
            
        } startRefreshing:NO];
    }
    return _collectionView;
}


@end
