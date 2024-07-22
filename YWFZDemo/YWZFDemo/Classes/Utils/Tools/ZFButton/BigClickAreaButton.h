//
//  BigClickAreaButton.h
//  ZZZZZ
//
//  Created by YW on 16/12/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BigClickAreaButton : UIButton

/// 1.想要放大 btn 的点击热区的范围,注意,只在 btn 的父视图范围内有效
/// 2.这个范围是按钮的整体宽度,如果需要以中心点开始计算,则需要*2
@property (nonatomic,assign) CGFloat clickAreaRadious;

@end


@interface ZFLimitImageRectButton : UIButton

// 限制按钮图片的显示CGRect
@property (nonatomic, assign) CGRect imageRect;

// 限制按钮标题的显示CGRect
@property (nonatomic, assign) CGRect titleRect;

// 限制按钮图片的遮罩显示CGRect
@property (nonatomic, assign) CGRect imageMaskRect;

@end
