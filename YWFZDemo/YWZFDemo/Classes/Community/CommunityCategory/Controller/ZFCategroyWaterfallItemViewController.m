//
//  ZFCategroyWaterfallItemViewController.m
//  Zaful
//
//  Created by occ on 2018/8/15.
//  Copyright © 2018年 Zaful. All rights reserved.
//

#import "ZFCommunityPostCategroyItemsViewController.h"
#import "ZFCommunityTopicDetailViewController.h"
#import "ZFCommunityCategoryPostListCell.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "CHTCollectionViewWaterfallLayout.h"

#import "ZFInitViewProtocol.h"
#import "ZFCategroyPostListViewModel.h"

static NSString *const kZFCategoryPostListCellIdentifier = @"kZFCategoryPostListCellIdentifier";

@interface ZFCommunityPostCategroyItemsViewController ()
<
ZFInitViewProtocol,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
CHTCollectionViewDelegateWaterfallLayout
>

@property (nonatomic, strong) CHTCollectionViewWaterfallLayout            *flowLayout;
@property (nonatomic, strong) UICollectionView                            *listCollectionView;

@property (nonatomic, strong) ZFCategroyPostListViewModel                 *viewModel;
@property (nonatomic, strong) NSMutableArray <ZFCategoryPostItemModel *>  *datasArray;
@property (nonatomic, assign) BOOL                                        isFirst;
@end

@implementation ZFCommunityPostCategroyItemsViewController

#pragma mark - Life cycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = ZFCOLOR_WHITE;
    self.isFirst = YES;
    
    [self zfInitView];
    [self zfAutoLayoutView];
    
    //初始空时，不请求
    if (!ZFIsEmptyString(self.channelModel.channel_id)) {
        [self requestChannelPageData:[Refresh boolValue]];
    }
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
- (void)requestChannelPageData:(BOOL)refresh {
    
    if (refresh && self.isFirst) {
        self.isFirst = NO;
        ShowLoadingToView(self.view);
    }
    @weakify(self)
    [self.viewModel requestCategroyWaterItemListData:refresh catID:ZFToString(self.channelModel.channel_id) completion:^(NSArray *currentPageDataArr, NSDictionary *pageInfo) {
        @strongify(self)
        
        HideLoadingFromView(self.view);

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
    
    if (self.datasArray.count > indexPath.row) {
        ZFCategoryPostItemModel *postModel = self.datasArray[indexPath.row];
        ZFCategoryPostListCell *postCell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCategoryPostListCellIdentifier forIndexPath:indexPath];
        postCell.model = postModel;
        return postCell;
    }
    return [UICollectionViewCell new];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
   
    if (self.datasArray.count > indexPath.row) {
        ZFCategoryPostItemModel *postModel = self.datasArray[indexPath.row];
        
        ZFCommunityTopicDetailViewController *detailViewController = [[ZFCommunityTopicDetailViewController alloc] initWithReviewID:postModel.post_id userID:postModel.user_id title:postModel.title];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

#pragma mark - UICollectionDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.datasArray.count > indexPath.row) {
        ZFCategoryPostItemModel *postModel = self.datasArray[indexPath.row];
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

- (NSMutableArray<ZFCategoryPostItemModel *> *)datasArray {
    if (!_datasArray) {
        _datasArray = [[NSMutableArray alloc] init];
    }
    return _datasArray;
}

- (ZFCategroyPostListViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCategroyPostListViewModel alloc] init];
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
        [_listCollectionView registerClass:[ZFCategoryPostListCell class] forCellWithReuseIdentifier:kZFCategoryPostListCellIdentifier];
        
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
@end
