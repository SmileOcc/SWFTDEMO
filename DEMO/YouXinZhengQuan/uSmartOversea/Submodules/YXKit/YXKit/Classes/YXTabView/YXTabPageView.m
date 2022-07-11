//
//  YXTabPageView.m
//  ScrollViewDemo
//
//  Created by ellison on 2018/11/1.
//  Copyright © 2018 ellison. All rights reserved.
//

#import "YXTabPageView.h"
#import <Masonry/Masonry.h>

@interface YXTabPageView () <UITableViewDelegate, UIScrollViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YXTabMainTableView *mainTableView;
@property (nonatomic, weak) UIScrollView *currentScrollingView;

@property (nonatomic, weak) YXTabView *tabView;
@property (nonatomic, weak) YXPageView *pageView;

@end

@implementation YXTabPageView

- (instancetype)initWithDelegate:(id<YXTabPageViewDelegate>)delegate {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _delegate = delegate;
        [self initializeViews];
    }
    return self;
}

- (void)initializeViews {
    
    _tabView = [self.delegate tabViewInTabPage];
    _tabView.needLayout = YES;
    _pageView = [self.delegate pageViewInTabPage];
    _pageView.needLayout = YES;
    _tabView.pageView = _pageView;
    
    _mainTableView = [[YXTabMainTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _mainTableView.showsVerticalScrollIndicator = NO;
    _mainTableView.showsHorizontalScrollIndicator = NO;
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    _mainTableView.decelerationRate = UIScrollViewDecelerationRateNormal;
    if ([_delegate respondsToSelector:@selector(headerViewInTabPage)]) {
        self.mainTableView.tableHeaderView = [self.delegate headerViewInTabPage];
    }
    
    [self.mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    if (@available(iOS 11.0, *)) {
        self.mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.mainTableView.contentInset = UIEdgeInsetsZero;
    }
    [self addSubview:self.mainTableView];
    
    [self configListViewDidScrollCallback];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_mainTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(self);
    }];
}

- (void)reloadData {
    if ([_delegate respondsToSelector:@selector(headerViewInTabPage)]) {
        [self.mainTableView.tableHeaderView layoutIfNeeded];
        self.mainTableView.tableHeaderView = [self.delegate headerViewInTabPage];
    }
    [_mainTableView reloadData];
    [_tabView reloadData];
    [_pageView reloadData];
    [self configListViewDidScrollCallback];
}

- (void)scrollToTop {
    id<YXTabPageViewDelegate> delegate = self.delegate;
    self.delegate = nil;
    [self.currentScrollingView setContentOffset:CGPointZero];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.delegate = delegate;
        [self.mainTableView setContentOffset:CGPointZero];
        [self reloadData];
    });
    
}

static inline CGFloat YXKitCGFloatPixelFloor(CGFloat value) {
    CGFloat scale = [UIScreen mainScreen].scale;
    return floor(value * scale) / scale;
}


- (void)configListViewDidScrollCallback {
    NSArray *viewControllers = self.pageView.viewControllers;
    
    for (UIViewController <YXTabPageScrollViewProtocol>* viewController in viewControllers) {
        if ([viewController respondsToSelector:@selector(pageScrollViewDidScrollCallback:)]) {
             __weak typeof(self)weakSelf = self;
            [viewController pageScrollViewDidScrollCallback:^(UIScrollView * _Nonnull scrollView) {
                [weakSelf pageScrollViewDidSCroll:scrollView];
            }];
        }
    }
}

- (void)pageScrollViewDidSCroll:(UIScrollView *)scrollView {
    self.currentScrollingView = scrollView;
    
    if ([self.delegate respondsToSelector:@selector(heightForHeaderViewInTabPage)]) {
        CGFloat headerHeight = YXKitCGFloatPixelFloor([self.delegate heightForHeaderViewInTabPage]);
        if (_mainTableView.contentOffset.y < headerHeight) {
            scrollView.contentOffset = CGPointZero;
            scrollView.showsVerticalScrollIndicator = NO;
        }else {
            _mainTableView.contentOffset = CGPointMake(0, headerHeight);
            scrollView.showsVerticalScrollIndicator = YES;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(heightForHeaderViewInTabPage)]) {
        CGFloat headerHeight = YXKitCGFloatPixelFloor([self.delegate heightForHeaderViewInTabPage]);
        if (self.currentScrollingView != nil && self.currentScrollingView.contentOffset.y > 0) {
            _mainTableView.contentOffset = CGPointMake(0, headerHeight);
        }
        
        if (scrollView.contentOffset.y < headerHeight) {
            NSArray *viewControllers = self.pageView.viewControllers;
            for (UIViewController <YXTabPageScrollViewProtocol>* viewController in viewControllers) {
                if ([viewController respondsToSelector:@selector(pageScrollView)]) {
                    [viewController pageScrollView].contentOffset = CGPointZero;
                }
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.delegate heightForPageViewInTabPage];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = UIColor.clearColor;
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    self.pageView.needLayout = YES;
    self.pageView.frame = cell.contentView.bounds;
    [cell.contentView addSubview:self.pageView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self.delegate heightForTabViewInTabPage];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return  self.tabView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    footer.backgroundColor = [UIColor clearColor];
    return footer;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
