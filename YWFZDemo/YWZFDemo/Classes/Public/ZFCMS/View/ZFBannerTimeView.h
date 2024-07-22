//
//  ZFBannerTimeView.h
//  ZZZZZ
//
//  Created by YW on 24/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, ZFBannerTimePosition) {
    /**上左*/
    ZFBannerTimePositionTopLeft,
    /**上中*/
    ZFBannerTimePositionTopCenter,
    /**上右*/
    ZFBannerTimePositionTopRight,
    /**中左*/
    ZFBannerTimePositionCenterLeft,
    /**中*/
    ZFBannerTimePositionCenter,
    /**中右*/
    ZFBannerTimePositionCenterRight,
    /**下左*/
    ZFBannerTimePositionBottomLeft,
    /**下中*/
    ZFBannerTimePositionBottomCenter,
    /**下右*/
    ZFBannerTimePositionBottomRight,
};

@interface ZFBannerTimeView : UIView

///背景颜色 默认 blackColor
@property (nonatomic, strong) UIColor *textBgColor;
///文字颜色 默认 whiteColor
@property (nonatomic, strong) UIColor *textColor;
///dot颜色 默认 blackColor
@property (nonatomic, strong) UIColor *dotColor;
///是否显示天 默认显示
@property (nonatomic, assign) BOOL isShowDay;

/**
 开启倒计时任务

 @param timeStamp 倒计时总秒数
 @param timerKey 去全局单利定时器中取相应的定时器key
 */
- (void)startCountDownTimerStamp:(NSString *)timeStamp
                    withTimerKey:(NSString *)timerKey;


//默认：上中
+ (ZFBannerTimePosition)getBannerTimePosition:(NSString *)position;
+ (CGFloat)minContentViewHeight;
@end
