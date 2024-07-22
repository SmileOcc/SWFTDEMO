//
//  ZFCommunityAlbumOperateView.m
//  ZZZZZ
//
//  Created by YW on 2019/10/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityAlbumOperateView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ExchangeManager.h"
#import "BigClickAreaButton.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "SystemConfigUtils.h"
#import "ZFLocalizationString.h"

#import "ZFTitleArrowTipView.h"

NSString *const kZFCommunityShowAlbumViewTip  = @"kZFCommunityShowAlbumViewTip";

@interface ZFCommunityAlbumOperateView()
<
ZFInitViewProtocol,
UIGestureRecognizerDelegate
>

@property (nonatomic, assign) CGPoint                   currentItemCenterPoint;
@property (nonatomic, assign) CGRect                    currentItemFrame;

@property (nonatomic, assign) BOOL                      isExpand;
@property (nonatomic, strong) ZFTitleArrowTipView       *scaleTipView;

@property (nonatomic, assign) CGFloat                   expandW;

@property (nonatomic, assign) CGFloat                   leftSpace;

@property (nonatomic, assign) CGFloat                   currentImageW;
@property (nonatomic, assign) CGFloat                   currentImageH;



@property (nonatomic, assign) BOOL isAnimating;







@end

@implementation ZFCommunityAlbumOperateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.expandW = 34.0;
        self.isExpand = YES;
//        self.leftSpace = (KScreenWidth - ([ZFCommunityAlbumOperateView operateHeight] * 3 / 4.0)) / 2.0;
        self.leftSpace = (KScreenWidth - [ZFCommunityAlbumOperateView operateHeight]) / 2.0;

        [self zfInitView];
        [self zfAutoLayoutView];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] init];
        [self.panGesture addTarget:self action:@selector(positionPanAction:)];
        self.panGesture.delegate = self;
        [self.contentView addGestureRecognizer:self.panGesture];
        
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] init];
        [self.pinchGesture addTarget:self action:@selector(pinchAction:)];
        self.pinchGesture.delegate = self;
        [self.contentView addGestureRecognizer:self.pinchGesture];
        
        self.bottomTapGesture = [[UITapGestureRecognizer alloc] init];
        [self.bottomTapGesture addTarget:self action:@selector(tapAction:)];
        [self.bottomMaskView addGestureRecognizer:self.bottomTapGesture];
        
        self.bottomPanGesture = [[UIPanGestureRecognizer alloc] init];
        [self.bottomPanGesture addTarget:self action:@selector(positionPanAction:)];
        [self.bottomMaskView addGestureRecognizer:self.bottomPanGesture];
        
    }
    return self;
}

+ (CGFloat)operateHeight {
    return KScreenWidth;
}

+ (CGRect)screenshotRect {
    return CGRectMake(0, 0, [ZFCommunityAlbumOperateView operateHeight], [ZFCommunityAlbumOperateView operateHeight]);
}

//+ (CGFloat)operateHeight {
//    return KScreenWidth * 360.0/375.0;
//}

//+ (CGRect)screenshotRect {
//    return CGRectMake(0, 0, [ZFCommunityAlbumOperateView operateHeight] * 3 / 4.0, [ZFCommunityAlbumOperateView operateHeight]);
//}



- (void)zfInitView {
    self.backgroundColor = ZFC0xF2F2F2();
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.pictureImageView];
    [self addSubview:self.icloudImagView];
    [self addSubview:self.pictureExpandButton];
    [self addSubview:self.bottomMaskView];
}

- (void)zfAutoLayoutView {
        
    [self.pictureExpandButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(10);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
        make.size.mas_equalTo(CGSizeMake(self.expandW, self.expandW));
    }];
    
    [self.icloudImagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.mas_equalTo(self);
        make.height.mas_equalTo([ZFCommunityAlbumOperateView operateHeight]);
    }];
}


- (void)showLoading:(BOOL)isShow {
    self.icloudImagView.hidden = !isShow;
}

- (void)updateImage:(UIImage *)image frame:(CGRect)frame zoomScale:(CGFloat)zoomScale{
    if (image) {
        self.pictureImageView.image = image;
        if (!CGRectEqualToRect(frame, CGRectZero)) {
            self.pictureImageView.frame = frame;
            self.currentImageW = CGRectGetWidth(frame);
            self.currentImageH = CGRectGetHeight(frame);
        } else {
            CGFloat imageW = image.size.width;
            CGFloat imageH = image.size.height;
            
            //初始图片处理
            if (imageW > 0 && imageH > 0) {
                if (imageW >= imageW) {
                    
                    imageH = [ZFCommunityAlbumOperateView operateHeight] * imageH / imageW;
                    imageW = [ZFCommunityAlbumOperateView operateHeight];
                } else {
                    imageW = [ZFCommunityAlbumOperateView operateHeight] * imageW / imageH;
                    imageH = [ZFCommunityAlbumOperateView operateHeight];
                }
            } else {
                imageW = [ZFCommunityAlbumOperateView operateHeight];
                imageH = [ZFCommunityAlbumOperateView operateHeight];
            }
            self.currentImageH = imageH;
            self.currentImageW = imageW;
            self.pictureImageView.frame = CGRectMake(0, 0, imageW, imageH);
            self.pictureImageView.center = self.contentView.center;
        }
        self.currentItemCenterPoint = self.pictureImageView.center;
        self.currentItemFrame = self.pictureImageView.frame;
        [self changeFrema:self.currentItemFrame];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGRectEqualToRect(self.pictureImageView.frame, CGRectZero)) {
        self.contentView.frame = CGRectMake(self.leftSpace, 0, CGRectGetWidth(self.frame) - 2 * self.leftSpace, CGRectGetHeight(self.frame));
        
        self.pictureImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame) - 2 * self.leftSpace, CGRectGetHeight(self.frame));
        if (self.pictureImageView.image) {
            CGFloat imageW = self.pictureImageView.image.size.width;
            CGFloat imageH = self.pictureImageView.image.size.height;
            if (imageW > 0 && imageH > 0) {
                
                CGFloat realH = CGRectGetWidth(self.contentView.frame) * imageH / imageW;
                
                self.pictureImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame) - 2 * self.leftSpace, realH);
            }
        }
        self.currentItemCenterPoint = self.pictureImageView.center;
        self.currentItemFrame = self.pictureImageView.frame;
        [self changeFrema:self.currentItemFrame];
        
    };
}

- (void)showBottomTapView:(BOOL)isShow {
    self.bottomMaskView.hidden = !isShow;
}
- (void)tapAction:(UITapGestureRecognizer *)tapGesture {
    if (self.tapBottomBlock) {
        self.tapBottomBlock(YES);
    }
    self.bottomMaskView.hidden = YES;
}
- (void)actionExpand:(UIButton *)sender {
    if (!self.pictureImageView.image) {
        return;
    }
    
    if (self.isAnimating) {
        return;
    }
    
    CGPoint tempCenterPoint = self.pictureImageView.center;
    CGRect  tempRect = self.pictureImageView.frame;
    CGFloat kWidth = CGRectGetWidth(self.pictureImageView.frame);
    CGFloat kHeight = CGRectGetHeight(self.pictureImageView.frame);
    if (kWidth <=0 || kHeight <=0) {
        return;
    }
    
    CGFloat realW = kWidth;
    CGFloat realH = kHeight;
    
    self.isExpand = !self.isExpand;
    if (self.isExpand) {
        if (kWidth >= kHeight) {
            realW  = kWidth * 2;
            if (realW >= self.currentImageW * 2.0) {
                realW = self.currentImageW * 2.0;
            }
            realH = realW * kHeight / kWidth;
            
        } else {
            realH = kHeight * 2.0;
            if (realH >= self.currentImageH * 2.0) {
                realH = self.currentImageH * 2.0;
            }
            realW = realH * kWidth / kHeight;
        }
        
        tempRect.size.width = realW;
        tempRect.size.height = realH;
        
        self.isAnimating = YES;
        [UIView animateWithDuration:0.25 animations:^{
            self.pictureImageView.frame = tempRect;
            self.pictureImageView.center = tempCenterPoint;
            
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.isAnimating = NO;
            self.currentItemCenterPoint = self.pictureImageView.center;
            self.currentItemFrame = self.pictureImageView.frame;
            [self changeFrema:self.currentItemFrame];
        }];

    } else {
        
        if (kWidth >= kHeight) {
            realW = [ZFCommunityAlbumOperateView operateHeight];
            realH = realW * kHeight / kWidth;
        } else {
            realH = [ZFCommunityAlbumOperateView operateHeight];
            realW = realH * kWidth / kHeight;
        }
        tempRect.size.width = realW;
        tempRect.size.height = realH;
        
        self.isAnimating = YES;
        [UIView animateWithDuration:0.25 animations:^{
            self.pictureImageView.frame = tempRect;
            self.pictureImageView.center = self.contentView.center;
            
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.isAnimating = NO;
            self.currentItemCenterPoint = self.pictureImageView.center;
            self.currentItemFrame = self.pictureImageView.frame;
            [self changeFrema:self.currentItemFrame];
        }];
    }
    
    
    
    if (self.isExpand) {
        [sender setImage:[UIImage imageNamed:@"picture_scale"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"picture_expand"] forState:UIControlStateNormal];
    }
}

- (void)changeFrema:(CGRect)frame {
    if (self.changeFrameBlock) {
        self.changeFrameBlock(frame,1.0);
    }
}

- (void)positionPanAction:(UIPanGestureRecognizer *)panGesture {
    if (panGesture == self.bottomPanGesture) {
        if (self.tapBottomBlock) {
            self.tapBottomBlock(YES);
        }
        return;
    }
    
    if (self.isAnimating) {
        return;
    }
    
    CGPoint translatedPoint = [panGesture translationInView:self];
    YWLog(@"--------pan: x:%f   y:%f",translatedPoint.x,translatedPoint.y);
    if (self.pictureImageView) {
        
        CGPoint currentCentPoint = self.currentItemCenterPoint;
        switch (panGesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                currentCentPoint = CGPointMake(self.currentItemCenterPoint.x + translatedPoint.x, self.currentItemCenterPoint.y + translatedPoint.y);
                self.pictureImageView.center = currentCentPoint;
                [self setNeedsDisplay];
                break;
            }
            case UIGestureRecognizerStateEnded: {
                
                CGRect picRect = self.pictureImageView.frame;

                CGFloat tempPicW = CGRectGetWidth(picRect);
                CGFloat tempPicH = CGRectGetHeight(picRect);
                CGPoint centerPoint = self.contentView.center;
                CGPoint tempPoint = self.pictureImageView.center;
                CGFloat moveY = 0;
                CGFloat moveX = 0;
                
                if (tempPicH >= [ZFCommunityAlbumOperateView operateHeight] && CGRectGetWidth(picRect) >= [ZFCommunityAlbumOperateView operateHeight]) {
                    
                    // 垂直方向
                    if(CGRectGetMinY(picRect) >= 0) {
                        moveY = CGRectGetMinY(picRect);
                        tempPoint = CGPointMake(tempPoint.x, tempPoint.y - moveY);
                        
                    } else if(CGRectGetMaxY(picRect) <= [ZFCommunityAlbumOperateView operateHeight]) {
                        moveY = [ZFCommunityAlbumOperateView operateHeight] - CGRectGetMaxY(picRect);
                        tempPoint = CGPointMake(tempPoint.x, tempPoint.y + moveY);
                    }
                    
                    // 横屏方向
                    if (CGRectGetMinX(picRect) >= 0) {
                        moveX = CGRectGetMinX(picRect);
                        tempPoint = CGPointMake(tempPoint.x - moveX, tempPoint.y);
                    } else if(CGRectGetMaxX(picRect) <= [ZFCommunityAlbumOperateView operateHeight]) {
                        CGFloat moveX = [ZFCommunityAlbumOperateView operateHeight] - CGRectGetMaxX(picRect);
                        tempPoint = CGPointMake(tempPoint.x + moveX, tempPoint.y);

                    }
                    
                } else if (tempPicH >= [ZFCommunityAlbumOperateView operateHeight]) {
                    
                    if(CGRectGetMinY(picRect) >= 0) {
                        CGFloat moveY = CGRectGetMinY(picRect);
                        tempPoint = CGPointMake(tempPoint.x, tempPoint.y - moveY);
                        
                    } else if (CGRectGetMaxY(picRect) <= [ZFCommunityAlbumOperateView operateHeight]) {
                        CGFloat moveY = [ZFCommunityAlbumOperateView operateHeight] - CGRectGetMaxY(picRect);
                        
                        tempPoint = CGPointMake(tempPoint.x, tempPoint.y + moveY);
                    }
                    if (tempPicW < [ZFCommunityAlbumOperateView operateHeight]) {
                        tempPoint = CGPointMake(centerPoint.x, tempPoint.y);
                    }
                    
                } else if(tempPicW >= [ZFCommunityAlbumOperateView operateHeight]) {
                    if (CGRectGetMinX(picRect) >= 0) {
                        CGFloat moveX = CGRectGetMinX(picRect);
                        tempPoint = CGPointMake(tempPoint.x - moveX, tempPoint.y);
                        
                    } else if(CGRectGetMaxX(picRect) <= [ZFCommunityAlbumOperateView operateHeight]) {
                        CGFloat moveX = [ZFCommunityAlbumOperateView operateHeight] - CGRectGetMaxX(picRect);
                        tempPoint = CGPointMake(tempPoint.x + moveX, tempPoint.y);
                    }
                    if (tempPicH < [ZFCommunityAlbumOperateView operateHeight]) {
                        tempPoint = CGPointMake(tempPoint.x, centerPoint.y);
                    }
                }
                
                
                self.isAnimating = YES;
                [UIView animateWithDuration:0.25 animations:^{
                    
                    self.pictureImageView.frame = picRect;
                    self.pictureImageView.center = tempPoint;
                    
                    [self layoutIfNeeded];
                } completion:^(BOOL finished) {
                    self.isAnimating = NO;
                    self.currentItemCenterPoint = self.pictureImageView.center;
                    self.currentItemFrame = self.pictureImageView.frame;
                    [self changeFrema:self.currentItemFrame];
                }];
                break;
            }
            default:
                break;
        }
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

#pragma mark - Property Method

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(self.leftSpace, 0, CGRectGetWidth(self.frame) - self.leftSpace * 2, CGRectGetHeight(self.frame))];
        _contentView.layer.masksToBounds = YES;
        _contentView.backgroundColor = ZFC0xF2F2F2();
    }
    return _contentView;
}
- (UIImageView *)pictureImageView {
    if (!_pictureImageView) {
        _pictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame))];
        _pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
        _pictureImageView.layer.masksToBounds = YES;
        
        self.currentItemCenterPoint = self.pictureImageView.center;
        self.currentItemFrame = self.pictureImageView.frame;
    }
    return _pictureImageView;
}

- (UIImageView *)icloudImagView {
    if (!_icloudImagView) {
        _icloudImagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"album_cloud"]];
        _icloudImagView.hidden = YES;
    }
    return _icloudImagView;
}

- (UIButton *)pictureExpandButton {
    if (!_pictureExpandButton) {
        _pictureExpandButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pictureExpandButton setImage:[UIImage imageNamed:@"picture_scale"] forState:UIControlStateNormal];
        [_pictureExpandButton addTarget:self action:@selector(actionExpand:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pictureExpandButton;
}

- (ZFTitleArrowTipView *)scaleTipView {
    if (!_scaleTipView) {
        _scaleTipView = [[ZFTitleArrowTipView alloc] init];
    }
    return _scaleTipView;
}

- (UIView *)bottomMaskView {
    if (!_bottomMaskView) {
        _bottomMaskView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomMaskView.backgroundColor = ZFC0x000000_04();
        _bottomMaskView.hidden = YES;
    }
    return _bottomMaskView;
}


#pragma mark - ShowTip

- (void)showScaleTipView {
    
    if (self.pictureExpandButton.isHidden) {
        return;
    }
    BOOL isShowAddGoodsTip = [GetUserDefault(kZFCommunityShowAlbumViewTip) boolValue];
    if (!_scaleTipView && !isShowAddGoodsTip) {
        SaveUserDefault(kZFCommunityShowAlbumViewTip, @(YES));
        
        [self addSubview:self.scaleTipView];

        [self.scaleTipView updateTipArrowOffset:self.expandW / 2.0 + (10-8) direct:[SystemConfigUtils isRightToLeftShow] ? ZFTitleArrowTipDirectDownRight : ZFTitleArrowTipDirectDownLeft cotent:ZFLocalizedString(@"Community_editPhotoTips", nil)];
        
        [self.scaleTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(8);
            make.bottom.mas_equalTo(self.pictureExpandButton.mas_top).offset(-5);
            make.width.mas_lessThanOrEqualTo(KScreenWidth - 86);
        }];
        
        [self.scaleTipView hideViewWithTime:4.5 complectBlock:nil];
    }
}

- (void)pinchAction:(UIPinchGestureRecognizer *)pinch {

    if (self.isAnimating) {
        return;
    }
    YWLog(@"--------pinch");
    if (self.pictureImageView) {
        
        switch (pinch.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {

                if (pinch.scale >= 0.5 && pinch.scale <= 3) {
                    
                    CGPoint currentCenter = self.pictureImageView.center;
                    CGFloat imageH = self.currentItemFrame.size.height * pinch.scale;
                    CGFloat imageW  = self.currentItemFrame.size.width * pinch.scale;
                    
                    BOOL isOverMax = NO;
                    if (imageH > imageW) {
                        if (imageH >= self.currentImageH * 2) {
                            isOverMax = YES;
                            YWLog(@"----- isOverMax");
                        }
                    }
                    if (imageW > imageH) {
                        if (imageW >= self.currentImageW * 2) {
                            isOverMax = YES;
                            YWLog(@"----- isOverMax");
                        }
                    }
                    
                    if (!isOverMax) {
                        YWLog(@"--------pinch: height:%f   width:%f",imageH,imageW);
                        self.pictureImageView.bounds    = CGRectMake(0.0, 0.0, imageW, imageH);
                        self.pictureImageView.center = currentCenter;
                        YWLog(@"------- %@ %@",NSStringFromCGPoint(currentCenter),self.pictureImageView);
                        [self setNeedsDisplay];
                    }
                }
                
                break;
            }
            case UIGestureRecognizerStateEnded: {
                
                CGRect picRect = self.pictureImageView.frame;
                CGFloat tempPicW = CGRectGetWidth(picRect);
                CGFloat tempPicH = CGRectGetHeight(picRect);
                CGPoint centerPoint = self.contentView.center;
                CGPoint tempPoint = self.pictureImageView.center;
                
                

                if (tempPicW >= [ZFCommunityAlbumOperateView operateHeight] && tempPicH >= [ZFCommunityAlbumOperateView operateHeight]) {
                    
                    YWLog(@"------- 都大于");

                    if (CGRectGetMinY(picRect) <= 0 && CGRectGetMaxY(picRect) >= [ZFCommunityAlbumOperateView operateHeight]) {
                        
                    } else if (CGRectGetMinY(picRect) >= 0) {
                        CGFloat moveY = CGRectGetMinY(picRect);
                        tempPoint = CGPointMake(tempPoint.x, tempPoint.y - moveY);
                        
                    } else if(CGRectGetMaxY(picRect) <= [ZFCommunityAlbumOperateView operateHeight]) {
                        CGFloat moveY = [ZFCommunityAlbumOperateView operateHeight] - CGRectGetMaxY(picRect);
                        tempPoint = CGPointMake(tempPoint.x, tempPoint.y + moveY);
                    }
                    
                    
                    if (CGRectGetMinX(picRect) <= 0 && CGRectGetMaxX(picRect) >= [ZFCommunityAlbumOperateView operateHeight]) {
                        
                    } else if(CGRectGetMinX(picRect) >= 0) {
                        CGFloat moveX = CGRectGetMinX(picRect);
                        tempPoint = CGPointMake(tempPoint.x - moveX, tempPoint.y);
                        
                    } else if (CGRectGetMaxX(picRect) <= [ZFCommunityAlbumOperateView operateHeight]) {
                        CGFloat moveX = [ZFCommunityAlbumOperateView operateHeight] - CGRectGetMaxX(picRect);
                        
                        tempPoint = CGPointMake(tempPoint.x + moveX, tempPoint.y);
                    }
                    
                    self.isAnimating = YES;
                    [UIView animateWithDuration:0.25 animations:^{
                        
                        self.pictureImageView.frame = picRect;
                        self.pictureImageView.center = tempPoint;
                        
                        [self layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        self.isAnimating = NO;
                        self.currentItemFrame = self.pictureImageView.frame;
                        self.currentItemCenterPoint = self.pictureImageView.center;
                        [self changeFrema:self.currentItemFrame];
                    }];
                    
                } else if (tempPicH <= [ZFCommunityAlbumOperateView operateHeight] || tempPicW <= [ZFCommunityAlbumOperateView operateHeight]) {
                    YWLog(@"------- 一个大于");

                    if (tempPicH <= [ZFCommunityAlbumOperateView operateHeight] && tempPicW <= [ZFCommunityAlbumOperateView operateHeight]) {
                        YWLog(@"------- 0");

                        if (tempPicH > tempPicW) {
                            picRect.size.height = [ZFCommunityAlbumOperateView operateHeight];
                            picRect.size.width = picRect.size.height * tempPicW / tempPicH;
                            
                        } else if(tempPicW >= tempPicH) {
                            picRect.size.width = [ZFCommunityAlbumOperateView operateHeight];
                            picRect.size.height = picRect.size.width * tempPicH / tempPicW;
                        }
                        tempPoint = centerPoint;
                        
                    } else if (tempPicH >= [ZFCommunityAlbumOperateView operateHeight]) {
                        YWLog(@"------- 1");

                        if (CGRectGetMinY(picRect) <= 0 && CGRectGetMaxY(picRect) >= [ZFCommunityAlbumOperateView operateHeight]) {
                            
                        } else if (CGRectGetMinY(picRect) >= 0) {
                            CGFloat moveY = CGRectGetMinY(picRect);
                            tempPoint = CGPointMake(tempPoint.x, tempPoint.y - moveY);
                            
                        } else if(CGRectGetMaxY(picRect) <= [ZFCommunityAlbumOperateView operateHeight]) {
                            CGFloat moveY = [ZFCommunityAlbumOperateView operateHeight] - CGRectGetMaxY(picRect);
                            tempPoint = CGPointMake(tempPoint.x, tempPoint.y + moveY);
                        }
                        
                        tempPoint = CGPointMake(centerPoint.x, tempPoint.y);
                    } else if (CGRectGetWidth(picRect) >= [ZFCommunityAlbumOperateView operateHeight]) {
                        
                        YWLog(@"------- 2");

                        if (CGRectGetMinX(picRect) >= 0 && CGRectGetMaxX(picRect) <= [ZFCommunityAlbumOperateView operateHeight]) {
                            
                        } else if(CGRectGetMinX(picRect) >= 0) {
                            CGFloat moveX = CGRectGetMinX(picRect);
                            tempPoint = CGPointMake(tempPoint.x - moveX, tempPoint.y);
                            
                        } else if (CGRectGetMaxX(picRect) <= [ZFCommunityAlbumOperateView operateHeight]) {
                            CGFloat moveX = [ZFCommunityAlbumOperateView operateHeight] - CGRectGetMaxX(picRect);
                            
                            tempPoint = CGPointMake(tempPoint.x + moveX, tempPoint.y);
                        }
                        tempPoint = CGPointMake(tempPoint.x, centerPoint.y);
                        
                        YWLog(@"------- ");
                    }
                    
                    self.isAnimating = YES;
                    [UIView animateWithDuration:0.25 animations:^{
                        
                        self.pictureImageView.frame = picRect;
                        self.pictureImageView.center = tempPoint;
                        
                        [self layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        self.isAnimating = NO;
                        self.currentItemFrame = self.pictureImageView.frame;
                        self.currentItemCenterPoint = self.pictureImageView.center;
                        [self changeFrema:self.currentItemFrame];
                    }];
                    
                } else if(CGRectGetWidth(self.pictureImageView.frame) > CGRectGetWidth(self.contentView.frame) * 2) {
                    picRect.size = CGSizeMake(self.contentView.frame.size.width * 2, self.contentView.frame.size.height * 2);
                    
                    CGFloat imageW = self.pictureImageView.image.size.width;
                    CGFloat imageH = self.pictureImageView.image.size.height;
                    if (imageW > 0 && imageH > 0) {
                        CGFloat realH = CGRectGetWidth(self.contentView.frame) * 2 * imageH / imageW;
                        picRect = CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame) * 2, realH);
                    }
                    tempPoint = CGPointMake(self.contentView.center.x -self.leftSpace, self.contentView.center.y);
                    
                    self.isAnimating = YES;
                    [UIView animateWithDuration:0.25 animations:^{
                        
                        self.pictureImageView.frame = picRect;
                        self.pictureImageView.center = tempPoint;
                        
                        [self layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        self.isAnimating = NO;
                        self.currentItemFrame = self.pictureImageView.frame;
                        self.currentItemCenterPoint = self.pictureImageView.center;
                        [self changeFrema:self.currentItemFrame];
                    }];
                    
                } else {
                    self.currentItemFrame = self.pictureImageView.frame;
                    self.currentItemCenterPoint = self.pictureImageView.center;
                    [self changeFrema:self.currentItemFrame];
                }

                
                break;
            }
            default:
                break;
        }
    }
}

- (void)changeFrameAnimte:(CGRect)rect {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.pictureImageView.frame = rect;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

@end
