//
//  ZFGameLoginView.h
//  ZZZZZ
//
//  Created by YW on 2018/9/28.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^gameLoginCompletion)(void);

@interface ZFGameLoginView : UIView

- (void)showLoginView:(UIView *)parentView success:(gameLoginCompletion)completion;

- (void)hiddenLoginView;

@end

NS_ASSUME_NONNULL_END
