//
//  YWLoginTypePasswordView.h
//  ZZZZZ
//
//  Created by YW on 26/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWLoginModel.h"    
#import "YWLoginTextField.h"

typedef void(^PasswordTextFieldEditingDidEndHandler)(BOOL isShowError,YWLoginModel *model);
typedef void(^PasswordTextFieldDoneHandler)(YWLoginModel *model);

@interface YWLoginTypePasswordView : UIView
@property (nonatomic, strong) YWLoginTextField   *passwordTextField;

@property (nonatomic, copy)   PasswordTextFieldEditingDidEndHandler      passwordTextFieldEditingDidEndHandler;
@property (nonatomic, copy)   PasswordTextFieldDoneHandler               passwordTextFieldDoneHandler;
@property (nonatomic, strong) YWLoginModel                               *model;
///是否显示done按钮，默认YES
@property (nonatomic, assign) BOOL                                       isShowDone;

- (BOOL)checkValidPassword;

@end
