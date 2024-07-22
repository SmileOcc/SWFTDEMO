//
//  GenderSelectionView.m
//  YoshopPro
//
//  Created by mac on 2018/10/11.
//  Copyright © 2018年 yoshop. All rights reserved.
//

#import "CouponRulesView.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "YYTextLayout.h"
#import "ZFLocalizationString.h"
#import "ZFNewUserHeckReceivingStatusModel.h"

@interface CouponRulesView ()

/** 背景 */
@property (nonatomic, strong) UIView *bgView;
/** 选择视图 */
@property (nonatomic, strong) UIView *infoView;
/** web */
@property (nonatomic, strong) UIWebView *webView;
/** 分隔线 */
@property (nonatomic, strong) UIView *lineView;
/** 关闭 */
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation CouponRulesView


- (void)dealloc {
    self.webView.delegate = nil;
    [self.webView stopLoading];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [self addSubview:self.bgView];
        [self addSubview:self.infoView];
        [self.infoView addSubview:self.webView];
        [self.infoView addSubview:self.lineView];
        [self.infoView addSubview:self.cancelButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bgView.frame = self.bounds;
    
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).mas_offset(52);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-52);
        make.height.mas_equalTo(388*ScreenWidth_SCALE);
        make.center.mas_equalTo(self.bgView);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.infoView);
        make.height.mas_equalTo(44);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.cancelButton.mas_top);
        make.leading.trailing.mas_equalTo(self.infoView);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.infoView).mas_offset(15);
        make.leading.mas_equalTo(self.infoView).mas_offset(15);
        make.trailing.mas_equalTo(self.infoView).mas_offset(-15);
        make.bottom.mas_equalTo(self.lineView.mas_top).mas_offset(-15);
    }];
}

#pragma mark - 方法
-(void)show
{
    if (!self.superview) {
        [[[UIApplication sharedApplication].delegate window] addSubview:self];
        self.maskView.alpha = 0.0;
        self.infoView.alpha = 1.0;
        self.infoView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.infoView.transform = CGAffineTransformIdentity;
            self.maskView.alpha = 0.5;
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void)hiddenView
{
    [UIView animateWithDuration:.2 animations:^{
        self.maskView.alpha = 0.0;
        self.infoView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)closeClick {
    
    [self hiddenView];
}

- (void)setHeckReceivingStatusModel:(ZFNewUserHeckReceivingStatusModel *)heckReceivingStatusModel {
    _heckReceivingStatusModel = heckReceivingStatusModel;
    
    [self.webView loadHTMLString:heckReceivingStatusModel.rules baseURL:nil];
}

#pragma mark - 懒加载
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = ZFC0x000000_04();
            UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeClick)];
            [view addGestureRecognizer:tapGesturRecognizer];
            view;
        });
    }
    return _bgView;
};

- (UIView *)infoView {
    if (!_infoView) {
        _infoView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            view.layer.cornerRadius = 8;
            view;
        });
    }
    return _infoView;
};

-(UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = ({
            UIButton *button = [[UIButton alloc] init];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitle:ZFLocalizedString(@"OK", nil) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _cancelButton;
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.backgroundColor = [UIColor clearColor];
        _webView.opaque = NO;
        
        // 去掉webView的滚动条
        for (UIView *subView in [_webView subviews]) {
            if ([subView isKindOfClass:[UIScrollView class]]) {
                // 不显示竖直的滚动条
                [(UIScrollView *)subView setShowsVerticalScrollIndicator:NO];
            }
        }
    }
    return _webView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = ColorHex_Alpha(0xEEEEEEE, 1.0);
    }
    return _lineView;
}


@end
