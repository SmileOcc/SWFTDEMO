//
//  YXLiveLandscapePlayView.m
//  uSmartOversea
//
//  Created by suntao on 2021/2/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXLiveLandscapePlayView.h"
#import "YXLiveBackgroundTool.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "NSDictionary+Category.h"

@import RSKGrowingTextView;

@interface YXLiveLandscapePlayView ()//<TXLivePlayListener>
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIView * topView;
// 视频的方向
@property (nonatomic, assign) BOOL isPortrait;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) YXExpandAreaButton *startBtn;
@property (nonatomic, strong) YXExpandAreaButton * messageBtn;
@property (nonatomic, strong) QMUIButton * inputBtn;
@property (nonatomic, strong) YXExpandAreaButton *closeBtn;
@property (nonatomic, strong) CAGradientLayer *bottomGl;

@property (nonatomic, strong) YXCommentLandscapeView * commentView;
@property (nonatomic, strong) YXLandscapeToolView * inputToolView;

@end

@implementation YXLiveLandscapePlayView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
 
    self.backgroundColor = UIColor.blackColor;
    
    [self startPlay];
    
    [self.bottomView addSubview:self.startBtn];
    [self.bottomView addSubview:self.messageBtn];
    [self.bottomView addSubview:self.inputBtn];
    [self.bottomView addSubview:self.closeBtn];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(70);
    }];
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(50);
        make.centerY.equalTo(self.bottomView);
        make.width.height.mas_equalTo(24);
    }];
    [self.messageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.startBtn.mas_right).offset(24);
        make.width.height.mas_equalTo(24);
        make.centerY.equalTo(self.startBtn.mas_centerY);
    }];
    [self.inputBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.messageBtn.mas_right).offset(24);
        make.width.mas_equalTo(140);
        make.height.mas_equalTo(36);
        make.centerY.equalTo(self.startBtn.mas_centerY);
    }];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-50);
        make.centerY.equalTo(self.bottomView);
        make.width.height.mas_equalTo(24);
    }];
    
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(70);
    }];
    
    [self addSubview:self.commentView];
    [self addSubview:self.inputToolView];
    [self actionInit];
    [self initNotifycation];
    
}

-(void)initNotifycation
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)firstShow
{
    self.topView.hidden = NO;
    self.bottomView.hidden = NO;
    
    if (self.bottomView.hidden == NO) {
        [UIView animateWithDuration:0.3 animations:^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            self.bottomView.hidden = YES;
            [self performSelector:@selector(hiddenStatus) withObject:nil afterDelay:3];
        }];
    }
    if (self.topView.hidden == NO) {
        [UIView animateWithDuration:0.3 animations:^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            self.topView.hidden = YES;
            [self performSelector:@selector(hiddenStatus) withObject:nil afterDelay:3];
        }];
    }
}

#pragma mark - Action
-(void)actionInit
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self addGestureRecognizer:tap];
    
    
    @weakify(self);
    [[self.startBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        BOOL isPlay = NO;
//        if (!self.startBtn.selected) {
//            [self.txLivePlayer pause];
//        } else {
//            [self.txLivePlayer resume];
//            isPlay = YES;
//        }
        self.startBtn.selected = !self.startBtn.selected;
        if (self.playBlock) {
            self.playBlock(isPlay);
        }

    }];
    
    [[self.messageBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        self.messageBtn.selected = !self.messageBtn.selected;
        self.commentView.hidden = (self.messageBtn.selected == YES);
        if (self.commentView.isHidden) {
            [self.commentView closeTimer];
        }else{
            [self.commentView startTimer];
        }
    }];

    [[self.closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        if (self.closeBlock) {
            self.closeBlock();
        }
    }];
    
    [[self.inputBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        if ([YXUserManager isLogin] == NO) {
            if (self.toLoginBlock) {
                self.toLoginBlock();
            }
            return;
        }
        self.inputToolView.hidden = NO;
        [self.inputToolView keyboardShowBecomeEdit];
    }];
}

- (void)tapClick {
    
    [self.inputToolView keyBoardHideEndEdit];
    
    if (self.bottomView.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            self.bottomView.hidden = NO;
            [self performSelector:@selector(hiddenStatus) withObject:nil afterDelay:3];
        }];
    }
    if (self.topView.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            self.topView.hidden = NO;
            [self performSelector:@selector(hiddenStatus) withObject:nil afterDelay:3];
        }];
    }
}

-(void)backClick:(UIButton *)sender
{
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (void)hiddenStatus {
    self.topView.hidden = YES;
    self.bottomView.hidden = YES;
}

-(void)showStatus {
    
    self.topView.hidden = NO;
    self.bottomView.hidden = NO;
}

-(void)showTopBottomView {
    [self showStatus];
}

#pragma mark - 前后台切换
- (void)willResignActive:(NSNotification *)notification {
//    if (self.txLivePlayer.isPlaying) {
//        @weakify(self);
//        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//        [YXLiveBackgroundTool setBackGroundWithLive:self.liveModel andCallBack:^(YXPlayEvent event) {
//            @strongify(self);
//            if (event == YXPlayEventPlay) {
//                [self.txLivePlayer resume];
//                self.startBtn.selected = NO;
//            } else {
//                [self.txLivePlayer pause];
//                self.startBtn.selected = YES;
//            }
//        }];
//    }
}

- (void)didBecomeActive:(NSNotification *)notification {
//    if (self.txLivePlayer) {
//    }
}

#pragma mark - keyBoardNotifycation
-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;

    self.inputToolView.frame = CGRectMake(0, keyBoardEndY-64, YXConstant.screenHeight, 64);
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    self.inputToolView.frame = CGRectMake(0, YXConstant.screenWidth, YXConstant.screenHeight, 64);
    self.inputToolView.hidden = YES;
}

- (void)startPlay {
//    self.txLivePlayer = [[TXLivePlayer alloc] init];
//    self.txLivePlayer.delegate = self;
//    // 设置裁剪
//    [self.txLivePlayer setRenderMode:RENDER_MODE_FILL_EDGE];
//
//    [self.txLivePlayer setupVideoWidget:self.bounds containView:self insertIndex:0];
}

- (void)setShowUrl:(NSString *)showUrl {
    _showUrl = showUrl;
    if (showUrl.length == 0) {
        return;
    }
//    [self.txLivePlayer startPlay:showUrl type:PLAY_TYPE_LIVE_FLV];
    [self firstShow];  //第一次进来展示
}

-(void)setIsPlaying:(BOOL)isPlaying
{
//    if (isPlaying) {
//        self.startBtn.selected = NO;
//        if (self.txLivePlayer.isPlaying == NO) {
//            [self.txLivePlayer resume];
//        }
//    }else{
//        self.startBtn.selected = YES;
//        if (self.txLivePlayer.isPlaying) {
//            [self.txLivePlayer pause];
//        }
//
//    }
}


-(void)setLiveModel:(YXLiveDetailModel *)liveModel
{
    _liveModel = liveModel;
    self.commentView.liveModel = self.liveModel;
    self.inputToolView.liveModel = self.liveModel;
    self.titleLabel.text = self.liveModel.title;
}

//- (void)setCount:(NSInteger)count {
//    _count = count;
//
//    if (count > 10000) {
//        self.watchCountLabel.text = [NSString stringWithFormat:@"%.1fw人观看", count / 10000.0];
//    } else {
//        self.watchCountLabel.text = [NSString stringWithFormat:@"%ld人观看", count];
//    }
//}

#pragma mark - txlive
- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param {

//    if (EvtID == PLAY_EVT_PLAY_BEGIN) {
//        // 播放开始
//        
//    } else if (EvtID == PLAY_EVT_PLAY_LOADING) {
//        // 加载中
//    } else if (EvtID == PLAY_EVT_CHANGE_RESOLUTION) {
//        // 分辨率改变
//        CGFloat width = [param yx_intValueForKey:@"EVT_PARAM1"];
//        CGFloat height = [param yx_intValueForKey:@"EVT_PARAM2"];
//        if (width < height) {
//            self.isPortrait = YES;
//        } else {
//            self.isPortrait = NO;
//        }
//    } else if (EvtID == PLAY_ERR_NET_DISCONNECT || EvtID == PLAY_EVT_PLAY_END) {
//        // 直播结束
//        [self.txLivePlayer startPlay:self.showUrl type:PLAY_TYPE_LIVE_FLV];
//    }
}

- (void)onNetStatus:(NSDictionary *)param {
    
    
}

-(void)closeCommentTimer
{
    [self.commentView closeTimer];
}

-(void)updateCommentFromLogin
{
    [self.commentView updateRequestDetailFromLogin];
}


#pragma mark - Getter

- (UIView *)topView {
    if (_topView == nil) {
        _topView = [[UIView alloc] init];
        _topView.clipsToBounds = YES;
        // gradient
        CAGradientLayer *gl = [CAGradientLayer layer];
        gl.frame = CGRectMake(0,0,YXConstant.screenHeight,70);
        gl.startPoint = CGPointMake(0.5, 0);
        gl.endPoint = CGPointMake(0.5, 1);
        gl.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.8].CGColor,(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor];
        gl.locations = @[@(0), @(1.0f)];
        [_topView.layer insertSublayer:gl atIndex:0];
        
        YXExpandAreaButton * backBtn = [YXExpandAreaButton buttonWithType:UIButtonTypeCustom];
        [backBtn setImage:[UIImage imageNamed:@"live_back_icon"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:backBtn];
        
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topView).offset(50);
            make.centerY.equalTo(self.topView);
            make.width.height.mas_equalTo(20);
        }];
        [_topView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(backBtn.mas_right).offset(3);
            make.centerY.equalTo(self.topView);
        }];
//        [_topView addSubview:self.watchCountLabel];
//        [self.watchCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(backBtn.mas_right).offset(3);
//            make.centerY.equalTo(self.topView);
//        }];
        
    }
    return _topView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
        _bottomView.clipsToBounds = YES;
        // gradient
        CAGradientLayer *gl = [CAGradientLayer layer];
        self.bottomGl = gl;
        gl.frame = CGRectMake(0,0,YXConstant.screenHeight,70);
        gl.startPoint = CGPointMake(0.5, 0);
        gl.endPoint = CGPointMake(0.5, 1);
        gl.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.8].CGColor];
        gl.locations = @[@(0), @(1.0f)];
        [_bottomView.layer insertSublayer:gl atIndex:0];
    }
    return _bottomView;
}

//- (UILabel *)watchCountLabel {
//    if (_watchCountLabel == nil) {
//        _watchCountLabel = [UILabel labelWithText:@"--" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:12]];
//    }
//    return _watchCountLabel;
//}

- (YXExpandAreaButton *)startBtn {
    if (_startBtn == nil) {
        _startBtn = [YXExpandAreaButton buttonWithType:UIButtonTypeCustom ];
        [_startBtn setImage:[UIImage imageNamed:@"live_stop"] forState:UIControlStateNormal];
        [_startBtn setImage:[UIImage imageNamed:@"live_play"] forState:UIControlStateSelected];
        _startBtn.selected = NO;
    }
    return _startBtn;
}

- (UIButton *)messageBtn {
    if (_messageBtn == nil) {
        _messageBtn = [YXExpandAreaButton buttonWithType:UIButtonTypeCustom ];
        [_messageBtn setImage:[UIImage imageNamed:@"tanmu_open"] forState:UIControlStateNormal];
        [_messageBtn setImage:[UIImage imageNamed:@"tanmu_close"] forState:UIControlStateSelected];
        _messageBtn.selected = NO;
    }
    return _messageBtn;
}

-(QMUIButton *)inputBtn
{
    if (_inputBtn == nil){
        _inputBtn = [[QMUIButton alloc] init];
        _inputBtn.adjustsButtonWhenHighlighted = NO;
        _inputBtn.layer.cornerRadius = 21;
    
        [_inputBtn setTitle:[YXLanguageUtility kLangWithKey:@"live_comment"] forState:UIControlStateNormal];
        [_inputBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        _inputBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _inputBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        _inputBtn.contentHorizontalAlignment = NSTextAlignmentLeft;
        _inputBtn.backgroundColor = [[UIColor qmui_colorWithHexString:@"#000000"] colorWithAlphaComponent:0.4];
    }
    return _inputBtn;
}

- (YXExpandAreaButton *)closeBtn {
    if (_closeBtn == nil) {
        _closeBtn = [YXExpandAreaButton buttonWithType:UIButtonTypeCustom ];
        [_closeBtn setImage:[UIImage imageNamed:@"live_rota"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}

-(YXCommentLandscapeView *)commentView
{
    if (!_commentView ) {
        _commentView = [[YXCommentLandscapeView alloc] initWithFrame:CGRectMake(48, 90, 300, YXConstant.screenWidth - 70 - 90)];
       
    }
    return _commentView;
}

-(YXLandscapeToolView *)inputToolView
{
    if (!_inputToolView) {
        _inputToolView = [[YXLandscapeToolView alloc] initWithFrame:CGRectMake(0, YXConstant.screenWidth, YXConstant.screenHeight, 64)];
        _inputToolView.hidden = YES;
        @weakify(self);
        _inputToolView.reqDetailCommentBlock = ^{
            @strongify(self);
            [self.commentView requestDetail];
        };
    }
    return _inputToolView;
}

@end
