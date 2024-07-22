//
//  ZFTitleArrowTipView.h
//  ZZZZZ
//
//  Created by YW on 2018/12/20.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
     |---   上左   ----|           |---   上右   ---|
     |<---箭头尖位置--->|           | <--箭头尖位置-->|
-----|----------------^-----------^---------------|------------------
     |                                            |    |
左上 <|                                            |    箭头尖位置
     |                                            |    |
     |                                            |>---右上
     |                                            |
     |                                            |
     |                                            |
     |                                            |
     |                                            |>---右下
     |                                            |    |
左下 <|                                            |    箭头尖位置
     |                                            |    |
-----|----------------V-----------V---------------|------------------
     |---   下左   ----|           |---   下右   ---|
     |<---箭头尖位置--->|           | <--箭头尖位置-->|
 */



typedef NS_ENUM(NSInteger,ZFTitleArrowTipDirect) {
    /**上左*/
    ZFTitleArrowTipDirectUpLeft,
    /**上右*/
    ZFTitleArrowTipDirectUpRight,
    /**下左*/
    ZFTitleArrowTipDirectDownLeft,
    /**下右*/
    ZFTitleArrowTipDirectDownRight,
    
    /**左上*/
    ZFTitleArrowTipDirectLeftUp,
    /**左下*/
    ZFTitleArrowTipDirectLeftDown,
    /**右上*/
    ZFTitleArrowTipDirectRightUp,
    /**右下*/
    ZFTitleArrowTipDirectRightDown,
};

@interface ZFTitleArrowTipView : UIView

/*
 * direct: 箭头方向
 * offset: 箭头【尖】距离设置方向的距离,
 * offset: < 0,居中
 */
- (instancetype)initTipArrowOffset:(CGFloat)offset
                            direct:(ZFTitleArrowTipDirect)direct
                           content:(NSString *)content;

/*
 * direct: 箭头方向
 * offset: 箭头【尖】距离设置方向的距离
 * offset: < 0,居中
 * content: 【nil】:不处理， 【@""】：若原先显示内容，设置则隐藏视图，其他不处理
 */
- (void)updateTipArrowOffset:(CGFloat)offset
                      direct:(ZFTitleArrowTipDirect)direct
                      cotent:(NSString *)content;

/*
 * direct: 箭头方向
 * offset: 箭头【尖】距离设置方向的距离
 * contentView:【nil】隐藏视图
 */

- (void)updateTipArrowOffset:(CGFloat)offset
                      direct:(ZFTitleArrowTipDirect)direct
                 contentView:(UIView *)contentView;

/*
 * time: 设置自动隐藏时间
 * completion:
 */
- (void)hideViewWithTime:(NSInteger)time complectBlock:(void (^)(void))completion;

- (void)hideView;

/*
 * 获取视图相对Window坐标
 * sourceView: 目标视图
 */
+ (CGRect)sourceViewFrameToWindow:(UIView *)sourceView;

@end

