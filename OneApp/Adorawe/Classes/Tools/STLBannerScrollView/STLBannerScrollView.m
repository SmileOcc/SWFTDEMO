//
//  STLBannerScrollView.m
// XStarlinkProject
//
//  Created by odd on 2021/6/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLBannerScrollView.h"

#define kImageViewTagFlag   (2021)

@interface STLBannerImageView : UIView

@property (nonatomic, strong) YYAnimatedImageView     *imageView;
@property (nonatomic, strong) UIView                  *lineView;

- (void)setImageUrl:(NSString *)imageUrl placeHoldImage:(UIImage *)placeHoldImage;
- (void)hideLastLineView;

@end

@implementation STLBannerImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self stlInitView];
        [self stlAutoLayoutView];
    }
    return self;
}

- (void)stlInitView {
    self.backgroundColor = [OSSVThemesColors col_F5F5F5];
    [self addSubview:self.imageView];
    [self addSubview:self.lineView];
}

- (void)stlAutoLayoutView {
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.mas_equalTo(self);
        make.width.mas_equalTo(kBannerLineMagin);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.mas_equalTo(self);
        make.trailing.mas_equalTo(self.lineView.mas_leading);
    }];
}

- (void)hideLastLineView {
    self.lineView.hidden = YES;
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.mas_equalTo(self);
        make.trailing.mas_equalTo(self.mas_trailing);
    }];
}

#pragma mark - setter
- (void)setImageUrl:(NSString *)imageUrl placeHoldImage:(UIImage *)placeHoldImage {
    if (![imageUrl isKindOfClass:[NSString class]]) return;

    self.imageView.backgroundColor = APP_TYPE == 3 ? UIColor.clearColor : [OSSVThemesColors col_EEEEEE];
    @weakify(self)
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:imageUrl]
                               placeholder:placeHoldImage
                                   options:YYWebImageOptionShowNetworkActivity
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  }
                                 transform:^UIImage *(UIImage *image, NSURL *url) {
                                     return image; //发现商详的大图有些图片是透明的,因此不能重绘图片
                                 }
                            completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        @strongify(self)
        if (image) {
            self.imageView.backgroundColor = APP_TYPE == 3 ? UIColor.clearColor : [OSSVThemesColors stlWhiteColor];

        } else {
            self.imageView.backgroundColor = APP_TYPE == 3 ? UIColor.clearColor : [OSSVThemesColors col_EEEEEE];
        }
    }];
}

#pragma mark - getter
- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [OSSVThemesColors col_EEEEEE];
//        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [OSSVThemesColors col_F5F5F5];
    }
    return _lineView;
}
@end


@interface STLBannerScrollView() <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView                      *bannerScrollView;
@property (nonatomic, strong) UIPageControl                     *pageControl;
@property (nonatomic, strong) NSMutableArray                    *imageViewArray;
@end

@implementation STLBannerScrollView

#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self stlInitView];
        [self setPageDotStyle];
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)setPageDotStyle {
    self.currentPageDotColor = [UIColor whiteColor];
    self.pageDotColor = [UIColor grayColor];
    self.placeHoldImage = [UIImage imageNamed:@"loading_product"];
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

#pragma mark - <stlInitViewProtocol>
- (void)stlInitView {
    self.backgroundColor = [OSSVThemesColors col_F5F5F5];
    [self addSubview:self.bannerScrollView];
    [self addSubview:self.pageControl];
    self.pageControl.hidden = YES;
    
    [self.bannerScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(kBannerViewWidth);
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {//阿语
//            make.leading.mas_equalTo(self).offset((SCREEN_WIDTH-kBannerViewWidth+4));
//        } else {
            make.leading.mas_equalTo(self);
//        }
    }];
    
    CGSize size = self.pageControl.intrinsicContentSize;
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-16);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.size.mas_equalTo(size);
    }];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGFloat bannerWidth = [self bannerImageWidth];
    
    CGRect needTapRect = CGRectMake(bannerWidth, 0, SCREEN_WIDTH-bannerWidth, SCREEN_WIDTH);
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        needTapRect = CGRectMake(0, 0, SCREEN_WIDTH-bannerWidth, SCREEN_WIDTH);
    }
    if (CGRectContainsPoint(needTapRect, point)) {
        return self.bannerScrollView;
    }
    return [super hitTest:point withEvent:event];
}

- (CGFloat)bannerImageWidth {
    CGFloat bannerWidth = kBannerViewWidth;
    NSInteger urlCount = self.imageUrlArray.count;
    if (self.configureImageWidth > 0) {
        bannerWidth = (urlCount == 1) ? SCREEN_WIDTH : self.configureImageWidth + kBannerLineMagin;
    }
    return bannerWidth;
}

#pragma mark - setter

- (void)tapShowRightImageAction:(UIGestureRecognizer *)gesture {
    STLLog(@"====tapShowRightImageAction========");
    NSInteger urlCount = self.imageUrlArray.count;
    if (self.pageControl.currentPage == (urlCount-1)) {
        [self shouldSelectItemAtIndex:(urlCount-1)];
    } else {
        [self scrollToIndexBanner:(self.pageControl.currentPage + 1) animated:YES];
    }
}

- (void)clickImageView:(UIGestureRecognizer *)gesture {
    STLLog(@"====clickImageView========");
    UIView *imageView = gesture.view;
    if (imageView.tag < kImageViewTagFlag) return;
    
    NSInteger index = (imageView.tag - kImageViewTagFlag);
    NSInteger imageCount = self.imageUrlArray.count;
    
    if (self.pageControl.currentPage == (imageCount - 1)
        && imageView.tag == (kImageViewTagFlag + imageCount - 2)) {
        [self scrollToIndexBanner:index animated:YES];
    } else {
        [self shouldSelectItemAtIndex:index];
    }
}

- (void)shouldSelectItemAtIndex:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerScrollView:showImageViewArray:didSelectItemAtIndex:)]) {
        [self.delegate bannerScrollView:self showImageViewArray:self.imageViewArray didSelectItemAtIndex:index];
    }
}

- (void)setImageUrlArray:(NSArray<NSString *> *)imageUrlArray {
    _imageUrlArray = imageUrlArray;
    [self.bannerScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.imageViewArray removeAllObjects];
    
    NSInteger urlCount = imageUrlArray.count;
    self.pageControl.numberOfPages = urlCount;
    if (self.showPageControl) {
        self.pageControl.hidden = urlCount>0 ? NO : YES;
    }
    CGFloat bannerWidth = [self bannerImageWidth];
    
    self.bannerScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, -(SCREEN_WIDTH-bannerWidth));
    if (imageUrlArray.count > 1) {
        self.bannerScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, -(SCREEN_WIDTH-bannerWidth +kBannerLineMagin));
    }
    [self.bannerScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(bannerWidth);
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {//阿语
//            make.leading.mas_equalTo(self).offset((SCREEN_WIDTH-bannerWidth+4));
//        } else {
            make.leading.mas_equalTo(self);
//        }
    }];
    
    for (NSInteger i=0; i<urlCount; i++) {
        STLBannerImageView *imageView = [[STLBannerImageView alloc] init];
        
        CGFloat tempW = bannerWidth;
       
        if (i > 0 && i == (urlCount - 1)) {
            tempW = bannerWidth - kBannerLineMagin;
        }
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {//阿语
//            CGFloat x = bannerWidth * i + ((i == urlCount-1) ? 4 : 0);
//            imageView.frame = CGRectMake(x, 0, bannerWidth, SCREEN_WIDTH);
            imageView.frame = CGRectMake(bannerWidth * i, 0, tempW, SCREEN_WIDTH);
            imageView.transform = CGAffineTransformMakeScale(-1.0,1.0);

        } else {
            imageView.frame = CGRectMake(bannerWidth * i, 0, tempW, SCREEN_WIDTH);
        }
        imageView.tag = kImageViewTagFlag + i;
        imageView.userInteractionEnabled = YES;
        [self.bannerScrollView addSubview:imageView];
        if (i == (urlCount-1)) {
            [imageView hideLastLineView];
        }
        [imageView setImageUrl:imageUrlArray[i] placeHoldImage:self.placeHoldImage];
        UIImageView *showImageView = imageView.imageView;
        if (showImageView) {
            [self.imageViewArray addObject:showImageView];
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView:)];
        [imageView addGestureRecognizer:tap];
    }
    self.bannerScrollView.contentSize = CGSizeMake(bannerWidth * urlCount, CGRectGetHeight(self.bounds));
}

- (void)refreshImageUrl:(NSArray *)imageUrlArray scrollToFirstIndex:(BOOL)scrollToFirstIndex {
    self.imageUrlArray = imageUrlArray;
    
    if (self.pageControl.currentPage != 0 && scrollToFirstIndex) {
        [self scrollToIndexBanner:0 animated:YES];
    }
}

- (void)refreshImageUrl:(NSArray *)imageUrlArray scrollToFirstIndex:(BOOL)scrollToFirstIndex animated:(BOOL)animated{
    self.imageUrlArray = imageUrlArray;
    
    if (self.pageControl.currentPage != 0 && scrollToFirstIndex) {
        [self scrollToIndexBanner:0 animated:animated];
    }
}


- (void)scrollToIndexBanner:(NSInteger)currentPage animated:(BOOL)animated {
    if (currentPage > self.imageUrlArray.count) return;
    self.pageControl.currentPage = currentPage;
    
    
    CGFloat bannerWidth = [self bannerImageWidth];
    CGRect rect = CGRectMake(bannerWidth * currentPage, 0, bannerWidth, SCREEN_WIDTH);
    
    STLLog(@"scrollToIndexBanner==%ld", (long)currentPage);

    [self.bannerScrollView scrollRectToVisible:rect animated:animated];
    [self handleDidShowScrollViewPageAtIndex:currentPage];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat bannerWidth = [self bannerImageWidth];
    CGFloat currentIndex = [[NSString stringWithFormat:@"%.2f",(scrollView.contentOffset.x / bannerWidth)] floatValue];
    CGFloat maxOffset = (bannerWidth * (self.imageUrlArray.count - 1) - (SCREEN_WIDTH-bannerWidth));
    if (scrollView.contentOffset.x == maxOffset) {
        currentIndex += 1;//最后一页 ceil
    }
    self.pageControl.currentPage = ceil(currentIndex);
    [self handleDidShowScrollViewPageAtIndex:self.pageControl.currentPage];
    STLLog(@"scrollViewDidEndDecelerating==%ld==%.2f", self.pageControl.currentPage, currentIndex);
}

- (void)handleDidShowScrollViewPageAtIndex:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didShowScrollViewPageAtIndex:)]) {
        [self.delegate didShowScrollViewPageAtIndex:index];
    }
}

#pragma mark - Getter
- (UIScrollView *)bannerScrollView {
    if (!_bannerScrollView) {
        _bannerScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _bannerScrollView.backgroundColor = [OSSVThemesColors col_F5F5F5];

        _bannerScrollView.delegate = self;
        _bannerScrollView.directionalLockEnabled = YES;
        _bannerScrollView.showsVerticalScrollIndicator = NO;
        _bannerScrollView.showsHorizontalScrollIndicator = NO;
        _bannerScrollView.delaysContentTouches = NO;
        _bannerScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, -(SCREEN_WIDTH-kBannerViewWidth));
        _bannerScrollView.bounces = NO;
        _bannerScrollView.clipsToBounds = NO;
        _bannerScrollView.pagingEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapShowRightImageAction:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [_bannerScrollView addGestureRecognizer:tap];
        
        _bannerScrollView.semanticContentAttribute = [OSSVSystemsConfigsUtils isRightToLeftShow] ? UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
        if (@available(iOS 11.0, *)) {
            _bannerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }

        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _bannerScrollView.transform = CGAffineTransformMakeScale(-1.0,1.0);
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

- (NSMutableArray *)imageViewArray {
    if (!_imageViewArray) {
        _imageViewArray = [NSMutableArray array];
    }
    return _imageViewArray;
}

@end
