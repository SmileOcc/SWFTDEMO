//
//  ZFCommunityLiveVideoChatView.m
//  ZZZZZ
//
//  Created by YW on 2019/8/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveVideoChatView.h"
#import "Constants.h"
#import "Masonry.h"
#import "ZFZegoHelper.h"
#import "YWCFunctionTool.h"
#import "ZFThemeManager.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "ZFBaseViewController.h"

@interface ZFCommunityLiveVideoChatView ()

@end

@implementation ZFCommunityLiveVideoChatView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bottomView];
        [self addSubview:self.messageListView];
        [self addSubview:self.likeView];
        
        [self.bottomView addSubview:self.textView];
        [self.bottomView addSubview:self.textPlaceLabel];
        [self.bottomView addSubview:self.textButton];
        [self.bottomView addSubview:self.likeButton];
        [self.bottomView addSubview:self.lineView];
        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.trailing.mas_equalTo(self);
            make.height.mas_equalTo(49);
        }];
        
        [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.bottomView.mas_centerY);
            make.width.mas_greaterThanOrEqualTo(73);
        }];
        
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bottomView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.likeButton.mas_leading);
            make.centerY.mas_equalTo(self.bottomView.mas_centerY);
            make.height.mas_equalTo(37);
        }];
        
        [self.textPlaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.textView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.textView.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.textView.mas_centerY);
        }];
        
        [self.textButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.textView);
        }];
        
        [self.messageListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(16);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-49);
            make.top.mas_equalTo(self.mas_top).offset(10);
        }];
        
        [self.likeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing);
            make.bottom.mas_equalTo(self.bottomView.mas_top);
            make.width.mas_equalTo(90);
            make.height.mas_equalTo(300);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_equalTo(self.bottomView);
            make.height.mas_equalTo(MIN_PIXEL);
        }];
        
        [self.textView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.likeButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.likeButton setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMessageNotif:) name:kVideoLiveAddMessageNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLikeNumsNotif:) name:kVideoLiveLikeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addInputTextNotif:) name:kVideoLiveCommentInputTextNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendCommentSuccessNotif:) name:kVideoLiveCommentSendTextNotification object:nil];

    }
    return self;
}


- (void)zfViewWillAppear {
}

- (void)clearAllSeting {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_messageListView) {
        [_messageListView cancelMessageTimer];
    }
}

- (void)fullScreen:(id)isFull {
    if (![isFull boolValue]) {
        [self.messageListView scrollCurrentContnetOffSetY];
    }
}
- (void)addHeaderRefreshKit:(BOOL)flag {
    if (flag) {
        [self.messageListView addTableViewRefreshKit];
    } else {
        [self.messageListView hideTableViewRefreshKit];
    }
}


- (void)updateLikeNums {
    self.likeNums = [ZFVideoLiveCommentUtils sharedInstance].likeNums;
}
#pragma mark - Private Method

- (void)actionText:(UIButton *)sender {
    
    ZFBaseViewController *baseVC = (ZFBaseViewController *)self.viewController;
    baseVC.isStatusBarHidden = NO;

    @weakify(self)
    [self.viewController judgePresentLoginVCCompletion:^{
        @strongify(self)
        baseVC.isStatusBarHidden = YES;
        
        self.inputTextView.textView.text = ZFToString([ZFVideoLiveCommentUtils sharedInstance].inputText);
        [self.inputTextView showTextView];
    }];
    
}

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

- (void)sendCommentMsg:(NSString *)contentMsg {
    if (!ZFIsEmptyString(contentMsg)) {
        [self endEditing:YES];
        
        self.textView.text = @"";
        
        ShowLoadingToView(self);
        
        NSString *phase = [ZFVideoLiveCommentUtils sharedInstance].isLoginRoom ? @"1" : @"0";
        NSString *nickName = [ZFVideoLiveCommentUtils sharedInstance].nickName;

        
        @weakify(self)
        [self.liveViewModel requestCommunityLiveCommentLiveID:[ZFVideoLiveCommentUtils sharedInstance].liveDetailID liveType:[ZFVideoLiveCommentUtils sharedInstance].isLoginRoom ? @"1" : @"0" content:contentMsg nickname:ZFToString(nickName) phase:phase completion:^(BOOL success, NSString *msg) {
            @strongify(self)
            HideLoadingFromView(self);

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


- (void)actionLike:(UIButton *)sender {
    [self endEditing:YES];
    
    [sender.imageView.layer addAnimation:[sender.imageView zfAnimationFavouriteScaleMax:1.1] forKey:@"Liked"];
    
    
    ZFBaseViewController *baseVC = (ZFBaseViewController *)self.viewController;
    baseVC.isStatusBarHidden = NO;
    @weakify(self)
    [self.viewController judgePresentLoginVCCompletion:^{
        @strongify(self)
        baseVC.isStatusBarHidden = YES;
        [self liveLikeEvent];
    }];
}

- (void)liveLikeEvent {
    
    //没有登录，自己加动画，登录情况下，点赞成，直播会收到点赞消息，然后显示动画
    if (![ZFVideoLiveCommentUtils sharedInstance].isLoginRoom) {
        //点赞
        [self.likeView doLikeAnimation];
        self.likeNums ++;
    } else if([ZFVideoLiveCommentUtils sharedInstance].isLoginRoom) {
        //登录成功，直播流链接中断
//        if (![ZFVideoLiveCommentUtils sharedInstance].isLiveConnecting) {
//            //点赞
//            [self.likeView doLikeAnimation];
//            self.likeNums ++;
//        }
    }
    
    NSString *phase = [[ZFVideoLiveCommentUtils sharedInstance].liveType isEqualToString:@"2"] ? @"1" : @"0";
    NSString *nickName = [ZFVideoLiveCommentUtils sharedInstance].nickName;
    //写死为1 不然测试没及时数据
    phase = @"1";
    
    [self.liveViewModel requestCommunityLiveLikeLiveID:[ZFVideoLiveCommentUtils sharedInstance].liveDetailID liveType:[ZFVideoLiveCommentUtils sharedInstance].isLoginRoom ? @"1" : @"0" nickname:ZFToString(nickName) phase:phase completion:^(ZFCommunityLiveZegoLikeModel *likeModel) {
        
        if (![ZFVideoLiveCommentUtils sharedInstance].isLoginRoom) {
            if ([likeModel.like_num integerValue] > 0) {
                [ZFVideoLiveCommentUtils sharedInstance].likeNums = [likeModel.like_num integerValue];
                [[ZFVideoLiveCommentUtils sharedInstance] refreshLikeNumsAnimate:NO];
            }
        }
    }];
}

#pragma mark - Notfication

- (void)addMessageNotif:(NSNotification *)notif {
    
    if ([notif.object isKindOfClass:[ZFZegoMessageInfo class]]) {
        ZFZegoMessageInfo *messageInfo = (ZFZegoMessageInfo *)notif.object;
        if(messageInfo.infoType == ZegoMessageInfoTypeComment
           || messageInfo.infoType == ZegoMessageInfoTypeSystem
           || messageInfo.infoType == ZegoMessageInfoTypeUser) {
            
            [self.messageListView reloadView];
            [self.messageListView scrollTableViewToBottom];
        }
    } else if([notif.object isKindOfClass:[NSString class]]) {
        [self.messageListView reloadView];
        if ([notif.object isEqualToString:@"scrollToTop"]) {
            
            // 处理第一页数据显示，滚到底部
            if ([ZFVideoLiveCommentUtils sharedInstance].liveMessageList.count <= 20) {
                [self.messageListView scrollTableViewToBottom];
            } else {
                [self.messageListView scrollTableViewToTop];
            }
        }
    } else {
        [self.messageListView reloadView];
        [self.messageListView scrollTableViewToBottom];
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
    self.messageListView.hasMoved = NO;
    [self.messageListView scrollTableViewToBottom];
}

#pragma mark - Property Method

- (ZFCommunityLiveViewModel *)liveViewModel {
    if (!_liveViewModel) {
        _liveViewModel = [[ZFCommunityLiveViewModel alloc] init];
    }
    return _liveViewModel;
}

- (void)setLikeNums:(NSInteger)likeNums {
    _likeNums = likeNums;
    if (likeNums > 0) {
        NSString *numTitle = [ZFVideoLiveCommentUtils formatNumberStr:[NSString stringWithFormat:@"%ld",(long)likeNums]];
        [self.likeButton setTitle:numTitle forState:UIControlStateNormal];
        [self.likeButton zfLayoutStyle:ZFButtonEdgeInsetsStyleTop imageTitleSpace:2];
    }
}

- (ZFVideoLiveCommentListView *)messageListView {
    if (!_messageListView) {
        _messageListView = [[ZFVideoLiveCommentListView alloc] initWithFrame:CGRectZero isNew:NO];
        [_messageListView startMessageTimer];
    }
    return _messageListView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _bottomView;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.backgroundColor = ZFC0xF7F7F7();
        _textView.layer.cornerRadius = 2.0;
        _textView.layer.masksToBounds = YES;
        _textView.textColor = ZFC0x2D2D2D();
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.editable = NO;
    }
    return _textView;
}

- (UILabel *)textPlaceLabel {
    if (!_textPlaceLabel) {
        _textPlaceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textPlaceLabel.textColor = ZFC0xCCCCCC();
        _textPlaceLabel.font = [UIFont systemFontOfSize:14];
        _textPlaceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _textPlaceLabel.text = ZFLocalizedString(@"Live_Review_Input_tip", nil);
    }
    return _textPlaceLabel;
}

- (UIButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_likeButton setImage:[UIImage imageNamed:@"live_video_like"] forState:UIControlStateNormal];
        _likeButton.titleLabel.font = [UIFont systemFontOfSize:9];
        [_likeButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_likeButton addTarget:self action:@selector(actionLike:) forControlEvents:UIControlEventTouchUpInside];
        [_likeButton convertUIWithARLanguage];
    }
    return _likeButton;
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


- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = ZFC0xDDDDDD();
    }
    return _lineView;
}

@end
