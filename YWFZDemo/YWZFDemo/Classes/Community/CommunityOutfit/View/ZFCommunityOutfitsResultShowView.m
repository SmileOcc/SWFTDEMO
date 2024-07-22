//
//  ZFCommunityOutfitsResultShowView.m
//  ZZZZZ
//
//  Created by YW on 2019/10/15.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityOutfitsResultShowView.h"
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
#import "ZFSystemPhototHelper.h"
#import "ZFLocalizationString.h"
#import "ZFProgressHUD.h"

@interface ZFCommunityOutfitsResultShowView ()<UIGestureRecognizerDelegate>

@end

@implementation ZFCommunityOutfitsResultShowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ZFC0x000000();
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        
        [self addSubview:self.imageView];
        [self addSubview:self.saveButton];
        
        self.imageView.backgroundColor = ZFRandomColor();
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
            make.height.mas_equalTo(self.mas_width).multipliedBy(1.0);
        }];
        
        [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(-(kiphoneXHomeBarHeight + 16));
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] init];
        [panGesture addTarget:self action:@selector(positionPanAction:)];
        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
        
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] init];
        [pinchGesture addTarget:self action:@selector(pinchAction:)];
        pinchGesture.delegate = self;
        [self addGestureRecognizer:pinchGesture];
        
        
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] init];
        [rotationGesture addTarget:self action:@selector(rotationAction:)];
        rotationGesture.delegate = self;
        [self addGestureRecognizer:rotationGesture];

    }
    return self;
}

- (void)setCoverImage:(UIImage *)image {
    if (image) {
        self.imageView.image = image;
    }
}

- (void)showView:(BOOL)isShow {
    if (isShow) {
        if (self.superview) {
            [self.superview removeFromSuperview];
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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.currentItemCenterPoint = self.imageView.center;
    self.currentItemFrame = self.imageView.frame;
}

#pragma mark - GestureRecognizer

- (void)actionSave:(UIButton *)sender {
    
    if ([ZFSystemPhototHelper isCanUsePhotos]) {
        if (self.imageView.image) {
            UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
        }
    } else {
        ShowToastToViewWithText(self.superview, ZFLocalizedString(@"AccoundHeaderView_Settings_Photos",nil));
    }
}
- (void)tapAction {
    [self showView:NO];
}

- (void)positionPanAction:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint translatedPoint = [panGesture translationInView:self];
    YWLog(@"--------pan: x:%f   y:%f",translatedPoint.x,translatedPoint.y);
    if (self.imageView) {
        
        CGPoint currentCentPoint = self.currentItemCenterPoint;
        switch (panGesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                currentCentPoint = CGPointMake(self.currentItemCenterPoint.x + translatedPoint.x, self.currentItemCenterPoint.y + translatedPoint.y);
                self.imageView.center = currentCentPoint;
                [self setNeedsDisplay];
                break;
            }
            case UIGestureRecognizerStateEnded: {
                self.currentItemCenterPoint = self.imageView.center;
                self.currentItemFrame = self.imageView.frame;
                
                break;
            }
            default:
                break;
        }
    }
    
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


- (void)rotationAction:(UIRotationGestureRecognizer *)rotationGesture {
    YWLog(@"--------rotation");
    if (self.imageView) {
        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, rotationGesture.rotation) ;
        rotationGesture.rotation = 0 ;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    YWLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    if (!error) {
        ShowToastToViewWithText(self.superview, ZFLocalizedString(@"Success", nil));
    } else {
        YWLog(@"%@", error.description);
    }
}


- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton addTarget:self action:@selector(actionSave:) forControlEvents:UIControlEventTouchUpInside];
        [_saveButton setImage:[UIImage imageNamed:@"picture_save"] forState:UIControlStateNormal];
        [_saveButton setTitle:ZFLocalizedString(@"Profile_Save_Button", nil) forState:UIControlStateNormal];
        [_saveButton zfLayoutStyle:ZFButtonEdgeInsetsStyleLeft imageTitleSpace:4];
    }
    return _saveButton;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}

@end
