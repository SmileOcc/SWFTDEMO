//
//  ZFCommunityFloatingPostView.m
//  ZZZZZ
//
//  Created by YW on 2019/7/3.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityFloatingPostView.h"
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CAAnimation.h>

#import "TZImagePickerController.h"

#import "ZFCommunityOutfitPostVC.h"
#import "ZFCommunityShowPostViewController.h"
#import "PostPhotosManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "SystemConfigUtils.h"
#import "ZFStatistics.h"

#import "ZFShareButton.h"
#import "ZFShowOutfitButton.h"
#import <pop/POP.h>
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+LayoutMethods.h"
#import "UIImage+ZFExtended.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIView+YYAdd.h"

@interface ZFCommunityFloatingPostView()<CAAnimationDelegate,TZImagePickerControllerDelegate,
UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIView             *mainView;
@property (nonatomic, strong) ZFShowOutfitButton *showButton;
@property (nonatomic, strong) ZFShowOutfitButton *outfitsButton;
@property (nonatomic, strong) UIControl          *menuControl;
@property(nonatomic ,assign) BOOL                isCannotTouch;


@property (nonatomic, assign) CGRect moveFrame;

@property (nonatomic ,assign) CGRect startFrame;

@property (nonatomic, assign) CGRect rectToWindow;

@property (nonatomic ,assign) BOOL isShowBiging;

@property (nonatomic, assign) BOOL isAnimating;


@end

@implementation ZFCommunityFloatingPostView

- (void)dealloc {
    YWLog(@"dealloc:%@",NSStringFromClass(self.class));
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.startFrame = frame;
        self.menuControl.frame = self.bounds;
        self.menuControl.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2.0;
        self.menuControl.layer.masksToBounds = YES;
        self.menuControl.backgroundColor = ZFCOLOR_RANDOM;
        
        [self zfInitView];
        [self zfAutoLayoutView];
        
        //添加移动的手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        pan.delaysTouchesBegan = YES;
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)zfInitView {
    [self addSubview:self.mainView];
    [self addSubview:self.menuControl];
    [self.mainView addSubview:self.showButton];
    [self.mainView addSubview:self.outfitsButton];
}

- (void)zfAutoLayoutView {
    self.mainView.frame       = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    CGFloat topSpace          = 10;
    CGFloat offsetX           = (self.mainView.width - self.showButton.width) / 2.0;
    CGFloat offsetTopY        = (self.mainView.height - 120 - 120 - topSpace) / 2.0;
    //手动调的高度
    self.showButton.frame     = CGRectMake(offsetX, offsetTopY, self.showButton.width, 120);
    self.outfitsButton.frame  = CGRectMake(offsetX, offsetTopY + 120 + topSpace, self.outfitsButton.width, 120);
}

#pragma mark--- 开始和结束

- (void)showPostView {
    [self showCircleBiggerStartView:self.menuControl];
}
- (void)hideCircleSmallerAnimation:(BOOL)animate{
    
    self.isShowBiging = NO;
    if (!animate) {
        [self handleAnimateStateForceEnd:YES];
        
    } else {
        self.isAnimating = YES;
        CGRect rectToView = self.rectToWindow;
        UIBezierPath *maskStartBP =  [UIBezierPath bezierPathWithOvalInRect:rectToView];
        CGFloat radius = [UIScreen mainScreen].bounds.size.height - 100;
        UIBezierPath *maskFinalBP = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rectToView, -radius, -radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = maskFinalBP.CGPath;
        maskLayer.backgroundColor = (__bridge CGColorRef)([UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]);
        self.mainView.layer.mask = maskLayer;
        CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        maskLayerAnimation.fromValue = (__bridge id)(maskFinalBP.CGPath);
        maskLayerAnimation.toValue = (__bridge id)((maskStartBP.CGPath));
        maskLayerAnimation.duration = 0.5f;
        __weak typeof(self) weakSelf = self;
        maskLayerAnimation.delegate = weakSelf;
        [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
    }
    
}

- (void)showCircleBiggerStartView:(UIView *)startView {
    
    self.isShowBiging = YES;
    self.isAnimating = YES;
    CGRect rectToWindow = [ZFCommunityFloatingPostView sourceViewFrameToWindow:startView];
    self.rectToWindow = rectToWindow;
    
    if (startView.superview) {
        [startView removeFromSuperview];
    }
    startView.frame = rectToWindow;
    self.mainView.frame = [UIScreen mainScreen].bounds;
    self.mainView.hidden = NO;
    [self.mainView addSubview:startView];
    [[UIApplication sharedApplication].keyWindow addSubview:self.mainView];
    
    UIBezierPath *maskStartBP =  [UIBezierPath bezierPathWithOvalInRect:rectToWindow];
    CGFloat radius = [UIScreen mainScreen].bounds.size.height - 100;
    UIBezierPath *maskFinalBP = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rectToWindow, -radius, -radius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskFinalBP.CGPath;
    maskLayer.backgroundColor = (__bridge CGColorRef)([UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]);
    
    self.mainView.layer.mask = maskLayer;
    
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.fromValue = (__bridge id)(maskStartBP.CGPath);
    maskLayerAnimation.toValue = (__bridge id)((maskFinalBP.CGPath));
    maskLayerAnimation.duration = 0.5f;
    __weak typeof(self) weakSelf = self;
    maskLayerAnimation.delegate = weakSelf;
    [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
    
}


/**
 * 动画开始时
 */
- (void)animationDidStart:(CAAnimation *)theAnimation {
}

/**
 * 动画结束时
 */
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    [self handleAnimateStateForceEnd:NO];
}

/** 处理结束状态*/
- (void)handleAnimateStateForceEnd:(BOOL)forceEnd {
    
    // 强制结束
    if (forceEnd) {
        if (self.menuControl.superview) {
            [self.menuControl removeFromSuperview];
        }
        self.menuControl.frame = self.bounds;
        [self addSubview:self.menuControl];
        self.mainView.hidden = YES;
        self.mainView.layer.mask = nil;
        
        self.isAnimating = NO;
        self.isShowBiging = NO;
        self.isCannotTouch = self.isShowBiging;
        if (self.animateStateBlock) {
            self.animateStateBlock(self.isShowBiging);
        }
        return;
    }
    
    // 自然动画回收处理
    if (self.isShowBiging) {
        [self makeIntoAnimation];
        self.isCannotTouch = NO;
        
    } else {
        if (self.menuControl.superview) {
            [self.menuControl removeFromSuperview];
        }
        self.menuControl.frame = self.bounds;
        [self addSubview:self.menuControl];
        self.mainView.hidden = YES;
    }
    
    self.isAnimating = NO;
    self.mainView.layer.mask = nil;
    self.isCannotTouch = self.isShowBiging;
    if (self.animateStateBlock) {
        self.animateStateBlock(self.isShowBiging);
    }
}

#pragma mark ---进去和出去动画
- (void)makeIntoAnimation {
}

#pragma mark - event

- (void)actionMenu:(UIControl *)control {
    if (self.isAnimating) {
        return;
    }
    if (!self.isShowBiging) {
        [self showCircleBiggerStartView:control];
    } else {
        [self hideCircleSmallerAnimation:YES];
    }
    
    control.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        control.enabled = YES;
    });
}

- (void)communityShow {
    if (self.isAnimating) {
        return;
    }
    if (self.showsBlock) {
        self.showsBlock();
    }
    self.mainView.hidden = YES;
    [self hideCircleSmallerAnimation:NO];
    [self pushImagePickerController];
}

- (void)communityOutfits {
    if (self.isAnimating) {
        return;
    }
    if (self.outfitsBlock) {
        self.outfitsBlock();
    }
    
    self.mainView.hidden = YES;
    [self hideCircleSmallerAnimation:NO];

    ZFCommunityOutfitPostVC *outfitPostViewController = [[ZFCommunityOutfitPostVC alloc] init];
    UIViewController *currentViewController = [UIViewController currentTopViewController];
    ZFNavigationController *navigationController = [[ZFNavigationController alloc] initWithRootViewController:outfitPostViewController];
    [currentViewController.navigationController presentViewController:navigationController animated:YES completion:nil];
}



- (void)communityClose {
    self.isShowBiging = NO;
    [self hideCircleSmallerAnimation:YES];
}

- (void)tapAction {
    if (self.isAnimating) {
        return;
    }
    self.isShowBiging = NO;
    [self hideCircleSmallerAnimation:YES];
}


- (void)pushImagePickerController
{
    TZImagePickerController *imagePickerController = [[TZImagePickerController alloc] initWithMaxImagesCount:6 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    
    //四类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerController.isSelectOriginalPhoto = YES;
    // 1. 设置目前已经选中的图片数组
    imagePickerController.selectedAssets = [PostPhotosManager sharedManager].selectedAssets; // 目前已经选中的图片数组
    
    // 在内部显示拍照按钮
    imagePickerController.allowTakePicture = YES;
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerController.allowPickingVideo = NO;
    imagePickerController.allowPickingImage = YES;
    imagePickerController.allowPickingOriginalPhoto = YES;
    
    // 4. 照片排列按修改时间升序
    imagePickerController.sortAscendingByModificationDate = NO;
    imagePickerController.minImagesCount = 1;
    imagePickerController.maxImagesCount = 6;
    
    imagePickerController.naviBgColor = [UIColor whiteColor];
    imagePickerController.naviTitleColor = [UIColor blackColor];
    // 换肤时这里的导航按钮色需要自定义
    UIColor *barItemTextColor = [UIColor blackColor];
    if ([AccountManager sharedManager].needChangeAppSkin) {
        barItemTextColor = [AccountManager sharedManager].appNavFontColor;
    }
    imagePickerController.barItemTextColor = barItemTextColor;
    imagePickerController.statusBarStyle = [self.viewController preferredStatusBarStyle];
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self.viewController presentViewController:imagePickerController animated:YES completion:nil];
    
    // firebase
    [ZFStatistics eventType:ZF_CommunityTabbar_ImagePicker_type];
}

+ (CGRect)sourceViewFrameToWindow:(UIView *)sourceView {
    if (sourceView.superview) {
        return [sourceView.superview convertRect:sourceView.frame toView:WINDOW];
    }
    return CGRectZero;
}

+ (CGRect)sourceViewFrameToView:(UIView *)sourceView {
    if (sourceView.superview) {
        return [sourceView.superview convertRect:sourceView.frame toView:sourceView.superview];
    }
    return CGRectZero;
}

#pragma mark - getter/setter

- (UIView *)mainView {
    if (!_mainView) {
        _mainView                 = [[UIView alloc] init];
        _mainView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _mainView.hidden = YES;
        
        UITapGestureRecognizer *tap           = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(tapAction)];
        [_mainView addGestureRecognizer:tap];
    }
    return _mainView;
}

- (ZFShowOutfitButton *)showButton {
    if (!_showButton) {
        NSString *title       = ZFLocalizedString(@"community_show_new", nil);
        NSString *imageName   = @"community_z_shows";
        //@"community_show_bg"
        _showButton = [[ZFShowOutfitButton alloc] initWithBackImage:@"" Image:imageName Title:title TransitionType:ZFShowOutfitButtonTransitionTypeWave];
        _showButton.tag       = 0;
        [_showButton addTarget:self action:@selector(communityShow) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showButton;
}

- (ZFShowOutfitButton *)outfitsButton {
    if (!_outfitsButton) {
        NSString *title          = ZFLocalizedString(@"community_outfit_new", nil);
        NSString *imageName      = @"community_z_outfit";
        //community_outfit_bg
        _outfitsButton = [[ZFShowOutfitButton alloc] initWithBackImage:@"" Image:imageName Title:title TransitionType:ZFShowOutfitButtonTransitionTypeWave];
        _outfitsButton.tag       = 1;
        [_outfitsButton addTarget:self action:@selector(communityOutfits) forControlEvents:UIControlEventTouchUpInside];
    }
    return _outfitsButton;
}

- (UIControl *)menuControl {
    if (!_menuControl) {
        _menuControl = [[UIControl alloc] init];
        [_menuControl addTarget:self action:@selector(actionMenu:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuControl;
}


#pragma mark - 触摸移动事件
-(void)locationChange:(UIPanGestureRecognizer*)panGesture{
    if (self.isShowBiging || self.isAnimating || self.isCannotTouch) {
        return;
    }
    
    CGPoint panPoint = [panGesture locationInView:self.superview];
    CGFloat HEIGHT = CGRectGetHeight(self.frame);
    CGFloat WIDTH = CGRectGetWidth(self.frame);
    CGFloat moveWidth = CGRectGetWidth(self.superview.frame);
    CGFloat moveHeight = CGRectGetHeight(self.superview.frame);
    CGFloat leftSpace = 13;
    CGFloat topSpace = 16;
    
    CGFloat pointX = panPoint.x;
    CGFloat pointY = panPoint.y;
    
    //CGPoint panPoint = [p locationInView:[[UIApplication sharedApplication] keyWindow]];
    if(panGesture.state == UIGestureRecognizerStateBegan){
    } else if (panGesture.state == UIGestureRecognizerStateEnded){
    } if(panGesture.state == UIGestureRecognizerStateChanged) {
        
        self.center = CGPointMake(pointX, pointY);
        
    } else if(panGesture.state == UIGestureRecognizerStateEnded) {
        
        if(panPoint.x <= moveWidth / 2.0) {
            
            pointX = WIDTH/2.0 + leftSpace;
            if(panPoint.x >= (WIDTH/2.0+leftSpace) && panPoint.y <= (HEIGHT/2.0+topSpace)) {//左上上顶边
                pointY = HEIGHT / 2.0 + topSpace;
                
            } else if(panPoint.x >= (WIDTH/2.0+leftSpace) && panPoint.y >= (moveHeight-HEIGHT/2.0-topSpace) ) {//左下下边
                pointY = moveHeight-HEIGHT/2.0-topSpace;
                
            } else if (panPoint.x <= (WIDTH/2+leftSpace) && panPoint.y <= (HEIGHT/2.0+topSpace)) {//左上角超出
                pointY = HEIGHT/2.0 + topSpace;
                
            } else if (panPoint.x <= (WIDTH/2+leftSpace) && panPoint.y >= (moveHeight-HEIGHT/2.0-topSpace)) {//左下角超出
                pointY = moveHeight - HEIGHT/2.0 - topSpace;
                
            } else {
                //防止超出边界
                pointY = panPoint.y > (moveHeight-HEIGHT/2.0-topSpace) ? (moveHeight-HEIGHT/2.0-topSpace) : panPoint.y;
                pointY = pointY < (HEIGHT/2.0+topSpace) ? (HEIGHT/2.0+topSpace) : panPoint.y;
            }
            
        } else if(panPoint.x > moveWidth/2.0) {
            
            pointX = moveWidth - WIDTH/2.0 - leftSpace;
            if(panPoint.x <= (moveWidth-WIDTH/2.0-leftSpace) && panPoint.y <= (HEIGHT/2.0+topSpace) ) {//右上上顶边
                pointY = HEIGHT/2.0 + topSpace;
                
            } else if(panPoint.x <= (moveWidth-WIDTH/2.0-leftSpace) && panPoint.y >= (moveHeight-HEIGHT/2.0-topSpace)) {//右下下边
                pointY = moveHeight - HEIGHT/2.0 - topSpace;
                
            } else if (panPoint.x >= (moveWidth-WIDTH/2.0-leftSpace) && panPoint.y <= (HEIGHT/2.0+topSpace)) {//右上角超出
                pointY = HEIGHT/2.0 + topSpace;
                
            } else if (panPoint.x >= (moveWidth-WIDTH/2.0-leftSpace) && panPoint.y >= (moveHeight-HEIGHT/2.0-topSpace) ){//右下角超出
                pointY = moveHeight - HEIGHT/2.0 - topSpace;
                
            } else {
                
                //防止超出边界
                pointY = panPoint.y > (moveHeight-HEIGHT/2.0-topSpace) ? (moveHeight-HEIGHT/2.0-topSpace) : panPoint.y;
                pointY = pointY < (HEIGHT/2.0+topSpace) ? (HEIGHT/2.0+topSpace) : pointY;
            }
        }
        
        self.isAnimating = YES;
        [UIView animateWithDuration:0.15f animations:^{
            self.center = CGPointMake(pointX, pointY);
            self.startFrame = self.frame;
            self.isAnimating = NO;
        }];
    }
}

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker
       didFinishPickingPhotos:(NSArray *)photos
                 sourceAssets:(NSArray *)assets
        isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    [self isAR];
    [PostPhotosManager sharedManager].selectedPhotos = [NSMutableArray arrayWithArray:photos];
    [PostPhotosManager sharedManager].selectedAssets = [NSMutableArray arrayWithArray:assets];
    [PostPhotosManager sharedManager].isSelectOriginalPhoto = isSelectOriginalPhoto;
    
    ZFCommunityShowPostViewController *postVC = [[ZFCommunityShowPostViewController alloc] init];
//    postVC.selectedPhotos = [PostPhotosManager sharedManager].selectedPhotos;
//    postVC.selectedAssets = [PostPhotosManager sharedManager].selectedAssets;
    if ([picker isKindOfClass:[TZImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:postVC];
        [self.viewController presentViewController:nav animated:YES completion:nil];
    }
}

-(void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    [self isAR];
}

- (void) isAR {
    if ([SystemConfigUtils isCanRightToLeftShow]) {
        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    }
}
@end



@interface ZFCommunityFloatingPostMenuView ()

@property (nonatomic, strong) UIImageView        *menuImageView;
@property (nonatomic, strong) UIView             *shadowView;

@property (nonatomic, strong) UIControl          *menuControl;
@property (nonatomic, assign) BOOL               isAnimating;

@end

@implementation ZFCommunityFloatingPostMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.menuImageView.frame = CGRectMake(0, 0, 38, 38);
        self.menuControl.frame = self.bounds;
        self.menuImageView.center = self.menuControl.center;
        
        [self addSubview:self.shadowView];
        [self addSubview:self.menuImageView];
        [self addSubview:self.menuControl];
        
        //添加移动的手势 v5.7.0去掉
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
//        pan.delaysTouchesBegan = YES;
//        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)actionMenu:(UIControl *)control {
    if (self.isAnimating) {
        return;
    }
    
    if (self.tapBlock) {
        self.tapBlock();
    }
    
    control.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        control.enabled = YES;
    });
}

- (UIControl *)menuControl {
    if (!_menuControl) {
        _menuControl = [[UIControl alloc] init];
        [_menuControl addTarget:self action:@selector(actionMenu:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuControl;
}

- (UIImageView *)menuImageView {
    if (!_menuImageView) {
        _menuImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"community_zm_post"]];
        _menuImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _menuImageView;
}
- (UIView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[UIView alloc]initWithFrame:self.bounds];
        _shadowView.backgroundColor = ZFC0xFE5269();
        _shadowView.layer.shadowColor = ZFC0xFE5269_A(0.32).CGColor;
        _shadowView.layer.shadowOffset = CGSizeMake(1.5, 4);
        _shadowView.layer.shadowOpacity = 1;
        _shadowView.layer.shadowRadius = 4.0;
        _shadowView.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2.0;
        _shadowView.clipsToBounds = NO;
    }
    return _shadowView;
}

#pragma mark - 触摸移动事件
-(void)locationChange:(UIPanGestureRecognizer*)panGesture{
    if (self.isAnimating) {
        return;
    }
    
    CGPoint panPoint = [panGesture locationInView:self.superview];
    CGFloat HEIGHT = CGRectGetHeight(self.frame);
    CGFloat WIDTH = CGRectGetWidth(self.frame);
    CGFloat moveWidth = CGRectGetWidth(self.superview.frame);
    CGFloat moveHeight = CGRectGetHeight(self.superview.frame);
    CGFloat leftSpace = 13;
    CGFloat topSpace = 24;
    
    CGFloat pointX = panPoint.x;
    CGFloat pointY = panPoint.y;
    
    //CGPoint panPoint = [p locationInView:[[UIApplication sharedApplication] keyWindow]];
    if(panGesture.state == UIGestureRecognizerStateBegan){
    } else if (panGesture.state == UIGestureRecognizerStateEnded){
    } if(panGesture.state == UIGestureRecognizerStateChanged) {
        
        self.center = CGPointMake(pointX, pointY);
        
    } else if(panGesture.state == UIGestureRecognizerStateEnded) {
        
        if(panPoint.x <= moveWidth / 2.0) {
            
            pointX = WIDTH/2.0 + leftSpace;
            if(panPoint.x >= (WIDTH/2.0+leftSpace) && panPoint.y <= (HEIGHT/2.0+topSpace)) {//左上上顶边
                pointY = HEIGHT / 2.0 + topSpace;
                
            } else if(panPoint.x >= (WIDTH/2.0+leftSpace) && panPoint.y >= (moveHeight-HEIGHT/2.0-topSpace) ) {//左下下边
                pointY = moveHeight-HEIGHT/2.0-topSpace;
                
            } else if (panPoint.x <= (WIDTH/2+leftSpace) && panPoint.y <= (HEIGHT/2.0+topSpace)) {//左上角超出
                pointY = HEIGHT/2.0 + topSpace;
                
            } else if (panPoint.x <= (WIDTH/2+leftSpace) && panPoint.y >= (moveHeight-HEIGHT/2.0-topSpace)) {//左下角超出
                pointY = moveHeight - HEIGHT/2.0 - topSpace;
                
            } else {
                //防止超出边界
                pointY = panPoint.y > (moveHeight-HEIGHT/2.0-topSpace) ? (moveHeight-HEIGHT/2.0-topSpace) : panPoint.y;
                pointY = pointY < (HEIGHT/2.0+topSpace) ? (HEIGHT/2.0+topSpace) : panPoint.y;
            }
            
        } else if(panPoint.x > moveWidth/2.0) {
            
            pointX = moveWidth - WIDTH/2.0 - leftSpace;
            if(panPoint.x <= (moveWidth-WIDTH/2.0-leftSpace) && panPoint.y <= (HEIGHT/2.0+topSpace) ) {//右上上顶边
                pointY = HEIGHT/2.0 + topSpace;
                
            } else if(panPoint.x <= (moveWidth-WIDTH/2.0-leftSpace) && panPoint.y >= (moveHeight-HEIGHT/2.0-topSpace)) {//右下下边
                pointY = moveHeight - HEIGHT/2.0 - topSpace;
                
            } else if (panPoint.x >= (moveWidth-WIDTH/2.0-leftSpace) && panPoint.y <= (HEIGHT/2.0+topSpace)) {//右上角超出
                pointY = HEIGHT/2.0 + topSpace;
                
            } else if (panPoint.x >= (moveWidth-WIDTH/2.0-leftSpace) && panPoint.y >= (moveHeight-HEIGHT/2.0-topSpace) ){//右下角超出
                pointY = moveHeight - HEIGHT/2.0 - topSpace;
                
            } else {
                
                //防止超出边界
                pointY = panPoint.y > (moveHeight-HEIGHT/2.0-topSpace) ? (moveHeight-HEIGHT/2.0-topSpace) : panPoint.y;
                pointY = pointY < (HEIGHT/2.0+topSpace) ? (HEIGHT/2.0+topSpace) : pointY;
            }
        }
        
        self.isAnimating = YES;
        [UIView animateWithDuration:0.15f animations:^{
            self.center = CGPointMake(pointX, pointY);
            self.isAnimating = NO;
        }];
    }
}
@end
