//
//  YWLoginTypeSendCodeView.h
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWLoginModel.h"
#import "YWLoginTextField.h"
#import "ZFCountDownButton.h"

typedef void(^EmailTextFieldEditingChangeHandler)(YWLoginTextField *textField);
typedef void(^DidClickSendCode)(ZFCountDownButton *sendCodeButton);
@interface YWLoginTypeSendCodeView : UIView

@property (nonatomic, weak) YWLoginModel                              *model;
@property (nonatomic, strong) YWLoginTextField                        *emailTextField;

@property (nonatomic, copy) EmailTextFieldEditingChangeHandler        emailTextFieldEditingChangeHandler;
@property (nonatomic, copy) DidClickSendCode                          sendCodeHandler;

@end
