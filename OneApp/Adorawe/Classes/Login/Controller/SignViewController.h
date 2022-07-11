//
//  SignViewController.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"

typedef void (^SuccessSignBlock)();
typedef void (^SuccessSignUpBlock)();
typedef void (^CloseSignUpBlock)();
typedef void (^GuestCheckOutAction)();

@interface SignViewController : STLBaseCtrl

@property (nonatomic, copy) SuccessSignBlock signBlock;

@property (nonatomic, copy) SuccessSignBlock modalBlock;

@property (nonatomic, copy) SuccessSignUpBlock signUpBlock;

@property (nonatomic, copy) CloseSignUpBlock closeBlock;

@property (nonatomic, copy) GuestCheckOutAction guestCheckOutAction;

/** 状态 1.登录 2.注册 */
@property (nonatomic, assign) NSInteger state;

// 是否是点击check out 进入的
@property (nonatomic, assign) BOOL isCheckOutIn;

@end
