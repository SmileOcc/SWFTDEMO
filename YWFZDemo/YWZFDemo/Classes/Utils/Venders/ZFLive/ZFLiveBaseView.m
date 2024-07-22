//
//  ZFLiveBaseView.m
//  ZZZZZ
//
//  Created by YW on 2019/8/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFLiveBaseView.h"

@implementation ZFLiveBaseView

- (instancetype)initWithFrame:(CGRect)frame webView:(WKWebView *)webView {
    self = [super initWithFrame:frame];
    if (webView) {
        self.webView = webView;
        self.sourceFrame = webView.bounds;
    }
    if (self) {
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfAutoLayoutView {
    self.backgroundColor = [UIColor blackColor];
    self.webVideoConterView.frame = self.webView.frame;
    [self addSubview:self.webVideoConterView];
    [self addSubview:self.operateView];
    
    [self.webVideoConterView addSubview:self.webView];
    [self.webVideoConterView addSubview:self.closeButton];
    [self.webVideoConterView addSubview:self.progressView];
    
    [self.operateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.mas_equalTo(self.webVideoConterView);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.mas_equalTo(self.webVideoConterView);
        make.height.mas_equalTo(2);
    }];
    
    [self.webVideoConterView addGestureRecognizer:self.pan];
    [self.webVideoConterView addGestureRecognizer:self.tap];
    
}

//布局
- (void)layoutSubviews {
    
    [super layoutSubviews];
    if (CGSizeEqualToSize(_webView.frame.size, CGSizeZero)) {
        _webView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.webVideoConterView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.sourceFrame = _webView.bounds;
    }
}


- (void)setHideEyesNumsView:(BOOL)hideEyesNumsView {
    _hideEyesNumsView = hideEyesNumsView;
    self.operateView.hideEyesNumsView = hideEyesNumsView;
}

- (void)setHideTopOperateView:(BOOL)hideTopOperateView {
    _hideTopOperateView = hideTopOperateView;
    self.operateView.hideTopOperateView = hideTopOperateView;
}

- (void)setHideFullScreenView:(BOOL)hideFullScreenView {
    _hideFullScreenView = hideFullScreenView;
    self.operateView.hideFullScreenView = hideFullScreenView;
}

- (void)setHideTopBottomLayerView:(BOOL)hideTopBottomLayerView {
    _hideTopBottomLayerView = hideTopBottomLayerView;
    self.operateView.hideTopBottomLayerView = hideTopBottomLayerView;
}

- (void)setHideAllAlertTipView:(BOOL)hideAllAlertTipView {
    _hideAllAlertTipView = hideAllAlertTipView;
    self.operateView.hideAllAlertTipView = hideAllAlertTipView;
}

#pragma mark - ZFVideoLiveOperateDelegate

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapBlack:(BOOL)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfLiveBasePlayer:tapBlack:)]) {
        [self.delegate zfLiveBasePlayer:self tapBlack:YES];
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView play:(BOOL)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfLiveBasePlayer:player:)]) {
        [self.delegate zfLiveBasePlayer:self player:tap];
    }
    
    if (ZFIsEmptyString(self.liveVideoID)) {
        self.liveVideoID = ZFToString(self.sourceVideoAddress);
        [self basePlayVideoWithVideoID:self.liveVideoID];
        return;
    }
    switch (self.currentPlayerState) {
        case PlayerStateEnded:
        case PlayerStatePaused:
        case PlayerStateUnStarted:
            [self startVideo];
            break;
        case PlayerStatePlaying:
            [self pauseVideo];
            break;
        default:
            break;
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapGoods:(ZFGoodsModel *)tapGoods {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfLiveBasePlayer:tapGoods:)]) {
        [self.delegate zfLiveBasePlayer:self tapGoods:tapGoods];
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView similarGoods:(ZFGoodsModel *)tapGoods {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfLiveBasePlayer:similarGoods:)]) {
        [self.delegate zfLiveBasePlayer:self similarGoods:tapGoods];
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapScreenFull:(BOOL)isFullScreen {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfLiveBasePlayer:tapScreenFull:)]) {
        [self.delegate zfLiveBasePlayer:self tapScreenFull:!self.isFullScreen];
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapCart:(BOOL)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfLiveBasePlayer:tapCart:)]) {
        [self.delegate zfLiveBasePlayer:self tapCart:YES];
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapAlertCart:(ZFGoodsModel *)goodsModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfLiveBasePlayer:tapAlertCart:)]) {
        [self.delegate zfLiveBasePlayer:self tapAlertCart:goodsModel];
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapScreen:(BOOL)tap {
    
    if (self.currentPlayerState == PlayerStatePlaying) {
        [self pauseVideo];
    } else {
        [self startVideo];
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView sliderValue:(float)value {
    [self baseSeekToSecondsPlayVideo:value];
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView receiveCoupon:(ZFGoodsDetailCouponModel *)couponModel {
}


#pragma mark - Action

- (BOOL)basePlayVideoWithVideoID:(NSString *)liveVideoID {
    return YES;
}

- (void)baseSeekToSecondsPlayVideo:(float)seconds {
    
}

- (void)removePlyerViewFromSuperView {
    [self.webView removeFromSuperview];
}

- (void)actionClose:(UIButton *)sender {
    [self dissmissFromWindow];
}


- (void)startVideo {
}

- (void)pauseVideo {
}

- (void)stopVideo {
}

- (void)fullScreen:(BOOL)isFull {
    
    self.isFullScreen = isFull;
    [self.operateView fullScreen:isFull];
    self.userInteractionEnabled = YES;
    if (isFull) {
        
        self.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        BOOL isIphoneX = KScreenHeight >= 812.0f;
        CGFloat h = isIphoneX ? KScreenWidth + 80 : KScreenWidth;
        CGFloat w = KScreenHeight;
        CGFloat x = isIphoneX ? -40 : 0;
        
        self.webVideoConterView.frame = CGRectMake(0, x, h, w);
        self.webView.frame = CGRectMake(0, 0, h, w);
        
    } else {
        self.frame = self.sourceFrame;
        self.webView.frame = self.sourceFrame;
        self.webVideoConterView.frame = self.sourceFrame;
    }
}

#pragma mark - 播放窗口显示
- (void)showToWindow:(CGSize)size {
    
    if (self.webVideoConterView.superview) {
        [self.webVideoConterView removeFromSuperview];
    }
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        CGFloat w = CGRectGetWidth(self.frame) / 2.34;
        CGFloat h = CGRectGetHeight(self.frame) / 2.34;
        size = CGSizeMake(w, h);
    }
    
    self.operateView.hidden = YES;
    self.hidden = NO;
    self.webView.frame = CGRectMake(0, 0, size.width, size.height);
    self.webVideoConterView.frame = CGRectMake(KScreenWidth - size.width - 16, (KScreenHeight - size.height) / 2.0, size.width, size.height);
    self.closeButton.hidden = NO;
    [WINDOW addSubview:self.webVideoConterView];
    
    self.progressView.hidden = NO;
    self.tap.enabled = YES;
    [self startVideo];
}

- (void)dissmissFromWindow {
    
    self.progressView.hidden = YES;
    if (self.webVideoConterView.superview) {
        [self.webVideoConterView removeFromSuperview];
    }
    
    self.operateView.hidden = NO;
    self.closeButton.hidden = YES;
    if (self.sourceView) {
        self.webView.frame = CGRectMake(0, 0, CGRectGetWidth(self.sourceView.frame), CGRectGetHeight(self.sourceView.frame));
        self.webVideoConterView.frame = CGRectMake(0, 0, CGRectGetWidth(self.sourceView.frame), CGRectGetHeight(self.sourceView.frame));
        [self insertSubview:self.webVideoConterView atIndex:0];
        [self pauseVideo];
    }
}

#pragma mark - 推荐商品相关
- (void)setRecommendGoods:(NSArray *)recommendGoods {
    self.operateView.recommendGoods = recommendGoods;
}

- (void)showGoodsAlertView:(ZFCommunityVideoLiveGoodsModel *)goodsModel {
    [self.operateView showGoodsAlertView:goodsModel];
}

- (void)dissmissGoodsAlertView {
    [self.operateView dissmissGoodsAlertView];
}

#pragma mark - 推荐优惠券相关
- (void)showCouponAlertView:(ZFGoodsDetailCouponModel *)couponModel {
    [self.operateView showCouponAlertView:couponModel];
}

- (void)dissmissCouponAlertView {
    [self.operateView dissmissCouponAlertView];
}


#pragma mark - Property Method

- (void)setLookNums:(NSString *)lookNums {
    _lookNums = lookNums;
    [self.operateView lookNumbers:ZFToString(lookNums)];
}

- (UIView *)webVideoConterView {
    if (!_webVideoConterView) {
        _webVideoConterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _webVideoConterView.backgroundColor = [UIColor blackColor];
    }
    return _webVideoConterView;
}

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[NSClassFromString(@"WKWebViewConfiguration") alloc] init];
        NSString *jsStr = @"var meta=document.createElement('meta');meta.setAttribute('name','viewport');meta.setAttribute('content','width=device-width');document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsStr injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        configuration.preferences = [NSClassFromString(@"WKPreferences") new];
        configuration.userContentController = [NSClassFromString(@"WKUserContentController") new];
        [configuration.userContentController addUserScript:userScript];
        WKPreferences *prefer = [[WKPreferences alloc] init];
        prefer.javaScriptEnabled = YES;
        prefer.javaScriptCanOpenWindowsAutomatically = YES;
        configuration.preferences = prefer;
        configuration.allowsInlineMediaPlayback = YES;//控制视频播放默认不是全屏播放
        if (kiOSSystemVersion >= 10 ) {
            configuration.mediaTypesRequiringUserActionForPlayback = NO;
        }
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) configuration:configuration];
        _webView.backgroundColor = [UIColor clearColor];
        _webView.scrollView.scrollEnabled = NO;
        for (UIView *view in _webView.subviews) {
            view.backgroundColor = [UIColor clearColor];
        }
        _webView.hidden = YES;
        
        self.sourceFrame = _webView.bounds;
    }
    return _webView;
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

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0.0, 0.0, KScreenWidth, 1.0)];
        _progressView.progressTintColor = ZFC0xFE5269();
        _progressView.trackTintColor = ZFCClearColor();
        _progressView.progress = 0.0;
        _progressView.hidden = YES;
    }
    return _progressView;
}

- (ZFVideoLiveOperateView *)operateView {
    if (!_operateView) {
        _operateView = [[ZFVideoLiveOperateView alloc] initWithFrame:self.bounds];
        _operateView.backgroundColor = [UIColor clearColor];
        _operateView.videoType = ZFVideoTypeYT;
        _operateView.delegate = self;
    }
    return _operateView;
}

- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        pan.delaysTouchesBegan = YES;
        _pan = pan;
    }
    return _pan;
}

- (UITapGestureRecognizer *)tap {
    if (!_tap) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionWebTap:)];
        tap.enabled = NO;
        _tap = tap;
    }
    return _tap;
}

#pragma mark - 触摸移动事件

- (void)actionWebTap:(UITapGestureRecognizer *)tapGesture {
    if (self.viewController) {
        [self.viewController.navigationController popViewControllerAnimated:YES];
    }
    [self dissmissFromWindow];
}

-(void)locationChange:(UIPanGestureRecognizer*)panGesture{
    if (self.isAnimating) {
        return;
    }
    
    CGPoint panPoint = [panGesture locationInView:self.webVideoConterView.superview];
    CGFloat HEIGHT = CGRectGetHeight(self.webVideoConterView.frame);
    CGFloat WIDTH = CGRectGetWidth(self.webVideoConterView.frame);
    CGFloat moveWidth = CGRectGetWidth(self.webVideoConterView.superview.frame);
    CGFloat moveHeight = CGRectGetHeight(self.webVideoConterView.superview.frame);
    CGFloat leftSpace = 13;
    CGFloat topSpace = 24;
    
    CGFloat pointX = panPoint.x;
    CGFloat pointY = panPoint.y;
    
    //CGPoint panPoint = [p locationInView:[[UIApplication sharedApplication] keyWindow]];
    if(panGesture.state == UIGestureRecognizerStateBegan){
    } else if (panGesture.state == UIGestureRecognizerStateEnded){
    } if(panGesture.state == UIGestureRecognizerStateChanged) {
        
        self.webVideoConterView.center = CGPointMake(pointX, pointY);
        
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
            self.webVideoConterView.center = CGPointMake(pointX, pointY);
            self.isAnimating = NO;
        }];
    }
}
@end
