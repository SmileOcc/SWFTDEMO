//
//  STLProgressHUD.m
// XStarlinkProject
//
//  Created by odd on 2020/7/18.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLProgressHUD.h"
#import "STLCFunctionTool.h"

#define kToastShowTime                  1.5
#define kHUDLoadingViewTag              4028
#define kHUDToastViewTag                6028
#define kNetworkErrorTipViewTag         8028

CGFloat const kDelayTime                = 30;
CGFloat const kFontsize                 = 12.0;

@implementation STLProgressHUD

/**
 * 根据传进来的参数获取需要转圈的View
 */
NS_INLINE UIView *QueryLoadingView(id parmaters) {
    NSDictionary *dict = parmaters;
    
    if (STLJudgeNSDictionary(parmaters)) {
        if (dict[kLoadingView] && [dict[kLoadingView] isKindOfClass:[UIView class]]) {
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
    CGFloat statusAndNavHeight = kSTATUSHEIGHT+44;
    if ([loadingSuperView isEqual:window]) {
        rect = CGRectMake(0, statusAndNavHeight, rect.size.width, SCREEN_HEIGHT-statusAndNavHeight);
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
    STLLoadingAnimationView *loadingView = [[STLLoadingAnimationView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-72)/2, (SCREEN_HEIGHT-72)/2, 72, 72)];
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
    
    CGFloat statusAndNavHeight = (kSTATUSHEIGHT + 44) / 2;
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
    if (STLIsEmptyString(message)) return;
    
    //黑色半透明View
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectZero];
    blackView.tag = kHUDToastViewTag;
    blackView.backgroundColor = OSSVThemesColors.col_333333;
    blackView.layer.cornerRadius = 8;
    blackView.layer.masksToBounds = YES;
    [loadingSuperView addSubview:blackView];
    
    CGFloat horizontalMargin = 27;//水平方向间距
    CGFloat verticalMargin = 17;//垂直方向间距
    CGFloat maxTextWidth = SCREEN_WIDTH-horizontalMargin*4;
    
    //提示文案
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.frame = CGRectMake(0, 0, maxTextWidth, 0);
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = FontWithSize(14.0);
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.preferredMaxLayoutWidth = maxTextWidth;
    messageLabel.numberOfLines = 0;
    messageLabel.text = message;
    [messageLabel sizeToFit];
    messageLabel.size = CGSizeMake(MIN(messageLabel.size.width, maxTextWidth), messageLabel.size.height);
    [blackView addSubview:messageLabel];
    
    CGFloat blackViewWidth = MIN(messageLabel.size.width + horizontalMargin*2, SCREEN_WIDTH-horizontalMargin*2);
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

void ShowToastToViewWithTextTime(id parmaters ,NSString *message,CGFloat showTime) {
    
    UIView *loadingSuperView = QueryLoadingView(parmaters);
    //先移除老的Toast
    UIView *oldToastView = [loadingSuperView viewWithTag:kHUDToastViewTag];
    if (oldToastView) {
        [oldToastView removeFromSuperview];
    }
    
    CGFloat statusAndNavHeight = (kSTATUSHEIGHT + 44) / 2;
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
    if (STLIsEmptyString(message)) return;
    
    //黑色半透明View
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectZero];
    blackView.tag = kHUDToastViewTag;
    blackView.backgroundColor = OSSVThemesColors.col_333333;
    blackView.layer.cornerRadius = 8;
    blackView.layer.masksToBounds = YES;
    [loadingSuperView addSubview:blackView];
    
    CGFloat horizontalMargin = 27;//水平方向间距
    CGFloat verticalMargin = 17;//垂直方向间距
    CGFloat maxTextWidth = SCREEN_WIDTH-horizontalMargin*4;
    
    //提示文案
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.frame = CGRectMake(0, 0, maxTextWidth, 0);
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = FontWithSize(14.0);
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.preferredMaxLayoutWidth = maxTextWidth;
    messageLabel.numberOfLines = 0;
    messageLabel.text = message;
    [messageLabel sizeToFit];
    messageLabel.size = CGSizeMake(MIN(messageLabel.size.width, maxTextWidth), messageLabel.size.height);
    [blackView addSubview:messageLabel];
    
    CGFloat blackViewWidth = MIN(messageLabel.size.width + horizontalMargin*2, SCREEN_WIDTH-horizontalMargin*2);
    CGFloat blackViewHeight = messageLabel.size.height + verticalMargin*2;
    blackView.size = CGSizeMake(blackViewWidth, blackViewHeight);
    blackView.center = CGPointMake(loadingSuperView.width/2, loadingSuperView.height / 2 - statusAndNavHeight);
    
    messageLabel.center = CGPointMake(blackView.size.width/2, blackView.size.height/2);
    
    //NSInteger messageLength = message.length;
    CGFloat time = showTime;
    if (time < 1) {
        time = 1;
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
    blackView.backgroundColor = [OSSVThemesColors col_000000:0.65];
    blackView.layer.cornerRadius = 2;
    blackView.layer.masksToBounds = YES;
    [targetView addSubview:blackView];
    [blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(-12);
        make.height.mas_equalTo(48);
        make.top.mas_equalTo(kSCREEN_BAR_HEIGHT + 44 + offset + 4);
    }];
    
    //网络图标
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(@"nowifi")]];
    [blackView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(12);
        make.centerY.mas_equalTo(blackView);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    //提示文案
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = FontWithSize(14.0);
    messageLabel.numberOfLines = 2;
    messageLabel.text = STLLocalizedString_(@"HomeTopBar_NetworkErrorTipTitle",nil);
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
    
    CGFloat toolBarHeight = kSTATUSHEIGHT + 60;
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.frame = CGRectMake(0, -toolBarHeight, SCREEN_WIDTH, toolBarHeight);
    [superView addSubview:contentView];
    
    if ([title isKindOfClass:[NSString class]] && title.length > 0) {
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.backgroundColor = [UIColor clearColor];
        titleLab.textColor = OSSVThemesColors.col_2D2D2D;
        titleLab.font = FontWithSize(14);
        titleLab.text = title;
        [titleLab sizeToFit];
        titleLab.x = 20;
        titleLab.y = kSTATUSHEIGHT + (44 - titleLab.height)/2;
        [contentView addSubview:titleLab];
    }
    
    if ([btnTitle isKindOfClass:[NSString class]] && btnTitle.length > 0) {
        UIButton *popShareViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        popShareViewBtn.titleLabel.font = FontWithSize(14);
        popShareViewBtn.backgroundColor = OSSVThemesColors.col_2D2D2D;
        popShareViewBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [popShareViewBtn setTitle:btnTitle forState:0];
        [popShareViewBtn sizeToFit];
        popShareViewBtn.width += 20;
        popShareViewBtn.x = SCREEN_WIDTH-(popShareViewBtn.width+12);;
        popShareViewBtn.y = kSTATUSHEIGHT + (44 - popShareViewBtn.height)/2;
        [contentView addSubview:popShareViewBtn];
//        [popShareViewBtn addTouchUpInsideHandler:^(UIButton *btn) {
//            if (buttonBlcok) {
//                buttonBlcok();
//            }
//        }];
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
    if (STLJudgeNSDictionary(resultDict)) {
        NSString *error = STLToString(resultDict[kErrorKey]);
        if ([error integerValue] != 0) {
            
            NSString *msg = STLToString(resultDict[kMsgKey]);
            if (!STLIsEmptyString(msg)) {
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
//    [transparenceView addTapGestureWithComplete:^(UIView * _Nonnull view) {
//        @strongify(transparenceView)
//        if (buttonBlcok) {
//            buttonBlcok();
//        }
//        [transparenceView removeFromSuperview];
//    }];

    CGFloat imageStartY = (kSTATUSHEIGHT +44) + offset;
    UIImageView *bootomImageView = [[UIImageView alloc] init];
    bootomImageView.frame = CGRectMake(0, imageStartY, transparenceView.width, size.height);
    bootomImageView.contentMode = UIViewContentModeScaleAspectFill;
    bootomImageView.clipsToBounds = YES;
    bootomImageView.image = [UIImage imageNamed:bottomImgName];
    [transparenceView addSubview:bootomImageView];
    
    
    YYAnimatedImageView *gifImageView = [[YYAnimatedImageView alloc] init];
    gifImageView.image = [YYImage imageNamed:gifName];
    gifImageView.frame = CGRectMake(SCREEN_WIDTH - size.width, imageStartY, size.width, size.height);
    gifImageView.contentMode = UIViewContentModeScaleAspectFill;
    gifImageView.clipsToBounds = YES;
    [transparenceView addSubview:gifImageView];
}


@end
