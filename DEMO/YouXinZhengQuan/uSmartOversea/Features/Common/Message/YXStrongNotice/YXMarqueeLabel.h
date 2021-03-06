//
//  YXMarqueeLabel.h
//  YouXinZhengQuan
//
//  Created by Evan on 2021/10/8.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 参考 QMUIMarqueeLabel 实现增加 enableMarqueeAnimation 属性控制
@interface YXMarqueeLabel : UILabel

/// 控制滚动的速度，1 表示一帧滚动 1pt，10 表示一帧滚动 10pt，默认为 .5，与系统一致。
@property(nonatomic, assign) IBInspectable CGFloat speed;

/// 当文字第一次显示在界面上，以及重复滚动到开头时都要停顿一下，这个属性控制停顿的时长，默认为 2.5（也是与系统一致），单位为秒。
@property(nonatomic, assign) IBInspectable NSTimeInterval pauseDurationWhenMoveToEdge;

/// 用于控制首尾连接的文字之间的间距，默认为 40pt。
@property(nonatomic, assign) IBInspectable CGFloat spacingBetweenHeadToTail;

// 用于控制左和右边两端的渐变区域的百分比，默认为 0.2，则是 20% 宽。
@property(nonatomic, assign) IBInspectable CGFloat fadeWidthPercent;

/**
 *  自动判断 label 的 frame 是否超出当前的 UIWindow 可视范围，超出则自动停止动画。默认为 YES。
 *  @warning 某些场景并无法触发这个自动检测（例如直接调整 label.superview 的 frame 而不是 label 自身的 frame），这种情况暂不处理。
 */
@property(nonatomic, assign) IBInspectable BOOL automaticallyValidateVisibleFrame;

/// 在文字滚动到左右边缘时，是否要显示一个阴影渐变遮罩，默认为 YES。
@property(nonatomic, assign) IBInspectable BOOL shouldFadeAtEdge;

/// YES 表示文字会在打开 shouldFadeAtEdge 的情况下，从左边的渐隐区域之后显示，NO 表示不管有没有打开 shouldFadeAtEdge，都会从 label 的边缘开始显示。默认为 NO。
/// @note 如果文字宽度本身就没超过 label 宽度（也即无需滚动），此时必定不会显示渐隐，则这个属性不会影响文字的显示位置。
@property(nonatomic, assign) IBInspectable BOOL textStartAfterFade;

/// 开启走马灯效果，默认为 NO。
@property(nonatomic, assign) BOOL enableMarqueeAnimation;

@end


/// 如果在可复用的 UIView 里使用（例如 UITableViewCell、UICollectionViewCell），由于 UIView 可能重复被使用，因此需要在某些显示/隐藏的时机去手动开启/关闭 label 的动画。如果在普通的 UIView 里使用则无需关注这一部分的代码。
@interface YXMarqueeLabel (ReusableView)

/**
 *  尝试开启 label 的滚动动画
 *  @return 是否成功开启
 */
- (BOOL)requestToStartAnimation;

/**
 *  尝试停止 label 的滚动动画
 *  @return 是否成功停止
 */
- (BOOL)requestToStopAnimation;

@end
