//
//  YXScreenShotOperationViewController.m
//  uSmartOversea
//
//  Created by rrd on 2019/6/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXScreenShotOperationViewController.h"

#import "uSmartOversea-Swift.h"

@interface YXScreenShotOperationViewController ()

@property(nonatomic, assign, getter=isShowing, readwrite) BOOL showing;
@property(nonatomic, assign, getter=isAnimating, readwrite) BOOL animating;
@property(nonatomic, assign) BOOL hideByCancel; // 是否通过点击取消按钮或者遮罩来隐藏面板，默认为 NO
@end

@implementation YXScreenShotOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.cancelButton addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)cancelClick:(QMUIButton *)button {
    if (self.hideBlock) {
        self.hideBlock();
    }
}


- (void)showFromBottom {
    
    if (self.showing || self.animating) {
        return;
    }
    
    self.hideByCancel = YES;
    
    __weak __typeof(self)weakSelf = self;
    
    QMUIModalPresentationViewController *modalPresentationViewController = [[QMUIModalPresentationViewController alloc] init];
    modalPresentationViewController.delegate = self;
    modalPresentationViewController.modal = YES;
    modalPresentationViewController.maximumContentViewWidth = self.contentMaximumWidth;
    modalPresentationViewController.contentViewMargins = self.contentEdgeInsets;
    modalPresentationViewController.contentViewController = self;
    modalPresentationViewController.dimmingView.backgroundColor = UIColor.clearColor;
    
    //实现模糊效果
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    //毛玻璃视图
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];;
    effectView.frame = UIScreen.mainScreen.bounds;//CGRectMake(0, 0, ScreenW/2, ScreenH);
    [modalPresentationViewController.dimmingView addSubview:effectView];
    
    
    CGFloat uniSize = UIScreen.mainScreen.bounds.size.height / 812.0;
    //截图
    UIImageView *screenshotImgView = [[UIImageView alloc]initWithImage:self.screenshotImage];
    screenshotImgView.contentMode = UIViewContentModeScaleAspectFit;
    screenshotImgView.qmui_top = uniSize * 50;
    screenshotImgView.qmui_left = 0;
    screenshotImgView.qmui_width = modalPresentationViewController.view.qmui_width;
    
    
    //modalPresentationViewController 的 weak 对象
    __weak __typeof(screenshotImgView)weakScreenshotImgView = screenshotImgView;
    __weak __typeof(modalPresentationViewController)weakModalController = modalPresentationViewController;
    modalPresentationViewController.layoutBlock = ^(CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewDefaultFrame) {
        //contentViewDefaultFrame 白色 弹框的frame
        CGFloat y = CGRectGetHeight(containerBounds) - weakModalController.contentViewMargins.bottom - CGRectGetHeight(contentViewDefaultFrame) - weakModalController.view.qmui_safeAreaInsets.bottom ;
        //设置 rect.origin.y
        weakModalController.contentView.frame = CGRectSetY(contentViewDefaultFrame, y);
        
        weakScreenshotImgView.qmui_height = y - weakScreenshotImgView.qmui_top - uniSize * 34;
        [weakModalController.dimmingView addSubview:weakScreenshotImgView];
    };
    /**
     *  管理自定义的显示动画，需要管理的对象包括`contentView`和`dimmingView`，在`showingAnimation`被调用前，`contentView`已被添加到界面上。若使用了`layoutBlock`，则会先调用`layoutBlock`，再调用`showingAnimation`。在动画结束后，必须调用参数里的`completion` block。
     *  @arg  dimmingView         背景遮罩的View，请自行设置显示遮罩的动画
     *  @arg  containerBounds     浮层所在的父容器的大小，也即`self.view.bounds`
     *  @arg  keyboardHeight      键盘在当前界面里的高度，若无键盘，则为0
     *  @arg  contentViewFrame    动画执行完后`contentView`的最终frame，若使用了`layoutBlock`，则也即`layoutBlock`计算完后的frame
     *  @arg  completion          动画结束后给到modalController的回调，modalController会在这个回调里做一些状态设置，务必调用。
     */
    modalPresentationViewController.showingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewFrame, void(^completion)(BOOL finished)) {
        
        if ([weakSelf.delegate respondsToSelector:@selector(willPresentMoreOperationController:)]) {
            [weakSelf.delegate willPresentMoreOperationController:weakSelf];
        }
        
        //设置 dimmingView.alpha 的动画
        dimmingView.alpha = 0;
        [UIView animateWithDuration:0 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^(void) {
            dimmingView.alpha = 1;
            weakModalController.contentView.frame = contentViewFrame;
        } completion:^(BOOL finished) {
            weakSelf.showing = YES;
            weakSelf.animating = NO;
            if ([weakSelf.delegate respondsToSelector:@selector(didPresentMoreOperationController:)]) {
                [weakSelf.delegate didPresentMoreOperationController:weakSelf];
            }
            if (completion) {
                completion(finished);
            }
        }];
    };
    //hidingAnimation
    modalPresentationViewController.hidingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, void(^completion)(BOOL finished)) {
        
        [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
            dimmingView.alpha = 0;
            weakModalController.contentView.frame = CGRectSetY(weakModalController.contentView.frame, CGRectGetHeight(containerBounds));
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    };
    
    self.animating = YES;
    [modalPresentationViewController showWithAnimated:YES completion:NULL];
}

@end
