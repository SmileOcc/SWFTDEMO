//
//  ZFSearchMapCropViewController.m
//  ZZZZZ
//
//  Created by YW on 24/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchMapCropViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFCameraImageCutView.h"
#import "ZFThemeManager.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFSearchMapCropViewController ()<ZFInitViewProtocol>

@property (nonatomic, strong) UIImageView   *sourceImageView;
@property (nonatomic, strong) UIButton      *confirmButton;
@property (nonatomic, strong) UIView        *iPhoneXBottomView;
@property (nonatomic, strong) ZFCameraImageCutView *imageCutView;
// 剪切的位置
@property (nonatomic, assign) CGRect cutFrame;

@end

@implementation ZFSearchMapCropViewController

- (instancetype)initWithCutFrame:(CGRect)cutFrame {
    if (self = [super init]) {
        self.cutFrame = cutFrame;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds   = YES;
    self.title = ZFLocalizedString(@"crop_title", nil);
    [self zfInitView];
    [self zfAutoLayoutView];
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    [self.view addSubview:self.sourceImageView];
    [self.view addSubview:self.iPhoneXBottomView];
    [self.view addSubview:self.imageCutView];
    [self.iPhoneXBottomView addSubview:self.confirmButton];
}

- (void)zfAutoLayoutView {
    [self.sourceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.iPhoneXBottomView.mas_top);
    }];
    
    [self.iPhoneXBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(kiphoneXHomeBarHeight + 56);
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
        make.top.mas_equalTo(self.iPhoneXBottomView.mas_top).offset(8);
        make.height.mas_equalTo(40);
    }];
    
    [self.view layoutIfNeeded];
    
    self.imageCutView.frame = self.sourceImageView.bounds;
    [self.imageCutView setPreCutRect:self.cutFrame];
}

#pragma mark - Action
- (void)refreshResultData {
    if (self.confirmHandler) {
        [self.navigationController popViewControllerAnimated:YES];
        UIImage *cropImage = [self clipImage];
        self.confirmHandler(cropImage, self.cutFrame);
    }
}

- (UIImage *)clipImage {
    self.cutFrame = [self.imageCutView cutResultImageRect];
    return [self screenshotWithRect:[self.imageCutView cutResultImageRect]];
}

- (UIImage *)screenshotWithRect:(CGRect)rect
{
    BOOL ignoreOrientation = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0");
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGSize imageSize = CGSizeZero;
    CGFloat width = rect.size.width, height = rect.size.height;
    CGFloat x = rect.origin.x, y = rect.origin.y;
    if (UIInterfaceOrientationIsPortrait(orientation) || ignoreOrientation)  {
        imageSize = CGSizeMake(width, height);
        x = rect.origin.x;
        y = rect.origin.y;
    } else {
        imageSize = CGSizeMake(height, width);
        x = rect.origin.y;
        y = rect.origin.x;
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, self.sourceImageView.center.x, self.sourceImageView.center.y);
    CGContextConcatCTM(context, self.sourceImageView.transform);
    CGContextTranslateCTM(context, -self.sourceImageView.bounds.size.width * self.sourceImageView.layer.anchorPoint.x, -self.sourceImageView.bounds.size.height * self.sourceImageView.layer.anchorPoint.y);
    
    // Correct for the screen orientation
    if(!ignoreOrientation) {
        if(orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, (CGFloat)M_PI_2);
            CGContextTranslateCTM(context, 0, -self.sourceImageView.bounds.size.height);
            CGContextTranslateCTM(context, -x, y);
        } else if(orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, (CGFloat)-M_PI_2);
            CGContextTranslateCTM(context, -self.sourceImageView.bounds.size.width, 0);
            CGContextTranslateCTM(context, x, -y);
        } else if(orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, (CGFloat)M_PI);
            CGContextTranslateCTM(context, -self.sourceImageView.bounds.size.height, -self.sourceImageView.bounds.size.width);
            CGContextTranslateCTM(context, x, y);
        } else {
            CGContextTranslateCTM(context, -x, -y);
        }
    } else {
        CGContextTranslateCTM(context, -x, -y);
    }
    
    [self.sourceImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    CGContextRestoreGState(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Getter
- (UIImageView *)sourceImageView{
    if (!_sourceImageView) {
        _sourceImageView = [[UIImageView alloc] init];
        _sourceImageView.contentMode = UIViewContentModeScaleAspectFill;
        _sourceImageView.image = self.sourceImage;
        _sourceImageView.userInteractionEnabled = YES;
    }
    return _sourceImageView;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.layer.cornerRadius = 3;
        _confirmButton.layer.masksToBounds = YES;
        [_confirmButton setTitle:ZFLocalizedString(@"community_outfit_leave_confirm", nil) forState:UIControlStateNormal];
        [_confirmButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = ZFFontBoldSize(16);
        _confirmButton.backgroundColor = ZFC0x2D2D2D();
        [_confirmButton addTarget:self action:@selector(refreshResultData) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (ZFCameraImageCutView *)imageCutView {
    if (!_imageCutView) {
        _imageCutView = [[ZFCameraImageCutView  alloc] init];
        _imageCutView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    return _imageCutView;
}

- (UIView *)iPhoneXBottomView {
    if (!_iPhoneXBottomView) {
        _iPhoneXBottomView = [[UIView alloc] init];
        _iPhoneXBottomView.backgroundColor = [UIColor whiteColor];
    }
    return _iPhoneXBottomView;
}

@end
