//
//  ZFFullLiveSendMessageView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>

#import "ZFVideoLiveCommentListView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFFullLiveSendMessageView : UIView


@property (nonatomic, strong) UIView                          *expandCollapseView;
@property (nonatomic, strong) UIButton                        *expandCollapseButton;


@property (nonatomic, strong) UIView                          *goodsView;
@property (nonatomic, strong) YYAnimatedImageView             *goodsImageView;
@property (nonatomic, strong) UIButton                        *goodsButton;
@property (nonatomic, assign) BOOL                            stopGoodsAnimate;

@property (nonatomic, strong) UIView                          *couponView;
@property (nonatomic, strong) YYAnimatedImageView             *couponImageView;
@property (nonatomic, strong) UIButton                        *couponButton;
@property (nonatomic, assign) BOOL                            stopCouponAnimate;

@property (nonatomic, strong) UIView                          *commentView;
@property (nonatomic, strong) UIButton                        *commentButton;


/** 点赞按钮*/
@property (nonatomic, strong) UIView                          *likeView;
@property (nonatomic, strong) UIButton                        *likeButton;
@property (nonatomic, strong) UIButton                        *likeNumsButton;


@property (nonatomic, strong) UITextView                      *textView;
@property (nonatomic, strong) UILabel                         *textPlaceLabel;
@property (nonatomic, strong) UIButton                        *textButton;


/** 是否显示各组件 外部最好判断一下 根据这个*/
@property (nonatomic, assign) BOOL                         isShowExpandUtils;
/** 扩散、收起按钮是否可点击*/
@property (nonatomic, assign) BOOL                         isExpandEnable;

/** 点赞数*/
@property (nonatomic, assign) NSInteger                       likeNums;

- (void)showCommentView:(BOOL)show;

- (void)showLandscapeView:(BOOL)showLandscape;

- (void)updateCommentContnet:(NSString *)text;

/// 隐藏、显示事件单元
- (void)hideEventView;

@property (nonatomic, copy) void (^expandBlock)(BOOL isShow);
@property (nonatomic, copy) void (^goodsBlock)(void);
@property (nonatomic, copy) void (^couponBlock)(void);
@property (nonatomic, copy) void (^commentBlock)(void);
@property (nonatomic, copy) void (^likeBlock)(void);
@property (nonatomic, copy) void (^textBlock)(void);





@end

NS_ASSUME_NONNULL_END
