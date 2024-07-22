//
//  VerificationView.h
//  ZZZZZ
//
//  Created by DBP on 17/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CodeStrBlock)(NSString *codeStr);
typedef void (^SendCodeBlock)(void);
@interface VerificationView : UIView

@property (nonatomic,copy) CodeStrBlock codeBlock; //校验验证码
@property (nonatomic,copy) SendCodeBlock sendCodeBlock; // 发送验证码
@property (nonatomic, assign) BOOL isCodeSuccess; //校验是否成功
- (instancetype)init;

- (void)showTitle:(NSString *)title andCode:(NSString *)code andphoneNum:(NSString *)phoneNum;
- (void)dismiss;
- (void)stopTimer;

@end
