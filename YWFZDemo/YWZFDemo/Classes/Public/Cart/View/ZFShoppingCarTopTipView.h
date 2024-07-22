//
//  ZFShoppingCarTopTipView.h
//  ZZZZZ
//
//  Created by YW on 2018/9/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TapTopTipViewBlock)(void);

@interface ZFShoppingCarTopTipView : UIView

@property (nonatomic, copy) TapTopTipViewBlock tapTopTipViewBlock;

- (void)cartTipText:(NSString *)cartTipText
          showArrow:(BOOL)showArrow
            bgColor:(UIColor *)bgColor;

- (CGFloat)emptViewMinHeight;
@end
