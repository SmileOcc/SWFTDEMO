//
//  OSSVSMSVerifysView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVSMSVerifysView : UIView

- (void)coolse;
- (void)setUserPhoneNum:(NSString *)userPhoneNum paymentAmount:(NSString *)paymentAmount;
@property (nonatomic, copy) void(^sendSMSRequestBlock)();
@property (nonatomic, copy) void(^verifyCodeRequestBlock)(NSString *code);
@property (nonatomic, copy) void(^verifyCodeAnalyticBlock)(BOOL hasCode);

@property (nonatomic, copy) void(^closeSMSBlock)();
@property (nonatomic, copy) NSString *prompt;
@property (nonatomic, assign) BOOL    isShow;

@end
