//
//  STLPhotoBrowserView.m
// XStarlinkProject
//
//  Created by odd on 2021/6/30.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLPhotoBrowserView.h"
#include <sys/sysctl.h>

#import "UIView+YYAdd.h"
#import "CALayer+YYAdd.h"
#import "YYCGUtilities.h"
#import "UICollectionViewLeftAlignedLayout.h"


#import "Adorawe-Swift.h"

#define kPhotoPadding 20
@interface STLPhotoGroupItem()<NSCopying>
@property (nonatomic, readonly) UIImage *thumbImage;
@property (nonatomic, readonly) BOOL thumbClippedToTop;
- (BOOL)shouldClipToTop:(CGSize)imageSize forView:(UIView *)view;
@end
@implementation STLPhotoGroupItem

- (UIImage *)thumbImage {
    if ([_thumbView respondsToSelector:@selector(image)]) {
        return ((UIImageView *)_thumbView).image;
    }
    return nil;
}

- (BOOL)thumbClippedToTop {
    if (_thumbView) {
        if (_thumbView.layer.contentsRect.size.height < 1) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)shouldClipToTop:(CGSize)imageSize forView:(UIView *)view {
    if (imageSize.width < 1 || imageSize.height < 1) return NO;
    if (view.frame.size.width < 1 || view.frame.size.height < 1) return NO;
    return imageSize.height / imageSize.width > view.frame.size.width / view.frame.size.height;
}

- (id)copyWithZone:(NSZone *)zone {
    STLPhotoGroupItem *item = [self.class new];
    return item;
}
@end


@interface STLSelectPhotoCCell : UICollectionViewCell

@property (nonatomic, strong) YYAnimatedImageView *imgView;
@property (nonatomic, strong) UIView              *borderWhiteView;
@end

@implementation STLSelectPhotoCCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
        self.imgView = [[YYAnimatedImageView alloc] init];
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        self.imgView.clipsToBounds = YES;
        [self.contentView addSubview:self.imgView];
        
        self.borderWhiteView = [[UIView alloc] initWithFrame:CGRectZero];
        self.borderWhiteView.layer.borderWidth = 1;
        self.borderWhiteView.layer.borderColor = [OSSVThemesColors stlWhiteColor].CGColor;
        self.borderWhiteView.backgroundColor = [UIColor clearColor];
        self.borderWhiteView.hidden = YES;
        [self.contentView addSubview:self.borderWhiteView];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        [self.borderWhiteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(1);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-1);
            make.top.mas_equalTo(self.mas_top).offset(1);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-1);
        }];
        self.imgView.layer.masksToBounds = YES;
        
    }
    return self;
}
@end


@interface STLPhotoGroupCell : UIScrollView <UIScrollViewDelegate>
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, assign) NSInteger page;

@property (nonatomic, assign) BOOL showProgress;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, strong) STLPhotoGroupItem *item;
@property (nonatomic, readonly) BOOL itemDidLoad;
- (void)resizeSubviewSize;
@end

@implementation STLPhotoGroupCell

- (instancetype)init {
    self = super.init;
    if (!self) return nil;
    self.delegate = self;
    self.bouncesZoom = YES;
    self.maximumZoomScale = 3;
    self.multipleTouchEnabled = YES;
    self.alwaysBounceVertical = NO;
    self.showsVerticalScrollIndicator = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    
    _imageContainerView = [UIView new];
    _imageContainerView.clipsToBounds = YES;
    [self addSubview:_imageContainerView];
    
    _imageView = [YYAnimatedImageView new];
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        _imageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    [_imageContainerView addSubview:_imageView];
    
    _progressLayer = [CAShapeLayer layer];
   _progressLayer.size = CGSizeMake(40, 40);
    _progressLayer.cornerRadius = 20;
    _progressLayer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, 7, 7) cornerRadius:(40 / 2 - 7)];
    _progressLayer.path = path.CGPath;
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    _progressLayer.lineWidth = 2;
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.strokeStart = 0;
    _progressLayer.strokeEnd = 0;
    _progressLayer.hidden = YES;
    [self.layer addSublayer:_progressLayer];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _progressLayer.center = CGPointMake(self.width / 2, self.height / 2);
}

- (void)setItem:(STLPhotoGroupItem *)item {
    if (_item == item) return;
    _item = item;
    _itemDidLoad = NO;
    
    [self setZoomScale:1.0 animated:NO];
    self.maximumZoomScale = 1;
    
    [_imageView yy_cancelCurrentImageRequest];

    
    _progressLayer.hidden = NO;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _progressLayer.strokeEnd = 0;
    _progressLayer.hidden = YES;
    [CATransaction commit];
    
    if (!_item) {
        _imageView.image = nil;
        return;
    }
    
    @weakify(self);
    
    [_imageView yy_setImageWithURL:item.largeImageURL placeholder:item.thumbImage options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        @strongify(self);
        if (!self) return;
        CGFloat progress = receivedSize / (float)expectedSize;
        progress = progress < 0.01 ? 0.01 : progress > 1 ? 1 : progress;
        if (isnan(progress)) progress = 0;
        self.progressLayer.hidden = NO;
        self.progressLayer.strokeEnd = progress;
    } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        @strongify(self);
        if (!self) return;
        self.progressLayer.hidden = YES;
        if (stage == YYWebImageStageFinished) {
            self.maximumZoomScale = 3;
            if (image) {
                
                self->_itemDidLoad = YES;
                
                [self resizeSubviewSize];
                [self.imageView.layer addFadeAnimationWithDuration:0.1 curve:UIViewAnimationCurveLinear];
            }
        }
    }];
    [self resizeSubviewSize];
}

- (void)resizeSubviewSize {
    _imageContainerView.origin = CGPointZero;
 
    CGFloat tempWidth = SCREEN_WIDTH;
    CGFloat tempHeight = SCREEN_HEIGHT - kSCREEN_BAR_HEIGHT - kIPHONEX_BOTTOM;
    
    _imageContainerView.width = tempWidth;
    
    UIImage *image = _imageView.image;
    
    CGFloat tempImageHeight = image.size.height;
    CGFloat tempImageWidth = image.size.width;
    
    CGFloat scale = image.size.height / image.size.width;
    CGFloat orScale = tempHeight / tempWidth;
    STLLog(@"---- %f   %f",scale,orScale);
    if (tempImageHeight / tempImageWidth > tempHeight / tempWidth) {
        CGFloat imageWidth = floor(tempImageWidth * tempHeight) / tempImageHeight;
        _imageContainerView.frame = CGRectMake((tempWidth - imageWidth) / 2.0, kSCREEN_BAR_HEIGHT, imageWidth, tempHeight);

    } else {
        CGFloat height = tempImageHeight / tempImageWidth * tempWidth;
        if (height < 1 || isnan(height)) height = tempHeight;
        height = floor(height);
        CGFloat topSpace = (tempHeight - height) / 2.0 + kSCREEN_BAR_HEIGHT;
        _imageContainerView.frame = CGRectMake(0, topSpace, tempWidth, height);

    }
    if (_imageContainerView.height > tempHeight && _imageContainerView.height - tempHeight <= 1) {
        _imageContainerView.height = tempHeight;
    }
    self.contentSize = CGSizeMake(tempWidth, MAX(_imageContainerView.height, tempHeight));
    [self scrollRectToVisible:self.bounds animated:NO];
    
    if (_imageContainerView.height <= tempHeight) {
        self.alwaysBounceVertical = NO;
    } else {
        self.alwaysBounceVertical = YES;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _imageView.frame = _imageContainerView.bounds;
    [CATransaction commit];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = _imageContainerView;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

@end


@interface STLPhotoBrowserView() <UIScrollViewDelegate, UIGestureRecognizerDelegate,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateLeftAlignedLayout>
@property (nonatomic, weak) UIView *fromView;
@property (nonatomic, weak) UIView *toContainerView;

@property (nonatomic, strong) UIImage *snapshotImage;
@property (nonatomic, strong) UIImage *snapshorImageHideFromView;

@property (nonatomic, strong) UIImageView *background;
@property (nonatomic, strong) UIImageView *blurBackground;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) UIPageControl *pager;
@property (nonatomic, assign) CGFloat pagerCurrentPage;
@property (nonatomic, assign) BOOL fromNavigationBarHidden;

@property (nonatomic, assign) NSInteger fromItemIndex;
@property (nonatomic, assign) BOOL isPresented;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint panGestureBeginPoint;

@property (nonatomic, assign) BOOL dismissAnimated;

@property (nonatomic, assign) NSInteger   selectIndex;
@property (nonatomic, assign) int         bottomSelectIndex;
@end

@implementation STLPhotoBrowserView
- (NSString *)machineModel {
    static dispatch_once_t one;
    static NSString *model;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hwcc.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    return model;
}




- (instancetype)initWithGroupItems:(NSArray *)groupItems {
    self = [super init];
    if (groupItems.count == 0) return nil;
    _groupItems = groupItems.copy;
    _blurEffectBackground = YES;
    _bottomSelectIndex = -1;
    
    NSString *model = [self machineModel];
    static NSMutableSet *olddDevices;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        olddDevices = [NSMutableSet new];
        [olddDevices addObject:@"iPod1,1"];
        [olddDevices addObject:@"iPod2,1"];
        [olddDevices addObject:@"iPod3,1"];
        [olddDevices addObject:@"iPod4,1"];
        [olddDevices addObject:@"iPod5,1"];
        
        [olddDevices addObject:@"iPhone1,1"];
        [olddDevices addObject:@"iPhone1,1"];
        [olddDevices addObject:@"iPhone1,2"];
        [olddDevices addObject:@"iPhone2,1"];
        [olddDevices addObject:@"iPhone3,1"];
        [olddDevices addObject:@"iPhone3,2"];
        [olddDevices addObject:@"iPhone3,3"];
        [olddDevices addObject:@"iPhone4,1"];
        
        [olddDevices addObject:@"iPad1,1"];
        [olddDevices addObject:@"iPad2,1"];
        [olddDevices addObject:@"iPad2,2"];
        [olddDevices addObject:@"iPad2,3"];
        [olddDevices addObject:@"iPad2,4"];
        [olddDevices addObject:@"iPad2,5"];
        [olddDevices addObject:@"iPad2,6"];
        [olddDevices addObject:@"iPad2,7"];
        [olddDevices addObject:@"iPad3,1"];
        [olddDevices addObject:@"iPad3,2"];
        [olddDevices addObject:@"iPad3,3"];
    });
    if ([olddDevices containsObject:model]) {
        _blurEffectBackground = NO;
    }
    
    self.backgroundColor = [OSSVThemesColors col_F5F5F5];
    self.frame = [UIScreen mainScreen].bounds;
    self.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.delegate = self;
    tap2.numberOfTapsRequired = 2;
    [tap requireGestureRecognizerToFail: tap2];
    [self addGestureRecognizer:tap2];
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    press.delegate = self;
    [self addGestureRecognizer:press];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    _panGesture = pan;
    
    
    _cells = @[].mutableCopy;
    
    _background = UIImageView.new;
    _background.frame = self.bounds;
    _background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _blurBackground = UIImageView.new;
    _blurBackground.frame = self.bounds;
    _blurBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _contentView = UIView.new;
    _contentView.frame = self.bounds;
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _scrollView = UIScrollView.new;
   _scrollView.frame = CGRectMake(-kPhotoPadding / 2, 0, self.width + kPhotoPadding, self.height);
    _scrollView.delegate = self;
    _scrollView.scrollsToTop = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.alwaysBounceHorizontal = groupItems.count > 1;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.delaysContentTouches = NO;
    _scrollView.canCancelContentTouches = YES;
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        _scrollView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
    _pager = [[UIPageControl alloc] init];
    _pager.hidesForSinglePage = YES;
    _pager.userInteractionEnabled = NO;
    _pager.width = self.width - 36;
    _pager.height = 10;
    _pager.center = CGPointMake(self.width / 2, self.height - 18);
    _pager.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _pager.hidden = self.isHidePager;
    
    [self addSubview:_background];
    [self addSubview:_blurBackground];
    [self addSubview:_contentView];
    [_contentView addSubview:_scrollView];
    [_contentView addSubview:_pager];
    
    [self addSubview:self.dismissButton];
    [self addSubview:self.countLabel];
    [self addSubview:self.bottomCollectView];
    
    [self.dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.mas_top).offset(22+kSCREEN_BAR_HEIGHT);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.dismissButton.mas_centerY);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.bottomCollectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        if (SCREEN_HEIGHT > 736.0) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(-kIPHONEX_BOTTOM);
        } else {
            make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
        }
        make.height.mas_equalTo(72);
    }];
    [self.bottomCollectView reloadData];
    return self;
}

- (void)presentFromImageView:(UIView *)fromView
                 toContainer:(UIView *)toContainer
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion {
    if (!toContainer) return;
    
    _fromView = fromView;
    _toContainerView = toContainer;
    _dismissAnimated = animated;
    NSInteger page = -1;
    for (NSUInteger i = 0; i < self.groupItems.count; i++) {
        
        if([fromView isEqual:((STLPhotoGroupItem *)self.groupItems[i]).thumbView]){
            page = (int)i;
            break;
        }
    }
    if (page == -1) page = 0;
    _fromItemIndex = page;
    
    self.countLabel.text = [NSString stringWithFormat:@"%li / %li",(long)_fromItemIndex,(long)self.groupItems.count];
    _snapshotImage = [_toContainerView snapshotImageAfterScreenUpdates:NO];
    BOOL fromViewHidden = fromView.hidden;
    fromView.hidden = YES;
    _snapshorImageHideFromView = [_toContainerView snapshotImage];
    fromView.hidden = fromViewHidden;
    
    _background.image = _snapshorImageHideFromView;
//    if (_blurEffectBackground) {
//        _blurBackground.image = [_snapshorImageHideFromView yy_imageByBlurDark]; //Same to UIBlurEffectStyleDark
//    } else {
//        _blurBackground.image = [UIImage yy_imageWithColor:[UIColor blackColor]];
//    }
    
    _blurBackground.image = [UIImage yy_imageWithColor:[UIColor whiteColor]];
    self.size = _toContainerView.size;
    self.blurBackground.alpha = 0;
    self.bottomCollectView.alpha = 0;
    self.pager.alpha = 0;
    self.pager.numberOfPages = self.groupItems.count;
    self.pager.currentPage = page;
    [_toContainerView addSubview:self];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.width * self.groupItems.count, _scrollView.height);
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.width * _pager.currentPage, 0, _scrollView.width, _scrollView.height) animated:NO];
    [self scrollViewDidScroll:_scrollView];
    
    [UIView setAnimationsEnabled:YES];
    _fromNavigationBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    
    
//    [self.bottomCollectView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];

    
    STLPhotoGroupCell *cell = [self cellForPage:self.currentPage];
    STLPhotoGroupItem *item = _groupItems[self.currentPage];
    
    if (!item.thumbClippedToTop) {
        NSString *imageKey = [[YYWebImageManager sharedManager] cacheKeyForURL:item.largeImageURL];
        if ([[YYWebImageManager sharedManager].cache getImageForKey:imageKey withType:YYImageCacheTypeMemory]) {
            cell.item = item;
        }
    }
    
    if (!cell.item) {
        cell.imageView.image = item.thumbImage;
        [cell resizeSubviewSize];
        self.tempImageSize = cell.imageContainerView.frame;
    }
    
    if (item.thumbClippedToTop) {
        CGRect fromFrame = [_fromView convertRect:_fromView.bounds toView:cell];
        CGRect originFrame = cell.imageContainerView.frame;
        CGFloat scale = fromFrame.size.width / cell.imageContainerView.width;
        
        cell.imageContainerView.centerX = CGRectGetMidX(fromFrame);
        cell.imageContainerView.height = fromFrame.size.height / scale;
        cell.imageContainerView.layer.transformScale = scale;
        cell.imageContainerView.centerY = CGRectGetMidY(fromFrame);
        self.tempImageSize = originFrame;
        
        float oneTime = animated ? 0.25 : 0;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            _blurBackground.alpha = 1;
        }completion:NULL];
        
        _scrollView.userInteractionEnabled = NO;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.imageContainerView.layer.transformScale = 1;
            cell.imageContainerView.frame = originFrame;
            _pager.alpha = 1;
            _bottomCollectView.alpha = 1;
        }completion:^(BOOL finished) {
            _isPresented = YES;
            [self scrollViewDidScroll:_scrollView];
            _scrollView.userInteractionEnabled = YES;
            [self hidePager];
            if (completion) completion();
        }];
        
    } else {
        CGRect fromFrame = [_fromView convertRect:_fromView.bounds toView:cell.imageContainerView];
        
        cell.imageContainerView.clipsToBounds = NO;
        cell.imageView.frame = fromFrame;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageView.clipsToBounds = YES;
        float oneTime = animated ? 0.18 : 0;
        [UIView animateWithDuration:oneTime*2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            _blurBackground.alpha = 1;
        }completion:NULL];
        
        _scrollView.userInteractionEnabled = NO;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.imageView.frame = cell.imageContainerView.bounds;
            cell.imageView.layer.transformScale = 1.01;
            _bottomCollectView.alpha = 1;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
                cell.imageView.layer.transformScale = 1.0;
                _pager.alpha = 1;
            }completion:^(BOOL finished) {
                cell.imageContainerView.clipsToBounds = YES;
                _isPresented = YES;
                [self scrollViewDidScroll:_scrollView];
                _scrollView.userInteractionEnabled = YES;
                [self hidePager];
                if (completion) completion();
            }];
        }];
    }
    
    /////occ 添加
    if (self.showDismiss) {
        
        float oneTime = animated ? 0.25 : 0;
        self.dismissButton.alpha = 0.0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(oneTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            /////显示图片上
//            CGRect dismissButtonFrame = self.dismissButton.frame;
//            dismissButtonFrame.origin.y = self.tempImageSize.origin.y - 40;
//            self.dismissButton.frame = dismissButtonFrame;
            ///固定位置
            self.dismissButton.hidden = NO;
            self.dismissButton.alpha = 1.0;
        });
        
        
        
    } else {
        self.dismissButton.hidden = YES;
    }
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion {
    
    
    if (self.dismissCompletion) { //商详使用时不要背景图
        self.background.image = nil;
        self.blurBackground.image = nil;
        self.background.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        self.blurBackground.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        self.dismissCompletion(self.currentPage);
    }
    
    [UIView setAnimationsEnabled:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:_fromNavigationBarHidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    NSInteger currentPage = self.currentPage;
    STLPhotoGroupCell *cell = [self cellForPage:currentPage];
    STLPhotoGroupItem *item = _groupItems[currentPage];
    
    UIView *fromView = nil;
    if (_fromItemIndex == currentPage) {
        fromView = _fromView;
    } else {
        fromView = item.thumbView;
    }
    
    if (self.isDismissToFirstPosition) {
        fromView = _fromView;
    }
    
    [self cancelAllImageLoad];
    _isPresented = NO;
    BOOL isFromImageClipped = fromView.layer.contentsRect.size.height < 1;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (isFromImageClipped) {
        CGRect frame = cell.imageContainerView.frame;
        cell.imageContainerView.layer.anchorPoint = CGPointMake(0.5, 0);
        cell.imageContainerView.frame = frame;
    }
    cell.progressLayer.hidden = YES;
    [CATransaction commit];
    

    if (fromView == nil) {
        if (!self.dismissCompletion) {
            self.background.image = _snapshotImage;
        }
        [UIView animateWithDuration:animated ? 0.25 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 0.0;
            self.scrollView.layer.transformScale = 0.95;
            self.scrollView.alpha = 0;
            self.pager.alpha = 0;
            self.blurBackground.alpha = 0;
        }completion:^(BOOL finished) {
            self.scrollView.layer.transformScale = 1;
            [self removeFromSuperview];
            [self cancelAllImageLoad];
            if (completion) completion();
        }];
        return;
    }
    
    if (_fromItemIndex != currentPage) {
        if (!self.dismissCompletion) {
            _background.image = _snapshotImage;
        }
        [_background.layer addFadeAnimationWithDuration:0.25 curve:UIViewAnimationCurveEaseOut];
    } else {
        if (!self.dismissCompletion) {
            _background.image = _snapshorImageHideFromView;
        }
    }

    
    if (isFromImageClipped) {
        CGPoint off = cell.contentOffset;
        off.y = 0 - cell.contentInset.top;
        [cell setContentOffset:off animated:animated];
    }
#warning 此处为处理查看大图时，取消的动画效果
    [UIView animateWithDuration:animated ? 0.2 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        _pager.alpha = 0.0;
        _blurBackground.alpha = 0.0;
        _dismissButton.alpha = 0.0;
        _bottomCollectView.alpha = 0.0;
        _countLabel.alpha = 0.0;
        _dismissButton.alpha = 0.0;

        if (isFromImageClipped) {
            CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell];
            CGFloat scale = fromFrame.size.width / cell.imageContainerView.width * cell.zoomScale;
            CGFloat height = fromFrame.size.height / fromFrame.size.width * cell.imageContainerView.width;
            if (isnan(height)) height = cell.imageContainerView.height;
            
            cell.imageContainerView.height = height;
            cell.imageContainerView.center = CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMinY(fromFrame));
            cell.imageContainerView.layer.transformScale = scale;
            
        } else {
            if (animated) {
                CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell.imageContainerView];
                cell.imageContainerView.clipsToBounds = NO;
                cell.imageView.contentMode = fromView.contentMode;
                cell.imageView.frame = fromFrame;
            } else {
                CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell];
                cell.imageContainerView.clipsToBounds = NO;
                cell.imageView.contentMode = fromView.contentMode;
                cell.imageView.frame = fromFrame;
            }
        }
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:!animated ? 0.15 : 0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            cell.imageContainerView.layer.anchorPoint = CGPointMake(0.5, 0.5);
            if (completion) completion();
        }];
    }];
}

- (void)dismiss {
    [self dismissAnimated:_dismissAnimated completion:nil];
}


- (void)cancelAllImageLoad {
    [_cells enumerateObjectsUsingBlock:^(STLPhotoGroupCell *cell, NSUInteger idx, BOOL *stop) {
        [cell.imageView yy_cancelCurrentImageRequest];
    }];
}

#pragma mark

#pragma mark --UICollectionDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return self.groupItems.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    STLSelectPhotoCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STLSelectPhotoCCell" forIndexPath:indexPath];
    if (self.groupItems.count > indexPath.row) {
        STLPhotoGroupItem *item = self.groupItems[indexPath.row];
        
        [cell.imgView yy_setImageWithURL:item.largeImageURL
                          placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                              options:kNilOptions
                           completion:nil];
    }
    
    cell.borderWhiteView.hidden = YES;
    if (self.selectIndex == indexPath.row) {
        cell.borderWhiteView.hidden = NO;
        cell.layer.borderWidth = 1.0;
        cell.layer.borderColor = [OSSVThemesColors col_0D0D0D].CGColor;
    } else {
        cell.layer.borderWidth = 0.5;
        cell.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.selectIndex) {
        return;
    }
    self.bottomSelectIndex = (int)indexPath.row;
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * indexPath.row, 0) animated:YES];
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (APP_TYPE == 3) {
        return CGSizeMake(60, 60);
    }
    return CGSizeMake(54, 72);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 12, 0, 12);
}
///如果不加这个，cell之间有间隙
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 12;
}



#pragma mark - scrolldelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.bottomCollectView) {
        return;
    }
    [self updateCellsForReuse];
    
    CGFloat floatPage = _scrollView.contentOffset.x / _scrollView.width;
    NSInteger page = _scrollView.contentOffset.x / _scrollView.width + 0.5;
    
    for (NSInteger i = page - 1; i <= page + 1; i++) { // preload left and right cell
        if (i >= 0 && i < self.groupItems.count) {
            STLPhotoGroupCell *cell = [self cellForPage:i];
            if (!cell) {
                STLPhotoGroupCell *cell = [self dequeueReusableCell];
                cell.page = i;
                cell.left = (self.width + kPhotoPadding) * i + kPhotoPadding / 2;
                
                if (_isPresented) {
                    cell.item = self.groupItems[i];
                }
                [self.scrollView addSubview:cell];
            } else {
                if (_isPresented && !cell.item) {
                    cell.item = self.groupItems[i];
                }
            }
        }
    }
    
    if (self.bottomSelectIndex >= 0) {
        
        NSInteger intPage = self.bottomSelectIndex;
        
        _pager.currentPage = intPage;
        self.countLabel.text = [NSString stringWithFormat:@"%li / %li",(long)(intPage+1),(long)self.groupItems.count];
        
        if (self.selectIndex == intPage) {
            return;
        }
        

        self.selectIndex = intPage;
        [self.bottomCollectView reloadData];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            _pager.alpha = 1;
            if (self.groupItems.count * (54 + 12) >= SCREEN_WIDTH) {
                [self.bottomCollectView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:intPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            }
        }completion:^(BOOL finish) {
        }];
        
    } else {
        
        NSInteger intPage = floatPage + 0.5;
        intPage = intPage < 0 ? 0 : intPage >= _groupItems.count ? (int)_groupItems.count - 1 : intPage;
        
        _pager.currentPage = intPage;
        self.countLabel.text = [NSString stringWithFormat:@"%li / %li",(long)(intPage+1),(long)self.groupItems.count];
        
        if (self.selectIndex == intPage) {
            return;
        }
        
        
        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:self.selectIndex inSection:0];
        STLSelectPhotoCCell *cell = (STLSelectPhotoCCell *)[self.bottomCollectView cellForItemAtIndexPath:currentIndexPath];
        if (cell) {
            cell.layer.borderWidth = 0.5;
            cell.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
            cell.borderWhiteView.hidden = YES;
        }
        
        self.selectIndex = intPage;
        NSIndexPath *indexPathNew = [NSIndexPath indexPathForRow:intPage inSection:0];
        STLSelectPhotoCCell *cellNew = (STLSelectPhotoCCell *)[self.bottomCollectView cellForItemAtIndexPath:indexPathNew];
        if (cellNew) {
            cellNew.layer.borderWidth = 1.0;
            cellNew.layer.borderColor = [OSSVThemesColors col_0D0D0D].CGColor;
            cellNew.borderWhiteView.hidden = NO;
        }
        
        if (self.groupItems.count * (54 + 12) >= SCREEN_WIDTH) {
            [self.bottomCollectView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:intPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            _pager.alpha = 1;
        }completion:^(BOOL finish) {
        }];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.bottomCollectView) {
        return;
    }
    if (self.bottomSelectIndex>=0) {
        self.bottomSelectIndex = -1;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView == self.bottomCollectView) {
        return;
    }
    if (!decelerate) {
        [self hidePager];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.bottomCollectView) {
        return;
    }
    [self hidePager];
}


- (void)hidePager {
        [UIView animateWithDuration:0.3 delay:0.8 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
            _pager.alpha = 0;
        }completion:^(BOOL finish) {
        }];
}

/// enqueue invisible cells for reuse
- (void)updateCellsForReuse {
    for (STLPhotoGroupCell *cell in _cells) {
        if (cell.superview) {
            if (cell.left > _scrollView.contentOffset.x + _scrollView.width * 2||
                cell.right < _scrollView.contentOffset.x - _scrollView.width) {
                [cell removeFromSuperview];
                cell.page = -1;
                cell.item = nil;
            }
        }
    }
}

/// dequeue a reusable cell
- (STLPhotoGroupCell *)dequeueReusableCell {
    STLPhotoGroupCell *cell = nil;
    for (cell in _cells) {
        if (!cell.superview) {
            return cell;
        }
    }
    
    cell = [STLPhotoGroupCell new];
    cell.frame = self.bounds;
    cell.imageContainerView.frame = self.bounds;
    cell.imageView.frame = cell.bounds;
    cell.page = -1;
    cell.item = nil;
    [_cells addObject:cell];
    return cell;
}

/// get the cell for specified page, nil if the cell is invisible
- (STLPhotoGroupCell *)cellForPage:(NSInteger)page {
    for (STLPhotoGroupCell *cell in _cells) {
        if (cell.page == page) {
            return cell;
        }
    }
    return nil;
}

- (NSInteger)currentPage {
    NSInteger page = _scrollView.contentOffset.x / _scrollView.width + 0.5;
    if (page >= _groupItems.count) page = (NSInteger)_groupItems.count - 1;
    if (page < 0) page = 0;
    return page;
}

- (void)showHUD:(NSString *)msg {
    if (!msg.length) return;
    UIFont *font = [UIFont systemFontOfSize:17];
    CGSize size = [msg sizeWithFont:font constrainedToSize:CGSizeMake(200, 200) lineBreakMode:NSLineBreakByCharWrapping];//[msg sizeForFont:font size:CGSizeMake(200, 200) mode:NSLineBreakByCharWrapping];

    UILabel *label = [UILabel new];
    label.size = CGSizePixelCeil(size);
    label.font = font;
    label.text = msg;
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    
    UIView *hud = [UIView new];
    hud.size = CGSizeMake(label.width + 20, label.height + 20);
    hud.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.650];
    hud.clipsToBounds = YES;
    hud.layer.cornerRadius = 8;
    
    label.center = CGPointMake(hud.width / 2, hud.height / 2);
    [hud addSubview:label];
    
    hud.center = CGPointMake(self.width / 2, self.height / 2);
    hud.alpha = 0;
    [self addSubview:hud];
    
    [UIView animateWithDuration:0.4 animations:^{
        hud.alpha = 1;
    }];
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:0.4 animations:^{
            hud.alpha = 0;
        } completion:^(BOOL finished) {
            [hud removeFromSuperview];
        }];
    });
}


#pragma mark - UIGestureRecognizer

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    CGPoint point = [touch locationInView:self];
//    BOOL inside = [self.bottomCollectView pointInside:point withEvent:UIEventTypeTouches];
//    if(inside){
//        return NO;
//    }
    
    if ([touch.view isKindOfClass:[UICollectionView class]]) {
        return NO;
    }
    UIView *collectView = touch.view.parentCollectionView;
    if (collectView) {
        return NO;;
    }
    return YES;
}

- (void)tap:(UITapGestureRecognizer *)g {
//    CGPoint loc = [g locationInView:self];
//    if (CGRectContainsPoint(self.bottomCollectView.frame, loc)) {
//        return;
//    }
    [self dismiss];
}
- (void)doubleTap:(UITapGestureRecognizer *)g {
//    CGPoint loc = [g locationInView:self];
//    if (CGRectContainsPoint(self.bottomCollectView.frame, loc)) {
//        return;
//    }
    
    if (!_isPresented) return;
    STLPhotoGroupCell *tile = [self cellForPage:self.currentPage];
    if (tile) {
        if (tile.zoomScale > 1) {
            [tile setZoomScale:1 animated:YES];
        } else {
            CGPoint touchPoint = [g locationInView:tile.imageView];
            CGFloat newZoomScale = tile.maximumZoomScale;
            CGFloat xsize = self.width / newZoomScale;
            CGFloat ysize = self.height / newZoomScale;
            [tile zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        }
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)g {
    
//    CGPoint loc = [g locationInView:self];
//    if (CGRectContainsPoint(self.bottomCollectView.frame, loc)) {
//        return;
//    }
    
    if (!_isPresented) return;
    
    STLPhotoGroupCell *tile = [self cellForPage:self.currentPage];
    if (!tile.imageView.image) return;
    
    // try to save original image data if the image contains multi-frame (such as GIF/APNG)
    id imageItem = [tile.imageView.image yy_imageDataRepresentation];
    YYImageType type = YYImageDetectType((__bridge CFDataRef)(imageItem));
    if (type != YYImageTypePNG &&
        type != YYImageTypeJPEG &&
        type != YYImageTypeGIF) {
        imageItem = tile.imageView.image;
    }
    
    // 点击崩溃
//    UIActivityViewController *activityViewController =
//    [[UIActivityViewController alloc] initWithActivityItems:@[imageItem] applicationActivities:nil];
//    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
//        activityViewController.popoverPresentationController.sourceView = self;
//    }
//
//    UIViewController *toVC = self.toContainerView.viewController;
//    if (!toVC) toVC = self.viewController;
//    [toVC presentViewController:activityViewController animated:YES completion:nil];
}

- (void)pan:(UIPanGestureRecognizer *)g {
    
//    CGPoint loc = [g locationInView:self];
//    if (CGRectContainsPoint(self.bottomCollectView.frame, loc)) {
//        return;
//    }
    
    switch (g.state) {
        case UIGestureRecognizerStateBegan: {
            if (_isPresented) {
                _panGestureBeginPoint = [g locationInView:self];
            } else {
                _panGestureBeginPoint = CGPointZero;
            }
        } break;
        case UIGestureRecognizerStateChanged: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            _scrollView.top = deltaY;
            
            CGFloat alphaDelta = 160;
            CGFloat alpha = (alphaDelta - fabs(deltaY) + 50) / alphaDelta;
            alpha = YY_CLAMP(alpha, 0, 1);
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
                _blurBackground.alpha = alpha;
                _pager.alpha = alpha;
            } completion:nil];
            
        } break;
        case UIGestureRecognizerStateEnded: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint v = [g velocityInView:self];
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            
            if (fabs(v.y) > 1000 || fabs(deltaY) > 120) {
                [self cancelAllImageLoad];
                _isPresented = NO;
                [[UIApplication sharedApplication] setStatusBarHidden:_fromNavigationBarHidden withAnimation:UIStatusBarAnimationFade];
                
                BOOL moveToTop = (v.y < - 50 || (v.y < 50 && deltaY < 0));
                CGFloat vy = fabs(v.y);
                if (vy < 1) vy = 1;
                CGFloat duration = (moveToTop ? _scrollView.bottom : self.height - _scrollView.top) / vy;
                duration *= 0.8;
                duration = YY_CLAMP(duration, 0.05, 0.3);
                
                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    _blurBackground.alpha = 0;
                    _pager.alpha = 0;
                    if (moveToTop) {
                        _scrollView.bottom = 0;
                    } else {
                        _scrollView.top = self.height;
                    }
                } completion:^(BOOL finished) {
                    [self removeFromSuperview];
                }];
                
                _background.image = _snapshotImage;
                [_background.layer addFadeAnimationWithDuration:0.3 curve:UIViewAnimationCurveEaseInOut];
                
            } else {
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:v.y / 1000 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    _scrollView.top = 0;
                    _blurBackground.alpha = 1;
                    _pager.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];
            }
            
        } break;
        case UIGestureRecognizerStateCancelled : {
            _scrollView.top = 0;
            _blurBackground.alpha = 1;
        }
        default:break;
    }
}

- (void)setIsHidePager:(BOOL)isHidePager {
    _isHidePager = isHidePager;
    if (_pager) {
        _pager.hidden = isHidePager;
    }
}

- (UIButton *)dismissButton {
    if (!_dismissButton) {
        _dismissButton = [UIButton new];
        [_dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [_dismissButton setImage:[UIImage imageNamed:@"close_circel_32"] forState:UIControlStateNormal];
        [_dismissButton setImage:[UIImage imageNamed:@"close_circel_32"] forState:UIControlStateHighlighted];

        _dismissButton.hidden = YES;
//        _dismissButton.frame = CGRectMake(SCREEN_WIDTH - 36, 56 + kIPHONEX_TOP_SPACE, 24, 24);
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            _dismissButton.frame = CGRectMake(12, 100, 24, 24);
//        }
    }
    return _dismissButton;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _countLabel.font = [UIFont systemFontOfSize:14];
        _countLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _countLabel;
}


- (UICollectionView *)bottomCollectView {
    if (!_bottomCollectView) {
//        UICollectionViewLeftAlignedLayout *flowLayout = [[UICollectionViewLeftAlignedLayout alloc] init];
        STLCollectionViewLeftAlignedLayout *flowLayout = [[STLCollectionViewLeftAlignedLayout alloc] init];
        
        flowLayout.minimumLineSpacing = 12;
        flowLayout.minimumInteritemSpacing = 12;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            flowLayout.alignedLayoutType = STLAlignedLayoutTypeHorizontalLeft;
        } else {
            flowLayout.alignedLayoutType = STLAlignedLayoutTypeHorizontalRight;
        }
        
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _bottomCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 72) collectionViewLayout:flowLayout];
        [_bottomCollectView registerClass:[STLSelectPhotoCCell class] forCellWithReuseIdentifier:@"STLSelectPhotoCCell"];
        _bottomCollectView.backgroundColor = [UIColor clearColor];
        //_bottomCollectView.minimumZoomScale = 0;
        _bottomCollectView.dataSource = self;
        _bottomCollectView.delegate = self;
        _bottomCollectView.showsHorizontalScrollIndicator = NO;
        _bottomCollectView.showsVerticalScrollIndicator = NO;
    }
    return _bottomCollectView;
}
@end
