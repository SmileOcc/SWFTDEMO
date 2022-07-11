//
//  YXPasswordSetAlertView.h
//  uSmartOversea
//
//  Created by JC_Mac on 2018/10/18.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXPasswordResetView.h"

typedef NS_ENUM(NSUInteger, YXPasswordSetAlertType){
//    YXPasswordSetAlertTypePwd = 0, //设置交易密码输入
//    YXPasswordSetAlertTypeConfirm, //设置交易密码确认输入
    YXPasswordSetAlertTypeValid,   //验证交易密码
};

@protocol YXPasswordSetAlertViewDelegate <NSObject>

@optional

//- (void)passwordSetAlertViewDidSetPwd:(NSString *)pwd;
- (void)passwordSetAlertViewDidValidPwd:(NSString *)pwd;
- (void)alertWithMsg:(NSString *)msg alertType:(YXPasswordSetAlertType)alertType;

@end

@interface YXPasswordSetAlertView : UIView

@property (nonatomic, strong)YXPasswordResetView *passwordResetView;
@property (nonatomic, strong) UIButton *dismissBtn;
@property (nonatomic, copy) NSString *pwd;
@property (nonatomic, copy) NSString *pwdConfirm;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, assign) YXPasswordSetAlertType alertType;
@property (nonatomic, weak) id<YXPasswordSetAlertViewDelegate>delegate;




@end

