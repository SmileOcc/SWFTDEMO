//
//  ZFProgressHUD.m
//  ZZZZZ
//
//  Created by YW on 1/4/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFProgressHUD.h"
#import "ZFLoadingAnimationView.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "NSStringUtils.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIView+ZFViewCategorySet.h"

#define kToastShowTime                  1.5
#define kHUDLoadingViewTag              4028
#define kHUDToastViewTag                6028
#define kNetworkErrorTipViewTag         8028

CGFloat const kDelayTime                = 30;
CGFloat const kFontsize                 = 12.0;


@implementation ZFProgressHUD

/**
 * 根据传进来的参数获取需要转圈的View
 */
NS_INLINE UIView *QueryLoadingView(id parmaters) {
    NSDictionary *dict = parmaters;
    
    if (ZFJudgeNSDictionary(parmaters)) {
        if ([dict hasKey:kLoadingView] && [dict[kLoadingView] isKindOfClass:[UIView class]]) {
            return dict[kLoadingView];
        }
    } else if ([parmaters isKindOfClass:[UIView class]]) {
        return parmaters;
    }
    return (UIView*)[UIApplication sharedApplication].delegate.window;
}

/**
 移除指定参数传进来的View
 
 @param parmaters 这里的参数可以传字典(心痛的代码),也可以传UIView进来
 */
void HideLoadingFromView(id parmaters)
{
    UIView *loadingSuperView = QueryLoadingView(parmaters);
    //    UIView *loadingView = [loadingSuperView viewWithTag:kHUDLoadingViewTag];
    //    [loadingView removeFromSuperview];
    
    for (UIView *tempLoadingView in loadingSuperView.subviews) {
        if (tempLoadingView.tag == kHUDLoadingViewTag) {
            [tempLoadingView removeFromSuperview];
        }
    }
}

UIView *loadingViewFromView(id parmaters)
{
    UIView *loadingSuperView = QueryLoadingView(parmaters);
    //    UIView *loadingView = [loadingSuperView viewWithTag:kHUDLoadingViewTag];
    //    [loadingView removeFromSuperview];
    
    for (UIView *tempLoadingView in loadingSuperView.subviews) {
        if (tempLoadingView.tag == kHUDLoadingViewTag) {
            return tempLoadingView;
        }
    }
    return nil;
}

/**
 在指定的VIew上显示转圈请求
 
 @param parmaters 这里的参数可以传字典(心痛的代码),也可以传UIView进来
 */
void ShowLoadingToView(id parmaters) {
    UIView *loadingSuperView = QueryLoadingView(parmaters);
    
    CGRect rect = loadingSuperView.bounds;
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    CGFloat statusAndNavHeight = STATUSHEIGHT+44;
    if ([loadingSuperView isEqual:window]) {
        rect = CGRectMake(0, statusAndNavHeight, rect.size.width, KScreenHeight-statusAndNavHeight);
    }
    //转圈时如果有Toast显示则先移除
    UIView *oldToastView = [loadingSuperView viewWithTag:kHUDToastViewTag];
    if (oldToastView) {
        [oldToastView removeFromSuperview];
    }
    
    //转圈时如果有Loading显示则先移除
    UIView *oldLoadingView = [loadingSuperView viewWithTag:kHUDLoadingViewTag];
    if (oldLoadingView) {
        [oldLoadingView removeFromSuperview];
    }
    
    //转圈背景蒙层
    UIView *maskBgView = [[UIView alloc] initWithFrame:rect];
    maskBgView.backgroundColor = [UIColor clearColor];
    maskBgView.tag = kHUDLoadingViewTag;
    
    //Z 型动画View
    ZFLoadingAnimationView *loadingView = [[ZFLoadingAnimationView alloc] initWithFrame:CGRectMake((KScreenWidth-72)/2, (KScreenHeight-72)/2, 72, 72)];
    loadingView.center = CGPointMake(maskBgView.width/2, maskBgView.height/2 - statusAndNavHeight/2);
    [maskBgView addSubview:loadingView];
    [loadingSuperView addSubview:maskBgView];
}

/**
 * 在指定View上显示Toast提示
 */
void ShowToastToViewWithText(id parmaters ,NSString *message) {
    
    UIView *loadingSuperView = QueryLoadingView(parmaters);
    //先移除老的Toast
    UIView *oldToastView = [loadingSuperView viewWithTag:kHUDToastViewTag];
    if (oldToastView) {
        [oldToastView removeFromSuperview];
    }
    
    CGFloat statusAndNavHeight = (STATUSHEIGHT + 44) / 2;
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    if ([loadingSuperView isEqual:window] || loadingSuperView.height == window.height) {
        statusAndNavHeight = 0;
    }
    
    //老的Loading先移除
    UIView *oldLoadingView = [loadingSuperView viewWithTag:kHUDLoadingViewTag];
    if (oldLoadingView) {
        [oldLoadingView removeFromSuperview];
    }
    
    // 空字符串不提示
    if ([NSStringUtils isEmptyString:message]) return;
    
    //黑色半透明View
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectZero];
    blackView.tag = kHUDToastViewTag;
    blackView.backgroundColor = ZFCOLOR(51, 51, 51, 0.9);
    blackView.layer.cornerRadius = 8;
    blackView.layer.masksToBounds = YES;
    [loadingSuperView addSubview:blackView];
    
    CGFloat horizontalMargin = 27;//水平方向间距
    CGFloat verticalMargin = 17;//垂直方向间距
    CGFloat maxTextWidth = KScreenWidth-horizontalMargin*4;
    
    //提示文案
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.frame = CGRectMake(0, 0, maxTextWidth, 0);
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = ZFFontSystemSize(14.0);
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.preferredMaxLayoutWidth = maxTextWidth;
    messageLabel.numberOfLines = 0;
    messageLabel.text = message;
    [messageLabel sizeToFit];
    messageLabel.size = CGSizeMake(MIN(messageLabel.size.width, maxTextWidth), messageLabel.size.height);
    [blackView addSubview:messageLabel];
    
    CGFloat blackViewWidth = MIN(messageLabel.size.width + horizontalMargin*2, KScreenWidth-horizontalMargin*2);
    CGFloat blackViewHeight = messageLabel.size.height + verticalMargin*2;
    blackView.size = CGSizeMake(blackViewWidth, blackViewHeight);
    blackView.center = CGPointMake(loadingSuperView.width/2, loadingSuperView.height / 2 - statusAndNavHeight);
    
    messageLabel.center = CGPointMake(blackView.size.width/2, blackView.size.height/2);
    
    NSInteger messageLength = message.length;
    CGFloat time = messageLength / 15;
    if (time < kToastShowTime) {
        time = kToastShowTime;
    }
    if (time > 5) {
        time = 5;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (loadingSuperView) {
            [blackView removeFromSuperview];
        }
    });
}

/**
 * 显示网络异常提示框
 */
void ShowNetworkErrorTipToView(UIView *targetView,CGFloat offset) {
    HideNetworkErrorTipToView(targetView);
    
    if (!targetView) return;
    //黑色半透明View
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectZero];
    blackView.tag = kNetworkErrorTipViewTag;
    blackView.backgroundColor = ZFCOLOR(0, 0, 0, 0.65);
    blackView.layer.cornerRadius = 2;
    blackView.layer.masksToBounds = YES;
    [targetView addSubview:blackView];
    [blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(-12);
        make.height.mas_equalTo(48);
        make.top.mas_equalTo(kiphoneXTopOffsetY + 44 + offset + 4);
    }];
    
    //网络图标
    UIImageView *imageView = [[UIImageView alloc] initWithImage:ZFImageWithName(@"nowifi")];
    [blackView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(12);
        make.centerY.mas_equalTo(blackView);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    //提示文案
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.textColor = ZFCOLOR(255, 255, 255, 1);
    messageLabel.font = ZFFontSystemSize(14.0);
    messageLabel.numberOfLines = 2;
    messageLabel.text = ZFLocalizedString(@"HomeTopBar_NetworkErrorTipTitle",nil);
    [blackView addSubview:messageLabel];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(imageView.mas_trailing).offset(12);
        make.centerY.mas_equalTo(blackView);
        make.trailing.mas_equalTo(-12);
    }];
}

/**
 * 隐藏网络异常提示框
 */
void HideNetworkErrorTipToView(UIView *targetView) {
    UIView *networkErrorTipView = [targetView viewWithTag:kNetworkErrorTipViewTag];
    if (networkErrorTipView) {
        [networkErrorTipView removeFromSuperview];
    }
}

/**
 * 初始化截屏顶条
 */
void ShowScreenTopToolBarToView(UIView *superView, NSString *title, NSString *btnTitle, void(^buttonBlcok)(void)) {
    if (![superView isKindOfClass:[UIView class]]) return;
    
    CGFloat toolBarHeight = STATUSHEIGHT + 60;
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.frame = CGRectMake(0, -toolBarHeight, KScreenWidth, toolBarHeight);
    [superView addSubview:contentView];
    
    if ([title isKindOfClass:[NSString class]] && title.length > 0) {
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.backgroundColor = [UIColor clearColor];
        titleLab.textColor = ZFCOLOR(45, 45, 45, 1.0);
        titleLab.font = ZFFontSystemSize(14);
        titleLab.text = title;
        [titleLab sizeToFit];
        titleLab.x = 20;
        titleLab.y = STATUSHEIGHT + (44 - titleLab.height)/2;
        [contentView addSubview:titleLab];
    }
    
    if ([btnTitle isKindOfClass:[NSString class]] && btnTitle.length > 0) {
        UIButton *popShareViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        popShareViewBtn.titleLabel.font = ZFFontSystemSize(14);
        popShareViewBtn.backgroundColor = ZFCOLOR(45, 45, 45, 1.0);
        popShareViewBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [popShareViewBtn setTitle:btnTitle forState:0];
        [popShareViewBtn sizeToFit];
        popShareViewBtn.width += 20;
        popShareViewBtn.x = KScreenWidth-(popShareViewBtn.width+12);;
        popShareViewBtn.y = STATUSHEIGHT + (44 - popShareViewBtn.height)/2;
        [contentView addSubview:popShareViewBtn];
        [popShareViewBtn addTouchUpInsideHandler:^(UIButton *btn) {
            if (buttonBlcok) {
                buttonBlcok();
            }
        }];
    }
    __weak UIView *tempContentView = contentView;
    [UIView animateWithDuration:1 animations:^{
        tempContentView.y = 0;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:1 animations:^{
                tempContentView.y = -toolBarHeight;
            } completion:^(BOOL finished) {
                [tempContentView removeFromSuperview];
            }];
        });
    }];
}

/**
 * 显示网络请求错误信息提示弹框, 只要在网络数据中 (result)中(error != 0)时才会提示
 */
void ShowErrorToastToViewWithResult(UIView *targetView ,NSDictionary *resultDict) {
    
    if (![targetView isKindOfClass:[UIView class]]) {
        targetView = (UIView*)[UIApplication sharedApplication].delegate.window;
    }
    
    UIView *oldToastView = [targetView viewWithTag:kHUDToastViewTag];
    if (oldToastView) {
        [oldToastView removeFromSuperview];//先移除老的Toast
    }
    
    // 空字符串不提示
    if (ZFJudgeNSDictionary(resultDict)) {
        NSString *error = ZFToString(resultDict[ZFErrorKey]);
        if ([error integerValue] != 0) {
            
            NSString *msg = ZFToString(resultDict[ZFMsgKey]);
            if (!ZFIsEmptyString(msg)) {
                ShowToastToViewWithText(targetView, msg);
            }
        }
    }
}

/**
 * 显示gif动画加按钮
 */
void ShowGifImageWithGifPathToTransparenceScreenView(CGFloat offset, CGSize size, NSString *gifName, NSString *bottomImgName, void(^buttonBlcok)(void))
{
    UIView *transparenceView = [[UIView alloc] init];
    transparenceView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    transparenceView.frame = WINDOW.bounds;
    [WINDOW addSubview:transparenceView];
    @weakify(transparenceView);
    [transparenceView addTapGestureWithComplete:^(UIView * _Nonnull view) {
        @strongify(transparenceView)
        if (buttonBlcok) {
            buttonBlcok();
        }
        [transparenceView removeFromSuperview];
    }];

    CGFloat imageStartY = (STATUSHEIGHT +44) + offset;
    UIImageView *bootomImageView = [[UIImageView alloc] init];
    bootomImageView.frame = CGRectMake(0, imageStartY, transparenceView.width, size.height);
    bootomImageView.contentMode = UIViewContentModeScaleAspectFill;
    bootomImageView.clipsToBounds = YES;
    bootomImageView.image = ZFImageWithName(bottomImgName);
    [transparenceView addSubview:bootomImageView];
    
    
    YYAnimatedImageView *gifImageView = [[YYAnimatedImageView alloc] init];
    gifImageView.image = [YYImage imageNamed:gifName];
    gifImageView.frame = CGRectMake(KScreenWidth - size.width, imageStartY, size.width, size.height);
    gifImageView.contentMode = UIViewContentModeScaleAspectFill;
    gifImageView.clipsToBounds = YES;
    [transparenceView addSubview:gifImageView];
}

@end
