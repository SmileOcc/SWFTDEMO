//
//  YWLoginFooterView.h
//  ZZZZZ
//
//  Created by YW on 26/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWLoginModel.h"

typedef enum : NSUInteger {
    TreatyLinkAction_ProvacyPolicy,
    TreatyLinkAction_TermsUse,
} ZFTreatyLinkAction;

typedef void(^GoogleplusButtonCompletionHandler)(void);
typedef void(^FacebookButtonCompletionHandler)(void);
typedef void(^VKButtonCompletionHandler)(void);
typedef void(^RegisterPrivacyPolicyActionBlock)(ZFTreatyLinkAction actionType);

@interface YWLoginFooterView : UIView

@property (nonatomic, copy) GoogleplusButtonCompletionHandler       googleplusButtonCompletionHandler;
@property (nonatomic, copy) FacebookButtonCompletionHandler         facebookButtonCompletionHandler;
@property (nonatomic, copy) VKButtonCompletionHandler         vkButtonCompletionHandler;
@property (nonatomic, copy) RegisterPrivacyPolicyActionBlock        privacyPolicyActionBlock;

@property (nonatomic, strong) YWLoginModel   *model;

- (void)configurationRus:(BOOL)isRus;


@end
