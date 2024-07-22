//
//  ZFVideoLiveCommentOperateView.m
//  ZZZZZ
//
//  Created by YW on 2019/8/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFVideoLiveCommentOperateView.h"
#import "Constants.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFProgressHUD.h"
#import "ZFBaseViewController.h"
#import "ZFLocalizationString.h"

@interface ZFVideoLiveCommentOperateView()

/** 是否显示评论*/
@property (nonatomic, assign) BOOL                         isShowComment;
/** 是否显示各组件*/
@property (nonatomic, assign) BOOL                         isExpandUtils;
/** 扩散、收起按钮是否可点击*/
@property (nonatomic, assign) BOOL                         isExpandEnable;
/** 显示、隐藏评论按钮是否可点击*/
@property (nonatomic, assign) BOOL                         isShieldEnable;


@end

@implementation ZFVideoLiveCommentOperateView


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isShowComment = YES;
        self.isExpandUtils = YES;
        self.isExpandEnable = YES;
        self.isShieldEnable = YES;
        
        [self addSubview:self.commentContentView];
        [self addSubview:self.commentBottomView];
        [self addSubview:self.expandCollapseButton];
        [self addSubview:self.textView];
        [self.textView addSubview:self.textPlaceLabel];
        [self.textView addSubview:self.textButton];
        
        [self.commentContentView addSubview:self.commentListView];
        [self.commentBottomView addSubview:self.likeView];
        [self.commentBottomView addSubview:self.shieldButton];
        [self.commentBottomView addSubview:self.likeButton];
        [self.commentBottomView addSubview:self.likeNumButton];
        
        [self addSubview:self.inputTextView];
        
        [self.expandCollapseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(16);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-12);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
        
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.expandCollapseButton.mas_trailing).offset(16);
            make.centerY.mas_equalTo(self.expandCollapseButton.mas_centerY);
            make.height.mas_greaterThanOrEqualTo(32);
            make.width.mas_equalTo(210);
        }];
        
        [self.textPlaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.textView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.textView.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.textView.mas_centerY);
        }];
        
        [self.textButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.textView);
        }];
        
        [self.commentBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing);
            make.centerY.mas_equalTo(self.expandCollapseButton.mas_centerY);
            make.height.mas_equalTo(50);
        }];
        
        [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.commentBottomView.mas_trailing).offset(-16);
            make.centerY.mas_equalTo(self.commentBottomView.mas_centerY);
        }];
        
        [self.likeNumButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.likeButton.mas_centerX);
            make.top.mas_equalTo(self.likeButton.mas_bottom).offset(-17);
            make.height.mas_equalTo(14);
            make.width.mas_greaterThanOrEqualTo(22);
        }];
        
        [self.shieldButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.likeButton.mas_leading).offset(-4);
            make.centerY.mas_equalTo(self.expandCollapseButton.mas_centerY);
            make.leading.mas_equalTo(self.commentBottomView.mas_leading);
        }];
        
        [self.commentContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.expandCollapseButton.mas_leading);
            make.trailing.mas_equalTo(self.textView.mas_trailing);
            make.top.mas_equalTo(self.mas_top);
            make.bottom.mas_equalTo(self.textView.mas_top).offset(2);
        }];
        [self.commentListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.commentContentView.mas_leading);
            make.trailing.mas_equalTo(self.commentContentView.mas_trailing);
            make.top.mas_equalTo(self.commentContentView.mas_top);
            make.bottom.mas_equalTo(self.commentContentView.mas_bottom);
        }];
        
        [self.likeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-1);
            make.top.mas_equalTo(self.commentContentView.mas_top);
            make.bottom.mas_equalTo(self.commentContentView.mas_bottom);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(230);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMessageNotif:) name:kVideoLiveAddMessageNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLikeNumsNotif:) name:kVideoLiveLikeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addInputTextNotif:) name:kVideoLiveCommentInputTextNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendCommentSuccessNotif:) name:kVideoLiveCommentSendTextNotification object:nil];

    }
    return self;
}

- (void)clearAllSeting {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_commentListView) {
        [_commentListView cancelMessageTimer];
    }
}

- (void)reloadView {
    [self.commentListView reloadView];
    [self.commentListView scrollTableViewToBottom];
    
    [self updateLikeNums];
    [self updateCommentContnet:[ZFVideoLiveCommentUtils sharedInstance].inputText];
}

- (void)addRefreshView:(BOOL)add {
    if (add) {
        [self.commentListView addTableViewRefreshKit];
    } else {
        [self.commentListView hideTableViewRefreshKit];
    }
}


/// 点赞处理
- (void)updateLikeNums {
    
    NSInteger likeNums = [ZFVideoLiveCommentUtils sharedInstance].likeNums;
    if (likeNums > 0) {
        NSString *numTitle = [ZFVideoLiveCommentUtils formatNumberStr:[NSString stringWithFormat:@"%ld",(long)likeNums]];
        [self.likeNumButton setTitle:numTitle forState:UIControlStateNormal];
        self.likeNumButton.hidden = NO;
    } else {
        self.likeNumButton.hidden = YES;
    }
}

/// 输入内容
- (void)updateCommentContnet:(NSString *)text {
    if (!ZFIsEmptyString(text)) {
        self.textPlaceLabel.hidden = YES;
        self.textView.text = text;
        [ZFVideoLiveCommentUtils sharedInstance].inputText = text;
    } else {
        self.textPlaceLabel.hidden = NO;
        self.textView.text = @"";
        [ZFVideoLiveCommentUtils sharedInstance].inputText = @"";
    }
}

/// 隐藏、显示事件单元
- (void)expandUtilsView:(void (^)(void))completion {
    if (self.isExpandUtils) {
        self.commentListView.hidden = NO;
        self.textView.hidden = NO;
        self.commentBottomView.hidden = NO;
    } else {
        self.commentListView.hidden = YES;
        self.textView.hidden = YES;
        self.commentBottomView.hidden = YES;
    }
    if (completion) {
        completion();
    }
}

/// 隐藏、显示评论视图
- (void)shieldCommentLimitShow:(BOOL)isShow {
    if (self.isShowComment && self.isExpandUtils) {
        [self shieldCommentViewShow:isShow completion:^{
            
        }];
    } else if(self.isShowComment && !self.isExpandUtils) {//不显示其他小组件时
        [self shieldCommentViewShow:isShow completion:^{
            
        }];
    }
}

/// 隐藏、显示评论
- (void)shieldCommentViewShow:(BOOL)isShow completion:(void (^)(void))completion {
    
    if (self.isShowComment) {
        
        [self.shieldButton setImage:[UIImage imageNamed:@"live_video_comment_on"] forState:UIControlStateNormal];
        [self.shieldButton setImage:[UIImage imageNamed:@"live_video_comment_on"] forState:UIControlStateSelected];
        
    } else {
        
        [self.shieldButton setImage:[UIImage imageNamed:@"live_video_comment_off"] forState:UIControlStateNormal];
        [self.shieldButton setImage:[UIImage imageNamed:@"live_video_comment_off"] forState:UIControlStateSelected];
    }
    
    if (isShow && self.isExpandUtils) {
        self.commentListView.hidden = NO;
    }
    
    CGFloat topSpace = isShow ? 0 : 250;
    [UIView animateWithDuration:0.2 animations:^{
        [self.commentListView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.commentContentView.mas_top).offset(topSpace);
        }];
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
        self.commentListView.hidden = self.isExpandUtils ? !isShow : YES;
    }];
}

#pragma mark - Action

- (void)actionText:(UIButton *)sender {

    if ([AccountManager sharedManager].isSignIn) {
        self.inputTextView.textView.text = ZFToString([ZFVideoLiveCommentUtils sharedInstance].inputText);
        [self.inputTextView showTextView];
        
    } else {
        //此处只登录
        [self isOperateLoginBlock:^{
            
        }];
    }
}

- (void)sendCommentMsg:(NSString *)contentMsg {
    if (!ZFIsEmptyString(contentMsg)) {
        [self endEditing:YES];
        self.textView.text = @"";

        NSString *phase = [ZFVideoLiveCommentUtils sharedInstance].isLoginRoom ? @"1" : @"0";
        NSString *nickName = [ZFVideoLiveCommentUtils sharedInstance].nickName;
        
        [self.liveViewModel requestCommunityLiveCommentLiveID:[ZFVideoLiveCommentUtils sharedInstance].liveDetailID liveType:[ZFVideoLiveCommentUtils sharedInstance].isLoginRoom ? @"1" : @"0" content:contentMsg nickname:ZFToString(nickName) phase:phase completion:^(BOOL success, NSString *msg) {
            if (success) {
                YWLog(@"---- 直播评论成功");
                
                /// 未登录时，自己添加
                if (![ZFVideoLiveCommentUtils sharedInstance].isLoginRoom) {
                    ZFZegoMessageInfo *message = [[ZFZegoMessageInfo alloc] init];
                    message.type = @"4";
                    message.nickname = ZFToString([AccountManager sharedManager].account.nickname);
                    message.content = ZFToString(contentMsg);
                    [[ZFVideoLiveCommentUtils sharedInstance] addMessage:message];
                }
                
                [ZFVideoLiveCommentUtils sharedInstance].inputText = @"";
                [[ZFVideoLiveCommentUtils sharedInstance] sendCommentSuccessNotif];
                [[ZFVideoLiveCommentUtils sharedInstance] refreshInputTextNotif];
            } else {
                self.textView.text = [ZFVideoLiveCommentUtils sharedInstance].inputText;
                ShowToastToViewWithText(self, msg);
            }
        }];
        
        
    }
}

- (void)actionExpand:(UIButton *)sender {
    
    if (self.isExpandEnable) {
        self.isExpandUtils = !self.isExpandUtils;

//        if (self.isExpandUtils) {
//            [sender setImage:[UIImage imageNamed:@"live_video_comment_hide"] forState:UIControlStateNormal];
//            [sender setImage:[UIImage imageNamed:@"live_video_comment_hide"] forState:UIControlStateSelected];
//        } else {
//            [sender setImage:[UIImage imageNamed:@"live_video_comment_show"] forState:UIControlStateNormal];
//            [sender setImage:[UIImage imageNamed:@"live_video_comment_show"] forState:UIControlStateSelected];
//        }
        if (self.isExpandUtils) {
            [UIView animateWithDuration:0.25 animations:^{
                CGAffineTransform transform = CGAffineTransformIdentity;
                [self.expandCollapseButton.imageView setTransform:transform];
            }];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
                [self.expandCollapseButton.imageView setTransform:transform];
            }];
        }
        
        self.isExpandEnable = NO;
        [self expandUtilsView:^{
            self.isExpandEnable = YES;
        }];
    }
}


- (void)actionLike:(UIButton *)sender {
    [self endEditing:YES];

    [sender.imageView.layer addAnimation:[sender.imageView zfAnimationFavouriteScaleMax:1.1] forKey:@"Liked"];

    @weakify(self)
    [self isOperateLoginBlock:^{
        @strongify(self)
        [self liveLikeEvent];
    }];
}

- (void)isOperateLoginBlock:(void (^)(void))completion {
    
    if ([AccountManager sharedManager].isSignIn) {
        if (completion) {
            completion();
        }
        
    } else {
        
        UIViewController *ctrl = self.viewController;
        if ([ctrl isKindOfClass:[ZFBaseViewController class]]) {
            ZFBaseViewController *baseCtrl = (ZFBaseViewController *)ctrl;
            if (baseCtrl.navigationController) {
                ZFNavigationController *nav = (ZFNavigationController *)baseCtrl.navigationController;
                if (nav.interfaceOrientation == UIInterfaceOrientationLandscapeRight || nav.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                    
                    [baseCtrl forceOrientation:AppForceOrientationPortrait];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        baseCtrl.isStatusBarHidden = NO;
                        [self.viewController judgePresentLoginVCCompletion:^{
                            baseCtrl.isStatusBarHidden = YES;
                            if (completion) {
                                completion();
                            }
                        } cancelCompetion:^{
                            baseCtrl.isStatusBarHidden = YES;
                        }];
                    });
                    
                    
                } else {
                    
                    baseCtrl.isStatusBarHidden = NO;
                    [self.viewController judgePresentLoginVCCompletion:^{
                        baseCtrl.isStatusBarHidden = YES;
                        if (completion) {
                            completion();
                        }
                    } cancelCompetion:^{
                        baseCtrl.isStatusBarHidden = YES;
                    }];
                }
            }
        }
    }
}

- (void)liveLikeEvent {
    
    //没有登录，自己加动画，登录情况下，点赞成，直播会收到点赞消息，然后显示动画
    if (![ZFVideoLiveCommentUtils sharedInstance].isLoginRoom) {
        //点赞
        [ZFVideoLiveCommentUtils sharedInstance].likeNums++;
        [self updateLikeNums];
        [self.likeView doLikeAnimation];
        
    } else if([ZFVideoLiveCommentUtils sharedInstance].isLoginRoom) {
        //登录成功，直播流链接中断
//        if (![ZFVideoLiveCommentUtils sharedInstance].isLiveConnecting) {
//            //点赞
//            [ZFVideoLiveCommentUtils sharedInstance].likeNums++;
//            [self refreshLikeNums];
//            [self.likeView doLikeAnimation];
//        }
    }
    
    NSString *phase = [[ZFVideoLiveCommentUtils sharedInstance].liveType isEqualToString:@"2"] ? @"1" : @"0";
    NSString *nickName = [ZFVideoLiveCommentUtils sharedInstance].nickName;
    //写死为1 不然测试没及时数据
    phase = @"1";
    
    [self.liveViewModel requestCommunityLiveLikeLiveID:[ZFVideoLiveCommentUtils sharedInstance].liveDetailID liveType:[ZFVideoLiveCommentUtils sharedInstance].isLoginRoom ? @"1" : @"0" nickname:ZFToString(nickName) phase:phase completion:^(ZFCommunityLiveZegoLikeModel *likeModel) {
        
        if (![ZFVideoLiveCommentUtils sharedInstance].isLoginRoom) {//没有登录，自己加动画
            if ([likeModel.like_num integerValue] > 0) {
                [ZFVideoLiveCommentUtils sharedInstance].likeNums = [likeModel.like_num integerValue];
                [[ZFVideoLiveCommentUtils sharedInstance] refreshLikeNumsAnimate:NO];
            }
        }
    }];
}


- (void)actionShield:(UIButton *)sender {
    if (self.isShieldEnable) {
        self.isShieldEnable = NO;

        self.isShowComment = !self.isShowComment;
        [self shieldCommentViewShow:self.isShowComment completion:^{
            self.isShieldEnable = YES;
        }];
    }
}

#pragma mark - Notfication

- (void)addMessageNotif:(NSNotification *)notif {
    
    if ([notif.object isKindOfClass:[ZFZegoMessageInfo class]]) {
        ZFZegoMessageInfo *messageInfo = (ZFZegoMessageInfo *)notif.object;
        if(messageInfo.infoType == ZegoMessageInfoTypeComment
           || messageInfo.infoType == ZegoMessageInfoTypeSystem
           || messageInfo.infoType == ZegoMessageInfoTypeUser) {
            
            [self.commentListView reloadView];
            [self.commentListView scrollTableViewToBottom];
        }
    } else if([notif.object isKindOfClass:[NSString class]]) {
        [self.commentListView reloadView];
        
        if ([notif.object isEqualToString:@"scrollToTop"]) {
            // 处理第一页数据显示，滚到底部
            if ([ZFVideoLiveCommentUtils sharedInstance].liveMessageList.count <= 20) {
                [self.commentListView scrollTableViewToBottom];
            } else {
                [self.commentListView scrollTableViewToTop];
            }
        }
        
    }  else {
        [self.commentListView reloadView];
        [self.commentListView scrollTableViewToBottom];
    }
}

- (void)addLikeNumsNotif:(NSNotification *)notif {
    if ([ZFVideoLiveCommentUtils sharedInstance].isLoginRoom) {
        if ([notif.object isKindOfClass:[NSNumber class]]) {
            if ([notif.object boolValue]) {
                [self.likeView doLikeAnimation];
            }
        }
    }
    [self updateLikeNums];
}

- (void)addInputTextNotif:(NSNotification *)notif {
    [self updateCommentContnet:[ZFVideoLiveCommentUtils sharedInstance].inputText];
}

- (void)sendCommentSuccessNotif:(NSNotification *)notif {
    self.commentListView.hasMoved = NO;
    [self.commentListView scrollTableViewToBottom];
}

#pragma mark - Property Method

- (ZFCommunityLiveViewModel *)liveViewModel {
    if (!_liveViewModel) {
        _liveViewModel = [[ZFCommunityLiveViewModel alloc] init];
    }
    return _liveViewModel;
}

- (UIButton *)expandCollapseButton {
    if (!_expandCollapseButton) {
        _expandCollapseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_expandCollapseButton setImage:[UIImage imageNamed:@"live_video_comment_hide"] forState:UIControlStateNormal];
        [_expandCollapseButton setImage:[UIImage imageNamed:@"live_video_comment_hide"] forState:UIControlStateSelected];

        [_expandCollapseButton addTarget:self action:@selector(actionExpand:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _expandCollapseButton;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.backgroundColor = ColorHex_Alpha(0x000000, 0.2);
        _textView.layer.cornerRadius = 16.0;
        _textView.layer.masksToBounds = YES;
        _textView.textColor = ZFC0xDDDDDD();
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.editable = NO;
    }
    return _textView;
}

- (UILabel *)textPlaceLabel {
    if (!_textPlaceLabel) {
        _textPlaceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textPlaceLabel.textColor = ZFC0xDDDDDD();
        _textPlaceLabel.font = [UIFont systemFontOfSize:14];
        _textPlaceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _textPlaceLabel.text = ZFLocalizedString(@"Live_Review_Input_tip", nil);
    }
    return _textPlaceLabel;
}

- (UIButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_likeButton setImage:[UIImage imageNamed:@"live_video_like_white"] forState:UIControlStateNormal];
        [_likeButton addTarget:self action:@selector(actionLike:) forControlEvents:UIControlEventTouchUpInside];
        _likeButton.contentEdgeInsets = UIEdgeInsetsMake(12, 8, 12, 8);
    }
    return _likeButton;
}

- (UIButton *)likeNumButton {
    if (!_likeNumButton) {
        _likeNumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeNumButton.layer.cornerRadius = 7.0;
        _likeNumButton.layer.masksToBounds = YES;
        _likeNumButton.hidden = YES;
        _likeNumButton.titleLabel.font = [UIFont systemFontOfSize:9];
        [_likeNumButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        _likeNumButton.contentEdgeInsets =  UIEdgeInsetsMake(0, 5, 0.5, 5);
        _likeNumButton.userInteractionEnabled = NO;
        [_likeNumButton setBackgroundColor:ZFC0xFF5C9C()];
        
    }
    return _likeNumButton;
}

- (UIButton *)shieldButton {
    if (!_shieldButton) {
        _shieldButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shieldButton setImage:[UIImage imageNamed:@"live_video_comment_on"] forState:UIControlStateNormal];
        [_shieldButton setImage:[UIImage imageNamed:@"live_video_comment_on"] forState:UIControlStateSelected];
        [_shieldButton addTarget:self action:@selector(actionShield:) forControlEvents:UIControlEventTouchUpInside];
        _shieldButton.contentEdgeInsets = UIEdgeInsetsMake(12, 8, 12, 8);


    }
    return _shieldButton;
}

- (UIView *)commentContentView {
    if (!_commentContentView) {
        _commentContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _commentContentView.backgroundColor = [UIColor clearColor];
        _commentContentView.layer.masksToBounds = YES;
    }
    return _commentContentView;
}

- (UIView *)commentBottomView {
    if (!_commentBottomView) {
        _commentBottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _commentBottomView.backgroundColor = [UIColor clearColor];
    }
    return _commentBottomView;
}


- (ZFVideoLiveCommentListView *)commentListView {
    if (!_commentListView) {
        _commentListView = [[ZFVideoLiveCommentListView alloc] initWithFrame:CGRectZero isNew:NO];
        _commentListView.isHorizontalState = YES;
    }
    return _commentListView;
}

- (ZFCommunityLiveChatLikeView *)likeView {
    if (!_likeView) {
        _likeView = [[ZFCommunityLiveChatLikeView alloc] initWithFrame:CGRectZero];
        _likeView.userInteractionEnabled = NO;
    }
    return _likeView;
}

- (UIButton *)textButton {
    if (!_textButton) {
        _textButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_textButton addTarget:self action:@selector(actionText:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _textButton;
}

- (GZFInputTextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[GZFInputTextView alloc] initWithFrame:CGRectZero];
        _inputTextView.hidden = YES;
        @weakify(self)
        _inputTextView.texeEditBlock = ^(NSString *text) {
            @strongify(self)
            [self updateCommentContnet:text];
            [[ZFVideoLiveCommentUtils sharedInstance] refreshInputTextNotif];
        };
        _inputTextView.sendTextBlock = ^(NSString * _Nonnull text) {
            @strongify(self)
            [self sendCommentMsg:text];
        };
    }
    return _inputTextView;
}
@end
