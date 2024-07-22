//
//  ZFCameraImageCutView.h
//  ZZZZZ
//
//  Created by YW on 2018/7/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 意图搜索剪切蒙层
 */
@interface ZFCameraImageCutView : UIView

- (CGRect)cutResultImageRect;
- (void)setPreCutRect:(CGRect)cutFrame;

@end
