//
//  ZFZegoBasePlayerView.m
//  ZZZZZ
//
//  Created by YW on 2019/8/6.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFZegoBasePlayerView.h"

@implementation ZFZegoBasePlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfAutoLayoutView {
    self.backgroundColor = [UIColor blackColor];
    [self addSubview:self.videoConterView];
    [self addSubview:self.operateView];
    
//    [self.webVideoConterView addSubview:self.webView];
    [self.videoConterView addSubview:self.previewImageView];
    [self.videoConterView addSubview:self.closeButton];
    [self.videoConterView addSubview:self.progressView];
    
    [self.operateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.videoConterView);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.mas_equalTo(self.videoConterView);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.mas_equalTo(self.videoConterView);
        make.height.mas_equalTo(2);
    }];
    
    [self.videoConterView addGestureRecognizer:self.pan];
    [self.videoConterView addGestureRecognizer:self.tap];
    
}

//布局
- (void)layoutSubviews {
    
    [super layoutSubviews];
    if (CGSizeEqualToSize(self.sourceFrame.size, CGSizeZero)) {
        self.videoConterView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.sourceFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
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

#pragma mark - ZFVideoLiveOperateDelegate

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapBlack:(BOOL)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoBasePlayer:tapBlack:)]) {
        [self.delegate zfZegoBasePlayer:self tapBlack:YES];
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView play:(BOOL)tap {
    self.liveVideoID = ZFToString(self.sourceVideoAddress);
    [self basePlayVideoWithVideoID:self.liveVideoID];
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapGoods:(ZFGoodsModel *)tapGoods {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoBasePlayer:tapGoods:)]) {
        [self.delegate zfZegoBasePlayer:self tapGoods:tapGoods];
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView similarGoods:(ZFGoodsModel *)tapGoods {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoBasePlayer:similarGoods:)]) {
        [self.delegate zfZegoBasePlayer:self similarGoods:tapGoods];
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapScreenFull:(BOOL)isFullScreen {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoBasePlayer:tapScreenFull:)]) {
        [self.delegate zfZegoBasePlayer:self tapScreenFull:!self.isFullScreen];
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapCart:(BOOL)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoBasePlayer:tapCart:)]) {
        [self.delegate zfZegoBasePlayer:self tapCart:YES];
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapAlertCart:(ZFGoodsModel *)goodsModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoBasePlayer:tapAlertCart:)]) {
        [self.delegate zfZegoBasePlayer:self tapAlertCart:goodsModel];
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapScreen:(BOOL)tap {
    

}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView sliderValue:(float)value {
    [self baseSeekToSecondsPlayVideo:value];
}


- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView receiveCoupon:(ZFGoodsDetailCouponModel *)couponModel {
}


- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView showRecommendGoods:(BOOL)isShow {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoBasePlayer:showRecommendGoods:)]) {
        [self.delegate zfZegoBasePlayer:self showRecommendGoods:isShow];
    }
}

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView liveCoverStateBlack:(LiveZegoCoverState )state {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoBasePlayer:liveCoverStateBlack:)]) {
        [self.delegate zfZegoBasePlayer:self liveCoverStateBlack:state];
    }
}


#pragma mark - Action

- (void)basePlayVideoWithVideoID:(NSString *)videoID {
    
}

- (void)baseSeekToSecondsPlayVideo:(float)seconds {
    
}

- (void)removePlyerViewFromSuperView {
//    [self.webView removeFromSuperview];
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
        
        self.videoConterView.frame = CGRectMake(0, x, h, w);
//        self.webView.frame = CGRectMake(0, 0, h, w);
        
    } else {
        self.frame = self.sourceFrame;
//        self.webView.frame = self.sourceFrame;
        self.videoConterView.frame = self.sourceFrame;
    }
}

#pragma mark - 显示封面图
- (void)showPreviewView:(UIImage *)image {
    if (image) {
        self.previewImageView.image = image;
        self.previewImageView.hidden = NO;
    }
}

- (void)hidePreviewView {
    self.previewImageView.hidden = YES;
}
#pragma mark - 播放窗口显示
- (void)showToWindow:(CGSize)size {
    
    if (self.videoConterView.superview) {
        [self.videoConterView removeFromSuperview];
    }
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        CGFloat w = CGRectGetWidth(self.frame) / 2.34;
        CGFloat h = CGRectGetHeight(self.frame) / 2.34;
        size = CGSizeMake(w, h);
    }
    
    self.operateView.hidden = YES;
    self.hidden = NO;
//    self.webView.frame = CGRectMake(0, 0, size.width, size.height);
    self.videoConterView.frame = CGRectMake(KScreenWidth - size.width - 16, (KScreenHeight - size.height) / 2.0, size.width, size.height);
    self.closeButton.hidden = NO;
    [WINDOW addSubview:self.videoConterView];
    
    self.progressView.hidden = NO;
    self.tap.enabled = YES;
    [self startVideo];
}

- (void)dissmissFromWindow {
    
    self.progressView.hidden = YES;
    if (self.videoConterView.superview) {
        [self.videoConterView removeFromSuperview];
    }
    
    self.operateView.hidden = NO;
    self.closeButton.hidden = YES;
    if (self.sourceView) {
//        self.webView.frame = CGRectMake(0, 0, CGRectGetWidth(self.sourceView.frame), CGRectGetHeight(self.sourceView.frame));
        self.videoConterView.frame = CGRectMake(0, 0, CGRectGetWidth(self.sourceView.frame), CGRectGetHeight(self.sourceView.frame));
        [self insertSubview:self.videoConterView atIndex:0];
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

- (UIView *)videoConterView {
    if (!_videoConterView) {
        _videoConterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _videoConterView.backgroundColor = [UIColor blackColor];
    }
    return _videoConterView;
}

- (UIImageView *)previewImageView {
    if (!_previewImageView) {
        _previewImageView = [[UIImageView alloc] init];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFit;
        _previewImageView.hidden = YES;
    }
    return _previewImageView;
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
        _operateView.videoType = ZFVideoTypeZG;
        _operateView.delegate = self;
        _operateView.isNeedComment = YES;
    }
    return _operateView;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        activityView.color = [UIColor whiteColor];
        [activityView hidesWhenStopped];
        [activityView startAnimating];
        _activityView = activityView;
    }
    return _activityView;
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
    
    CGPoint panPoint = [panGesture locationInView:self.videoConterView.superview];
    CGFloat HEIGHT = CGRectGetHeight(self.videoConterView.frame);
    CGFloat WIDTH = CGRectGetWidth(self.videoConterView.frame);
    CGFloat moveWidth = CGRectGetWidth(self.videoConterView.superview.frame);
    CGFloat moveHeight = CGRectGetHeight(self.videoConterView.superview.frame);
    CGFloat leftSpace = 13;
    CGFloat topSpace = 24;
    
    CGFloat pointX = panPoint.x;
    CGFloat pointY = panPoint.y;
    
    //CGPoint panPoint = [p locationInView:[[UIApplication sharedApplication] keyWindow]];
    if(panGesture.state == UIGestureRecognizerStateBegan){
    } else if (panGesture.state == UIGestureRecognizerStateEnded){
    } if(panGesture.state == UIGestureRecognizerStateChanged) {
        
        self.videoConterView.center = CGPointMake(pointX, pointY);
        
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
            self.videoConterView.center = CGPointMake(pointX, pointY);
            self.isAnimating = NO;
        }];
    }
}


- (NSString *)addStaticsInfo:(BOOL)publish stream:(NSString *)streamID fps:(double)fps kbs:(double)kbs akbs:(double)akbs rtt:(int)rtt pktLostRate:(int)pktLostRate
{
    if (streamID.length == 0)
        return nil;
    
    // 丢包率的取值为 0~255，需要除以 256.0 得到丢包率百分比
    NSString *qualityString = [NSString stringWithFormat:NSLocalizedString(@"[%@] 帧率: %.3f, 视频码率: %.3f kb/s, 音频码率: %.3f kb/s, 延时: %d ms, 丢包率: %.3f%%", nil), publish ? NSLocalizedString(@"推流", nil): NSLocalizedString(@"拉流", nil), fps, kbs, akbs, rtt, pktLostRate/256.0 * 100];
    NSString *totalString =[NSString stringWithFormat:NSLocalizedString(@"[%@] 流ID: %@, 帧率: %.3f, 视频码率: %.3f kb/s, 音频码率: %.3f kb/s, 延时: %d ms, 丢包率: %.3f%%", nil), publish ? NSLocalizedString(@"推流", nil): NSLocalizedString(@"拉流", nil), streamID, fps, kbs, akbs, rtt, pktLostRate/256.0 * 100];
//    [self.staticsArray insertObject:totalString atIndex:0];
    
    //YWLog(@"---------直播状态:  %@",totalString);
    
    // 通知 log 界面更新
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logUpdateNotification" object:self userInfo:nil];
    
    return qualityString;
}

#pragma mark -- Update pubslish and play quality statistics

- (void)updateQuality:(int)quality detail:(NSString *)detail onView:(UIView *)playerView
{
    if (playerView == nil)
        return;
    
    CALayer *qualityLayer = nil;
    CATextLayer *textLayer = nil;
    
    for (CALayer *layer in playerView.layer.sublayers)
        {
        if ([layer.name isEqualToString:@"quality"])
            qualityLayer = layer;
        
        if ([layer.name isEqualToString:@"indicate"])
            textLayer = (CATextLayer *)layer;
        }
    
    int originQuality = 0;
    if (qualityLayer != nil)
        {
        if (CGColorEqualToColor(qualityLayer.backgroundColor, [UIColor greenColor].CGColor))
            originQuality = 0;
        else if (CGColorEqualToColor(qualityLayer.backgroundColor, [UIColor yellowColor].CGColor))
            originQuality = 1;
        else if (CGColorEqualToColor(qualityLayer.backgroundColor, [UIColor redColor].CGColor))
            originQuality = 2;
        else
            originQuality = 3;
        
        //        if (quality == originQuality)
        //            return;
        }
    
    UIFont *textFont = [UIFont systemFontOfSize:12];
    
    if (qualityLayer == nil)
        {
        qualityLayer = [CALayer layer];
        qualityLayer.name = @"quality";
        [playerView.layer addSublayer:qualityLayer];
        qualityLayer.frame = CGRectMake(12, 44, 10, 10);
        qualityLayer.contentsScale = [UIScreen mainScreen].scale;
        qualityLayer.cornerRadius = 5.0f;
        }
    
    if (textLayer == nil)
        {
        textLayer = [CATextLayer layer];
        textLayer.name = @"indicate";
        [playerView.layer addSublayer:textLayer];
        textLayer.backgroundColor = [UIColor clearColor].CGColor;
        textLayer.wrapped = YES;
        textLayer.font = (__bridge CFTypeRef)textFont.fontName;
        textLayer.foregroundColor = [UIColor whiteColor].CGColor;
        textLayer.fontSize = textFont.pointSize;
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        }
    
    UIColor *qualityColor = nil;
    NSString *text = nil;
    if (quality == 0)
        {
        qualityColor = [UIColor greenColor];
        text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"当前质量:", nil), NSLocalizedString(@"优", nil)];
        }
    else if (quality == 1)
        {
        qualityColor = [UIColor yellowColor];
        text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"当前质量:", nil), NSLocalizedString(@"良", nil)];
        }
    else if (quality == 2)
        {
        qualityColor = [UIColor redColor];
        text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"当前质量:", nil), NSLocalizedString(@"中", nil)];
        }
    else
        {
        qualityColor = [UIColor grayColor];
        text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"当前质量:", nil), NSLocalizedString(@"差", nil)];
        }
    
    qualityLayer.backgroundColor = qualityColor.CGColor;
    
    NSString *totalString = [NSString stringWithFormat:@"%@  %@", text, detail];
    
    //    CGSize textSize = [totalString sizeWithAttributes:@{NSFontAttributeName: textFont}];
    
    CGSize textSize = [totalString boundingRectWithSize:CGSizeMake(playerView.bounds.size.width - 30, 0)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:textFont}
                                                context:nil].size;
    
    CGRect textFrame = CGRectMake(CGRectGetMaxX(qualityLayer.frame) + 3,
                                  CGRectGetMinY(qualityLayer.frame) - 3,
                                  ceilf(textSize.width),
                                  ceilf(textSize.height) + 10);
    textLayer.frame = textFrame;
    textLayer.string = totalString;
}

#pragma mark comment

- (void)updateLayout:(NSArray<ZegoRoomMessage *> *)messageList {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (ZegoRoomMessage *message in messageList) {
            if (message.category == ZEGO_CHAT) {
                //                [self caculateLayout:@"" userName:message.fromUserName content:message.content];
            } else if (message.category == ZEGO_LIKE) {
                //解析Content 内容
                NSData *contentData = [message.content dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *contentDict = [NSJSONSerialization JSONObjectWithData:contentData options:0 error:nil];
                
                NSUInteger count = [contentDict[@"likeCount"] unsignedIntegerValue];
                if (count != 0) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self updateLikeAnimation:count];
//                    });
                }
//                [self caculateLayout:@"" userName:message.fromUserName content:@"点赞了主播"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.messageView reloadData];
//                [self scrollTableViewToBottom];
            });
        }
    });
}

- (void)addLogString:(NSString *)log {
    YWLog(@"----- %@",log);
}

- (NSDictionary *)decodeJSONToDictionary:(NSString *)json
{
    if (json == nil)
        return nil;
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData)
        {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        return dictionary;
        }
    
    return nil;
}
@end
