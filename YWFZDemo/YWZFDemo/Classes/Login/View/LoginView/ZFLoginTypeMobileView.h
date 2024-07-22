//
//  YWLoginTypeMobileView.h
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  电话号码登录视图

#import <UIKit/UIKit.h>
#import "YWLoginModel.h"
#import "YWLoginTextField.h"

typedef void(^EmailTextFieldEditingDidEndHandler)(BOOL isShowError,YWLoginModel *model);
typedef void(^EmailTextFieldEditingChangeHandler)(YWLoginTextField *textField);

@interface YWLoginTypeMobileView : UIView

@property (nonatomic, copy)   EmailTextFieldEditingDidEndHandler      emailTextFieldEditingDidEndHandler;
@property (nonatomic, weak) YWLoginModel                              *model;
@property (nonatomic, strong) YWLoginTextField                        *emailTextField;
@property (nonatomic, copy) EmailTextFieldEditingChangeHandler        emailTextFieldEditingChangeHandler;

- (BOOL)checkValidMobile;

- (void)showErrorAnimation;

- (void)setupErrorMessage:(NSString *)errorMessage;

@end

