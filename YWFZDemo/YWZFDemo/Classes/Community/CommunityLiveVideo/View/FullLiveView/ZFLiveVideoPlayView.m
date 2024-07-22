//
//  ZFLiveVideoPlayView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFLiveVideoPlayView.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
static NSInteger kZFLiveVideoPlayTag999978 = 999978;
@implementation ZFLiveVideoPlayView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.playView];
        [self addSubview:self.previewImageView];
        [self addSubview:self.closeButton];
        [self addSubview:self.videoPorgressLineView];

        [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        [self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.top.mas_equalTo(self);
        }];
        
        [self.videoPorgressLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_equalTo(self);
            make.height.mas_equalTo(1);
        }];
        
        [self addGestureRecognizer:self.pan];
        [self addGestureRecognizer:self.tap];
    }
    return self;
}

- (BOOL)isShowPreviewImage {
    return !self.previewImageView.isHidden;
}
#pragma mark - 显示封面图
- (void)showPreviewView {
    UIImage *image = [self snapshotVideoImage];
    self.previewImageView.image = image;
    self.previewImageView.hidden = NO;
}

- (void)hidePreviewView {
    self.previewImageView.hidden = YES;
}

- (UIImage *)snapshotVideoImage {
    //视频截图
    UIGraphicsBeginImageContextWithOptions(self.playView.bounds.size, YES,[UIScreen mainScreen].scale);
    [self.playView.layer renderInContext:UIGraphicsGetCurrentContext()];
    [self.playView drawViewHierarchyInRect:self.playView.bounds afterScreenUpdates:YES];
    UIImage *currentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return currentImage;
}

- (void)actionClose:(UIButton *)sender {
    [self dissmissFromWindow:NO];
}

- (void)showProgressLine:(BOOL)show {
    self.videoPorgressLineView.hidden = !show;

}
- (void)updateProgress:(CGFloat)progress {
    self.videoPorgressLineView.progress = progress;
}


- (UIView *)playView {
    if (!_playView) {
        _playView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _playView;
}
- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.hidden = YES;
        [_closeButton setImage:[UIImage imageNamed:@"video_small_close"] forState:UIControlStateNormal];
        [_closeButton convertUIWithARLanguage];
    }
    return _closeButton;
}

- (ZFLiveProgressLineView *)videoPorgressLineView {
    if (!_videoPorgressLineView) {
        _videoPorgressLineView = [[ZFLiveProgressLineView alloc] initWithFrame:CGRectZero];
        _videoPorgressLineView.backgroundColor = ZFC0xCCCCCC();
        _videoPorgressLineView.hidden = YES;
    }
    return _videoPorgressLineView;
}

- (UIImageView *)previewImageView {
    if (!_previewImageView) {
        _previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _previewImageView;
}

#pragma mark - 播放窗口显示
- (void)showToWindow:(CGSize)size {
    
    if (self.superview) {
        NSArray *array = [MASViewConstraint installedConstraintsForView:self];
        for (MASConstraint *constraint in array) {
            [constraint uninstall];
        }
        [self removeFromSuperview];
    }
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        CGFloat w = CGRectGetWidth(self.frame) / 2.34;
        CGFloat h = CGRectGetHeight(self.frame) / 2.34;
        size = CGSizeMake(w, h);
    }
    
    self.tap.enabled = YES;
    self.pan.enabled = YES;
    self.videoPorgressLineView.hidden = NO;
    self.hidden = NO;
    self.frame = CGRectMake(KScreenWidth - size.width - 16, (KScreenHeight - size.height) / 2.0, size.width, size.height);
    
    self.closeButton.hidden = NO;
    
    UIView *lastVideoPlay = [WINDOW viewWithTag:kZFLiveVideoPlayTag999978];
    if (lastVideoPlay) {
        [lastVideoPlay removeFromSuperview];
    }
    
    [WINDOW addSubview:self];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(WINDOW.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(WINDOW.mas_bottom).offset(-16);
        make.size.mas_equalTo(size);
    }];
    self.tag = kZFLiveVideoPlayTag999978;
    
    if (self.showWindowBlock) {
        self.showWindowBlock();
    }
}

- (void)dissmissFromWindow:(BOOL)isPlaying {
    
    self.closeButton.hidden = YES;
    self.pan.enabled = NO;
    self.videoPorgressLineView.hidden = YES;

    if (self.superview) {
        if (![self.superview isEqual:WINDOW]) {
            return;
        }
    }
    
    if (self.superview) {
        [self removeFromSuperview];
    }
    
    if (self.sourceView) {
        self.frame = CGRectMake(0, 0, CGRectGetWidth(self.sourceView.frame), CGRectGetHeight(self.sourceView.frame));
        
        [self.sourceView insertSubview:self atIndex:0];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.sourceView);
        }];
    }
    
    if (!isPlaying) {
        if (self.stopPlayBlock) {
            self.stopPlayBlock();
        }
    }
    
    if (self.dismissWindowBlock) {
        self.dismissWindowBlock();
    }
}

#pragma mark - 触摸移动事件

- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        pan.delaysTouchesBegan = YES;
        pan.enabled = NO;
        _pan = pan;
    }
    return _pan;
}

- (UITapGestureRecognizer *)tap {
    if (!_tap) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionWebTap:)];
        _tap = tap;
    }
    return _tap;
}

- (void)actionWebTap:(UITapGestureRecognizer *)tapGesture {
    
    if ([self.superview isEqual:WINDOW]) {
        [self dissmissFromWindow:YES];
        if (self.viewController) {
            
            if ([self.viewController popToSpecifyVCSuccess:NSStringFromClass(self.viewController.class)]) {
            } else if(self.stopPlayBlock) {
                self.stopPlayBlock();
            }
        }
    } else {
        if (self.tapBlock) {
            self.tapBlock();
        }
    }
}

-(void)locationChange:(UIPanGestureRecognizer*)panGesture{
    if (self.isAnimating) {
        return;
    }
    
    CGPoint panPoint = [panGesture locationInView:self.superview];
    UIView *superView = self.superview;
    if (![self.superview isEqual:WINDOW]) {
        return;
    }
    
    CGFloat HEIGHT = CGRectGetHeight(self.frame);
    CGFloat WIDTH = CGRectGetWidth(self.frame);
    CGFloat moveWidth = CGRectGetWidth(self.superview.frame);
    CGFloat moveHeight = CGRectGetHeight(self.superview.frame);
    CGFloat leftSpace = 13;
    CGFloat topSpace = 24;
    
    CGFloat pointX = panPoint.x;
    CGFloat pointY = panPoint.y;
    
    CGFloat trailSpace = 0;
    CGFloat bottomSpace = 0;
    
    //CGPoint panPoint = [p locationInView:[[UIApplication sharedApplication] keyWindow]];
    if(panGesture.state == UIGestureRecognizerStateBegan){
    } else if (panGesture.state == UIGestureRecognizerStateEnded){
    } if(panGesture.state == UIGestureRecognizerStateChanged) {
        
//        self.center = CGPointMake(pointX, pointY);
        
        trailSpace = (moveWidth - pointX) - WIDTH / 2.0;
        bottomSpace = (moveHeight - pointY) - HEIGHT / 2.0;
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(superView.mas_trailing).offset(-trailSpace);
            make.bottom.mas_equalTo(superView.mas_bottom).offset(-bottomSpace);
        }];
        
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
//        self.center = CGPointMake(pointX, pointY);
        trailSpace = (moveWidth - pointX) - WIDTH / 2.0;
        bottomSpace = (moveHeight - pointY) - HEIGHT / 2.0;
        [self setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.25f animations:^{
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(superView.mas_trailing).offset(-trailSpace);
                make.bottom.mas_equalTo(superView.mas_bottom).offset(-bottomSpace);
            }];
            self.isAnimating = NO;
            [self layoutIfNeeded];
        }];
    }
}


@end
