//
//  BigClickAreaButton.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BigClickAreaButton : UIButton

/// 1.想要放大 btn 的点击热区的范围,注意,只在 btn 的父视图范围内有效
/// 2.这个范围是按钮的整体宽度,如果需要以中心点开始计算,则需要*2
@property (nonatomic,assign) CGFloat clickAreaRadious;

@end
