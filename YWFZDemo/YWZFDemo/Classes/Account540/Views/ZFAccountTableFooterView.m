//
//  ZFAccountTableFooterView.m
//  ZZZZZ
//
//  Created by YW on 2019/11/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountTableFooterView.h"
#import "ZFAccountGoodsListView.h"
#import "ZFFrameDefiner.h"
#import "ZFColorDefiner.h"
#import "Masonry.h"
#import "SystemConfigUtils.h"

@interface ZFAccountFooterScrollView : UIScrollView<UIGestureRecognizerDelegate>
@end

@implementation ZFAccountFooterScrollView

///此方法是支持多手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.view isKindOfClass:[UICollectionView class]]) {
        return NO;
    }
    return YES;
}
@end

@interface ZFAccountTableFooterView () <UIScrollViewDelegate >
@property (nonatomic, strong) ZFAccountFooterScrollView     *horizontalScrollView;
@property (nonatomic, strong) ZFAccountGoodsListView        *recommendListView;
@property (nonatomic, strong) ZFAccountGoodsListView        *historyListView;
@property (nonatomic, copy) SelectedGoodsBlock              selectedGoodsBlock;
@property (nonatomic, assign) NSInteger                     curreentPage;
@end

@implementation ZFAccountTableFooterView

- (instancetype)initWithFrame:(CGRect)frame
           selectedGoodsBlock:(SelectedGoodsBlock)selectedGoodsBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedGoodsBlock = selectedGoodsBlock;
        [self zfInitView];
    }
    return self;
}

- (void)selectCustomIndex:(NSInteger)index {
    [self.horizontalScrollView scrollRectToVisible:CGRectMake(index * KScreenWidth , 0, KScreenWidth, self.frame.size.height) animated:YES];
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
        [self.recommendListView.collectionView setContentOffset:CGPointZero animated:YES];
    } else {
        [self.historyListView.collectionView setContentOffset:CGPointZero animated:YES];
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat width = scrollView.bounds.size.width;
    if (width == 0) {
        width = KScreenWidth;
    }
    NSInteger curreentPage = scrollView.contentOffset.x / width;
    if (self.selectIndexCompletion) {
        self.selectIndexCompletion(curreentPage);
    }
    self.curreentPage = curreentPage;
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView{
    [self addSubview:self.horizontalScrollView];
    
    CGFloat height = self.frame.size.height;
    NSInteger typeCount = 2;
    for (int i=0; i< typeCount; i++) {
        CGRect rect = CGRectMake(i * KScreenWidth, 0, KScreenWidth, height);
        if (i == 0) { // recommend
            self.recommendListView.frame = rect;
            
        } else if (i == 1) { //history
            self.historyListView.frame = rect;
        }
    }
    self.horizontalScrollView.contentSize = CGSizeMake(KScreenWidth * typeCount, height);
}

-(ZFAccountFooterScrollView *)horizontalScrollView {
    if (!_horizontalScrollView) {
        _horizontalScrollView = [[ZFAccountFooterScrollView alloc] initWithFrame:self.bounds];
        _horizontalScrollView.showsVerticalScrollIndicator = NO;
        _horizontalScrollView.showsHorizontalScrollIndicator = NO;
        _horizontalScrollView.delegate = self;
        _horizontalScrollView.pagingEnabled = YES;
        _horizontalScrollView.bounces = NO;
        _horizontalScrollView.backgroundColor = [UIColor whiteColor];
        if ([SystemConfigUtils isRightToLeftShow]) {
            _horizontalScrollView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _horizontalScrollView;
}

- (ZFAccountGoodsListView *)recommendListView {
    if (!_recommendListView) {
        _recommendListView = [[ZFAccountGoodsListView alloc] initWithFrame:self.bounds dataType:ZFAccountSelect_RecommendType];
        _recommendListView.selectedGoodsBlock = self.selectedGoodsBlock;
        [self.horizontalScrollView addSubview:_recommendListView];
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            _recommendListView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _recommendListView;
}

- (ZFAccountGoodsListView *)historyListView {
    if (!_historyListView) {
        _historyListView = [[ZFAccountGoodsListView alloc] initWithFrame:self.bounds dataType:ZFAccountSelect_HistoryType];
        _historyListView.selectedGoodsBlock = self.selectedGoodsBlock;
        [self.horizontalScrollView addSubview:_historyListView];
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            _historyListView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _historyListView;
}


@end
