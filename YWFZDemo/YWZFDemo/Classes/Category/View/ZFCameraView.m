//
//  ZFCameraView.m
//  ZZZZZ
//
//  Created by YW on 14/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCameraView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "BigClickAreaButton.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIView+ZFViewCategorySet.h"
#import "YWCFunctionTool.h"

#define TopViewTag                       6666
#define BottomViewTag                    7777

@interface ZFCameraView ()<ZFInitViewProtocol,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView                *topBar;
@property (nonatomic, strong) UIView                *bottomBar;
@property (nonatomic, strong) BigClickAreaButton    *backButton;
@property (nonatomic, strong) UIButton              *flashButton; // 闪光灯
@property (nonatomic, strong) UIButton              *albumButton; // 相册
@property (nonatomic, strong) UIButton              *switchCameraButton; // 前后摄像头切换
@property (nonatomic, strong) UIButton              *photoButton; // 拍照
@property (nonatomic, strong) UILabel               *tipLabel;
@property (nonatomic, strong) UIView                *focusView;   // 聚焦动画view
@end

@implementation ZFCameraView
#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(focusAction:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)zfInitView {
    [self addSubview:self.topBar];
    [self.topBar addSubview:self.backButton];
    [self.topBar addSubview:self.flashButton];
    [self addSubview:self.bottomBar];
    [self.bottomBar addSubview:self.albumButton];
    [self.bottomBar addSubview:self.photoButton];
    [self.bottomBar addSubview:self.tipLabel];
    [self.bottomBar addSubview:self.switchCameraButton];
    [self addSubview:self.focusView];
}

- (void)zfAutoLayoutView {
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.top.mas_equalTo(-1);
        make.size.mas_equalTo(CGSizeMake(KScreenWidth, kiphoneXTopOffsetY + 44));
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(21);
        make.size.mas_equalTo(CGSizeMake(22, 22));
        make.bottom.mas_equalTo(self.topBar.mas_bottom).offset(-12);
    }];
    
    [self.flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backButton);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-21);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.bottom.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(KScreenWidth, 84+kiphoneXHomeBarHeight));
    }];
    
    [self.albumButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(57);
        make.centerY.mas_equalTo(self.photoButton).offset(8);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [self.photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(9);
        make.centerX.equalTo(self.bottomBar);
        make.size.mas_equalTo(CGSizeMake(55, 55));
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bottomBar);
        make.top.equalTo(self.photoButton.mas_bottom).offset(1);
    }];
    
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-57);
        make.centerY.mas_equalTo(self.photoButton).offset(8);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
}

- (void)updateTipLabel:(NSString *)tip {
    self.tipLabel.text = ZFToString(tip);
}

#pragma mark - Action
- (void)backButtonAction:(UIButton *)sender {
    if (self.backHandler) {
        self.backHandler();
    }
}

- (void)flashButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.flashButtonHandler) {
        self.flashButtonHandler(sender);
    }
}

- (void)albumButtonAction:(UIButton *)sender {
    if (self.albumButtonHandler) {
        self.albumButtonHandler();
    }
}

- (void)photoButtonAction_performSelector:(UIButton *)sender {
    //防止重复点击
    sender.enabled = NO;
    if (self.photoButtonHandler) {
        self.photoButtonHandler();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}

- (void)photoButtonAction {
    if (self.photoButtonHandler) {
        self.photoButtonHandler();
    }
}

- (void)toggleButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.flashButton.hidden = sender.selected ? YES : NO;
    if (self.toggleButtonHandler) {
        self.toggleButtonHandler();
    }
}

- (void)focusAction:(UITapGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self];
    [self runFocusAnimation:self.focusView point:point];
    if (self.focusHandler) {
        self.focusHandler(point);
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *view = touch.view;
    if (view.tag == TopViewTag || view.tag == BottomViewTag) {
        return NO;
    }
    return YES;
}

#pragma mark - Private method
- (void)runFocusAnimation:(UIView *)view point:(CGPoint)point {
    view.center = point;
    view.hidden = NO;
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    } completion:^(BOOL complete) {
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            view.hidden = YES;
            view.transform = CGAffineTransformIdentity;
        });
    }];
}

#pragma mark - Getter
- (UIView *)topBar {
    if (!_topBar) {
        _topBar = [[UIView alloc] init];
        _topBar.tag = TopViewTag;
        
        CAGradientLayer *menuGradientLayer = [[CAGradientLayer alloc] init];
        menuGradientLayer.colors = @[(__bridge id)ZFCOLOR(0, 0, 0, 1.0).CGColor,(__bridge id)ZFCOLOR(0, 0, 0, 0).CGColor];
        menuGradientLayer.frame = CGRectMake(0, 0, KScreenWidth, kiphoneXTopOffsetY + 44);
        menuGradientLayer.startPoint = CGPointMake(0, 0);
        menuGradientLayer.endPoint   = CGPointMake(0, 1);
        [_topBar.layer addSublayer:menuGradientLayer];
    }
    return _topBar;
}

- (BigClickAreaButton *)backButton {
    if (!_backButton) {
        _backButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        _backButton.adjustsImageWhenHighlighted = NO;
        [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setImage:[UIImage imageNamed:@"camera_back"] forState:UIControlStateNormal];
        _backButton.clipsToBounds = YES;
        [_backButton convertUIWithARLanguage];
        _backButton.clickAreaRadious = 64;
    }
    return _backButton;
}

- (UIButton *)flashButton {
    if (!_flashButton) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashButton.adjustsImageWhenHighlighted = NO;
        [_flashButton addTarget:self action:@selector(flashButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_flashButton setImage:[UIImage imageNamed:@"camera_flash"] forState:UIControlStateNormal];
    }
    return _flashButton;
}

- (UIView *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [[UIView alloc] init];
        _bottomBar.tag = BottomViewTag;
        _bottomBar.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    }
    return _bottomBar;
}

- (UIButton *)albumButton {
    if (!_albumButton) {
        _albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _albumButton.adjustsImageWhenHighlighted = NO;
        [_albumButton addTarget:self action:@selector(albumButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_albumButton setImage:[UIImage imageNamed:@"camera_album"] forState:UIControlStateNormal];
    }
    return _albumButton;
}

- (UIButton *)photoButton {
    if (!_photoButton) {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoButton.adjustsImageWhenHighlighted = NO;
        [_photoButton addTarget:self action:@selector(photoButtonAction_performSelector:) forControlEvents:UIControlEventTouchUpInside];
        [_photoButton setImage:[UIImage imageNamed:@"camera_photo"] forState:UIControlStateNormal];
    }
    return _photoButton;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = ZFFontSystemSize(12);
        _tipLabel.textColor = ZFCOLOR_WHITE;
        _tipLabel.text = ZFLocalizedString(@"3DTouch_icon_Search", nil);
    }
    return _tipLabel;
}

- (UIButton *)switchCameraButton {
    if (!_switchCameraButton) {
        _switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchCameraButton.adjustsImageWhenHighlighted = NO;
        [_switchCameraButton addTarget:self action:@selector(toggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_switchCameraButton setImage:[UIImage imageNamed:@"camera_toggle"] forState:UIControlStateNormal];
    }
    return _switchCameraButton;
}

- (UIView *)focusView {
    if (!_focusView) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.layer.borderColor = [UIColor blueColor].CGColor;
        _focusView.layer.borderWidth = 5.0f;
        _focusView.hidden = YES;
    }
    return _focusView;
}

@end
