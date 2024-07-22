//
//  ZFBannerScrollView_B.m
//  ZZZZZ
//
//  Created by YW on 2019/5/28.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFNewBannerScrollView.h"
#import "ZFInitViewProtocol.h"
#import "GoodsDetailSameModel.h"
#import "ZFCarRecommendGoodsCell.h"
#import "ZFGoodsModel.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZF3DTouchHeader.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import <YYWebImage/YYWebImage.h>
#import "Constants.h"
#import "UIImage+ZFExtended.h"

#define kImageViewTagFlag   (2019)

@interface ZFBannerImageView : UIView
@property(nonatomic,strong) YYAnimatedImageView *imageView;
@property(nonatomic,strong) UIView *lineView;
- (void)setImageUrl:(NSString *)imageUrl placeHoldImage:(UIImage *)placeHoldImage;
- (void)hideLastLineView;
@end

@implementation ZFBannerImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.imageView];
    [self addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
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
    if (![imageUrl isKindOfClass:[NSString class]] && !placeHoldImage) return;

    [self.imageView yy_setImageWithURL:[NSURL URLWithString:imageUrl]
                               placeholder:placeHoldImage
                                   options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  }
                                 transform:^UIImage *(UIImage *image, NSURL *url) {
                                     return image; //发现商详的大图有些图片是透明的,因此不能重绘图片
                                     
                                     // 解决像素混合渲染问题
//                                     if ([image isKindOfClass:[YYImage class]]) {
//                                         YYImage *showImage = (YYImage *)image;
//                                         if (showImage.animatedImageType == YYImageTypeGIF || showImage.animatedImageData) {
//                                             return image;
//                                         }
//                                     }
                                     return [image zf_drawImageToOpaque];
                                 }
                                completion:nil];
}

#pragma mark - getter
- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [UIColor whiteColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor whiteColor];
    }
    return _lineView;
}
@end


@interface ZFNewBannerScrollView() <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView                      *bannerScrollView;
@property (nonatomic, strong) UIPageControl                     *pageControl;
@property (nonatomic, strong) NSMutableArray                    *imageViewArray;
@end

@implementation ZFNewBannerScrollView

#pragma mark - init methods

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

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.bannerScrollView];
    [self addSubview:self.pageControl];
    
    [self.bannerScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(kBannerViewWidth);
        if ([SystemConfigUtils isRightToLeftShow]) {//阿语
            make.leading.mas_equalTo(self).offset((KScreenWidth-kBannerViewWidth+4));
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
    if (CGRectContainsPoint(CGRectMake(kBannerViewWidth, 0, KScreenWidth-kBannerViewWidth, kBannerViewHeight), point)) {
        return self.bannerScrollView;
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - setter

- (void)tapShowRightImageAction:(UIGestureRecognizer *)gesture {
    YWLog(@"====tapShowRightImageAction========");
    NSInteger urlCount = self.imageUrlArray.count;
    if (self.pageControl.currentPage == (urlCount-1)) {
        [self shouldSelectItemAtIndex:(urlCount-1)];
    } else {
        [self scrollToIndexBanner:(self.pageControl.currentPage + 1) animated:YES];
    }
}

- (void)clickImageView:(UIGestureRecognizer *)gesture {
    YWLog(@"====clickImageView========");
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
    CGFloat bannerWidth = (urlCount == 1) ? KScreenWidth : kBannerViewWidth;
    
    for (NSInteger i=0; i<urlCount; i++) {
        ZFBannerImageView *imageView = [[ZFBannerImageView alloc] init];
        
        if ([SystemConfigUtils isRightToLeftShow]) {//阿语
            CGFloat x = bannerWidth * i + ((i == urlCount-1) ? 4 : 0);
            imageView.frame = CGRectMake(x, 0, bannerWidth, kBannerViewHeight);
        } else {
            imageView.frame = CGRectMake(bannerWidth * i, 0, bannerWidth, kBannerViewHeight);
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

- (void)scrollToIndexBanner:(NSInteger)currentPage animated:(BOOL)animated {
    if (currentPage > self.imageUrlArray.count) return;
    self.pageControl.currentPage = currentPage;
    
    YWLog(@"scrollToIndexBanner==%ld", (long)currentPage);
    CGRect rect = CGRectMake(kBannerViewWidth * currentPage, 0, kBannerViewWidth, kBannerViewHeight);
    [self.bannerScrollView scrollRectToVisible:rect animated:animated];
    [self handleDidShowScrollViewPageAtIndex:currentPage];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat currentIndex = (scrollView.contentOffset.x / kBannerViewWidth);
    CGFloat maxOffset = (kBannerViewWidth * (self.imageUrlArray.count - 1) - (KScreenWidth-kBannerViewWidth));
    if (scrollView.contentOffset.x == maxOffset) {
        currentIndex += 1;//最后一页 ceil
    }
    self.pageControl.currentPage = ceil(currentIndex);
    [self handleDidShowScrollViewPageAtIndex:self.pageControl.currentPage];
    //YWLog(@"scrollViewDidEndDecelerating==%ld==%.2f", self.pageControl.currentPage, currentIndex);
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
        _bannerScrollView.backgroundColor = [UIColor whiteColor];
        _bannerScrollView.delegate = self;
        _bannerScrollView.directionalLockEnabled = YES;
        _bannerScrollView.showsVerticalScrollIndicator = NO;
        _bannerScrollView.showsHorizontalScrollIndicator = NO;
        _bannerScrollView.delaysContentTouches = NO;
        _bannerScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, -(KScreenWidth-kBannerViewWidth));
        _bannerScrollView.bounces = NO;
        _bannerScrollView.clipsToBounds = NO;
        _bannerScrollView.pagingEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapShowRightImageAction:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
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

- (NSMutableArray *)imageViewArray {
    if (!_imageViewArray) {
        _imageViewArray = [NSMutableArray array];
    }
    return _imageViewArray;
}

@end
