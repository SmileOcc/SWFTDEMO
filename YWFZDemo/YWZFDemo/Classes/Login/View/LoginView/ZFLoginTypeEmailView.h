//
//  YWLoginTypeEmailView.h
//  ZZZZZ
//
//  Created by YW on 26/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWLoginModel.h"
#import "YWLoginTextField.h"

typedef void(^EmailTextFieldEditingDidEndHandler)(BOOL isShowError,YWLoginModel *model);
typedef void(^EmailTextFieldCheckValidEmailBlock)(NSString *message);
typedef void(^EmailTextFieldEditingChangeHandler)(YWLoginTextField *textField);

@interface YWLoginTypeEmailView : UIView

@property (nonatomic, copy)   EmailTextFieldEditingDidEndHandler      emailTextFieldEditingDidEndHandler;
@property (nonatomic, strong) YWLoginModel                            *model;
@property (nonatomic, strong) YWLoginTextField                        *emailTextField;
///是否显示提示邮箱，默认为YES
@property (nonatomic, assign) BOOL isShowTipsEmail;
@property (nonatomic, copy) EmailTextFieldCheckValidEmailBlock        checkValidRequestComplation;
@property (nonatomic, copy) EmailTextFieldEditingChangeHandler        emailTextFieldEditingChangeHandler;

/// 国家id
@property (nonatomic, copy) NSString *region_id;



- (void)checkValidEmail;

- (void)showErrorAnimation;

- (void)setupErrorTip:(BOOL)isForgotPassword;

- (void)setupErrorMessage:(NSString *)errorMessage;

@end
