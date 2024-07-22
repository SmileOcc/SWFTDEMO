//
//  ZFCommunityPostCategoryItemsViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/8/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityPostCategoryItemsViewController.h"
#import "ZFCommunityPostDetailPageVC.h"

#import "ZFCommunityCategoryPostListCell.h"
#import "CHTCollectionViewWaterfallLayout.h"

#import "ZFInitViewProtocol.h"
#import "ZFCommunityCategroyPostListViewModel.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFCommunityPostCategoryAOP.h"

static NSString *const kZFCommunityCategoryPostListCellIdentifier = @"kZFCommunityCategoryPostListCellIdentifier";

@interface ZFCommunityPostCategoryItemsViewController ()
<
ZFInitViewProtocol,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
CHTCollectionViewDelegateWaterfallLayout
>

@property (nonatomic, strong) CHTCollectionViewWaterfallLayout                     *flowLayout;
@property (nonatomic, strong) UICollectionView                                     *listCollectionView;

@property (nonatomic, strong) ZFCommunityCategroyPostListViewModel                 *viewModel;
@property (nonatomic, strong) NSMutableArray <ZFCommunityCategoryPostItemModel *>  *datasArray;
@property (nonatomic, assign) BOOL                                                 hadRequest;
@property (nonatomic, strong) ZFCommunityPostCategoryAOP                           *analyticsAOP;


@end

@implementation ZFCommunityPostCategoryItemsViewController

#pragma mark - Life cycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];
    [self zfInitView];
    [self zfAutoLayoutView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - <ZFInitViewProtocol>
-(void)zfInitView {
    [self.view addSubview:self.listCollectionView];
}

- (void)zfAutoLayoutView {
    [self.listCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

#pragma mark - request

- (void)startRequestData {
    //初始空时，不请求
    if (!ZFIsEmptyString(self.channelModel.channel_id) && !self.hadRequest) {
        [self.listCollectionView.mj_header beginRefreshing];
    }
}

- (void)requestChannelPageData:(BOOL)refresh {
    self.hadRequest = YES;
    @weakify(self)
    [self.viewModel requestCategroyWaterItemListData:refresh catID:ZFToString(self.channelModel.channel_id) completion:^(NSArray *currentPageDataArr, NSDictionary *pageInfo) {
        @strongify(self)
        
        if (refresh) {
            [self.datasArray removeAllObjects];
            [self.datasArray addObjectsFromArray:currentPageDataArr];
            [self.listCollectionView reloadData];

        } else {
            [self.datasArray addObjectsFromArray:currentPageDataArr];

            NSInteger startIndex = self.datasArray.count - currentPageDataArr.count;
            NSMutableArray *newAddArray = [NSMutableArray array];
            for (int i = 0 ; i < currentPageDataArr.count; i++) {
                [newAddArray addObject:[NSIndexPath indexPathForItem:(startIndex+i) inSection:0]];
            }
            if (newAddArray.count > 0) {
                [self.listCollectionView performBatchUpdates:^{
                    [self.listCollectionView insertItemsAtIndexPaths:newAddArray];
                } completion:nil];
            }
        }

        [self.listCollectionView showRequestTip:pageInfo];
    }];
}


#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datasArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFCommunityCategoryPostListCell *postCell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCommunityCategoryPostListCellIdentifier forIndexPath:indexPath];
    if (self.datasArray.count > indexPath.row) {
        ZFCommunityCategoryPostItemModel *postModel = self.datasArray[indexPath.row];
        postCell.model = postModel;
    }
    return postCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
   
    if (self.datasArray.count > indexPath.row) {
        
        ZFCommunityCategoryPostItemModel *postModel = self.datasArray[indexPath.row];

        
        // 进入帖子详情需要带入所有相关联的帖子id
        BOOL hasStartIndex = NO;
        NSMutableArray *reviewIDArray = [NSMutableArray array];
        
        for (NSInteger i= indexPath.row; i<self.datasArray.count; i++) {
            ZFCommunityCategoryPostItemModel *showsModel = self.datasArray[i];
            if (hasStartIndex) {
                [reviewIDArray addObject:ZFToString(showsModel.post_id)];
                
            } else if ([postModel.post_id isEqualToString:showsModel.post_id]) {
                hasStartIndex = YES;
                [reviewIDArray addObject:ZFToString(showsModel.post_id)];
            }
        }
        
        ZFCommunityPostDetailPageVC *detailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:postModel.post_id title:postModel.title];

        detailViewController.sourceType = ZFAppsflyerInSourceTypeZMeExploreid;
        detailViewController.reviewIDArray = reviewIDArray;

        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

#pragma mark - UICollectionDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.datasArray.count > indexPath.row) {
        ZFCommunityCategoryPostItemModel *postModel = self.datasArray[indexPath.row];
        CGFloat item_w = (KScreenWidth - 2 * 12 - 13) / 2.0;
        CGFloat item_h = 0;
        if ([postModel.pic.width floatValue] > 0) {
            item_h = item_w * [postModel.pic.height floatValue] / [postModel.pic.width floatValue];
        }
        return CGSizeMake(item_w, item_h);
    }

    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(12, 12, 12, 12);
}

#pragma mark - getter

- (NSMutableArray<ZFCommunityCategoryPostItemModel *> *)datasArray {
    if (!_datasArray) {
        _datasArray = [[NSMutableArray alloc] init];
    }
    return _datasArray;
}

- (ZFCommunityCategroyPostListViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityCategroyPostListViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
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

- (UICollectionView *)listCollectionView {
    if (!_listCollectionView) {
        _listCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _listCollectionView.backgroundColor = ZFCOLOR_WHITE;
        _listCollectionView.showsVerticalScrollIndicator = NO;
        _listCollectionView.showsHorizontalScrollIndicator = NO;
        _listCollectionView.dataSource = self;
        _listCollectionView.delegate = self;
        _listCollectionView.blankPageViewCenter = CGPointMake(KScreenWidth / 2.0, (self.view.bounds.size.height) / 2.0 - self.tipMoveHeight);
        _listCollectionView.emptyDataImage = [UIImage imageNamed:@"blankPage_noPicture"];
        [_listCollectionView registerClass:[ZFCommunityCategoryPostListCell class] forCellWithReuseIdentifier:kZFCommunityCategoryPostListCellIdentifier];
        
        @weakify(self)
        ZFRefreshFooter *footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self requestChannelPageData:[LoadMore boolValue]];
        }];
        [_listCollectionView setMj_footer:footer];
        _listCollectionView.mj_footer.hidden = YES;
        
        ZFRefreshHeader *header = [ZFRefreshHeader headerWithRefreshingBlock:^{
            @strongify(self)
            [self requestChannelPageData:[Refresh boolValue]];
        }];
        
        [_listCollectionView setMj_header:header];
    }
    return _listCollectionView;
}

- (ZFCommunityPostCategoryAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFCommunityPostCategoryAOP alloc] init];
        [_analyticsAOP baseConfigureChannelId:self.channelModel.channel_id channelName:self.channelModel.cat_name];
    }
    return _analyticsAOP;
}
@end
