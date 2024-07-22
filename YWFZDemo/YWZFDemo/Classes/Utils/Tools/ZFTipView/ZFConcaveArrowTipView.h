//
//  ZFConcaveArrowTipView.h
//  ZZZZZ
//
//  Created by YW on 2019/3/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 |---   上左   ----|           |---   上右   ---|
 |<---箭头尖位置--->|           | <--箭头尖位置-->|
 -----|----------------v-----------v---------------|------------------
 |                                            |    |
 左上 >|                                            |    箭头尖位置
 |                                            |    |
 |                                            |<---右上
 |                                            |
 |                                            |
 |                                            |
 |                                            |
 |                                            |<---右下
 |                                            |    |
 左下 >|                                            |    箭头尖位置
 |                                            |    |
 -----|----------------^-----------^---------------|------------------
 |---   下左   ----|           |---   下右   ---|
 |<---箭头尖位置--->|           | <--箭头尖位置-->|
 */


typedef NS_ENUM(NSInteger, ZFConcaveArrowTipDirect) {
    
    /**向上没偏移量，居中*/
    ZFConcaveArrowTipDirectUpNoOffset,
    /**向左没偏移量，居中*/
    ZFConcaveArrowTipDirectLeftNoOffset,
    /**向下没偏移量，居中*/
    ZFConcaveArrowTipDirectDownNoOffset,
    /**向右没偏移量，居中*/
    ZFConcaveArrowTipDirectRightNoOffset,
    
    /**上左*/
    ZFConcaveArrowTipDirectUpLeft,
    /**上右*/
    ZFConcaveArrowTipDirectUpRight,
    /**下左*/
    ZFConcaveArrowTipDirectDownLeft,
    /**下右*/
    ZFConcaveArrowTipDirectDownRight,
    
    /**左上*/
    ZFConcaveArrowTipDirectLeftUp,
    /**左下*/
    ZFConcaveArrowTipDirectLeftDown,
    /**右上*/
    ZFConcaveArrowTipDirectRightUp,
    /**右下*/
    ZFConcaveArrowTipDirectRightDown,
};

// 凹箭头视图
@interface ZFConcaveArrowTipView : UIView

/**

 @param offset 箭头尖偏移位置：< 0,居中
 @param direct 箭头【尖】距离设置方向的距离,
 @param content 文案
 @param arrowWidth 箭头宽度：< 0,默认16
 @param arrowHeight 箭头高度：< 0,默认16
 @param topSpace 内容视图上下间隙值：< 0,默认12
 @param leadSpace 内容视图左右间隙值：< 0,默认18
 @param textFont 字体：默认
 @param textColor 字体颜色：默认
 @param textBackgroundColor 字体背景颜色：默认无
  @param backgroundColr 背景颜色：默认 白
 @return
 */
- (instancetype)initTipArrowOffset:(CGFloat)offset
                            direct:(ZFConcaveArrowTipDirect)direct
                           content:(NSString *)content
                        arrowWidth:(CGFloat)arrowWidth
                       arrowHeight:(CGFloat)arrowHeight
                          topSpace:(CGFloat)topSpace
                         leadSpace:(CGFloat)leadSpace
                          textFont:(UIFont *)textFont
                         textColor:(UIColor *)textColor
               textBackgroundColor:(UIColor *)textBackgroundColor
                   backgroundColor:(UIColor *)backgroundColr;
/*
 * direct: 箭头方向
 * offset: 箭头【尖】距离设置方向的距离
 * offset: < 0,居中
 * content: 【nil】:不处理， 【@""】：若原先显示内容，设置则隐藏视图，其他不处理
 */
- (void)updateTipArrowOffset:(CGFloat)offset
                      direct:(ZFConcaveArrowTipDirect)direct
                      cotent:(NSString *)content;

/*
 * time: 设置自动隐藏时间
 * completion:
 */
- (void)hideViewWithTime:(NSInteger)time complectBlock:(void (^)(void))completion;

- (void)hideView;
@end

