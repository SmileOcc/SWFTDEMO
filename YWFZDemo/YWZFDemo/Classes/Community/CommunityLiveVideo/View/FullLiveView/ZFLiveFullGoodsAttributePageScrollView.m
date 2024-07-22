//
//  ZFPageScrollView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFLiveFullGoodsAttributePageScrollView.h"

#define kLiveGoodsTagFlag   (201900)

@interface ZFLiveFullGoodsAttributePageScrollView()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView                      *bannerScrollView;
@property (nonatomic, strong) UIPageControl                     *pageControl;
@property (nonatomic, strong) NSMutableArray                    *itemViewArray;

@end

@implementation ZFLiveFullGoodsAttributePageScrollView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self setPageDotStyle];
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)setPageDotStyle {
    self.currentPageDotColor = [UIColor whiteColor];
    self.pageDotColor = [UIColor grayColor];
}

- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor {
    _currentPageDotColor = currentPageDotColor;
    self.pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
}

- (void)setPageDotColor:(UIColor *)pageDotColor {
    _pageDotColor = pageDotColor;
    self.pageControl.pageIndicatorTintColor = self.pageDotColor;
}

- (void)setShowPageControl:(BOOL)showPageControl {
    _showPageControl = showPageControl;
    self.pageControl.hidden = !showPageControl;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    [self addSubview:self.bannerScrollView];
    [self addSubview:self.pageControl];
    
    [self.bannerScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(kLiveViewWidth);
        if ([SystemConfigUtils isRightToLeftShow]) {//阿语
            make.leading.mas_equalTo(self).offset((KScreenWidth-kLiveViewWidth+4));
        } else {
            make.leading.mas_equalTo(self);
        }
    }];
    
    CGSize size = self.pageControl.intrinsicContentSize;
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-16);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.size.mas_equalTo(size);
    }];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGFloat contentH = CGRectGetHeight(self.frame);
    if (CGRectContainsPoint(CGRectMake(kLiveViewWidth, 0, KScreenWidth-kLiveViewWidth, contentH), point)) {
        return self.bannerScrollView;
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - setter

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
 
    for (UIView *view = touch.view; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UICollectionViewCell class]]) {
            return NO;
        }
    }
    return YES;
}
- (void)tapShowRightImageAction:(UIGestureRecognizer *)gesture {
    YWLog(@"====tapShowRightImageAction========");
    NSInteger urlCount = self.goodsArray.count;
    if (self.pageControl.currentPage == (urlCount-1)) {

    } else {
        [self scrollToIndexBanner:(self.pageControl.currentPage + 1) animated:YES];
    }
}

- (void)setLiveVideoId:(NSString *)liveVideoId {
    _liveVideoId = liveVideoId;
}

-(void)setGoodsArray:(NSArray<ZFGoodsModel *> *)goodsArray {
    _goodsArray = goodsArray;
    [self.bannerScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.itemViewArray removeAllObjects];
    
    NSInteger urlCount = goodsArray.count;
    self.pageControl.numberOfPages = urlCount;
    if (self.showPageControl) {
        self.pageControl.hidden = urlCount>0 ? NO : YES;
    }
    CGFloat bannerWidth = (urlCount == 1) ? KScreenWidth : kLiveViewWidth;
    
    
    for (NSInteger i=0; i<urlCount; i++) {
        ZFFullLiveGoodsAttributesItemView *itemView = [[ZFFullLiveGoodsAttributesItemView alloc] init];
        itemView.liveId = self.liveVideoId;
        
        @weakify(self)
        @weakify(itemView)
        itemView.goCartBlock = ^{
            @strongify(self)
            @strongify(itemView)
            [self handeImtemView:itemView eventType:LiveGoodsAttributesOperateTypeCart];
        };
        
        itemView.commentBlock = ^(GoodsDetailModel * _Nonnull model) {
            @strongify(self)
            @strongify(itemView)
            if (self.delegate && [self.delegate respondsToSelector:@selector(liveFullGoodsAttributePage:eventType:goodsDetailModel:)]) {
                [self.delegate liveFullGoodsAttributePage:itemView eventType:LiveGoodsAttributesOperateTypeComment goodsDetailModel:model];
            }
        };
        
        itemView.guideSizeBlock = ^(NSString * _Nonnull guideUrl) {
            @strongify(self)
            @strongify(itemView)
            [self handeImtemView:itemView eventType:LiveGoodsAttributesOperateTypeGuideSize];

        };
        
        ZFGoodsModel *goodsModel = goodsArray[i];
        itemView.goodsModel = goodsModel;

        if ([SystemConfigUtils isRightToLeftShow]) {//阿语
            CGFloat x = bannerWidth * i + ((i == urlCount-1) ? 4 : 0);
            itemView.frame = CGRectMake(x, 0, bannerWidth, [self contentHeight]);
        } else {
            itemView.frame = CGRectMake(bannerWidth * i, 0, bannerWidth, [self contentHeight]);
        }
        itemView.tag = kLiveGoodsTagFlag + i;
        itemView.userInteractionEnabled = YES;
        [self.bannerScrollView addSubview:itemView];

        [self.itemViewArray addObject:itemView];
    }
    self.bannerScrollView.contentSize = CGSizeMake(bannerWidth * urlCount, CGRectGetHeight(self.bounds));
    
    if (urlCount > 0) {
        [self handleDidShowScrollViewPageAtIndex:0];
    }
}

- (void)handeImtemView:(ZFFullLiveGoodsAttributesItemView *)itemView eventType:(LiveGoodsAttributesOperateType )eventType {
    if (self.delegate && [self.delegate respondsToSelector:@selector(liveFullGoodsAttributePage:eventType:)]) {
        [self.delegate liveFullGoodsAttributePage:itemView eventType:eventType];
    }
}

- (void)refreshImageUrl:(NSArray *)imageUrlArray scrollToFirstIndex:(BOOL)scrollToFirstIndex {

    if (self.pageControl.currentPage != 0 && scrollToFirstIndex) {
        [self scrollToIndexBanner:0 animated:YES];
    }
}

- (void)refreshTopMarkIndex:(NSString *)recommendGoodsId {
    
    if (!ZFIsEmptyString(recommendGoodsId) && self.itemViewArray) {
        NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
        for (ZFFullLiveGoodsAttributesItemView *itemView in self.itemViewArray) {
            if ([ZFToString(itemView.goodsModel.goods_id) isEqualToString:ZFToString(recommendGoodsId)]) {
                itemView.recommendGoodsId = recommendGoodsId;
                [itemsArray insertObject:itemView atIndex:0];
            } else {
                itemView.recommendGoodsId = @"";
                [itemsArray addObject:itemView];
            }
        }
        
        NSInteger urlCount = itemsArray.count;
        CGFloat bannerWidth = (urlCount == 1) ? KScreenWidth : kLiveViewWidth;

        for (NSInteger i=0; i<urlCount; i++) {
            ZFFullLiveGoodsAttributesItemView *itemView = itemsArray[i];
            if ([SystemConfigUtils isRightToLeftShow]) {//阿语
                CGFloat x = bannerWidth * i + ((i == urlCount-1) ? 4 : 0);
                itemView.frame = CGRectMake(x, 0, bannerWidth, [self contentHeight]);
            } else {
                itemView.frame = CGRectMake(bannerWidth * i, 0, bannerWidth, [self contentHeight]);
            }
        }
        self.itemViewArray = itemsArray;
    }
}

- (void)scrollToIndexBanner:(NSInteger)currentPage animated:(BOOL)animated {
    if (currentPage > self.goodsArray.count) return;
    self.pageControl.currentPage = currentPage;
    
    YWLog(@"scrollToIndexBanner==%ld", (long)currentPage);
    CGFloat cotetnH = CGRectGetHeight(self.frame);
    CGRect rect = CGRectMake(kLiveViewWidth * currentPage, 0, kLiveViewWidth, cotetnH);
    [self.bannerScrollView scrollRectToVisible:rect animated:animated];
    [self handleDidShowScrollViewPageAtIndex:currentPage];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat currentIndex = (scrollView.contentOffset.x / kLiveViewWidth);
    CGFloat maxOffset = (kLiveViewWidth * (self.goodsArray.count - 1) - (KScreenWidth-kLiveViewWidth));
    if (scrollView.contentOffset.x == maxOffset) {
        currentIndex += 1;//最后一页 ceil
    }
    self.pageControl.currentPage = ceil(currentIndex);
    [self handleDidShowScrollViewPageAtIndex:self.pageControl.currentPage];
    //YWLog(@"scrollViewDidEndDecelerating==%ld==%.2f", self.pageControl.currentPage, currentIndex);
}

- (void)handleDidShowScrollViewPageAtIndex:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didShowScrollView:pageAtIndex:)]) {
        
        ZFFullLiveGoodsAttributesItemView *itemView = [self.bannerScrollView viewWithTag:(kLiveGoodsTagFlag + index)];
        [self.delegate didShowScrollView:itemView pageAtIndex:index];
        
        if ([self.delegate respondsToSelector:@selector(willShowScrollView:pageAtIndex:)]) {
            if (index < self.goodsArray.count - 1) {
                ZFFullLiveGoodsAttributesItemView *itemView = [self.bannerScrollView viewWithTag:(kLiveGoodsTagFlag + index + 1)];
                if (itemView) {
                    [self.delegate willShowScrollView:itemView pageAtIndex:index+1];
                }

            }
        }
    }
}

#pragma mark - Getter
- (UIScrollView *)bannerScrollView {
    if (!_bannerScrollView) {
        _bannerScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _bannerScrollView.backgroundColor = [UIColor clearColor];
        _bannerScrollView.delegate = self;
        _bannerScrollView.directionalLockEnabled = YES;
        _bannerScrollView.showsVerticalScrollIndicator = NO;
        _bannerScrollView.showsHorizontalScrollIndicator = NO;
        _bannerScrollView.delaysContentTouches = NO;
        _bannerScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, -(KScreenWidth-kLiveViewWidth));
        _bannerScrollView.bounces = NO;
        _bannerScrollView.clipsToBounds = NO;
        _bannerScrollView.pagingEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapShowRightImageAction:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        tap.delegate = self;
        [_bannerScrollView addGestureRecognizer:tap];
        
        if (IOS9UP) {
            _bannerScrollView.semanticContentAttribute = [SystemConfigUtils isRightToLeftShow] ? UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
        }
        if (@available(iOS 11.0, *)) {
            _bannerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _bannerScrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

- (NSMutableArray *)itemViewArray {
    if (!_itemViewArray) {
        _itemViewArray = [NSMutableArray array];
    }
    return _itemViewArray;
}


- (CGFloat)contentHeight {
    CGFloat h = CGRectGetHeight(self.frame);
    if (h <=0) {
        return self.contentH;
    }
    return h;
}
@end
