//
//  ZFCommunityAlbumPhotoView.m
//  ZZZZZ
//
//  Created by YW on 2019/10/15.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityAlbumPhotoView.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFProgressHUD.h"
#import <YYWebImage/YYWebImage.h>
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFInitViewProtocol.h"

@interface ZFCommunityAlbumPhotoView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView                     *contView;

@property (nonatomic, assign) NSInteger                   counts;

@property (nonatomic, strong) ZFCommunityAlbumPhotoItemView *currenItemView;




@end
@implementation ZFCommunityAlbumPhotoView


- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    self.backgroundColor = ZFC0x000000();
    if (self) {
        [self addSubview:self.scrollView];
        [self addSubview:self.numsLabel];
        
        [self.scrollView addSubview:self.contView];
        
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        [self.contView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.scrollView);
            make.width.mas_equalTo(KScreenWidth);
            make.height.mas_equalTo(KScreenHeight);
        }];
        
        [self.numsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(26);
            make.top.mas_equalTo(self.mas_top).offset(kiphoneXTopOffsetY + 10);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)updateAssets:(NSArray<PYAssetModel *> *)assets index:(NSInteger)index {
    
    self.counts = assets.count;
    NSArray *subViews = self.contView.subviews;
    for (UIView *subView in subViews) {
        if ([subView isKindOfClass:[ZFCommunityAlbumPhotoItemView class]]) {
            [subView removeFromSuperview];
        }
    }
    ZFCommunityAlbumPhotoItemView *tempView;
    for(int i=0; i<assets.count; i++) {
        
        PYAssetModel *assetModel = assets[i];
        
        ZFCommunityAlbumPhotoItemView *itemView = [[ZFCommunityAlbumPhotoItemView alloc] initWithFrame:CGRectZero];
        itemView.tag = 30000 + i;
        [self.contView addSubview:itemView];
        
        if (!tempView) {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.top.bottom.mas_equalTo(self.contView);
                make.width.mas_equalTo(KScreenWidth);
            }];
        } else if(i == assets.count - 1) {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.bottom.top.mas_equalTo(self.contView);
                make.leading.mas_equalTo(tempView.mas_trailing);
                make.width.mas_equalTo(KScreenWidth);
            }];
        } else {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(tempView.mas_trailing);
                make.top.bottom.mas_equalTo(self.contView);
                make.width.mas_equalTo(KScreenWidth);
            }];
        }
        tempView = itemView;
        
        if (assetModel.screenshotImage) {
            tempView.imageView.image = assetModel.screenshotImage;
            
        } else {
            tempView.imageView.image = assetModel.delicateImage ? assetModel.delicateImage : assetModel.degradedImage;
            
            @weakify(tempView)
            [assetModel getOriginImage:^(UIImage *image) {
                @strongify(tempView)
                tempView.imageView.image = image;
            } progress:^(double progress) {
                
            }];
        }
        
    }
        
    [self.contView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(assets.count * KScreenWidth);
    }];
    self.scrollView.contentSize = CGSizeMake(assets.count * KScreenWidth, 0);
    [self.scrollView setContentOffset:CGPointMake(KScreenWidth * index, 0) animated:NO];
    self.numsLabel.text = [NSString stringWithFormat:@"%li/%lu",(long)(index + 1),(long)self.counts];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currenIndex = scrollView.contentOffset.x / KScreenWidth;
    self.numsLabel.text = [NSString stringWithFormat:@"%li/%lu",(long)(currenIndex+1),(long)self.counts];

}

- (void)showView:(BOOL)isShow rect:(CGRect)forRect {
    if (isShow) {
        if (self.superview) {
            [self removeFromSuperview];
        }
        self.hidden = NO;
        [WINDOW addSubview:self];
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(WINDOW);
        }];
        
    } else {
        self.hidden = YES;
        [self removeFromSuperview];
    }
}

- (void)actionTap {
    [self showView:NO rect:CGRectZero];
}

#pragma mark - Property Method

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _scrollView.backgroundColor = ZFCClearColor();
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = YES;
        _scrollView.delegate = self;
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            _scrollView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _scrollView;
}

- (UIView *)contView {
    if (!_contView) {
        _contView = [[UIView alloc] initWithFrame:CGRectZero];
        _contView.backgroundColor = ZFCClearColor();
    }
    return _contView;
}

- (UILabel *)numsLabel {
    if (!_numsLabel) {
        _numsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _numsLabel.textColor = ZFC0xFFFFFF();
    }
    return _numsLabel;
}
@end


@interface ZFCommunityAlbumPhotoItemView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView              *scrollView;
@property (nonatomic, assign) CGPoint                   currentItemCenterPoint;
@property (nonatomic, assign) CGRect                    currentItemFrame;

@end

@implementation ZFCommunityAlbumPhotoItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        //FIXME: occ Bug 1101  用uiscroll支持缩放
//        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] init];
//        [pinchGesture addTarget:self action:@selector(pinchAction:)];
//        pinchGesture.delegate = self;
//        [self addGestureRecognizer:pinchGesture];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.currentItemCenterPoint = self.imageView.center;
    self.currentItemFrame = self.imageView.frame;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (void)pinchAction:(UIPinchGestureRecognizer *)pinch {
    
    YWLog(@"--------pinch");
    if (self.imageView) {
        
        switch (pinch.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                CGFloat height = self.currentItemFrame.size.height * pinch.scale;
                CGFloat width  = self.currentItemFrame.size.width * pinch.scale;
                YWLog(@"--------pinch: height:%f   width:%f",height,width);

                self.imageView.bounds    = CGRectMake(0.0, 0.0, width, height);
                [self setNeedsDisplay];
                break;
            }
            case UIGestureRecognizerStateEnded: {
                self.currentItemFrame = self.imageView.frame;
                self.currentItemCenterPoint = self.imageView.center;
                break;
            }
            default:
                break;
        }
    }
}

@end
