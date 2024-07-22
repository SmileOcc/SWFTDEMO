//
//  ZFBannerScrollView.m
//  ZFBannerView
//
//  Created by YW on 22/11/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBannerScrollView.h"
#import "ZFBannerContentView.h"
#import <pop/POP.h>
#import "SystemConfigUtils.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFBannerScrollView ()<UIScrollViewDelegate,POPAnimationDelegate>
{
    BOOL _autoScroll;
}
@property (nonatomic, strong) UIScrollView          *scrollView;
@property (nonatomic, weak)   UIPageControl         *pageControl;
@property (nonatomic, strong) NSTimer               *timer;
@property (nonatomic, strong) ZFBannerContentView   *leftImageView;
@property (nonatomic, strong) ZFBannerContentView   *centerImageView;
@property (nonatomic, strong) ZFBannerContentView   *rightImageView;
@property (nonatomic, strong) NSArray               *imagePathsGroup;
@property (nonatomic, assign) int  currentIndex;
@property (nonatomic, assign) int  forwardIndex;
@property (nonatomic, assign) int  backwardIndex;
@end

@implementation ZFBannerScrollView
#pragma mark - Life Cyclex
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
        [self initView];
        [self autoLayoutSubView];
    }
    return self;
}

- (void)initialization {
    _autoScroll = YES;
    _timerInterval = 4.0f;
    _bannerType = ZFBannerTypeNormal;
    _currentPageDotColor = [UIColor whiteColor];
    _pageDotColor = [UIColor grayColor];
}

- (void)initView {
    [self addSubview:self.scrollView];
    
    for (int i = 0 ; i < 3 ; i++) {
        ZFBannerContentView *imageView =  [[ZFBannerContentView alloc]initWithFrame:CGRectMake(i*CGRectGetWidth(self.bounds), 0, CGRectGetWidth(self.bounds),  CGRectGetHeight(self.bounds))];
        [self.scrollView addSubview:imageView];
        switch (i) {
            case 0:
            {
                _leftImageView = imageView;
            }
                break;
            case 1:
            {
                _centerImageView = imageView;
                [_centerImageView setUserInteraction:YES];
            }
                break;
            case 2:
            {
                _rightImageView = imageView;
            }
                break;
        }
    }
    
    __weak typeof(self) WeakSelf = self;
    _centerImageView.callBack = ^(ZFBannerContentView * sender){
        [WeakSelf tapFuncCallBack];
    };
}

- (void)autoLayoutSubView {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self.scrollView);
        make.top.equalTo(self.scrollView);
        make.left.equalTo(self.scrollView).mas_offset(0);
    }];
    [self.centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self.scrollView);
        make.top.equalTo(self.scrollView);
        make.left.equalTo(self.leftImageView.mas_right);
    }];
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self.scrollView);
        make.top.equalTo(self.scrollView);
        make.left.equalTo(self.centerImageView.mas_right);
    }];
}

- (void)dealloc {
#ifdef DEBUG
    YWLog(@"Dealloc %@",self);
#endif
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self adaptScrollviewContentOffset];
    [self layoutPageControl];
}

- (void)adaptScrollviewContentOffset {
    if (CGSizeEqualToSize(self.scrollView.contentSize, CGSizeZero)) {
        self.currentIndex = 0;
        [self resetTimer];
        
        _scrollView.contentSize   = CGSizeMake(CGRectGetWidth(self.bounds) * 3, CGRectGetHeight(self.bounds));
        _scrollView.scrollEnabled = YES;
        
        if (self.imageURLStringsGroup.count == 1) {
            _scrollView.scrollEnabled = NO;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.bounds), 0);
        });
    }
}

- (void)layoutPageControl {
    CGSize size = CGSizeZero;
    size = _pageControl.intrinsicContentSize;
    CGFloat x = (CGRectGetWidth(self.bounds) - size.width) * 0.5;
    CGFloat y = CGRectGetHeight(self.bounds) - size.height;
    [_pageControl sizeToFit];
    CGRect pageControlFrame = CGRectMake(x, y, size.width, size.height);
    self.pageControl.frame = pageControlFrame;
}

// 这个方法会在子视图添加到父视图或者离开父视图时调用
- (void)willMoveToSuperview:(UIView *)newSuperview {
    //解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
    if (!newSuperview) {
        [self invalidateTimer];
    }
}

#pragma mark - Setter
- (void)setImageURLStringsGroup:(NSArray *)imageURLStringsGroup {
    _imageURLStringsGroup = imageURLStringsGroup;
    NSMutableArray *temp = [NSMutableArray new];
    self.leftImageView.placeHoldImage   = self.placeHoldImage;
    self.centerImageView.placeHoldImage = self.placeHoldImage;
    self.rightImageView.placeHoldImage  = self.placeHoldImage;
    [_imageURLStringsGroup enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
        NSString *urlString;
        if ([obj isKindOfClass:[NSString class]]) {
            urlString = obj;
        } else if ([obj isKindOfClass:[NSURL class]]) {
            NSURL *url = (NSURL *)obj;
            urlString = [url absoluteString];
        }
        if (urlString) {
            [temp addObject:urlString];
        }
    }];
    self.imagePathsGroup = [temp copy];
}

- (void)setImagePathsGroup:(NSArray *)imagePathsGroup {
    [self invalidateTimer];
    [self layoutIfNeeded];
    _imagePathsGroup = imagePathsGroup;
    self.currentIndex = 0;
    [self setContainerImageViews];
    [self setupPageControl];
    [self resetTimer];
}

- (void)setCurrentIndex:(int)currentIndex {
    _currentIndex = currentIndex;
    _forwardIndex = _currentIndex + 1;
    _backwardIndex = _currentIndex - 1;
    
    if (_currentIndex == (int)self.imageURLStringsGroup.count - 1) {
        _forwardIndex = 0;
    }
    if (_currentIndex > (int)self.imageURLStringsGroup.count - 1) {
        _currentIndex = 0;
        _forwardIndex = 1;
    }
    if (_currentIndex == 0) {
        _backwardIndex = (int)self.imageURLStringsGroup.count -1;
    }
    if (_currentIndex < 0) {
        _currentIndex = (int)self.imageURLStringsGroup.count -1;
        _backwardIndex = _currentIndex - 1;
    }
    
    if (self.imageURLStringsGroup.count == 1) {
        _forwardIndex = 0;
        _backwardIndex = 0;
    }
    self.pageControl.currentPage = _currentIndex;
}

- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
    if (_autoScroll == NO) {
        [self invalidateTimer];
    }
}

- (BOOL)autoScroll {
    return _autoScroll;
}

- (void)setTimerInterval:(NSTimeInterval)timerInterval {
    _timerInterval = timerInterval;
}

- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor {
    _currentPageDotColor = currentPageDotColor;
    _pageControl.currentPageIndicatorTintColor = currentPageDotColor;
    
}

- (void)setPageDotColor:(UIColor *)pageDotColor {
    _pageDotColor = pageDotColor;
    _pageControl.pageIndicatorTintColor = pageDotColor;
}

#pragma mark - Private method
- (void)invalidateTimer {
    self.timer.fireDate = [NSDate distantFuture];
    [_timer invalidate];
    _timer = nil;
}

- (void)pauseTimer {
    self.timer.fireDate = [NSDate distantFuture];
}

- (void)resumeTimer {
    self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.timerInterval];
}

- (void)resetTimer {
    if (self.timer) {
        [self invalidateTimer];
    }
    
    if (self.imageURLStringsGroup.count >= 2) {
        if (self.autoScroll) {
            self.timer = [NSTimer timerWithTimeInterval:self.timerInterval target:self selector:@selector(loop) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
    }else{
        self.pageControl.hidden = YES;
    }
}

// 设置scrollView无限循环滚动
- (void)infiniteLoopScrollView:(UIScrollView *)scrollView {
    div_t x = div(self.scrollView.contentOffset.x,self.scrollView.frame.size.width);
    if (x.quot == 0) {
        self.currentIndex -= 1;
    }else if(x.quot == 2){
        self.currentIndex += 1;
    }
    [self setContainerImageViews];
    self.pageControl.currentPage = self.currentIndex;
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds), 0);
}

/// 滚动到指定页
- (void)scrollToIndexBanner:(NSInteger)currentPage {
    if (currentPage >= self.imagePathsGroup.count) return;
    self.currentIndex = currentPage;
    [self setContainerImageViews];
    self.pageControl.currentPage = self.currentIndex;
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds), 0);
}

- (void)setContainerImageViews {
    if (_backwardIndex >= 0 && self.imagePathsGroup.count > _backwardIndex) {
        [self.leftImageView setContentIMGWithStr:self.imagePathsGroup[_backwardIndex]];
    }
    
    if (_currentIndex >= 0 && self.imagePathsGroup.count > _currentIndex) {
        [self.centerImageView setContentIMGWithStr:self.imagePathsGroup[_currentIndex]];
    }
    
    if (_forwardIndex >= 0 && self.imagePathsGroup.count > _forwardIndex) {
        [self.rightImageView setContentIMGWithStr:self.imagePathsGroup[_forwardIndex]];
    }
}

- (void)setupPageControl {
    if (_pageControl) [_pageControl removeFromSuperview]; // 重新加载数据时调整
    if (self.imagePathsGroup.count <= 1) return;
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = self.imagePathsGroup.count;
    pageControl.pageIndicatorTintColor = self.pageDotColor;
    pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
    pageControl.userInteractionEnabled = NO;
    [self addSubview:pageControl];
    _pageControl = pageControl;
}

#pragma mark - Target action
-(void)tapFuncCallBack {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFBannerScrollView:didSelectItemAtIndex:)]) {
        [self.delegate ZFBannerScrollView:self didSelectItemAtIndex:self.currentIndex];
    }
}

#pragma mark - Time action
- (void)loop {
    POPBasicAnimation *basicAnimationCenter = [POPBasicAnimation animationWithPropertyNamed:kPOPScrollViewContentOffset];
    // 2.设置初始值
    basicAnimationCenter.fromValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(self.bounds), 0)];
    // 动画的时长
    basicAnimationCenter.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(self.bounds)*2, 0)];
    // 动画的时长
    basicAnimationCenter.duration = 2;
    basicAnimationCenter.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    basicAnimationCenter.beginTime = CACurrentMediaTime();
    basicAnimationCenter.delegate = self;
    // 3.添加到view上
    [_scrollView pop_addAnimation:basicAnimationCenter forKey:basicAnimationCenter.name];
}

#pragma mark - POPAnimationDelegate
- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished {
    [self infiniteLoopScrollView:self.scrollView];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.imagePathsGroup.count) return; // 解决清除timer时偶尔会出现的问题
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (self.bannerType) {
            case ZFBannerTypeNormal     : break;
            case ZFBannerTypeParallax   : [obj setOffsetWithFactor:0.7]; break;
            case ZFBannerTypeUNParallax : [obj setOffsetWithFactor:1];   break;
        }
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    scrollView.contentInset = UIEdgeInsetsZero;
    [self pauseTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self infiniteLoopScrollView:scrollView];
    [self resumeTimer];
}

// 自定义设置滑动阻尼,实现丝滑效果 (手势拖动的情况下) 有滑动bug
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    CGFloat moveX = scrollView.contentOffset.x - self.scrollView.bounds.size.width;
//    CGFloat targetX = [self targetOffsetForMoveX:moveX velocity:velocity.x];
//    if (targetX == self.scrollView.bounds.size.width) {//cancel
//        targetContentOffset->x = scrollView.contentOffset.x;
//        [self.scrollView setContentOffset:CGPointMake(targetX, targetContentOffset->y) animated:YES];
//        [self resumeTimer];
//    } else {//complete
//        targetContentOffset->x = targetX;
//    }
//}

- (CGFloat)targetOffsetForMoveX:(CGFloat)moveX velocity:(CGFloat)velocity {
    BOOL complete = fabs(moveX) >= self.scrollView.bounds.size.width * 0.3 ||
    (fabs(velocity) > 0 && fabs(moveX) >= self.scrollView.bounds.size.width * 0.1 )? YES : NO;
    BOOL leftDirection = moveX > 0 ? YES : NO;
    if (complete) {
        if (leftDirection) {
            return self.scrollView.bounds.size.width * 2;
        }
        return 0; //right Direction
    }else {
        return self.scrollView.bounds.size.width;//cancel
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint point = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
        if ((fabs(point.y) / fabs(point.x)) < 1) { // 判断角度 tan(45),这里需要通过正负来判断手势方向
            YWLog(@"横向手势");
            return NO;
        }
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

#pragma mark - Getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        _scrollView.directionalLockEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor whiteColor];
        //该句是否执行会影响pageControl的位置,如果该应用上面有导航栏,就是用该句,否则注释掉即可
        _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _scrollView.clipsToBounds = YES;
        _scrollView.delaysContentTouches = NO;
        _scrollView.pagingEnabled = YES;
        if (IOS9UP) {
            _scrollView.semanticContentAttribute = [SystemConfigUtils isRightToLeftShow] ? UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
        }
        
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _scrollView;
}

@end

