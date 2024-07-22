//
//  ZFReviewPhotoBrowseCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFReviewPhotoBrowseCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "UIView+LayoutMethods.h"
#import <YYWebImage/YYWebImage.h>

@interface ZFReviewPhotoBrowseCell ()<ZFInitViewProtocol, UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) YYAnimatedImageView *reviewImageView;
@end

@implementation ZFReviewPhotoBrowseCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.backgroundColor = [UIColor blackColor];
    self.contentView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.reviewImageView];
}

- (void)zfAutoLayoutView {
    self.reviewImageView.frame = UIScreen.mainScreen.bounds;
    self.scrollView.frame = UIScreen.mainScreen.bounds;
}

#pragma mark - Setter

- (void)setImageurl:(NSString *)imageurl {
    _imageurl = imageurl;
    if (![imageurl isKindOfClass:[NSString class]]) return;
    
    [self.reviewImageView yy_setImageWithURL:[NSURL URLWithString:imageurl]
                                 placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                     options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                    progress:nil
                                   transform:nil
                                  completion:nil];
}

#pragma mark -<UIScrollViewDelegate>

- (void)tapGestureAction:(UISwipeGestureRecognizer *)tapGesture {
    if (self.tapImageBlock) {
        self.tapImageBlock();
    }
}

- (void)doubleTapAction:(UITapGestureRecognizer *)tapGes {
    CGFloat currScale = self.scrollView.zoomScale;
    CGFloat minScale = self.scrollView.minimumZoomScale;
    CGFloat maxScale = self.scrollView.maximumZoomScale;
    CGFloat goalScale;
    
    if (currScale == minScale) {
        goalScale = maxScale;
    } else {
        goalScale = minScale;
    }
    if (currScale == goalScale) {
        return;
    }
    CGPoint touchPoint = [tapGes locationInView:self.reviewImageView];
    CGFloat xsize = self.scrollView.frame.size.width / goalScale;
    CGFloat ysize = self.scrollView.frame.size.height/ goalScale;
    
    CGFloat x = touchPoint.x-xsize/2;
    CGFloat y = touchPoint.y-ysize/2;
    [self.scrollView zoomToRect:CGRectMake(x, y, xsize, ysize) animated:YES];
}

/// 缩放的子视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.reviewImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    BOOL widthIsSmall = self.reviewImageView.width < scrollView.width;
    BOOL heightIsSmall = self.reviewImageView.height < scrollView.height;
    
    if (widthIsSmall) {
        self.reviewImageView.centerX = scrollView.centerX;
    } else {
        self.reviewImageView.left = 0;
    }
    if (heightIsSmall) {
        self.reviewImageView.centerY = scrollView.centerY;
    } else {
        self.reviewImageView.top = 0;
    }
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        _scrollView.backgroundColor = UIColor.blackColor;
        _scrollView.delegate = self;
        _scrollView.maximumZoomScale = KScreenHeight / KScreenWidth; //缩放比例
        _scrollView.minimumZoomScale = 1;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        UITapGestureRecognizer *doubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        doubleGesture.numberOfTapsRequired = 2;
        [_scrollView addGestureRecognizer:doubleGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [tapGesture requireGestureRecognizerToFail:doubleGesture];
        [_scrollView addGestureRecognizer:tapGesture];
    }
    return _scrollView;
}

- (YYAnimatedImageView *)reviewImageView {
    if (!_reviewImageView) {
        _reviewImageView = [[YYAnimatedImageView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        _reviewImageView.center = _scrollView.center;
        _reviewImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _reviewImageView.contentMode = UIViewContentModeScaleAspectFit;
        _reviewImageView.backgroundColor = [UIColor blackColor];
        _reviewImageView.image = [UIImage imageNamed:@"loading_cat_list"];
    }
    return _reviewImageView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.reviewImageView.image = nil;
}

@end
