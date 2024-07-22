//
//  ZFFullLiveLiveVideoChatView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveLiveVideoChatView.h"
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


@interface ZFFullLiveLiveVideoChatView ()

@end

@implementation ZFFullLiveLiveVideoChatView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.messageListView];
        [self addSubview:self.likeView];
        [self addSubview:self.pushContentView];
        
        CGFloat mixW = [ZFVideoLiveCommentListView newLiveCommentListWidth];
        [self.messageListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading);
            make.width.mas_equalTo(mixW);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.top.mas_equalTo(self.mas_top).offset(10);
        }];
        
        [self.likeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.width.mas_equalTo(90);
            make.height.mas_equalTo(300);
        }];
        
        [self.pushContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.messageListView.mas_top).offset(75);
            make.width.mas_equalTo(mixW);
            make.leading.offset(0);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMessageNotif:) name:kVideoLiveAddMessageNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMessageNotif:) name:kVideoLiveOrderPayCartNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLikeNumsNotif:) name:kVideoLiveLikeNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addInputTextNotif:) name:kVideoLiveCommentInputTextNotification object:nil];
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

#pragma mark - Notfication

- (void)addMessageNotif:(NSNotification *)notif {
    
    if ([notif.object isKindOfClass:[ZFZegoMessageInfo class]]) {
        ZFZegoMessageInfo *messageInfo = (ZFZegoMessageInfo *)notif.object;
        if(messageInfo.infoType == ZegoMessageInfoTypeComment
           || messageInfo.infoType == ZegoMessageInfoTypeSystem
           || messageInfo.infoType == ZegoMessageInfoTypeUser) {
            
            [self.messageListView reloadView];
            [self.messageListView scrollTableViewToBottom];
        } else if(messageInfo.infoType == ZegoMessageInfoTypePay || messageInfo.infoType == ZegoMessageInfoTypeOrder || messageInfo.infoType == ZegoMessageInfoTypeCart) {
            [self.pushContentView pushMessageInfo:messageInfo];
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

- (ZFVideoLiveCommentListView *)messageListView {
    if (!_messageListView) {
        _messageListView = [[ZFVideoLiveCommentListView alloc] initWithFrame:CGRectZero isNew:YES];
        _messageListView.isNoNeedTimer = YES;
        _messageListView.isNoDataHideMessageList = YES;
        
//        [_messageListView startMessageTimer];
    }
    return _messageListView;
}

- (ZFCommunityLiveChatLikeView *)likeView {
    if (!_likeView) {
        _likeView = [[ZFCommunityLiveChatLikeView alloc] initWithFrame:CGRectZero];
        _likeView.userInteractionEnabled = NO;
    }
    return _likeView;
}

- (ZFFullLiveMessagePushContentView *)pushContentView {
    if (!_pushContentView) {
        _pushContentView = [[ZFFullLiveMessagePushContentView alloc] init];
        _pushContentView.backgroundColor = [UIColor clearColor];
    }
    return _pushContentView;
}
@end
