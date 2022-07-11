//
//  OSSVAccountsTableFootView.m
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVAccountsTableFootView.h"
#import "OSSVAccountsGoodsListsView.h"

@interface STLAccountFooterScrollView : UIScrollView<UIGestureRecognizerDelegate>
@end

@implementation STLAccountFooterScrollView

///此方法是支持多手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.view isKindOfClass:[UICollectionView class]]) {
        return NO;
    }
    return YES;
}
@end



@interface OSSVAccountsTableFootView () <UIScrollViewDelegate >
@property (nonatomic, strong) STLAccountFooterScrollView     *horizontalScrollView;
@property (nonatomic, strong) OSSVAccountsGoodsListsView        *recommendListView;
@property (nonatomic, strong) OSSVAccountsGoodsListsView        *historyListView;
@property (nonatomic, copy) SelectedGoodsBlock              selectedGoodsBlock;
@property (nonatomic, assign) NSInteger                     curreentPage;
@end

@implementation OSSVAccountsTableFootView

- (instancetype)initWithFrame:(CGRect)frame
           selectedGoodsBlock:(SelectedGoodsBlock)selectedGoodsBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedGoodsBlock = selectedGoodsBlock;
        [self stlInitView];
    }
    return self;
}

- (void)selectCustomIndex:(NSInteger)index{
    
    if (index == -1) return;

    [self.horizontalScrollView scrollRectToVisible:CGRectMake(index * SCREEN_WIDTH , 0, SCREEN_WIDTH, self.frame.size.height) animated:YES];

    [self currentViewFirstRequest:index];

}

- (void)currentViewFirstRequest:(NSInteger)index{
    
    OSSVAccountsGoodsListsView *subShowView = [self.horizontalScrollView viewWithTag:(21200 + index)];
    
    // handling collectionView scrollsToTop state
    if ([subShowView respondsToSelector:@selector(collectionViewScrollsTopState)]) {
        BOOL scrolleTopState = [subShowView collectionViewScrollsTopState];
        if ([self.superview isKindOfClass:[UITableView class]]) {
            UITableView *superTable = (UITableView *)self.superview;
            //superTable.scrollsToTop = !scrolleTopState;
            
            if (superTable.superview && [superTable.superview isKindOfClass:[OSSVAccountsMainsView class]]) {
                OSSVAccountsMainsView *accountMainView = (OSSVAccountsMainsView *)superTable.superview;
                accountMainView.canScroll = !scrolleTopState;
            }
        }
    }
    if ([subShowView respondsToSelector:@selector(startFirstRequest)]) {
        [subShowView startFirstRequest];
    }
}


- (void)refreshHistoryListData {
    if (_historyListView) {
        [self.historyListView refreshRecentlyData];
    }
}

- (void)refreshRecommendToFirst {
    [self.recommendListView resetPageIndexToFirst];
}

- (void)setScrollToTopAction {
    if (self.curreentPage == 0) {
        [self.historyListView.collectionView setContentOffset:CGPointZero animated:YES];
    } else {
        [self.recommendListView.collectionView setContentOffset:CGPointZero animated:YES];
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat width = scrollView.bounds.size.width;
    if (width == 0) {
        width = SCREEN_WIDTH;
    }
    NSInteger curreentPage = scrollView.contentOffset.x / width;
    if (self.selectIndexCompletion) {
        self.selectIndexCompletion(curreentPage);
    }
    self.curreentPage = curreentPage;
}

#pragma mark - <STLInitViewProtocol>

- (void)stlInitView{
    [self addSubview:self.horizontalScrollView];
    
    CGFloat height = self.frame.size.height;
    NSInteger typeCount = 2;
    for (int i=0; i< typeCount; i++) {
        CGRect rect = CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, height);
        if (i == 0) { //history
            self.historyListView.frame = rect;
            self.historyListView.tag = 21200 + i;
        } else if (i == 1) { // recommend
            self.recommendListView.frame = rect;
            self.recommendListView.tag = 21200 + i;
        }
    }
    self.horizontalScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * typeCount, height);
}

-(STLAccountFooterScrollView *)horizontalScrollView {
    if (!_horizontalScrollView) {
        _horizontalScrollView = [[STLAccountFooterScrollView alloc] initWithFrame:self.bounds];
        _horizontalScrollView.showsVerticalScrollIndicator = NO;
        _horizontalScrollView.showsHorizontalScrollIndicator = NO;
        _horizontalScrollView.delegate = self;
        _horizontalScrollView.pagingEnabled = YES;
        _horizontalScrollView.bounces = NO;
        _horizontalScrollView.backgroundColor = [UIColor whiteColor];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _horizontalScrollView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _horizontalScrollView;
}

- (OSSVAccountsGoodsListsView *)recommendListView {
    if (!_recommendListView) {
        _recommendListView = [[OSSVAccountsGoodsListsView alloc] initWithFrame:self.bounds dataType:AccountGoodsListTypeRecommend];
        _recommendListView.selectedGoodsBlock = self.selectedGoodsBlock;
        [self.horizontalScrollView addSubview:_recommendListView];
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _recommendListView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _recommendListView;
}

- (OSSVAccountsGoodsListsView *)historyListView {
    if (!_historyListView) {
        _historyListView = [[OSSVAccountsGoodsListsView alloc] initWithFrame:self.bounds dataType:AccountGoodsListTypeHistory];
        _historyListView.selectedGoodsBlock = self.selectedGoodsBlock;
        [self.horizontalScrollView addSubview:_historyListView];
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _historyListView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _historyListView;
}


@end
