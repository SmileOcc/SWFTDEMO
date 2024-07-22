//
//  ZFMyOrderListTopTipView.h
//  ZZZZZ
//
//  Created by YW on 2018/11/29.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFMyOrderListTopTipView : UIView

- (instancetype)initWithFrame:(CGRect)frame tip:(NSString *)tipText arrow:(BOOL)showArrow;

- (void)tipText:(NSString *)tipText showArrow:(BOOL)showArrow;
@end

