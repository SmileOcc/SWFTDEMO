//
//  ZFCollectionPostsContainerView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCollectionPostsContainerView.h"
#import "ZFCollectionPostsMenuView.h"
#import "ZFCollectionPostsNormalView.h"
#import "ZFCollectionPostsOutfitView.h"

#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "ZFLocalizationString.h"


static CGFloat kCollectionPostsMenuHeight = 56;
@interface ZFCollectionPostsContainerView()<ZFInitViewProtocol,UIScrollViewDelegate>

@property (nonatomic, strong) ZFCollectionPostsMenuView          *menuView;
@property (nonatomic, strong) ZFCollectionPostsNormalView        *normalView;
@property (nonatomic, strong) ZFCollectionPostsOutfitView        *outfitView;
@property (nonatomic, strong) UIScrollView                       *scrollView;


@end

@implementation ZFCollectionPostsContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)viewWillShow {
    
    // 内外高度不一致时
    if ((self.scrollView.frame.size.height + kCollectionPostsMenuHeight) != self.frame.size.height) {
        
        CGFloat width = CGRectGetWidth(self.frame);
        CGFloat height = CGRectGetHeight(self.frame);
        self.scrollView.frame = CGRectMake(0, kCollectionPostsMenuHeight, KScreenWidth, self.frame.size.height - kCollectionPostsMenuHeight);
        self.normalView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        self.outfitView.frame = CGRectMake(width, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        self.scrollView.contentSize = CGSizeMake(width * 2, height - kCollectionPostsMenuHeight);
    }
    
    [self.normalView viewWillShow];
    
}
#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    self.backgroundColor = ZFC0xFFFFFF();
    [self addSubview:self.menuView];
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.normalView];
    [self.scrollView addSubview:self.outfitView];
}

- (void)zfAutoLayoutView {
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self);
        make.height.mas_equalTo(kCollectionPostsMenuHeight);
    }];
    
    self.normalView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    self.outfitView.frame = CGRectMake(width, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    self.scrollView.contentSize = CGSizeMake(width * 2, height - kCollectionPostsMenuHeight);

    if ([SystemConfigUtils isRightToLeftShow]) {
        self.normalView.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
    
    if ([SystemConfigUtils isRightToLeftShow]) {
        self.outfitView.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
}

- (void)changeIndexView:(NSInteger)selectIndex {
    if (selectIndex == -1) return;
    CGFloat width = CGRectGetWidth(self.frame);
    [self.scrollView setContentOffset:CGPointMake(selectIndex *width, 0) animated:NO];
}

#pragma mark - UIScrollView

//快速滑动调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.scrollView]) {
        int index = scrollView.contentOffset.x / KScreenWidth;
        if (index < 0) {
            index = 0;
        }
        self.menuView.selectIndex = index;
        if (index == 1) {
            [self.outfitView viewWillShow];
        }
    }
}

//手指 慢慢拖动时调用
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate && [scrollView isEqual:self.scrollView]) {
        int index = scrollView.contentOffset.x / KScreenWidth;
        if (index < 0) {
            index = 0;
        }
        self.menuView.selectIndex = index;
        if (index == 1) {
            [self.outfitView viewWillShow];
        }
    }
}

#pragma mark - Property Method

- (ZFCollectionPostsMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[ZFCollectionPostsMenuView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _menuView.indexBlock = ^(NSInteger index) {
            @strongify(self)
            if (index == 1) {
                [self.outfitView viewWillShow];
            }
            [self changeIndexView:index];
        };
    }
    return _menuView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kCollectionPostsMenuHeight, KScreenWidth, self.frame.size.height - kCollectionPostsMenuHeight)];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor whiteColor];
        if ([SystemConfigUtils isRightToLeftShow]) {
            _scrollView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _scrollView;
}

- (ZFCollectionPostsNormalView *)normalView {
    if (!_normalView) {
        _normalView = [[ZFCollectionPostsNormalView alloc] initWithFrame:CGRectMake(0, kCollectionPostsMenuHeight, KScreenWidth, self.frame.size.height - kCollectionPostsMenuHeight)];
    }
    return _normalView;
}

- (ZFCollectionPostsOutfitView *)outfitView {
    if (!_outfitView) {
        _outfitView = [[ZFCollectionPostsOutfitView alloc] initWithFrame:CGRectMake(0, kCollectionPostsMenuHeight, KScreenWidth, self.frame.size.height - kCollectionPostsMenuHeight)];
    }
    return _outfitView;
}
@end
