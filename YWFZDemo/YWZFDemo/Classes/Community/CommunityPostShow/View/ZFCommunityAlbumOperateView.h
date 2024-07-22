//
//  ZFCommunityAlbumOperateView.h
//  ZZZZZ
//
//  Created by YW on 2019/10/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZFCommunityAlbumOperateView : UIView


@property (nonatomic, strong) UIView                     *contentView;
@property (nonatomic, strong) UIScrollView               *scrollView;

@property (nonatomic, strong) UIImageView                *pictureImageView;
@property (nonatomic, strong) UIImageView                *icloudImagView;

@property (nonatomic, strong) UIButton                   *pictureExpandButton;
@property (nonatomic, strong) UIView                     *bottomMaskView;

@property (nonatomic, strong) UIPanGestureRecognizer     *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer   *pinchGesture;

@property (nonatomic, strong) UITapGestureRecognizer     *bottomTapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer     *bottomPanGesture;




@property (nonatomic, copy) void (^changeFrameBlock)(CGRect changeFrame,CGFloat zoomScale);
@property (nonatomic, copy) void (^tapBottomBlock)(BOOL flag);

- (void)updateImage:(UIImage *)image frame:(CGRect)frame zoomScale:(CGFloat)zoomScale;

- (void)showScaleTipView;

- (void)showBottomTapView:(BOOL)isShow;

- (void)showLoading:(BOOL)isShow;

+ (CGFloat)operateHeight;

+ (CGRect)screenshotRect;
@end

