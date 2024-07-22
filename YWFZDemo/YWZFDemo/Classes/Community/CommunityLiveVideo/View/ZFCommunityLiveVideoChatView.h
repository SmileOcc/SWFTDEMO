//
//  ZFCommunityLiveVideoChatView.h
//  ZZZZZ
//
//  Created by YW on 2019/8/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYText.h"
#import "ZFCommunityLiveChatLikeView.h"
#import "ZFVideoLiveCommentListView.h"
#import "GZFInputTextView.h"
#import "ZFCommunityLiveViewModel.h"

@interface ZFCommunityLiveVideoChatView : UIView


@property (nonatomic, strong) ZFCommunityLiveViewModel        *liveViewModel;

/** 评论列表*/
@property (nonatomic, strong) ZFVideoLiveCommentListView      *messageListView;

@property (nonatomic, strong) UIView                          *bottomView;
@property (nonatomic, strong) UITextView                      *textView;
@property (nonatomic, strong) UILabel                         *textPlaceLabel;
@property (nonatomic, strong) UIButton                        *textButton;

/** 点赞按钮*/
@property (nonatomic, strong) UIButton                        *likeButton;
@property (nonatomic, strong) UIView                          *lineView;

/** 弹出输入视图*/
@property (nonatomic, strong) GZFInputTextView                *inputTextView;

/** 点赞动画视图*/
@property (nonatomic, strong) ZFCommunityLiveChatLikeView     *likeView;
/** 点赞数*/
@property (nonatomic, assign) NSInteger                       likeNums;


/**
 是否添加、隐藏刷新加载更多

 @param flag : YES 有刷新， NO 无刷新
 */
- (void)addHeaderRefreshKit:(BOOL)flag;

- (void)zfViewWillAppear;


/**
 清除设置
 */
- (void)clearAllSeting;

/**
 横竖屏处理

 @param isFull ：
 */
- (void)fullScreen:(id)isFull;

@end

