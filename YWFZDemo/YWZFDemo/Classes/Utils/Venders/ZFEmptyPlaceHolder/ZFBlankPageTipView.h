//
//  CCParkingRequestTipView.h
//  CommonFrameWork
//
//  Created by YW on 2016/11/24.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFBlankPageTipView : UIView

//当前提示view在父视图上的tag
#define kRequestTipViewTag      1990

@property (nonatomic, strong) UIButton *actionBtn;

/**
 返回一个提示空白view

 @param frame       提示View大小
 @param moveOffsetY 只能上移距离
 @param topImage    图片名字
 @param title       提示标题
 @param subTitle    提示副标题
 @param title       按钮标题
 @param block       点击按钮回调Block
 @return 提示空白view
 */
+ (ZFBlankPageTipView *)tipViewByFrame:(CGRect)frame
                           moveOffsetY:(CGFloat)moveOffsetY
                              topImage:(UIImage *)image
                                 title:(id)title
                              subTitle:(id)subTitle
                           actionTitle:(id)buttonTitle
                           actionBlock:(void(^)(void))block;

@end

