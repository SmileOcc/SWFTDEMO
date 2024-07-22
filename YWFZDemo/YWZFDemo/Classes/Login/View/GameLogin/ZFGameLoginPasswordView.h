//
//  ZFGameLoginPasswordView.h
//  ZZZZZ
//
//  Created by YW on 2018/9/27.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWLoginTypePasswordView.h"

@protocol ZFGameLoginPasswordViewDelegate <NSObject>

///点击回退
- (void)ZFGameLoginPasswordViewDidClickClose;

///点击跳转到大登录页
- (void)ZFGameLoginPasswordViewDidClickJumpLogin;

///点击登录按钮
- (void)ZFGameLoginPasswordViewDidClickLogin;

///点击忘记密码按钮
- (void)ZFGameLoginPasswordViewDidClickForgetPassword;

@end

@interface ZFGameLoginPasswordView : UIView

-(void)passwordBecomeFirstResponder;

@property (nonatomic, strong) YWLoginTypePasswordView *passwordView;
@property (nonatomic, weak) id<ZFGameLoginPasswordViewDelegate>delegate;

@end

