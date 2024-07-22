//
//  ZFCommunityLiveVideoActivityView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveVideoActivityView.h"

#import "ZFInitViewProtocol.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "Masonry.h"

#import "ZFCommunityLiveVideoActivityCCell.h"

#import "ZFCommunityLiveVideoActivityModel.h"

@interface ZFCommunityLiveVideoActivityView()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
ZFInitViewProtocol,
CHTCollectionViewDelegateWaterfallLayout
>

@property (nonatomic, strong) UICollectionView                      *collectionView;

@property (nonatomic, strong) ZFCommunityLiveVideoActivityModel     *liveActivityViewModel;

@property (nonatomic, assign) BOOL                                  isDraging;

@property (nonatomic, assign) CGFloat                               contentOffsetY;

@end

@implementation ZFCommunityLiveVideoActivityView

- (instancetype)initWithFrame:(CGRect)frame cateName:(NSString *)cateName cateID:(NSString *)cateID {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfViewWillAppear {
    
}

- (void)zfInitView {
    [self addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)fullScreen:(id)isFull {
    if (![isFull boolValue]) {
        [self scrollCurrentContnetOffSetY];
    }
}

- (void)scrollCurrentContnetOffSetY {
    if (self.contentOffsetY > 0) {
        [self.collectionView setContentOffset:CGPointMake(0, self.contentOffsetY) animated:NO];
    }
}

- (void)updateHotActivity:(NSArray<ZFCommunityLiveVideoRedNetModel *>*)activityModel {
    if (ZFJudgeNSArray(activityModel)) {
        self.liveActivityViewModel.datasArray = [[NSMutableArray alloc] initWithArray:activityModel];
        [self.collectionView reloadData];
        self.contentOffsetY = self.collectionView.contentOffset.y;
    }
    
    [self.collectionView showRequestTip:@{kTotalPageKey  : @(1),
                                          kCurrentPageKey: @(1)}];
}

- (void)requestLiveGoodsPageData:(BOOL)isFirstPage {
    // 不请求数据
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.liveActivityViewModel.datasArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFCommunityLiveVideoActivityCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommunityLiveVideoActivityCCell class]) forIndexPath:indexPath];
    
    if (self.liveActivityViewModel.datasArray.count > indexPath.section) {
        ZFCommunityLiveVideoRedNetModel *activityModel = self.liveActivityViewModel.datasArray[indexPath.section];
        cell.redNetModel = activityModel;
    }
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.liveActivityViewModel.datasArray.count > indexPath.section) {
        ZFCommunityLiveVideoRedNetModel *activityModel = self.liveActivityViewModel.datasArray[indexPath.section];
        
        if (self.liveVideoBlock) {
            self.liveVideoBlock(ZFToString(activityModel.link_url));
        }
    }
}


#pragma mark -===CHTCollectionViewDelegateWaterfallLayout===


/**
 * 每个Item的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.liveActivityViewModel.datasArray.count > indexPath.section) {
        ZFCommunityLiveVideoRedNetModel *activityModel = self.liveActivityViewModel.datasArray[indexPath.section];
        if ([activityModel.pic_width floatValue] > 0) {
            return CGSizeMake(KScreenWidth, KScreenWidth * [activityModel.pic_height floatValue] / [activityModel.pic_width floatValue]);
        }
    }
    return CGSizeZero;
}

/**
 * 每个section之间的缩进间距
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(12, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section {
    return  0;
}

#pragma mark - UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetY = scrollView.contentOffset.y;
    YWLog(@"------- %f",offsetY);
    
    if (self.isDraging) {// 这个只处理拖拽
        self.contentOffsetY = offsetY;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    YWLog(@"-----scrollViewDidEndDecelerating：%f",scrollView.contentOffset.y);
    self.contentOffsetY = scrollView.contentOffset.y;
    
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    self.isDraging = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isDraging = YES;
}
#pragma mark - Property Method

- (ZFCommunityLiveVideoActivityModel *)liveActivityViewModel {
    if (!_liveActivityViewModel) {
        _liveActivityViewModel = [[ZFCommunityLiveVideoActivityModel alloc] init];
    }
    return _liveActivityViewModel;
}


- (UICollectionView *)collectionView {
    if(!_collectionView){
        
        CHTCollectionViewWaterfallLayout *waterfallLayout = [[CHTCollectionViewWaterfallLayout alloc] init]; //创建布局
        waterfallLayout.minimumColumnSpacing = 13;
        waterfallLayout.minimumInteritemSpacing = 0;
        waterfallLayout.headerHeight = 0;
        waterfallLayout.columnCount = 1;
        
        
        CGRect frameRect = self.bounds;
        if (CGSizeEqualToSize(frameRect.size, CGSizeZero)) {
            frameRect = CGRectMake(0, 0, KScreenWidth, KScreenHeight - 150);
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:frameRect collectionViewLayout:waterfallLayout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceVertical = YES;
        
        _collectionView.emptyDataImage = ZFImageWithName(@"blankPage_noImages");
        _collectionView.emptyDataTitle = ZFLocalizedString(@"Community_LivesVideo_Host_Forgot_Introduce_msg", nil);

        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_collectionView registerClass:[ZFCommunityLiveVideoActivityCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityLiveVideoActivityCCell class])];
    }
    return _collectionView;
}

@end
