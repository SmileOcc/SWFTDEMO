//
//  ZFCollectionPostsOutfitView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCollectionPostsOutfitView.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFInitViewProtocol.h"
#import "UIView+ZFViewCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "ZFProgressHUD.h"

#import "ZFCollectionPostCCell.h"
#import "ZFCommunityPostDetailPageVC.h"

#import "ZFCollectionViewModel.h"
#import "ZFCollectionPostAnalyticsAOP.h"

@interface ZFCollectionPostsOutfitView ()
<ZFInitViewProtocol,
UIScrollViewDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
CHTCollectionViewDelegateWaterfallLayout
>

@property (nonatomic, strong) ZFCollectionViewModel                                    *viewModel;
@property (nonatomic, strong) ZFCollectionPostListModel                                *listModel;
@property (nonatomic, strong) CHTCollectionViewWaterfallLayout                         *flowLayout;
@property (nonatomic, strong) UICollectionView                                         *collectionView;
@property (nonatomic, strong) ZFCollectionPostAnalyticsAOP            *analyticsAOP;

@end

@implementation ZFCollectionPostsOutfitView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];

        [self zfInitView];
        [self zfAutoLayoutView];
        [self addObserver];
    }
    return self;
}

- (void)viewWillShow {
    if (!_viewModel) {
        [self requestPost:YES];
    }
}

- (void)addObserver {
    // 帖子详情页收藏通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshCollectPost:) name:kCollectionPostsNotification object:nil];
}


#pragma mark - <ZFInitViewProtocol>
-(void)zfInitView {
    [self addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}


- (void)refreshCollectPost:(NSNotification *)notif {
    [self requestPost:YES];
}

#pragma mark - request
- (void)requestPost:(BOOL)refresh {
    
    if ([AccountManager sharedManager].isSignIn) {
        @weakify(self)
        [self.viewModel requestCollectPostPageData:refresh type:@"1" completion:^(ZFCollectionPostListModel *listModel, NSArray *currentPageArray, NSDictionary *pageInfo) {
            @strongify(self)
            self.listModel = listModel;
            [self.collectionView reloadData];
            [self.collectionView showRequestTip:pageInfo];
        }];
        
    } else {
        //处理数据空白页
        [self.collectionView showRequestTip:@{}];
    }
}
#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listModel.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFCollectionPostCCell *postCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFCollectionPostCCell.class) forIndexPath:indexPath];
    if (self.listModel.list.count > indexPath.row) {
        ZFCollectionPostItemModel *postModel = self.listModel.list[indexPath.row];
        postCell.model = postModel;
    }
    return postCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (self.listModel.list.count > indexPath.row) {
        ZFCollectionPostItemModel *postModel = self.listModel.list[indexPath.row];
        ZFCommunityPostDetailPageVC *detailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:postModel.idx title:postModel.title];
        //v4.7.0 不设置来源
        //detailViewController.sourceType = ZFAppsflyerInSourceTypeZMeExploreid;
        
        [self.viewController.navigationController pushViewController:detailViewController animated:YES];
    }
}

#pragma mark - UICollectionDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.listModel.list.count > indexPath.row) {
        ZFCollectionPostItemModel *postModel = self.listModel.list[indexPath.row];
        ZFCollectionPostReviewPicModel *picModel = postModel.reviewPic.firstObject;
        
        CGFloat item_w = (KScreenWidth - 2 * 12 - 13) / 2.0;
        CGFloat item_h = 0;
        if ([picModel.big_pic_width floatValue] > 0) {
            item_h = item_w * [picModel.big_pic_height floatValue] / [picModel.big_pic_width floatValue];
        }
        return CGSizeMake(item_w, item_h);
    }
    
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(12, 12, 12, 12);
}

#pragma mark - Property Method

- (ZFCollectionViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCollectionViewModel alloc] init];
    }
    return _viewModel;
}

- (ZFCollectionPostListModel *)listModel {
    if (!_listModel) {
        _listModel = [[ZFCollectionPostListModel alloc] init];
    }
    return _listModel;
}


- (CHTCollectionViewWaterfallLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[CHTCollectionViewWaterfallLayout alloc] init];
        _flowLayout.minimumColumnSpacing = 13;
        _flowLayout.minimumInteritemSpacing = 12;
        _flowLayout.headerHeight = 0;
    }
    return _flowLayout;
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[ZFCollectionPostCCell class] forCellWithReuseIdentifier:NSStringFromClass(ZFCollectionPostCCell.class)];
        _collectionView.blankPageViewCenter = CGPointMake(KScreenWidth / 2.0, 150);
        //        _collectionView.emptyDataImage = [UIImage imageNamed:@"blankPage_noPicture"];
        //        [_collectionView registerClass:[ZFCommunityCategoryPostListCell class] forCellWithReuseIdentifier:NSStringFromClass(ZFCommunityCategoryPostListCell.class)];
        
        
        //处理数据空白页
        _collectionView.emptyDataImage = [UIImage imageNamed:@"blankPage_favorites"];
        _collectionView.emptyDataTitle = ZFLocalizedString(@"Collection_empty_tip",nil);
        
        @weakify(self);
        [_collectionView addHeaderRefreshBlock:^{
            @strongify(self);
            [self requestPost:YES];
            
        } footerRefreshBlock:^{
            @strongify(self);
            [self requestPost:NO];
        } startRefreshing:NO];
        
    }
    return _collectionView;
}

- (ZFCollectionPostAnalyticsAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFCollectionPostAnalyticsAOP alloc] init];
        [_analyticsAOP baseConfigureSource:ZFAnalyticsAOPSourceDefault analyticsId:NSStringFromClass(ZFCollectionPostsOutfitView.class)];
    }
    return _analyticsAOP;
}
@end
