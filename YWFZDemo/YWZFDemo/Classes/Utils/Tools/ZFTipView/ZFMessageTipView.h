//
//  ZFMessageTipView.h
//  ZZZZZ
//
//  Created by YW on 2019/1/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZFMessageTipView : UIView

- (instancetype)initMessage:(NSString *)message
                       font:(UIFont *)font
                  textColor:(UIColor *)textColor
            backgroundColor:(UIColor *)backgroundColor
                     corner:(CGFloat)corner;

- (void)showTime:(CGFloat)time completion:(void (^)(void))completion;

@end

