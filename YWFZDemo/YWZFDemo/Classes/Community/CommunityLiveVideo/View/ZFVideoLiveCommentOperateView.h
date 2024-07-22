//
//  ZFVideoLiveCommentOperateView.h
//  ZZZZZ
//
//  Created by YW on 2019/8/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFVideoLiveCommentListView.h"
#import "ZFCommunityLiveChatLikeView.h"
#import "GZFInputTextView.h"

#import "ZFCommunityLiveViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFVideoLiveCommentOperateView : UIView

@property (nonatomic, strong) ZFCommunityLiveViewModel     *liveViewModel;

@property (nonatomic, strong) UIView                       *commentContentView;
@property (nonatomic, strong) UIView                       *commentBottomView;

/** 评论列表*/
@property (nonatomic, strong) ZFVideoLiveCommentListView   *commentListView;
/** 收起、展开按钮*/
@property (nonatomic, strong) UIButton                     *expandCollapseButton;
@property (nonatomic, strong) UITextView                   *textView;
@property (nonatomic, strong) UILabel                      *textPlaceLabel;
@property (nonatomic, strong) UIButton                     *textButton;

/** 隐藏评论按钮*/
@property (nonatomic, strong) UIButton                     *shieldButton;
/** 点赞按钮*/
@property (nonatomic, strong) UIButton                     *likeButton;
/** 点赞数显示*/
@property (nonatomic, strong) UIButton                     *likeNumButton;

/** 弹窗输入视图*/
@property (nonatomic, strong) GZFInputTextView             *inputTextView;

/** 点赞动画视图*/
@property (nonatomic, strong) ZFCommunityLiveChatLikeView  *likeView;

/** 添加、隐藏刷新组件*/
- (void)addRefreshView:(BOOL)add;


/** 刷新*/
- (void)reloadView;

/** 清除设置*/
- (void)clearAllSeting;

/** 是否隐藏显示评论*/
- (void)shieldCommentLimitShow:(BOOL)isShow;

@end
NS_ASSUME_NONNULL_END
