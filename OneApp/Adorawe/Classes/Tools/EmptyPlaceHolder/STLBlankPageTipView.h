//
//  STLBlankPageTipView.h
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface STLBlankPageTipView : UIView

//当前提示view在父视图上的tag
#define kRequestTipViewTag      1990

@property (nonatomic, strong) UIButton *actionBtn;

/**
 返回一个提示空白view

 @param frame       提示View大小
 @param topDistance 距离上距离 优先级大于 moveOffsetY
 @param moveOffsetY 只能上移距离
 @param topImage    图片名字
 @param title       提示标题
 @param subTitle    提示副标题
 @param title       按钮标题
 @param block       点击按钮回调Block
 @return 提示空白view
 */
+ (STLBlankPageTipView *)tipViewByFrame:(CGRect)frame
                            topDistance:(CGFloat)topDistance
                            moveOffsetY:(CGFloat)moveOffsetY
                               topImage:(UIImage *)image
                                  title:(id)title
                               subTitle:(id)subTitle
                            actionTitle:(id)buttonTitle
                            actionBlock:(void(^)(void))block;

@end

NS_ASSUME_NONNULL_END
