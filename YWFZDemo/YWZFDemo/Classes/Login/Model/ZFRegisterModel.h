//
//  ZFRegisterModel.h
//  ZZZZZ
//
//  Created by YW on 30/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFRegisterModel : NSObject

@property (nonatomic, copy) NSString   *email;
@property (nonatomic, copy) NSString   *nickName;
@property (nonatomic, copy) NSString   *gender;

@property (nonatomic, assign) BOOL   isValidEmail;
@property (nonatomic, assign) BOOL   showEmailError;
@property (nonatomic, assign) BOOL   showAgreeTipAnimation;
@property (nonatomic, assign) BOOL   showSubTipAnimation;
@property (nonatomic, assign) BOOL   isAgree;
@property (nonatomic, assign) BOOL   isSubscribe;

/// 自定义
@property (nonatomic, copy) NSString *errorMsg;



@end
